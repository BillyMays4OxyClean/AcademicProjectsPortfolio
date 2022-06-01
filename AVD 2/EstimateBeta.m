function beta = EstimateBeta(M1,theta,threshold)
    f = @(Beto) atan(2*cot(Beto)*((M1^2*sin(Beto)^2-1)/(M1^2*(1.4+cos(2*Beto))+2)))-theta;
    fp = @(Beto) ((4*M1^2*cos(Beto)*cot(Beto)*sin(Beto))/((cos(2*Beto) + 7/5)*M1^2 + 2) - (2*(cot(Beto)^2 + 1)*(M1^2*sin(Beto)^2 - 1))/((cos(2*Beto) + 7/5)*M1^2 + 2) + (4*M1^2*sin(2*Beto)*cot(Beto)*(M1^2*sin(Beto)^2 - 1))/((cos(2*Beto) + 7/5)*M1^2 + 2)^2)/((4*cot(Beto)^2*(M1^2*sin(Beto)^2 - 1)^2)/((cos(2*Beto) + 7/5)*M1^2 + 2)^2 + 1);
    mu = asin(1/M1);
    Beto(1) = mu;
    f1 = f(Beto(1));
    error = abs(f1-theta);
    i = 1;
    imax = 10000;
    if error >= threshold
        while error >= threshold
            i = i + 1;
            fe = f(Beto(i - 1));
            fpe = fp(Beto(i - 1));
            Beto(i) = Beto(i - 1) - fe/fpe;
            error = abs(f(Beto(i))-theta);
            if Beto(i) > pi/2 || Beto(i) < 0
                beta = NaN;
%                 fprintf('Out of bounds. Beta does not exist for Mach value of %f and Theta value of %f\n',M1,theta);
                break
            elseif i==imax
                beta = Beto(i);
%                 fprintf('Success! Calculated Beta to be %f in %d iterations!\t for mach value of %f and theta value of %f\n',beta*180/pi,i,M1,theta);
                break
            elseif error <= threshold
                beta = Beto(i);
%                 fprintf('Success! Calculated Beta to be %f in %d iterations!\t for mach value of %f and theta value of %f\n',beta*180/pi,i,M1,theta);
                break
            end
        end
    elseif error <= threshold
        if Beto(i) > pi/2 || Beto(i) < 0
            beta = NaN;
            return
%             fprintf('Out of bounds. Beta does not exist for Mach value of %f and Theta value of %f\n',M1,theta);
        elseif i==imax
            beta = Beto(i);
            return
%             fprintf('Success! Calculated Beta to be %f in %d iterations!\n',beta*180/pi,i);
        elseif error <= threshold
            beta = Beto(i);
            return
%             fprintf('Success! Calculated Beta to be %f in %d iterations!\n',beta*180/pi,i);
        end
        beta = NaN;
    end
end