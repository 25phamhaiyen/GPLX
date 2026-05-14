
USE master;
GO

ALTER DATABASE GPLX_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE GPLX_DB;
GO
CREATE DATABASE GPLX_DB;
GO

USE GPLX_DB;
GO
-- Bảng Loại Bằng Lái 
CREATE TABLE LoaiBangLai ( 
MaLoaiBang INT IDENTITY(1,1) PRIMARY KEY, 
TenLoaiBang NVARCHAR(10) NOT NULL UNIQUE, 
MoTa NVARCHAR(500), 
PhiThi DECIMAL(15,2) NOT NULL CHECK (PhiThi > 0), 
SoGioLyThuyet INT NOT NULL CHECK (SoGioLyThuyet BETWEEN 1 AND 100), 
SoGioThucHanh INT NOT NULL CHECK (SoGioThucHanh BETWEEN 1 AND 100), 
ThoiGianThiSauKhoaHoc INT NOT NULL CHECK (ThoiGianThiSauKhoaHoc > 0), 
DiemDatLyThuyet INT NOT NULL CHECK (DiemDatLyThuyet BETWEEN 0 AND 100), 
DiemDatThucHanh INT NOT NULL CHECK (DiemDatThucHanh BETWEEN 0 AND 100), 
ThoiHanGPLX INT NOT NULL DEFAULT 10 CHECK (ThoiHanGPLX BETWEEN 5 AND 50), 
TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Hoạt động' CHECK (TrangThai IN (N'Hoạt động', N'Ngừng cấp')) ); 
-- Bảng Học viên 

CREATE TABLE HocVien ( 
MaHocVien INT IDENTITY(1,1) PRIMARY KEY, 
TenDangNhap NVARCHAR(50) NOT NULL UNIQUE, 
MatKhau NVARCHAR(255) NOT NULL, 
HoTen NVARCHAR(100) NOT NULL, 
NgaySinh DATE NOT NULL CHECK (DATEDIFF(YEAR, NgaySinh, GETDATE()) >= 18), 
GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')), 
CCCD CHAR(12) UNIQUE CHECK (LEN(CCCD) = 12 AND CCCD NOT LIKE '%[^0-9]%'), 
SoDienThoai VARCHAR(15) NOT NULL CHECK (SoDienThoai LIKE '0%' AND LEN(SoDienThoai)=10), 
Email NVARCHAR(100) NOT NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'), 
DiaChi NVARCHAR(255), NgayTao DATETIME DEFAULT GETDATE() ); 
-- Bảng Giảng viên 

CREATE TABLE GiangVien ( 
MaGiangVien INT IDENTITY(1,1) PRIMARY KEY, 
HoTen NVARCHAR(100) NOT NULL, 
SoDienThoai VARCHAR(15) NULL CHECK (SoDienThoai LIKE '0%' AND LEN(SoDienThoai)=10), 
Email NVARCHAR(100) UNIQUE NULL CHECK (Email LIKE '%_@__%.__%'), 
TrangThai NVARCHAR(30) DEFAULT N'Hoạt động' CHECK (TrangThai IN (N'Hoạt động', N'Nghỉ việc')), 
GhiChu NVARCHAR(500) NULL ); 
-- Bảng Khóa Học 

CREATE TABLE KhoaHoc ( 
MaKhoaHoc INT IDENTITY(1,1) PRIMARY KEY, 
TenKhoaHoc NVARCHAR(200) NOT NULL, 
MaLoaiBang INT NOT NULL, 
NgayBatDau DATE NOT NULL, 
NgayKetThuc DATE NOT NULL, 
SoLuongHocVienToiDa INT NOT NULL CHECK (SoLuongHocVienToiDa BETWEEN 10 AND 100), 
SoLuongDaDangKy INT NOT NULL DEFAULT 0 CHECK (SoLuongDaDangKy >= 0), 
TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Sắp mở' CHECK (TrangThai IN (N'Sắp mở', N'Đang mở', N'Đang học', N'Kết thúc', N'Hủy')), 
GhiChu NVARCHAR(500), FOREIGN KEY (MaLoaiBang) REFERENCES LoaiBangLai(MaLoaiBang) ON UPDATE CASCADE ON DELETE NO ACTION, 
CHECK (NgayKetThuc > NgayBatDau), 
CHECK (SoLuongDaDangKy <= SoLuongHocVienToiDa) ); 
-- Bảng trung gian quản lý giảng viên phụ trách khóa học 

CREATE TABLE GiangVien_KhoaHoc ( 
MaGiangVien INT NOT NULL, 
MaKhoaHoc INT NOT NULL, 
GhiChu NVARCHAR(500) NULL, 
NgayPhanCong DATE DEFAULT GETDATE(), 
TrangThai NVARCHAR(20) DEFAULT N'Đang dạy' CHECK (TrangThai IN (N'Đang dạy', N'Hoàn thành', N'Hủy')), 
CONSTRAINT PK_GiangVien_KhoaHoc PRIMARY KEY (MaGiangVien, MaKhoaHoc), 
FOREIGN KEY (MaGiangVien) REFERENCES GiangVien(MaGiangVien) ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (MaKhoaHoc) REFERENCES KhoaHoc(MaKhoaHoc) ON UPDATE CASCADE ON DELETE CASCADE ); 


CREATE TABLE LichHoc ( MaLichHoc INT IDENTITY(1,1) PRIMARY KEY, 
MaKhoaHoc INT NOT NULL, Thu INT NOT NULL CHECK (Thu BETWEEN 1 AND 7), 
GioBatDau TIME NOT NULL, GioKetThuc TIME NOT NULL, GhiChu NVARCHAR(500) NULL, 
CONSTRAINT CHK_LichHoc_Time CHECK (GioKetThuc > GioBatDau), 
FOREIGN KEY (MaKhoaHoc) REFERENCES KhoaHoc(MaKhoaHoc) ON UPDATE CASCADE ON DELETE CASCADE ); 

CREATE TABLE LichThi ( 
MaLichThi INT IDENTITY(1,1) PRIMARY KEY, 
MaKhoaHoc INT NOT NULL, 
NgayThi DATE NOT NULL, 
Thu INT NOT NULL CHECK (Thu BETWEEN 1 AND 7), 
GioBatDau TIME NOT NULL, 
GioKetThuc TIME NOT NULL, 
DiaDiem NVARCHAR(200) NULL, 
GhiChu NVARCHAR(500) NULL, 
CONSTRAINT CHK_LichThi_Time CHECK (GioKetThuc > GioBatDau), 
FOREIGN KEY (MaKhoaHoc) REFERENCES KhoaHoc(MaKhoaHoc) ON UPDATE CASCADE ON DELETE CASCADE ); 
-- Bảng Hồ sơ Đăng ký 

CREATE TABLE HoSoDangKy ( 
MaHoSo INT IDENTITY(1,1) PRIMARY KEY, 
MaHocVien INT NOT NULL, 
MaLoaiBang INT NOT NULL, 
MaKhoaHoc INT NOT NULL, 
NgayDangKy DATETIME DEFAULT GETDATE(), 

-- Thông tin sức khỏe 
TinhTrangSucKhoe NVARCHAR(50) DEFAULT N'Khỏe mạnh', 
NgayKhamSucKhoe DATE NULL, 
GiayKhamSucKhoe NVARCHAR(MAX) NULL, 
Anh3x4 NVARCHAR(255) NULL, 
-- Thông tin đăng ký 
ThoiGianThiDuKien DATE NULL, 
-- Sẽ tự động tính bởi trigger 
-- Thanh toán 
TongHocPhi DECIMAL(15,2) CHECK (TongHocPhi >= 0), 
TrangThaiThanhToan NVARCHAR(30) DEFAULT N'Chưa thanh toán' CHECK (TrangThaiThanhToan IN (N'Chưa thanh toán', N'Đã thanh toán')), 
NgayThanhToan DATETIME NULL, 
-- Trạng thái hồ sơ 
TrangThaiHoSo NVARCHAR(30) DEFAULT N'Chờ duyệt' CHECK (TrangThaiHoSo IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối')), 
NgayDuyet DATETIME NULL, 
GhiChu NVARCHAR(500), 
FOREIGN KEY (MaHocVien) REFERENCES HocVien(MaHocVien), 
FOREIGN KEY (MaLoaiBang) REFERENCES LoaiBangLai(MaLoaiBang), 
FOREIGN KEY (MaKhoaHoc) REFERENCES KhoaHoc(MaKhoaHoc), ); 


CREATE TABLE ThongTinThi ( MaThongTinThi INT IDENTITY(1,1) 
PRIMARY KEY, MaHoSo INT NOT NULL, 
-- Học viên trong hồ sơ đăng ký 
MaLichThi INT NOT NULL, 
-- Lịch thi tương ứng (liên kết tới khóa học) 
-- Kết quả thi 
DiemLyThuyet DECIMAL(5,2) NULL CHECK (DiemLyThuyet BETWEEN 0 AND 100), 
DiemThucHanh DECIMAL(5,2) NULL CHECK (DiemThucHanh BETWEEN 0 AND 100), 
GhiChuLyThuyet NVARCHAR(500) NULL, GhiChuThucHanh NVARCHAR(500) NULL, 
NgayNhapDiem DATETIME NULL,
-- Khóa ngoại 
FOREIGN KEY (MaHoSo) REFERENCES HoSoDangKy(MaHoSo) ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (MaLichThi) REFERENCES LichThi(MaLichThi) ON UPDATE CASCADE ON DELETE CASCADE ); 
-- Bảng Duyệt cấp GPLX 

CREATE TABLE DuyetCapGPLX ( 
MaDuyet INT IDENTITY(1,1) PRIMARY KEY, 
MaThongTinThi INT NOT NULL UNIQUE, 
NgayNop DATETIME NOT NULL DEFAULT GETDATE(), 
NgayDuyet DATETIME NULL, 
TrangThaiDuyet NVARCHAR(30) NOT NULL DEFAULT N'Chờ duyệt' CHECK (TrangThaiDuyet IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối', N'Cần bổ sung')), 
LyDoTuChoi NVARCHAR(500), 
GhiChu NVARCHAR(500) NULL, 
FOREIGN KEY (MaThongTinThi) REFERENCES ThongTinThi(MaThongTinThi) ON UPDATE CASCADE ON DELETE NO ACTION, 
CHECK (NgayDuyet IS NULL OR NgayDuyet >= NgayNop) ); 
-- Bảng GPLX 

CREATE TABLE GPLX ( 
SoGPLX VARCHAR(20) PRIMARY KEY, 
MaHocVien INT NOT NULL, 
MaDuyet INT NOT NULL UNIQUE, 
MaLoaiBang INT NOT NULL, 
NgayCap DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE), 
NgayHetHan DATE NOT NULL, 
NoiCap NVARCHAR(200) NOT NULL DEFAULT N'Sở Giao thông Vận tải', 
TrangThai NVARCHAR(30) DEFAULT N'Đang sử dụng' CHECK (TrangThai IN (N'Đang sử dụng', N'Hết hạn', N'Thu hồi', N'Mất')), 
GhiChu NVARCHAR(500) NULL, 
FOREIGN KEY (MaHocVien) REFERENCES HocVien(MaHocVien) ON UPDATE CASCADE ON DELETE NO ACTION, 
FOREIGN KEY (MaDuyet) REFERENCES DuyetCapGPLX(MaDuyet) ON UPDATE NO ACTION ON DELETE NO ACTION, 
FOREIGN KEY (MaLoaiBang) REFERENCES LoaiBangLai(MaLoaiBang) ON UPDATE CASCADE ON DELETE NO ACTION, 
CHECK (NgayHetHan > NgayCap) );

-- =============================================
-- 1. LOẠI BẰNG LÁI
-- =============================================
INSERT INTO LoaiBangLai (TenLoaiBang, MoTa, PhiThi, SoGioLyThuyet, SoGioThucHanh, ThoiGianThiSauKhoaHoc, DiemDatLyThuyet, DiemDatThucHanh, ThoiHanGPLX, TrangThai)
VALUES
(N'A1',  N'Xe mô tô có dung tích xi-lanh từ 50cc đến dưới 175cc',     800000,   21, 84,  7, 21, 80, 10, N'Hoạt động'),
(N'A2',  N'Xe mô tô có dung tích xi-lanh từ 175cc trở lên',           1000000,  21, 84,  7, 21, 80, 10, N'Hoạt động'),
(N'B1',  N'Ô tô số tự động không kinh doanh vận tải dưới 9 chỗ',      3500000,  90, 100, 7, 21, 80, 10, N'Hoạt động'),
(N'B2',  N'Ô tô lái thuê, kinh doanh vận tải dưới 9 chỗ',             4000000,  90, 100, 7, 21, 80, 10, N'Hoạt động'),
(N'C',   N'Ô tô tải, kéo moóc tải trọng dưới 3.5 tấn',                4500000, 100, 100, 7, 21, 80, 10, N'Hoạt động'),
(N'D',   N'Ô tô chở người từ 10 đến 30 chỗ ngồi',                     5000000, 100,100, 7, 21, 80, 15, N'Hoạt động'),
(N'E',   N'Ô tô chở người trên 30 chỗ ngồi',                          5500000, 100,100, 7, 21, 80, 15, N'Hoạt động'),
(N'F',   N'Các loại xe chuyên dùng: cần cẩu, nâng hàng...',           6000000, 100, 100, 7, 21, 80, 10, N'Hoạt động');

-- =============================================
-- 2. HỌC VIÊN
-- =============================================
INSERT INTO HocVien (TenDangNhap, MatKhau, HoTen, NgaySinh, GioiTinh, CCCD, SoDienThoai, Email, DiaChi)
VALUES
(N'nguyenvana',  N'$2b$10$abc123hashed', N'Nguyễn Văn An',     '2000-03-15', N'Nam', '001200012345', '0912345678', 'vana@gmail.com',     N'12 Lê Lợi, Q1, TP.HCM'),
(N'tranthib',    N'$2b$10$def456hashed', N'Trần Thị Bình',     '1998-07-22', N'Nữ',  '079198023456', '0987654321', 'binhtt@gmail.com',   N'45 Nguyễn Huệ, Q1, TP.HCM'),
(N'levanc',      N'$2b$10$ghi789hashed', N'Lê Văn Cường',      '1995-11-10', N'Nam', '048195034567', '0901122334', 'cuonglv@yahoo.com',  N'78 Trần Hưng Đạo, Q5, TP.HCM'),
(N'phamthid',    N'$2b$10$jkl012hashed', N'Phạm Thị Dung',     '2001-01-05', N'Nữ',  '064201045678', '0933445566', 'dungpt@gmail.com',   N'23 Điện Biên Phủ, Q3, TP.HCM'),
(N'hoangvane',   N'$2b$10$mno345hashed', N'Hoàng Văn Em',      '1997-09-18', N'Nam', '026197056789', '0977889900', 'emhv@gmail.com',     N'56 Cách Mạng Tháng 8, Q10, TP.HCM'),
(N'vuthif',      N'$2b$10$pqr678hashed', N'Vũ Thị Phương',     '1999-05-30', N'Nữ',  '001199067890', '0945123456', 'phuongvt@gmail.com', N'90 Lý Thường Kiệt, Q11, TP.HCM'),
(N'dangvangh',   N'$2b$10$stu901hashed', N'Đặng Văn Giang',    '1993-12-25', N'Nam', '048193078901', '0918765432', 'giangdv@gmail.com',  N'34 Bà Huyện Thanh Quan, Q3, TP.HCM'),
(N'buithinh',    N'$2b$10$vwx234hashed', N'Bùi Thị Hương',     '2002-04-14', N'Nữ',  '079202089012', '0966554433', 'huongbt@gmail.com',  N'15 Võ Thị Sáu, Q3, TP.HCM'),
(N'dovanit',     N'$2b$10$yza567hashed', N'Đỗ Văn Tùng',       '1990-08-03', N'Nam', '001190090123', '0939887766', 'tungdv@gmail.com',   N'67 Pasteur, Q1, TP.HCM'),
(N'ngothik',     N'$2b$10$bcd890hashed', N'Ngô Thị Kim Anh',   '1996-06-20', N'Nữ',  '075196001234', '0922334455', 'kinhant@gmail.com',  N'29 Nam Kỳ Khởi Nghĩa, Q3, TP.HCM');

-- =============================================
-- 3. GIẢNG VIÊN
-- =============================================
INSERT INTO GiangVien (HoTen, SoDienThoai, Email, TrangThai, GhiChu)
VALUES
(N'Nguyễn Minh Tuấn',   '0912111222', 'tuan.gv@truonglaixe.vn',   N'Hoạt động', N'Giảng viên lý thuyết - 10 năm kinh nghiệm'),
(N'Trần Văn Hùng',      '0933222333', 'hung.gv@truonglaixe.vn',   N'Hoạt động', N'Giảng viên thực hành B2 - 8 năm kinh nghiệm'),
(N'Lê Thị Mai',         '0944333444', 'mai.gv@truonglaixe.vn',    N'Hoạt động', N'Giảng viên thực hành B1 - 6 năm kinh nghiệm'),
(N'Phạm Quốc Bảo',      '0955444555', 'bao.gv@truonglaixe.vn',   N'Hoạt động', N'Giảng viên thực hành C, D - 12 năm kinh nghiệm'),
(N'Vũ Thị Lan',         '0966555666', 'lan.gv@truonglaixe.vn',    N'Hoạt động', N'Giảng viên lý thuyết - Luật giao thông'),
(N'Hoàng Đức Thịnh',    '0977666777', 'thinh.gv@truonglaixe.vn', N'Nghỉ việc', N'Đã nghỉ việc từ 01/2024');

-- =============================================
-- 4. KHÓA HỌC
-- =============================================
INSERT INTO KhoaHoc (TenKhoaHoc, MaLoaiBang, NgayBatDau, NgayKetThuc, SoLuongHocVienToiDa, SoLuongDaDangKy, TrangThai, GhiChu)
VALUES
(N'Lớp B2 tháng 3/2025 - Ca sáng',    4, '2025-03-01', '2025-06-30', 30, 28, N'Kết thúc',  N'Học sáng: 7h-11h, thứ 2-6'),
(N'Lớp B2 tháng 5/2025 - Ca chiều',   4, '2025-05-01', '2025-08-31', 30, 25, N'Kết thúc',  N'Học chiều: 13h-17h, thứ 2-6'),
(N'Lớp B1 tháng 6/2025 - Cuối tuần',  3, '2025-06-07', '2025-09-28', 20, 18, N'Kết thúc',  N'Học thứ 7 & CN: 7h-11h'),
(N'Lớp B2 tháng 8/2025 - Ca sáng',    4, '2025-08-01', '2025-11-30', 30, 30, N'Kết thúc',  N'Đã đủ sĩ số'),
(N'Lớp C tháng 9/2025',               5, '2025-09-15', '2026-01-15', 20, 15, N'Kết thúc',  N'Lớp bằng C - tải nhẹ'),
(N'Lớp B2 tháng 11/2025 - Ca sáng',   4, '2025-11-03', '2026-02-28', 30, 22, N'Kết thúc',  N'Học sáng: 7h-11h'),
(N'Lớp B1 tháng 1/2026 - Cuối tuần',  3, '2026-01-10', '2026-04-30', 20, 12, N'Đang học',  N'Đang trong giai đoạn thi'),
(N'Lớp B2 tháng 2/2026 - Ca chiều',   4, '2026-02-01', '2026-05-31', 30, 20, N'Đang học',  N'Học chiều thứ 2-6'),
(N'Lớp A2 tháng 3/2026',              2, '2026-03-01', '2026-05-31', 25, 10, N'Đang học',  N'Lớp mô tô phân khối lớn'),
(N'Lớp B2 tháng 5/2026 - Ca sáng',    4, '2026-05-05', '2026-08-31', 30,  5, N'Đang mở',   N'Đang nhận đăng ký'),
(N'Lớp B2 tháng 7/2026 - Ca chiều',   4, '2026-07-01', '2026-10-31', 30,  0, N'Sắp mở',    N'Dự kiến khai giảng tháng 7/2026'),
(N'Lớp D tháng 8/2026',               6, '2026-08-01', '2027-01-31', 15,  0, N'Sắp mở',    N'Bằng D - xe khách 10-30 chỗ');

-- =============================================
-- 5. GIẢNG VIÊN - KHÓA HỌC
-- =============================================
INSERT INTO GiangVien_KhoaHoc (MaGiangVien, MaKhoaHoc, GhiChu, NgayPhanCong, TrangThai)
VALUES
(1, 1,  N'Phụ trách lý thuyết',          '2025-02-20', N'Hoàn thành'),
(2, 1,  N'Phụ trách thực hành',          '2025-02-20', N'Hoàn thành'),
(1, 2,  N'Phụ trách lý thuyết',          '2025-04-15', N'Hoàn thành'),
(2, 2,  N'Phụ trách thực hành',          '2025-04-15', N'Hoàn thành'),
(1, 3,  N'Lý thuyết cuối tuần',          '2025-05-25', N'Hoàn thành'),
(3, 3,  N'Thực hành B1 số tự động',      '2025-05-25', N'Hoàn thành'),
(1, 4,  N'Phụ trách lý thuyết',          '2025-07-20', N'Hoàn thành'),
(2, 4,  N'Phụ trách thực hành',          '2025-07-20', N'Hoàn thành'),
(1, 5,  N'Lý thuyết xe tải',             '2025-09-01', N'Hoàn thành'),
(4, 5,  N'Thực hành bằng C',             '2025-09-01', N'Hoàn thành'),
(5, 6,  N'Lý thuyết ATGT',               '2025-10-20', N'Hoàn thành'),
(2, 6,  N'Thực hành B2',                 '2025-10-20', N'Hoàn thành'),
(5, 7,  N'Lý thuyết cuối tuần',          '2025-12-25', N'Đang dạy'),
(3, 7,  N'Thực hành B1',                 '2025-12-25', N'Đang dạy'),
(5, 8,  N'Phụ trách lý thuyết',          '2026-01-20', N'Đang dạy'),
(2, 8,  N'Phụ trách thực hành B2',       '2026-01-20', N'Đang dạy'),
(1, 9,  N'Lý thuyết mô tô',              '2026-02-15', N'Đang dạy'),
(5, 10, N'Lý thuyết - lớp mới',          '2026-04-25', N'Đang dạy'),
(2, 10, N'Thực hành - lớp mới',          '2026-04-25', N'Đang dạy');

-- =============================================
-- 6. LỊCH HỌC
-- =============================================
INSERT INTO LichHoc (MaKhoaHoc, Thu, GioBatDau, GioKetThuc, GhiChu)
VALUES
-- Lớp B2 ca sáng (KH 1) - thứ 2,4,6
(1, 2, '07:00', '11:00', N'Lý thuyết & thực hành sáng'),
(1, 4, '07:00', '11:00', N'Lý thuyết & thực hành sáng'),
(1, 6, '07:00', '11:00', N'Thực hành đường trường'),
-- Lớp B2 ca chiều (KH 2) - thứ 3,5,7
(2, 3, '13:00', '17:00', N'Lý thuyết & thực hành chiều'),
(2, 5, '13:00', '17:00', N'Lý thuyết & thực hành chiều'),
(2, 7, '13:00', '17:00', N'Thực hành cuối tuần'),
-- Lớp B1 cuối tuần (KH 3) - thứ 7, CN
(3, 7, '07:00', '11:00', N'Thực hành sáng cuối tuần'),
(3, 1, '07:00', '11:00', N'Lý thuyết Chủ nhật'),
-- Lớp B2 tháng 8 (KH 4)
(4, 2, '07:00', '11:00', N'Lý thuyết & thực hành'),
(4, 4, '07:00', '11:00', N'Lý thuyết & thực hành'),
(4, 6, '07:00', '11:00', N'Thực hành tổng hợp'),
-- Lớp C (KH 5) - thứ 2-6
(5, 2, '07:00', '11:30', N'Lý thuyết xe tải'),
(5, 3, '07:00', '11:30', N'Thực hành lái xe tải'),
(5, 5, '07:00', '11:30', N'Thực hành đường dài'),
-- Lớp B2 tháng 2/2026 (KH 8)
(8, 2, '13:00', '17:00', N'Lý thuyết chiều'),
(8, 4, '13:00', '17:00', N'Thực hành chiều'),
(8, 6, '13:00', '17:00', N'Thực hành đường trường'),
-- Lớp A2 (KH 9)
(9, 3, '08:00', '11:00', N'Lý thuyết & kỹ thuật mô tô'),
(9, 5, '08:00', '11:00', N'Thực hành lái mô tô'),
-- Lớp B2 tháng 5/2026 (KH 10)
(10, 2, '07:00', '11:00', N'Lý thuyết & thực hành'),
(10, 4, '07:00', '11:00', N'Lý thuyết & thực hành'),
(10, 6, '07:00', '11:00', N'Thực hành');

-- =============================================
-- 7. LỊCH THI
-- =============================================
INSERT INTO LichThi (MaKhoaHoc, NgayThi, Thu, GioBatDau, GioKetThuc, DiaDiem, GhiChu)
VALUES
-- Khóa 1 (B2, kết thúc 6/2025): thi LT + TH
(1, '2025-07-08', 3, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B2 - Đợt 1'),
(1, '2025-07-12', 7, '07:00', '11:30', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B2 - Sa hình & đường trường'),
-- Khóa 2 (B2, kết thúc 8/2025)
(2, '2025-09-10', 4, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B2'),
(2, '2025-09-14', 1, '07:00', '11:30', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B2'),
-- Khóa 3 (B1, kết thúc 9/2025)
(3, '2025-10-07', 3, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B1'),
(3, '2025-10-11', 7, '07:00', '11:00', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B1 số tự động'),
-- Khóa 4 (B2, kết thúc 11/2025)
(4, '2025-12-03', 4, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B2'),
(4, '2025-12-07', 1, '07:00', '11:30', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B2'),
-- Khóa 5 (C, kết thúc 1/2026)
(5, '2026-01-20', 3, '08:00', '10:30', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết bằng C'),
(5, '2026-01-24', 7, '06:30', '12:00', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành bằng C - xe tải'),
-- Khóa 6 (B2, kết thúc 2/2026)
(6, '2026-03-10', 3, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B2'),
(6, '2026-03-14', 7, '07:00', '11:30', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B2'),
-- Khóa 7 (B1, đang học, dự kiến thi 5/2026)
(7, '2026-05-06', 4, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B1 - dự kiến'),
(7, '2026-05-10', 1, '07:00', '11:00', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B1 - dự kiến'),
-- Khóa 8 (B2, đang học, dự kiến thi 6/2026)
(8, '2026-06-02', 3, '08:00', '10:00', N'Trung tâm Sát hạch lái xe TP.HCM - 282 Lê Văn Thịnh, Q2', N'Thi lý thuyết B2 - dự kiến'),
(8, '2026-06-06', 7, '07:00', '11:30', N'Sân thi sát hạch - 282 Lê Văn Thịnh, Q2',                   N'Thi thực hành B2 - dự kiến');

-- =============================================
-- 8. HỒ SƠ ĐĂNG KÝ
-- =============================================
INSERT INTO HoSoDangKy (MaHocVien, MaLoaiBang, MaKhoaHoc, NgayDangKy, TinhTrangSucKhoe, NgayKhamSucKhoe, GiayKhamSucKhoe, Anh3x4, ThoiGianThiDuKien, TongHocPhi, TrangThaiThanhToan, NgayThanhToan, TrangThaiHoSo, NgayDuyet, GhiChu)
VALUES
-- Hồ sơ đã hoàn thành (khóa cũ, có điểm, có GPLX)
(1,  4, 1,  '2025-02-15 09:00:00', N'Khỏe mạnh', '2025-02-10', 'GKS-2025-001', 'anh/hv001.jpg', '2025-07-12', 4000000, N'Đã thanh toán', '2025-02-16 10:00:00', N'Đã duyệt', '2025-02-17 14:00:00', N'Hồ sơ đầy đủ'),
(2,  4, 1,  '2025-02-17 10:30:00', N'Khỏe mạnh', '2025-02-12', 'GKS-2025-002', 'anh/hv002.jpg', '2025-07-12', 4000000, N'Đã thanh toán', '2025-02-18 09:00:00', N'Đã duyệt', '2025-02-19 15:00:00', N'Hồ sơ đầy đủ'),
(3,  4, 2,  '2025-04-20 08:00:00', N'Khỏe mạnh', '2025-04-15', 'GKS-2025-003', 'anh/hv003.jpg', '2025-09-14', 4000000, N'Đã thanh toán', '2025-04-21 10:00:00', N'Đã duyệt', '2025-04-22 14:00:00', NULL),
(4,  3, 3,  '2025-05-28 14:00:00', N'Khỏe mạnh', '2025-05-25', 'GKS-2025-004', 'anh/hv004.jpg', '2025-10-11', 3500000, N'Đã thanh toán', '2025-05-29 08:00:00', N'Đã duyệt', '2025-05-30 09:00:00', NULL),
(5,  4, 4,  '2025-07-22 09:00:00', N'Khỏe mạnh', '2025-07-20', 'GKS-2025-005', 'anh/hv005.jpg', '2025-12-07', 4000000, N'Đã thanh toán', '2025-07-23 10:30:00', N'Đã duyệt', '2025-07-24 14:00:00', NULL),
(6,  5, 5,  '2025-09-10 10:00:00', N'Khỏe mạnh', '2025-09-05', 'GKS-2025-006', 'anh/hv006.jpg', '2026-01-24', 4500000, N'Đã thanh toán', '2025-09-11 09:00:00', N'Đã duyệt', '2025-09-12 14:00:00', N'Học viên có kinh nghiệm lái xe'),
(7,  4, 6,  '2025-10-25 09:00:00', N'Khỏe mạnh', '2025-10-20', 'GKS-2025-007', 'anh/hv007.jpg', '2026-03-14', 4000000, N'Đã thanh toán', '2025-10-26 10:00:00', N'Đã duyệt', '2025-10-27 14:00:00', NULL),
-- Hồ sơ đang học (khóa 7, 8, 9)
(8,  3, 7,  '2025-12-20 09:00:00', N'Khỏe mạnh', '2025-12-18', 'GKS-2025-008', 'anh/hv008.jpg', '2026-05-10', 3500000, N'Đã thanh toán', '2025-12-21 10:00:00', N'Đã duyệt', '2025-12-22 14:00:00', NULL),
(9,  4, 8,  '2026-01-22 10:00:00', N'Khỏe mạnh', '2026-01-18', 'GKS-2026-001', 'anh/hv009.jpg', '2026-06-06', 4000000, N'Đã thanh toán', '2026-01-23 08:00:00', N'Đã duyệt', '2026-01-24 14:00:00', NULL),
(10, 2, 9,  '2026-02-25 14:00:00', N'Khỏe mạnh', '2026-02-20', 'GKS-2026-002', 'anh/hv010.jpg', NULL,         1000000, N'Đã thanh toán', '2026-02-26 09:00:00', N'Đã duyệt', '2026-02-27 14:00:00', N'Đăng ký lớp A2'),
-- Hồ sơ mới đăng ký, chờ duyệt
(1,  4, 10, '2026-05-10 09:00:00', N'Khỏe mạnh', '2026-05-08', 'GKS-2026-003', 'anh/hv001b.jpg', NULL,        4000000, N'Chưa thanh toán', NULL,                  N'Chờ duyệt',  NULL,                  N'Đăng ký học lại - lớp mới'),
(3,  4, 10, '2026-05-11 10:00:00', N'Khỏe mạnh', '2026-05-09', 'GKS-2026-004', 'anh/hv003b.jpg', NULL,        4000000, N'Đã thanh toán', '2026-05-12 08:00:00', N'Đã duyệt',   '2026-05-13 09:00:00', NULL);

-- =============================================
-- 9. THÔNG TIN THI
-- =============================================
INSERT INTO ThongTinThi (MaHoSo, MaLichThi, DiemLyThuyet, DiemThucHanh, GhiChuLyThuyet, GhiChuThucHanh, NgayNhapDiem)
VALUES
-- Hồ sơ 1 (HV An, B2, khóa 1) - Đạt cả 2
(1, 1, 88.00, 90.00, N'Đạt - Sai 3 câu trong bộ 450 câu', N'Đạt - Hoàn thành tốt các bài thi sa hình và đường trường', '2025-07-12 17:00:00'),
-- Hồ sơ 2 (HV Bình, B2, khóa 1) - Đạt cả 2
(2, 1, 82.00, 85.00, N'Đạt', N'Đạt - Điểm thực hành tốt', '2025-07-12 17:00:00'),
-- Hồ sơ 3 (HV Cường, B2, khóa 2) - Đạt cả 2
(3, 3, 79.00, 82.00, N'Đạt', N'Đạt', '2025-09-14 17:00:00'),
-- Hồ sơ 4 (HV Dung, B1, khóa 3) - Đạt cả 2
(4, 5, 91.00, 88.00, N'Đạt - Xuất sắc phần lý thuyết', N'Đạt - Thực hành chuẩn', '2025-10-11 17:00:00'),
-- Hồ sơ 5 (HV Em, B2, khóa 4) - Trượt thực hành, chưa nhập điểm thi lại
(5, 7, 75.00, 65.00, N'Đạt', N'Không đạt - Lỗi bài thi ghép xe vào nơi đỗ', '2025-12-07 17:00:00'),
-- Hồ sơ 6 (HV Phương, C, khóa 5) - Đạt cả 2
(6, 9, 85.00, 87.00, N'Đạt', N'Đạt - Thực hành xe tải tốt', '2026-01-24 17:00:00'),
-- Hồ sơ 7 (HV Giang, B2, khóa 6) - Đạt cả 2
(7, 11, 80.00, 83.00, N'Đạt', N'Đạt', '2026-03-14 17:00:00');

-- =============================================
-- 10. DUYỆT CẤP GPLX
-- =============================================
INSERT INTO DuyetCapGPLX (MaThongTinThi, NgayNop, NgayDuyet, TrangThaiDuyet, LyDoTuChoi, GhiChu)
VALUES
(1, '2025-07-14 09:00:00', '2025-07-21 14:00:00', N'Đã duyệt', NULL,  N'Hồ sơ đầy đủ, điểm đạt yêu cầu'),
(2, '2025-07-14 09:30:00', '2025-07-21 14:00:00', N'Đã duyệt', NULL,  N'Hồ sơ đầy đủ'),
(3, '2025-09-15 08:00:00', '2025-09-22 14:00:00', N'Đã duyệt', NULL,  N'Hồ sơ đầy đủ, điểm đạt'),
(4, '2025-10-13 08:00:00', '2025-10-20 14:00:00', N'Đã duyệt', NULL,  N'Hồ sơ hợp lệ - Bằng B1'),
(6, '2026-01-25 09:00:00', '2026-02-01 14:00:00', N'Đã duyệt', NULL,  N'Đủ điều kiện cấp bằng C'),
(7, '2026-03-15 09:00:00', '2026-03-22 14:00:00', N'Đã duyệt', NULL,  N'Hồ sơ đầy đủ'),
-- HV Em (hồ sơ 5) - trượt thực hành, chưa nộp hồ sơ cấp bằng
(5, '2025-12-10 08:00:00', NULL,                  N'Từ chối',  N'Điểm thực hành 65/100 không đạt yêu cầu tối thiểu 80/100. Học viên cần thi lại phần thực hành.', NULL);

-- =============================================
-- 11. GPLX
-- =============================================
INSERT INTO GPLX (SoGPLX, MaHocVien, MaDuyet, MaLoaiBang, NgayCap, NgayHetHan, NoiCap, TrangThai, GhiChu)
VALUES
('B2-HCM-2025-001', 1, 1, 4, '2025-07-25', '2035-07-25', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', NULL),
('B2-HCM-2025-002', 2, 2, 4, '2025-07-25', '2035-07-25', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', NULL),
('B2-HCM-2025-003', 3, 3, 4, '2025-09-26', '2035-09-26', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', NULL),
('B1-HCM-2025-001', 4, 4, 3, '2025-10-24', '2035-10-24', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', N'Bằng B1 số tự động'),
('C-HCM-2026-001',  6, 5, 5, '2026-02-05', '2036-02-05', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', NULL),
('B2-HCM-2026-001', 7, 6, 4, '2026-03-26', '2036-03-26', N'Sở Giao thông Vận tải TP.HCM', N'Đang sử dụng', NULL);

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- SP1: Đăng ký học viên mới
CREATE PROCEDURE sp_DangKyHocVien
    @TenDangNhap NVARCHAR(50),
    @MatKhau NVARCHAR(255),
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @CCCD CHAR(12),
    @SoDienThoai VARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Kiểm tra tuổi
        IF DATEDIFF(YEAR, @NgaySinh, GETDATE()) < 18
        BEGIN
            RAISERROR(N'Học viên phải đủ 18 tuổi!', 16, 1);
            RETURN;
        END;
        
        INSERT INTO HocVien (TenDangNhap, MatKhau, HoTen, NgaySinh, GioiTinh,
                            CCCD, SoDienThoai, Email, DiaChi)
        VALUES (@TenDangNhap, @MatKhau, @HoTen, @NgaySinh, @GioiTinh,
                @CCCD, @SoDienThoai, @Email, @DiaChi);
        
        DECLARE @MaHocVien INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaHocVien AS MaHocVien, N'Đăng ký thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP2: Đăng ký hồ sơ học GPLX
CREATE PROCEDURE sp_DangKyHoSo
    @MaHocVien INT,
    @MaLoaiBang INT,
    @MaKhoaHoc INT,
    @GiayKhamSucKhoe NVARCHAR(255) = NULL,
    @NgayKhamSucKhoe DATE = NULL,
    @ThoiGianHocDuKien DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @TongHocPhi DECIMAL(15,2);
        DECLARE @SoLuongDaDangKy INT, @SoLuongToiDa INT;
        
        -- Kiểm tra khóa học còn chỗ
        SELECT @SoLuongDaDangKy = SoLuongDaDangKy, 
               @SoLuongToiDa = SoLuongHocVienToiDa
        FROM KhoaHoc
        WHERE MaKhoaHoc = @MaKhoaHoc;
        
        IF @SoLuongDaDangKy >= @SoLuongToiDa
        BEGIN
            RAISERROR(N'Khóa học đã đầy!', 16, 1);
            RETURN;
        END;
        
        -- Kiểm tra học viên đã có hồ sơ chưa
        IF EXISTS (
            SELECT 1 FROM HoSoDangKy
            WHERE MaHocVien = @MaHocVien 
              AND MaLoaiBang = @MaLoaiBang
              AND TrangThaiHoSo IN (N'Chờ duyệt', N'Đã duyệt')
        )
        BEGIN
            RAISERROR(N'Bạn đã có hồ sơ đang xử lý!', 16, 1);
            RETURN;
        END;
        
        -- Tính học phí
        SELECT @TongHocPhi = PhiThi
        FROM LoaiBangLai
        WHERE MaLoaiBang = @MaLoaiBang;
        
        INSERT INTO HoSoDangKy (
            MaHocVien, MaLoaiBang, MaKhoaHoc, GiayKhamSucKhoe,
            NgayKhamSucKhoe, ThoiGianHocDuKien, TongHocPhi
        ) VALUES (
            @MaHocVien, @MaLoaiBang, @MaKhoaHoc, @GiayKhamSucKhoe,
            @NgayKhamSucKhoe, @ThoiGianHocDuKien, @TongHocPhi
        );
        
        DECLARE @MaHoSo INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaHoSo AS MaHoSo, N'Đăng ký hồ sơ thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP3: Đăng ký thi
CREATE PROCEDURE sp_DangLichThi
    @MaHoSo INT,
    @MaHocVien INT,
    @MaLichThi INT,
    @LoaiThi NVARCHAR(20) = N'Lần đầu'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @LanThi INT = 1;
        DECLARE @PhiThiLai DECIMAL(15,2) = 0;
        DECLARE @TrangThaiHoSo NVARCHAR(30);
        DECLARE @SoLuongDaDangKy INT, @SoLuongToiDa INT;
        
        -- Kiểm tra hồ sơ đã duyệt chưa
        SELECT @TrangThaiHoSo = TrangThaiHoSo
        FROM HoSoDangKy
        WHERE MaHoSo = @MaHoSo;
        
        IF @TrangThaiHoSo <> N'Đã duyệt'
        BEGIN
            RAISERROR(N'Hồ sơ chưa được duyệt!', 16, 1);
            RETURN;
        END;
        
        -- Kiểm tra kỳ thi còn chỗ
        SELECT @SoLuongDaDangKy = SoLuongDaDangKy,
               @SoLuongToiDa = SoLuongThiSinhToiDa
        FROM LichThi
        WHERE MaLichThi = @MaLichThi;
        
        IF @SoLuongDaDangKy >= @SoLuongToiDa
        BEGIN
            RAISERROR(N'Kỳ thi đã đầy!', 16, 1);
            RETURN;
        END;
        
        -- Nếu thi lại, tính lần thi và phí
        IF @LoaiThi = N'Thi lại'
        BEGIN
            SELECT @LanThi = ISNULL(MAX(LanThi), 0) + 1
            FROM ThongTinThi
            WHERE MaHocVien = @MaHocVien AND MaHoSo = @MaHoSo;
            
            SELECT @PhiThiLai = lbl.PhiThiLai
            FROM HoSoDangKy hs
            INNER JOIN LoaiBangLai lbl ON hs.MaLoaiBang = lbl.MaLoaiBang
            WHERE hs.MaHoSo = @MaHoSo;
        END;
        
        INSERT INTO ThongTinThi (MaHoSo, MaHocVien, MaLichThi, LoaiThi, LanThi, PhiThiLai)
        VALUES (@MaHoSo, @MaHocVien, @MaLichThi, @LoaiThi, @LanThi, @PhiThiLai);
        
        DECLARE @MaThongTinThi INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaThongTinThi AS MaThongTinThi, N'Đăng ký thi thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP4: Nhập điểm thi
CREATE PROCEDURE sp_NhapDiemThi
    @MaThongTinThi INT,
    @MaGiamThi INT,
    @DiemLyThuyet DECIMAL(5,2),
    @DiemThucHanh DECIMAL(5,2),
    @GhiChuLyThuyet NVARCHAR(500) = NULL,
    @GhiChuThucHanh NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE ThongTinThi
        SET NgayThi = GETDATE(),
            MaGiamThi = @MaGiamThi,
            DiemLyThuyet = @DiemLyThuyet,
            DiemThucHanh = @DiemThucHanh,
            GhiChuLyThuyet = @GhiChuLyThuyet,
            GhiChuThucHanh = @GhiChuThucHanh,
            NgayNhapDiem = GETDATE()
        WHERE MaThongTinThi = @MaThongTinThi;
        
        COMMIT TRANSACTION;
        
        SELECT N'Nhập điểm thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP5: Duyệt cấp GPLX và tự động tạo bằng
CREATE PROCEDURE sp_DuyetCapGPLX
    @MaThongTinThi INT,
    @MaHoiDong INT,
    @NguoiDuyet NVARCHAR(100),
    @TrangThaiDuyet NVARCHAR(30),
    @LyDoTuChoi NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @MaHocVien INT, @MaLoaiBang INT, @HoTen NVARCHAR(100);
        DECLARE @KetQuaTong NVARCHAR(20);
        
        -- Lấy thông tin từ ThongTinThi
        SELECT @MaHocVien = tt.MaHocVien,
               @KetQuaTong = tt.KetQuaTong,
               @MaLoaiBang = hs.MaLoaiBang,
               @HoTen = hv.HoTen
        FROM ThongTinThi tt
        INNER JOIN HoSoDangKy hs ON tt.MaHoSo = hs.MaHoSo
        INNER JOIN HocVien hv ON tt.MaHocVien = hv.MaHocVien
        WHERE tt.MaThongTinThi = @MaThongTinThi;
        
        -- Kiểm tra kết quả thi
        IF @KetQuaTong <> N'Đạt' AND @TrangThaiDuyet = N'Đã duyệt'
        BEGIN
            RAISERROR(N'Học viên chưa đạt kết quả thi!', 16, 1);
            RETURN;
        END;
        
        -- Thêm bản ghi duyệt
        INSERT INTO DuyetCapGPLX (
            MaThongTinThi, MaHoiDong, NgayDuyet, TrangThaiDuyet,
            LyDoTuChoi, NguoiDuyet
        ) VALUES (
            @MaThongTinThi, @MaHoiDong, GETDATE(), @TrangThaiDuyet,
            @LyDoTuChoi, @NguoiDuyet
        );
        
        DECLARE @MaDuyet INT = SCOPE_IDENTITY();
        
        -- Nếu duyệt thành công, tạo GPLX
        IF @TrangThaiDuyet = N'Đã duyệt'
        BEGIN
            INSERT INTO GPLX (MaHocVien, MaDuyet, MaLoaiBang, NgayCap, NoiCap)
            VALUES (@MaHocVien, @MaDuyet, @MaLoaiBang, CAST(GETDATE() AS DATE), 
                   N'Sở Giao thông Vận tải');
        END;
        
        COMMIT TRANSACTION;
        
        SELECT @MaDuyet AS MaDuyet, 
               CASE 
                   WHEN @TrangThaiDuyet = N'Đã duyệt' 
                   THEN N'Đã duyệt và cấp GPLX cho ' + @HoTen
                   ELSE N'Đã xử lý duyệt!'
               END AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP6: Thống kê tổng quan
CREATE PROCEDURE sp_ThongKeTongQuan
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Thống kê hồ sơ
    SELECT 
        N'Hồ sơ đăng ký' AS LoaiThongKe,
        COUNT(*) AS TongSo,
        SUM(CASE WHEN TrangThaiHoSo = N'Đã duyệt' THEN 1 ELSE 0 END) AS DaDuyet,
        SUM(CASE WHEN TrangThaiHoSo = N'Chờ duyệt' THEN 1 ELSE 0 END) AS ChoDuyet,
        SUM(CASE WHEN TrangThaiHoSo = N'Từ chối' THEN 1 ELSE 0 END) AS BiTuChoi
    FROM HoSoDangKy
    WHERE NgayDangKy BETWEEN @TuNgay AND @DenNgay;
    
    -- Thống kê thi
    SELECT 
        N'Kết quả thi' AS LoaiThongKe,
        COUNT(*) AS TongLuotThi,
        SUM(CASE WHEN KetQuaTong = N'Đạt' THEN 1 ELSE 0 END) AS SoLuongDat,
        SUM(CASE WHEN KetQuaTong = N'Không đạt' THEN 1 ELSE 0 END) AS SoLuongRot,
        CAST(AVG(TongDiem) AS DECIMAL(5,2)) AS DiemTrungBinh,
        CAST(SUM(CASE WHEN KetQuaTong = N'Đạt' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS TyLeDat
    FROM ThongTinThi
    WHERE NgayThi BETWEEN @TuNgay AND @DenNgay;
    
    -- Thống kê GPLX
    SELECT 
        N'GPLX đã cấp' AS LoaiThongKe,
        COUNT(*) AS TongGPLX,
        SUM(CASE WHEN TrangThai = N'Đang sử dụng' THEN 1 ELSE 0 END) AS DangSuDung,
        SUM(CASE WHEN TrangThai = N'Hết hạn' THEN 1 ELSE 0 END) AS HetHan
    FROM GPLX
    WHERE NgayCap BETWEEN @TuNgay AND @DenNgay;
END;
GO

-- =====================================================
-- VIEWS
-- =====================================================

-- View 1: Tổng quan học viên
CREATE VIEW v_TongQuanHocVien AS
SELECT 
    hv.MaHocVien,
    hv.HoTen,
    hv.CCCD,
    hv.SoDienThoai,
    hv.Email,
    hs.MaHoSo,
    lbl.TenLoaiBang,
    kh.TenKhoaHoc,
    hs.TrangThaiHoSo,
    hs.TrangThaiThanhToan,
    hs.TongHocPhi,
    hs.DaThanhToan,
    kh.NgayBatDau,
    kh.NgayKetThuc,
    hs.ThoiGianThiDuKien
FROM HocVien hv
LEFT JOIN HoSoDangKy hs ON hv.MaHocVien = hs.MaHocVien
LEFT JOIN LoaiBangLai lbl ON hs.MaLoaiBang = lbl.MaLoaiBang
LEFT JOIN KhoaHoc kh ON hs.MaKhoaHoc = kh.MaKhoaHoc;
GO

INSERT INTO HocVien (TenDangNhap, MatKhau, HoTen, NgaySinh, GioiTinh,
                            CCCD, SoDienThoai, Email, DiaChi)
        VALUES (@TenDangNhap, @MatKhau, @HoTen, @NgaySinh, @GioiTinh,
                @CCCD, @SoDienThoai, @Email, @DiaChi);
        
        DECLARE @MaHocVien INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaHocVien AS MaHocVien, N'Đăng ký thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP2: Đăng ký hồ sơ học GPLX
CREATE PROCEDURE sp_DangKyHoSo
    @MaHocVien INT,
    @MaLoaiBang INT,
    @MaKhoaHoc INT,
    @GiayKhamSucKhoe NVARCHAR(255) = NULL,
    @NgayKhamSucKhoe DATE = NULL,
    @ThoiGianHocDuKien DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @TongHocPhi DECIMAL(15,2);
        DECLARE @SoLuongDaDangKy INT, @SoLuongToiDa INT;
        
        -- Kiểm tra khóa học còn chỗ
        SELECT @SoLuongDaDangKy = SoLuongDaDangKy, 
               @SoLuongToiDa = SoLuongHocVienToiDa
        FROM KhoaHoc
        WHERE MaKhoaHoc = @MaKhoaHoc;
        
        IF @SoLuongDaDangKy >= @SoLuongToiDa
        BEGIN
            RAISERROR(N'Khóa học đã đầy!', 16, 1);
            RETURN;
        END;
        
        -- Kiểm tra học viên đã có hồ sơ chưa
        IF EXISTS (
            SELECT 1 FROM HoSoDangKy
            WHERE MaHocVien = @MaHocVien 
              AND MaLoaiBang = @MaLoaiBang
              AND TrangThaiHoSo IN (N'Chờ duyệt', N'Đã duyệt')
        )
        BEGIN
            RAISERROR(N'Bạn đã có hồ sơ đang xử lý!', 16, 1);
            RETURN;
        END;
        
        -- Tính học phí
        SELECT @TongHocPhi = PhiThi
        FROM LoaiBangLai
        WHERE MaLoaiBang = @MaLoaiBang;
        
        INSERT INTO HoSoDangKy (
            MaHocVien, MaLoaiBang, MaKhoaHoc, GiayKhamSucKhoe,
            NgayKhamSucKhoe, ThoiGianHocDuKien, TongHocPhi
        ) VALUES (
            @MaHocVien, @MaLoaiBang, @MaKhoaHoc, @GiayKhamSucKhoe,
            @NgayKhamSucKhoe, @ThoiGianHocDuKien, @TongHocPhi
        );
        
        DECLARE @MaHoSo INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaHoSo AS MaHoSo, N'Đăng ký hồ sơ thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP3: Đăng ký thi
CREATE PROCEDURE sp_DangLichThi
    @MaHoSo INT,
    @MaHocVien INT,
    @MaLichThi INT,
    @LoaiThi NVARCHAR(20) = N'Lần đầu'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @LanThi INT = 1;
        DECLARE @PhiThiLai DECIMAL(15,2) = 0;
        DECLARE @TrangThaiHoSo NVARCHAR(30);
        DECLARE @SoLuongDaDangKy INT, @SoLuongToiDa INT;
        
        -- Kiểm tra hồ sơ đã duyệt chưa
        SELECT @TrangThaiHoSo = TrangThaiHoSo
        FROM HoSoDangKy
        WHERE MaHoSo = @MaHoSo;
        
        IF @TrangThaiHoSo <> N'Đã duyệt'
        BEGIN
            RAISERROR(N'Hồ sơ chưa được duyệt!', 16, 1);
            RETURN;
        END;
        
        -- Kiểm tra kỳ thi còn chỗ
        SELECT @SoLuongDaDangKy = SoLuongDaDangKy,
               @SoLuongToiDa = SoLuongThiSinhToiDa
        FROM LichThi
        WHERE MaLichThi = @MaLichThi;
        
        IF @SoLuongDaDangKy >= @SoLuongToiDa
        BEGIN
            RAISERROR(N'Kỳ thi đã đầy!', 16, 1);
            RETURN;
        END;
        
        -- Nếu thi lại, tính lần thi và phí
        IF @LoaiThi = N'Thi lại'
        BEGIN
            SELECT @LanThi = ISNULL(MAX(LanThi), 0) + 1
            FROM ThongTinThi
            WHERE MaHocVien = @MaHocVien AND MaHoSo = @MaHoSo;
            
            SELECT @PhiThiLai = lbl.PhiThiLai
            FROM HoSoDangKy hs
            INNER JOIN LoaiBangLai lbl ON hs.MaLoaiBang = lbl.MaLoaiBang
            WHERE hs.MaHoSo = @MaHoSo;
        END;
        
        INSERT INTO ThongTinThi (MaHoSo, MaHocVien, MaLichThi, LoaiThi, LanThi, PhiThiLai)
        VALUES (@MaHoSo, @MaHocVien, @MaLichThi, @LoaiThi, @LanThi, @PhiThiLai);
        
        DECLARE @MaThongTinThi INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT @MaThongTinThi AS MaThongTinThi, N'Đăng ký thi thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP4: Nhập điểm thi
CREATE PROCEDURE sp_NhapDiemThi
    @MaThongTinThi INT,
    @MaGiamThi INT,
    @DiemLyThuyet DECIMAL(5,2),
    @DiemThucHanh DECIMAL(5,2),
    @GhiChuLyThuyet NVARCHAR(500) = NULL,
    @GhiChuThucHanh NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE ThongTinThi
        SET NgayThi = GETDATE(),
            MaGiamThi = @MaGiamThi,
            DiemLyThuyet = @DiemLyThuyet,
            DiemThucHanh = @DiemThucHanh,
            GhiChuLyThuyet = @GhiChuLyThuyet,
            GhiChuThucHanh = @GhiChuThucHanh,
            NgayNhapDiem = GETDATE()
        WHERE MaThongTinThi = @MaThongTinThi;
        
        COMMIT TRANSACTION;
        
        SELECT N'Nhập điểm thành công!' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP5: Duyệt cấp GPLX và tự động tạo bằng
CREATE PROCEDURE sp_DuyetCapGPLX
    @MaThongTinThi INT,
    @MaHoiDong INT,
    @NguoiDuyet NVARCHAR(100),
    @TrangThaiDuyet NVARCHAR(30),
    @LyDoTuChoi NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @MaHocVien INT, @MaLoaiBang INT, @HoTen NVARCHAR(100);
        DECLARE @KetQuaTong NVARCHAR(20);
        
        -- Lấy thông tin từ ThongTinThi
        SELECT @MaHocVien = tt.MaHocVien,
               @KetQuaTong = tt.KetQuaTong,
               @MaLoaiBang = hs.MaLoaiBang,
               @HoTen = hv.HoTen
        FROM ThongTinThi tt
        INNER JOIN HoSoDangKy hs ON tt.MaHoSo = hs.MaHoSo
        INNER JOIN HocVien hv ON tt.MaHocVien = hv.MaHocVien
        WHERE tt.MaThongTinThi = @MaThongTinThi;
        
        -- Kiểm tra kết quả thi
        IF @KetQuaTong <> N'Đạt' AND @TrangThaiDuyet = N'Đã duyệt'
        BEGIN
            RAISERROR(N'Học viên chưa đạt kết quả thi!', 16, 1);
            RETURN;
        END;
        
        -- Thêm bản ghi duyệt
        INSERT INTO DuyetCapGPLX (
            MaThongTinThi, MaHoiDong, NgayDuyet, TrangThaiDuyet,
            LyDoTuChoi, NguoiDuyet
        ) VALUES (
            @MaThongTinThi, @MaHoiDong, GETDATE(), @TrangThaiDuyet,
            @LyDoTuChoi, @NguoiDuyet
        );
        
        DECLARE @MaDuyet INT = SCOPE_IDENTITY();
        
        -- Nếu duyệt thành công, tạo GPLX
        IF @TrangThaiDuyet = N'Đã duyệt'
        BEGIN
            INSERT INTO GPLX (MaHocVien, MaDuyet, MaLoaiBang, NgayCap, NoiCap)
            VALUES (@MaHocVien, @MaDuyet, @MaLoaiBang, CAST(GETDATE() AS DATE), 
                   N'Sở Giao thông Vận tải');
        END;
        
        COMMIT TRANSACTION;
        
        SELECT @MaDuyet AS MaDuyet, 
               CASE 
                   WHEN @TrangThaiDuyet = N'Đã duyệt' 
                   THEN N'Đã duyệt và cấp GPLX cho ' + @HoTen
                   ELSE N'Đã xử lý duyệt!'
               END AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SP6: Thống kê tổng quan
CREATE PROCEDURE sp_ThongKeTongQuan
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Thống kê hồ sơ
    SELECT 
        N'Hồ sơ đăng ký' AS LoaiThongKe,
        COUNT(*) AS TongSo,
        SUM(CASE WHEN TrangThaiHoSo = N'Đã duyệt' THEN 1 ELSE 0 END) AS DaDuyet,
        SUM(CASE WHEN TrangThaiHoSo = N'Chờ duyệt' THEN 1 ELSE 0 END) AS ChoDuyet,
        SUM(CASE WHEN TrangThaiHoSo = N'Từ chối' THEN 1 ELSE 0 END) AS BiTuChoi
    FROM HoSoDangKy
    WHERE NgayDangKy BETWEEN @TuNgay AND @DenNgay;
    
    -- Thống kê thi
    SELECT 
        N'Kết quả thi' AS LoaiThongKe,
        COUNT(*) AS TongLuotThi,
        SUM(CASE WHEN KetQuaTong = N'Đạt' THEN 1 ELSE 0 END) AS SoLuongDat,
        SUM(CASE WHEN KetQuaTong = N'Không đạt' THEN 1 ELSE 0 END) AS SoLuongRot,
        CAST(AVG(TongDiem) AS DECIMAL(5,2)) AS DiemTrungBinh,
        CAST(SUM(CASE WHEN KetQuaTong = N'Đạt' THEN 1 ELSE 0 END) * 100.0 / 
             NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS TyLeDat
    FROM ThongTinThi
    WHERE NgayThi BETWEEN @TuNgay AND @DenNgay;
    
    -- Thống kê GPLX
    SELECT 
        N'GPLX đã cấp' AS LoaiThongKe,
        COUNT(*) AS TongGPLX,
        SUM(CASE WHEN TrangThai = N'Đang sử dụng' THEN 1 ELSE 0 END) AS DangSuDung,
        SUM(CASE WHEN TrangThai = N'Hết hạn' THEN 1 ELSE 0 END) AS HetHan
    FROM GPLX
    WHERE NgayCap BETWEEN @TuNgay AND @DenNgay;
END;
GO

-- =====================================================
-- VIEWS
-- =====================================================

-- View 1: Tổng quan học viên
CREATE VIEW v_TongQuanHocVien AS
SELECT 
    hv.MaHocVien,
    hv.HoTen,
    hv.CCCD,
    hv.SoDienThoai,
    hv.Email,
    hs.MaHoSo,
    lbl.TenLoaiBang,
    kh.TenKhoaHoc,
    hs.TrangThaiHoSo,
    hs.TrangThaiThanhToan,
    hs.TongHocPhi,
    hs.DaThanhToan,
    kh.NgayBatDau,
    kh.NgayKetThuc,
    hs.ThoiGianThiDuKien
FROM HocVien hv
LEFT JOIN HoSoDangKy hs ON hv.MaHocVien = hs.MaHocVien
LEFT JOIN LoaiBangLai lbl ON hs.MaLoaiBang = lbl.MaLoaiBang
LEFT JOIN KhoaHoc kh ON hs.MaKhoaHoc = kh.MaKhoaHoc;
GO

-- View 2: Lịch sử thi học viên
CREATE VIEW v_LichSuThi AS
SELECT 
    hv.MaHocVien,
    hv.HoTen,
    lbl.TenLoaiBang,
    tt.LanThi,
    tt.LoaiThi,
    kt.TenLichThi,
    kt.NgayThi AS NgayThiKeHoach,
    tt.NgayThi AS NgayThiThucTe,
    tt.DiemLyThuyet,
    tt.DiemThucHanh,
    tt.TongDiem,
    tt.KetQuaLyThuyet,
    tt.KetQuaThucHanh,
    tt.KetQuaTong,
    tt.XepLoai,
    gt.HoTen AS GiamThiCham
FROM ThongTinThi tt
INNER JOIN HocVien hv ON tt.MaHocVien = hv.MaHocVien
INNER JOIN LichThi kt ON tt.MaLichThi = kt.MaLichThi
INNER JOIN HoSoDangKy hs ON tt.MaHoSo = hs.MaHoSo
INNER JOIN LoaiBangLai lbl ON hs.MaLoaiBang = lbl.MaLoaiBang
LEFT JOIN GiamThi gt ON tt.MaGiamThi = gt.MaGiamThi;
GO

INSERT INTO HocVien (
    TenDangNhap,
    MatKhau,
    HoTen,
    NgaySinh,
    GioiTinh,
    CCCD,
    SoDienThoai,
    Email
)
VALUES (
    'nguyenvana',
    '123456',
    N'Nguyễn Văn A',
    '2000-01-01',
    N'Nam',
    '123456789012',
    '0912345678',
    'a@gmail.com'
);
SELECT * FROM HocVien;

ALTER LOGIN sa WITH PASSWORD = 'Sa123456';
GO