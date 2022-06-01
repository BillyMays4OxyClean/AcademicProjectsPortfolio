%% Created by Luke Patterson for Aerospace Vehicle Design 1
clear
close all
clc

%% Givens
% Wing Planform Area
S = 1415; % sq. ft
S = S / (3.28)^2 ; % sq. meters

% US Standard Atmosphere
[ATM,ATMe] = StandardATM(15200); % Return atmospheric data up until 15,200 meters
Altitude = ATM(:,1);
T_atm = ATM(:,2);
P_atm = ATM(:,3);
Rho_atm = ATM(:,4);
SoS_atm = ATM(:,5);

