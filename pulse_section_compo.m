%Makes pretty plot of Hycom sections produced using 'm2section' routine, in a pulse composite approach
%N. Malan, Jan 2016, UCT

close all;clear all;clc;

%Define time period
firstday=datenum('1-Jan-1997');
lastday=datenum('31-Dec-2007');

%load data
load ind_pulse020.mat	
	
fname='section001.nc'
[time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname);

intf_lower=squeeze(lwr_intf(1,:,:));
temptemp=squeeze(temp(1,:,:));
meantemp=squeeze(nanmean(temp));

pulse_i=cell2mat(ind_pulse020)

lag=0

%plot 1st section to check
figure(1)
pcolor(dist,-intf_lower,meantemp)
ylim([-1000 0])
%shading interp
colorbar

%set time period inds
% firstday_i=nearestpoint(firstday,time)
% lastday_i=nearestpoint(lastday,time)
% time=time(1:lastday_i);

data=(squeeze(nanmean(temp([pulse_i+lag],:,:))))-meantemp;

figure(2)
pcolor(dist,-intf_lower,data)
ylim([-400 0])
xlim([0 200000])
colormap(bluewhitered)
% shading interp
colorbar

data=(squeeze(nanmean(temp([pulse_i+lag],:,:))));

figure(3)
pcolor(dist,-intf_lower,data)
ylim([-400 0])
xlim([0 200000])
colormap(jet)
% shading interp
colorbar

figure(4)
pcolor(dist,-intf_lower,meantemp)
ylim([-400 0])
xlim([0 200000])
colormap(jet)
% shading interp
colorbar
