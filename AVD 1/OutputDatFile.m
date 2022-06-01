function file = OutputDatFile(obj,filename,delimiter)
    if IsInList(GetAirfoilList(),class(obj))
        filename = convertStringsToChars(filename);
        
        if IsInList(filename,'.') == 1
            f = fopen(char(filename),'w');
        else
            f = fopen(char(strcat(filename,'.dat')),'w');
        end
        
%         fprintf(f,'%s\n\n',obj.Name);
        
        for i=1:length(obj.xu)
            if nargin == 3
                if ischar(delimiter)==1 || isa(delimiter,'string')==1
                    fprintf(f,'%f%s%f\n',obj.xu(i),delimiter,obj.yu(i));
                else
                    error('You silly goose, the input delimiter must be a string or character array!')
                end
            else
                fprintf(f,'%f\t%f\n',obj.xu(i),obj.yu(i));
            end
        end
        
        fprintf(f,'\n');
        
        for i=1:length(obj.xl)
            if nargin == 3
                if ischar(delimiter)==1 || isa(delimiter,'string')==1
                    fprintf(f,'%f%s%f\n',obj.xl(i),delimiter,obj.yl(i));
                else
                    error('You silly goose, the input delimiter must be a string or character array!')
                end
            else
                fprintf(f,'%f\t%f\n',obj.xl(i),obj.yl(i));
            end
        end
        
        file = f;
    else
        error('The object you are trying to output to a dat file must be an airfoil')
    end
    
    fclose(f);
end

