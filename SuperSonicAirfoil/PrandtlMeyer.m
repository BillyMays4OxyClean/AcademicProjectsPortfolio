function [nu1,nu2,M2] = AppC(theta,M1,y)
    nu1 = sqrt((y+1)/(y-1))*atand(sqrt((y-1)/(y+1)*(M1^2-1)))-atand(sqrt(M1^2-1));
    
    nu2 = theta + nu1;

    M2 = M1;

    for i=1:10000

        nu2_guess = ((sqrt((y+1)/(y-1))*atand(sqrt((y-1)/(y+1)*(M2^2-1)))-atand(sqrt(M2^2-1))));

        if (nu2_guess > nu2)
            M2 = M2 - 1/(i);
        elseif (nu2_guess < nu2)
            M2 = M2 + 1/(i);
        else
            M2 = M2;
        end

    end
end

