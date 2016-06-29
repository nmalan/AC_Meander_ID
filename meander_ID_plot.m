%Loads and plots outputs of hycave
%N.Malan, Dece 2014

close all;clear all;
%read netcdfs
nc=netcdf('AGUDAILY_start20051226_dump20070307.nc')

ncdump(nc)

%get scale factors for variables
temp_sf=nc{'temperature'}.scale_factor(:);
u_sf=nc{'u'}.scale_factor(:);
v_sf=nc{'v'}.scale_factor(:);
salt_sf=nc{'salinity'}.scale_factor(:);
ssh_sf=nc{'ssh'}.scale_factor(:);

%get fill values for variables
temp_fill=nc{'temperature'}.FillValue_(:);
u_fill=nc{'u'}.FillValue_(:);
v_fill=nc{'v'}.FillValue_(:);
salt_fill=nc{'salinity'}.FillValue_(:);
ssh_fill=nc{'ssh'}.FillValue_(:);

% get offsets for variables
temp_offset=nc{'temperature'}.add_offset(:);
salt_offset=nc{'salinity'}.add_offset(:);

%define variables
lat=nc{'latitude'}(:);
lon=nc{'longitude'}(:);
time=nc{'time'}(:);
depth=nc{'depth'}(:);
temp=nc{'temperature'}(:);
u=nc{'u'}(:);
v=nc{'v'}(:);
salt=nc{'salinity'}(:);
ssh=nc{'ssh'}(:);

%fix time vector
time=datenum(1950,1,1)+time/24;

%add scale factors and offsets
ind=find(temp==temp_fill);
temp(ind)=NaN;
temp=temp*temp_sf+temp_offset;

%Create map 
lonmin=18
lonmax=30
latmin=-38
latmax=-30


m_proj('Mercator','longitude',[lonmin lonmax],'latitude', [latmin latmax])  
 m_pcolor(lon,lat,squeeze(temp))
 colorbar
 caxis([14 25])
 shading interp
 m_grid('box','fancy')
 m_gshhs_h('patch',[.7 .7 .7])
 m_gshhs_h('speckle','color','k');
 set(gcf,'color','white');
 title('Pulse ID method')
 
 hold on
 
 % plot Sat_tracks
 %track coordinates
 t020_LAT=[-34.08,-43.99];
 t020_LON=[25.07,32.02];

 t198_LAT=[-34.21,-43.97];
 t198_LON=[22.32,29.17];
 
 m_plot(t020_LON,t020_LAT,'k','linewidth',1.5)
 m_text(26.5,-35.8,'Track 020')
 m_plot(t198_LON,t198_LAT,'k','linewidth',1.5)
 m_text(24.1,-36.5,'Track 198')
 
 hold on
 
 %plot 150cm isotherm
 m_contour(lon,lat,ssh,0.15)
 
 %Define time period
 firstday=datenum('1-Jan-1997');
 lastday=datenum('31-Dec-2007');

 %load data
 fname='section001.nc'
 [timeS,distS,lonS,latS,depthS,lwr_intfS,salnS,tempS,utotS,vtotS,kineticS,diffsS,presS,sshS]=load_m2section(fname);

 %find index of day coresponding to map plot
 timeS_i=nearestpoint(datenum(2007,03,07),timeS);

 intf_lower=squeeze(lwr_intfS(1,:,:));
 temptempS=squeeze(tempS(1,:,:));
 meantempS=squeeze(nanmean(tempS));
 
 figure(2)
 plot(distS./1000,sshS(timeS_i,:))