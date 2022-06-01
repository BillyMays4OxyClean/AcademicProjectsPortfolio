%% Created by Luke Patterson
clear
close all
clc

%% Inputs
Swet = 2132; % Wetted planform area
S = 1041; % Rerence planform area
Sref = 1316; % Planform area
b = 141; % wingspan

M0 = 0.55; % Mach number used for compressibility corrections. Works for Mach values < 0.8


%% NACA Four-Digit Section Generator
[m,p,t] = NACA2Specs('2421');
c = 5;
nseg = 128;

Airfoil = NACA4WingSection('2421',c,nseg);
xc = Airfoil.xc;
yc = Airfoil.yc;
f = @Airfoil.MeanSlope;
xu = Airfoil.xu;
yu = Airfoil.yu;
xl = Airfoil.xl;
yl = Airfoil.yl;
naca = Airfoil.Name;

plot(xc,yc,'-.b')
hold on
plot(xl,yl,'-k')
plot(xu,yu,'-k')

title(['NACA ',naca])
xlabel('Chord length')
ylabel('Section thickness')
grid on
xlim([-0.1 c+0.1])
ylim([-2*t*c 2*t*c])

%% Thin Airfoil Theory for Cambered Wing Sections: Section Lift and Moment Coefficient Calculations
m0 = 2*pi;
m0 = m0 / sqrt(1 - M0^2);
theta = transpose(0:pi/(nseg-1):pi) ;
x = transpose(c/2*(1 - cos(theta))) ;
dydx = zeros(length(x),1);

for i = 1:length(x)
    dydx(i) = f(x(i));
end

integrand = -1/pi * dydx .* (cos(theta) - 1) ;

a0l = integrate_simpson(integrand,0,pi,128) ;

Cl = @(AoA) m0 * (deg2rad(AoA) - a0l) ;

integrand = -1/2 * dydx .* (cos(2*theta) - cos(theta));

CMac = integrate_simpson(integrand,0,pi,128);

AoA = -2:1:12;

% figure()
% 
% plot(AoA,Cl(AoA),'-b','LineWidth',2)
% grid on
% title('C_L_\alpha (Thin Airfoil Theory Cambered)')
% xlabel('Angle of Attack, degrees')
% ylabel('Section lift coefficient, C_L')

%% Finite Wing Corrections
AR  = b^2/Sref;
B = sqrt(1 - M0^2);
delta = 0;
CLa = 2*pi*AR/(2+sqrt(4+AR^2*B^2*(1+(tand(delta)^2/B^2)) ));
CL = @(AoA) CLa*(deg2rad(AoA)-a0l);

figure()
% subplot(2,2,1)
plot(AoA,CL(AoA),'-b','LineWidth',2)
grid on
title('Finite Wing Corrected C_L_\alpha')
xlabel('Angle of Attack, degrees')
ylabel('Section lift coefficient, C_L')

%% Section drag coefficient calculations
kdp = 0.0047; % An assumption valid only for the NACA 24XX family of airfoils
e = 0.7;
Clmin = 0.2;
Cdmin = 0.007;

Cd = @(AoA) Cdmin + kdp.*(CL(AoA) - Clmin).^2;

% subplot(2,2,2)
figure()
plot(AoA,Cd(AoA),'-k','LineWidth',2)
grid on
title('C_D_\alpha')
xlabel('Angle of Attack, degrees')
ylabel('Section drag coefficient, C_D')

%% Drag polar diagram
% figure()
% plot(Cd(AoA),Cl(AoA),'-Vk','LineWidth',2)
% 
% grid on
% title({'Drag Polar (Thin Cambered)';'';''})
% xlabel('C_D')
% ylabel('C_L')
% xtickangle(45)
% 
% ax = gca;
% ax.XAxis.Exponent = 0;
% 
% new_axis = axes('Position',ax.Position,'XAxisLocation','top','Color','none');
% line(Cl(AoA)./Cd(AoA),Cl(AoA),'Parent',new_axis,'Color','b','LineWidth',2,'Marker','o');
% xlabel('L/D')
% set(new_axis,{'xcolor'},{'b'})

%% CL vs. CD
% subplot(2,2,3)
figure()
plot(Cd(AoA),CL(AoA),'-b','LineWidth',2)
xlabel('Coefficient of Drag C_D')
ylabel('Coefficient of Lift C_L')
title('Section Lift vs. Section Drag')

%% Drag polar
% subplot(2,2,4)
figure()
CD = Cdmin + kdp.*(CL(AoA) - Clmin).^2;
a1 = plot(CD,CL(AoA),'-Vk','LineWidth',2);

grid on
title({'Drag Polar (Finite Wing Corrections)';'';''})
xlabel('C_D')
ylabel('C_L')

xtickangle(45)

ax = gca;
ax.XAxis.Exponent = 0;

new_axis = axes('Position',ax.Position,'XAxisLocation','top','Color','none');
a2 = line(CL(AoA)./Cd(AoA),CL(AoA),'Parent',new_axis,'Color','b','LineWidth',2,'Marker','o');
xlabel('L/D')
set(new_axis,{'xcolor'},{'b'})

% figure()
% hold on
% plot(AoAVSP,(CL./CD0),'b')
% plot(dat.AOA,(dat.CL./(dat.CDi+dat.CD0)),'r')
% xlabel('Angle of Attack \alpha (deg)')
% ylabel('Lift/Drag')
% title(['L/D vs \alpha at Mach ',num2str(Takeofff.AirSpeed.Mach)])
% legend('MATLAB Evaluation','VSPAero','Location','NorthWest')
% 
