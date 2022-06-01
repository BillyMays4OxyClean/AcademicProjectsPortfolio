function [x,y] = Sine(xt,t,c,N)

    x = 0:1/N:c;

    y = zeros(1,N+1);
    A = 4*xt;
    B = 4*(c-xt);

    for i=1:N
        if x(i) <= xt
            y(1,i) = t*sin(2*pi/A*x(i)) ;
        elseif x(i) >= xt
            y(1,i) = t*cos(2*pi/B*(x(i)-xt));
        elseif x(i) == c
            y(1,i) = 0;
        end
    end

end