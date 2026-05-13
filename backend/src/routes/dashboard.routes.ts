import { Router } from "express";
import { prisma } from "../config/db";
import { asyncHandler } from "../utils/asyncHandler";

const router = Router();

router.get(
  "/stats",
  asyncHandler(async (_req, res) => {
    const [hocVien, khoaHoc, kyThi, gplx, hoSo] = await Promise.all([
      prisma.hocVien.count(),
      prisma.khoaHoc.count(),
      prisma.lichThi.count(),
      prisma.gPLX.count(),
      prisma.hoSoDangKy.count(),
    ]);

    // GPLX cấp theo tháng (12 tháng gần nhất)
    const gplxList = await prisma.gPLX.findMany({ select: { NgayCap: true } });
    const monthly = new Map<string, number>();
    for (let i = 11; i >= 0; i--) {
      const d = new Date();
      d.setMonth(d.getMonth() - i);
      const k = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
      monthly.set(k, 0);
    }
    gplxList.forEach((g) => {
      if (!g.NgayCap) return;
      const k = `${g.NgayCap.getFullYear()}-${String(g.NgayCap.getMonth() + 1).padStart(2, "0")}`;
      if (monthly.has(k)) monthly.set(k, (monthly.get(k) || 0) + 1);
    });
    const gplxByMonth = Array.from(monthly.entries()).map(([month, count]) => ({
      month,
      count,
    }));

    // Theo loại bằng lái
    const byType = await prisma.gPLX.groupBy({
      by: ["MaLoaiBang"],
      _count: { _all: true },
    });
    const loai = await prisma.loaiBangLai.findMany();
    const gplxByType = byType.map((b) => ({
      name:
        loai.find((l) => l.MaLoaiBang === b.MaLoaiBang)?.TenLoaiBang ||
        `Loại ${b.MaLoaiBang}`,
      value: b._count._all,
    }));

    res.json({
      counts: { hocVien, khoaHoc, kyThi, gplx, hoSo },
      gplxByMonth,
      gplxByType,
    });
  }),
);

export default router;
