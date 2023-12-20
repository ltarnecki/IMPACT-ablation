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

flag = nan(nevents,1); %path length in channels

offset = 50;


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
        didx = find(pxs == ichann);
        plot(event_data(end-3,:),(event_data(pxs(ichann),:).*1e3)+offset.*(16-pmt_chan(ichann-(16*(ipmt-1))))+800*(ipmt-1)) 
        text(median(event_data(end-3,:)+5000),offset.*ichann,string(ichann))
        title((fnames(ievent)))
        hold on
    end
    [~,~,tmp] = ginput(4);
    hold off
    tmp = tmp-48;
    flag(ievent) = str2num(strjoin(string(tmp(3:4)'),''))-str2num(strjoin(string(tmp(1:2)'),''));
end

save('path_length_flag.mat','flag')