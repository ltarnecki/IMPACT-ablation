%%%%%%%%%%%%%%%%%%%%%%
% Loops through flagged events and plots all PMT data.
% User clicks to define the center of the event.
% A file (event_#.mat) will be saved with the data from all PMTs, 
%    the time vector, and the footer information for the event.
%%%%%%%%%%%%%%%%%%%%%%

% SETUP
base_path = '/media/lita3520/IMPACTablation/dust_data/6_15_21/7/';
flst = ls(strcat(base_path,'*1.A.mat'));
tmp = strsplit(flst,'/');
fn = cell2mat(tmp(end));
runname = fn(1:19);

barr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
daq_chans = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
pmt_chan = ([6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13,]);
nchans = 16;
npmts = 4;

% load flags
load(strcat(base_path,'flag.mat'));

npts = 100096;
dmat1 = nan(nchans,npts);
dmat2 = dmat1;
dmat3 = dmat1;
dmat4 = dmat1;

% read in data
events = find(flag == 1);
nevents = size(events,1);
for ievent = 1:nevents
    
    irec = events(ievent);
    %read in data 
    
    figure(1)
    offset = 50;
    end_cutoff = 3;
    tvec = linspace(1,npts,npts);
    %%
    ipmt = 1;
    for ichan=1:nchans
        %obj = matfile(strcat(base_path,runname,'_1.',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        obj = matfile(strcat(base_path,runname,'_',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        dmat1(pmt_chan(ichan),:) = eval(strcat('obj.Y',string(irec)));
        plot(tvec(1:npts-end_cutoff),(dmat1(pmt_chan(ichan),1:npts-end_cutoff).*1e3)+offset.*(16-pmt_chan(ichan))+800*(ipmt-1))
        hold on
    end
    xlabel('Time (\mu s)')
    ylabel('Voltage (mV), 50 mV offset')
    title(strcat('i=',string(irec)))
    
    ipmt = 2;
    for ichan=1:nchans
        %obj = matfile(strcat(base_path,runname,'_1.',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        obj = matfile(strcat(base_path,runname,'_',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        dmat2(pmt_chan(ichan),:) = eval(strcat('obj.Y',string(irec)));
        plot(tvec(1:npts-end_cutoff),(dmat2(pmt_chan(ichan),1:npts-end_cutoff).*1e3)+offset.*((16-pmt_chan(ichan)))+800*(ipmt-1))
    end
    
    ipmt = 3;
    for ichan=1:nchans
        %obj = matfile(strcat(base_path,runname,'_1.',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        obj = matfile(strcat(base_path,runname,'_',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        dmat3(pmt_chan(ichan),:) = eval(strcat('obj.Y',string(irec)));
        plot(tvec(1:npts-end_cutoff),(dmat3(pmt_chan(ichan),1:npts-end_cutoff).*1e3)+offset.*((16-pmt_chan(ichan)))+800*(ipmt-1))
    end
    %{
    ipmt = 4;
    for ichan=1:nchans
        %obj = matfile(strcat(base_path,runname,'_1.',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        obj = matfile(strcat(base_path,runname,'_',string(ipmt),'.',barr(daq_chans(ichan)),'.mat'));
        dmat4(pmt_chan(ichan),:) = eval(strcat('obj.Y',string(irec)));
        plot(tvec(1:npts-end_cutoff),(dmat4(pmt_chan(ichan),1:npts-end_cutoff).*1e3)+offset.*((16-pmt_chan(ichan)))+800*(ipmt-1))
    end
    %}
    [cpt,~] = ginput(1);

    npts_range = 1e4;
    elims = [cpt-npts_range,cpt+npts_range];
    if elims(1) < 1
        elims(1) = 1;
    end
    if elims(2) > npts
        elims(2) = npts;
    end
    
    hold off
    
    elims = round(elims);
    elength = elims(2)-elims(1)+1;
    event_data = nan(nchans*npmts+4,elength);
    event_data(1:nchans,:) = dmat1(:,elims(1):elims(2));
    event_data(nchans+1:2*nchans,:) = dmat2(:,elims(1):elims(2));
    event_data(2*nchans+1:3*nchans,:) = dmat3(:,elims(1):elims(2));
    event_data(3*nchans+1:4*nchans,:) = dmat4(:,elims(1):elims(2));
    event_data(end-3,:) = tvec(elims(1):elims(2)); % make the fourth to last row the time vector
    event_data(end-2,1:8) = dmat1(9:16,end-1); % make the first 8 elements of the third to last row footer info
    event_data(end-1,1:8) = dmat2(9:16,end-1); % make the first 8 elements of the second to last row footer info
    event_data(end,1:8) = dmat3(9:16,end-1); % make the first 8 elements of the last row footer info
    save(strcat(base_path,'event_',string(irec),'.mat'),'event_data')

end