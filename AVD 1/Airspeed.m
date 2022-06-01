classdef Airspeed
    properties
        Mach {mustBeNumeric}
        V {mustBeNumeric}
        q {mustBeNumeric}
        Name string
        Units string
        Parent
    end
    
    methods
        
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
        
        function [field,prop,len] = ReturnFieldsNProperties(obj)
            field = fieldnames(obj);
            len = length(field);
            prop = cell(len,1);
            for i=1:len
                prop{i,1} = obj.(field{i,1});
            end
        end
        
        function obj = Set(obj,prop,val)
            if strcmp(prop,'Mach')
                obj.Mach = val;
                obj.V = val .* obj.Parent.Atmosphere.a;
                if strcmp(obj.Units,'SI')
                    obj.q = 1/2 .* obj.Parent.Atmosphere.rho .* obj.V.^2;
                elseif strcmp(obj.Units,'FPS')
                    obj.q = 1/2 .* obj.Parent.Atmosphere.rho .* obj.V.^2 / 32.2;
                end
                obj.Name = obj.Parent.Name;
            elseif strcmp(prop,'V')
                obj.V = val;
                obj.Mach = val ./ obj.Parent.Atmosphere.a;
                if strcmp(obj.Units,'SI')
                    obj.q = 1/2 .* obj.Parent.Atmosphere.rho .* obj.V.^2;
                elseif strcmp(obj.Units,'FPS')
                    obj.q = 1/2 .* obj.Parent.Atmosphere.rho .* obj.V.^2 / 32.2;
                end
                obj.Name = obj.Parent.Name;
            end
        end
        function obj = ConvertUnits(obj,unitSystem)
            if strcmp(unitSystem,'FPS')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in FPS. No action was taken.\n')
                    return
                end
                obj.V = obj.V .* 3.28; % m/s to ft/s by m/s * 3.28 ft/m
                obj.q = obj.q .* 2.2/(3.28 * 32.2);
                obj.Units = 'FPS';
            elseif strcmp(unitSystem,'SI')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in SI. No action was taken.\n')
                    return
                end
                obj.V = obj.V ./ 3.28; % ft/s to m/s by m/s / 3.28 ft/m
                obj.q = obj.q .* 32.2*3.28/2.2;
                obj.Units = 'SI';
            end
        end
    end
end