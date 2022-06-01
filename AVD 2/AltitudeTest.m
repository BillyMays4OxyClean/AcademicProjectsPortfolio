%% Created by Luke Patterson for Ellipsoid Testing
clear
close all
clc

%% Full Ellipse All-Body Generation

Sref = 9750;
Tau = 0.1206;
Sweep = 75;
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
end

plot(alt/1000,l,'-b','LineWidth',2)
xlabel('Altitude, km')
ylabel('Lift, Newtons')
title('Lift vs. Altitude')
set(gca,'xdir','reverse')
figure()
plot(alt/1000,d,'-k','LineWidth',2)
xlabel('Altitude, km')
ylabel('Drag, Newtons')
title('Drag vs. Altitude')
set(gca,'xdir','reverse')
