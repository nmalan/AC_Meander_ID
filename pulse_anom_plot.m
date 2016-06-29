close all;clear all;clc

load ind_pulse020.mat

nc=netcdf('AGUDAILY_nemoz_shelfbox_97_07_STUV_depth_average_pulse_days.rsc.nc')

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



%Test plot
	m_T=squeeze(nanmean(temp));
	m_U=squeeze(nanmean(u));
	m_V=squeeze(nanmean(v));
	
	%Meshgrid lats and lons for m_quiver
	[lon1 lat1]=meshgrid(lon,lat);
	
figure(1)
m_proj('mercator','longitude',[20 28],'latitude', [-37 -33])
%[fat guy]=m_etopo2('contour',0:-200:-200);
[a]=m_pcolor(lon,lat,m_T)
shading interp
colormap (bluewhitered(128))
colorbar('southoutside')
%caxis([-1.5 1.5])
m_grid('box','fancy')
m_gshhs_i('patch',[.7 .7 .7])
hold on
m_quiver(lon1,lat1,m_U,m_V,4,'k')
hold on 

title('HYCOM 4std pulse composite anomalies of depth-averaged temp and surface currents')