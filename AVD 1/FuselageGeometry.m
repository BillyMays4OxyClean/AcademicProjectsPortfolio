classdef FuselageGeometry
    properties
        SlendernessRatio {mustBeNumeric}
        FinenessRatio {mustBeNumeric}
        e {mustBeNumeric}
        MaxDiameter {mustBeNumeric}
        BaseDiameter {mustBeNumeric}
        L {mustBeNumeric}
        W {mustBeNumeric}
        H {mustBeNumeric}
        Swet {mustBeNumeric}
        Sb {mustBeNumeric}
        V {mustBeNumeric}
        Name string
        Units string
    end
    methods
        
        function [CD,CD0Body,CDLfuse,D] = ReturnDrag(Body,FC)
            if isa(FC,'FlightCondition') == 0
                error('The flight condition argument must be the class "FlightCondition"')
            elseif isa(Body,'FuselageGeometry') == 0
                error('The object for which the method is called must be of the class "FuselageGeometry"')
            else
                required_atm_properties = ["rho";"mu"];
                if isempty(FC.Atmosphere) == 0
                    [afield,~,~] = FC.Atmosphere.ReturnFieldsNProperties();
                    for i=1:length(required_atm_properties)
                        DoesExist = IsInList(afield,required_atm_properties{i});
                        if DoesExist == 1
                            if isempty(FC.Atmosphere.(required_atm_properties{i}))
                                error(strcat(required_atm_properties{i},' is a required property to calculate Body drag'))
                            end
                        else
                            error(strcat("For some reason the property you are trying to access, ",'"',required_atm_properties{i},'"',", does not exist."))
                        end
                    end
                else
                    error("The atmospheric properties of the flight condition you entered are blank. Use the SetSpeed(prop,val) method to calculate full flight condition information")
                end
                
                required_FC_properties = "V";
                [field,~,~] = FC.AirSpeed.ReturnFieldsNProperties();
                for i=1:length(required_FC_properties)
                    DoesExist = IsInList(field,required_FC_properties{i});
                    if DoesExist == 1
                        if isempty(FC.AirSpeed.(required_FC_properties{i}))
                            error(strcat(required_FC_properties{i},' is a required property to calculate Body drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',required_FC_properties{i},'"',", does not exist."))
                    end
                end
                
                required_WG_properties = ["FinenessRatio";"BaseDiameter";"MaxDiameter";"Swet"];
                [field,~,~] = Body.ReturnFieldsNProperties();
                for i=1:length(required_WG_properties)
                    DoesExist = IsInList(field,required_WG_properties{i});
                    if DoesExist == 1
                        current_check = required_WG_properties{i};
                        if isempty(Body.(required_WG_properties{i}))
                            error(strcat(required_WG_properties{i},' is a required property to calculate Body drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',required_WG_properties{i},'"',", does not exist."))
                    end
                end
            end
            
            Cf = frictionCoefficient(FC.Atmosphere.rho,FC.AirSpeed.V,Body.MaxDiameter,FC.Atmosphere.mu);
            CDf = Cf*(1 + 60/(Body.FinenessRatio)^3 + 0.0025*(Body.FinenessRatio) ) * Body.Swet/Body.Sb;
            CDb = 0.029 * (Body.BaseDiameter/Body.MaxDiameter)^3/sqrt(CDf);
            CD0Body = CDf + CDb;
            
%             eta = [.552 .6 .64 0.66 0.705 0.72 ];
            eta = 0.67;
            
            CDLfuse = 2*abs(deg2rad(FC.AoA)^2); % + eta*Cdc*deg2rad(FC.AoA)^3*Body.Splan
            
            CD = CD0Body+CDLfuse;
            D = FC.AirSpeed.q*CD*Body.Sb;
            
            function Cf = frictionCoefficient(rho,V,cmac,mu)
                Re = rho*V*cmac/mu;
                if Re < 5*10^5
                    Cf = 1.328/sqrt(Re);
                elseif Re > 5*10^5
                    Cf = 0.455/((log10(Re))^2.58);
                end
            end
            
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
        
        function [field,prop,len] = ReturnFieldsNProperties(obj)
            field = fieldnames(obj);
            len = length(field);
            prop = cell(len,1);
            for i=1:len
                prop{i,1} = obj.(field{i,1});
            end
        end
        
        function obj = ConvertUnits(obj,unitSystem)
            if strcmp(unitSystem,'FPS')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in FPS. No action was taken\n')
                    return
                end
                obj.MaxDiameter = obj.MaxDiameter * 3.28; % 1 m / 3.28 ft
                obj.BaseDiameter = obj.BaseDiameter * 3.28; % 1 m / 3.28 ft
                obj.L = obj.L * 3.28; % 1 m / 3.28 ft
                obj.W = obj.W * 3.28; % 1 m / 3.28 ft
                obj.H = obj.H * 3.28; % 1 m / 3.28 ft
                obj.Swet = obj.Swet * (3.28)^2; % 1 m^2 / (3.28 ft)^2
                obj.Sb = obj.Sb * (3.28)^2; % 1 m^2 / (3.28 ft)^2
                obj.V = obj.V * (3.28)^3; % 1 m^3 / (3.28 ft)^3
                obj.Units = 'FPS';
            elseif strcmp(unitSystem,'SI')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in SI. No action was taken\n')
                    return
                end
                obj.MaxDiameter = obj.MaxDiameter / 3.28; % 1 m / 3.28 ft
                obj.BaseDiameter = obj.BaseDiameter / 3.28; % 1 m / 3.28 ft
                obj.L = obj.L / 3.28; % 1 m / 3.28 ft
                obj.W = obj.W / 3.28; % 1 m / 3.28 ft
                obj.H = obj.H / 3.28; % 1 m / 3.28 ft
                obj.Swet = obj.Swet / (3.28)^2; % 1 m^2 / (3.28 ft)^2
                obj.Sb = obj.Sb / (3.28)^2; % 1 m^2 / (3.28 ft)^2
                obj.V = obj.V / (3.28)^3; % 1 m^3 / (3.28 ft)^3
                obj.Units = 'SI';
            end
        end
    end
end