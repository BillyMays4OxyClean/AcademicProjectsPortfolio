function [T,mdot] = Thrust(alt,M0,unitSystem)
    [ATMOm,~] = StandardATM(alt);

    Altitude=ATMOm(:,1);
    P=ATMOm(:,3);
    T=ATMOm(:,2);
    p=ATMOm(:,4);
    a0=ATMOm(:,5);

    % T=217;
    % p=1.125;
    % a0=344;

    %AE3007A1 Engine%
    %inputs%
    T0=216.7;
    y=1.4;
    cp=1004;
    hpr=42800000; %70000
    Tt4=1800; %2400
    prc3=18;
    prf3=1.7;
    %M0=.215;
    a3=4.1;
    gc=1;
    A3=1.299;
    
    R3=(y-1)/y*cp;
    tr3=1+(y-1)/2*M0.^2;
    tv3=Tt4/T0;
    tc3=prc3^((y-1)/y);
    tf3=prf3^((y-1)/y);
    v9a03=sqrt(2/(y-1)*(tv3-tr3*(tc3-1+a3*(tf3-1))-tv3./(tr3*tc3)));
    v93=v9a03.*a0;
    v19a03=sqrt(2/(y-1).*(tr3*tf3-1));
    v193=v19a03.*a0;
    V3=M0.*a0;
    mair3=p.*V3*A3;
    mc3=mair3./(1+a3);
    mf3=mair3-mc3;


    %thrust%
    T=mc3/gc.*(v93-V3)+mf3/gc.*(v193-V3)/10;
    mdot = mair3;
    
    if strcmp(unitSystem,'Imperial')
        T = T * 2.2 * 3.28 / 32.2;
        mdot = mdot * 2.2;
    end
    
end

