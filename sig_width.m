% plot width of dust signal vs channel

bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_15_21/';
sset = '6';
cd(strcat(bpath,edate,sset))

p4_dat = load('/media/lita3520/IMPACTablation/pmt4_ex.mat');

pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13];
pxs = [pmt_chan,pmt_chan + 16, pmt_chan + 32,pmt_chan+48];
idcs = [10,12,11,13,8,14,9,15,6,0,7,1,4,2,5,3];
idcsf = [idcs,idcs + 16, idcs + 32,idcs+48]+1;

event_list = [79,80,126,177];
nevents = size(event_list,2);
nchann = 64;

end_cutoff = 2; %# of points to cut off the end of the data (NPT footer)
widths = nan(nevents,nchann);

for ievent = 1:nevents
    load(strcat('event_',string(event_list(ievent)),'.mat'))
    npts = size(event_data,2);
    event_data_aug = [event_data(1:48,:);p4_dat.dmat4(:,1:npts).*rand(16,npts);event_data(49:52,:)];
    lint = nan(64,1);
    tvec = event_data_aug(65,:)./1e8.*1e6;
    
    for ichann = 1:64
        %{
        subplot(211)
        plot(event_data_aug(65,:)./1e8.*1e6,(event_data_aug(pxs(ichann),:).*1e3)+offset.*idcsf(ichann));
        hold on
        xlabel('Time (\mu s)')
        ylabel('Voltage (mV, 50 mV offset)')
%}
        dat = event_data_aug(pxs(ichann),:).*1e3+offset.*idcsf(ichann);
        fts = fit(tvec',smooth(dat',100)-median(dat),'gauss1');
        widths(ievent,ichann) = 2*sqrt(2*log(2))*fts.c1/sqrt(2);
        
    end
    hold off

    subplot(2,2,ievent)
    widths(widths > 10) = nan;
    plot(widths(ievent,:),'*')
    xlabel('Channel')
    ylabel('FWHM (\mu s)')
end