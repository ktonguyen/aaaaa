CREATE OR REPLACE FUNCTION "VP_KBH_SLDS_TN_SVV" (
  p_dvtt in varchar2,
 p_ngay in date,
 p_tt in number
)RETURN SYS_REFCURSOR
IS
cur  SYS_REFCURSOR;aaaaa
BEGIN
 if substr(p_dvtt, 1,2) != '79' then
  if p_tt = 0 then

        -- thêm vào s? ti?n b?nh nhân thanh toán vi?n phí khi chuy?n phòng khám
        
        open cur for 
        select  TEN_PHONGBAN ,  MA_BENH_NHAN ,  ID_TIEPNHAN ,  TEN_BENH_NHAN ,  NAMSINH ,  SOVAOVIEN from(
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn,KB_CHUYENPK_THUTIEN_TT37 tt37
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tt37.sovaovien=tn.sovaovien
        and tn.MA_DV = dv.MA_DV
        and tn.tien_cong_kham>0
        and dv.TRANGTHAI = 1
        and nvl(tt37.tt_thutienvienphi,0)=p_tt
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN

        union all
        -- --------------------------------------------------------------------
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
         and tn.tien_cong_kham>0
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
      -- xem xét ph?n ti?p nh?n các b?nh nhân mà: v?a có b?o hi?m v?a khám d?ch v?
        -- => d? thu ti?n d?ch v? khám D?CH V?
        -- insert into ds_benhnhan
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and tn.TI_LE_MIEN_GIAM  > 0
        and tn.THANH_TOAN_YC = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 1
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh xét nghi?m mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_XET_NGHIEM cd, KB_CD_XET_NGHIEM_CHI_TIET ct , cls_xetnghiem xn , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
         and trunc(KB.NGAY_KB) = p_ngay
        -- and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
        -- and kb.NGAY_KB = p_ngay
        and ct.BHYTKCHI = 1
        and xn.dvtt = p_dvtt
        and ct.thanh_tien>0
        and ct.DA_THANH_TOAN = 0
        and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
        AND kb.sovaovien = cd.sovaovien
        and cd.sovaovien=ct.sovaovien
        and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_CDHA cd, KB_CD_CDHA_CT ct ,cls_cdha  cdha, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
        --and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and ct.thanh_tien>0
        and cdha.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_CDHA = cdha.ma_CDHA
        and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ra thu?c mua qu?y mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
        --and trunc(cd.NGAY_RA_TOA) = p_ngay
        and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
        and ct.DATHANHTOAN = p_tt
        and ct.THANHTIEN_THUOC>0
        AND kb.sovaovien = cd.sovaovien
        and kb.sovaovien=ct.sovaovien
        and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all
      -- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select '' as ten_phongban,kb.MABENHNHAN,replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_DICHVU cd, KB_CD_DICHVU_CT ct ,dm_dich_vu_kham  dv, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
        --and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and ct.thanh_tien>0
        and dv.DVTT = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        and ct.MA_DV = dv.MA_DV
        and cd.sovaovien=ct.sovaovien
        and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all

        select '' as ten_phongban,ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 0
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        union all

        select '' as ten_phongban,ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 1
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        and BENHNHANDUOC_VC=0
        UNION all

        select '' as ten_phongban, 0, cast(tt.STT_TOABANLE as varchar2(50)) , tt.TEN_KHACH_HANG, 0, 0
        from KB_TOATHUOC_BANLE tt, KB_CHI_TIET_TOA_THUOC_BANLE CT
        where 
        TT.dvtt =CT.DVTT and
        TT.dvtt = p_dvtt AND
        TT.STT_TOABANLE = CT.STT_TOABANLE and
        TT.NGAY_BAN = p_ngay and
        DATHANHTOAN = 0
        and ct.THANHTIEN_THUOC>0) a
        group by TEN_PHONGBAN ,  MA_BENH_NHAN ,  ID_TIEPNHAN ,  TEN_BENH_NHAN ,  NAMSINH ,  SOVAOVIEN;
    return cur;
  else
        open cur for select  TEN_PHONGBAN ,  MA_BENH_NHAN ,  ID_TIEPNHAN ,  TEN_BENH_NHAN ,  NAMSINH ,  SOVAOVIEN from (
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn,KB_CHUYENPK_THUTIEN_TT37 tt37
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tt37.sovaovien=tn.sovaovien
        and tn.MA_DV = dv.MA_DV
        and tn.tien_cong_kham>0
        and dv.TRANGTHAI = 1
        and nvl(tt37.tt_thutienvienphi,0)=p_tt
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 0
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
      -- xem xét ph?n ti?p nh?n các b?nh nhân mà: v?a có b?o hi?m v?a khám d?ch v?
        -- => d? thu ti?n d?ch v? khám D?CH V?
        -- insert into ds_benhnhan
        select '' as ten_phongban,tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and tn.TI_LE_MIEN_GIAM  > 0
        and tn.THANH_TOAN_YC = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 1
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
        select '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_XET_NGHIEM cd, KB_CD_XET_NGHIEM_CHI_TIET ct , cls_xetnghiem xn , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and trunc(KB.NGAY_KB) = p_ngay
        and ct.BHYTKCHI = 1
        and xn.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_CDHA cd, KB_CD_CDHA_CT ct ,cls_cdha  cdha, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
      --  and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and cdha.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_CDHA = cdha.ma_CDHA
        and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ra thu?c mua qu?y mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  '' as ten_phongban,kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
      --  and trunc(cd.NGAY_RA_TOA) = p_ngay
        and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
        and ct.DATHANHTOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all
      -- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  '' as ten_phongban,kb.MABENHNHAN,replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_DICHVU cd, KB_CD_DICHVU_CT ct ,dm_dich_vu_kham  dv, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
        --and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and dv.DVTT = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_DV = dv.MA_DV
        and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all

        select '' as ten_phongban,ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 0
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        union all

        select '' as ten_phongban,ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 1
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        and BENHNHANDUOC_VC=0
        union all

        select '' as ten_phongban, 0, cast(tt.STT_TOABANLE as varchar2(50)) , tt.TEN_KHACH_HANG, 0, 0 from KB_TOATHUOC_BANLE tt, KB_CHI_TIET_TOA_THUOC_BANLE CT
        where TT.dvtt =CT.DVTT and
        TT.dvtt = p_dvtt AND
        TT.STT_TOABANLE = CT.STT_TOABANLE and
        TT.NGAY_BAN = p_ngay and
        DATHANHTOAN = 1) a
        group by TEN_PHONGBAN ,  MA_BENH_NHAN ,  ID_TIEPNHAN ,  TEN_BENH_NHAN ,  NAMSINH ,  SOVAOVIEN;
    return cur;
  end if;

else

  if p_tt = 0 then

        -- thêm vào s? ti?n b?nh nhân thanh toán vi?n phí khi chuy?n phòng khám
        open cur for select a.*,pbn.ten_phongban  from (select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay -- '20160428'

        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = 2
        and tn.DVTT = p_dvtt -- 82011
        and dv.DVTT = p_dvtt -- 82011
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 0
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        and tn.MA_DV_THUTIEN is null
        union all
        -- thêm vào s? ti?n b?nh nhân thanh toán vi?n phí khi chuy?n phòng khám THEO TI?N T?NG PHÒNG KHÁM Ð?N
        select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = 2
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV_THUTIEN = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 0
        and tn.MA_DV_THUTIEN is not null
        and nvl(tn.khongtinhtien_dvchuyen,0)  = 0
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN

        union all
        -- --------------------------------------------------------------------
        select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 0
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
      -- xem xét ph?n ti?p nh?n các b?nh nhân mà: v?a có b?o hi?m v?a khám d?ch v?
        -- => d? thu ti?n d?ch v? khám D?CH V?
        -- insert into ds_benhnhan
        select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and tn.TI_LE_MIEN_GIAM  > 0
        and tn.THANH_TOAN_YC = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 1
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh xét nghi?m mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_XET_NGHIEM cd, KB_CD_XET_NGHIEM_CHI_TIET ct , cls_xetnghiem xn , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and trunc(KB.NGAY_KB) = p_ngay
       -- and trunc(cd.NGAY_CHI_DINH) = p_ngay
        -- and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
      --  and kb.NGAY_KB = p_ngay
        and ct.BHYTKCHI = 1
        and xn.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_CDHA cd, KB_CD_CDHA_CT ct ,cls_cdha  cdha, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
        --and trunc(cd.NGAY_CHI_DINH) = p_ngay
        --and Cast(cd.NGAY_CHI_DINH AS date) = p_ngay
        and ct.BHYTKCHI = 1
        and cdha.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_CDHA = cdha.ma_CDHA
        and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ra thu?c mua qu?y mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
       -- and trunc(cd.NGAY_RA_TOA) = p_ngay
        --and Cast(cd.NGAY_RA_TOA AS date) = p_ngay
        and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
        and ct.DATHANHTOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all
      -- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN,replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_DICHVU cd, KB_CD_DICHVU_CT ct ,dm_dich_vu_kham  dv, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        --and to_char(cd.NGAY_RA_TOA,'yyyy-mm-dd') = v_ngay
        and trunc(kb.NGAY_KB) = p_ngay
       -- and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and dv.DVTT = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_DV = dv.MA_DV
        and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all

        select ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and tn.sovaovien=CT.sovaovien
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 0
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
         union all

        select ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and tn.sovaovien=CT.sovaovien
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 1
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        and BENHNHANDUOC_VC=0
      union all
        select 0, cast(tt.STT_TOABANLE as varchar2(50)) , tt.TEN_KHACH_HANG, 0, 0
        from KB_TOATHUOC_BANLE tt, KB_CHI_TIET_TOA_THUOC_BANLE CT
        where TT.dvtt =CT.DVTT and
        TT.dvtt = p_dvtt AND
        TT.STT_TOABANLE = CT.STT_TOABANLE and
        TT.NGAY_BAN = p_ngay and
        DATHANHTOAN = 0) a,
        (select * from his_manager.tiep_nhan_phong_benh a where dvtt = p_dvtt -- 82011
        and THOI_GIAN_KHAM_BENH=(select max(THOI_GIAN_KHAM_BENH) from his_manager.tiep_nhan_phong_benh 
        where 
        id_tiepnhan = a.id_tiepnhan
        and sovaovien=a.sovaovien)) b,
        his_manager.dm_phong_benh pb, his_fw.dm_phongban pbn
        where
          a.sovaovien = b.sovaovien and b.ma_phong_benh = pb.ma_phong_benh
          and pb.ma_phong_ban = pbn.ma_phongban and pbn.ma_donvi = p_dvtt; -- 82011;

         return cur;
  else
        open cur for select a.*,pbn.ten_phongban from (select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAMSINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay -- '20160428'
        and nvl( tn.TI_LE_MIEN_GIAM,0)   = 0
        and tn.THANH_TOAN = p_tt
        and tn.DVTT = p_dvtt -- 82011
        and dv.DVTT = p_dvtt -- 82011
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 0
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all
      -- xem xét ph?n ti?p nh?n các b?nh nhân mà: v?a có b?o hi?m v?a khám d?ch v?
        -- => d? thu ti?n d?ch v? khám D?CH V?
        -- insert into ds_benhnhan
        select tn.MA_BENH_NHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_tiep_nhan tn, dm_dich_vu_kham dv, his_public_list.dm_benh_nhan bn
        where trunc(tn.NGAY_TIEP_NHAN) = p_ngay
        and tn.TI_LE_MIEN_GIAM  > 0
        and tn.THANH_TOAN_YC = p_tt
        and tn.DVTT = p_dvtt
        and dv.DVTT = p_dvtt
        and tn.MA_DV = dv.MA_DV
        and dv.TRANGTHAI = 1
        and dv.KHAM_DV = 1
        and tn.MA_BENH_NHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh xét nghi?m mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_XET_NGHIEM cd, KB_CD_XET_NGHIEM_CHI_TIET ct , cls_xetnghiem xn , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
      --  and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and trunc(kb.NGAY_KB) = p_ngay
        and ct.BHYTKCHI = 1
        and xn.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        and ct.MA_XET_NGHIEM = xn.ma_xetnghiem
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and cd.SO_PHIEU_XN = ct.SO_PHIEU_XN
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ch? d?nh ch?n doán hình ?nh mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_CDHA cd, KB_CD_CDHA_CT ct ,cls_cdha  cdha, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
       -- and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and cdha.dvtt = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        AND kb.sovaovien = ct.sovaovien
        and ct.MA_CDHA = cdha.ma_CDHA
        and cd.SO_PHIEU_CDHA = ct.SO_PHIEU_CDHA
        and kb.MABENHNHAN = bn.MA_BENH_NHAN
        union all

      -- xem xét ph?n ra thu?c mua qu?y mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN, replace(cd.MA_KHAM_BENH,'kb_','') ,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from kb_toa_thuoc cd, kb_chi_tiet_toa_thuoc ct , kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
       -- and trunc(cd.NGAY_RA_TOA) = p_ngay
        and ct.NGHIEP_VU = 'ngoaitru_toaquaybanthuocbv'
        and ct.DATHANHTOAN = p_tt
        and kb.sovaovien=ct.sovaovien
        and kb.sovaovien=cd.sovaovien
        and cd.MA_TOA_THUOC = ct.MA_TOA_THUOC
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all
      -- xem xét ph?n ch? d?nh th? thu?t ph?u thu?t mà b?nh nhân yêu c?u.
        -- insert into ds_benhnhan
        select  kb.MABENHNHAN,replace(cd.MA_KHAM_BENH,'kb_',''),bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, kb.sovaovien
        from KB_CD_DICHVU cd, KB_CD_DICHVU_CT ct ,dm_dich_vu_kham  dv, kb_kham_benh kb, his_public_list.dm_benh_nhan bn
        where cd.DVTT = p_dvtt
        and ct.DVTT = p_dvtt
        and kb.DVTT = p_dvtt
        and trunc(kb.NGAY_KB) = p_ngay
      --  and trunc(cd.NGAY_CHI_DINH) = p_ngay
        and ct.BHYTKCHI = 1
        and dv.DVTT = p_dvtt
        and ct.DA_THANH_TOAN = p_tt
        AND kb.sovaovien = cd.sovaovien
        and cd.sovaovien=ct.sovaovien
        and ct.MA_DV = dv.MA_DV
        and cd.SO_PHIEU_DICHVU = ct.SO_PHIEU_DICHVU
        and kb.MABENHNHAN = bn.MA_BENH_NHAN

        union all

        select ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 0
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        union all

        select ct.MABENHNHAN,tn.ID_TIEPNHAN,bn.TEN_BENH_NHAN , extract(year from bn.NGAY_SINH) as NAM_SINH, tn.sovaovien
        from kb_chuyentuyenbenhnhan ct, kb_tiep_nhan tn, his_public_list.dm_benh_nhan bn
        where ct.dvtt=p_dvtt
        and tn.dvtt=p_dvtt
        and tn.sovaovien=CT.sovaovien
        and trunc(TN.NGAY_TIEP_NHAN) = p_ngay
        and ct.MABENHNHAN = bn.MA_BENH_NHAN
        and tn.co_bao_hiem = 1
        and ct.phi_chuyenvien > 0
        and ct.tt_phichuyenvien = p_tt
        and BENHNHANDUOC_VC=0
        union all
        select 0, cast(tt.STT_TOABANLE as varchar2(50)) , tt.TEN_KHACH_HANG, 0, 0 from KB_TOATHUOC_BANLE tt, KB_CHI_TIET_TOA_THUOC_BANLE CT
        where TT.dvtt =CT.DVTT and
        TT.dvtt = p_dvtt AND
        TT.STT_TOABANLE = CT.STT_TOABANLE and
        TT.NGAY_BAN = p_ngay and
        DATHANHTOAN = 1) a,
        (select * from his_manager.tiep_nhan_phong_benh a where dvtt = p_dvtt -- 82011
        and THOI_GIAN_KHAM_BENH=(select max(THOI_GIAN_KHAM_BENH) from his_manager.tiep_nhan_phong_benh 
        where id_tiepnhan = a.id_tiepnhan
        and sovaovien=a.sovaovien)) b,
        his_manager.dm_phong_benh pb, his_fw.dm_phongban pbn
        where
          a.sovaovien = b.sovaovien and b.ma_phong_benh = pb.ma_phong_benh
          and pb.ma_phong_ban = pbn.ma_phongban and pbn.ma_donvi = p_dvtt; -- 82011;

   return cur;
  end if;

end if;
END;
