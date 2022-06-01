%% Created by Luke Patterson for the analysis of the Boeing 747 during cruise
clear
close all
clc

%% Unit Definition
unitSystem = 'FPS';

%% Geometry Definitions for the Boeing 747
MainWing = WingGeometry;
MainWing.S = 550.36;
MainWing.b = 195.66929;
MainWing.Rc = 47.24409;
MainWing.Tc = 13.32021;

bac = GenericAirfoil;
bac = bac.ImportFromDatFile('bacxxx.txt');

MainWing.RootAirfoil = bac;
MainWing.TipAirfoil = bac;
MainWing.Taper = 0.2819;
MainWing.AR = 6.9607;
MainWing.MAC = 33.4491;
MainWing.meanThicc = 0.1981;
MainWing.Sweep = 38.8596;
MainWing.Swet = 11332.944;
MainWing.Se = 5399.1;
MainWing.Kw = 2.0604;
MainWing.V = 1950.2;
MainWing.Units = 'FPS';
MainWing.Name = "Main Wing";
MainWing = MainWing.ConvertUnits(unitSystem);
exp2Excel = MainWing.Data2Cell();
writecell(exp2Excel,'B747Geometry.xlsx','Sheet','MainWing');

Fuselage = FuselageGeometry;
Fuselage.SlendernessRatio = 0.0479;
Fuselage.FinenessRatio = 10.5548;
Fuselage.e = 1.5072;
Fuselage.MaxDiameter = 21.333;
Fuselage.BaseDiameter = 7.5;
Fuselage.Sb = pi/4 * Fuselage.MaxDiameter^2;
Fuselage.L = 225.166;
Fuselage.W = 21.333;
Fuselage.H = 32.1522;
Fuselage.Swet = 14787.8356;
Fuselage.V = 65231;
Fuselage.Units = 'FPS';
Fuselage.Name = "Fuselage";
Fuselage = Fuselage.ConvertUnits(unitSystem);
exp2Excel = MainWing.Data2Cell();
writecell(exp2Excel,'B747Geometry.xlsx','Sheet','Fuselage');

HT = WingGeometry;
HT.b = 72.73;
HT.Rc = 31.56168;
HT.Tc = 8.39895;
HT.RootAirfoil = NACA4WingSection('0012',HT.Rc,128);
HT.TipAirfoil = NACA4WingSection('0012',HT.Tc,128);
HT.AR = 3.6389;
HT.Sweep = 34.2025;
HT.MAC = 22.218;
HT.Swet = 3110.3;
HT.Se = 1493.4;
HT.S = 1453;
HT.Units = 'FPS';
HT.Name = "Horizontal Stabilizer";
HT = HT.ConvertUnits(unitSystem);
exp2Excel = HT.Data2Cell();
writecell(exp2Excel,'B747Geometry.xlsx','Sheet','HT');

VT = WingGeometry;
VT.S = 1051.957;
VT.b = 38.05774;
VT.Rc = 42.6509;
VT.Tc = 12.63123;
VT.RootAirfoil = NACA4WingSection('0012',VT.Rc,128);
VT.TipAirfoil = NACA4WingSection('0012',VT.Tc,128);
VT.Taper = 0.2961;
VT.AR = 1.3768;
VT.Sweep = 45;
VT.meanThicc = 0.2375;
VT.MAC = 30.358;
VT.Swet = 2228.8;
VT.Se = 1051.957;
VT.Units = 'FPS';
VT.Name = "Vertical Stabilizer";
VT = VT.ConvertUnits(unitSystem);
exp2Excel = MainWing.Data2Cell();
writecell(exp2Excel,'B747Geometry.xlsx','Sheet','VT');

B747 = Vehicle;
B747.Components.MainWing = MainWing;
B747.Components.Fuselage = Fuselage;
B747.Components.Fuselage2 = Fuselage;
B747.Components.VT = VT;
B747.Components.HT = HT;

B747.Export2Excel("B747.xlsx")

%% Flight Condition
AoA_f = 15;
AoA = 0:AoA_f;

begin = FlightCondition;
begin.Altitude = 35105; % Altitude in feet, condition for cruise is 35kft.
begin.Units = 'FPS';
begin = begin.SetSpeed('V',850.7); % Takeoff velocity in ft/s
begin = begin.ConvertUnits(unitSystem);
begin.Name = 'Takeoff';