%% Created by Luke Patterson for Ellipsoid Body Testing
clear
close all
clc

% Trajectory Data Import
data = readmatrix("Aspiration Re-entry Data.xlsx");
M = data(:,2);
A = data(:,4);
% plot(A/1000,M,'-k','LineWidth',2)
% set(gca,'XDir','reverse')
% title('Mach vs. Altitude for Aspiration Reentry')
% xlabel('Altitude, km')
% ylabel('Mach')

%% Full Ellipse All-Body Generation
Sref = 74; % Latest and hopefully last design point
Tau = 0.162;
Sweep = 74;
lpil = 0.667;

test = Ellipsoid_Body;
test.Units = 'SI';
test.nseg = 2^5;
test = test.Generate_Ellipsoid_Body(Sref,Tau,Sweep,lpil);

%% Flight Condition Definition
fc = FlightCondition;
fc.Units = 'SI'; % Units may be "SI" or "FPS" for feet, pound, second
fc.Name = 'Reentry';

AoA = 0:1:20;

for a = 1:length(AoA)
    for i=1:length(M)
        Alt(a,i) = A(i);
        aoa(a,i) = AoA(a);
        fc.Altitude = A(i);
        fc.AoA = AoA(a);
        fc = fc.SetSpeed('Mach',M(i)); % Set Mach number here, if velocity is the desired property to be set,
        % then change 'Mach' to 'V' and the number folling it to the desired velocity in the unit system defined for the class
        [CL(a,i),L(a,i)] = test.CalculateLift(fc); % Calculation of lift is performed here, CL and dimensionalized L are returned in the units specified
        [CD(a,i),D(a,i),~,~] = test.CalculateDrag(fc); % Calculation of drag is performed here, CD, dimensionalized D is returned in the units specified along with, CDi, and CD0
    end
end
%% A whole bunch o figures, if you don't need them get rid of them

figure()
A = mesh(Alt/1000,aoa,CL);
hold on
plot3(Alt(16,:)/1000,ones(1,105)*15,CL(16,:),'-r','LineWidth',2)
legend('Available C_L','C_L along trajectory')
A.FaceColor = 'b';
A.FaceAlpha = .75;
A.EdgeColor = 'none';
xlabel('Altitude, km')
ylabel('AoA, degrees')
zlabel('C_L')
title('C_L across reentry trajectory with varying AoA')

figure()
B = mesh(Alt/1000,aoa,CD);
hold on
plot3(Alt(16,:)/1000,ones(1,105)*15,CD(16,:),'-r','LineWidth',2)
legend('Available C_D','C_D along trajectory')
B.FaceColor = 'k';
B.FaceAlpha = .75;
B.EdgeColor = 'none';
xlabel('Altitude, km')
ylabel('AoA, degrees')
zlabel('C_D')
title('C_D across reentry trajectory with varying AoA')

