function [m,p,t] = NACA2Specs(NACA)
    if str2double(NACA)<1000
        p = 0;
        m = 0;
        t = str2double(NACA)*10^-2;
    else
        m = floor(str2double(NACA)*10^-3) * 10^-2;
        p = floor(str2double(NACA)*10^-2 - m*10^3) * 10^-1;
        t = (str2double(NACA) - (m*10^5 + p*10^3) ) * 10^-2;
    end
end

