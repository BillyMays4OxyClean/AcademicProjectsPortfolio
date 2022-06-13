%% Created by Luke Patterson 10014203030 - Heat Transfer Project 1
clear
close all
clc

%% Constant dfintions
kb = 5; % W/(m*K)
ks = 350; % W/(m*K)
kc = 150; % W/(m*K)
h = 250; % W/(m^2*K)
l = 1*10^-3; % m
% s = 3*10^-3; % m
q_dot = 2.5*10^7; % W/m^3
Tinf = 20+273; % deg K
colors = {'k','b','c','g','m','r','y','k','b','c'};
markers = {'s','s','s','s','s','s','s','o','o','o'};

%% Boundary definitions
k = 1;
step = 1; % mm delta_x and delta_y
if mod(27,step)~=0 || mod(18,step)~=0
    error('Please enter a step size divisible by 27 and 18');
end
N = 1:step:19;
M = 1:step:28;
A = zeros(length(N)*length(M),length(M)*length(N));
C = zeros(length(N)*length(M),1);
nodes_per_row = 27/step + 1;
nodes_per_column = 18/step + 1;

%% FEM Calculations
for n = 1:step:19
   for m = 1:step:28
       [a,c,type,enum] = returnA(n,m,ks,kc,kb,h,step*10^-3,Tinf,q_dot); % where a = [Tm-1,n Tm,n+1, Tm+1,n Tm,n-1 Tm,n] in a clockwise fassion

       if (a(1)==0 && a(4)==0) % if the node we are analysing is a bottom left corner node
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k) = A(k,k) + a(5);

       elseif (a(2)==0 && a(3)==0) % if the node we are analysing is a top right corner node
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       elseif (a(3)==0 && a(4)==0) % if the node we are analysing is a bottom right node
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k) = A(k,k) + a(5);

       elseif (a(1)==0 && a(2)==0) % if the node we are analysing is a top left node
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       elseif a(1)==0 && a(2)~=0 && a(3)~=0 && a(4)~=0 % if the node we are analysing is a node on the left edge
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       elseif a(2)==0 && a(1)~=0 && a(3)~=0 && a(4)~=0 % if the node we are analysing is a node on the top edge
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       elseif a(3)==0 && a(1)~=0 && a(2)~=0 && a(4)~=0 % if the node we are analysing is a node on the right edge
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       elseif a(4)==0 && a(1)~=0 && a(2)~=0 && a(3)~=0 % if the node we are analysing is a bottom node
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k) = A(k,k) + a(5);

       else % if the node we are analysing is not a node on any extremity of the board
           A(k,k-1) = A(k,k-1) + a(1);
           A(k,k+nodes_per_row) = A(k,k+nodes_per_row) + a(2);
           A(k,k+1) = A(k,k+1) + a(3);
           A(k,k-nodes_per_row) = A(k,k-nodes_per_row) + a(4);
           A(k,k) = A(k,k) + a(5);

       end

       plot(m,n,strcat(string(markers(type)),string(colors(type))),'MarkerSize',5,'MarkerFaceColor',string(colors(type)));
       text(m+.1,n+.1,string(enum));
       hold on

       C(k,1) = c;
       k = k + 1;
   end
end

% Finally calculating the Temperature distribution of the entire apparatus
% we have:

T = A\C - 273;

%% Plotting the results
[X,Y] = meshgrid(0:step:(nodes_per_row-1)*step,0:step:(nodes_per_column-1)*step);
ThreeDT = zeros(nodes_per_column,nodes_per_row);
k = 1;

for n=nodes_per_column:-1:1
    for m=nodes_per_row:-1:1
        ThreeDT(n,m) = T(k,1);
        k = k + 1;
    end
end
figure()
subplot(2,1,1);
contourf(X,Y,ThreeDT)
colorbar
xlabel('X direction, mm');
ylabel('Y direction, mm');
zlabel('Temperature, C');
title( strcat('Temperature distribution w/ step',{' '},string(step),{', '},'k_s',{' '},string(ks),{', '},'T_i_n_f',{' '},string(Tinf-273)) );
subplot(2,1,2);
surf(X,Y,ThreeDT)
colormap jet
xlabel('X direction, mm');
ylabel('Y direction, mm');
zlabel('Temperature, C');
title( strcat('Temperature distribution w/ step',{' '},string(step),{', '},'k_s',{' '},string(ks),{', '},'T_i_n_f',{' '},string(Tinf-273)) );

