%Makes pretty plot of Hycom sections produced using 'm2section' routine
%N. Malan, Jan 2016, UCT

close all;clear all;clc;

%Define time period
firstday=datenum('1-Jan-1997');
lastday=datenum('31-Dec-2007');

%load data
fname='section001.nc'
[time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname);

intf_lower=squeeze(lwr_intf(1,:,:));
temptemp=squeeze(temp(1,:,:));
meantemp=squeeze(nanmean(temp));

%plot 1st section to check
figure(1)
pcolor(dist,-intf_lower,meantemp)
ylim([-1000 0])
%shading interp
colorbar

%set time period inds
firstday_i=nearestpoint(firstday,time)
lastday_i=nearestpoint(lastday,time)
time=time(1:lastday_i);

%%extract distance to 150cm isoline for NP time series

%set pulse ID threshhold (# of std from mode)
n=4;

count=0

for i=1:lastday_i
	count=count+1
	ac_edge_ind=find(ssh(count,:)>=0.15,1);
	ac_pos020(count)=dist(ac_edge_ind);
end

figure(2)
plot(time,ac_pos020/1000,'k')
datetick
ylabel('distance from coast [km]')
title('AGUHYCOM Agulhas Current core position at 020')

%print -dpng HYCOM_ACpos_timeseries020.png

%Calculate Anomalies from the mode
mode_020=mode(ac_pos020)

ac_anom020=(ac_pos020-mode_020)/1000;

ac_std020=repmat(std(ac_anom020),size(ac_anom020));

%load data
fname='section002.nc'
[time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname);

intf_lower=squeeze(lwr_intf(1,:,:));
temptemp=squeeze(temp(1,:,:));
meantemp=squeeze(nanmean(temp));
time=time(1:lastday_i);

%plot 1st section to check
figure(3)
pcolor(dist,-intf_lower,meantemp)
ylim([-1000 0])
%shading interp
colorbar

%%extract distance to 150cm isoline for NP time series

count=0

for i=1:lastday_i
	count=count+1
	ac_edge_ind_198=find(ssh(count,:)>=0.15,1);
	ac_pos198(count)=dist(ac_edge_ind_198);
end

figure(3)
plot(time,ac_pos198/1000,'k')
datetick
ylabel('distance from coast [km]')
title('AGUHYCOM Agulhas Current position at 198')

%print -dpng HYCOM_ACpos_timeseries198.png

%Calculate Anomalies from the mode
mode_198=mode(ac_pos198)

ac_anom198=(ac_pos198-mode_198)/1000;

ac_std198=repmat(std(ac_anom198),size(ac_anom198));


figure(4)
r=plot(time,ac_anom020,'r')
datetick
ylabel('position anomaly [km]')
title('AGUHYCOM Agulhas Current position anomaly at 020')
hold on
plot(time,ac_std020*n,'r--')
datetick
hold on
plot(time,ac_std020*-n,'r--')
datetick

b=plot(time,ac_anom198)
datetick
ylabel('position anomaly [km]')
title('AGU-HYCOM Agulhas Current position anomaly at 020 and 198')
hold on
plot(time,ac_std198*n,'--')
datetick
hold on
plot(time,ac_std198*-n,'--')
datetick

l=legend([r,b],{'track 020','track 198'})
set(l, 'Box', 'off','location','southeast')
hold off

print -r300 -dpng AGUHYCOM_ACanom_timeseries.png

%%find time indices with which to make composites
%first approach - within n std of the mode
Pulse020_type1=find(ac_anom020>ac_std020(1)*n);

%use split vec to split indices into separate cells by consecutive numbers
ind_pulse020=SplitVec(Pulse020_type1,'consecutive')

%calculate correlation
xcov(ac_anom020,ac_anom198,0,'coeff')

%calculate lags
[cor,lags]=xcov(ac_anom020,ac_anom198,'coeff');

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

figure(8)
area(veclag,rsign,0,'facecolor',[.6 .6 .6],'linestyle','none')
hold on
area(veclag,-rsign,0,'facecolor',[.6 .6 .6],'linestyle','none')
hold on
plot(lags,cor)
title('lag correlation between AC position anomaly at 020 and 198, 020 leads for negative lags(days)')
text(.8,.6,['max corelation is ',num2str(max(cor)),' at ', num2str(maxcor),'days lag'])
%print -r300 -dpng pulse_020_198_lags.png

%export time series for climate explorer


%Make pretty anomaly plot of 020
figure(9)
plot(time,ac_anom020,'r')
datetick
ylabel('position anomaly [km]')
title('AGUHYCOM Agulhas Current position anomaly at 020')
hold on
plot(time,ac_std020*n,'r--')
datetick
hold on
plot(time,ac_std020*-n,'r--')
datetick
