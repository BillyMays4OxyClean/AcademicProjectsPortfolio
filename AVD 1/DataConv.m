function C = DataConv(obj)
    f = fieldnames(obj);
    C{1,1} = string(strcat(string(class(obj))," ","-"," ",obj.Name));
    m = 2;
    for i=2:(length(f)+1)
        if isempty(obj.(f{i-1,1})) == 0
            if isa(obj.(f{i-1,1}),'double')
                C{i,1} = f{i-1,1};
                val = obj.(f{i-1,1});
                ValDim = size(val);
                Cdim = size(C);

                if ValDim(2) == 1 && ValDim(1)>1
                    val = transpose(val);
                end

                ValDim = size(val);

                for column = 1:ValDim(2)
                    for row = 1:ValDim(1)
                        C{i+row-1,1+column} = val(row,column);
                    end
                end
            elseif ischar(obj.(f{i-1,1})) || isa(obj.(f{i-1,1}),'string')
                C{i,1} = f{i-1,1};
                C{i,2} = obj.(f{i-1,1});
            elseif isstruct(obj.(f{i-1,1}))
                C{i,1} = f{i-1,1};
                C{i,2} = string(strcat(f{i-1,1}," ","-"," ",obj.Name));
                structt = obj.(f{i-1,1});
                structfields = fieldnames(structt);

                Cdim = size(C);
                C{1,Cdim(2)+2} = string(strcat(f{i-1,1}," ","-"," ",obj.Name));
                for struct = 1:length(structfields)
                    C{struct+1,Cdim(2)+2} = structfields{struct};
                    C{struct+1,Cdim(2)+3} = structt.(structfields{struct}); 
                end
            else
                if strcmp(f{i-1,1},'Parent')==0
                    C{i,1} = f{i-1,1};
    %                 if isempty(obj.(f{i-1,1}).Name)
    %                     C{i,2} = class(obj.(f{i-1,1}));
    %                 else
    %                     C{i,2} = obj.(f{i-1,1}).Name;
    %                 end
                    B = obj.(f{i-1,1}).Data2Cell();
                    C{i,2} = B{1,1};

                    Bdim = size(B);
                    Cdim = size(C);

                    for column = 1:Bdim(2)
                        for row = 1:Bdim(1)
                            C{row,Cdim(2)+column+1} = B{row,column};
                        end
                    end
                else
                    C{i,1} = f{i-1,1};
                    C{i,2} = string(strcat(string(class(obj.Parent))," ","-"," ",obj.Parent.Name));
                end
            end
        end
    end
end