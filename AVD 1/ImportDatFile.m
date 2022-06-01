function obj = ImportDatFile(obj,filename)
    C = readmatrix(filename);
    Cdim = size(C);
    obj.c = C(Cdim(1),1);
    dat = zeros(ceil(Cdim(1)/2),4);
    m = 2; % Column location for current y chord
    n = 1;
    for i=1:Cdim(1)
        if i == Cdim(1)
            dat(n,m-1) = C(i,1);
            dat(n,m) = C(i,2);
            break
        end
        islarger = C(i+1,1) > C(i,1);
        switch islarger
            case 1
                dat(n,m-1) = C(i,1);
                dat(n,m) = C(i,2);
                n = n + 1;
            case 0
                dat(n,m-1) = C(i,1);
                dat(n,m) = C(i,2);
                n = 1;
                m = m + 2;
        end
    end
    obj.xu = dat(:,1);
    obj.yu = dat(:,2);
    obj.xl = dat(:,3);
    obj.yl = dat(:,4);

    obj.t = max(obj.yu - obj.yl)/obj.c;

    obj.xc = dat(:,1);
    obj.yc = obj.CamberLine();
    obj.dycdx = obj.CamberLineSlope();

    [M,I] = max(obj.yc);
    
    obj.p = obj.xc(I)/obj.c;
    obj.m = M/obj.c;

    obj.e = 0.7; % This is just a shit ass assumption
    
    obj.nseg = ceil(Cdim(1)/2);

    obj.a0l = obj.Calculatea0l();
    obj.Cmac = obj.CalculateCMAC();
end