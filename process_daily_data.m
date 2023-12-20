%%%%%%%%%
% Calculate luminous efficiency for a day's worth of data
%
% Events must be isolated (i.e. in event_*.mat files)
%
% Set collection date
%
% Saves file out.mat with mass, velocity, luminous efficiency, lum eff
% error
%%%%%%%%%%

% change to correct folder
bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_14_21/';
nsets = 7;

for iset = 1:nsets
    cd(strcat(bpath,edate,string(iset)))

    % load particle metadata
    load('metadata.mat')   
    metadata = metadata_out;

    % load flag
    load('flag.mat')
    flag = find(flag == 1);
        nevents = size(flag,1);

    % set up output array: mass, velocity, luminous efficiency, 1sigma
    out = nan(nevents,4); 
    out(:,1) = metadata(flag',3);
    out(:,2) = metadata(flag',2);
    out(:,5) = metadata(flag',4);

    % list event files & fix the weird sorting
    lst = dir('event_*.mat');
    name = {lst.name};
    str  = sprintf('%s#', name{:});
    num  = sscanf(str, 'event_%d.mat#');
    [dummy, index] = sort(num);
    fnames = name(index);

    % calculate luminous efficiency
    for ievent = 1:nevents
        load(cell2mat(fnames(ievent)))
        [out(ievent,3),out(ievent,4),out(ievent,6)] = lum_eff_calc(event_data,metadata(ievent,2),metadata(ievent,3),0);  
    end

    fpath = strcat(bpath,edate,string(iset),'/out_new.mat');
    save(fpath,'out')
    
end