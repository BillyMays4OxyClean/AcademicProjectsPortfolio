
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

unitSystem = 'SI';

Cruise = FlightCondition;
Cruise.Altitude = 15244; % Altitude in meters
% (0:5:50) * 10^3/3.28
% 0.15:(0.45-0.15)/10:0.45
Cruise.Units = 'SI';
Cruise.Name = 'Cruise';
Cruise.AoA = 1.5;
Cruise = Cruise.SetSpeed('Mach',0.55);
Cruise = Cruise.ConvertUnits(unitSystem);

rho = Cruise.Atmosphere.rho;
a = Cruise.Atmosphere.a;
M = Cruise.AirSpeed.Mach;
mu = Cruise.Atmosphere.mu;
V = Cruise.AirSpeed.V;

%% Geometry Definitions

MainWing = WingGeometry;
MainWing.Name = 'Main Wing';
MainWing.b = 141.0833;
MainWing.Rc = 10.3937;
MainWing.RootAirfoil = NACA4WingSection('2421',MainWing.Rc,128);
MainWing.RootAirfoil.Parent = MainWing;
MainWing.Tc = 5.1968;
MainWing.TipAirfoil = NACA4WingSection('2309',MainWing.Tc,128);
MainWing.TipAirfoil.Parent = MainWing;
MainWing.Taper = 0.5;
MainWing.AR = 15.1365;
MainWing.MAC = 8.084;
MainWing.Sweep = 0;
MainWing.Swet = 2141.3;
MainWing.Se = 1041.3;
MainWing.S = 1316.882;
MainWing.V = 2573;
MainWing.Units = 'FPS';
MainWing = MainWing.ConvertUnits(unitSystem);

HT = WingGeometry;
HT = HT.ImportFromCell(readcell('DataDump.xlsx','Sheet','HT'));
HT = HT.ConvertUnits(unitSystem);

VT = WingGeometry;
VT = VT.ImportFromCell(readcell('DataDump.xlsx','Sheet','VT'));
VT = VT.ConvertUnits(unitSystem);

Fuselage = FuselageGeometry;
Fuselage = Fuselage.ImportFromCell(readcell('DataDump.xlsx','Sheet','Fuselage'));
Fuselage.Units = 'FPS';
Fuselage = Fuselage.ConvertUnits(unitSystem);

SS2 = WingGeometry;
SS2.S = 47.63;
SS2.Units = 'SI';
SS2 = SS2.ConvertUnits(unitSystem);

%% Drag Coefficient Calculations for sub-sonic wings and bodies

CLw = @(AoA) 6.4247*(deg2rad(AoA)+0.0363);

AoA = Cruise.AoA;

CDMainWing = WingDrag(MainWing,M,rho,mu,V,CLw,AoA);

CDFuselage = BodyDrag(Fuselage,rho,V,mu);

CLHT = @(AoA) FWCLa(M,VT.AR,VT.Sweep)*deg2rad(AoA);
CDHT = WingDrag(HT,M,rho,mu,V,CLHT,AoA);

CLVT = @(AoA) FWCLa(M,VT.AR,VT.Sweep)*deg2rad(AoA);
CDVT = WingDrag(VT,M,rho,mu,V,CLVT,AoA);

CDSS2 = 0.0314;

Sreff = MainWing.S;

CD = CDMainWing + 2*CDFuselage*Fuselage.Sb/Fuselage.Swet + CDSS2*SS2.S/Sreff + CDHT*HT.S/Sreff + CDVT*VT.S/Sreff;

D = Cruise.AirSpeed.q*Sreff*(CDMainWing + 2*CDFuselage*Fuselage.Sb/Sreff + CDSS2*SS2.S/Sreff + CDHT*HT.S/Sreff + CDVT*VT.S/Sreff);

L = Cruise.AirSpeed.q*(CLw(AoA)*MainWing.S + 2*CLHT(AoA)*HT.S);

n = L/W2(1);

if strcmp(unitSystem,'SI')
    unit = 'Newtons';
elseif strcmp(unitSystem,'FPS')
    unit = 'Pounds';
end

fprintf('WhiteKnight Two drag during M = %.3f @ AoA = %.1f is %.2f %s\n',M,AoA,D,unit)
fprintf('WhiteKnight Two lift during M = %.3f @ AoA = %.1f is %.2f %s\n',M,AoA,L,unit)
fprintf('WhiteKnight Two load factor during M = %.3f @ AoA = %.1f is %.2f %s\n',M,AoA,L,unit)


%% Data Export

FC = Cruise.Data2Cell();
MW = MainWing.Data2Cell();
F = Fuselage.Data2Cell();

writecell(FC,'DataDump.xlsx','Sheet','FlightCondition')
writecell(MW,'DataDump.xlsx','Sheet','MainWing')
writecell(F,'DataDump.xlsx','Sheet','Fuselage')

%% Drag Functions
function CDWing = WingDrag(Wing,Mach,rho,mu,V,CLw,AoA)
    tc = Wing.RootAirfoil.t;
    xc = Wing.RootAirfoil.p;
    Swet = Wing.Swet;
    Sref = Wing.S;
    sweep = Wing.Sweep;
    cmac = Wing.MAC;
    AR = Wing.AR;
    e = 0.7;
    Cf = frictionCoefficient(rho,V,cmac,mu);
    L = thiccParameter(xc);
    R = LiftingSurfaceCorrelationFactor(sweep,Mach);
    CD0Wing = Cf*(1 + L*tc + 100*tc^4 ) * R * Swet / Sref;
    CDLWing = CLw(AoA)^2/(pi*AR*e);
    CDWing = CD0Wing + CDLWing;
end

function R = LiftingSurfaceCorrelationFactor(sweep,Mach)
    % Until the process is developed from DATC0M, 1.146 will be used. This
    % assumes Mach = 0.55 and sweep is 0 degrees.
    peTransonic = @(M) abs(0.6-M)/M;
    peSubSonic = @(M) abs(0.25-M)/M;
    
    if peTransonic(Mach) > peSubSonic(Mach)
        R = 1.065;
    else
        R = 1.146;
    end
end

function L = thiccParameter(xc)
    if xc >= 0.3
        L  = 1.2;
    elseif xc <= 0.3
        L = 2.0;
    end
end

function CD0Body = BodyDrag(body,rho,V,mu)
    Cf = frictionCoefficient(rho,V,body.MaxDiameter,mu);
    CDf = Cf*(1 + 60/(body.FinenessRatio)^3 + 0.0025*(body.FinenessRatio) ) * body.Swet/body.Sb;
    CDb = 0.029 * (body.BaseDiameter/body.MaxDiameter)^3/sqrt(CDf);
    CD0Body = CDf + CDb;
end

function Cf = frictionCoefficient(rho,V,cmac,mu)
    Re = rho*V*cmac/mu;
    if Re < 5*10^5
        Cf = 1.328/sqrt(Re);
    elseif Re > 5*10^5
        Cf = 0.455/((log10(Re))^2.58);
    end
end

function CLa = FWCLa(M0,AR,delta)
    B = sqrt(1 - M0^2);
    CLa = 2*pi*AR/(2+sqrt(4+AR^2*B^2*(1+(tand(delta)^2/B^2)) ));
end