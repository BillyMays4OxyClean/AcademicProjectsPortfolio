function [p2p1,rho2rho1,t2t1,p02p01,p02p1,Mn2] = AppB(M)
%     if M<1.00000
%         error('For Appendix B, Mach values must be larger than 1. The given input argument is %f',M);
%     end
    p2p1 = 1 + ((2*1.4)/(1.4+1))*(M^2-1);
    rho2rho1 = (1.4+1)*M^2/(2 + (1.4-1)*M^2);
    t2t1 = (1+(2*1.4/(1.4+1)*(M^2-1)))*(2+(1.4-1)*M^2)/((1.4+1)*M^2);
    delt_s = 1004.5*log(t2t1)-287*log(p2p1);
    p02p01 = exp(-delt_s/287);
    p02p1 = (((1.4+1)^2*M^2)/(4*1.4*M^2-2*(1.4-1)))^(1.4/(1.4-1))*((1-1.4+2*1.4*M^2)/(1.4+1));

    Mn2 = sqrt( (1 + (1.4-1)/2*(M)^2)/( 1.4*(M)^2 - (1.4-1)/2 ) );
end
