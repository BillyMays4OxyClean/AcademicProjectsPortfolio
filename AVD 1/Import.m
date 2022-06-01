function obj = Import(obj,C,par)

    if nargin==3
        parent = par;
    end
    
    Cdim = size(C);
    
    for i=1:Cdim(1)
        for j=1:Cdim(2)
            if isa(C{i,j},'missing')==1
                C{i,j} = [];
            end
        end
    end
    
    title = char(C{1,1});
    class = extractBefore(title," - ");
    name = extractAfter(title," - ");

    f = fieldnames(obj);
    
    
    for i = 2:Cdim(1)
        if (i-1) <= length(f)
            if (isa(C{i,2},'string') || ischar(C{i,2})) && strcmp(f{i-1,1},'Parent')==0
                c = char(C{i,2});
                for s = 1:length(c)
                    if strcmp(c(s),'-') == 1
                        classdesignation = C{i,2};
                        newclass = extractBefore(classdesignation," - ");
                        newname = extractAfter(classdesignation," - ");
                        newclass = eval(newclass);
                        
                        if isa(newclass,'NACA4') && strcmp(C{i,1},'RootAirfoil')
                            obj.(C{i,1}) = NACA4WingSection(extractAfter(C{i,2}," - "),obj.Rc,128);
                            obj.(C{i,1}).Parent = obj;
                            break
                        elseif isa(newclass,'NACA4') && strcmp(C{i,1},'TipAirfoil')
                            obj.(C{i,1}) = NACA4WingSection(extractAfter(C{i,2}," - "),obj.Tc,128);
                            obj.(C{i,1}).Parent = obj;
                            break
                        end
                        
                        newclass.Name = newname;

                        for j = 1:Cdim(2)
                            if isa(C{1,j},'string') || ischar(C{1,j})
                                c = char(C{i,2});
                                for s2 = 1:length(c)
                                    if strcmp(c(s2),'-') == 1
                                        column_offset = j-1;
                                        break
                                    end
                                end
                            end
                        end

                        B = cell(Cdim(1),Cdim(2)-column_offset);
                        Bdim = size(B);

                        for column = 1:Bdim(2)
                            for row = 1:Bdim(1)
                                B{row,column} = C{row,column+column_offset};
                            end
                        end

                        newclass = newclass.ImportFromCell(B,obj);
                        obj.(C{i,1}) = newclass;
                        break
                    elseif s == length(c)
                        obj.(C{i,1}) = C{i,2};
                    end
                end
            elseif strcmp(f{i-1,1},'Parent')==1
                obj.Parent = parent;
            else
                for v = 1:length(f)
                    if strcmp(C{i,1},f{v,1}) == 1

                        if Cdim(2)>2
                            if isempty(C{i,3})
                                obj.(f{v,1}) = C{i,2};
                                break
                            else
                                n = 2;
                                while isempty(C{i,n})==0 && n<Cdim(2)
                                    n = n + 1;
                                end

                                D = zeros(n-1,1);
                                for n = 2:n
                                    D(n-1,1) = C{i,n};
                                end
                                obj.(f{v,1}) = D;
                                break
                            end
                        else
                            obj.(f{v,1}) = C{i,2};
                            break
                        end

                    end
                end
            end
        end
    end
end

