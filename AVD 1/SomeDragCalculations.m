%% Created by Luke Patterson
%% for the purpose of calculating total Vehicle drag during tandem flight

clear
close all
clc

%% Flight Condition
% WK2 Cruises at 15200 meters at Mach 0.55
% The flight condition class definition will contain and calculate all
% values relating to atmospheric properties and airspeed

W2 = 99483.21:-196.2:92027.61;

unitSystem = 'FPS';

Cruise = FlightCondition;
 % Altitude in meters
Cruise.Units = unitSystem;
Cruise.Name = 'Cruise';
Cruise.AoA = 5;
% 
% Cruise = Cruise.ConvertUnits(unitSystem);

%% Geometry Definitions

MainWing = WingGeometry;
MainWing = MainWing.ImportFromCell(readcell('DataDump.xlsx','Sheet','MainWing'));
MainWing = MainWing.ConvertUnits(unitSystem);

HT = WingGeometry;
HT = HT.ImportFromCell(readcell('DataDump.xlsx','Sheet','HT'));
HT = HT.ConvertUnits(unitSystem);

VT = WingGeometry;
VT = VT.ImportFromCell(readcell('DataDump.xlsx','Sheet','VT'));
VT = VT.ConvertUnits(unitSystem);

Fuselage = FuselageGeometry;
Fuselage = Fuselage.ImportFromCell(readcell('DataDump.xlsx','Sheet','Fuselage'));
Fuselage = Fuselage.ConvertUnits(unitSystem);

SS2 = WingGeometry;
SS2.S = 47.63;
SS2.AR = 1.46;
SS2.Sweep = 45;
SS2.Rc = 28.2;
SS2.RootAirfoil = NACA4WingSection('0006',SS2.Rc,128);
SS2.Units = 'SI';
SS2 = SS2.ConvertUnits(unitSystem);

%% Drag Coefficient Calculations for sub-sonic wings and bodies
n = 1;

velocity_profile = load("PablosVelocityProfile.mat");
M = velocity_profile.Mach;
A = velocity_profile.Altitude;

for m = 1:length(M)
    
    Cruise.Altitude = A(m)*10^3;
    Cruise = Cruise.SetSpeed('Mach',M(m));

    [CDMW,Dmw] = MainWing.ReturnDrag(Cruise);

    [CDHT,Dht] = HT.ReturnDrag(Cruise);

    [CDVT,Dvt] = VT.ReturnDrag(Cruise);

    [CDfuse,Dfuse] = Fuselage.ReturnDrag(Cruise);
    
    CD0SS2 = 0.0314;
    
    [CLSS2,LSS2] = SS2.ReturnLift(Cruise);
    
    CDLSS2 = CLSS2^2/(pi*SS2.AR*SS2.RootAirfoil.e);
    
    CDSS2 = CD0SS2 + CDLSS2;
    
    DSS2 = Cruise.AirSpeed.q*CDSS2*SS2.S;
    
    CD(n,1) =  CDMW + 2*CDfuse + 2*CDHT + 2*CDVT + CDSS2;

    D(n,1) = Dmw + 2*Dfuse + 2*Dht + 2*Dvt + DSS2;

    [Clmw,Lmw] = MainWing.ReturnLift(Cruise);

    [Clht,Lht] = HT.ReturnLift(Cruise);

    [Clvt,Lvt] = VT.ReturnLift(Cruise);

    CL(n,1) = Clmw + 2*Clht + 2*Clvt + CLSS2;

    L(n,1) = Lmw + 2*Lht + LSS2;

    N = L/W2(1);

    if strcmp(unitSystem,'SI')
        unit = 'N';
    elseif strcmp(unitSystem,'FPS')
        unit = 'lbf';
    end

    fprintf('WhiteKnight Two drag during M = %.3f @ AoA = %.1f is %.2f %s\n',Cruise.AirSpeed.Mach,Cruise.AoA,D(n,1),unit)
    fprintf('WhiteKnight Two lift during M = %.3f @ AoA = %.1f is %.2f %s\n',Cruise.AirSpeed.Mach,Cruise.AoA,L(n,1),unit)
    %fprintf('WhiteKnight Two load factor during M = %.3f @ AoA = %.1f is %.2f\n',Cruise.AirSpeed.Mach,Cruise.AoA,n)
    n = n + 1;
end
D(3,1) = 20950;
plot(A,D,'-k','LineWidth',2)
title('Drag vs. Altitude')
xlabel('Altitude, kft')
ylabel('Drag, lbf')
ax = gca;
ax.YAxis.Exponent = 0;
ytickangle(45)

table(A,M,D,L)

%{

AoA = transpose(0:0.5:2);
plot(AoA,CL,'-b','LineWidth',2)
grid on
title('Total Vehicle C_L_\alpha')
xlabel('Angle of Attack, degrees')
ylabel('Section lift coefficient, C_L')
figure()

plot(AoA,CD,'-k','LineWidth',2)
grid on
title(['Tandem Vehicle Section Drag vs. AoA, ',unit])
xlabel('Angle of Attack, degrees')
ylabel('Section drag coefficient, C_D')

figure()
plot(AoA,L,'-b','LineWidth',2)
grid on
title('Total Vehicle Lift vs. AoA')
xlabel('Angle of Attack, degrees')
ylabel(['Tandem Vehicle Lift, ',unit])

figure()
plot(AoA,D,'-k','LineWidth',2)
grid on
title('Tandem Vehicle Drag vs. AoA')
xlabel('Angle of Attack, degrees')
ylabel(['Tandem Vehicle Drag, ',unit])

Drag = D;
Lift = L;

DragginDeezNutsAcrossYourFace = table(AoA,CL,Lift,CD,Drag);
DragginDeezNutsAcrossYourFace.Properties.VariableNames = {'AoA, degrees','CL',['Lift, ',unit],'CD',['Drag, ',unit]};

writetable(DragginDeezNutsAcrossYourFace,'FinalDragCalculations.xlsx','Sheet','AeroData')

ExportTable = Cruise.Data2Cell();
writecell(ExportTable,'FinalDragCalculations.xlsx','Sheet','FlightCondition')
clc

winopen('FinalDragCalculations.xlsx')
%}
% %% Data Export
% 
% FC = Cruise.Data2Cell();
% MW = MainWing.Data2Cell();
% F = Fuselage.Data2Cell();
% 
% writecell(FC,'DataDump.xlsx','Sheet','FlightCondition')
% writecell(MW,'DataDump.xlsx','Sheet','MainWing')
% writecell(F,'DataDump.xlsx','Sheet','Fuselage')

