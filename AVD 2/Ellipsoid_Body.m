%% Created by Luke Patterson for an Elliptical Lifting-Body Geometric definition to be used for the aerodynamics discipline
classdef Ellipsoid_Body
    properties
        fatness_ratio {mustBeNumeric} % Spi/Sref
        forebody_location {mustBeNumeric} %lpi/l, ratio of forebody length and body length
        e {mustBeNumeric} % Eccentricity
        Sweep {mustBeNumeric} % Delta Wing Sweep, self explanatory
        length {mustBeNumeric} % Body length
        width {mustBeNumeric} % Body span
        hight {mustBeNumeric} % Body height
        AR {mustBeNumeric} % Aspect ratio
        tau {mustBeNumeric} % Kuchemann's Tau ratio
        Vol {mustBeNumeric} % Body Volume
        Kw {mustBeNumeric} % Sw/Sref
        Sref {mustBeNumeric} % Planform area
        Swet {mustBeNumeric} % Wetted area
        Mesh % 3D Mesh to define the body
        PerpMesh % 3D Mesh parallel to flow
        nseg {mustBeNumeric}
        Name string % Name of the body
        Units string % Units, either SI or FPS (Feet, Pound, Second)
    end
    
    methods
        
        function C = Data2Cell(obj)
            C = DataConv(obj);
        end
        
        function ExportAsObj(obj,filename)
            if isempty(obj.Mesh)
                obj = obj.GenerateMesh();
            end
            
            file = fopen(strcat(string(pwd),"/",filename,".obj"),'w');
            
            XDim = size(obj.Mesh.X);
            r = XDim(1);
            c = XDim(2);
            
            for x = 1:c
                for y = 1:r
                    X = obj.Mesh.X(x,y);
                    Y = obj.Mesh.Y(x,y);
                    z = obj.Mesh.Zup(x,y);
                    fprintf(file,'v %f %f %f\n',X,Y,z);
                    z = obj.Mesh.Zdown(x,y);
                    fprintf(file,'v %f %f %f\n',X,Y,z);
                end
            end
            
            fclose(file);
        end
        
        function obj = ImportFromCell(obj,C,parent)
            if nargin == 3
                obj = Import(obj,C,parent);
            else
                obj = Import(obj,C);
            end
        end
        
        function [field,prop,len] = ReturnFieldsNProperties(obj)
            field = fieldnames(obj);
            len = length(field);
            prop = cell(len,1);
            for i=1:len
                prop{i,1} = obj.(field{i,1});
            end
        end
        
        function fig = Plot(obj,perp)
            
            if isempty(obj.Mesh)
                obj = obj.GenerateMesh();
            end
            
            X = obj.Mesh.X;
            Y = obj.Mesh.Y;
            zup = obj.Mesh.Zup;
            zdown = obj.Mesh.Zdown;
            
            if nargin == 2
                X = perp.X;
                Y = perp.Y;
                zup = perp.Zup;
                zdown = perp.Zdown;
            end
            
            % Plotting an ellipse at each length value
            fig = figure();
            units = "";
            if strcmp(obj.Units,'SI')
                units = "m";
            elseif strcmp(obj.Units,'FPS')
                units = "ft";
            end
            surfl(X,Y,zup)
            hold on
            surfl(X,Y,zdown)
            colormap(gray)
            shading interp
            set(gca,'ydir','reverse')
            xlabel("Span, "+units)
            ylabel("Chord, "+units)
            zlabel("Body Height, "+units)
            xlim([-ceil(obj.length/2) ceil(obj.length/2)])
            ylim([0 ceil(obj.length)])
            zlim([-ceil(obj.length/2) ceil(obj.length/2)])
            title('Full Ellipse Body')
            
        end
        
        function obj = Generate_Ellipsoid_Body(obj,Sref,tau,sweep,lpil)
            cs = 0; % There is no interspatular distance for an elliptical all-body config.
            Ks = 0.2413;
            l = sqrt(Sref*tand(sweep)/(1+cs));
            s = l/tand(sweep);
            c = cs*s;
            b = 2*s+c;
            
            E = tau/0.483;
            
            
            a = s;
            api = lpil*l*cotd(sweep);
            Spi = pi*api^2*E;
            R = (1-E)/(1+E);
            Sw = pi*a^2*(1+E)/cosd(sweep)*(1 + R^2/4 + R^4/64 + R^6/256) + pi*R^2*E;
            
            if cs>0
                Kdub = Sw/Sref*(1+cs*Ks/(1+cs));
            else
                Kdub = Sw/Sref;
            end
            
            Vtot = pi*a^3*E/3*tand(sweep);
            
            obj.fatness_ratio = Spi/Sref;
            obj.forebody_location = lpil;
            obj.e = E;
            obj.Sweep = sweep;
            obj.length = l;
            obj.width = b;
            obj.AR = b^2/Sref;
            obj.tau = tau;
            obj.Vol = Vtot;
            obj.Kw = Kdub;
            obj.Sref = Sref;
            obj.Swet = Sw;
            
        end
        
        function [CL,L] = CalculateLift(obj,fc)
            
            beta = sqrt(abs(fc.AirSpeed.Mach^2 - 1));
            
            
            if fc.AirSpeed.Mach <= 1
                C1 = pi*obj.AR/2 - 0.355 * beta^(0.45) * obj.AR^(1.45);
                C2 = 0;
            elseif fc.AirSpeed.Mach > 1 && beta < 4/obj.AR
                C1 = pi*obj.AR/2 - 0.153*beta*obj.AR^2;
                beeta = [0 4/obj.AR];
                c2 = [0 exp(0.955 - 4.35/fc.AirSpeed.Mach)];
                C2 = interp1(beeta,c2,beta);
            elseif fc.AirSpeed.Mach > 1 && beta >= 4/obj.AR
                C1 = 4.17/beta - 0.13;
                C2 = exp(0.955 - 4.35/fc.AirSpeed.Mach);
            end
            
            CL = C1*sind(fc.AoA)+C2*sind(fc.AoA)^2;
            L = CL * fc.AirSpeed.q * obj.Sref;
            
            
        end
        
        
        
        function [CD,D,CDi,CdOB] = CalculateDrag(obj,fc)
            % Wave drag
            M = fc.AirSpeed.Mach;
            
            if M > 1
                CDBB = 1/(0.91*M^2 - 0.2*M + 1.51);
            else
                CDBB = 0;
            end
            % Induced Drag
            
            if fc.AirSpeed.Mach >= 3
                Km = 0.25*(1 + fc.AirSpeed.Mach);
            elseif fc.AirSpeed.Mach < 3
                Km = 1.0;
            end
            
            [CL,~] = CalculateLift(obj,fc);
            
            CDi = Km*CL*tand(fc.AoA);
            
            % Zero lift drag: CdOB = CDpB + CDFB + CDBB
            % Pressure drag
            if M >= 1.2
                lpi = obj.forebody_location * obj.length;
                api = lpi*cotd(obj.Sweep);
                bpi = obj.e * api;
                
                thetaf = atan(bpi/lpi);
                thetaa = atan(bpi/(obj.length-lpi));
                
                Cpuf = 2*thetaf/sqrt(M^2-1);
                Cpua = -2*thetaa/sqrt(M^2-1);
                
                Cplf = -Cpuf;
                Cpla = -Cpua;
                
                Cd1 = Cpuf * obj.fatness_ratio * obj.Sref / (2 * obj.fatness_ratio * obj.Sref);
                Cd2 = Cpua * obj.fatness_ratio * obj.Sref / (2 * obj.fatness_ratio * obj.Sref);
                Cd3 = Cplf * obj.fatness_ratio * obj.Sref / (2 * obj.fatness_ratio * obj.Sref);
                Cd4 = Cpua * obj.fatness_ratio * obj.Sref / (2 * obj.fatness_ratio * obj.Sref);
                
                CDpB = abs(Cd1 + Cd2 + Cd3 + Cd4)/2;
            end
            CDpB = 0;
            
            % Body friction drag
            tcBod = 2*obj.forebody_location*obj.e/tand(obj.Sweep);
            
            b = obj.width;
            l = obj.length;
            
            mac = tand(obj.Sweep)^2*b^2/(12*l);
            
            Re = fc.Atmosphere.rho*fc.AirSpeed.V*mac/fc.Atmosphere.mu;
            y = 1.4;
            
            if M <= 0.8
                CDFB = 0.455*(1 + 2*tcBod)*(obj.Swet/obj.Sref)/(log10(Re)^(2.58)*(1 + (y - 1)/2*M^2)^(0.467));
            elseif (0.8 < M) && (M < 1.2)
                CDFB = 0.05;
            elseif 1.2 <= M
                CDFi = 0.44/(log10(Re)^(2.58));
                Cf = CDFi/((1 + 0.144*M^2)^(0.65));
                CDFB = Cf*obj.Swet/obj.Sref;
            end
            
            CdOB = CDpB + CDFB + CDBB;
            
            CD = CdOB + CDi;
            
            D = CD * fc.AirSpeed.q * obj.Sref;
            
        end
        
        function obj = GenerateMesh(obj)
            if isempty(obj.nseg)
                obj.nseg = 32;
            end
            neg = obj.nseg;
            l=obj.length;
            lpi = obj.forebody_location*l;
            m = 1;
            
            X = zeros(neg,neg);
            Y = zeros(neg,neg);
            zup = zeros(neg,neg);
            zdown = zeros(neg,neg);
            
            for li = 0:l/(neg-1):l
                
                a = (l-li)*cotd(obj.Sweep);
                if li/l <= (1-obj.forebody_location)
                    b = li*obj.e*lpi*cotd(obj.Sweep)/(l-lpi);
                elseif li/l > (1-obj.forebody_location)
                    b = obj.e*a;
                end
                
                n = 1;
                
                for x = -a:(2*a)/(neg-1):a
                    X(n,m) = x;
                    Y(n,m) = li;
                    if b^2*(1-x^2/a^2) < 0
                        zup(n,m) = 0;
                        zdown(n,m) = 0;
                    else
                        zup(n,m) = sqrt(b^2*(1-x^2/a^2));
                        zdown(n,m) = -sqrt(b^2*(1-x^2/a^2));
                    end
                    n = n + 1;
                end
                if a==0
                    X(:,m) = a;
                    Y(:,m) = li;
                    zup(n,m) = 0;
                    zdown(n,m) = 0;
                end
                m = m + 1;
            end
            
            obj.Mesh.X = X;
            obj.Mesh.Y = Y;
            obj.Mesh.Zup = zup;
            obj.Mesh.Zdown = zdown;
            
        end
        
        function obj = GeneratePerpMesh(obj)
            if isempty(obj.nseg)
                obj.nseg = 32;
            end
            neg = obj.nseg;
            ni = neg;
            w=obj.width;
            l = obj.length;
            lpi = obj.forebody_location*l;
            m = 1;
            
            X = zeros(neg,neg);
            Y = zeros(neg,neg);
            zup = zeros(neg,neg);
            zdown = zeros(neg,neg);
            h = w/2;
            k = 0;
            
            for si = 0:w/(neg-1):w
                if si/w <= 0.5
                    c = si*tand(obj.Sweep);
%                     ni = floor(c/l*neg);
                elseif si/w > 0.5
                    c = (w-si)*tand(obj.Sweep);
%                     ni = floor(c/l*neg);
                end
                n = 1;
                for ci = 0:c/(ni-1):c
                    X(n,m) = si;
                    Y(n,m) = ci;
                    if ci/l < (1-obj.forebody_location)
                        a = (l-ci)*cotd(obj.Sweep);
                        b = ci*obj.e*lpi*cotd(obj.Sweep)/(l-lpi);
                    elseif ci/l >= (1-obj.forebody_location)
                        a = (l-ci)*cotd(obj.Sweep);
                        b = obj.e*a;
                    end
                    if b^2*(1-(si-h)^2/a^2) < 0
                        zup(n,m) = 0;
                        zdown(n,m) = 0;
                    else
                        zup(n,m) = sqrt(b^2*(1-(si-h)^2/a^2))+k;
                        zdown(n,m) = -sqrt(b^2*(1-(si-h)^2/a^2))+k;
                    end
                    n = n + 1;
                end
                m = m + 1;
            end
            
            obj.PerpMesh.X = X;
            obj.PerpMesh.Y = Y;
            obj.PerpMesh.Zup = zup;
            obj.PerpMesh.Zdown = zdown;
        end
    end
end
