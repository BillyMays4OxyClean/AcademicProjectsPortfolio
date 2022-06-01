function bool = IsInList(list,item)
    for i=1:length(list)
        if isa(list,'cell') || isa(list,'string')
            if strcmp(list{i},item)==1
                bool = 1;
                return
            end
        elseif ischar(list)
            if strcmp(list(i),item)==1
                bool = 1;
                return
            end
        end
    end
    bool = 0;
end