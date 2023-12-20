function [lum_eff,lum_eff_sig,luminosity] = lum_eff_calc(dmat_loc,dvel,dmass,decel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to estimate the luminous efficiency of a dust particle using
% data from an IMPACT experiment.
% Inputs:
%           dmat_loc: array containing data from the PMTs, with the event isolated (V)
%                       also includes footer & timing info
%           dvel: velocity of the particle (km/s)
%           dmass: particle mass (kg)
%
% Ouput: 
%           lum_eff_avg: estimate of the luminous efficiency (0-1)
%
%   I = -τdE/dt = -τ(v^2/2*dm/dt + mv*dv/dt)
%
% Written 3 March 2021 - LKT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nchann = 48; % number of PMT channels

% neglect deceleration
if ~exist('decel','var')
    decel = 0;
end

%% extract PMT data, footer info, and time array - voltages
pmt_dat = dmat_loc(1:nchann,:); % measured voltages
tvec = dmat_loc(nchann+1,:)./1e8; % time series, in seconds
footer_info = dmat_loc(nchann+2:nchann+4,1:8); % footer infor

remove_noise = 1;

if(remove_noise)
for ichann = 1:nchann
    % remove noise offset by taking the average of the data and
    % subtracting it. signal peaks are narrow compared to the time
    % series, so this approximation works alright
    nnpts = 2000; %number of points from which to calculate the noise floor
    off1 = nanmean(pmt_dat(ichann,1:nnpts));
    off2 = nanmean(pmt_dat(ichann,end-nnpts:end));
    off = median([off1,off2]);
    pmt_dat(ichann,:) = pmt_dat(ichann,:) - off;
end
end
%% Convert voltages - photons/s
% Linear fit converting integrated voltage to number of photons, from
% calibration data

% arrays of fit parameters (slope ; intercept) for each channel for each pmt
pmt1_conv = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt1channel_fits_int.mat');
pmt1_sig  = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt1channel_fits_sig.mat');
pmt2_conv = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt2channel_fits_int.mat');
pmt2_sig = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt2channel_fits_sig.mat');
pmt3_conv = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt3channel_fits_int.mat');
pmt3_sig = load('/media/lita3520/IMPACTablation/PMT_calibration/pmt3channel_fits_sig.mat');
pmt4_conv = pmt1_conv;
pmt4_sig = pmt1_sig;
conv_arr = [pmt1_conv.channel_fits;pmt2_conv.channel_fits;pmt3_conv.channel_fits;pmt4_conv.channel_fits];
sig_arr = [pmt1_sig.channel_sig;pmt2_sig.channel_sig;pmt3_sig.channel_sig;pmt4_sig.channel_sig];

phot_det = nan(size(pmt_dat));
eprop = zeros(size(pmt_dat));
for ichann = 1:nchann
    if ichann == 12 || ichann == 16 || ichann > 48
        phot_det(ichann,:) = NaN;
    else
        phot_det(ichann,:) = (pmt_dat(ichann,:))./(conv_arr(ichann,1));
        eprop(ichann,:) = phot_det(ichann,:).*sig_arr(ichann)./conv_arr(ichann,1);
    end
end

phot_det_tot_chan = nan(nchann,1);
for ichann = 1:nchann
    phot_det_tot_chan(ichann) = trapz(tvec,phot_det(ichann,:));
end

phot_det_tot = nansum(phot_det_tot_chan);

%% Assume isotropic radiation & estimate total photon output - photons/s
lens_SA = 0.022; % solid angle of lens (sr)
con_fac = lens_SA/(4*pi); % fraction of total sphere covered by the lens
QE = 1;%0.07; % quantum efficiency of PMT - accounted for in calibration
lens_tr = 0.9; % assume 90% transmission at 374 nm
lens_frac = 0.74; % lens transmission window accounts for ~74% of iron line emissions
window_tr = 0.95; % window is quartz, > 90% transmission

phot_iso = phot_det./(con_fac*QE*lens_tr*lens_frac*window_tr); %this should be a time series array of isotropic output for each channel (# of photons emitted)
eprop2 = eprop./(con_fac*QE*lens_tr*lens_frac*window_tr); 
%% Integrate

phot_total = nan(nchann,1);
phot_total_e = phot_total;
for i = 1:nchann
    phot_total(i) = trapz(tvec,phot_iso(i,:)); %estimated total photon output for each channel segment
    phot_total_e(i) = trapz(tvec,phot_iso(i,:)+eprop2(i,:));
    %    eprop3 = sum(eprop2.^2);
end

phot_total_sum = nansum(phot_total); % TOTAL number of photons emitted by the particle
phot_total_e_sum = nansum(phot_total_e);
eprop4 = abs(phot_total_e_sum-phot_total_sum);

%% Calculate luminosity
wl = 374e-9; %Assume 373.7/374.5 nm iron emission
c = 3e8; %m/s
h_pl = 6.626e-34; %Planck constant, Js

Ephot = h_pl*c/wl; %J/photon

luminosity = phot_total_sum.*Ephot; %J/s
lum_err = eprop4.*Ephot;

%% Calculate luminous efficiency

% TEST PARAMETERS (6/15/21, event 16)
%dvel = 1.6040e4; %m/s
%dmass = 3.478e-18; %kg

Dmass = -dmass;
metadata_sig = 0.02; %2% uncertainty in mass/velocity measurement
msig = metadata_sig*dmass;
vsig = metadata_sig*dvel;

dE = dvel^2*Dmass;%+dmass*dvel*dvdt
dE_sig = dE*sqrt((2*vsig/dvel)^2+(1*msig/dmass)^2);
dE = dE/2;
dE_sig = dE_sig/2;
lum_eff = -luminosity./dE;
lum_eff_sig = lum_eff*sqrt((lum_err/luminosity)^2+(dE_sig/dE)^2);
lum_eff_pct = lum_eff.*100;

if(0)
    % print interesting quantities
    KE = 1/2*dmass*dvel^2
    tphot = phot_total_sum
    tphot_det = phot_det_tot
    OE = luminosity
end

end