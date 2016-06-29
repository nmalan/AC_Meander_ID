close all;clear all;clc

load ind_pulse020.mat

%nc=netcdf('AGUDAILY_nemoz_shelfbox_97_07_STUV_depth_average_pulse_days.rsc.nc')
nc=netcdf('AGUDAILY_nemoz_shelfbox_97_07_STUV_depth_average.rsc.nc')

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
	depth_fill=nc{'model_depth'}.FillValue_(:);

	% get offsets for variables
	temp_offset=nc{'temperature'}.add_offset(:);
	salt_offset=nc{'salinity'}.add_offset(:);

	%define variables
	lat=nc{'latitude'}(:);
	lon=nc{'longitude'}(:);
	time=nc{'time'}(:);
	depth=nc{'model_depth'}(:);
	temp=nc{'temperature'}(:);
	u=nc{'u'}(:);
	v=nc{'v'}(:);
	salt=nc{'salinity'}(:);
	ssh=nc{'ssh'}(:);

	disp(['replacing fill values with NaNs'])
	u(find(u==u_fill))=NaN;
	v(find(v==v_fill))=NaN;
	temp(find(temp==temp_fill))=NaN;
	depth(find(depth==depth_fill))=NaN;
	%fix time vector
	time=datenum(1950,1,1)+time/24;

	%add scale factors and offsets
	%ind=find(temp==temp_fill);
	%temp(ind)=NaN;
	%temp=temp*temp_sf+temp_offset;


	day=1
	
	%Meshgrid lats and lons for m_quiver
	[lon1 lat1]=meshgrid(lon,lat);
	
figure(1)
m_proj('mercator','longitude',[20 28],'latitude', [-37 -33])
%[fat guy]=m_etopo2('contour',0:-200:-200);
[a]=m_pcolor(lon,lat,squeeze(temp(day,:,:)))
shading interp
colormap (bluewhitered(128))
colorbar('southoutside')
%caxis([-1.5 1.5])
m_grid('box','fancy')
m_gshhs_i('patch',[.7 .7 .7])
hold on
m_quiver(lon1,lat1,squeeze(u(day,:,:)),squeeze(v(day,:,:)),4,'k')
hold on 

title('HYCOM 4std pulse composite anomalies of depth-averaged temp and surface currents')


%create Shelf mask

mask_ind=find(depth>200);		
		
%absolute values
figure(2)
m_proj('mercator','longitude',[18 28],'latitude', [-37 -33])
data=(squeeze(temp(day,:,:)))
data=data.*mask;
m_pcolor(lon,lat,data)
colorbar 
shading interp
m_grid('box','fancy')
m_gshhs_i('patch',[.7 .7 .7])

%Now plot composite
pulse_i=cell2mat(ind_pulse020)

figure(3)
lag=-20
m_proj('mercator','longitude',[18 28],'latitude', [-37 -33])
data_m=squeeze(nanmean(temp));
data=(squeeze(nanmean(temp([pulse_i+lag],:,:))))-data_m;
data=data.*mask;
m_pcolor(lon,lat,data)
shading interp
colorbar 
caxis([-1.5 2])
colormap (bluered)
m_grid('box','fancy')
m_gshhs_i('patch',[.7 .7 .7])

%print -depsc posterINALT01_pulse_composite.eps

figure(4)
m_proj('mercator','longitude',[18 28],'latitude', [-37 -33])
data=(squeeze(nanmean(temp([pulse_i],:,:))));
data=data.*mask;
m_pcolor(lon,lat,data)
shading interp
colorbar 
m_grid('box','fancy')
m_gshhs_i('patch',[.7 .7 .7])

%Calculate timeseries for box 20-28E
roi=find(lon>22 & lon<28);
shelfT=squeeze(nanmean(nanmean(temp(:,:,roi),3),2));
figure(5)
plot(Time,shelfT)
datetick
title('Vertical mean of Shelf Temperature from INALT01')

figure(6)
plot(Time,shelfT-nanmean(shelfT))
datetick
title('Vertical mean Shelf Temperature Anomaly from INALT01')


%Make common time period
shelfT=shelfT(765:4380);
ac_anom020=ac_anom020(1:length(shelfT));

%Correlate
xcov(ac_anom020,shelfT,0,'coeff')

%calculate lags
[cor,lags]=xcov(ac_anom020,shelfT,'coeff');

%check lags
figure(7)
plot(lags,cor)

% calculate significant level using length of time series as number of degrees of freedom
% using JD_significant
[rsign, veclag]=JD_significant(length(ac_anom020));
rsign(find(isnan(rsign)))=0;

%find max corr
lagind=find(cor==(max(cor)))
disp('max corelation is at')
maxcor=lags(lagind)

lagind=find(cor==(max(cor)))
disp('max corelation is at (days)')
maxcor=lags(lagind)

%find min corr
lagind=find(cor==(min(cor)))
disp('min corelation is at')
mincor=lags(lagind);
lagind=find(cor==(min(cor)))
disp('min corelation is at (days)')
mincor=lags(lagind)

figure(8)
area(veclag,rsign,0,'facecolor',[.6 .6 .6],'linestyle','none')
hold on
area(veclag,-rsign,0,'facecolor',[.6 .6 .6],'linestyle','none')
hold on
plot(lags,cor)
title('lag correlation between AC position anomaly at 020 and shelfT(common_ind), 020 leads for negative lags(days)')
text(.8,.6,['max corelation is ',num2str(max(cor)),' at ', num2str(maxcor),'days lag'])
