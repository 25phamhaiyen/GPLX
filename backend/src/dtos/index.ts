import { z } from "zod";

const optStr = z.string().optional().nullable();
const optDate = z.coerce.date().optional().nullable();
const optNum = z.preprocess(
  (val) => (val === "" || (typeof val === "number" && isNaN(val)) ? null : val),
  z.coerce.number().optional().nullable(),
);
const reqNum = (label: string) =>
  z.preprocess(
    (val) =>
      val === "" || (typeof val === "number" && isNaN(val)) ? undefined : val,
    z.coerce.number({
      invalid_type_error: `${label} phải là số`,
      required_error: `${label} là bắt buộc`,
    }),
  );

// ===== Học Viên =====
const HocVienBase = z.object({
  TenDangNhap: z.string().min(1, "Tài khoản không được để trống"),
  MatKhau: z.string().min(1, "Mật khẩu không được để trống"),
  HoTen: z.string().min(1, "Họ tên không được để trống"),
  NgaySinh: z.coerce.date().refine((d) => {
    const age = new Date().getFullYear() - d.getFullYear();
    return age >= 18;
  }, "Học viên phải từ 18 tuổi trở lên"),
  GioiTinh: z.enum(["Nam", "Nữ", "Khác"]).optional().nullable(),
  CCCD: z
    .string()
    .regex(/^\d{12}$/, "CCCD phải đúng 12 chữ số")
    .optional()
    .nullable(),
  SoDienThoai: z
    .string()
    .regex(/^0\d{9}$/, "Số điện thoại phải bắt đầu bằng 0 và có 10 chữ số"),
  Email: z.string().email("Email không hợp lệ"),
  DiaChi: optStr,
});
export const HocVienCreate = HocVienBase;
export const HocVienUpdate = HocVienBase.partial();

// ===== Loại Bằng Lái =====
const LoaiBangLaiBase = z.object({
  TenLoaiBang: z.string().min(1),
  MoTa: optStr,
  PhiThi: reqNum("Phí thi").pipe(z.number().positive()),
  SoGioLyThuyet: reqNum("Số giờ lý thuyết").pipe(z.number().min(1).max(100)),
  SoGioThucHanh: reqNum("Số giờ thực hành").pipe(z.number().min(1).max(100)),
  ThoiGianThiSauKhoaHoc: reqNum("Thời gian thi").pipe(z.number().positive()),
  DiemDatLyThuyet: reqNum("Điểm đạt LT").pipe(z.number().min(0).max(100)),
  DiemDatThucHanh: reqNum("Điểm đạt TH").pipe(z.number().min(0).max(100)),
  ThoiHanGPLX: optNum,
  TrangThai: z.enum(["Hoạt động", "Ngừng cấp"]).optional().nullable(),
});
export const LoaiBangLaiCreate = LoaiBangLaiBase;
export const LoaiBangLaiUpdate = LoaiBangLaiBase.partial();

// ===== Khóa Học =====
const KhoaHocBase = z.object({
  TenKhoaHoc: z.string().min(1),
  MaLoaiBang: reqNum("Mã loại bằng"),
  NgayBatDau: z.coerce.date(),
  NgayKetThuc: optDate,
  SoLuongHocVienToiDa: reqNum("Số lượng tối đa").pipe(
    z.number().min(10).max(100),
  ),
  TrangThai: z
    .enum(["Sắp mở", "Đang mở", "Đang học", "Kết thúc", "Hủy"])
    .optional()
    .nullable(),
  GhiChu: optStr,
});
export const KhoaHocCreate = KhoaHocBase.refine(
  (data) => {
    if (data.NgayKetThuc && data.NgayBatDau)
      return data.NgayKetThuc > data.NgayBatDau;
    return true;
  },
  { message: "Ngày kết thúc phải sau ngày bắt đầu", path: ["NgayKetThuc"] },
);
export const KhoaHocUpdate = KhoaHocBase.partial();

// ===== Hồ Sơ Đăng Ký =====
// Schema mới: bỏ DaThanhToan, LyDoTuChoi; thêm TinhTrangSucKhoe, Anh3x4
const HoSoDangKyBase = z.object({
  MaHocVien: optNum,
  MaLoaiBang: reqNum("Loại bằng"),
  MaKhoaHoc: reqNum("Khóa học"),
  TinhTrangSucKhoe: optStr,
  NgayKhamSucKhoe: optDate,
  GiayKhamSucKhoe: optStr,
  Anh3x4: optStr,
  ThoiGianThiDuKien: optDate,
  TrangThaiHoSo: z
    .enum(["Chờ duyệt", "Đã duyệt", "Từ chối"])
    .optional()
    .nullable(),
  NgayDuyet: optDate,
  LyDoTuChoi: optStr,
  GhiChu: optStr,
});
export const HoSoDangKyCreate = HoSoDangKyBase;
export const HoSoDangKyUpdate = HoSoDangKyBase.partial();

// ===== Lịch Thi (mới — không còn TenKyThi, MaLoaiBang; thêm Thu, GioBatDau, GioKetThuc) =====
const LichThiBase = z.object({
  MaKhoaHoc: reqNum("Mã khóa học"),
  NgayThi: z.coerce.date(),
  Thu: reqNum("Thứ").pipe(z.number().min(1).max(7)),
  GioBatDau: z.string().min(1, "Giờ bắt đầu là bắt buộc"),
  GioKetThuc: z.string().min(1, "Giờ kết thúc là bắt buộc"),
  DiaDiem: optStr,
  GhiChu: optStr,
});
export const LichThiCreate = LichThiBase;
export const LichThiUpdate = LichThiBase.partial();

// ===== Lịch Học (mới — Thu, GioBatDau, GioKetThuc) =====
const LichHocBase = z.object({
  MaKhoaHoc: reqNum("Mã khóa học"),
  Thu: reqNum("Thứ").pipe(z.number().min(1).max(7)),
  GioBatDau: z.string().min(1),
  GioKetThuc: z.string().min(1),
  GhiChu: optStr,
});
export const LichHocCreate = LichHocBase;
export const LichHocUpdate = LichHocBase.partial();

// ===== Giảng Viên (bảng mới tách riêng) =====
const GiangVienBase = z.object({
  HoTen: z.string().min(1),
  SoDienThoai: z
    .string()
    .regex(/^0\d{9}$/)
    .optional()
    .nullable(),
  Email: z.string().email().optional().nullable(),
  TrangThai: z.enum(["Hoạt động", "Nghỉ việc"]).optional().nullable(),
  GhiChu: optStr,
});
export const GiangVienCreate = GiangVienBase;
export const GiangVienUpdate = GiangVienBase.partial();

// ===== Giám Thị =====
const GiamThiBase = z.object({
  HoTen: z.string().min(1),
  CCCD: z.string().regex(/^\d{12}$/, "CCCD phải đúng 12 chữ số"),
  SoDienThoai: z.string().regex(/^0\d{9}$/, "Số điện thoại không hợp lệ"),
  Email: z.string().email(),
  ChuyenMon: z.enum(["Lý thuyết", "Thực hành", "Cả hai"]).optional().nullable(),
  TrangThai: z.enum(["Hoạt động", "Nghỉ việc"]).optional().nullable(),
});
export const GiamThiCreate = GiamThiBase;
export const GiamThiUpdate = GiamThiBase.partial();

// ===== Thông Tin Thi — chỉ lưu điểm theo đúng DB mới =====
const ThongTinThiBase = z.object({
  MaHoSo: reqNum("Mã hồ sơ"),
  MaLichThi: reqNum("Mã lịch thi"),
  DiemLyThuyet: z.preprocess(
    (val) => (val === "" || val === null || val === undefined ? null : val),
    z.coerce
      .number()
      .min(0, "Điểm không được âm")
      .max(100, "Điểm tối đa 100")
      .optional()
      .nullable(),
  ),
  DiemThucHanh: z.preprocess(
    (val) => (val === "" || val === null || val === undefined ? null : val),
    z.coerce
      .number()
      .min(0, "Điểm không được âm")
      .max(100, "Điểm tối đa 100")
      .optional()
      .nullable(),
  ),
  GhiChuLyThuyet: optStr,
  GhiChuThucHanh: optStr,
  NgayNhapDiem: optDate,
});
export const ThongTinThiCreate = ThongTinThiBase;
export const ThongTinThiUpdate = ThongTinThiBase.partial();

// ===== Hội Đồng Sát Hạch =====
const HoiDongSatHachBase = z.object({
  TenHoiDong: z.string().min(1),
  ChuTichHoiDong: z.string().min(1),
  ThanhVien: optStr,
  NgayThanhLap: optDate,
  TrangThai: z.enum(["Hoạt động", "Tạm ngừng"]).optional().nullable(),
});
export const HoiDongSatHachCreate = HoiDongSatHachBase;
export const HoiDongSatHachUpdate = HoiDongSatHachBase.partial();

// ===== Duyệt Cấp GPLX — bỏ MaHoiDong, NguoiDuyet vì DB mới không có =====
const DuyetCapGPLXBase = z.object({
  MaThongTinThi: reqNum("Mã thông tin thi"),
  NgayDuyet: optDate,
  TrangThaiDuyet: z
    .enum(["Chờ duyệt", "Đã duyệt", "Từ chối", "Cần bổ sung"])
    .optional()
    .nullable(),
  LyDoTuChoi: optStr,
  GhiChu: optStr,
});
export const DuyetCapGPLXCreate = DuyetCapGPLXBase;
export const DuyetCapGPLXUpdate = DuyetCapGPLXBase.partial();

// ===== GPLX =====
const GPLXBase = z.object({
  SoGPLX: z.string().optional().nullable(),
  MaHocVien: reqNum("Mã học viên"),
  MaDuyet: reqNum("Mã duyệt"),
  MaLoaiBang: reqNum("Loại bằng"),
  NgayCap: optDate,
  NgayHetHan: optDate,
  NoiCap: optStr,
  TrangThai: z
    .enum(["Đang sử dụng", "Hết hạn", "Thu hồi", "Mất"])
    .optional()
    .nullable(),
  GhiChu: optStr,
});
export const GPLXCreate = GPLXBase;
export const GPLXUpdate = GPLXBase.partial();
