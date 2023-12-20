base_path = '/media/lkt/IMPACTablation/dust_data/6_3_21/1/';
flst = ls(strcat(base_path,'*atb'));
tmp = strsplit(flst,'/');
fn = cell2mat(tmp(end));
runname = fn(1:19);
%runname = '2021.06.03_10.43.00';

barr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
daq_chans = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13,];
nchans = 16;
npmts = 3;

load('flag.mat')

npts = 100096;
dmat = nan(nchans,npts);

%%
istart = 85;
nrecs = istart;
ipmt = 3;

for irec = istart:nrecs

    %read in data 
    for ichann=1:nchans
        obj = matfile(strcat(base_path,runname,'_',string(ipmt),'.',barr(daq_chans(ichann)),'.mat'));
        dmat(ichann,:) = eval(strcat('obj.Y',string(irec)));

    end
    
end

%%
figure(1)
offset = 50;
end_cutoff = 3;
tvec = linspace(1,npts,npts);
plot(tvec(1:npts-end_cutoff),dmat(1,1:npts-end_cutoff).*1e3-offset*(pmt_chan(1)-1))
xlabel('Sample')
ylabel('Voltage (mV), 50 mV offset')
title(strcat('i=',string(irec)))
hold on
for ichan = 2:nchans
    plot(tvec(1:npts-end_cutoff),(dmat(ichan,1:npts-end_cutoff).*1e3)-offset.*(pmt_chan(ichan)-1)-800*(ipmt-1))
end

hold off

%%
nevents = 520;
m = readmatrix('flag.txt');
flag = zeros(nevents,1);
flag(m) = 1;
save('flag.mat','flag')

%% Ablation characteristic comparison plot
bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_15_21/';

figure(1)
nimm = 0;
nshort = 0;
ntot = 0;
for i = 1:7
   iset = string(i);
   cd(strcat(bpath,edate,iset))
   load('turn_on_flag.mat')
   tof = flag(:,1);
   lf = flag(:,2);
   nimm = nimm + sum(tof);
   nshort = nshort + sum(lf);
   ntot = ntot + size(tof,1);
   load('out.mat')
   vel = out(:,2).*1e-3;
   le = out(:,3);
   semilogy(vel(tof==1),(le(tof==1).*100),'b*')
   hold on
   semilogy(vel(tof==0),(le(tof==0).*100),'r*')
end
legend('Immediate Ablation','Delayed Ablation')
hold off
title(strcat('n = ',string(ntot)))
xlabel('Velocity (km/s)')
ylabel('log \tau (%)')

bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_15_21/';

figure(2)
nimm = 0;
nshort = 0;
ntot = 0;
for i = 1:7
   iset = string(i);

    cd(strcat(bpath,edate,'/',string(iset)))
    load('out.mat')
    load('turn_on_flag.mat')
    tof = flag(:,1);
    lf = flag(:,2);
    tot_flag = tof + lf;

    ggidx = find(tot_flag == 0);
    bbidx = find(tot_flag == 2);
    badsnr_idx = find(tof == 1);
    badabl_idx = find(lf == 1);
    goodsnr_idx = find(tof == 0);
    goodabl_idx = find(lf == 0);
    tmp = ismember(badsnr_idx,goodabl_idx);
    bs_ga = badsnr_idx(tmp);
    tmp = ismember(goodsnr_idx,badabl_idx);
    ba_gs = goodsnr_idx(tmp);
    medval = nanmedian(out(ggidx,3).*100);

    semilogy(out(ggidx,1).*1e-3,out(ggidx,3).*100,'b.')
    hold on
    semilogy(out(bs_ga,1).*1e-3,out(bs_ga,3).*100,'r.')
    semilogy(out(bbidx,1).*1e-3,out(bbidx,3).*100,'rx','MarkerSize',5)
    semilogy(out(ba_gs,1).*1e-3,out(ba_gs,3).*100,'bx','MarkerSize',5)
    yline(1,'k-.')
    xlabel('Mass (kg)')
    ylabel('\tau (%)')    
end
hold off
legend('Immediate, Short','Immediate, Long','Delayed, Long','Delayed, Short')

%% match metadata loop


nsets = 4;
for iset = 4:nsets
     metadata_out = match_metadata('/media/lita3520/IMPACTablation/dust_data/6_7_21/',iset);
end

nsets = 7;
for iset = 1:nsets
     metadata_out = match_metadata('/media/lita3520/IMPACTablation/dust_data/6_16_21/',iset);
end

%% metadata plot
tmp = dir('*.csv');
m = readmatrix(tmp.name);
vtmp = m(:,5);
mtmp = m(:,6);

mass_list = [mass_list;mtmp];
vel_list = [vel_list;vtmp];