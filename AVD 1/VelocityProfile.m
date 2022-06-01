clear
close all
clc

%%Inputs everyhting is in english uunits 
%Inputs/Initialize Variables
g0=32.1741; %ft/s^2
T0=518.67; %R
rho0=0.0023769; %slug/ft^3
k=1.4;
Re=6378E3;
Re=Re*3.28;
R=1717;
i=0;
EheightM=[50:50:400].*10^3; %%% dont need to do 
Vmax=100000;
S= 1315;  %%%  
W0=64992.265;  %%% Inital wight
Th=7809.9; % lbf
Isp=344; %%%

PM=0;

%%%
%Data Henry 


%Optimal Trajectory for a given Eheight calculation
h2=[0,5,10,15,20,25,30,35,40,45,50]*10^3;
can=0;

for H=1:length(h2)  %H1=0:.1:350 for H=1:length(h2)-40
    h=h2(1,H);          %h=H1*10^3;    %h=h2(1,H);  %H=H+1;
    for Mach=0.1:0.01:1
        can=can+1;
        M=Mach;
        if h<36089
            theta=(1-h/145442);
            T=theta*T0;
            sigma=(1-h/145442)^(4.2561);
            rho=sigma*rho0;
        elseif h<=65617
            theta=(0.751865);
            T=theta*T0;
            sigma=0.297076*exp(-(h-36089)/20806);
            rho=sigma*rho0;
        elseif h<=104987
            theta=(0.682457+h/945374);
            T=theta*T0;
            sigma=(0.978261+h/659515)^(-35.16320);
            rho=sigma*rho0;  
        elseif h<=154199
            theta=0.482561+h/337634;
            T=theta*T0;
            sigma=(0.857003+h/190115)^(-13.20114);
            rho=sigma*rho0;         
        elseif h<=167232
            theta=0.939268;
            T=theta*T0;
            sigma=0.00116533*exp(-(h-154199)/25992);
            rho=sigma*rho0;
        elseif h<=232940
            theta=1.434843-h/337634;
            T=theta*T0;
            sigma=(0.798990-h/606330)^(11.20114);
            rho=sigma*rho0;
        elseif h<=278.386
            theta=1.237723-h/472687;
            T=theta*T0;
            sigma=(0.900194-h/649922)^(16.08160);
            rho=sigma*rho0;
        end
        a=sqrt(k*R*T);
        V=M*a;
        q=0.5*rho*V^2;
        
       % Aerodynamics data 
       Cdo = 0.266;
    
       % rocket propulsion
       H1=h/10^3;
%        Isp_rocket=interIsp(h); % might be H1=h/10^3. Ambiguous in Chudoba's work
       hblah = ceil(h/3.28)+1;
       [Th,mdot] = Thrust(hblah,Mach,'Imperial');
       Th = Th * 4;
       mdot = mdot * 4;
       ST = Th/mdot;
       if H==1
         W=W0;
         n=1;
         delV=0;
         t=0;
       else
         %HB=HB+1;  
         delV=V-Data2(H-1,4);
         %g=g0*(Re/(Re+h))^2;
         W=(Data2(H-1,5))/exp(delV/(g0*ST));
         Ps=(V*(Th-D))/Data2(H-1,5);
         t=((h-Data2(H-1,1)*10^3)/Ps)+Data2(H-1,9);
         %W=W0;
         %W=((Data2(H-1,5)))/(exp(delV/(g0*Isp)));
         %W=(Th/Isp_rocket)*((Data2(H-1,5))/(V*(Th-D)))*(h-Data2(H-1,1)*10^3);
         %W=2*Data2(H-1,5)-Data2(H-1,5)*exp(-(delV)/(Isp_rocket*g0));
         %W(i,j)=W(i,j-1)/(exp(V(i,j)-V(i,j-1)))/(32.2*Isp_rocket(j));
         %W=Data2(H-1,5)/(exp(delV))/(g0*Isp_rocket);
       end
       
       D=Cdo*q*S;
        RS=(ST*V*(Th-D))/(Th*W);      %this eqn with w0 works best
        %RS=(g0*Isp_rocket*(D-Th)*V)/(Th);
        %RS=1/RS;
        %mdot=Th/(Isp*g0);
        %RS=(V*(Th-D))/mdot;
        n=(Th-D-sind(10))/W;       %this eqn with W0 gives better ans       % OR 
%         n=((Th-D)/W)-sind(10);           % OR 
        %n=((Th-D)/W);
       %{
        if H==1
            n=1;
        end
        %}
        Tmax=T+0.2*T*M^2;
        AllData(can,:)=[RS M V W q n Tmax t delV h];
        if Mach < 1
            if q <=300 && n>0 && n<4 && delV>=0 Tmax<1500; %&& H1 <= 50 %300 -1000 -4
                %Change q to <=300
                PM=1+PM;
                MidData(PM,:)=[RS M V W q n Tmax t delV h];
                %{
                elseif q <=300 && Tmax<1000 && n>0 && n<4 && delV>0 && H1 > 50 && M>Data2(H-1,3)
                PM=1+PM;
                MidData(PM,:)=[RS M V W q n Tmax t delV h];
                [Value Loc]=max(MidData(:,1)); %add stop
                RSbest=MidData(Loc,1);
                Mbest=MidData(Loc,2);
                Vbest=MidData(Loc,3);
                Wbest=MidData(Loc,4);
                qbest=MidData(Loc,5);
                nbest=MidData(Loc,6);
                Tmaxbest=MidData(Loc,7);
                tbest=MidData(Loc,8);
                delVbest=MidData(Loc,9);
                Data2(H,:)=[h/10^3 RSbest Mbest Vbest Wbest qbest nbest Tmaxbest tbest delVbest];
                vpa(Data2)
                PM=0;
                can=0;
                clear MidData AllData
                break
                %}
            else
                continue
            end
        else   %add stop
            if q <=300 && n>0 && n<4 && delV>=0 Tmax<1500;
               %Change q to <=300
               PM=1+PM;
               MidData(PM,:)=[RS M V W q n Tmax t delV h];
               vpa(MidData);
               [Value Loc]=max(MidData(:,1)); %add stop
               RSbest=MidData(Loc,1);
               Mbest=MidData(Loc,2);
               Vbest=MidData(Loc,3);
               Wbest=MidData(Loc,4);
               qbest=MidData(Loc,5);
               nbest=MidData(Loc,6);
               Tmaxbest=MidData(Loc,7);
               tbest=MidData(Loc,8);
               delVbest=MidData(Loc,9);
               Data2(H,:)=[h RSbest Mbest Vbest Wbest qbest nbest Tmaxbest tbest delVbest];
               PM=0;
            end
            vpa(MidData);
            [Value Loc]=max(MidData(:,1)); %add stop
            RSbest=MidData(Loc,1);
            Mbest=MidData(Loc,2);
            Vbest=MidData(Loc,3);
            Wbest=MidData(Loc,4);
            qbest=MidData(Loc,5);
            nbest=MidData(Loc,6);
            Tmaxbest=MidData(Loc,7);
            tbest=MidData(Loc,8);
            delVbest=MidData(Loc,9);
            Data2(H,:)=[h/10^3 RSbest Mbest Vbest Wbest qbest nbest Tmaxbest tbest delVbest];
            vpa(Data2);
            PM=0;
            can=0;
            clear MidData AllData
            % if H==11;
            % delV=Data2(11,4)-Data2(1,4);
            % W=W/exp(delV/(g0*Isp));
            % end
        end
    end
end

plot(Data2(:,3),Data2(:,1),'-b','LineWidth',2)
ylabel('Altitude, ft*10^3')
xlabel('Mach')

function Ispout = interIsp(h)
RH=[0,921,2500,5000,10000,15000,20000,25000,30000,35000,36089,40000,...
    45000,50000,55000,60000,65000,65617,70000,75000,80000,85000,90000,...
    91000,96000,101000,104987,111000,121000,131000,140000,146000,150000,...
    154199,160000,170000,179200,180000,190000,200000,200131,225000,250000,...
    275000,300000,310000,320000,330000,340000,350000,375000,400000];
 
RIsp_LNG_LOX=[127.2,132.7,141.8,155.6,180.4,202.1,220.9,237.4,251.6,264,...
    266.5,274.6,283.4,290.9,297.1,302.5,307.1,307.6,311,314.5,317.5,...
    320.2,322.7,323.1,325.3,327.3,328.7,330.6,333.3,335.7,337.6,338.8,...
    339.5,340.3,341.2,342.7,343.9,344,345.2,346.4,346.4,348.8,351.4,...
    353.5,355.1,355.4,356.1,356.3,356.6,356.6,356.6,356.6];
 
 Ispout = interp1(RH,RIsp_LNG_LOX,h,'spline','extrap');    
end

%Lift and Drag coefficient estimation using MDC wind tunnel data
function [Claout,Cdoout]=interLD(M)
 
    RM=[0.252,0.291,0.375,0.461,0.470,0.478,0.773,0.953,1.018,1.090 ...
        1.168,1.228,1.349,1.521,1.716,1.935,2.182,2.463,2.502,2.775,3.123 ...
        3.514,3.953,4.448,4.526];

    RCla=[0.182,0.182,0.182,0.182,0.182,0.182,0.182,0.259,0.274,0.291 ...
        0.309,0.322,0.350,0.390,0.435,0.485,0.542,0.606,0.615,0.678,0.758 ...
        0.848,0.949,1.063,1.081];

    RCdo=[0.0220,0.0220,0.0220,0.0220,0.0220,0.0220,0.0220,0.0220 ...
          0.0280,0.0320,0.0340,0.0360,0.0354,0.0348,0.0341,0.0332  ...
          0.0323,0.0313,0.0311,0.0301,0.0288,0.0273,0.0257,0.0238,0.0235];

    Claout = interp1(RM,RCla,M,'spline','extrap');    
    Cdoout = interp1(RM,RCdo,M,'spline','extrap');  
end
