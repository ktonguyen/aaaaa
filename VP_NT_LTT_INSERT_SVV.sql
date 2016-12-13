CREATE OR REPLACE FUNCTION "VP_NT_LTT_INSERT_SVV"(
p_dvtt 	varchar2 , 
	p_id_tiepnhan 	varchar2 , 
	v_NGAY_GIO_TAO 	varchar2 ,
	p_NHAN_VIEN_TAO 	number ,
	p_SOTIENPHAITHANHTOAN 	number ,
	p_SOTIENBNTRA 	number ,
	p_SOTIENTHOILAI 	number ,
	p_STT_LANTHANHTOxAN 	number ,
	p_THANHTOANDAODONG 	number, -- thu?ng m?c d?nh là 0, phát sinh thì tính sau.
	p_SO_BIEN_LAI 	varchar2 ,
	p_ghichu varchar2 ,
	p_makhambenh varchar2,
	p_ngay date,
  v_sovaovien number
) RETURN varchar2



aaaaaa







IS
V_TONGTIENPHAITRA number(18);
         v_temp number(10);
     v_ketqua number(1);
     v_function NUMBER(1);
      p_STT_LANTT varchar2(50);
       p_max_stt_tuongung_idtiepnhan number(10);
     v_finished NUMBER(10) DEFAULT 0;
	   v_ID_CHITIETLANTT varchar2(50) DEFAULT '';
	   v_SOTIEN_CHITIETLANTT number(18,2) DEFAULT 0;
	   v_NHOM_LANTT varchar2(150) DEFAULT '';
	    v_MA_DV number(10);
	    v_NOIDUNG varchar2(500);
	    v_SOLUONG number(10);
	    v_DONGIA number(18,2);
	    v_THANHTIEN number(18,2);
	    v_BENHNHAN_phaitra number(18,2);
     p_NGAY_GIO_TAO timestamp;
		v_ma_benh_nhan number(11);
    p_thamso_208 varchar2(5);
v_cobaohiem number(1);
 CURSOR ID_CHITIETLANTT_cursor IS 
		 SELECT sophieu,THANHTIEN,ghi_chu,MA_DV,TEN_DV ,SOLUONG ,DONGIA  FROM ds_benhnhan_thanhtoanct_koBH
				where DVTT = p_dvtt and ID_TIEPNHAN= p_id_tiepnhan AND SOVAOVIEN=v_sovaovien;
       
BEGIN
        
    begin
 select mota_thamso into p_thamso_208 
		from his_fw.dm_thamso_donvi
	where ma_thamso = 208
	and dvtt = p_dvtt;
exception when no_data_found then p_thamso_208:=0 ;
  end;
        
		begin
	  select MA_BENH_NHAN, nvl(co_bao_hiem,0) into v_ma_benh_nhan, v_cobaohiem from KB_TIEP_NHAN where id_tiepnhan = p_id_tiepnhan
		and dvtt = p_dvtt and sovaovien=v_sovaovien;
		EXCEPTION when no_data_found THEN
			v_ma_benh_nhan := 0;
			v_cobaohiem:=0;
		end;
    p_NGAY_GIO_TAO := sysdate;
    select nvl( max(cast( replace(STT_LANTT,concat(p_id_tiepnhan,'_'),'') as number(18,0)))   ,0)  
		into p_max_stt_tuongung_idtiepnhan from vienphingoaitru_lantt
		where id_tiepnhan = p_id_tiepnhan
		and dvtt = p_dvtt and MABENHNHAN = v_ma_benh_nhan and SOVAOVIEN =v_sovaovien;
    v_temp:=p_max_stt_tuongung_idtiepnhan+1;
    p_STT_LANTT:= p_id_tiepnhan||'_'||v_temp;
		
		INSERT INTO vienphingoaitru_lantt
		(STT_LANTT,
		dvtt,
		id_tiepnhan,
		NGAY_GIO_TAO,
		NHAN_VIEN_TAO,
		SOTIENPHAITHANHTOAN,
		SOTIENBNTRA,
		SOTIENTHOILAI,
		STT_LANTHANHTOAN,
		TT_LANTT,
		THANHTOANDAODONG,
		SO_BIEN_LAI,
		ghichu,COBAOHIEM, TONGTIENBNTHANHTOAN, MABENHNHAN, SOVAOVIEN)
		VALUES
		(p_STT_LANTT ,
		p_dvtt ,
		p_id_tiepnhan ,
		v_NGAY_GIO_TAO ,
		p_NHAN_VIEN_TAO ,
		p_SOTIENPHAITHANHTOAN ,
		p_SOTIENBNTRA ,
		p_SOTIENTHOILAI ,
		p_max_stt_tuongung_idtiepnhan + 1 ,
		1 ,
		p_THANHTOANDAODONG ,
		p_SO_BIEN_LAI ,
		p_ghichu , 0, p_SOTIENPHAITHANHTOAN , v_ma_benh_nhan,v_sovaovien -- INSERT VÀO KHÔNG CÓ B?O HI?M
		);
   
		update kb_phieuthanhtoan
		set KETOANXACNHAN_CLS = 1,
		KETOANXACNHAN = 1
		where DVTT = p_dvtt
		AND MA_KHAM_BENH = p_makhambenh
		and SOVAOVIEN = v_sovaovien;
		--and NGAY_QUYET_TOAN_BHYT = p_ngay;
		-- t?o b?ng in l?n thanh toán và dùng con tr? quét quan b?ng in
			-- r?i th?c thi l?n thanh toán.
				-- thu ti?n vi?n phí ngo?i trú không b?o hi?m y t?:
		
	-- xem xét ph?n ti?p nh?n các b?nh nhân mà t? l? mi?n gi?m = 0 trong d?ch v? khám.
		delete from ds_benhnhan_thanhtoanct_kobh
		where DVTT = p_dvtt
		AND ID_TIEPNHAN = p_id_tiepnhan;
    
	-- xem xét ph?n ti?p nh?n các b?nh nhân mà t? l? mi?n gi?m = 0 trong d?ch v? khám.
	-- => d? thu ti?n d?ch v? khám
	if p_thamso_208='1' then
  	insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.gia_thang7_kobaohiem,dv.gia_thang7_kobaohiem,'CONGKHAM',tn.ID_TIEPNHAN,v_sovaovien
		from kb_tiep_nhan tn, dm_dich_vu_kham dv
		where 
    --tn.NGAY_TIEP_NHAN = p_ngay
		--and
     nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
		and tn.THANH_TOAN = 0
		and tn.DVTT = p_dvtt
		and dv.DVTT = p_dvtt
		and tn.MA_DV = dv.MA_DV
		and dv.TRANGTHAI = 1
		and tn.ID_TIEPNHAN = p_id_tiepnhan
		and TN.SOVAOVIEN = v_sovaovien;
    else
      	insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.GIA_DV,dv.GIA_DV,'CONGKHAM',tn.ID_TIEPNHAN,v_sovaovien
		from kb_tiep_nhan tn, dm_dich_vu_kham dv
		where 
    --tn.NGAY_TIEP_NHAN = p_ngay
		--and
     nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
		and tn.THANH_TOAN = 0
		and tn.DVTT = p_dvtt
		and dv.DVTT = p_dvtt
		and tn.MA_DV = dv.MA_DV
		and dv.TRANGTHAI = 1
		and tn.ID_TIEPNHAN = p_id_tiepnhan
		and TN.SOVAOVIEN = v_sovaovien;
      end if;

		insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.GIA_CHENHLECH_BHYT,dv.GIA_CHENHLECH_BHYT,'CONGKHAM',tn.ID_TIEPNHAN,
		v_sovaovien
		from kb_tiep_nhan tn, dm_dich_vu_kham dv
		where  tn.TI_LE_MIEN_GIAM  > 0 
		and tn.THANH_TOAN_YC = 0
		and tn.DVTT = p_dvtt
		and dv.DVTT = p_dvtt
		and tn.sovaovien=v_sovaovien
		and tn.MA_DV = dv.MA_DV
		and tn.ID_TIEPNHAN = p_id_tiepnhan	
		and dv.TRANGTHAI = 1
		and dv.KHAM_DV = 1;	

    insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,tt37.gia_dv,tt37.gia_dv,'CONGKHAMCHUYENPHONG',tt37.lanchuyen,v_sovaovien
		from kb_tiep_nhan tn, dm_dich_vu_kham dv,KB_CHUYENPK_THUTIEN_TT37 tt37
		where 
    --tn.NGAY_TIEP_NHAN = p_ngay
		--and
     nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
		and tn.DVTT = p_dvtt
    and nvl(tt37.tt_thutienvienphi,0)=0
		and dv.DVTT = p_dvtt
    and tt37.sovaovien =v_sovaovien
    and tt37.sovaovien=tn.sovaovien
    and tt37.dvtt=tn.dvtt
		and tn.MA_DV = dv.MA_DV
		and dv.TRANGTHAI = 1
		and tn.ID_TIEPNHAN = p_id_tiepnhan
		and TN.SOVAOVIEN = v_sovaovien;
    
		
	-- xem xét ph?n ch? d?nh xét nghi?m mà b?nh nhân yêu c?u.
		insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,kb.MABENHNHAN,ct.MA_XET_NGHIEM,p_id_tiepnhan ,xn.ten_xetnghiem 
		,ct.SO_LUONG,ct.DON_GIA+nvl(xn.GIA_CHENHLECH_BHYT, 0),ct.SO_LUONG*(ct.DON_GIA+nvl(xn.GIA_CHENHLECH_BHYT, 0)), 'XETNGHIEM',ct.SO_PHIEU_XN ||'--' ||ct.MA_XET_NGHIEM,v_sovaovien
		from KB_CD_XET_NGHIEM cd, KB_CD_XET_NGHIEM_CHI_TIET ct , cls_xetnghiem xn, kb_kham_benh kb
		where cd.DVTT = p_dvtt
		and ct.DVTT = p_dvtt
		--and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
		and ct.BHYTKCHI = 1
		and xn.dvtt = p_dvtt
		and ct.DA_THANH_TOAN = 0
		and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
		and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
		and cd.MA_KHAM_BENH = p_makhambenh
		and kb.MA_KHAM_BENH = p_makhambenh
		and kb.DVTT = p_dvtt
		--and kb.NGAY_KB = p_ngay
		and cd.MA_KHAM_BENH = p_makhambenh
		AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH
		and KB.SOVAOVIEN = v_sovaovien
		and cd.SOVAOVIEN = v_sovaovien;


	-- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
		insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,kb.MABENHNHAN,ct.MA_CDHA,p_id_tiepnhan,cdha.ten_cdha  
		,ct.SO_LUONG,ct.DON_GIA+nvl(cdha.GIA_CHENHLECH_BHYT, 0),ct.SO_LUONG*(ct.DON_GIA+nvl(cdha.GIA_CHENHLECH_BHYT, 0)),'CHANDOANHINHANH',ct.SO_PHIEU_CDHA ||'--' ||ct.MA_CDHA,v_sovaovien
		from KB_CD_CDHA cd, KB_CD_CDHA_CT ct ,cls_cdha  cdha, kb_kham_benh kb
		where cd.DVTT = p_dvtt
		and ct.DVTT = p_dvtt
		--and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
		and ct.BHYTKCHI = 1
		and cdha.dvtt = p_dvtt
		and ct.DA_THANH_TOAN = 0
		and ct.MA_CDHA = cdha.ma_CDHA
		and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
		and cd.MA_KHAM_BENH = p_makhambenh
		and kb.MA_KHAM_BENH = p_makhambenh
		and kb.DVTT = p_dvtt
		--and kb.NGAY_KB = p_ngay
		and cd.MA_KHAM_BENH = p_makhambenh
		AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH
		and KB.SOVAOVIEN = v_sovaovien
		and cd.SOVAOVIEN = v_sovaovien;


    
	-- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
		insert into ds_benhnhan_thanhtoanct_koBH
		select p_dvtt,kb.MABENHNHAN,ct.MA_DV,p_id_tiepnhan,dv.TEN_DV -- GIA_CHENHLECH_BHYT
		,ct.SO_LUONG,ct.DON_GIA+nvl(dv.GIA_CHENHLECH_BHYT, 0),ct.SO_LUONG*(ct.DON_GIA+nvl(dv.GIA_CHENHLECH_BHYT, 0)),'THUTHUATPHAUTHUAT', ct.SO_PHIEU_DICHVU ||'--' ||ct.MA_DV,v_sovaovien
		from KB_CD_DICHVU cd, KB_CD_DICHVU_CT ct ,dm_dich_vu_kham  dv, kb_kham_benh kb
		where cd.DVTT = p_dvtt
		and ct.DVTT = p_dvtt
		--and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
		and ct.BHYTKCHI = 1
		and dv.DVTT = p_dvtt
		and ct.DA_THANH_TOAN = 0
		and ct.MA_DV = dv.MA_DV
		and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
		and cd.MA_KHAM_BENH = p_makhambenh
		and kb.MA_KHAM_BENH = p_makhambenh
		and kb.DVTT = p_dvtt
		--and kb.NGAY_KB = p_ngay
		and cd.MA_KHAM_BENH = p_makhambenh
		AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH
and KB.SOVAOVIEN = v_sovaovien
		and cd.SOVAOVIEN = v_sovaovien;
     
    
	-- xem xét ph?n toa thu?c mua t?i qu?y thu?c c?a b?nh vi?n mà b?nh nhân yc
		insert into ds_benhnhan_thanhtoanct_koBH	
		select p_dvtt,kb.MABENHNHAN,ct.MAVATTU,p_id_tiepnhan,vt.TenVatTu 
		,ct.SO_LUONG,ct.DONGIA_BAN_BV,ct.SO_LUONG*ct.DONGIA_BAN_BV,'TOATHUOCBANTAIQUAYTHUOCBV',ct.STT_TOATHUOC ||'--' ||ct.MA_TOA_THUOC,v_sovaovien
		from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , dc_tb_vattu vt, kb_kham_benh kb
		where cd.DVTT = p_dvtt
		and ct.DVTT = p_dvtt
		--and cd.NGAY_RA_TOA = p_ngay
		and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
		and vt.DVTT = p_dvtt
		and ct.DATHANHTOAN = 0
		and ct.MAVATTU = vt.MaVatTu
		and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
		and cd.MA_KHAM_BENH = p_makhambenh
		and kb.MA_KHAM_BENH = p_makhambenh
		and kb.DVTT = p_dvtt
		--and kb.NGAY_KB = p_ngay
		and cd.MA_KHAM_BENH = p_makhambenh
		AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH
and KB.SOVAOVIEN = v_sovaovien
		and cd.SOVAOVIEN = v_sovaovien;


		insert into ds_benhnhan_thanhtoanct_koBH  
   select p_dvtt,ct.MABENHNHAN,ct.MAVATTU,p_id_tiepnhan,vt.TenVatTu 
   ,ct.SO_LUONG,ct.DONGIA_BAN_BV,ct.SO_LUONG*ct.DONGIA_BAN_BV,'TOATHUOCBANLE',ct.STT_TOATHUOC ||'--' ||ct.STT_TOABANLE,v_sovaovien
   from KB_TOATHUOC_BANLE cd, KB_CHI_TIET_TOA_THUOC_BANLE ct , dc_tb_vattu vt
   where cd.DVTT = p_dvtt
   and ct.DVTT = p_dvtt
   and cd.NGAY_BAN = p_ngay
   and ct.NGHIEP_VU = 'ngoaitru_toabanle'
   and vt.DVTT = p_dvtt
   and ct.DATHANHTOAN = 0
   and ct.MAVATTU = vt.MaVatTu
   and cd.STT_TOABANLE = ct.STT_TOABANLE
   and cast(cd.STT_TOABANLE as varchar2(50)) = p_id_tiepnhan;
		
    
    
		insert into ds_benhnhan_thanhtoanct_koBH	
		select p_dvtt,ct.MABENHNHAN,1,p_id_tiepnhan,'Tiền vận chuyển' 
		,1,ct.phi_chuyenvien,ct.phi_chuyenvien,'VANCHUYEN', p_id_tiepnhan,v_sovaovien
		from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn
		where ct.dvtt=p_dvtt
		and tn.dvtt=p_dvtt
		and tn.ID_TIEPNHAN=CT.ID_TIEPNHAN
		AND TN.ID_TIEPNHAN=p_id_tiepnhan
		and tn.co_bao_hiem=0
		and ct.phi_chuyenvien>0
		and ct.tt_phichuyenvien=0
		and TN.SOVAOVIEN =v_sovaovien;
		
    insert into ds_benhnhan_thanhtoanct_koBH	
		select p_dvtt,ct.MABENHNHAN,1,p_id_tiepnhan,'Tiền vận chuyển' 
		,1,ct.phi_chuyenvien,ct.phi_chuyenvien,'VANCHUYEN', p_id_tiepnhan,v_sovaovien
		from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn
		where ct.dvtt=p_dvtt
		and tn.dvtt=p_dvtt
		and tn.ID_TIEPNHAN=CT.ID_TIEPNHAN
		AND TN.ID_TIEPNHAN=p_id_tiepnhan
		and tn.co_bao_hiem=1
		and ct.phi_chuyenvien>0
		and ct.tt_phichuyenvien=0
    and ct.benhnhanduoc_vc=0
		and TN.SOVAOVIEN =v_sovaovien;
    
	-- -----------------------------------------------------------------------
	-- -----------------------------------------------------------------------

		 OPEN ID_CHITIETLANTT_cursor;
    
		 <<get_ID_CHITIETLANTT>> LOOP	 
      
		 FETCH ID_CHITIETLANTT_cursor INTO v_ID_CHITIETLANTT,v_SOTIEN_CHITIETLANTT,v_NHOM_LANTT,v_MA_DV,v_NOIDUNG,v_SOLUONG,v_DONGIA;     
   
    IF ID_CHITIETLANTT_cursor%NOTFOUND THEN 
			 v_finished := 1;
 		END IF;
		 IF v_finished = 1 THEN 
		 EXIT get_ID_CHITIETLANTT;
		 END IF;
		 v_function:=VP_NT_CTLTT_INSERT_MOI(
													p_dvtt , 
													p_STT_LANTT,
													p_id_tiepnhan  , 
													v_ID_CHITIETLANTT,
													'', -- ghi chú chi ti?t
													v_SOTIEN_CHITIETLANTT,
													p_NHAN_VIEN_TAO ,
													v_NHOM_LANTT,
													v_MA_DV,
													v_NOIDUNG,v_SOLUONG,v_DONGIA, v_ma_benh_nhan, v_sovaovien,p_thamso_208
													);
		 END LOOP get_ID_CHITIETLANTT;
		 CLOSE ID_CHITIETLANTT_cursor;
		-- sau khi quét xong th?c thi và 
		-- commit ;
		
   
  SELECT nvl(SUM(CT.BENHNHAN_PHAITRA),0) INTO V_TONGTIENPHAITRA FROM HIS_MANAGER.VIENPHINGOAITRU_CHITIETLTT CT
  WHERE  CT.SOVAOVIEN=v_sovaovien and ct.dvtt=p_dvtt and ct.stt_lantt=p_STT_LANTT and ct.id_tiepnhan=p_id_tiepnhan;
  
  update vienphingoaitru_lantt set 
  SOTIENPHAITHANHTOAN=V_TONGTIENPHAITRA,
  SOTIENBNTRA=V_TONGTIENPHAITRA,
  SOTIENTHOILAI=0,
  TONGTIENBNTHANHTOAN=V_TONGTIENPHAITRA
  where 
   sOVAOVIEN=v_sovaovien 
   and dvtt=p_dvtt 
   and stt_lantt=p_STT_LANTT 
   and id_tiepnhan=p_id_tiepnhan;
   
	RETURN p_STT_LANTT;
END;

 