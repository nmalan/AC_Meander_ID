%Identifies position of Agulhas Current core, using section extracted using m2section
%N. Malan, Jan 2016, UCT

% version 2, try using max velocities rather than acrosstrack 

close all;clear all;clc;

%Define time period
firstday=datenum('1-Jan-1997');
lastday=datenum('31-Dec-2007');

%load data
fname='section001.nc'
[time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname);

disp('sections loaded')

%load surface data
fname=('AGUDAILY_surf_1997_2008_SAzoom.nc')
[time_s,lon_s,lat_s,depth_s,lwr_intf_s,saln_s,temp_s,u_s,v_s,ssh_s]=load_hyc2proj(fname);

disp('3d data loaded')

intf_lower=squeeze(lwr_intf(1,:,:));
temptemp=squeeze(temp(1,:,:));

%decomposing U and V to get magnitude
vel_mag=sqrt(utot.^2+vtot.^2);
mean_vel_mag=squeeze(nanmean(vel_mag));
%
disp('now plotting test')
% % %plot 1st section to check
figure(1)
pcolor(dist,-intf_lower,mean_vel_mag)
% ylim([-1000 0])
%shading interp
colorbar

%set time period inds
firstday_i=nearestpoint(firstday,time)
lastday_i=nearestpoint(lastday,time)
time=time(1:lastday_i);


%% plot 1st rotated velocity section to check
% figure(1)
% pcolor(dist,-intf_lower,mean_vel_across)
% ylim([-1000 0])
% %shading interp
% colorbar

%take only surface acrosstrack velocities for meander ID and plot all profiles to check
surf_speed=squeeze(vel_mag(:,1,1:50));

close all
disp('looping to generate plots')

for i=508:length(time)
	figure(1)
	axes('position', [.75,.4,.2,.2])
	plot(dist(1:50)/1000,surf_speed(i,:),'k','linewidth',2)
	ylim([-1 2])
	xlim([0 500])
	xlabel('distance from coast [km]')
	ylabel('Acrosstrack surface velocity')
	hold on
	ac_edge_ind=find(surf_speed(i,:)==max(surf_speed(i,:)));
	plot(dist(ac_edge_ind)/1000,surf_speed(i,ac_edge_ind),'o','markersize',8,'markeredgecolor','k','markerfacecolor','g')
	%title(['HYCOM acrosstrack surface velocity at 020 on day',num2str(i)])
	hold off
	
	
	
	axes('position', [.1,.05,.55,.9])
	m_proj('mercator','longitude',[18 30],'latitude', [-38 -33])
	m_pcolor(lon_s,lat_s,squeeze(temp_s(i,:,:)))
	map=brewermap(24,'OrRd')
	colormap(map)
	shading interp
	colorbar('horiz','position',[.1,.2,.55,.01]);
	caxis([16 28])
	m_grid('box','on')
	m_gshhs_i('patch',[.7 .7 .7])
	title(['HYCOM surface temperature and acrosstrack surface velocity at 020 on day',num2str(i)])
	hold on
	
	%or absolute surf currents
	m_vec(2,lon,lat,squeeze(utot(i,1,:)),squeeze(vtot(i,1,:)))
	hold on 
	clevs=[0.1,0.2,0.3,0.4]
	 	[z,h]=m_contour(lon_s,lat_s,squeeze(ssh_s(i,:,:)),clevs)
		clabel(z,h,clevs)
		hold on
		m_plot(lon(ac_edge_ind),lat(ac_edge_ind),'o','markersize',8,'markeredgecolor','k','markerfacecolor','g')
	hold off
eval(['print -dpng Pulse_ID_movie_2/HYCOM_surf_across020_vel_2' num2str(i,'%04d') '.png'])
close all
end  

%set time period inds
firstday_i=nearestpoint(firstday,time)
lastday_i=nearestpoint(lastday,time)
time=time(1:lastday_i);

%%extract distance to velocity maximum for NP time series

%set pulse ID threshhold (# of std from mode)
n=4;

count=0

for i=1:lastday_i
	count=count+1
	ac_edge_ind=find(surf_speed(count,:)==max(surf_speed(count,:)));
	ac_pos020(count)=dist(ac_edge_ind);
end

figure(3)
plot(time,ac_pos020/1000,'k')
datetick
ylabel('distance from coast [km]')
title('AGUHYCOM Agulhas Current core position at 020')

%print -dpng HYCOM_ACpos_timeseries020.png

%Calculate Anomalies from the mode
mode_020=mode(ac_pos020)

ac_anom020=(ac_pos020-mode_020)/1000;

ac_std020=repmat(std(ac_anom020),size(ac_anom020));

figure(4)
r=plot(time,ac_anom020,'r')
datetick
ylabel('position anomaly [km]')
title('AGUHYCOM Agulhas Current core position anomaly at 020 (from abs. vel.)')
hold on
plot(time,ac_std020*n,'r--')
datetick
hold on
plot(time,ac_std020*-n,'r--')
datetick

print -dpng HYCvel2_core_pos_timeseries.png