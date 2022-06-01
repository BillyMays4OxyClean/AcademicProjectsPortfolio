classdef Vehicle
    properties
        Name string
        Components % Components list will be a structure array
        Results
    end
    
    methods
        
        function Export2Excel(obj,filename)
            if IsInList(char(filename),".")==1
                if strcmp(extractAfter(filename,"."),"xlsx")==1
                    fullname = filename;
                else
                    error('You must use ".xlsx" as the file extension');
                end
            else
                fullname = strcat(filename,".xlsx");
            end
            comp_list = obj.GetChildren();
            for i=1:length(comp_list)
                writecell(comp_list{i}.Data2Cell(),fullname,"Sheet",comp_list{i}.Name)
            end
            if ispc
                winopen(fullname)
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
        
        function [bool,child] = FindFirstChild(obj,name)
            f = fieldnames(obj.Components);
            for i=1:length(f)
                val = obj.Components.(f{i});
                if strcmp(val.Name,name)
                    bool = 1;
                    child = val;
                    return
                end
            end
            bool = 0;
        end
        
        function list = GetChildren(obj)
            f = fieldnames(obj.Components);
            list = cell(length(f),1);
            
            for i=1:length(f)
                list{i} = obj.Components.(f{i});
            end
            
        end
    end
end

