function out = check_dust_data(base_path,nrecs,npts,method,istart)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Routine to manually inspect the data for dust events. User can decide to 
% click through events in real time, make plots of all events, or make a
% movie of all events.
%
% Inputs
%           path: path to data
%           nrecs: number of events in the data set
%           npts: number of sample points
%           method: 1 - click through events individually
%                   2 - make plots
%                   3 - make a movie
%           istart: start analysis at record istart
%
% Outputs
%           out: if clicking through events individually, return a vector
%           of 0 if there is no dust event, 1 if there is. Otherwise,
%           return 0
%
% LKT, 4 June 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % set up channel mapping
    barr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
    daq_chans = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
    pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13];
    nchans = 16;
    npmts = 3;
    
    flst = ls(strcat(base_path,'*_1.A.mat'));
    tmp = strsplit(flst,'/');
    fn = cell2mat(tmp(end));
    filename = fn(1:19);

    offset = 50;
    tvec = linspace(1,npts,npts);
    
    end_cutoff = 2; %# of points to cut off the end of the data (NPT footer)

    % set up figure & movie (if using)
    figure(1)
    if method == 3
        F(nrecs) = struct('cdata',[],'colormap',[]);
        v = VideoWriter(strcat(base_path,'event_check.avi'));
        v.FrameRate = 3;
        open(v)
    end
    if method == 1
        out = nan(nrecs,1);
    end
    
    dmat = nan(nchans,npts);
    %{
    for irec = istart:nrecs
        for ipmt = 1:npmts
            %read in data 
            for ichann=1:nchans
                obj = matfile(strcat(base_path,filename,'_',string(ipmt),'.',barr(daq_chans(ichann)),'.mat'));
                dmat(pmt_chan(ichann),:) = eval(strcat('obj.Y',string(irec)));
                plot(tvec(1:npts-end_cutoff),(dmat(pmt_chan(ichann),1:npts-end_cutoff).*1e3)+offset.*(16-pmt_chan(ichann))+800*(ipmt-1))
                hold on
            end
            xlabel('Sample')
            ylabel('Voltage (mV), 50 mV offset')
            title(strcat('i=',string(irec)))
        end
        hold off
        
        switch method
            case 1
                [~,~,out(irec)] = ginput(1);
            case 2
                out = 0;
                savestr = strcat(base_path,'event_',string(irec),'.png');
                print(savestr,'-dpng')
            case 3
                out = 0;
                frame = getframe(gcf);
                writeVideo(v,frame);
        end
    end
    %}
    npmts = 1;
        for irec = istart:nrecs
        for ipmt = 1:npmts
            %read in data 
            for ichann=9:nchans
                obj = matfile(strcat(base_path,filename,'_',string(ipmt),'.',barr((ichann)),'.mat'));
                dmat((ichann),:) = eval(strcat('obj.Y',string(irec)));
                plot(tvec(npts-20:npts-end_cutoff),(dmat((ichann),npts-20:npts-end_cutoff).*1e3)+offset.*(16-(ichann))+800*(ipmt-1))
                hold on
            end
            xlabel('Sample')
            ylabel('Voltage (mV), 50 mV offset')
            title(strcat('i=',string(irec)))
        end
        hold off
        
        switch method
            case 1
                [~,~,out(irec)] = ginput(1);
            case 2
                out = 0;
                savestr = strcat(base_path,'event_',string(irec),'.png');
                print(savestr,'-dpng')
            case 3
                out = 0;
                frame = getframe(gcf);
                writeVideo(v,frame);
        end
    end
    
    % adjust flags to binary 0/1
    if method == 1
        out(out == 1) = 0;
        out(out == 3) = 1;
    end
    % close movie
    if method == 3
        close(v)
    end

end