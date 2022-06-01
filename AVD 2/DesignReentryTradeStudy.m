%% Created by Luke Patterson for Ellipsoid Body Testing
clear
close all
clc

% Trajectory Data Import
data = readmatrix("Aspiration Re-entry Data.xlsx");
M = data(:,2);
A = data(:,4);

%% Full Ellipse All-Body Generation
Sref = 74; % Latest and hopefully last design point
Tau = 0.162;
lpil = 0.667;

test = Ellipsoid_Body;
test.Units = 'SI';
test.nseg = 2^5;

%% Flight Condition Definition
fc = FlightCondition;
fc.Units = 'SI'; % Units may be "SI" or "FPS" for feet, pound, second
fc.Name = 'Reentry Trade Study';
fc.AoA = 15;

k = 1;
for sweep = 78:-1:70
    bodcontainer{k} = test.Generate_Ellipsoid_Body(Sref,Tau,sweep,lpil);
    for i=1:length(M)
        Alt(k,i) = A(i);
        s(k,i) = sweep;
        fc.Altitude = A(i);
        fc = fc.SetSpeed('Mach',M(i)); % Set Mach number here, if velocity is the desired property to be set,
        % then change 'Mach' to 'V' and the number folling it to the desired velocity in the unit system defined for the class
        [CL(k,i),L(k,i)] = bodcontainer{k}.CalculateLift(fc); % Calculation of lift is performed here, CL and dimensionalized L are returned in the units specified
        [CD(k,i),D(k,i),~,~] = bodcontainer{k}.CalculateDrag(fc); % Calculation of drag is performed here, CD, dimensionalized D is returned in the units specified along with, CDi, and CD0
    end
    k = k + 1;
end
%% A whole bunch o figures, if you don't need them get rid of them

figure()
A = mesh(Alt/1000,s,CL);
hold on
plot3(Alt(4,:)/1000,ones(1,105)*74,CL(5,:),'-r','LineWidth',2)
legend('Trade Study Sweep','Design Point Sweep','Location','Best')
A.FaceColor = 'b';
A.FaceAlpha = .75;
A.EdgeColor = 'none';
xlabel('Altitude, km')
ylabel('Body sweep angle, degrees')
zlabel('C_L')
title('C_L across reentry trajectory with varying body sweep')

figure()
B = mesh(Alt/1000,s,CD);
hold on
plot3(Alt(4,:)/1000,ones(1,105)*74,CD(5,:),'-r','LineWidth',2)
legend('Trade Study Sweep','Design Point Sweep','Location','Best')
B.FaceColor = 'k';
B.FaceAlpha = .75;
B.EdgeColor = 'none';
xlabel('Altitude, km')
ylabel('Body sweep angle, degrees')
zlabel('C_D')
title('C_D across reentry trajectory with varying body sweep')

figure()
B = mesh(Alt/1000,s,CL./CD);
hold on
plot3(Alt(4,:)/1000,ones(1,105)*74,CL(5,:)./CD(5,:),'-c','LineWidth',2)
legend('Trade Study Sweep','Design Point Sweep','Location','Best')
B.FaceColor = 'r';
B.FaceAlpha = .75;
B.EdgeColor = 'none';
xlabel('Altitude, km')
ylabel('Body sweep angle, degrees')
zlabel('L/D')
title('L/D across reentry trajectory with varying body sweep')