%% Created by Luke Patterson for SiaA Sub-Orbitals Senior Design Project
clear
close all
clc

%% Finite Wing Calculations for CL and CD
b = 141.0833; % Wingspan in feet
Swet = 2132.6; % square feet
Sref = 1315.3; % square feet
AR = b^2/Sref;
M = 0.55;

B = sqrt(1 - M^2);
delta = 0;
CLa = 2*pi*AR/( 2 + sqrt( 4 + AR^2*B^2*(1 + (tan(delta)^2/B^2))  )) ;
