%%%%%%%%
% Routine to produce calibration relations for each channel on each PMT
% Uses data collected for each setting of the calibration source using
% wheels B and C. Suggest using wheel B
%%%%%%%%%

%% Select PMT 
ipmt = 2;

%% Load calibration source information
m = readmatrix('/media/lita3520/IMPACTablation/analysis_code/cal_source.txt'); % wavelengths & spectral radiances (W/sr/m^2/nm)
r = readmatrix('/media/lita3520/IMPACTablation/analysis_code/calibration_ratios.txt'); % brightness ratios: wheels C,B,A, settings 12:1

%% Load test data
barr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
daq_chans = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
pmt_chan = ([6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13,]);

base_path = '/media/lita3520/IMPACTablation/PMT_calibration/brightness_calibration/new_gain/full_FOV/';
dmatA = nan(16*12,2048);
dmatB = dmatA;
wheel='b';
if wheel == 'b'
    nwheel = 2;
    runname = strcat('pmt',string(ipmt),'_wheelb');
end
if wheel == 'c'
    nwheel = 1;
    runname = strcat('pmt',string(ipmt),'wheelC');
end
nsettings = 4;
for iset = 1:nsettings
    for ichan = 1:16
        str = strcat(runname,'_',string(iset));
        obj = matfile(strcat(base_path,str,'_',string(ipmt),'.',barr((ichan)),'.mat'));
        eval(strcat(wheel,string(iset),'(ichan,:)=obj.Y1;'));
    end
end
npts = 2046; % ignore footer

%% Calculate photon fluxes
wl = m(:,1); %nm

%%%%% this is an approximation of the AOmega of the system
solid_ang = 0.00637; %calculated from the integral form
area = 0.005027; %m^2, area of the source

% spectral radiance * pixel surface area * source solid angle
spec_rad = m(:,2).*area*solid_ang; %W/nm = J/s/nm

planck_c = 6.626e-34; %Js
ls = 3e8; %m/s
phot_energy = planck_c*ls./(wl.*1e-9);
phot_flux_spec = spec_rad./phot_energy; % phot/s/nm
phot_flux_ref = trapz(wl,phot_flux_spec); % phot/s; reference photon flux for wheel C/12

% calculate photon fluxes for each setting of each wheel
photon_flux = nan(12,3);
for i = 1:3
    for j = 1:12
        photon_flux(j,i) = phot_flux_ref.*r(j,i); %columns c,b,a; rows 12-1
    end
end
photon_flux = flipud(photon_flux); %flip so that the array increases from dimmest to brightest

%% Calculate calibration relationship
% take the median voltage value as the channel response
channel_response = nan(3,nsettings,16);
for i = 1:nsettings
    channel_response(ipmt,i,:) = nanmedian(eval(strcat(wheel,string(i),'(:,1:npts)')),2);
end

%% Plot
channel_fits = nan(16,2);
channel_sig = nan(16,1);
t = tiledlayout(4,4);
for i = 1:16
   nexttile
   plot(photon_flux(1:nsettings,nwheel),channel_response(ipmt,:,i).*1e3,'b.','MarkerSize',10)
   ft = fit(photon_flux(1:nsettings,nwheel),channel_response(ipmt,:,i)','poly1');
   channel_fits(i,:) = coeffvalues(ft);
   confints = confint(ft);
   channel_sig(i) = (confints(2,1)-confints(1,1))/2;
   disp(strcat('y = ',string(channel_fits(i,1)),'x + ',string(channel_fits(i,2))))
   hold on
   plot(photon_flux(1:nsettings,nwheel),ft(photon_flux(1:nsettings,nwheel)).*1e3,'k--')
end
hold off

t.Padding='none';
t.TileSpacing='none';

%% Save calibration fits
fname = strcat('pmt',string(ipmt),'channel_fits_int.mat');
%save(fname,'channel_fits')
fname = strcat('pmt',string(ipmt),'channel_fits_sig.mat');
%save(fname,'channel_sig')
