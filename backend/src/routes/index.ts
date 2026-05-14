import { Router } from "express";
import { authMiddleware } from "../middlewares/auth";
import { checkRole } from "../middlewares/role";
import { buildCrudRouter } from "./crud.factory";
import authRoutes from "./auth.routes";
import dashboardRoutes from "./dashboard.routes";
import * as D from "../dtos";

const router = Router();

router.use("/auth", authRoutes);

// Protected routes
router.use(authMiddleware);
router.use("/dashboard", dashboardRoutes);

// LoaiBangLai
router.use(
  "/loaibanglai",
  checkRole(["ADMIN", "HOCVIEN"]),
  buildCrudRouter(
    {
      modelKey: "loaiBangLai",
      idField: "MaLoaiBang",
      searchFields: ["TenLoaiBang"],
    },
    D.LoaiBangLaiCreate,
    D.LoaiBangLaiUpdate,
  ),
);

// KhoaHoc — include LichThi (new schema), LichHoc
router.use(
  "/khoahoc",
  checkRole(["ADMIN", "HOCVIEN", "GIANGVIEN"]),
  buildCrudRouter(
    {
      modelKey: "khoaHoc",
      idField: "MaKhoaHoc",
      searchFields: ["TenKhoaHoc"],
      include: { LoaiBangLai: true, LichThi: true, LichHoc: true },
    },
    D.KhoaHocCreate,
    D.KhoaHocUpdate,
  ),
);

// HoSoDangKy
router.use(
  "/hosodangky",
  checkRole(["ADMIN", "HOCVIEN"]),
  buildCrudRouter(
    {
      modelKey: "hoSoDangKy",
      idField: "MaHoSo",
      searchFields: ["TrangThaiHoSo"],
      include: {
        HocVien: true,
        KhoaHoc: { include: { LichThi: true } },
        LoaiBangLai: true,
      },
    },
    D.HoSoDangKyCreate,
    D.HoSoDangKyUpdate,
  ),
);

// LichThi (exam schedules)
router.use(
  "/lichthi",
  checkRole(["ADMIN", "HOCVIEN", "GIAMTHI"]),
  buildCrudRouter(
    {
      modelKey: "lichThi",
      idField: "MaLichThi",
      searchFields: ["DiaDiem"],
      include: { KhoaHoc: true },
    },
    D.LichThiCreate,
    D.LichThiUpdate,
  ),
);

// LichHoc (class schedules)
router.use(
  "/lichhoc",
  checkRole(["ADMIN", "HOCVIEN", "GIANGVIEN"]),
  buildCrudRouter(
    {
      modelKey: "lichHoc",
      idField: "MaLichHoc",
      searchFields: [],
      include: {
        KhoaHoc: {
          include: { GiangVien_KhoaHoc: { include: { GiangVien: true } } },
        },
      },
    },
    D.LichHocCreate,
    D.LichHocUpdate,
  ),
);

// ThongTinThi — chấm điểm
router.use(
  "/thongtinthi",
  checkRole(["ADMIN", "GIAMTHI", "HOCVIEN"]),
  buildCrudRouter(
    {
      modelKey: "thongTinThi",
      idField: "MaThongTinThi",
      searchFields: [],
      include: {
        HoSoDangKy: {
          include: { HocVien: true, LoaiBangLai: true, KhoaHoc: true },
        },
        LichThi: { include: { KhoaHoc: true } },
      },
    },
    D.ThongTinThiCreate,
    D.ThongTinThiUpdate,
  ),
);

// DuyetCapGPLX
router.use(
  "/duyetcapgplx",
  checkRole(["ADMIN", "HOIDONG"]),
  buildCrudRouter(
    {
      modelKey: "duyetCapGPLX",
      idField: "MaDuyet",
      searchFields: ["TrangThaiDuyet"],
      include: { ThongTinThi: true },
    },
    D.DuyetCapGPLXCreate,
    D.DuyetCapGPLXUpdate,
  ),
);

// GPLX
router.use(
  "/gplx",
  checkRole(["ADMIN", "HOCVIEN"]),
  buildCrudRouter(
    {
      modelKey: "gPLX",
      idField: "SoGPLX",
      searchFields: ["SoGPLX"],
      include: { DuyetCapGPLX: true, LoaiBangLai: true, HocVien: true },
    },
    D.GPLXCreate,
    D.GPLXUpdate,
  ),
);

// GiangVien
router.use(
  "/giangvien",
  checkRole(["ADMIN"]),
  buildCrudRouter(
    { modelKey: "giangVien", idField: "MaGiangVien", searchFields: ["HoTen"] },
    D.GiangVienCreate,
    D.GiangVienUpdate,
  ),
);

// HocVien management
router.use(
  "/hocvien",
  checkRole(["ADMIN", "HOCVIEN"]),
  buildCrudRouter(
    {
      modelKey: "hocVien",
      idField: "MaHocVien",
      searchFields: ["HoTen", "CCCD", "SoDienThoai", "Email"],
    },
    D.HocVienCreate,
    D.HocVienUpdate,
  ),
);

export default router;
