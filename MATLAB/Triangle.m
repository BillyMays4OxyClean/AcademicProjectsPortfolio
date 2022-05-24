function [x,y] = Triangle(xt,t,c)
    x = zeros(1,3);
    x(1) = 0;
    x(2) = xt;
    x(3) = c;
    y = zeros(1,3);
    y(1) = 0;
    y(2) = t;
    y(3) = 0;
end