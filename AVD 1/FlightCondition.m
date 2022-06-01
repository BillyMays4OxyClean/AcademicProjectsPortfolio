classdef FlightCondition
    properties
        AirSpeed 
        Altitude {mustBeNumeric}
        Atmosphere
        AoA {mustBeNumeric}
        Name string
        Units string
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
        
        function obj = CalculateAtmosphericProperties(obj)
            if strcmp(obj.Units,'SI')
                units = 1;
                alt = obj.Altitude/1000;
            elseif strcmp(obj.Units,'FPS')
                alt = obj.Altitude / (3.28 * 1000);
                units = 2;
            end
            uNatz={'SI','FPS'};
            for i=1:length(alt)
                [~, ~, ~, T, P, rho, a, ~, mu, nu, ~, ~, ~] = atmo(alt(i),1,units);
                obj.Atmosphere = Atm;
                obj.Atmosphere.Units = string(uNatz{units});
                obj.Atmosphere.Name = obj.Name;
                obj.Atmosphere.T(i) = T(length(T),1);
                obj.Atmosphere.P(i) = P(length(P),1);
                obj.Atmosphere.rho(i) = rho(length(rho),1);
                obj.Atmosphere.mu(i) = mu(length(mu),1);
                obj.Atmosphere.nu(i) = nu(length(nu),1);
                obj.Atmosphere.a(i) = a(length(a),1);
                obj.Atmosphere.Parent = obj;
            end
        end
        
        function obj = ConvertUnits(obj,unitSystem)
            if strcmp(unitSystem,'FPS')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in FPS. No action was taken.\n')
                    return
                end
                obj.AirSpeed = obj.AirSpeed.ConvertUnits('FPS'); % m/s to ft/s by m/s * 3.28 ft/m
                obj.Altitude = obj.Altitude * 3.28; % Meters to feet by 3.28 feet / meter
                obj.Units = 'FPS';
                obj = obj.CalculateAtmosphericProperties();
            elseif strcmp(unitSystem,'SI')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in SI. No action was taken.\n')
                    return
                end
                obj.AirSpeed = obj.AirSpeed.ConvertUnits('SI'); % m/s to ft/s by m/s * 3.28 ft/m
                obj.Altitude = obj.Altitude / 3.28; % Meters to feet by 3.28 feet / meter
                obj.Units = 'SI';
                obj = obj.CalculateAtmosphericProperties();
            end
        end
        
        function obj = SetSpeed(obj,prop,val)
            if isempty(obj.Altitude)
                error("You must enter an altitude before you call the SetSpeed(prop,val) method")
            end
            sped = Airspeed;

            obj = obj.CalculateAtmosphericProperties();
            obj.Atmosphere.Name = obj.Name;
            
            sped.Units = obj.Units;
            
            sped.Parent = obj;
            sped = sped.Set(prop,val);
            obj.AirSpeed = sped;
            obj.AirSpeed.Parent.AirSpeed.Parent = []; % Avoid an infinite Panret/Child Heirarchal loop
            
        end

    end
end

