% rountine to visualize light production of the dust particle
% load event_*.mat file before running

dsum = sum(event_data(1:64,:),1);
plot(dsum)
[xinds,~] = ginput(2);
drange = dsum(xinds(1):xinds(2));
npts = size(drange,2);

dsmooth = smooth(drange,40);
plot(dsmooth)

xmax = npts;
ymax = 200;
sigx = 7;
sigy = 7;
Nx = npts;
Ny = 1000;

[x,y]=meshgrid(linspace(0,xmax,Nx),linspace(-ymax,ymax,Ny));
xvec = x(1,:);
yvec = y(:,1);
figure(1)

v = VideoWriter('ltest.avi');
v.FrameRate = 300;
open(v);
colormap(hot)
for istep = 1:npts
    xcen = istep+1;
    scl = dsmooth(istep).*10;
    G=scl.*exp(-(((x-xcen)/sigx).^2+((y)/sigy).^2)/2);
    imagesc(xvec,yvec,G,[0.5,2])
    %mx(istep) = max(G,'','all');
    %xlim([0,ymax])
    %ylim([-50,50])
    set(gca,'YDir','normal')
    daspect([1 1 1])
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);