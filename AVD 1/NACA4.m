%% Airfoil Class Experimentation
classdef NACA4
    properties
        p {mustBeNumeric}
        m {mustBeNumeric}
        t {mustBeNumeric}
        c {mustBeNumeric}
        x {mustBeNumeric}
        xu {mustBeNumeric}
        xl {mustBeNumeric}
        xc {mustBeNumeric}
        yu {mustBeNumeric}
        yl {mustBeNumeric}
        yc {mustBeNumeric}
        Name string
        nseg {mustBeNumeric}
        a0l {mustBeNumeric}
        Cmac {mustBeNumeric}
        e {mustBeNumeric} % Oswald efficiency factor
        r {mustBeNumeric}
        Parent
    end
    methods
        
        function a0l = Calculatea0l(obj)
            if obj.m == 0
                a0l = 0;
                return
            end
            f = @obj.MeanSlope;
            theta = transpose(0:pi/(obj.nseg-1):pi) ;
            ex = transpose(obj.c/2*(1 - cos(theta))) ;
            dydx = zeros(length(ex),1);

            for i = 1:length(ex)
                dydx(i) = f(ex(i));
            end

            integrand = -1/pi * dydx .* (cos(theta) - 1) ;

            a0l = integrate_simpson(integrand,0,pi,128) ;
        end
        
        function Cmac = CalculateCMAC(obj)
            if obj.m == 0
                Cmac = 0;
                return
            end
            f = @obj.MeanSlope;
            theta = transpose(0:pi/(obj.nseg-1):pi) ;
            ex = transpose(obj.c/2*(1 - cos(theta))) ;
            dydx = zeros(length(ex),1);

            for i = 1:length(ex)
                dydx(i) = f(ex(i));
            end

            integrand = -1/2 * dydx .* (cos(2*theta) - cos(theta));

            Cmac = integrate_simpson(integrand,0,pi,128) ;
        end
        
        function C = Data2Cell(obj)
            C = DataConv(obj);
        end
        
        function obj = ImportFromCell(obj,C,parent)
            if nargin == 3
                obj = Import(obj,C,parent);
            else
                obj = Import(obj,C);
            end
        end
        
        function dycdx = MeanSlope(obj,x)
            if x/obj.c <= obj.p
                dycdx = 2*obj.m/obj.p^2 * (obj.p - x/obj.c);
            elseif x/obj.c >= obj.p
                dycdx = 2*obj.m/(1-obj.p)^2 * (obj.p - x/obj.c);
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
        
        function PlotFoil(obj,fig)
            if nargin == 2
                plot(fig,obj.xc,obj.yc,'-.b')
                hold(fig,'on')
                plot(fig,obj.xl,obj.yl,'-k')
                plot(fig,obj.xu,obj.yu,'-k')

                title(fig,['NACA ',obj.Name])
                xlabel(fig,'Chord length, x/c')
                ylabel(fig,'Section thickness, t/c')
                grid(fig,'on')
                xlim(fig,[-0.1 obj.c+0.1])
                ylim(fig,[-2*obj.t*obj.c 2*obj.t*obj.c])
            elseif nargin == 1
                plot(obj.xc,obj.yc,'-.b')
                hold on
                plot(obj.xl,obj.yl,'-k')
                plot(obj.xu,obj.yu,'-k')

                title(['NACA ',obj.Name])
                xlabel('Chord length, x/c')
                ylabel('Section thickness, t/c')
                grid on
                xlim([-0.1 obj.c+0.1])
                ylim([-2*obj.t*obj.c 2*obj.t*obj.c])
            end
        end
    end
end