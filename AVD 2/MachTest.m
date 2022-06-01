%% Created by Luke Patterson for Ellipsoid Body Testing
clear
close all
clc

%% VSPAero Data Import

%% Full Ellipse All-Body Generation
Sref = 83; % Latest and hopefully last design point
Tau = 0.15;
Sweep = 74;
lpil = 1;

test = Ellipsoid_Body;
test.Units = 'SI';
test.nseg = 2^5;
test = test.Generate_Ellipsoid_Body(Sref,Tau,Sweep,lpil);

%% Flight Condition Definition
fc = FlightCondition;
fc.Units = 'SI'; % Units may be "SI" or "FPS" for feet, pound, second
fc.Name = 'Reentry';
fc.AoA = 0;
fc.Altitude = 3000; % Set altitude here
 % Set Mach number here, if velocity is the desired property to be set,
% then change 'Mach' to 'V' and the number folling it to the desired velocity in the unit system defined for the class

CL = zeros(16,1);
L = zeros(16,1);
AoA = 0:1:15;

m = .1:.1:3.5;

for i=1:length(m)
    fc = fc.SetSpeed('Mach',m(i)); % Changing the AoA of the FlightCondition Class here
    [cl,L] = test.CalculateLift(fc); % Calculation of lift is performed here, CL and dimensionalized L are returned in the units specified
    [CD,D,CDi,CdO] = test.CalculateDrag(fc); % Calculation of drag is performed here, CD, dimensionalized D is returned in the units specified along with, CDi, and CD0
    Cd0b(i,1) = CdO;
    Cdi(i,1) = CDi;
    Cd(i,1) = CD;
    CL(i,1) = cl;
end

plot(m,Cd,"--k")
xlabel('Mach')
ylabel('C_D')
title('Drag coefficient vs. Maach')
