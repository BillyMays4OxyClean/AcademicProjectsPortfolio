%% Created by Luke Patterson for the purposes of generating a Four-Digit NACA Cambered Airfoil Section
function Airfoil = NACA4WingSection(NACA,c,nseg,custom,e)
    % Parse the Wing section properties from the NACA Designation

    if ischar(NACA)
        if str2double(NACA)<1000
            p = 0;
            m = 0;
            t = str2double(NACA)*10^-2;
        else
            m = floor(str2double(NACA)*10^-3) * 10^-2;
            p = floor(str2double(NACA)*10^-2 - m*10^3) * 10^-1;
            t = (str2double(NACA) - (m*10^5 + p*10^3) ) * 10^-2;
        end
    elseif isa(NACA,'double') && nargin ==4
        p = NACA(1);
        m = NACA(2);
        t = NACA(3);
    end
    
    x = zeros(nseg,1);
    xu = zeros(nseg,1);
    xl = zeros(nseg,1);
    yc = zeros(nseg,1);
    dycdx = zeros(nseg,1);
    if p ~= 0 || m ~= 0
        k = 1;
        for i = 0:1/(nseg-1):1
            if i <= p
                yc(k,1) = m/p^2 * (2*p*i - (i)^2);
                dycdx(k,1) = 2*m/p^2 * (p - i);
            elseif i >= p
                yc(k,1) = m/((1-p)^2) * ((1 - 2*p) + 2*p*i - (i)^2);
                dycdx(k,1) = 2*m/(1-p)^2 * (p - i);
            end
            x(k,1) = i;
            k = k + 1;
        end
        theta = atand(dycdx);

        yt = t/0.2 * ( 0.29690*sqrt(x) - 0.12600*x - 0.35160 * x.^2 + 0.28430 * x.^3 - 0.10150 * x.^4);

        xu = x - yt.*sind(theta);
        yu = yc + yt.*cosd(theta);

        xl = x + yt.*sind(theta);
        yl = yc - yt.*cosd(theta);
    else
        x = transpose(0:c/(nseg-1):c);
        
        yt = t/0.2 * ( 0.29690*sqrt(x) - 0.12600*x - 0.35160 * x.^2 + 0.28430 * x.^3 - 0.10150 * x.^4);
        
        yu = yt;
        yl = -yt;
        
        xu = x;
        xl = x;
    end
    
    if nargin == 4
        fprintf('Outputting a Custom NACA 4 Wing Section')
    else
        NACUh = NACA;
        airfoil = cellstr(strcat({'Outputing a NACA'},{' '},NACUh,{' '},{'Wing Section\n'}));
        airfoil = string(airfoil);
        fprintf(airfoil)
    end
    
    x = x * c;
    xu = xu * c;
    xl = xl * c;
    yu = yu * c;
    yl = yl * c;
    yc = yc * c;
    xc = transpose(0:c/(nseg-1):c);

    Airfoil = NACA4;
    Airfoil.x = x;
    Airfoil.xu = xu;
    Airfoil.xl = xl;
    Airfoil.yu = yu;
    Airfoil.yl = yl;
    Airfoil.yc = yc;
    Airfoil.xc = xc;
    Airfoil.c = c;
    Airfoil.p = p;
    Airfoil.m = m;
    Airfoil.t = t;
    if nargin == 4
        Airfoil.Name = 'CustomFoil';
    elseif nargin == 5
        Airfoil.e = e;
    else
        Airfoil.Name = NACUh;
        Airfoil.e = 0.7;
    end
    Airfoil.nseg = nseg;
    Airfoil.a0l = Airfoil.Calculatea0l();
    Airfoil.Cmac = Airfoil.CalculateCMAC();
    Airfoil.r = 1.1019*t^2;
end