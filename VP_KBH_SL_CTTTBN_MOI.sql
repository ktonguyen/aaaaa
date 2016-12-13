CREATE OR REPLACE FUNCTION "VP_KBH_SL_CTTTBN_MOI" (
 p_id_tiepnhan IN varchar2 ,
 p_dvtt IN varchar2 ,
 p_ngay IN date ,
 p_tt IN NUMBER ,
 p_makhambenh IN varchar2,
 p_sovaovien in number
)RETURN SYS_REFCURSOR
IS
cur SYS_REFCURSOR;
v_count number(10);
v_thamso_tienkham37 varchar2(5);
BEGIN
 begin
  select mota_thamso into v_thamso_tienkham37 from his_fw.dm_thamso_donvi where dvtt=p_dvtt and ma_thamso=208;
  exception when no_data_found then 
    v_thamso_tienkham37:=0;
    end;
delete from ds_benhnhan_thanhtoanct_kobh
 	where DVTT = p_dvtt
 	AND sovaovien = p_sovaovien;
 -- xem xét ph?n ti?p nh?n các b?nh nhân mà t? l? mi?n gi?m = 0 trong d?ch v? khám.
 -- => d? thu ti?n d?ch v? khám
 select count(1) into v_count 
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv
 	where  nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
 	and tn.THANH_TOAN = p_tt
 	and tn.DVTT = p_dvtt
 	and dv.DVTT = p_dvtt
 	and tn.MA_DV = dv.MA_DV
 	and dv.TRANGTHAI = 1
  and tn.sovaovien=p_sovaovien
 	and tn.ID_TIEPNHAN = p_id_tiepnhan;
  
  if v_thamso_tienkham37='1' then
 	insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.gia_thang7_kobaohiem,dv.gia_thang7_kobaohiem,'CONGKHAM',tn.ID_TIEPNHAN,
  p_sovaovien
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv
 	where  nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
 	and tn.THANH_TOAN = p_tt
 	and tn.DVTT = p_dvtt
 	and dv.DVTT = p_dvtt
 	and tn.MA_DV = dv.MA_DV
 	and dv.TRANGTHAI = 1
  and tn.sovaovien=p_sovaovien
 	and tn.ID_TIEPNHAN = p_id_tiepnhan;
 
  insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.gia_thang7_kobaohiem,dv.gia_thang7_kobaohiem,'CONGKHAMCHUYENPHONG',tt37.lanchuyen,
  p_sovaovien
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv,kb_chuyenPK_thutien_tt37 tt37
 	where  nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
  and nvl(tt37.Tt_Thutienvienphi,1)=p_tt
  and nvl(tn.co_bao_hiem,0)=0
 	and tn.DVTT = p_dvtt
  and tn.ma_dv=tt37.ma_dv
  and tn.dvtt=tt37.dvtt
  and tt37.ma_dv=dv.ma_dv
  and tt37.dvtt=dv.dvtt
  and tt37.sovaovien=tn.sovaovien
  and tt37.sovaovien=p_sovaovien
  and tt37.id_tiepnhan=tn.id_tiepnhan
 	and dv.DVTT = p_dvtt
  and tn.sovaovien=p_sovaovien
 	and tn.MA_DV = dv.MA_DV
 	and dv.TRANGTHAI = 1
 	and tn.ID_TIEPNHAN = p_id_tiepnhan;
  
  else
    insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.GIA_DV,dv.GIA_DV,'CONGKHAM',tn.ID_TIEPNHAN,
  p_sovaovien
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv
 	where  nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 
 	and tn.THANH_TOAN = p_tt
 	and tn.DVTT = p_dvtt
 	and dv.DVTT = p_dvtt
 	and tn.MA_DV = dv.MA_DV
 	and dv.TRANGTHAI = 1
  and tn.sovaovien=p_sovaovien
 	and tn.ID_TIEPNHAN = p_id_tiepnhan;
  
   insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.gia_dv,dv.gia_dv,'CONGKHAMCHUYENPHONG',tt37.lanchuyen,
  p_sovaovien
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv,kb_chuyenPK_thutien_tt37 tt37
 	where  nvl(tn.TI_LE_MIEN_GIAM,0)  = 0 	
  and nvl(tt37.Tt_Thutienvienphi,1)=p_tt
  and nvl(tn.co_bao_hiem,0)=0
 	and tn.DVTT = p_dvtt
  and tn.ma_dv=tt37.ma_dv
  and tn.dvtt=tt37.dvtt
  and tt37.ma_dv=dv.ma_dv
  and tt37.dvtt=dv.dvtt
  and tt37.sovaovien=tn.sovaovien
  and tt37.sovaovien=p_sovaovien
  and tt37.id_tiepnhan=tn.id_tiepnhan
 	and dv.DVTT = p_dvtt
  and tn.sovaovien=p_sovaovien
 	and tn.MA_DV = dv.MA_DV
 	and dv.TRANGTHAI = 1
 	and tn.ID_TIEPNHAN = p_id_tiepnhan;
  
 end if;
     
 	insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,tn.MA_BENH_NHAN,tn.MA_DV,tn.ID_TIEPNHAN,dv.TEN_DV,1,dv.GIA_CHENHLECH_BHYT,dv.GIA_CHENHLECH_BHYT,'CONGKHAM',tn.ID_TIEPNHAN,
  p_sovaovien
 	from kb_tiep_nhan tn, dm_dich_vu_kham dv
 	where  tn.TI_LE_MIEN_GIAM  > 0 
 	and tn.THANH_TOAN_YC = p_tt
 	and tn.DVTT = p_dvtt
 	and dv.DVTT = p_dvtt
  and tn.sovaovien=p_sovaovien
 	and tn.MA_DV = dv.MA_DV
 	and tn.ID_TIEPNHAN = p_id_tiepnhan	
 	and dv.TRANGTHAI = 1
 	and dv.KHAM_DV = 1;	
 -- => d? thu ti?n d?ch v? khám
 	
 
 
 -- xem xét ph?n ch? d?nh xét nghi?m mà b?nh nhân yêu c?u.
 	insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,kb.MABENHNHAN,ct.MA_XET_NGHIEM,p_id_tiepnhan ,xn.ten_xetnghiem 
 	,ct.SO_LUONG,ct.DON_GIA,ct.SO_LUONG*ct.DON_GIA, 'XETNGHIEM',ct.SO_PHIEU_XN ||'--' ||ct.MA_XET_NGHIEM,
  p_sovaovien
 	from kb_cd_xet_nghiem cd, kb_cd_xet_nghiem_chi_tiet ct , cls_xetnghiem xn, kb_kham_benh kb
 	where cd.DVTT = p_dvtt
 	and ct.DVTT = p_dvtt
 	and ct.BHYTKCHI = 1
 	and xn.dvtt = p_dvtt
  and cd.sovaovien=p_sovaovien
  and kb.sovaovien=p_sovaovien
  and ct.sovaovien=p_sovaovien
  and kb.sovaovien=cd.sovaovien
  and kb.sovaovien=ct.sovaovien
 	and ct.DA_THANH_TOAN = p_tt
     and ct.chisocon = 0
 	and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
 	and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
 	and cd.MA_KHAM_BENH = p_makhambenh
 	and kb.MA_KHAM_BENH = p_makhambenh
 	and kb.DVTT = p_dvtt
 	and kb.NGAY_KB = p_ngay
 	and cd.MA_KHAM_BENH = p_makhambenh
 	AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH;
 
 
 -- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
 	insert into ds_benhnhan_thanhtoanct_koBH
 	select p_dvtt,kb.MABENHNHAN,ct.MA_CDHA,p_id_tiepnhan,cdha.ten_cdha  
 	,ct.SO_LUONG,ct.DON_GIA,ct.SO_LUONG*ct.DON_GIA,'CHANDOANHINHANH',ct.SO_PHIEU_CDHA ||'--' ||ct.MA_CDHA,
   p_sovaovien
 	from kb_cd_cdha cd, kb_cd_cdha_CT ct ,cls_cdha  cdha, kb_kham_benh kb
 	where cd.DVTT = p_dvtt
 	and ct.DVTT = p_dvtt
 	and ct.BHYTKCHI = 1
 	and cdha.dvtt = p_dvtt
 	and ct.DA_THANH_TOAN = p_tt
 	and ct.MA_CDHA = cdha.ma_CDHA
  and cd.sovaovien=p_sovaovien
  and kb.sovaovien=p_sovaovien
  and ct.sovaovien=p_sovaovien
  and kb.sovaovien=cd.sovaovien
  and kb.sovaovien=ct.sovaovien
 	and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
 	and cd.MA_KHAM_BENH = p_makhambenh
 	and kb.MA_KHAM_BENH = p_makhambenh
 	and kb.DVTT = p_dvtt
 	and kb.NGAY_KB = p_ngay
 	and cd.MA_KHAM_BENH = p_makhambenh
 	AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH;
 
 
 -- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
   insert into ds_benhnhan_thanhtoanct_koBH
   select p_dvtt,kb.MABENHNHAN,ct.MA_DV,p_id_tiepnhan,dv.TEN_DV 
   ,ct.SO_LUONG,ct.DON_GIA,ct.SO_LUONG*ct.DON_GIA,'THUTHUATPHAUTHUAT', ct.SO_PHIEU_DICHVU ||'--' ||ct.MA_DV,
    p_sovaovien
   from kb_cd_dichvu cd, kb_cd_dichvu_ct ct ,dm_dich_vu_kham  dv, kb_kham_benh kb
   where cd.DVTT = p_dvtt
   and ct.DVTT = p_dvtt
   and ct.BHYTKCHI = 1
   and dv.DVTT = p_dvtt
   and ct.DA_THANH_TOAN = p_tt
   and ct.MA_DV = dv.MA_DV
   and cd.sovaovien=p_sovaovien
  and kb.sovaovien=p_sovaovien
  and ct.sovaovien=p_sovaovien
  and kb.sovaovien=cd.sovaovien
  and kb.sovaovien=ct.sovaovien
   and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
   and cd.MA_KHAM_BENH = p_makhambenh
   and kb.MA_KHAM_BENH = p_makhambenh
   and kb.DVTT = p_dvtt
   and kb.NGAY_KB = p_ngay
   and cd.MA_KHAM_BENH = p_makhambenh
   AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH;
 -- xem xét ph?n toa thu?c mua t?i qu?y thu?c c?a b?nh vi?n mà b?nh nhân yc
   insert into ds_benhnhan_thanhtoanct_koBH  
   select p_dvtt,kb.MABENHNHAN,ct.MAVATTU,p_id_tiepnhan,vt.TenVatTu 
   ,ct.SO_LUONG,ct.DONGIA_BAN_BV,ct.SO_LUONG*ct.DONGIA_BAN_BV,'TOATHUOCBANTAIQUAYTHUOCBV',ct.STT_TOATHUOC ||'--' ||ct.MA_TOA_THUOC,
   p_sovaovien
   from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , dc_tb_vattu vt, kb_kham_benh kb
   where cd.DVTT = p_dvtt
   and ct.DVTT = p_dvtt
   and cd.NGAY_RA_TOA = p_ngay
   and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
   and vt.DVTT = p_dvtt
   and ct.DATHANHTOAN = p_tt
   and ct.MAVATTU = vt.MaVatTu
   and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
   and cd.MA_KHAM_BENH = p_makhambenh
   and kb.MA_KHAM_BENH = p_makhambenh
   and cd.sovaovien=p_sovaovien
  and kb.sovaovien=p_sovaovien
  and ct.sovaovien=p_sovaovien
  and kb.sovaovien=cd.sovaovien
  and kb.sovaovien=ct.sovaovien
   and kb.DVTT = p_dvtt
   and kb.NGAY_KB = p_ngay
   and cd.MA_KHAM_BENH = p_makhambenh
   AND kb.MA_KHAM_BENH = cd.MA_KHAM_BENH;
 -- -----------------------------------------------------------------------
insert into ds_benhnhan_thanhtoanct_koBH  
   select p_dvtt,ct.MABENHNHAN,ct.MAVATTU,p_id_tiepnhan,vt.TenVatTu 
   ,ct.SO_LUONG,ct.DONGIA_BAN_BV,ct.SO_LUONG*ct.DONGIA_BAN_BV,'TOATHUOCBANTAIQUAYTHUOCBV',ct.STT_TOATHUOC ||'--' ||ct.STT_TOABANLE,
    p_sovaovien
   from KB_TOATHUOC_BANLE cd, KB_CHI_TIET_TOA_THUOC_BANLE ct , dc_tb_vattu vt
   where cd.DVTT = p_dvtt
   and ct.DVTT = p_dvtt
   and cd.NGAY_BAN = p_ngay
   and ct.NGHIEP_VU = 'ngoaitru_toabanle'
   and vt.DVTT = p_dvtt
   and ct.DATHANHTOAN = p_tt
   and ct.MAVATTU = vt.MaVatTu
   and cd.STT_TOABANLE = ct.STT_TOABANLE
   and cast(cd.STT_TOABANLE as varchar2(50)) = p_id_tiepnhan;
------------------------------------
 
   insert into ds_benhnhan_thanhtoanct_koBH  
     select p_dvtt,ct.MABENHNHAN,1,p_id_tiepnhan,'Tiền vận chuyển' 
   ,1,ct.phi_chuyenvien,ct.phi_chuyenvien,'VANCHUYEN', p_id_tiepnhan
   ,p_sovaovien
     from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn
   where ct.dvtt=p_dvtt
   and tn.dvtt=p_dvtt
   and tn.ID_TIEPNHAN=CT.ID_TIEPNHAN
   AND TN.ID_TIEPNHAN=p_id_tiepnhan
   and ct.sovaovien=p_sovaovien
  and tn.sovaovien=p_sovaovien
  and ct.sovaovien=tn.sovaovien
   and tn.co_bao_hiem=0
     and ct.phi_chuyenvien>0
     and ct.tt_phichuyenvien=p_tt;
     
      insert into ds_benhnhan_thanhtoanct_koBH  
     select p_dvtt,ct.MABENHNHAN,1,p_id_tiepnhan,'Tiền vận chuyển' 
   ,1,ct.phi_chuyenvien,ct.phi_chuyenvien,'VANCHUYEN', p_id_tiepnhan
   ,p_sovaovien
     from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn
   where ct.dvtt=p_dvtt
   and tn.dvtt=p_dvtt
   and tn.ID_TIEPNHAN=CT.ID_TIEPNHAN
   AND TN.ID_TIEPNHAN=p_id_tiepnhan
   and ct.sovaovien=p_sovaovien
  and tn.sovaovien=p_sovaovien
  and ct.sovaovien=tn.sovaovien
   and tn.co_bao_hiem=1
     and ct.phi_chuyenvien>0
     and ct.tt_phichuyenvien=p_tt;
   open cur for select DS.* --,bn.TEN_BENH_NHAN 
   from ds_benhnhan_thanhtoanct_koBH DS --, his_public_list.dm_benh_nhan bn
 	where 
 		DS.ID_TIEPNHAN = p_id_tiepnhan
 	and DS.DVTT = p_dvtt
  and ds.sovaovien=p_sovaovien;
  
 
 	-- and DS.MA_BENH_NHAN = bn.MA_BENH_NHAN;
  RETURN cur;
  
 
END;

 