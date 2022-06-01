%% Created by Luke Patterson for Testing
clear
close all
clc

%% Define Units
unitSystem = 'SI';
%% Data Import

MainWing = WingGeometry;
MainWing = MainWing.ImportFromCell(readcell('DataDump.xlsx','Sheet','MainWing'));
MainWing = MainWing.ConvertUnits(unitSystem);

Fuselage = FuselageGeometry;
Fuselage.Name = 'Fuselage';
Fuselage = Fuselage.ImportFromCell(readcell('DataDump.xlsx','Sheet','Fuselage'));
Fuselage = Fuselage.ConvertUnits(unitSystem);

Session = struct();

WK2 = Vehicle;
WK2.Name = 'WK2';
WK2.Components.('WingGeometry1') = MainWing;
WK2.Components.('FuselageGeometry1') = Fuselage;
WK2.Components.('FuselageGeometry2') = Fuselage;
SS2 = Vehicle;
SS2.Name = 'SS2';

Session.('Vehicle0') = WK2;
Session.('Vehicle1') = SS2;

children = Session.('Vehicle0').GetChildren()