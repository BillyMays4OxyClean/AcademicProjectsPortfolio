%% Created by Luke Patterson for the experementation of classdef data export to an Excel file
%% Creative Commons License: CC BY-NC

clear
close all
clc

%% Filename

unitSystem = 'SI';

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

[cell,file] = Export2Excel(MainWing,string(strcat('MainWing-',datetime)));

function [cell,file] = Export2Excel(C,filename,r,c,cellOnly)
    if nargin == 1
        datetime.setDefaultFormats('default',"yyyy-MM-dd-hh:mm:ss")
        filename = string(strcat('Class2Excel-Export-',datetime));
        datetime.setDefaultFormats('reset')
    elseif nargin == 2
        r = 1;
        c = 1;
    elseif nargin == 5
        
    end
    
    n = fieldnames(C);
    for i=1:length(n)
        m{i,1} = cell.(n{i});
    end
    cell{:,c} = n;
    cell{:,c+1} = m;
    writecell(C,filename,'Sheet');
end

function cell = Class2Cell(Class)
    dim = size(C);
    x = dim(1);
    y = dim(2);
end

