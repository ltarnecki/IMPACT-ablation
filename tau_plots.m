%% plot luminous efficiency against velocity and mass, with errors
load('/media/lita3520/IMPACTablation/dust_data/out_good_new.mat')
load('/media/lita3520/IMPACTablation/analysis_code/fe_fit.mat')

fig = figure('Units','inch','position',[0,0,6.5,3]);
t=tiledlayout(1,2);
nexttile

hold on

ShadedErrorEllipse(out_good(:,2).*1e-3,out_good(:,3).*100,0.02*out_good(:,2).*1e-3,out_good(:,4).*100,'k',0.05,'off');

ms = 6;
colormap(jet)
scatter(out_good(:,2).*1e-3,out_good(:,3).*100,ms,dblue,'filled')
set(gca,'YScale','log')
xlabel('Velocity (km/s)')
ylabel('\tau (%)')
caxis([1e-19,1e-16])
set(gca,'ColorScale','log')


vspc = linspace(8.5,40,200);
yout = fe_fit(vspc);
plot(vspc,10.^yout.*1e2,'k--')
hold on


rmse = 10.^0.47;
c1 = 10.^yout*rmse;
c2 = 10.^yout./rmse;
x2 = [vspc,fliplr(vspc)];
ib = [c1;flipud(c2)];
fill(x2,ib'.*1e2,'k','FaceAlpha',0.1,'EdgeAlpha',0)
xlim([5,40])
ylim([1e-3,1e2])

grid on
grid minor
grid off
grid on

hold off
ylabel('\tau (%)')
xlabel('Velocity (km/s)')

nexttile
hold on
colormap(jet)
ShadedErrorEllipse(out_good(:,1),out_good(:,3).*100,0.05*out_good(:,1),out_good(:,4).*100,'b',0.1,'off');
scatter(out_good(:,1),out_good(:,3).*100,ms,dblue,'filled')

grid on
grid minor
grid off
grid on

ylim([1e-3,1e2])

set(gca,'xscale','log')
set(gca,'yscale','log')

xlim([5e-19,1e-16])

tl = get(gca,'YTick');
ticklabels_new = cell(size(tl));
for i = 1:length(tl)
ticklabels_new{i} = ['\color{white} ' tl(i)];
end
% set the tick labels
set(gca, 'YTickLabel', ticklabels_new);

xlabel('Mass (kg)')
t.TileSpacing = 'none';
t.Padding = 'none';
