DROP DATABASE 
CREATE DATABASE QLNHAHANG

USE QLNHAHANG

CREATE TABLE NHAHANG
(
	MANH CHAR(4) CONSTRAINT PK_NH PRIMARY KEY,
	TENNH VARCHAR(40),
	AMTHUC VARCHAR(20),
	MAVT CHAR(4),
	MADG CHAR(4),
)

CREATE TABLE VITRI
(
	MAVT CHAR(4) CONSTRAINT PK_VT PRIMARY KEY,
	QUAN VARCHAR(40),
	THANHPHO VARCHAR(40)
)

CREATE TABLE DANHGIA
(
	MADG CHAR(4) CONSTRAINT PK_DG PRIMARY KEY,
	DANHGIA FLOAT,
	GIATB MONEY,
	SLDG INT
)

ALTER TABLE NHAHANG
ADD CONSTRAINT Fk_NH_VT FOREIGN KEY (MAVT) REFERENCES VITRI(MAVT)

ALTER TABLE NHAHANG
ADD CONSTRAINT Fk_NH_DG FOREIGN KEY (MADG) REFERENCES DANHGIA(MADG)

SET DATEFORMAT DMY

INSERT INTO VITRI VALUES ('VT01','THU DUC', 'HO CHI MINH')
INSERT INTO VITRI VALUES ('VT02', 'PHU NHUAN', 'HO CHI MINH')
INSERT INTO VITRI VALUES ('VT03', 'BA DINH', 'HA NOI')

INSERT INTO DANHGIA VALUES ('DG01', '3.5', '200000', '1531')
INSERT INTO DANHGIA VALUES ('DG02', '2.5', '550000', '324')
INSERT INTO DANHGIA VALUES ('DG03', '4.5', '420000', '83')
INSERT INTO DANHGIA VALUES ('DG04', '4.5', '80000', '815')

INSERT INTO NHAHANG VALUES ('NH01', 'SUSHI NGON', 'NHAT BAN', 'VT01', 'DG01')
INSERT INTO NHAHANG VALUES ('NH02', 'TIEM BANH NEWYORK', 'MY', 'VT03', 'DG02')
INSERT INTO NHAHANG VALUES ('NH03', 'TIEM TRA HOANG GIA', 'MY', 'VT01', 'DG03')
INSERT INTO NHAHANG VALUES ('NH04', 'BUN BO HUE', 'VIET NAM', 'VT01', 'DG04')

--1
--TRIGGER ON NHAHANG
CREATE TRIGGER TRIGGER_INSERT_UPDATE_NH ON NHAHANG
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @QUAN VARCHAR(40), @GIATB MONEY

	SELECT @QUAN=QUAN, @GIATB= GIATB
	FROM INSERTED NH, VITRI VT, DANHGIA DG
	WHERE VT.MAVT=NH.MAVT AND NH.MADG=DG.MADG

	IF(@QUAN='BA DINH')
		BEGIN
			IF(@GIATB<=50000)
				BEGIN
					PRINT 'ERROR!'
					ROLLBACK TRAN
				END
			PRINT 'THANH CONG'
		END
END

--TRIGGER ON VITRI
CREATE TRIGGER TRIGGER_UPDATE_VT ON VITRI
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
	           FROM INSERTED VT, NHAHANG NH, DANHGIA DG
	           WHERE VT.MAVT=NH.MAVT AND NH.MADG=DG.MADG
			         AND QUAN='BA DINH' AND GIATB<=50000)
		BEGIN
			PRINT'ERROR!'
			ROLLBACK TRAN
		END
	PRINT 'THANH CONG'
END

--4
ALTER TABLE DANHGIA
ADD GHICHU VARCHAR(40)
--5
SELECT MANH, TENNH
FROM NHAHANG
WHERE AMTHUC='MY'

--6
SELECT NH.MANH, TENNH, DANHGIA, GIATB, SLDG
FROM NHAHANG NH, DANHGIA DG, VITRI VT
WHERE NH.MAVT=VT.MAVT AND NH.MADG=DG.MADG AND THANHPHO='HO CHI MINH'
ORDER BY DANHGIA ASC, GIATB DESC

--7
SELECT *
FROM VITRI
EXCEPT
SELECT VT.MAVT, QUAN, THANHPHO
FROM VITRI VT, NHAHANG NH, DANHGIA DG
WHERE VT.MAVT=NH.MAVT AND DG.MADG=NH.MADG

--8
SELECT COUNT(NH1.MANH) AS SL_TREN, COUNT(NH2.MANH) AS SL_DUOI
FROM NHAHANG NH1, DANHGIA DG, NHAHANG NH2
WHERE NH1.MADG=DG.MADG AND NH2.MADG=DG.MADG
      AND NH1.MANH IN (SELECT MANH
	                   FROM NHAHANG NH, DANHGIA DG
                       WHERE NH.MADG=DG.MADG AND GIATB >500000)
	  AND NH2.MANH IN (SELECT MANH
	                   FROM NHAHANG NH, DANHGIA DG
                       WHERE NH.MADG=DG.MADG AND GIATB <500000)
