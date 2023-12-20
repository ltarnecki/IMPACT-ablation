%% plot theoretical mass loss vs. time

Lambda = 0.5;
A = 1;
rho_m = 7874;
rho_a = 1.584e-4;
L = 8e6;
v = 30e3;
m0 = 1.1e-18;

const = A*Lambda./(2*L)*(rho_a*v.^3/rho_m^(2/3));

mprime = @(t,m) -const.*(m).^(2/3);

tspan = [0 8].*1e-6;
[t,m] = ode45(mprime,tspan,m0);

semilogy(t.*1e6,m,'b','LineWidth',1.5)
xlabel('Time (\mu s)')
ylabel('Mass (kg)')

%ts = text(1,4e-19,'$$\frac{dm}{dt}=-\frac{A\Lambda}{2L}\left(\frac{m}{\rho_m}\right)^{2/3}\rho_Av^3$$','Interpreter','latex');

title(strcat('v = ',string(v.*1e-3),'km/s'))