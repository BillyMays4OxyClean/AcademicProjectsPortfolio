classdef Atm
    properties
        T {mustBeNumeric}
        P {mustBeNumeric}
        rho {mustBeNumeric}
        mu {mustBeNumeric}
        nu {mustBeNumeric}
        a {mustBeNumeric}
        Units string
        Name string
        Parent
    end
    methods
        
        function C = Data2Cell(obj)
            C = DataConv(obj);
        end
        
        function [field,prop,len] = ReturnFieldsNProperties(obj)
            field = fieldnames(obj);
            len = length(field);
            prop = cell(len,1);
            for i=1:len
                prop{i,1} = obj.(field{i,1});
            end
        end
        
    end
end

