function [dvdt,dv] = calculate_decel(dmat_loc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to calculate the deceleration of a dust event
% Requires the signal to be seen on 3 PMTs
% Plots the signals with the center channels in red; user selects
% the signal peaks on the center channels (from PMT1 - PMT3)
% Algorithm then calculates the velocity between PMT1 and PMT2, and between
% PMT2 and PMT3, then calculates and returns the deceleration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

npts = size(dmat_loc,2);
tvec = linspace(1,npts,npts)./1e8; %seconds

pmt_chan = [6,4,5,3,8,2,7,1,10,16,9,15,12,14,11,13];
pxs = [pmt_chan,pmt_chan + 16, pmt_chan + 32];
offset = 50;

figure(2)
for ichann = 1:48
    if ichann < 17
        ipmt = 1;
    elseif ichann < 33
            ipmt = 2;
    else
        ipmt = 3;
    end
    if ichann == 5 || ichann == 21 || ichann == 37
        plot(tvec,(dmat_loc(pxs(ichann),:).*1e3)+offset.*(16-pmt_chan(ichann-(16*(ipmt-1))))+800*(ipmt-1),'r')
    else
        plot(tvec,(dmat_loc(pxs(ichann),:).*1e3)+offset.*(16-pmt_chan(ichann-(16*(ipmt-1))))+800*(ipmt-1),'k')
    end
    hold on
end
hold off
[xloc,~,~] = ginput(3);

dx = 0.104; %m, distance between pmt centers

vel1 = dx/(xloc(2)-xloc(1));
vel2 = dx/(xloc(3)-xloc(2));

dv = abs(vel1-vel2);
dt = xloc(3)-xloc(1);
dvdt = dv/dt;

end