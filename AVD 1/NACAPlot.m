%% Created by Luke Patterson for the purposes of generating a Four-Digit NACA Cambered or Uncambered Airfoil Section
clear
close all
clc

%% Airfoil Plot for NACA 2412
m = 0.02;
p = 0.4;
t = 0.12;
c = 1;
nseg = 128;

[xc,yc,dycdx,xu,yu,xl,yl,f] = NACA4Cambered(m,p,t,c,nseg);

plot(xc,yc,'-.b')
hold on
plot(xl,yl,'-k')
plot(xu,yu,'-k')
title('NACA 2412')
xlabel('Chord length')
ylabel('Section thickness')
grid on
xlim([-0.1 c+0.1])
ylim([-2*t*c 2*t*c])

%% Airfoil Plot for a NACA 0012
t = 0.12;
c = 1;
nseg = 128;

[xu,yu,xl,yl] = NACA4(t,c,nseg);

figure()
plot(xl,yl,'-k')
hold on
plot(xu,yu,'-k')

title('NACA 0012')
xlabel('Chord length')
ylabel('Section thickness')

grid on
xlim([-0.1 c+0.1])
ylim([-2*t*c 2*t*c])