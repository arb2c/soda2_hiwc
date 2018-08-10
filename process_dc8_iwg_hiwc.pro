PRO process_dc8_iwg_hiwc, op, nosave=nosave, data=data
   ;PRO to read in aimms Nav and Met data, and return it
   ;in a structure in IDL's native format.
   ;starttime and stoptime entered in sfm
   ;All units in m, s, mb, C
   ;Aaron Bansemer, 08-2018

   IF n_elements(nosave) eq 0 THEN nosave=0
   
   fn=op.fn & starttime=op.starttime & stoptime=op.stoptime & rate=op.rate; & date=op.date

   starttime=long(starttime) & stoptime=long(stoptime) & rate=long(rate)
   IF stoptime lt starttime THEN stoptime=stoptime+86400d
   num=(stoptime-starttime)/rate +1 ;number of records that will be saved

   ;Default column indexes for file variables 
   numcolumns=33
   ci={lat:2, lon:3, galt:4, ias:10, tas:9, temp:20, dew:21, pres:23,$
       wspd:26, wdir:27, wwind:28, palt:6, uwind:30, vwind:31, pitch:16, roll:17, ss:18, aa:19}
   ;Check for errors in the ci structure above, to avoid headaches later on
   icount=intarr(numcolumns)
   FOR i=0, n_elements(tag_names(ci))-1 DO icount[ci.(i)]=icount[ci.(i)]+1
   IF max(icount) gt 1 THEN stop,'Index is re-used. Stopping'
   
   xbad=''
   xbad2=''
   bad={lat:xbad, lon:xbad, galt:xbad, ias:xbad, tas:xbad ,temp:xbad,dew:xbad,dew2:xbad,rh:xbad , pres:xbad,$
        wspd:xbad, wdir:xbad, uwind:xbad, vwind:xbad, wwind:xbad, palt:xbad, pitch:xbad, roll:xbad, ss:xbad, aa:xbad}
   
   temp=fltarr(num)
   dew=fltarr(num)
   pres=fltarr(num)
   uwind=fltarr(num)
   vwind=fltarr(num)
   wwind=fltarr(num)
   palt=fltarr(num)
   galt=fltarr(num)
   lat=fltarr(num)
   lon=fltarr(num)
   ias=fltarr(num)
   tas=fltarr(num)
   pitch=fltarr(num)
   roll=fltarr(num)
   ss=fltarr(num)
   aa=fltarr(num)
   
   v=''
   ;s=fltarr(numcolumns) ; this is used to read in the data

   nb=lonarr(numcolumns,num)  ;nb=num buffers for each record
   time=starttime+rate*dindgen(num)  ; this is the start time for each record

   close,1   
   openr,1,fn[0]
     
   ;-------Find first line of interest------------
   REPEAT BEGIN
      readf,1,v
      s=str_sep(v,',')
      itime=sfm(strjoin(str_sep((str_sep(s[1],'T'))[1], ':')))
   ENDREP UNTIL round(itime) ge starttime
   firsttime=itime
   ymd=str_sep((str_sep(s[1],'T'))[0], '-')
   date=ymd[1]+ymd[2]+ymd[0]
   op=create_struct(op,'date',date)
   
   ;-------Read in subsequent data----------------
   WHILE round(itime) le stoptime DO BEGIN
      i=(round(itime)-starttime)/rate ;find index for each variable
         IF s[ci.lat] ne bad.lat THEN BEGIN & lat[i]=lat[i]+s[ci.lat] & nb[ci.lat,i]=nb[ci.lat,i]+1 & ENDIF
         IF s[ci.lon] ne bad.lon THEN BEGIN & lon[i]=lon[i]+s[ci.lon] & nb[ci.lon,i]=nb[ci.lon,i]+1 & ENDIF
         IF s[ci.galt] ne bad.galt THEN BEGIN & galt[i]=galt[i]+s[ci.galt] & nb[ci.galt,i]=nb[ci.galt,i]+1 & ENDIF
         IF s[ci.palt] ne bad.palt THEN BEGIN & palt[i]=palt[i]+s[ci.palt] & nb[ci.palt,i]=nb[ci.palt,i]+1 & ENDIF
         IF s[ci.wwind] ne bad.wwind THEN BEGIN & wwind[i]=wwind[i]+s[ci.wwind] & nb[ci.wwind,i]=nb[ci.wwind,i]+1 & ENDIF
         IF s[ci.ias] ne bad.ias THEN BEGIN & ias[i]=ias[i]+s[ci.ias] & nb[ci.ias,i]=nb[ci.ias,i]+1 & ENDIF
         IF s[ci.tas] ne bad.tas THEN BEGIN & tas[i]=tas[i]+s[ci.tas] & nb[ci.tas,i]=nb[ci.tas,i]+1 & ENDIF
         IF s[ci.temp] ne bad.temp THEN BEGIN & temp[i]=temp[i]+s[ci.temp] & nb[ci.temp,i]=nb[ci.temp,i]+1 & ENDIF
         IF s[ci.dew] ne bad.dew THEN BEGIN & dew[i]=dew[i]+s[ci.dew] & nb[ci.dew,i]=nb[ci.dew,i]+1 & ENDIF
         IF s[ci.pres] ne bad.pres THEN BEGIN & pres[i]=pres[i]+s[ci.pres] & nb[ci.pres,i]=nb[ci.pres,i]+1 & ENDIF
         IF s[ci.pitch] ne bad.pitch THEN BEGIN & pitch[i]=pitch[i]+s[ci.pitch] & nb[ci.pitch,i]=nb[ci.pitch,i]+1 & ENDIF
         IF s[ci.roll] ne bad.roll THEN BEGIN & roll[i]=roll[i]+s[ci.roll] & nb[ci.roll,i]=nb[ci.roll,i]+1 & ENDIF
         IF s[ci.ss] ne bad.ss THEN BEGIN & ss[i]=ss[i]+s[ci.ss] & nb[ci.ss,i]=nb[ci.ss,i]+1 & ENDIF
         IF s[ci.aa] ne bad.aa THEN BEGIN & aa[i]=aa[i]+s[ci.aa] & nb[ci.aa,i]=nb[ci.aa,i]+1 & ENDIF
         wspd=s[ci.wspd]
         wdir=s[ci.wdir]
         u1=-wspd*sin(wdir*!pi/180)
         v1=wspd*cos(wdir*!pi/180)
         IF wspd ne bad.wspd THEN BEGIN & uwind[i]=uwind[i]+u1 & nb[ci.uwind,i]=nb[ci.uwind,i]+1 & ENDIF
         IF wspd ne bad.wspd THEN BEGIN & vwind[i]=vwind[i]+v1 & nb[ci.vwind,i]=nb[ci.vwind,i]+1 & ENDIF
      readf,1,v
      s=str_sep(v,',')
      itime=sfm(strjoin(str_sep((str_sep(s[1],'T'))[1], ':')))
      IF itime lt firsttime THEN itime=itime+86400 ;Midnight
      IF eof(1) THEN itime=9999999
      ENDWHILE
   close,1
   ;nb=nb>1
  
   dew=dew/nb[ci.dew,*]
   temp=temp/nb[ci.temp,*]
   rh=few_wexhy(dew+273.15)/few_wexhy(temp+273.15)*100
   rhi=fei_wexhy(dew+273.15)/fei_wexhy(temp+273.15)*100
   
   ;Following commented out, since sometimes get >1Hz data on ER2
   ;IF max(nb) gt rate then stop,'nb is greater than rate, should not happen.  Check for re-used indexes.'
   ;divide by number of 'buffers' to get means and put in a structure
   ;also correct for the scaling factors in MMS data (0.1)
   data={time:time,t:temp,pres:pres/nb[ci.pres,*],u:uwind/nb[ci.uwind,*],v:vwind/nb[ci.vwind,*], w:wwind/nb[ci.wwind,*],$
         galt:galt/nb[ci.galt,*],palt:palt/nb[ci.palt,*], lat:lat/nb[ci.lat,*], lon:lon/nb[ci.lon,*], tas:tas/nb[ci.tas,*], ias:ias/nb[ci.ias,*], $
         dew:dew, rh:rh, rhi:rhi, pitch:pitch/nb[ci.pitch,*], roll:roll/nb[ci.roll,*], sideslip:ss/nb[ci.ss,*], attack:aa/nb[ci.aa,*], op:op}

   IF nosave eq 0 THEN BEGIN
      fn=op.outdir+strtrim(string(date),2)+'_'+strtrim(string(long(sfm2hms(starttime)),form='(i06)'),2)+'_PTH.dat'  
      save,file=fn, data
   ENDIF
END
