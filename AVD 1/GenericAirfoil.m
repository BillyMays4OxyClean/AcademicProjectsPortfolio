classdef GenericAirfoil
    properties
        p {mustBeNumeric}
        m {mustBeNumeric}
        t {mustBeNumeric}
        c {mustBeNumeric}
        xu {mustBeNumeric}
        xl {mustBeNumeric}
        yu {mustBeNumeric}
        yl {mustBeNumeric}
        xc {mustBeNumeric}
        yc {mustBeNumeric}
        dycdx {mustBeNumeric}
        Name string
        nseg {mustBeNumeric}
        a0l {mustBeNumeric}
        Cmac {mustBeNumeric}
        e {mustBeNumeric} % Oswald efficiency factor
        Parent
    end
    
    methods
        
        function a0l = Calculatea0l(obj)
            if mean(obj.CamberLineSlope()) == 0
                a0l = 0;
                return
            end
            
            theta = transpose(0:pi/(obj.nseg-1):pi) ;
            ex = obj.c/2*(1 - cos(theta)) ;
            dyc = diff(obj.CamberLine());
            dx = diff(ex);
            dydx = dyc./dx;
            
            theeta = transpose(0:pi/(obj.nseg-2):pi) ;
            
            integrand = -1/pi * obj.CamberLineSlope() .* (cos(theeta) - 1) ;

            a0l = integrate_simpson(integrand,0,pi,length(integrand)) ;
        end
        
        function Cmac = CalculateCMAC(obj)
            if mean(obj.CamberLineSlope()) == 0
                Cmac = 0;
                return
            end
            
            theta = transpose(0:pi/(obj.nseg-1):pi) ;
            ex = obj.c/2*(1 - cos(theta)) ;
            
            theeta = transpose(0:pi/(obj.nseg-2):pi) ;
            
            integrand = -1/pi * obj.CamberLineSlope() .* (cos(2*theeta) - cos(theeta));

            Cmac = integrate_simpson(integrand,0,pi,length(integrand)) ;
        end
        
        function C = Data2Cell(obj)
            C = DataConv(obj);
        end
        
        function file = ExportToDat(obj,name)
            file = OutputDatFile(obj,name);
        end
        
        function obj = ImportFromCell(obj,C,parent)
            if nargin == 3
                obj = Import(obj,C,parent);
            else
                obj = Import(obj,C);
            end
        end
        
        function yc = CamberLine(obj)
            if isempty(obj.yu) || isempty(obj.yl)
                error('You  need to set the airfoil surfaces before you may calculate camber line. (yu, yl, etc)')
            end
            yc = zeros(length(obj.yu),1);
            for i=1:length(obj.yu)
                yc(i,1) = mean([obj.yu(i,1) obj.yl(i,1)]);
            end
        end
        
        function dycdx = CamberLineSlope(obj)
            dyc = diff(obj.CamberLine());
            dx = diff(obj.xu);
            dycdx = vpa(dyc./dx);
            dycdx = double(dycdx);
        end
        
        function obj = ImportFromDatFile(obj,filename)
            obj = ImportDatFile(obj,filename);
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

                title(fig,obj.Name)
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

                title(obj.Name)
                xlabel('Chord length, x/c')
                ylabel('Section thickness, t/c')
                grid on
                xlim([-0.1 obj.c+0.1])
                ylim([-2*obj.t*obj.c 2*obj.t*obj.c])
            end
        end
        
    end
end

