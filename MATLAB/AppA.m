function [p0_p,rho0_rho,T0_T,A_Astar] = AppA(M,gamma)
    if M<1
        error('For Appendix A, Mach values must be larger than 1.\n The given input argument is %f',M1);
    end
    p0_p = (1 + (gamma-1)/2*M^2)^(gamma/(gamma-1));
    T0_T = 1 + (gamma-1)/2*M^2;
    rho0_rho = (1 + (gamma-1)/2*M^2)^(1/(gamma-1));
    A_Astar = sqrt(1/M^2 * (2/(gamma+1) * (1 + (gamma-1)/2 * M^2) )^((gamma+1)/(gamma-1)) );
end
