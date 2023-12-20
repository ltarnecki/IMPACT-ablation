%%%%%%%%%%%%%%%%%%
% Routine to flag identified dust events for low SNR/incomplete ablation
%
%
%
%%%%%%%%%%%%%%%%%%

%change to correct folder
bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_15_21/';
sset = '3';
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

flag = nan(nevents,1); 

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
    [~,~,flag(ievent,:)] = ginput(1);
    hold off
end

%%

%%%% 103 = clear deceleration (d)
%%%% 117 = no deceleration (n)

flag(flag == 110) = 0;
flag(flag == 100) = 1;

save('decel_flag.mat','flag')