function ts_fixed = extract_timestamp(base_path,fix_on,bad_save)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to extract footer information and calculate timestamps for all events in a dataset.
% Inputs: base_path: path to dataset
%         fix_on: fix the problem with the timestamps          
%         bad_save: turn on for data taken on or prior to 2_4_22, which
%         saved the footer data in the incorrect location
% Outputs: ts: array of event timestamps in seconds since file creation
%
% 14 June 2021 - LKT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  barr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
  
  % load flag info
  tmp = load(strcat(base_path,'flag.mat'));
  nevents = size(tmp.flag,1);
  
  % set up arrays
  footer_info = nan(8,1);
  ts_sec = nan(nevents,1);
  
  % set up list of files
  flst = ls(strcat(base_path,'*.A.mat'));
  tmp = strsplit(flst,'/');
  fn = cell2mat(tmp(end));
  filename = fn(1:19);
  
  sample_rate = 100e6; % assumes 100 MS/s sample rate
  
  warning('off','MATLAB:MatFile:OlderFormat')
  count = 0;

  mult_fac = 4; % if not all channels are collecting data, must multiply timestamp by constant factor
  
  % loop through flagged events
  for ievent = 1:nevents
      disp(ievent)
    count = count+1;

    % get footer info
    for ichan = 9:16
      %obj = matfile(strcat(base_path,filename,'_1.4.',barr((ichan)),'.mat'));
      obj = matfile(strcat(base_path,filename,'_1.',barr((ichan)),'.mat'));
      % get footer information, stored in last (or 2nd to last, for erroneous collection) sample of last 8 channels
      dsize = size(obj,'Y1');
      if bad_save
          floc = dsize(2)-1;
      else
          floc = dsize(2);
      end
      footer_info(ichan-8) = eval(strcat('obj.Y',string(ievent),'(1,',string(floc),')'));
    end

    % convert data from voltages to samples
    footer_samps = round(footer_info.*8191.5+8191.5);
    ts_samps = footer_samps(2) + bitshift(footer_samps(3),16) + bitshift(footer_samps(4),32);

    % calculate timestamp
    ts_sec(count) = ts_samps./sample_rate.*mult_fac;

  end
  %%
  %fix the insane issue
  if (fix_on)
    while ts_sec(2) - ts_sec(1) > 43
        ts_sec(1) = ts_sec(1) + 42.95;
    end
    
    tmpindn = find(diff(ts_sec) < -0.1);
    tmpindp = find(diff(ts_sec) > 100);
    
    tmpind = sort([1;tmpindn;tmpindp]);
    nshifts = size(tmpind,1);
    
    mult_fac = 42.95.*[3;0;1;2];
    
    ts_fixed = ts_sec.*0;
    
    for ishift = 1:nshifts-1
        set = mod(ishift,4)+1;
        ts_fixed(tmpind(ishift)+1:tmpind(ishift+1))= ts_sec(tmpind(ishift)+1:tmpind(ishift+1))+mult_fac(set);
    end
    
    set = mod(nshifts,4)+1;
    ts_fixed(tmpind(nshifts)+1:end) = ts_sec(tmpind(nshifts)+1:end)+mult_fac(set);
  else
    ts_fixed = ts_sec;
  end

  warning('on','MATLAB:MatFile:OlderFormat')

end
