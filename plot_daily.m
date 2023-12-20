% Various routines to plot the luminous efficiency results for one or 
% several days of data(kind of a mess)
% 
% plots the output of process_daily_data agianst velocity and mass, sorting 
% the events by flag
% saves the overall output (mass, velocity, luminous efficiency) for all
% events in the dust_data directory as out_all.mat
% saves the overall output of good events (fully ablated & good SNR) in the
% dust_data directory as out_good.mat

bpath = '/media/lita3520/IMPACTablation/dust_data/';
dtstr = ["6_16_21","6_15_21","6_14_21","6_7_21","6_3_21"];
ndays = size(dtstr,2);
nsets = [7,7,8,4,4];
%figure(1)

icolors = jet(31);
colormap(icolors)
colormap(jet)

out_all = nan(1,6);
out_good = nan(1,6);

%{
fig = figure('Units','inch','position',[0,0,6.5,3]);
t=tiledlayout(1,2);
nexttile
%}
dl = 0;
ds = 0;
il = 0;
is = 0;

st_iron = [];

for iday = 1:ndays
    for iset = 1:nsets(iday)
        cd(strcat(bpath,dtstr(iday),'/',string(iset)))
        load('out_new.mat')
        tmp = load('qual_flag.mat');
        qflag = tmp.flag;
      %{  
        %tmp = load('turn_on_flag_update.mat');
        tmp = load('turn_on_flag.mat');
        tflag = tmp.flag;
        tflag(tflag > 48) = 25;
        tflag(tflag < 1) = 1;
%        tmp = load('path_length_flag.mat');
 %       pflag = tmp.flag;
%        tflag(tflag > 48) = 1;
 %       tflag(tflag < 1) = 1;
      %}
        tm_flag = out(:,5);%1 for bad time match
        ablation_flag = qflag(:,2); %1 for incomplete ablation
        if (~isempty(tm_flag))
            tot_flag = tm_flag + ablation_flag;
        else
            tot_flag = [];
        end
        %st_iron = [st_iron;tflag];
        %{
        didx = find(tflag(:,1) == 0);
        iidx = find(tflag(:,1) == 1);
        lidx = find(tflag(:,2) == 0);
        sidx = find(tflag(:,2) == 1);

        % get counts
        dl = dl + size(intersect(didx,lidx),1);
        ds = ds + size(intersect(didx,sidx),1);
        il = il + size(intersect(iidx,lidx),1);
        is = is + size(intersect(iidx,sidx),1);
        
        %}
        ggidx = find(tot_flag == 0);
        bbidx = find(tot_flag == 2);
        badt_idx = find(tm_flag == 1);
        badabl_idx = find(ablation_flag == 1);
        goodt_idx = find(tm_flag == 0);
        goodabl_idx = find(ablation_flag == 0);
        tmp = ismember(badt_idx,goodabl_idx);
        bt_ga = badt_idx(tmp);
        tmp = ismember(goodt_idx,badabl_idx);
        ba_gt = goodt_idx(tmp);
        
        medval = nanmedian(out(ggidx,3).*100);
        
        %{
        nexttile(1)
        semilogy(out(didx,2).*1e-3,out(didx,3).*100,'b.')
        hold on
        semilogy(out(iidx,2).*1e-3,out(iidx,3).*100,'m.')
        xlabel('Velocity (km/s)')
        ylabel('\tau (%)')
        legend('Delayed Ablation','Immediate Ablation')
        set(gca,'yscale','log')

        nexttile(3)
        semilogy(out(lidx,2).*1e-3,out(lidx,3).*100,'b.')
        hold on
        semilogy(out(sidx,2).*1e-3,out(sidx,3).*100,'m.')
        xlabel('Velocity (km/s)')
        ylabel('\tau (%)')
        legend('Long Ablation','Short Ablation')
        set(gca,'yscale','log')
        %}
%{
        %figure(4)
        scatter(out(:,2).*1e-3,out(:,3).*100,12,icolors(tflag,:),'filled')
        hold on
        set(gca,'yscale','log')
        hold on
        colormap(gca,icolors)
        caxis([1,48])
%}       

     %{

        dx = 6.5.*1e-3;
        ablation_time = pflag.*dx.*1e-1.*1e2./out(:,2);
        ablation_time = pflag.*dx./out(:,2).*1e6;
    
        scatter(out(:,2).*1e-3,out(:,3).*100,12,icolors(ceil(ablation_time),:),'filled','')

%        scatter(out(~ablation_flag,2).*1e-3,out(~ablation_flag,3).*100,12,icolors(ceil(ablation_time),:),'filled')
        set(gca,'yscale','log')
        hold on
        c=colorbar();
        colormap(gca,icolors)
        caxis([0,0.31])
        xlabel('Velocity (km/s)')
        ylabel('\tau (%)')
        c.Label.String='Ablation Time (s)';

     %}
        figure(1)
        subplot(211)
        semilogy(out(ggidx,2).*1e-3,out(ggidx,3).*100,'b.','DisplayName','Good Match, Full Ablation')
        hold on
        semilogy(out(bt_ga,2).*1e-3,out(bt_ga,3).*100,'r.','DisplayName','Bad Match, Full Ablation')
        semilogy(out(bbidx,2).*1e-3,out(bbidx,3).*100,'rx','MarkerSize',5,'DisplayName','Bad Match, Incomplete Ablation')
        semilogy(out(ba_gt,2).*1e-3,out(ba_gt,3).*100,'bx','MarkerSize',5,'DisplayName','Good Match, Incomplete Ablation')
        yline(1,'k-.','DisplayName','1%')
        xlabel('Velocity (km/s)')
        ylabel('\tau (%)')
        subplot(212)
        loglog(out(ggidx,1),out(ggidx,3).*100,'b.')
        hold on
        semilogx(out(bt_ga,1),out(bt_ga,3).*100,'r.')
        semilogx(out(bbidx,1),out(bbidx,3).*100,'rx','MarkerSize',5)
        semilogx(out(ba_gt,1),out(ba_gt,3).*100,'bx','MarkerSize',5)
        yline(1,'k-.')
        xlabel('Mass (kg)')
        ylabel('\tau (%)')        
        out_all = [out_all;out];
        figure(2)
        semilogy(out(ggidx,2).*1e-3,out(ggidx,3).*100,'b.')
        hold on
        out_good = [out_good;out(ggidx,:)];

    end
end
%%

figure(4)
colormap(icolors)
c = colorbar();
caxis([1,48])
title('Start Channel')
xlabel('Velocity (km/s)')
ylabel('\tau (%)')
hold off

med_val = nanmedian(out_all(:,3));
good_med_val = nanmedian(out_good(:,3));
good_std = nanstd(out_good(:,3));

%%

figure(1)
subplot(211)
legend('','','','','','','','Good Match, Fully Ablated','Bad Match, Fully Ablated','Bad Match, Incomplete Ablation','Good Match, Incomplete Ablation','1%','location','southeast')
legend('boxoff')
%legend('Good Match, Fully Ablated','Bad Match, Fully Ablated',)
title(strcat('nevents=',string(size(out_all,1))))
%text(35,0.005,strcat('median=',string(med_val.*100),'%'))
hold off
figure(2)
xlabel('Velocity (km/s)')
ylabel('\tau (%)')
title('Good Events')
%text(30,good_med_val.*100+1,strcat('median=',string(good_med_val.*100),'%'))
%text(30,good_med_val.*100,strcat('standard deviation=',string(good_std.*100)))
hold off
%%
%figure(3)
colormap(jet)
cparam = log10(out_good(:,1));
scatter(out_good(:,2).*1e-3,out_good(:,3).*100,10,cparam,'filled')
set(gca,'yscale','log')
xlabel('Velocity (km/s)')
ylabel('\tau (%)')
c = colorbar();
c.Label.String = 'log Mass (kg)';
%hold on
%yline(1,'k--')
%hold off
%%
save('/media/lita3520/IMPACTablation/dust_data/out_all_L.mat','out_all')
save('/media/lita3520/IMPACTablation/dust_data/out_good_L.mat','out_good')
