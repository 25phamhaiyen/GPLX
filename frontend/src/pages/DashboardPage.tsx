import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend, CartesianGrid,
} from "recharts";
import { Users, BookOpen, CalendarCheck, GraduationCap, FileText } from "lucide-react";

interface Stats {
  counts: { hocVien: number; khoaHoc: number; kyThi: number; gplx: number; hoSo: number };
  gplxByMonth: { month: string; count: number }[];
  gplxByType: { name: string; value: number }[];
}

const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6", "#06b6d4"];

import { useAuth } from "@/hooks/useAuth";
import { getAuthorizedEntities } from "@/lib/entities";
import { Navigate } from "react-router-dom";

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState<Stats | null>(null);

  useEffect(() => {
    if (user?.role === "ADMIN") {
      api.get("/dashboard/stats")
        .then((r) => setStats(r.data))
        .catch(() => setStats({
          counts: { hocVien: 0, khoaHoc: 0, kyThi: 0, gplx: 0, hoSo: 0 },
          gplxByMonth: [],
          gplxByType: [],
        }));
    }
  }, [user]);

  if (user?.role !== "ADMIN") {
    const authorized = getAuthorizedEntities(user?.role);
    if (authorized.length > 0) return <Navigate to={`/entity/${authorized[0].key}`} replace />;
    return <div>Bạn không có quyền truy cập ứng dụng.</div>;
  }

  const cards = [
    { label: "Học viên", value: stats?.counts.hocVien ?? 0, icon: Users, color: "text-blue-500" },
    { label: "Khóa học", value: stats?.counts.khoaHoc ?? 0, icon: BookOpen, color: "text-emerald-500" },
    { label: "Hồ sơ đăng ký", value: stats?.counts.hoSo ?? 0, icon: FileText, color: "text-amber-500" },
    { label: "Kỳ thi", value: stats?.counts.kyThi ?? 0, icon: CalendarCheck, color: "text-violet-500" },
    { label: "Giấy phép lái xe đã cấp", value: stats?.counts.gplx ?? 0, icon: GraduationCap, color: "text-rose-500" },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Dashboard</h1>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
        {cards.map((c) => (
          <Card key={c.label}>
            <CardContent className="p-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">{c.label}</p>
                  <p className="text-3xl font-bold mt-1">{c.value.toLocaleString("vi-VN")}</p>
                </div>
                <c.icon className={`h-9 w-9 ${c.color}`} />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>Giấy phép lái xe cấp theo tháng (12 tháng gần nhất)</CardTitle></CardHeader>
          <CardContent className="h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={stats?.gplxByMonth || []}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="count" fill="hsl(var(--primary))" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Giấy phép lái xe theo loại bằng</CardTitle></CardHeader>
          <CardContent className="h-[320px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={stats?.gplxByType || []} dataKey="value" nameKey="name" outerRadius={100} label>
                  {(stats?.gplxByType || []).map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Legend />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
