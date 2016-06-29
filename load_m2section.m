function [time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname)
% function [time,dist,lon,lat,depth,lwr_intf,saln,temp,utot,vtot,kinetic,diffs,pres,ssh]=load_m2section(fname)
%
% load hycom section data into matlab
%
% netcdf section data extracted on hexagon with /home/nersc/bjornb/hycom/MSCPROGS/src/Section/m2section
% 

nc=netcdf(fname);

% load variables
time=floor(datenum([floor(nc{'time'}(:))],1,1)+(nc{'time'}(:)-floor(nc{'time'}(:)))*365);
dist=nc{'distance'}(:);
lon=nc{'lon'}(:);
lat=nc{'lat'}(:);
depth=nc{'depth'}(:);
lwr_intf=nc{'intf_lower'}(:,:,:);
saln=nc{'saln'}(:,:,:);
saln(find(saln==nc{'saln'}.FillValue_(:)))=NaN;
temp=nc{'temp'}(:,:,:);
temp(find(temp==nc{'temp'}.FillValue_(:)))=NaN;
utot=nc{'utot'}(:,:,:);
utot(find(utot==nc{'utot'}.FillValue_(:)))=NaN;
vtot=nc{'vtot'}(:,:,:);
vtot(find(vtot==nc{'vtot'}.FillValue_(:)))=NaN;
kinetic=nc{'kinetic'}(:,:,:);
kinetic(find(kinetic==nc{'kinetic'}.FillValue_(:)))=NaN;
diffs=nc{'diffs'}(:,:,:);
diffs(find(diffs==nc{'diffs'}.FillValue_(:)))=NaN;
pres=nc{'pres'}(:,:,:);
pres(find(pres==nc{'pres'}.FillValue_(:)))=NaN;
ssh=nc{'ssh'}(:,:);
ssh(find(ssh==nc{'ssh'}.FillValue_(:)))=NaN;

% permute variables to "normal" dimensions
% lwr_intf=permute(lwr_intf,[3 2 1]);
% saln=permute(saln,[3 2 1]);
% temp=permute(temp,[3 2 1]);
% utot=permute(utot,[3 2 1]);
% vtot=permute(vtot,[3 2 1]);
% kinetic=permute(kinetic,[3 2 1]);
% diffs=permute(diffs,[3 2 1]);
% pres=permute(pres,[3 2 1]);
% ssh=permute(ssh,[2 1]);

% make lon / lat / dist variable for plotting
% kdm=30; % set number of layers
% dist=repmat(dist,1,kdm);
% lon=repmat(lon,1,kdm);
% lat=repmat(lat,1,kdm);
% depth=repmat(depth,1,kdm);

% Treat empty layer:
% N.B. for contourf plot of section!
%for k=2:kdm
%	for ii=1:length(time)
%		% for tem
%	   	I=find(tem(k,:,ii)<-20000.);
%   		tmpvar=tem(k,:,ii);
%   		tmpvar(I)=tem(k-1,I,ii);
%   		tem(k,:,ii)=tmpvar;
%		clear I tmpvar
%		% for sal
%   		I=find(sal(k,:,ii)<-20000.);
%   		tmpvar=sal(k,:,ii);
%   		tmpvar(I)=sal(k-1,I,ii);
%   		sal(k,:,ii)=tmpvar;
%		clear I tmpvar
%		% for vnormal
%   		I=find(vnormal(k,:,ii)<-20000.);
%   		tmpvar=vnormal(k,:,ii);
%   		tmpvar(I)=vnormal(k-1,I,ii);
%   		vnormal(k,:,ii)=tmpvar;
%		clear I tmpvar
%	end
%end
%clear k kdm



