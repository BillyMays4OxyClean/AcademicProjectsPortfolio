function NACA = Specs2NACA(m,p,t)

    ms = string(m*100);
    ps = string(p*10);
    ts = string(t*100);
    if t < 0.1
        ts = string(strcat('0',ts));
    end
    NACA = strcat(ms,ps,ts);

end