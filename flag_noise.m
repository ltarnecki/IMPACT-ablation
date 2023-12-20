%%%%%%%%%%%%%%%%%%
% Routine to flag identified dust events for immediate/delayed start time 
% and long/short total ablation time
%
%
%
%%%%%%%%%%%%%%%%%%

%change to correct folder
bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_16_21/';
sset = '7';
cd(strcat(bpath,edate,sset))

pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13];
pxs = [pmt_chan,pmt_chan + 16, pmt_chan + 32];

% list event files & fix the weird sorting
lst = dir('event_*.mat');
name = {lst.name};
str  = sprintf('%s#', name{:});
num  = sscanf(str, 'event_%d.mat#');
[dummy, index] = sort(num);
fnames = name(index);

nevents = size(index,1);

offset = 50;
end_cutoff = 2; %# of points to cut off the end of the data (NPT footer)

flag = nan(nevents,2); 
% i/d for immediate/delayed turn on
% s/l for short/long ablation time

for ievent = 1:nevents
    load(cell2mat(fnames(ievent)))
    figure(1)
    for ichann = 1:48
        if ichann < 17
            ipmt = 1;
        elseif ichann < 33
                ipmt = 2;
        else
            ipmt = 3;
        end
       plot(event_data(49,:),(event_data(pxs(ichann),:).*1e3)+offset.*(16-pmt_chan(ichann-(16*(ipmt-1))))+800*(ipmt-1)) 
       hold on
    end
    [~,~,flag(ievent,:)] = ginput(2);
    hold off
end

%%%% 100 = delayed (d) --> 0
%%%% 105 = immediate (i) --> 1
%%%% 108 = long (l) --> 0
%%%% 115 = short (s) --> 1

flag(flag == 100) = 0;
flag(flag == 105) = 1;
flag(flag == 108) = 0;
flag(flag == 115) = 1;


save('turn_on_flag.mat','flag')