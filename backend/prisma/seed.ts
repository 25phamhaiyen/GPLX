import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Bắt đầu seed dữ liệu...");

  const password = await bcrypt.hash("admin123", 10);

  // =====================================================
  // HỌC VIÊN
  // =====================================================

  const admin = await prisma.hocVien.upsert({
    where: { TenDangNhap: "admin" },
    update: {},
    create: {
      TenDangNhap: "admin",
      MatKhau: password,
      HoTen: "Quản trị viên",
      NgaySinh: new Date("1985-01-01"),
      GioiTinh: "Nam",
      CCCD: "000000000001",
      SoDienThoai: "0900000001",
      Email: "admin@gplx.vn",
      DiaChi: "TP.HCM",
    },
  });

  const hocVien1 = await prisma.hocVien.upsert({
    where: { TenDangNhap: "hocvien1" },
    update: {},
    create: {
      TenDangNhap: "hocvien1",
      MatKhau: password,
      HoTen: "Nguyễn Văn An",
      NgaySinh: new Date("2001-03-15"),
      GioiTinh: "Nam",
      CCCD: "000000000002",
      SoDienThoai: "0911111111",
      Email: "an@gplx.vn",
      DiaChi: "Bình Dương",
    },
  });

  const hocVien2 = await prisma.hocVien.upsert({
    where: { TenDangNhap: "hocvien2" },
    update: {},
    create: {
      TenDangNhap: "hocvien2",
      MatKhau: password,
      HoTen: "Trần Thị Bình",
      NgaySinh: new Date("2000-07-20"),
      GioiTinh: "Nữ",
      CCCD: "000000000003",
      SoDienThoai: "0922222222",
      Email: "binh@gplx.vn",
      DiaChi: "TP.HCM",
    },
  });

  console.log("✅ HocVien");

  // =====================================================
  // GIẢNG VIÊN
  // =====================================================

  const gv1 = await prisma.giangVien.create({
    data: {
      HoTen: "Đinh Văn Giáo",
      SoDienThoai: "0966666661",
      Email: "gv1@gplx.vn",
      TrangThai: "Hoạt động",
      GhiChu: "Giảng viên lý thuyết",
    },
  });

  const gv2 = await prisma.giangVien.create({
    data: {
      HoTen: "Ngô Thị Hương",
      SoDienThoai: "0966666662",
      Email: "gv2@gplx.vn",
      TrangThai: "Hoạt động",
      GhiChu: "Giảng viên thực hành",
    },
  });

  console.log("✅ GiangVien");

  // =====================================================
  // HỘI ĐỒNG SÁT HẠCH
  // =====================================================

  const hoiDong = await prisma.hoiDongSatHach.create({
    data: {
      TenHoiDong: "Hội đồng sát hạch GPLX Trung tâm ABC",
      ChuTichHoiDong: "Nguyễn Văn Chủ tịch",
      ThanhVien: "Trần Thị Ủy viên 1, Lê Văn Ủy viên 2",
      NgayThanhLap: new Date("2024-01-01"),
      TrangThai: "Hoạt động",
    },
  });

  console.log("✅ HoiDongSatHach");

  // =====================================================
  // LOẠI BẰNG
  // =====================================================

  const bangB2 = await prisma.loaiBangLai.upsert({
    where: { TenLoaiBang: "B2" },
    update: {},
    create: {
      TenLoaiBang: "B2",
      MoTa: "Bằng lái ô tô",
      PhiThi: 600000,
      SoGioLyThuyet: 90,
      SoGioThucHanh: 84,
      ThoiGianThiSauKhoaHoc: 30,
      DiemDatLyThuyet: 80,
      DiemDatThucHanh: 80,
      ThoiHanGPLX: 10,
      TrangThai: "Hoạt động",
    },
  });

  const bangA1 = await prisma.loaiBangLai.upsert({
    where: { TenLoaiBang: "A1" },
    update: {},
    create: {
      TenLoaiBang: "A1",
      MoTa: "Bằng lái xe máy",
      PhiThi: 300000,
      SoGioLyThuyet: 36,
      SoGioThucHanh: 24,
      ThoiGianThiSauKhoaHoc: 14,
      DiemDatLyThuyet: 75,
      DiemDatThucHanh: 75,
      ThoiHanGPLX: 5,
      TrangThai: "Hoạt động",
    },
  });

  console.log("✅ LoaiBangLai");

  // =====================================================
  // KHÓA HỌC
  // =====================================================

  const khoaHoc1 = await prisma.khoaHoc.create({
    data: {
      TenKhoaHoc: "Khóa B2 K01",
      MaLoaiBang: bangB2.MaLoaiBang,
      NgayBatDau: new Date("2025-01-01"),
      NgayKetThuc: new Date("2025-04-01"),
      SoLuongHocVienToiDa: 30,
      SoLuongDaDangKy: 2,
      TrangThai: "Đang học",
      GhiChu: "Khóa B2 đầu năm",
    },
  });

  console.log("✅ KhoaHoc");

  // =====================================================
  // GIẢNG VIÊN - KHÓA HỌC
  // =====================================================

  await prisma.giangVien_KhoaHoc.create({
    data: {
      MaGiangVien: gv1.MaGiangVien,
      MaKhoaHoc: khoaHoc1.MaKhoaHoc,
      TrangThai: "Đang dạy",
    },
  });

  await prisma.giangVien_KhoaHoc.create({
    data: {
      MaGiangVien: gv2.MaGiangVien,
      MaKhoaHoc: khoaHoc1.MaKhoaHoc,
      TrangThai: "Đang dạy",
    },
  });

  console.log("✅ GiangVien_KhoaHoc");

  // =====================================================
  // LỊCH HỌC
  // =====================================================

  await prisma.lichHoc.create({
    data: {
      MaKhoaHoc: khoaHoc1.MaKhoaHoc,
      Thu: 2,
      GioBatDau: new Date("1970-01-01T07:30:00"),
      GioKetThuc: new Date("1970-01-01T11:00:00"),
      GhiChu: "Lý thuyết",
    },
  });

  console.log("✅ LichHoc");

  // =====================================================
  // LỊCH THI
  // =====================================================

  const lichThi = await prisma.lichThi.create({
    data: {
      MaKhoaHoc: khoaHoc1.MaKhoaHoc,
      NgayThi: new Date("2025-05-30"),
      Thu: 6,
      GioBatDau: new Date("1970-01-01T07:00:00"),
      GioKetThuc: new Date("1970-01-01T11:00:00"),
      DiaDiem: "TP.HCM",
      GhiChu: "Thi sát hạch",
    },
  });

  console.log("✅ LichThi");

  // =====================================================
  // HỒ SƠ ĐĂNG KÝ
  // =====================================================

  const hoSo1 = await prisma.hoSoDangKy.create({
    data: {
      MaHocVien: hocVien1.MaHocVien,
      MaLoaiBang: bangB2.MaLoaiBang,
      MaKhoaHoc: khoaHoc1.MaKhoaHoc,

      TinhTrangSucKhoe: "Khỏe mạnh",
      NgayKhamSucKhoe: new Date("2025-01-01"),
      GiayKhamSucKhoe: "GKK001",

      ThoiGianThiDuKien: new Date("2025-05-30"),

      TongHocPhi: 600000,
      TrangThaiThanhToan: "Đã thanh toán",
      NgayThanhToan: new Date(),

      TrangThaiHoSo: "Đã duyệt",
      NgayDuyet: new Date(),

      GhiChu: "Đầy đủ hồ sơ",
    },
  });

  console.log("✅ HoSoDangKy");

  // =====================================================
  // THÔNG TIN THI
  // =====================================================

  const thongTinThi = await prisma.thongTinThi.create({
    data: {
      MaHoSo: hoSo1.MaHoSo,
      MaLichThi: lichThi.MaLichThi,

      DiemLyThuyet: 85,
      DiemThucHanh: 90,

      GhiChuLyThuyet: "Đạt",
      GhiChuThucHanh: "Tốt",

      NgayNhapDiem: new Date(),
    },
  });

  console.log("✅ ThongTinThi");

  // =====================================================
  // DUYỆT GPLX
  // =====================================================

  const duyet = await prisma.duyetCapGPLX.create({
    data: {
      MaThongTinThi: thongTinThi.MaThongTinThi,
      MaHoiDong: hoiDong.MaHoiDong,
      NgayDuyet: new Date(),
      TrangThaiDuyet: "Đã duyệt",
      GhiChu: "Đủ điều kiện cấp GPLX",
    },
  });

  console.log("✅ DuyetCapGPLX");

  // =====================================================
  // GPLX
  // =====================================================

  await prisma.gPLX.create({
    data: {
      SoGPLX: "GPLX0001",
      MaHocVien: hocVien1.MaHocVien,
      MaDuyet: duyet.MaDuyet,
      MaLoaiBang: bangB2.MaLoaiBang,

      NgayCap: new Date("2025-06-01"),
      NgayHetHan: new Date("2035-06-01"),

      NoiCap: "Sở GTVT TP.HCM",

      TrangThai: "Đang sử dụng",

      GhiChu: "GPLX lần đầu",
    },
  });

  console.log("✅ GPLX");

  console.log("🎉 Seed hoàn tất");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
