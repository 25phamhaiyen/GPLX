import {
  Calendar,
  CalendarCheck,
  ClipboardList,
  GraduationCap,
  FileText,
  Shield,
  Building2,
  ShieldCheck,
  UserCheck,
  LucideIcon,
  User,
  Users,
} from "lucide-react";

export interface ColumnDef {
  key: string;
  label: string;
  type?: "text" | "number" | "date";
}

export interface FieldDef {
  name: string;
  label: string;
  type: "text" | "number" | "date" | "select" | "email" | "file" | "display";
  required?: boolean;
  optionsFrom?: string;
  optionLabel?: string;
  optionValue?: string;
  options?: { label: string; value: string | number }[];
  adminOnly?: boolean;
  source?: string;
}

export interface EntityConfig {
  key: string;
  label: string;
  icon: LucideIcon;
  idField: string;
  columns: ColumnDef[];
  fields: FieldDef[];
  roles?: string[];
  readOnlyRoles?: string[];
}

export const ENTITIES: EntityConfig[] = [
  {
    key: "loaibanglai",
    label: "Loại bằng lái",
    icon: Shield,
    idField: "MaLoaiBang",
    roles: ["ADMIN"],
    columns: [
      { key: "MaLoaiBang", label: "Mã" },
      { key: "TenLoaiBang", label: "Tên loại" },
      { key: "PhiThi", label: "Phí thi", type: "number" },
      { key: "ThoiHanGPLX", label: "Thời hạn (năm)" },
    ],
    fields: [
      {
        name: "TenLoaiBang",
        label: "Tên loại bằng",
        type: "text",
        required: true,
      },
      { name: "MoTa", label: "Mô tả / Ghi chú", type: "text" },
      { name: "PhiThi", label: "Phí thi", type: "number", required: true },
      {
        name: "PhiThiLai",
        label: "Phí thi lại",
        type: "number",
        required: true,
      },
      {
        name: "SoGioLyThuyet",
        label: "Số giờ lý thuyết",
        type: "number",
        required: true,
      },
      {
        name: "SoGioThucHanh",
        label: "Số giờ thực hành",
        type: "number",
        required: true,
      },
      {
        name: "ThoiGianThiSauKhoaHoc",
        label: "Thời gian thi sau học (ngày)",
        type: "number",
        required: true,
      },
      {
        name: "DiemDatLyThuyet",
        label: "Điểm đạt lý thuyết",
        type: "number",
        required: true,
      },
      {
        name: "DiemDatThucHanh",
        label: "Điểm đạt thực hành",
        type: "number",
        required: true,
      },
      { name: "ThoiHanGPLX", label: "Thời hạn GPLX (năm)", type: "number" },
      {
        name: "TrangThai",
        label: "Trạng thái",
        type: "select",
        options: [
          { label: "Hoạt động", value: "Hoạt động" },
          { label: "Ngừng cấp", value: "Ngừng cấp" },
        ],
      },
    ],
  },
  {
    key: "khoahoc",
    label: "Khóa học / Lịch học",
    icon: Calendar,
    idField: "MaKhoaHoc",
    roles: ["ADMIN", "HOCVIEN", "GIANGVIEN"],
    readOnlyRoles: ["HOCVIEN", "GIANGVIEN"],
    columns: [
      { key: "MaKhoaHoc", label: "Mã" },
      { key: "TenKhoaHoc", label: "Tên khóa học" },
      { key: "LoaiBangLai.TenLoaiBang", label: "Loại bằng" },
      { key: "NgayBatDau", label: "Bắt đầu", type: "date" },
      { key: "NgayKetThuc", label: "Kết thúc", type: "date" },
    ],
    fields: [
      {
        name: "TenKhoaHoc",
        label: "Tên khóa học",
        type: "text",
        required: true,
      },
      {
        name: "MaLoaiBang",
        label: "Loại bằng lái",
        type: "select",
        required: true,
        optionsFrom: "loaibanglai",
        optionLabel: "TenLoaiBang",
        optionValue: "MaLoaiBang",
      },
      {
        name: "NgayBatDau",
        label: "Ngày bắt đầu",
        type: "date",
        required: true,
      },
      {
        name: "NgayKetThuc",
        label: "Ngày kết thúc",
        type: "date",
        required: false,
      },
      {
        name: "SoLuongHocVienToiDa",
        label: "Số lượng tối đa",
        type: "number",
        required: true,
      },
      {
        name: "TrangThai",
        label: "Trạng thái",
        type: "select",
        options: [
          { label: "Sắp mở", value: "Sắp mở" },
          { label: "Đang mở", value: "Đang mở" },
          { label: "Đang học", value: "Đang học" },
          { label: "Kết thúc", value: "Kết thúc" },
          { label: "Hủy", value: "Hủy" },
        ],
      },
    ],
  },
  {
    key: "hosodangky",
    label: "Hồ sơ đăng ký",
    icon: FileText,
    idField: "MaHoSo",
    roles: ["ADMIN", "HOCVIEN"],
    readOnlyRoles: [],
    columns: [
      { key: "MaHoSo", label: "Mã" },
      { key: "HocVien.HoTen", label: "Học viên" },
      { key: "HocVien.CCCD", label: "CCCD" },
      { key: "HocVien.SoDienThoai", label: "SĐT" },
      { key: "HocVien.Email", label: "Email" },
      { key: "KhoaHoc.TenKhoaHoc", label: "Khóa học" },
      { key: "NgayDangKy", label: "Ngày đăng ký", type: "date" },
      { key: "TrangThaiHoSo", label: "Trạng thái" },
    ],
    fields: [
      {
        name: "MaHocVien",
        label: "Học viên",
        type: "select",
        required: true,
        optionsFrom: "hocvien",
        optionLabel: "HoTen",
        optionValue: "MaHocVien",
      },
      {
        name: "MaLoaiBang",
        label: "Loại bằng lái",
        type: "select",
        required: true,
        optionsFrom: "loaibanglai",
        optionLabel: "TenLoaiBang",
        optionValue: "MaLoaiBang",
      },
      {
        name: "MaKhoaHoc",
        label: "Khóa học",
        type: "select",
        required: true,
        optionsFrom: "khoahoc",
        optionLabel: "TenKhoaHoc",
        optionValue: "MaKhoaHoc",
      },
      { name: "Anh3x4", label: "Ảnh 3x4", type: "file" },
      { name: "GiayKhamSucKhoe", label: "Giấy khám sức khỏe", type: "file" },
      { name: "NgayKhamSucKhoe", label: "Ngày khám sức khỏe", type: "date" },
      { name: "ThoiGianThiDuKien", label: "TG thi dự kiến", type: "date" },
      {
        name: "TrangThaiHoSo",
        label: "Trạng thái hồ sơ",
        type: "select",
        adminOnly: true,
        options: [
          { label: "Chờ duyệt", value: "Chờ duyệt" },
          { label: "Đã duyệt", value: "Đã duyệt" },
          { label: "Từ chối", value: "Từ chối" },
        ],
      },
      {
        name: "LyDoTuChoi",
        label: "Lý do từ chối",
        type: "text",
        adminOnly: true,
      },
      { name: "GhiChu", label: "Ghi chú", type: "text", adminOnly: true },
      { name: "NgayDuyet", label: "Ngày duyệt", type: "date", adminOnly: true },
      {
        name: "HocVien.HoTen",
        label: "Họ tên học viên",
        type: "display",
        source: "HocVien.HoTen",
        adminOnly: true,
      },
      {
        name: "HocVien.CCCD",
        label: "CCCD",
        type: "display",
        source: "HocVien.CCCD",
        adminOnly: true,
      },
      {
        name: "HocVien.SoDienThoai",
        label: "Số điện thoại",
        type: "display",
        source: "HocVien.SoDienThoai",
        adminOnly: true,
      },
      {
        name: "HocVien.Email",
        label: "Email",
        type: "display",
        source: "HocVien.Email",
        adminOnly: true,
      },
      {
        name: "HocVien.DiaChi",
        label: "Địa chỉ",
        type: "display",
        source: "HocVien.DiaChi",
        adminOnly: true,
      },
    ],
  },
  {
    key: "lichthi",
    label: "Lịch thi sát hạch",
    icon: CalendarCheck,
    idField: "MaLichThi",
    roles: ["ADMIN", "HOCVIEN", "GIAMTHI"],
    readOnlyRoles: ["HOCVIEN", "GIAMTHI"],
    columns: [
      { key: "MaLichThi", label: "Mã" },
      { key: "KhoaHoc.TenKhoaHoc", label: "Khóa học" },
      { key: "NgayThi", label: "Ngày thi", type: "date" },
      { key: "Thu", label: "Thứ" },
      { key: "GioBatDau", label: "Giờ bắt đầu" },
      { key: "GioKetThuc", label: "Giờ kết thúc" },
      { key: "DiaDiem", label: "Địa điểm" },
      { key: "GhiChu", label: "Ghi chú" },
    ],
    fields: [
      {
        name: "MaKhoaHoc",
        label: "Khóa học",
        type: "select",
        required: true,
        optionsFrom: "khoahoc",
        optionLabel: "TenKhoaHoc",
        optionValue: "MaKhoaHoc",
      },
      { name: "NgayThi", label: "Ngày thi", type: "date", required: true },
      { name: "Thu", label: "Thứ (2-8, CN=1)", type: "number", required: true },
      { name: "GioBatDau", label: "Giờ bắt đầu", type: "text", required: true },
      {
        name: "GioKetThuc",
        label: "Giờ kết thúc",
        type: "text",
        required: true,
      },
      { name: "DiaDiem", label: "Địa điểm", type: "text" },
      { name: "GhiChu", label: "Ghi chú", type: "text" },
    ],
  },
  {
    key: "thongtinthi",
    label: "Chấm điểm thi",
    icon: ClipboardList,
    idField: "MaThongTinThi",
    roles: ["ADMIN", "GIAMTHI", "HOCVIEN"],
    readOnlyRoles: ["HOCVIEN"],
    columns: [
      { key: "MaThongTinThi", label: "Mã" },
      { key: "HoSoDangKy.KhoaHoc.TenKhoaHoc", label: "Khóa học" },
      { key: "HoSoDangKy.HocVien.HoTen", label: "Học viên" },
      { key: "LichThi.NgayThi", label: "Ngày thi", type: "date" },
      { key: "DiemLyThuyet", label: "Điểm LT" },
      { key: "DiemThucHanh", label: "Điểm TH" },
      { key: "NgayNhapDiem", label: "Ngày nhập", type: "date" },
    ],
    fields: [
      {
        name: "MaHoSo",
        label: "Hồ sơ đăng ký",
        type: "select",
        required: true,
        optionsFrom: "hosodangky",
        optionLabel: "MaHoSo",
        optionValue: "MaHoSo",
      },
      {
        name: "MaLichThi",
        label: "Lịch thi sát hạch",
        type: "select",
        required: true,
        optionsFrom: "lichthi",
        optionLabel: "MaLichThi",
        optionValue: "MaLichThi",
      },
      { name: "DiemLyThuyet", label: "Điểm lý thuyết (0-100)", type: "number" },
      { name: "GhiChuLyThuyet", label: "Ghi chú lý thuyết", type: "text" },
      { name: "DiemThucHanh", label: "Điểm thực hành (0-100)", type: "number" },
      { name: "GhiChuThucHanh", label: "Ghi chú thực hành", type: "text" },
    ],
  },
  {
    key: "duyetcapgplx",
    label: "Xét duyệt GPLX",
    icon: ShieldCheck,
    idField: "MaDuyet",
    roles: ["ADMIN", "HOIDONG"],
    columns: [
      { key: "MaDuyet", label: "Mã" },
      { key: "MaThongTinThi", label: "Mã TT thi" },
      { key: "NgayDuyet", label: "Ngày duyệt", type: "date" },
      { key: "TrangThaiDuyet", label: "Trạng thái" },
    ],
    fields: [
      {
        name: "MaThongTinThi",
        label: "Thông tin thi",
        type: "select",
        required: true,
        optionsFrom: "thongtinthi",
        optionLabel: "MaThongTinThi",
        optionValue: "MaThongTinThi",
      },
      { name: "NgayDuyet", label: "Ngày duyệt", type: "date" },
      {
        name: "TrangThaiDuyet",
        label: "Trạng thái",
        type: "select",
        options: [
          { label: "Chờ duyệt", value: "Chờ duyệt" },
          { label: "Đã duyệt", value: "Đã duyệt" },
          { label: "Từ chối", value: "Từ chối" },
          { label: "Cần bổ sung", value: "Cần bổ sung" },
        ],
      },
      { name: "NguoiDuyet", label: "Người duyệt", type: "text" },
    ],
  },
  {
    key: "gplx",
    label: "Giấy phép lái xe",
    icon: GraduationCap,
    idField: "SoGPLX",
    roles: ["ADMIN", "HOCVIEN"],
    readOnlyRoles: ["HOCVIEN"],
    columns: [
      { key: "SoGPLX", label: "Số GPLX" },
      { key: "HocVien.HoTen", label: "Học viên" },
      { key: "LoaiBangLai.TenLoaiBang", label: "Loại bằng" },
      { key: "NgayCap", label: "Ngày cấp", type: "date" },
      { key: "NgayHetHan", label: "Hết hạn", type: "date" },
    ],
    fields: [
      { name: "SoGPLX", label: "Số GPLX", type: "text", required: true },
      {
        name: "MaHocVien",
        label: "Học viên",
        type: "select",
        required: true,
        optionsFrom: "hocvien",
        optionLabel: "HoTen",
        optionValue: "MaHocVien",
      },
      {
        name: "MaDuyet",
        label: "Hồ sơ duyệt",
        type: "select",
        required: true,
        optionsFrom: "duyetcapgplx",
        optionLabel: "MaDuyet",
        optionValue: "MaDuyet",
      },
      {
        name: "MaLoaiBang",
        label: "Loại bằng lái",
        type: "select",
        required: true,
        optionsFrom: "loaibanglai",
        optionLabel: "TenLoaiBang",
        optionValue: "MaLoaiBang",
      },
      { name: "NgayCap", label: "Ngày cấp", type: "date", required: true },
      {
        name: "NgayHetHan",
        label: "Ngày hết hạn",
        type: "date",
        required: true,
      },
      {
        name: "TrangThai",
        label: "Trạng thái",
        type: "select",
        options: [
          { label: "Đang sử dụng", value: "Đang sử dụng" },
          { label: "Hết hạn", value: "Hết hạn" },
          { label: "Thu hồi", value: "Thu hồi" },
          { label: "Mất", value: "Mất" },
        ],
      },
    ],
  },
  {
    key: "lichhoc",
    label: "Lịch học",
    icon: Calendar,
    idField: "MaLichHoc",
    roles: ["ADMIN", "HOCVIEN", "GIANGVIEN"],
    readOnlyRoles: ["HOCVIEN", "GIANGVIEN"],
    columns: [
      { key: "MaLichHoc", label: "Mã" },
      { key: "KhoaHoc.TenKhoaHoc", label: "Khóa học" },
      { key: "Thu", label: "Thứ" },
      { key: "GioBatDau", label: "Giờ bắt đầu" },
      { key: "GioKetThuc", label: "Giờ kết thúc" },
      {
        key: "KhoaHoc.GiangVien_KhoaHoc.0.GiangVien.HoTen",
        label: "Giảng viên",
      },
      { key: "GhiChu", label: "Ghi chú" },
    ],
    fields: [
      {
        name: "MaKhoaHoc",
        label: "Khóa học",
        type: "select",
        required: true,
        optionsFrom: "khoahoc",
        optionLabel: "TenKhoaHoc",
        optionValue: "MaKhoaHoc",
      },
      {
        name: "MaGiangVien",
        label: "Giảng viên",
        type: "select",
        required: true,
        optionsFrom: "hocvien",
        optionLabel: "HoTen",
        optionValue: "MaHocVien",
      },
      { name: "Thu", label: "Thứ", type: "number", required: true },
      { name: "GioBatDau", label: "Giờ bắt đầu", type: "text", required: true },
      {
        name: "GioKetThuc",
        label: "Giờ kết thúc",
        type: "text",
        required: true,
      },
      { name: "GhiChu", label: "Ghi chú", type: "text" },
    ],
  },
  {
    key: "hocvien",
    label: "Người dùng",
    icon: Users,
    idField: "MaHocVien",
    roles: ["ADMIN"],
    columns: [
      { key: "MaHocVien", label: "Mã" },
      { key: "HoTen", label: "Họ tên" },
      { key: "Email", label: "Email" },
      { key: "Role", label: "Vai trò" },
    ],
    fields: [
      { name: "TenDangNhap", label: "Tài khoản", type: "text", required: true },
      { name: "MatKhau", label: "Mật khẩu", type: "text", required: true },
      { name: "HoTen", label: "Họ tên", type: "text", required: true },
      { name: "NgaySinh", label: "Ngày sinh", type: "date", required: true },
      {
        name: "SoDienThoai",
        label: "Số điện thoại",
        type: "text",
        required: true,
      },
      { name: "Email", label: "Email", type: "email", required: true },
      {
        name: "Role",
        label: "Vai trò",
        type: "select",
        required: true,
        options: [
          { label: "Admin", value: "ADMIN" },
          { label: "Học viên", value: "HOCVIEN" },
          { label: "Giảng viên", value: "GIANGVIEN" },
          { label: "Giám thị", value: "GIAMTHI" },
          { label: "Hội đồng", value: "HOIDONG" },
        ],
      },
    ],
  },
];

export const getEntity = (key: string, userRole?: string) => {
  const entity = ENTITIES.find((e) => e.key === key);
  if (!userRole || !entity) return entity;
  if (entity.roles && !entity.roles.includes(userRole)) return undefined;
  return entity;
};

export const getAuthorizedEntities = (userRole?: string) => {
  if (!userRole) return [];
  return ENTITIES.filter((e) => !e.roles || e.roles.includes(userRole));
};
