function [nu1,nu2,mu,M2] = AppC(M1,theta,threshold)
    if M1<1
        error('For Appendix C, Mach values must be larger than 1. The given input argument is %f',M1);
    elseif M1==1
        nu1 = 0;
        mu = 90*pi/180;
        nu2 = NaN;
        M2 = NaN;
        return
    end
    nu1 = sqrt((1.4+1)/(1.4-1))*atan(sqrt((1.4-1)/(1.4+1)*(M1^2-1)))-atan(sqrt(M1^2-1));
    
    if isnan(theta)==0 && theta>=0
        nu2 = theta + nu1;

        f = @(m2) sqrt((1.4+1)/(1.4-1))*atan(sqrt((1.4-1)/(1.4+1)*(m2^2-1)))-atan(sqrt(m2^2-1))-nu2;
        fp = @(m2) (6^(1/2)*m2)/(6*(m2^2/6 - 1/6)^(1/2)*(m2^2/6 + 5/6)) - 1/(m2*(m2^2 - 1)^(1/2));
        imax = 10000;
        m2 = zeros(1,imax+1);
        m2(1) = M1;
        f1 = f(m2(1));
        dev = abs(f1-nu2);
        i = 1;
        while dev >= threshold
            i = i + 1;
            fe = f(m2(i - 1));
            fpe = fp(m2(i - 1));
            m2(i) = m2(i - 1) - fe/fpe;
            dev = abs(f(m2(i))-theta);
            if i==imax
                M2 = m2(i);
%                 fprintf('Success! Calculated Mach 2 to be %f in %d iterations!\t for mach value of %f and theta value of %f\n',M2,i,M1,theta);
                break
            end
        end
        M2 = m2(i);
        mu = asind(1/M2);
        if m2(i) > 50 || m2(i) < 1
            M2 = NaN;
%             fprintf('Out of bounds. Beta does not exist for Mach value of %f and Theta value of %f\n',M2,theta);
        elseif i==imax
            M2 = m2(i);
%             fprintf('Success! Calculated Mach 2 to be %f in %d iterations!\t for mach value of %f and theta value of %f\n',M2,i,M1,theta);
        end
        mu = asin(1/M2);
    else
        nu2 = NaN;
        M2 = NaN;
        mu = asin(1/M1);
    end
    


%     if M2<1
%         error('For Appendix C, Mach values must be larger than 1.\n The given input argument is %f',M2);
%     end
%     nu1 = sqrt((y+1)/(y-1))*atan(sqrt((y-1)/(y+1)*(M2^2-1)))-atan(sqrt(M2^2-1));
%     if isnan(theta)==0 && theta>0
%         nu2 = theta + nu1;
%         syms m2
%         eq1 = nu2 == sqrt((y+1)/(y-1))*atan(sqrt((y-1)/(y+1)*(m2^2-1)))-atan(sqrt(m2^2-1));
%         M2 = vpasolve(eq1,m2,[1 50]);
%         M2 = double(M2);
%     else
%         nu2 = NaN;
%         M2 = NaN;
%     end
%     mu = asind(1/M2);

%     nu1 = sqrt((y+1)/(y-1))*atan(sqrt((y-1)/(y+1)*(M2^2-1)))-atan(sqrt(M2^2-1));
%     if isnan(theta)==0 && theta>0
%         nu2 = theta + nu1;
% 
%         f = @(m2) sqrt((y+1)/(y-1))*atan(sqrt((y-1)/(y+1)*(m2^2-1)))-atan(sqrt(m2^2-1));
%         fp = @(m2) (m2*((y + 1)/(y - 1))^(1/2)*(y - 1))/((y + 1)*(((m2^2 - 1)*(y - 1))/(y + 1) + 1)*(((m2^2 - 1)*(y - 1))/(y + 1))^(1/2)) - 1/(m2*(m2^2 - 1)^(1/2));
%         x0 = 1;
%         m2(1) = x0;
%         error = abs(f(m2(1))-nu2);
%         i = 1;
%         imax = 10000000;
%         while error >= threshold
%             i = i + 1;
%             fe = f(m2(i-1));
%             fpe = fp(m2(i-1));
%             m2(i) = m2(i - 1) - fe/fpe;
%             error = abs(f(m2(i))-theta);
%             if m2(i) > 50 || m2(i) < 1
%                 M2 = NaN;
%                 fprintf('Out of bounds. Mach 2 does not exist for Mach value of %f and Theta value of %f',M2,theta);
%                 break
%             elseif i==imax
%                 break
%             end
%         end
%         M2 = m2(i);
%         fprintf('Success! Calculated Mach 2 to be %f in %d iterations!',m2,i);
%     else
%         nu2 = NaN;
%         M2 = NaN;
%     end
    
%     for i=1:10000
% 
%         nu2_guess = ((sqrt((y+1)/(y-1))*atand(sqrt((y-1)/(y+1)*(M2^2-1)))-atand(sqrt(M2^2-1))));
% 
%         if (nu2_guess > nu2)
%             M2 = M2 - 1/(i);
%         elseif (nu2_guess < nu2)
%             M2 = M2 + 1/(i);
%         else
%             M2 = M2;
%         end
% 
%     end
%     nu2_guess = ((sqrt((y+1)/(y-1))*atand(sqrt((y-1)/(y+1)*(M2^2-1)))-atand(sqrt(M2^2-1))));
%     i=1;
% 
%     while abs(nu2 - nu2_guess)>=error
%         nu2_guess = ((sqrt((y+1)/(y-1))*atand(sqrt((y-1)/(y+1)*(M2^2-1)))-atand(sqrt(M2^2-1))));
% 
%         if (nu2_guess > nu2)
%             M2 = M2 + abs(nu2 - nu2_guess)/i
%         elseif (nu2_guess < nu2)
%             M2 = M2 - abs(nu2 - nu2_guess)/i
%         else
%             M2 = M2;
%         end
%         i=i+1;
%     end
%     fprintf('Success! Found Nu in %d iterations\n!',i);

end