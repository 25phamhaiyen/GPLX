  import { useEffect, useState } from "react";
  import { useForm } from "react-hook-form";
  import { zodResolver } from "@hookform/resolvers/zod";
  import { z } from "zod";
  import { api } from "@/lib/api";
  import { EntityConfig, FieldDef } from "@/lib/entities";
  import { Button } from "@/components/ui/button";
  import { Input } from "@/components/ui/input";
  import { Label } from "@/components/ui/label";
  import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
  import { toast } from "sonner";
  import { useAuth } from "@/hooks/useAuth";

  interface Props {
    entity: EntityConfig;
    open: boolean;
    onClose: () => void;
    initial?: Record<string, unknown> | null;
    onSaved: () => void;
  }

  function getValue(obj: unknown, path: string): unknown {
    return path.split(".").reduce<unknown>((acc, key) => {
      if (acc && typeof acc === "object") return (acc as Record<string, unknown>)[key];
      return undefined;
    }, obj);
  }

  function getCourseLicenseType(course: Record<string, unknown>) {
  return Number(
    course.MaLoaiBang ||
    (course as any)?.LoaiBangLai?.MaLoaiBang ||
    (course as any)?.LoaiBang?.MaLoaiBang ||
    0
  );
}

  function buildSchema(fields: FieldDef[], userRole?: string) {
    const shape: Record<string, z.ZodTypeAny> = {};
    fields.forEach((f) => {
      if (f.type === "display") return;

      // If field is hidden for this role, don't require it on frontend
      const isHidden = userRole === "HOCVIEN" && (f.name === "MaHocVien" || f.adminOnly);
      
      let s: z.ZodTypeAny;
      if (f.type === "number") {
        s = z.coerce.number({ invalid_type_error: "Vui lòng nhập số" });
        if (f.required && !isHidden) s = (s as z.ZodNumber).min(0, `${f.label} là bắt buộc`);
        else s = s.nullable().optional();
      } 
      else if (f.type === "date") {
        s = z.string();
        if (f.required && !isHidden) s = (s as z.ZodString).min(1, `${f.label} là bắt buộc`);
        else s = s.nullable().optional();
      }
      else if (f.type === "email") {
        s = z.string().email("Email không hợp lệ");
        if (f.required && !isHidden) s = (s as z.ZodString).min(1, `${f.label} là bắt buộc`);
        else s = s.nullable().optional().or(z.literal(""));
      }
      else if (f.type === "select" || f.type === "file") {
        const isNumeric = !!f.optionsFrom || (f.options && typeof f.options[0]?.value === "number");
        if (isNumeric) {
          s = (f.required && !isHidden) ? z.coerce.number().min(1, `${f.label} là bắt buộc`) : z.coerce.number().nullable().optional();
        } else {
          s = (f.required && !isHidden) ? z.string().min(1, `${f.label} là bắt buộc`) : z.string().nullable().optional();
        }
      }
      else {
        s = z.string();
        if (f.required && !isHidden) s = (s as z.ZodString).min(1, `${f.label} là bắt buộc`);
        else s = s.nullable().optional();
      }
      
      shape[f.name] = s;
    });
    return z.object(shape);
  }

  export function EntityForm({ entity, open, onClose, initial, onSaved }: Props) {
    const { user } = useAuth();
    const schema = buildSchema(entity.fields, user?.role);
    type FormValues = Record<string, unknown>;
    const { register, handleSubmit, reset, watch, setValue, formState: { errors, isSubmitting } } = useForm<FormValues>({
      resolver: zodResolver(schema),
    });

    const [fileUrls, setFileUrls] = useState<Record<string, string>>({});
    const [options, setOptions] = useState<Record<string, Array<Record<string, unknown>>>>({});
    const [forbiddenLicenseTypes, setForbiddenLicenseTypes] = useState<number[]>([]);
    const watchMaLoaiBang = watch("MaLoaiBang");
    const watchMaKhoaHoc = watch("MaKhoaHoc");
    const watchMaHoSo = watch("MaHoSo");
    const watchDiemLyThuyet = watch("DiemLyThuyet");
    const watchDiemThucHanh = watch("DiemThucHanh");
    const [passingScores, setPassingScores] = useState({ lt: 8, th: 8 });

    useEffect(() => {
      const selects = entity.fields.filter((f) => f.type === "select" && f.optionsFrom);
      Promise.allSettled(
        selects.map((f) =>
          api.get(`/${f.optionsFrom}`, { params: { pageSize: 500 } }).then((r) => {
            let data = r.data.data;
            if (f.optionsFrom === "hocvien") {
              data = data.filter((h: any) => !String(h.TenDangNhap).toLowerCase().includes("admin"));
            }
            return [f.name, data] as const;
          })
        )
      ).then((results) => {
        const opts: Record<string, any[]> = {};
        results.forEach((result, index) => {
          if (result.status === "fulfilled") {
            const [name, data] = result.value;
            opts[name] = data;
          } else {
            console.error(`Failed to load options for ${selects[index].name}:`, result.reason);
          }
        });
        setOptions(opts);
        if (entity.key === "hosodangky" && user?.role === "HOCVIEN") {
          api.get("/gplx", { params: { pageSize: 500 } })
            .then((r) => {
              const excluded = Array.from(
                new Set(
                  r.data.data
                    .map((g: any) => Number(g.MaLoaiBang))
                    .filter((v: number) => !Number.isNaN(v)),
                ),
              ) as number[];
              setForbiddenLicenseTypes(excluded);
            })
            .catch((err) => console.error("Failed to load current GPLX types:", err));
        }
      });
    }, [entity.key, user?.role]);

    // --- CORE AUTOMATION LOGIC ---
    useEffect(() => {
      if (!open) return;

      // 1. HoSoDangKy: Auto-fill from License Type & Course
      if (entity.key === "hosodangky") {
        if (watchMaKhoaHoc) {
          api.get(`/khoahoc/${watchMaKhoaHoc}`).then(r => {
            if (r.data.NgayKetThuc) {
              const examDate = new Date(r.data.NgayKetThuc);
              examDate.setDate(examDate.getDate() + (r.data.LoaiBangLai?.ThoiGianThiSauKhoaHoc || 7));
              setValue("ThoiGianThiDuKien", examDate.toISOString().slice(0, 10));
            }
          });
        }
      }

      // 2. ThongTinThi: Auto-fill LichThi from HoSo's KhoaHoc
      if (entity.key === "thongtinthi") {
        if (watchMaHoSo) {
          api.get(`/hosodangky/${watchMaHoSo}`).then(async r => {
            let lichThiId = r.data.KhoaHoc?.LichThi?.[0]?.MaLichThi;
            if (!lichThiId && r.data.MaKhoaHoc) {
              try {
                const res = await api.get("/lichthi", { params: { pageSize: 100 } });
                const kt = res.data.data.find((e: any) => Number(e.MaKhoaHoc) === Number(r.data.MaKhoaHoc));
                if (kt) lichThiId = kt.MaLichThi;
              } catch (err) {
                console.error("Failed to fetch lichthi:", err);
              }
            }
            if (lichThiId) setValue("MaLichThi", Number(lichThiId));
            else toast.error("Không tìm thấy lịch thi liên kết với khóa học này!");
          });
        }
        setValue("NgayNhapDiem", new Date().toISOString().slice(0, 10));
      }
    }, [entity.key, open, watchMaLoaiBang, watchMaKhoaHoc, watchMaHoSo, watchDiemLyThuyet, watchDiemThucHanh, passingScores]);

    useEffect(() => {
      if (open) {
        const data: Record<string, unknown> = {};
        entity.fields.forEach((f) => {
          const v = initial?.[f.name];
          if (f.type === "date" && v) data[f.name] = String(v).slice(0, 10);
          else if (f.type === "file" && v) {
            setFileUrls({ [f.name]: String(v) });
            data[f.name] = v;
          }
          else data[f.name] = v ?? "";
        });
        reset(data);
      }
    }, [open, initial, entity.key]);

    const onSubmit = async (values: FormValues) => {
      try {
        const payload: Record<string, unknown> = {};
        Object.entries(values).forEach(([k, v]) => {
          if (v === "" || v === undefined) return;
          payload[k] = v;
        });
        if (initial) {
          await api.put(`/${entity.key}/${initial[entity.idField]}`, payload);
          toast.success("Cập nhật thành công");
        } else {
          await api.post(`/${entity.key}`, payload);
          toast.success("Thêm mới thành công");
        }
        onSaved();
        onClose();
      } catch { /* handled */ }
    };

    return (
      <Dialog open={open} onOpenChange={(v) => !v && onClose()}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{initial ? "Cập nhật" : "Thêm mới"} {entity.label}</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {entity.fields.map((f) => {
              if (user?.role === "HOCVIEN" && (f.name === "MaHocVien" || f.adminOnly)) return null;

              // For HoSoDangKy
if (entity.key === "hosodangky") {
  // Chỉ ẩn MaLoaiBang nếu học viên chỉ còn 1 loại bằng có thể đăng ký
  if (f.name === "MaLoaiBang" && forbiddenLicenseTypes.length > 0) {
    const availableLicenseTypes =
      (options["MaLoaiBang"] || []).filter(
        (o) =>
          !forbiddenLicenseTypes.includes(
            Number(o[entity.fields.find(x => x.name === "MaLoaiBang")?.optionValue!])
          )
      );

    if (availableLicenseTypes.length === 1) {
      setValue(
        "MaLoaiBang",
        Number(
          availableLicenseTypes[0][
            entity.fields.find(x => x.name === "MaLoaiBang")?.optionValue!
          ]
        )
      );
      return null;
    }
  }
}

let fieldOptions = options[f.name] || [];

// ======================
// FILTER MaLoaiBang
// ======================
if (entity.key === "hosodangky" && f.name === "MaLoaiBang") {
  fieldOptions = fieldOptions.filter(
    (o) => !forbiddenLicenseTypes.includes(Number(o[f.optionValue!]))
  );
}

// ======================
// FILTER MaKhoaHoc
// ======================
if (entity.key === "hosodangky" && f.name === "MaKhoaHoc") {
  fieldOptions = fieldOptions.filter((o) => {
    const courseLicenseType = Number(getCourseLicenseType(o));

    console.log("course =", o);
    console.log("courseLicenseType =", courseLicenseType);
    console.log("watchMaLoaiBang =", watchMaLoaiBang);

    // Không hiện khóa học đã có GPLX
    if (forbiddenLicenseTypes.includes(courseLicenseType)) {
      return false;
    }

    // Chưa chọn loại bằng
    if (!watchMaLoaiBang) {
      return false;
    }

    // Chỉ hiện khóa học đúng loại bằng
    return courseLicenseType === Number(watchMaLoaiBang);
  });
}

              const isAutoFilled = entity.key === "thongtinthi" && (f.name === "MaHocVien" || f.name === "MaLichThi") && !!watchMaHoSo;
              const isCalculated = entity.key === "thongtinthi" && (f.name === "KetQuaLyThuyet" || f.name === "KetQuaThucHanh" || f.name === "KetQuaTong");

              return (
                <div key={f.name} className={`space-y-1.5 ${f.name === "GiayKhamSucKhoe" ? "sm:col-span-2" : ""}`}>
                  <Label>{f.label}{f.required && <span className="text-destructive"> *</span>}</Label>
                  {f.type === "display" ? (
                    <div className="min-h-[2.5rem] rounded-md border border-input bg-background px-3 py-2 text-sm text-muted-foreground">
                      {String(getValue(initial, f.source || f.name) ?? "—")}
                    </div>
                  ) : f.type === "select" ? (
                    <select
                      {...register(f.name)}
                      className={`flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ${isAutoFilled ? "pointer-events-none bg-muted" : ""}`}
                      tabIndex={isAutoFilled ? -1 : 0}
                      disabled={isAutoFilled}
                    >
                      <option value="">— Chọn —</option>
                      {f.options ? (
                        f.options.map((o) => <option key={String(o.value)} value={String(o.value)}>{o.label}</option>)
                      ) : (
                        fieldOptions.map((o) => (
                          <option key={String(o[f.optionValue!])} value={String(o[f.optionValue!])}>
                            {String(o[f.optionLabel!])}
                          </option>
                        ))
                      )}
                    </select>
                  ) : f.type === "file" ? (
                    <div className="space-y-2">
                      <Input
                        type="file"
                        accept="image/*"
                        onChange={async (e) => {
                          const file = (e.target as HTMLInputElement).files?.[0];
                          if (file) {
                            const formData = new FormData();
                            formData.append("file", file);
                            try {
                              const res = await api.post("/upload", formData);
                              const url = res.data.url;
                              setFileUrls((prev) => ({ ...prev, [f.name]: url }));
                              setValue(f.name, url, { shouldDirty: true, shouldValidate: true });
                            } catch (err) {
                              console.error("Upload failed", err);
                              toast.error("Không thể tải ảnh lên server");
                            }
                          }
                        }}
                      />
                      <input type="hidden" {...register(f.name)} />
                      {(() => {
                        const watchValue = watch(f.name);
                        const previewUrl = fileUrls[f.name] || (watchValue ? String(watchValue) : "");
                        return previewUrl ? (
                          <div className="mt-2 border rounded-md p-1 bg-muted/50">
                            <img
                              src={previewUrl}
                              alt={f.label}
                              className="max-h-40 mx-auto rounded"
                              onError={(e) => (e.currentTarget.src = "https://placehold.co/400x200?text=Không+có+ảnh")}
                            />
                          </div>
                        ) : null;
                      })()}
                    </div>
                  ) : (
                    <Input 
                      type={f.type === "date" ? "date" : f.type === "number" ? "number" : f.type === "email" ? "email" : "text"} 
                      readOnly={isCalculated}
                      {...register(f.name, { valueAsNumber: f.type === "number" })} 
                      className={isCalculated ? "bg-muted" : ""}
                    />
                  )}
                  {errors[f.name] && (
                    <p className="text-xs text-destructive">{String(errors[f.name]?.message ?? "")}</p>
                  )}
                </div>
              );
            })}
            <DialogFooter className="sm:col-span-2 mt-2 gap-2">
              <Button type="button" variant="outline" onClick={onClose}>Hủy</Button>
              <Button type="submit" disabled={isSubmitting}>{initial ? "Cập nhật" : "Tạo mới"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    );
  }
