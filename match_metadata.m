function metadata_out = match_metadata(base_path,batch)

%%%%%%%%%%%%%%%%%%%%%%%%
% function to match observed events with info in .csv viles
%   Inputs: 
%           base_path: path to directory containing a day of data
%           batch: dataset within a day
%
%   Output:
%           metadata_out: [timestamp, velocity, mass, flag_bad (1 if metadata match
%                           is bad)]
%%%%%%%%%%%%%%%%%%%%%%%%

load(strcat(base_path,string(batch),'/flag.mat'))
nevents = size(flag,1);

% get metadata
tmp = dir(strcat(base_path,'*.csv'));
m = readmatrix(strcat(base_path,tmp.name));
%%%%% 
% Columns:
% 1 event ID
% 2 UTC timestamp
% 3 local timestamp
% 4 integer timestamp (ms)
% 5 velocity (m/s)
% 6 mass (kg)
% 7 charge (C)
% 8 radius (m)t
%%%%%%

metadata_in.tstamp = m(:,3);
metadata_in.velocity = m(:,5);
metadata_in.mass = m(:,6);

% get timestamp base (date)
tstamp_base = char(string(m(2,3)));
tstamp_base = tstamp_base(1:8);

% get file creation time
tmp = load(strcat(base_path,'tstart.mat'));
tstart = tmp.tstart(batch,:);
tinit = strcat(tstamp_base,tstart);

tstart_dt = datetime(tinit,'InputFormat','yyyyMMddHHmmss.SSS');

% determine timestamp of each event (seconds since file creation)
ts = extract_timestamp(strcat(base_path,string(batch),'/'),1,1);

%%
ts_corr = ts+5;
tmp = load(strcat(base_path,string(batch),'/flag.mat'));
flag = tmp.flag;
metadata_out = nan(nevents,4);
diff_t = nan(nevents,1);

for ievent = 1:nevents
    t_elapse = duration(0,0,ts_corr(ievent));
    t_event_tmp = datetime(tstart_dt + t_elapse,'Format','yyyyMMddHHmmss.SSS');
    t_event = str2num(string(t_event_tmp));
    
    % record NaN if event is outside min and max time of metadata 
    if isempty(t_event)
        metadata_out(ievent,1) = nan;
        metadata_out(ievent,2) = nan;
        metadata_out(ievent,3) = nan;
    elseif t_event < m(1,3) || t_event > m(end,3)
        metadata_out(ievent,1) = nan;
        metadata_out(ievent,2) = nan;
        metadata_out(ievent,3) = nan;
    else
       [~,midx] = min(abs(metadata_in.tstamp - t_event));
       metadata_out(ievent,1) = metadata_in.tstamp(midx);
       metadata_out(ievent,2) = metadata_in.velocity(midx);
       metadata_out(ievent,3) = metadata_in.mass(midx);
       diff_t(ievent) = metadata_in.tstamp(midx)-t_event;
       if abs(diff_t(ievent)) > 1
           flag_bad = 1;
       else
           flag_bad = 0;
       end
       metadata_out(ievent,4) = flag_bad;
    end
end

figure(1)
plot(ts,'*')
figure(2)
plot(diff_t(flag == 1),'*')
figure(3)
plot(diff_t,'*')
hold on
plot(find(flag == 1),diff_t(flag == 1),'*')
hold off

svstr = strcat(base_path,string(batch),'/metadata.mat');
save(svstr,'metadata_out')

end