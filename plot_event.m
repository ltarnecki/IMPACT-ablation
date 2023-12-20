%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Routine to plot a single ablation event
%
% Specify path to data, date, data batch, and number of event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bpath = '/media/lita3520/IMPACTablation/dust_data/';
edate = '6_15_21/';
sset = '4';
enum = 578;

load(strcat(bpath,edate,sset,'/event_',string(enum)))

pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13];
pxs = [pmt_chan,pmt_chan + 16, pmt_chan + 32, pmt_chan + 48];

offset = 50;

figure(2)
for ichann = 1:64
    if ichann < 17
        ipmt = 1;
    elseif ichann < 33
            ipmt = 2;
    elseif ichann < 49
        ipmt = 3;
    else
        ipmt = 4;
    end
   plot(event_data(end-3,:)./100e6.*1e6,(event_data(pxs(ichann),:).*1e3)+offset.*(16-pmt_chan(ichann-(16*(ipmt-1))))+800*(ipmt-1)) 
   hold on
end

yline(1600-25,'k--')
yline(800-25,'k--')
yline(2400-25,'k--')
hold off
xlabel('Time (\mu s)')
ylabel('Voltage - 50 mV offset (mV)')
ylim([0,3200])