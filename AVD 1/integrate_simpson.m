% Numerical integration using Simpson's Rule. Created by Luke Patterson

function [output] = integrate_simpson(func,a,b,n)
    delt_x = (b-a)/(n-1);
    x = a:delt_x:b;
    y = func;
    s = y(1);
    for i=0:n
       if (-1)^i < 0 && i~=n
           s = s + 4*y(i);
       elseif (-1)^i > 0 && i~=0 && i~=n
           s = s + 2*y(i);
       elseif i==n
           s = s + y(i);
       end
%       fprintf('iteration: %d\tvalue: %f.4\n',i,s); 
    end
    S = s * delt_x/3;
    output = S;
end

