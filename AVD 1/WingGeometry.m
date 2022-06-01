classdef WingGeometry
    properties
        b {mustBeNumeric}
        Rc {mustBeNumeric}
        Tc {mustBeNumeric}
        RootAirfoil
        TipAirfoil
        Taper {mustBeNumeric}
        meanThicc {mustBeNumeric}
        AR {mustBeNumeric}
        MAC {mustBeNumeric}
        Sweep {mustBeNumeric}
        Swet {mustBeNumeric}
        Se {mustBeNumeric}
        S {mustBeNumeric}
        Kw {mustBeNumeric}
        V {mustBeNumeric}
        Name string
        Units string
    end
    methods
        
        function [CL,CLa,L] = ReturnLift(Wing,FC)
            if isa(FC,'FlightCondition') == 0
                error('The flight condition argument must be the class "FlightCondition"')
            elseif isa(Wing,'WingGeometry') == 0
                error('The object for which the method is called must be of the class "WingGeometry"')
            else
                required_atm_properties = ["rho";"mu"];
                if isempty(FC.Atmosphere) == 0
                    [afield,~,~] = FC.Atmosphere.ReturnFieldsNProperties();
                    for i=1:length(required_atm_properties)
                        DoesExist = IsInList(afield,required_atm_properties{i});
                        if DoesExist == 1
                            if isempty(FC.Atmosphere.(required_atm_properties{i}))
                                error(strcat(required_atm_properties{i},' is a required property to calculate wing drag'))
                            end
                        else
                            error(strcat("For some reason the property you are trying to access, ",'"',afield{i},'"',", does not exist."))
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
                            error(strcat(required_FC_properties{i},' is a required property to calculate wing drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',field{i},'"',", does not exist."))
                    end
                end
                
                required_WG_properties = ["RootAirfoil";"S";"AR";"Sweep"];
                [field,~,~] = Wing.ReturnFieldsNProperties();
                for i=1:length(required_WG_properties)
                    DoesExist = IsInList(field,required_WG_properties{i});
                    if DoesExist == 1
                        if isempty(Wing.(required_WG_properties{i}))
                            error(strcat(required_WG_properties{i},' is a required property to calculate wing drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',field{i},'"',", does not exist."))
                    end
                end
            end

            B = sqrt(1 - FC.AirSpeed.Mach^2);
            CLa = 2*pi*Wing.AR/(2+sqrt(4+Wing.AR^2*B^2*(1+(tand(Wing.Sweep)^2/B^2)) ));
            CL = CLa * (deg2rad(FC.AoA) - Wing.RootAirfoil.a0l);
            L = FC.AirSpeed.q*CL*Wing.S;
        end
        
        function [CD,CD0Wing,CDLWing,D] = ReturnDrag(Wing,FC)
            if isa(FC,'FlightCondition') == 0
                error('The flight condition argument must be the class "FlightCondition"')
            elseif isa(Wing,'WingGeometry') == 0
                error('The object for which the method is called must be of the class "WingGeometry"')
            else
                required_atm_properties = ["rho";"mu"];
                if isempty(FC.Atmosphere) == 0
                    [afield,~,~] = FC.Atmosphere.ReturnFieldsNProperties();
                    for i=1:length(required_atm_properties)
                        DoesExist = IsInList(afield,required_atm_properties{i});
                        if DoesExist == 1
                            if isempty(FC.Atmosphere.(required_atm_properties{i}))
                                error(strcat(required_atm_properties{i},' is a required property to calculate wing drag'))
                            end
                        else
                            error(strcat("For some reason the property you are trying to access, ",'"',afield{i},'"',", does not exist."))
                        end
                    end
                else
                    error("The atmospheric properties of the flight condition you entered are blank. Use the SetSpeed(prop,val) method to calculate full flight condition information")
                end
                
                required_AS_properties = "AoA";
                [field,~,~] = FC.ReturnFieldsNProperties();
                for i=1:length(required_AS_properties)
                    DoesExist = IsInList(field,required_AS_properties{i});
                    if DoesExist == 1
                        if isempty(FC.(required_AS_properties{i}))
                            error(strcat(required_AS_properties{i},' is a required property to calculate wing lift'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',field{i},'"',", does not exist."))
                    end
                end
                
                required_AS_properties = "V";
                [field,~,~] = FC.AirSpeed.ReturnFieldsNProperties();
                for i=1:length(required_AS_properties)
                    DoesExist = IsInList(field,required_AS_properties{i});
                    if DoesExist == 1
                        if isempty(FC.AirSpeed.(required_AS_properties{i}))
                            error(strcat(required_AS_properties{i},' is a required property to calculate wing drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',field{i},'"',", does not exist."))
                    end
                end
                
                required_WG_properties = ["RootAirfoil";"S";"Swet";"MAC";"AR";"Sweep"];
                [field,~,~] = Wing.ReturnFieldsNProperties();
                for i=1:length(required_WG_properties)
                    DoesExist = IsInList(field,required_WG_properties{i});
                    if DoesExist == 1
                        if isempty(Wing.(required_WG_properties{i}))
                            error(strcat(required_WG_properties{i},' is a required property to calculate wing drag'))
                        end
                    else
                        error(strcat("For some reason the property you are trying to access, ",'"',field{i},'"',", does not exist."))
                    end
                end
            end
            [CLw,~,~] = Wing.ReturnLift(FC);
            [CD,CD0Wing,CDLWing] = WingDrag(Wing,FC.AirSpeed.Mach,FC.Atmosphere.rho,FC.Atmosphere.mu,FC.AirSpeed.V,CLw);
            
            D = FC.AirSpeed.q*CD*Wing.S;
            
            function [CDWing,CD0Wing,CDLWing] = WingDrag(Wing,Mach,rho,mu,V,CLw)
                tc = Wing.RootAirfoil.t;
                xc = Wing.RootAirfoil.p;
                Swet = Wing.Swet;
                Sref = Wing.S;
                sweep = Wing.Sweep;
                cmac = Wing.MAC;
                AR = Wing.AR;
                e = Wing.RootAirfoil.e;
                Cf = frictionCoefficient(rho,V,cmac,mu);
                L = thiccParameter(xc);
                R = LiftingSurfaceCorrelationFactor(sweep,Mach);
                CD0Wing = Cf*(1 + L*tc + 100*tc^4 ) * R * Swet / Sref;
                CDLWing = CLw^2/(pi*AR*e);
                
                Clmin = 0.2;
                Cdmin = 0.007;
                kdp = 0.0047;
                CDLWing = kdp.*(CLw(1) - Clmin).^2;
                
                CDWing = CD0Wing + CDLWing;
            end

            function R = LiftingSurfaceCorrelationFactor(sweep,Mach)
                % Until the process is developed from DATC0M, 1.146 will be used. This
                % assumes Mach = 0.55 and sweep is 0 degrees.
                peTransonic = @(M) abs(0.6-M)/M;
                peSubSonic = @(M) abs(0.25-M)/M;

                if peTransonic(Mach) > peSubSonic(Mach)
                    R = 1.065;
                else
                    R = 1.146;
                end
            end

            function L = thiccParameter(xc)
                if xc >= 0.3
                    L  = 1.2;
                elseif xc <= 0.3
                    L = 2.0;
                end
            end

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
                    fprintf('Units are already in FPS. No action was taken.\n')
                    return
                end
                % Units of Length
                obj.b = obj.b * 3.28;
                obj.Rc = obj.Rc * 3.28;
                obj.Tc = obj.Tc * 3.28;
                obj.MAC = obj.MAC * 3.28;
                
                % Units of Area
                obj.Swet = obj.Swet * 3.28^2;
                obj.Se = obj.Se * 3.28^2;
                obj.S = obj.S * 3.28^2;
                
                % Units of Volume
                obj.V = obj.V * 3.28^3;
                
                % Change unit system labeled in the class
                obj.Units = 'FPS';
            elseif strcmp(unitSystem,'SI')
                if strcmp(obj.Units,unitSystem)
                    fprintf('Units are already in SI. No action was taken.\n')
                    return
                end
                % Units of Length
                obj.b = obj.b / 3.28;
                obj.Rc = obj.Rc / 3.28;
                obj.Tc = obj.Tc / 3.28;
                obj.MAC = obj.MAC / 3.28;
                
                % Units of Area
                obj.Swet = obj.Swet / 3.28^2;
                obj.Se = obj.Se / 3.28^2;
                obj.S = obj.S / 3.28^2;
                
                % Units of Volume
                obj.V = obj.V / 3.28^3;
                
                % Change unit system labeled in the class
                obj.Units = 'SI';
            end
        end
    end
end

