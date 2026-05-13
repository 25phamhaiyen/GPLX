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

function buildSchema(fields: FieldDef[], userRole?: string) {
  const shape: Record<string, z.ZodTypeAny> = {};
  fields.forEach((f) => {
    // If field is hidden for this role, don't require it on frontend
    const isHidden = userRole === "HOCVIEN" && f.name === "MaHocVien";
    
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
    else if (f.type === "select") {
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

  const [options, setOptions] = useState<Record<string, Array<Record<string, unknown>>>>({});
  const watchMaLoaiBang = watch("MaLoaiBang");
  const watchMaKhoaHoc = watch("MaKhoaHoc");
  const watchMaHoSo = watch("MaHoSo");
  const watchDiemLyThuyet = watch("DiemLyThuyet");
  const watchDiemThucHanh = watch("DiemThucHanh");
  const [passingScores, setPassingScores] = useState({ lt: 8, th: 8 });

  useEffect(() => {
    const selects = entity.fields.filter((f) => f.type === "select" && f.optionsFrom);
    Promise.all(
      selects.map((f) =>
        api.get(`/${f.optionsFrom}`, { params: { pageSize: 500 } }).then((r) => [f.name, r.data.data] as const)
      )
    ).then((rows) => setOptions(Object.fromEntries(rows)));
  }, [entity.key]);

  // --- CORE AUTOMATION LOGIC ---
  useEffect(() => {
    if (!open) return;

    // 1. HoSoDangKy: Auto-fill from License Type & Course
    if (entity.key === "hosodangky") {
      if (watchMaLoaiBang) {
        api.get(`/loaibanglai/${watchMaLoaiBang}`).then(r => setValue("TongHocPhi", Number(r.data.PhiThi)));
      }
      if (watchMaKhoaHoc) {
        api.get(`/khoahoc/${watchMaKhoaHoc}`).then(r => {
          if (r.data.NgayBatDau) setValue("ThoiGianHocDuKien", String(r.data.NgayBatDau).slice(0, 10));
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
            if (user?.role === "HOCVIEN" && f.name === "MaHocVien") return null;

            let fieldOptions = options[f.name] || [];
            if (entity.key === "hosodangky" && f.name === "MaKhoaHoc" && watchMaLoaiBang) {
              fieldOptions = fieldOptions.filter(o => Number(o.MaLoaiBang) === Number(watchMaLoaiBang));
            }

            const isAutoFilled = entity.key === "thongtinthi" && (f.name === "MaHocVien" || f.name === "MaLichThi") && !!watchMaHoSo;
            const isCalculated = entity.key === "thongtinthi" && (f.name === "KetQuaLyThuyet" || f.name === "KetQuaThucHanh" || f.name === "KetQuaTong");

            return (
              <div key={f.name} className={`space-y-1.5 ${f.name === "GiayKhamSucKhoe" ? "sm:col-span-2" : ""}`}>
                <Label>{f.label}{f.required && <span className="text-destructive"> *</span>}</Label>
                {f.type === "select" ? (
                  <select
                    {...register(f.name)}
                    className={`flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ${isAutoFilled ? "pointer-events-none bg-muted" : ""}`}
                    tabIndex={isAutoFilled ? -1 : 0}
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
                ) : f.name === "GiayKhamSucKhoe" ? (
                  <div className="space-y-2">
                    <Input placeholder="Dán link ảnh hoặc nhập tên file ảnh..." {...register(f.name)} />
                    {watch("GiayKhamSucKhoe") && (
                      <div className="mt-2 border rounded-md p-1 bg-muted/50">
                        <img 
                          src={String(watch("GiayKhamSucKhoe"))} 
                          alt="Giấy khám sức khỏe" 
                          className="max-h-40 mx-auto rounded"
                          onError={(e) => (e.currentTarget.src = "https://placehold.co/400x200?text=Anh+Giay+Kham+Suc+Khoe")}
                        />
                      </div>
                    )}
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
