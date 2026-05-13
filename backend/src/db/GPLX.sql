
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
GiayKhamSucKhoe VARCHAR(50) NULL, 
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