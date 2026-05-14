import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { toast } from "sonner";
import { GraduationCap, ArrowLeft } from "lucide-react";

const schema = z.object({
  TenDangNhap: z.string().min(1, "Tài khoản là bắt buộc"),
  MatKhau: z.string().min(6, "Mật khẩu tối thiểu 6 ký tự"),
  HoTen: z.string().min(1, "Họ tên là bắt buộc"),
  NgaySinh: z.string().min(1, "Ngày sinh là bắt buộc"),
  SoDienThoai: z.string().regex(/^0\d{9}$/, "Số điện thoại phải 10 số, bắt đầu bằng 0"),
  Email: z.string().email("Email không hợp lệ"),
  CCCD: z.string().regex(/^\d{12}$/, "CCCD phải đúng 12 chữ số"),
  DiaChi: z.string().min(1, "Địa chỉ là bắt buộc"),
});

type FormValues = z.infer<typeof schema>;

export default function RegisterPage() {
  const nav = useNavigate();
  const [loading, setLoading] = useState(false);
  const { register, handleSubmit, formState: { errors } } = useForm<FormValues>({ 
    resolver: zodResolver(schema),
    defaultValues: {
        NgaySinh: "2000-01-01"
    }
  });

  const onSubmit = async (v: FormValues) => {
    setLoading(true);
    try {
      await api.post("/auth/register", v);
      toast.success("Đăng ký thành công! Hãy đăng nhập.");
      nav("/login");
    } catch { /* handled */ }
    finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen grid place-items-center bg-gradient-to-br from-primary/10 via-background to-background p-4">
      <Card className="w-full max-w-2xl shadow-xl">
        <CardHeader className="text-center">
          <div className="mx-auto mb-2 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <GraduationCap className="h-6 w-6 text-primary" />
          </div>
          <CardTitle className="text-2xl">Đăng ký tài khoản</CardTitle>
          <CardDescription>Trở thành học viên của trung tâm đào tạo lái xe</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label>Họ tên</Label>
              <Input {...register("HoTen")} placeholder="Nguyễn Văn A" />
              {errors.HoTen && <p className="text-xs text-destructive">{errors.HoTen.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Tài khoản</Label>
              <Input {...register("TenDangNhap")} placeholder="hocvien1" />
              {errors.TenDangNhap && <p className="text-xs text-destructive">{errors.TenDangNhap.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Mật khẩu</Label>
              <Input type="password" {...register("MatKhau")} placeholder="••••••" />
              {errors.MatKhau && <p className="text-xs text-destructive">{errors.MatKhau.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Ngày sinh</Label>
              <Input type="date" {...register("NgaySinh")} />
              {errors.NgaySinh && <p className="text-xs text-destructive">{errors.NgaySinh.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Email</Label>
              <Input type="email" {...register("Email")} placeholder="a@gmail.com" />
              {errors.Email && <p className="text-xs text-destructive">{errors.Email.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Số điện thoại</Label>
              <Input {...register("SoDienThoai")} placeholder="0912345678" />
              {errors.SoDienThoai && <p className="text-xs text-destructive">{errors.SoDienThoai.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>CCCD</Label>
              <Input {...register("CCCD")} placeholder="012345678901" />
              {errors.CCCD && <p className="text-xs text-destructive">{errors.CCCD.message}</p>}
            </div>
            <div className="space-y-1.5">
              <Label>Địa chỉ</Label>
              <Input {...register("DiaChi")} placeholder="Hà Nội" />
              {errors.DiaChi && <p className="text-xs text-destructive">{errors.DiaChi.message}</p>}
            </div>
            
            <div className="md:col-span-2 flex flex-col gap-3 mt-4">
                <Button type="submit" className="w-full" disabled={loading}>
                {loading ? "Đang xử lý..." : "Đăng ký ngay"}
                </Button>
                <div className="flex items-center justify-between px-1">
                    <Link to="/login" className="text-sm text-primary flex items-center gap-1 hover:underline">
                        <ArrowLeft className="h-3 w-3" /> Quay lại đăng nhập
                    </Link>
                </div>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
