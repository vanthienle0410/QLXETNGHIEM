-- I. DDL & INITIAL DML: TẠO CẤU TRÚC, XÓA DỮ LIỆU CŨ VÀ NẠP DỮ LIỆU MỚI

-- 1. TẠO CƠ SỞ DỮ LIỆU
CREATE DATABASE QLXetNghiem
GO

USE QLXetNghiem
GO

-- 2. XÓA BẢNG VÀ KHÓA NGOẠI (Đảm bảo script chạy lại không lỗi)
-- Xóa Khóa Ngoại trước
IF OBJECT_ID('FK_NHANVIEN_CONGTY', 'F') IS NOT NULL
    ALTER TABLE [dbo].[NHANVIEN] DROP CONSTRAINT [FK_NHANVIEN_CONGTY]
GO

-- Xóa Bảng NHANVIEN
IF OBJECT_ID('[dbo].[NHANVIEN]', 'U') IS NOT NULL
    DROP TABLE [dbo].[NHANVIEN]
GO

-- Xóa Bảng CONGTY
IF OBJECT_ID('[dbo].[CONGTY]', 'U') IS NOT NULL
    DROP TABLE [dbo].[CONGTY]
GO

-- 3. TẠO BẢNG CONGTY
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CONGTY] (
    [MaCty] [nvarchar] (6) NOT NULL,
    [TenCty] [nvarchar] (100) NOT NULL,
    [SLNV] [int] NOT NULL,
    CONSTRAINT [PK_CONGTY] PRIMARY KEY CLUSTERED
    (
        [MaCty] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- 4. CHÈN DỮ LIỆU VÀO CONGTY
INSERT [dbo].[CONGTY] ([MaCty], [TenCty], [SLNV]) VALUES (N'HITECH', N'HI-TECH WIRES ASIA', 1200)
INSERT [dbo].[CONGTY] ([MaCty], [TenCty], [SLNV]) VALUES (N'THANAM', N'SĂN XUẤT THƯƠNG MẠI DƯỢC PHẨM THÀNH NAM', 850)
INSERT [dbo].[CONGTY] ([MaCty], [TenCty], [SLNV]) VALUES (N'VISION', N'VISION INTERNATIONAL', 5000)
GO

-- 5. TẠO BẢNG NHANVIEN
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHANVIEN](
    [ID] [nvarchar] (12) NOT NULL,
    [HoTen] [nvarchar] (200) NOT NULL,
    [SoLanXN] [int] NOT NULL,
    [AmTinh] [bit] NOT NULL, -- 1=Âm Tính, 0=Dương Tính
    [MaCty] [nvarchar] (6) NOT NULL,
    CONSTRAINT [PK_NHANVIEN] PRIMARY KEY CLUSTERED
    (
        [ID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- 6. CHÈN DỮ LIỆU VÀO NHANVIEN
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SoLanXN], [AmTinh], [MaCty]) VALUES (N'026087011432', N'Nguyễn Văn D', 1, 1, N'VISION')
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SoLanXN], [AmTinh], [MaCty]) VALUES (N'036284010260', N'Nguyễn Văn C', 2, 0, N'HITECH')
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SoLanXN], [AmTinh], [MaCty]) VALUES (N'240837639', N'Nguyễn Văn A', 1, 1, N'VISION')
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SoLanXN], [AmTinh], [MaCty]) VALUES (N'241233818', N'Nguyễn Văn B', 2, 0, N'THANAM')
GO

-- 7. THIẾT LẬP KHÓA NGOẠI
ALTER TABLE [dbo].[NHANVIEN] WITH CHECK ADD CONSTRAINT
[FK_NHANVIEN_CONGTY] FOREIGN KEY([MaCty])
REFERENCES [dbo].[CONGTY] ([MaCty])
GO

ALTER TABLE [dbo].[NHANVIEN] CHECK CONSTRAINT [FK_NHANVIEN_CONGTY]
GO

---------------------------------------------------
-- II. CÁC TRUY VẤN CHỨC NĂNG (DML)
---------------------------------------------------

-- 1. LOAD FORM / HIỂN THỊ TẤT CẢ NHÂN VIÊN (Yêu cầu 1)
SELECT
    NV.ID AS [CMND/CCCD],
    NV.HoTen AS [Họ và Tên],
    NV.SoLanXN AS [Số lần XN],
    CASE 
        WHEN NV.AmTinh = 0 THEN N'+' -- Dương Tính
        ELSE N'Âm Tính' 
    END AS [Kết Quả],
    NV.MaCty, -- Để dùng cho chức năng Cập nhật
    CT.TenCty
FROM
    [dbo].[NHANVIEN] AS NV
INNER JOIN
    [dbo].[CONGTY] AS CT ON NV.MaCty = CT.MaCty
ORDER BY 
    NV.ID;
GO

-- 2. TRUY VẤN TÌM KIẾM NHÂN VIÊN THEO ID (Yêu cầu 2.4)
-- Sử dụng trong code để lấy dữ liệu @ID_Nhap
SELECT
    NV.HoTen,
    NV.SoLanXN, 
    NV.AmTinh, 
    NV.MaCty,
    CT.TenCty
FROM
    [dbo].[NHANVIEN] AS NV
INNER JOIN
    [dbo].[CONGTY] AS CT ON NV.MaCty = CT.MaCty
WHERE
    NV.ID = @ID_Nhap; 
GO

-- 3. THÊM MỚI NHÂN VIÊN (Yêu cầu 3.1)
-- Lệnh cần sử dụng tham số (@...)
-- INSERT INTO [dbo].[NHANVIEN] ([ID], [HoTen], [SoLanXN], [AmTinh], [MaCty])
-- VALUES (@ID_Moi, @HoTen_Moi, @SoLanXN_Moi, @AmTinh_Moi, @MaCty_Moi);

-- 4. CẬP NHẬT NHÂN VIÊN (Yêu cầu 3.2)
-- Lệnh cần sử dụng tham số (@...)
-- UPDATE [dbo].[NHANVIEN]
-- SET
--     [HoTen] = @HoTen_Moi,
--     [SoLanXN] = @SoLanXN_Moi, 
--     [AmTinh] = @AmTinh_Moi,
--     [MaCty] = @MaCty_Moi
-- WHERE
--     [ID] = @ID_HienTai;

-- 5. DANH SÁCH NHÂN VIÊN DƯƠNG TÍNH (Yêu cầu 4.1)
SELECT
    NV.ID AS [CMND/CCCD],
    NV.HoTen AS [Họ và Tên],
    NV.SoLanXN AS [Số lần XN],
    N'+' AS [Kết Quả]
FROM
    [dbo].[NHANVIEN] AS NV
WHERE
    NV.AmTinh = 0;
GO

-- 6. DANH SÁCH CÔNG TY ĐÃ TEST ĐỦ YÊU CẦU (Yêu cầu 4.2)
SELECT
    CT.TenCty
FROM
    [dbo].[CONGTY] AS CT
INNER JOIN
    [dbo].[NHANVIEN] AS NV ON CT.MaCty = NV.MaCty
GROUP BY
    CT.MaCty, CT.TenCty, CT.SLNV
HAVING
    COUNT(NV.ID) >= CT.SLNV;
GO

-- 7. BÁO CÁO XÉT NGHIỆM CHO 1 CÔNG TY (Yêu cầu 5)
-- Dùng để nạp dữ liệu vào Report Viewer
SELECT
    NV.ID AS [CCCD/CMND],
    NV.HoTen AS [Họ Và Tên],
    CASE 
        WHEN NV.AmTinh = 0 THEN N'Dương Tính' 
        ELSE N'Âm Tính' 
    END AS [Kết Quả]
FROM
    [dbo].[NHANVIEN] AS NV
WHERE
    NV.MaCty = @MaCty_DuocChon; -- Tham số truyền vào từ Combobox chọn công ty
GO