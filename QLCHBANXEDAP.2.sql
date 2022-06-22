﻿CREATE DATABASE QLCUAHANGXEDAP_2

USE QLCUAHANGXEDAP_2

CREATE TABLE KHACHHANG
(
	MA_KHACHHANG VARCHAR(5) CONSTRAINT PK_KH PRIMARY KEY,
	TEN VARCHAR(10),
	HO VARCHAR(10),
	SO_DIENTHOAI VARCHAR(20),
	EMAIL VARCHAR(50),
	DUONG_DIACHI VARCHAR(50),
	TP_DIACHI VARCHAR(30),
	BANG_DIACHI VARCHAR(30),
	MA_BUUCHINH VARCHAR(5),
)

CREATE TABLE NHANVIEN
(
	MA_NHANVIEN VARCHAR(5) CONSTRAINT PK_NV PRIMARY KEY,
	TEN VARCHAR(10),
	HO VARCHAR(10),
	EMAIL VARCHAR(50),
	SO_DIENTHOAI VARCHAR(20),
	DANG_LAMVIEC INT,
	MA_CUAHANG VARCHAR(5),
	MA_NGUOIQL VARCHAR(5)
)

CREATE TABLE NHASX
(
	MA_NHASX VARCHAR(5) CONSTRAINT PK_NSX PRIMARY KEY,
	TEN_NHASX VARCHAR(50),
)

CREATE TABLE LOAISP
(
	MA_LOAISP VARCHAR(5) CONSTRAINT PK_LSP PRIMARY KEY,
	TEN_LOAISP VARCHAR(50),
)

CREATE TABLE SANPHAM
(
	MA_SANPHAM VARCHAR(5) CONSTRAINT PK_SP PRIMARY KEY,
	TEN_SANPHAM VARCHAR(50),
	MA_NHASX VARCHAR(5),
	MA_LOAISP VARCHAR(5),
	NAM INT,
	GIABAN MONEY
)

CREATE TABLE KHO
(
	MA_CUAHANG VARCHAR(5),
	MA_SANPHAM VARCHAR(5),
	SOLUONG INT,
	CONSTRAINT PK_KHO PRIMARY KEY(MA_CUAHANG, MA_SANPHAM)
)

CREATE TABLE CUAHANG
(
	MA_CUAHANG VARCHAR(5) CONSTRAINT PK_CH PRIMARY KEY,
	TEN_CUAHANG VARCHAR(50),
	SO_DIENTHOAI VARCHAR(20),
	EMAIL VARCHAR(50),
	DUONG_DIACHI VARCHAR(50),
	TP_DIACHI VARCHAR(30),
	BANG_DIACHI VARCHAR(30),
	MA_BUUCHINH VARCHAR(5),
)

CREATE TABLE HOADON
(
	SO_HOADON VARCHAR(5) CONSTRAINT PK_HD PRIMARY KEY,
	MA_KHACHHANG VARCHAR(5),
	TRANGTHAI_HOADON VARCHAR(20),
	NGAY_HOADON SMALLDATETIME,
	NGAY_GHDUKIEN SMALLDATETIME,
	NGAY_GHTHUCTE SMALLDATETIME,
	MA_CUAHANG VARCHAR(5),
	MA_NHANVIEN VARCHAR(5)
)

CREATE TABLE CTHD
(
	SO_HOADON VARCHAR(5),
	MA_CHIECXE VARCHAR(5),
	MA_SANPHAM VARCHAR(5),
	SOLUONG INT,
	GIABAN MONEY,
	GIAMGIA INT,
	CONSTRAINT PK_CT PRIMARY KEY(SO_HOADON,MA_CHIECXE)
)

ALTER TABLE NHANVIEN
ADD CONSTRAINT A FOREIGN KEY (MA_CUAHANG) REFERENCES CUAHANG(MA_CUAHANG)

ALTER TABLE NHANVIEN
ADD CONSTRAINT B FOREIGN KEY (MA_NGUOIQL) REFERENCES NHANVIEN(MA_NHANVIEN)

ALTER TABLE SANPHAM
ADD CONSTRAINT C FOREIGN KEY (MA_NHASX) REFERENCES NHASX(MA_NHASX)

ALTER TABLE SANPHAM
ADD CONSTRAINT D FOREIGN KEY (MA_LOAISP) REFERENCES LOAISP(MA_LOAISP)

ALTER TABLE KHO
ADD CONSTRAINT E FOREIGN KEY (MA_CUAHANG) REFERENCES CUAHANG(MA_CUAHANG)

ALTER TABLE KHO
ADD CONSTRAINT F FOREIGN KEY (MA_SANPHAM) REFERENCES SANPHAM(MA_SANPHAM)

ALTER TABLE HOADON
ADD CONSTRAINT G FOREIGN KEY (MA_KHACHHANG) REFERENCES KHACHHANG(MA_KHACHHANG)

ALTER TABLE HOADON
ADD CONSTRAINT H FOREIGN KEY (MA_CUAHANG) REFERENCES CUAHANG(MA_CUAHANG)

ALTER TABLE HOADON
ADD CONSTRAINT I FOREIGN KEY (MA_NHANVIEN) REFERENCES NHANVIEN(MA_NHANVIEN)

ALTER TABLE CTHD
ADD CONSTRAINT K FOREIGN KEY (SO_HOADON) REFERENCES HOADON(SO_HOADON)

ALTER TABLE CTHD
ADD CONSTRAINT L FOREIGN KEY (MA_CHIECXE) REFERENCES SANPHAM(MA_SANPHAM)

ALTER TABLE CTHD
ADD CONSTRAINT M FOREIGN KEY (MA_SANPHAM) REFERENCES SANPHAM(MA_SANPHAM)

--1. Hiện thực ràng buộc toàn vẹn sau: Các chi tiết hóa đơn có số lượng lớn hơn 2 thì đều được
--giảm giá nhiều hơn 12% (1đ).
ALTER TABLE CTHD
ADD CONSTRAINT CK_CT CHECK(SOLUONG <=12 OR (SOLUONG >12 AND GIAMGIA >12))
--2. Hiện thực ràng buộc toàn vẹn sau: Giá bán của sản phẩm trong quan hệ SANPHAM không
--được lớn hơn giá bán của sản phẩm đó trong quan hệ CTHD (2đ).
CREATE TRIGGER TRIGGER_INSERT_UPDATE_CT ON CTHD
FOR INSERT, UPDATE
AS
BEGIN
	 IF EXISTS ( SELECT *
				FROM INSERTED CT, SANPHAM SP
				WHERE  CT.MA_SANPHAM=SP.MA_SANPHAM
				       AND SP.GIABAN>CT.GIABAN)
		BEGIN	
			PRINT 'ERROR!'
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'THANH CONG'
END

CREATE TRIGGER TRIGGER_UPDATE_SP ON SANPHAM
FOR UPDATE
AS
BEGIN
	
    IF EXISTS ( SELECT *
				FROM INSERTED SP, CTHD CT
				WHERE  CT.MA_SANPHAM=SP.MA_SANPHAM
				       AND SP.GIABAN>CT.GIABAN)
		BEGIN	
			PRINT 'ERROR!'
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'THANH CONG'
END
--3. Liệt kê các sản phẩm được sản xuất từ năm 2019 trở đi (1đ).
SELECT MA_SANPHAM, TEN_SANPHAM
FROM SANPHAM
WHERE NAM>=2019
--4. Tìm các hóa đơn có trạng thái Đã hoàn thành của khách hàng ở thành phố Ronkonkoma (1đ)
SELECT SO_HOADON
FROM HOADON HD, KHACHHANG KH
WHERE HD.MA_KHACHHANG=KH.MA_KHACHHANG AND TP_DIACHI='Ronkonkoma'
      AND TRANGTHAI_HOADON='Đã hoàn thành'
--5. In ra danh sách các sản phẩm được bán bởi nhân viên có mã là 8 (1đ).
SELECT SP.MA_SANPHAM, TEN_SANPHAM
FROM SANPHAM SP, CTHD CT, HOADON HD
WHERE SP.MA_SANPHAM=CT.MA_SANPHAM AND CT.SO_HOADON=HD.SO_HOADON
      AND MA_NHANVIEN='8'
--6. In ra danh sách các hóa đơn có trạng thái Hủy đã mua các sản phẩm của nhà sản xuất Electra
--(1đ).
SELECT HD.SO_HOADON
FROM HOADON HD, CTHD CT, SANPHAM SP, NHASX NSX
WHERE HD.SO_HOADON=CT.SO_HOADON AND CT.MA_SANPHAM=SP.MA_SANPHAM AND SP.MA_NHASX=NSX.MA_NHASX
      AND TEN_NHASX='Electra' AND TRANGTHAI_HOADON='Hủy'
--7. Tìm nhân viên vừa bán được các sản phẩm loại Children Bicycles vừa bán được các sản phẩm
--loại Road Bikes (1đ).
SELECT NV.MA_NHANVIEN, HO+' '+TEN AS HOVATEN_NV
FROM NHANVIEN NV, HOADON HD, CTHD CT, SANPHAM SP, LOAISP LSP
WHERE NV.MA_NHANVIEN=HD.MA_NHANVIEN AND HD.SO_HOADON=CT.SO_HOADON
      AND CT.MA_SANPHAM=SP.MA_SANPHAM AND SP.MA_LOAISP=LSP.MA_LOAISP
	  AND TEN_LOAISP='Children Bicycles'
INTERSECT
SELECT NV.MA_NHANVIEN, HO+' '+TEN AS HOVATEN_NV
FROM NHANVIEN NV, HOADON HD, CTHD CT, SANPHAM SP, LOAISP LSP
WHERE NV.MA_NHANVIEN=HD.MA_NHANVIEN AND HD.SO_HOADON=CT.SO_HOADON
      AND CT.MA_SANPHAM=SP.MA_SANPHAM AND SP.MA_LOAISP=LSP.MA_LOAISP
	  AND TEN_LOAISP='Road Bikes'
--8. Tìm các khách hàng mua nhiều xe đạp của hãng Pure Cycles nhất (1đ).
SELECT TOP 1 WITH TIES  KH.MA_KHACHHANG, HO+' '+TEN AS HOVATEN_KH
FROM KHACHHANG KH, HOADON HD, CTHD CT, SANPHAM SP, NHASX NSX
WHERE KH.MA_KHACHHANG=HD.MA_KHACHHANG AND HD.SO_HOADON=CT.SO_HOADON
      AND CT.MA_SANPHAM=SP.MA_SANPHAM AND SP.MA_SANPHAM=NSX.MA_NHASX
	  AND TEN_NHASX='Pure Cycles'
GROUP BY KH.MA_KHACHHANG, HO+' '+TEN
ORDER BY SUM(CT.SOLUONG) DESC
--9. Tìm nhân viên đã bán tất cả xe đạp được sản xuất vào năm 2017 (1đ).
SELECT MA_NHANVIEN, HO+' '+TEN AS HOTEN_NV
FROM NHANVIEN NV
WHERE NOT EXISTS (SELECT *
                  FROM SANPHAM SP, CTHD CT
				  WHERE SP.MA_SANPHAM=CT.MA_SANPHAM
				        AND NOT EXISTS (SELECT *
						                FROM HOADON HD
										WHERE HD.MA_NHANVIEN=NV.MA_NHANVIEN
										      AND HD.SO_HOADON=CT.SO_HOADON))
