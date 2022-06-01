%% Created by Luke Patterson for the Unpowered coast phase of Aspiration
clear
close all
clc

%% Full Ellipse All-Body Generation

Sref = 546;
Tau = 0.32;
Sweep = 77;
lpil = 0.667;

test = Ellipsoid_Body;
test.Units = 'SI';
test.nseg = 2^6;
test = test.Generate_Ellipsoid_Body(Sref,Tau,Sweep,lpil);

fc = FlightCondition;
fc.Units = 'SI';
fc.Name = 'Reentry';
fc.AoA = 3;

alt = 100000:-1000:50000;

for a = 1:length(alt)
    fc.Altitude = alt(a);
    fc = fc.SetSpeed("Mach",3);
    [cl,L] = test.CalculateLift(fc);
    [CD,D,CDi] = test.CalculateDrag(fc);
    d(a) = D;
    l(a) = L;
    Cl(a) = cl;
    Cd(a) = CD;
end

plot(alt/1000,Cl,'-b')
xlabel('Altitude, km')
ylabel('C_L')
title('C_L vs. Altitude')
set(gca,'xdir','reverse')
figure()
plot(alt/1000,Cd,'-b')
xlabel('Altitude, km')
ylabel('C_D')
title('C_D vs. Altitude')
set(gca,'xdir','reverse')

figure()
plot(alt/1000,l,'-b')
xlabel('Altitude, km')
ylabel('Lift, Newtons')
title('Lift vs. Altitude')
set(gca,'xdir','reverse')
figure()
plot(alt/1000,d,'-k')
xlabel('Altitude, km')
ylabel('Drag, Newtons')
title('Drag vs. Altitude')
set(gca,'xdir','reverse')
