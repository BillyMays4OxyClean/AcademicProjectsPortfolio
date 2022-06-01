function [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha,x,yu,yl,nseg)
startTime = tic;
%     Minf --- Freestream Mach No.
%     alpha -- Angle of attack (in degrees)
%     x()  --- x coord.
%     yu() --- y upper coord.
%     yl   --- y lower coord.
%     nseg   --- Number of segments.
%
% Output:
%     cl   --- Coeff. of lift
%     cd   --- Coeff. of drag
%     cm   --- Coeff. of moment about the LE
%     xm   --- x coord. of Cp
%     cpu  --- Cp on upper surface
%     cpl  --- Cp on lower surface
%
%      f = waitbar(0,'Calculating Aerodynamic Coefficients: ');
     gamma = 1.4;   % Specific heat
%     R= 287;        % Gas constant
%     invlam = 1.0/sqrt(Minf*Minf-1);
     qinf = 2.0/( gamma*Minf*Minf);
     sum1 = 0.0;
     sum2 = 0.0;
     sum3 = 0.0;
%     xsum = 0.0;
%     ysum = 0.0;
%     cm=0.0;
     alpha = alpha*pi/180;
     
     cpu = zeros(1,nseg);
     cpl = zeros(1,nseg);
     xm = zeros(1,nseg);
     
%      delt_tu = zeros(1,nseg-1);
%      delt_tl = zeros(1,nseg-1);
%%
%    Leading edge
     yu1=yu(1);
     yl1=yl(1);
     phi_u0=alpha;
     phi_l0=alpha;
     theta1_u = alpha;
     theta1_l =-alpha;
     m1_u = Minf;
     m1_l = Minf;
     p1_u = 1.0;
     p1_l = 1.0;
%%
%  Compute forces on the upper and lower surfaces
%%
%     fprintf('Starting for loop for calculating forces on upper and lower surfaces\n');
    for i=1:nseg

%         fprintf('Segment %d of %d\n',i,nseg);
%         per = i/nseg;
%         s = strcat('Calculating Aerodynamic Coefficients: ',{' '},num2str(round(per*100)),'% Complete.');
%         waitbar(per,f,s);
        
        dx=x(i+1)-x(i);
        % y_u and y_l
        yu2 = yu(i+1);
        yl2 = yl(i+1);

        dyu=yu2-yu1;
        dyl=yl2-yl1;

        phi_u = atan( dyu/dx);
        phi_l = atan( dyl/dx);

        theta2_u = phi_u;
        theta2_l =-phi_l;

        %  Deflection angle
        dtheta_u = theta2_u - theta1_u;
        dtheta_l = theta2_l - theta1_l;
        
%         delt_tu(i) = dtheta_u;
%         delt_tl(i) = dtheta_l;
%         
%         if abs(dtheta_u) < 0.00000000001 && abs(dtheta_u)~=0
%             dtheta_u = 0;
%             p2_u = p1_u;
%         elseif abs(dtheta_l) < 0.00000000001 && abs(dtheta_l)~=0
%             dtheta_l = 0;
%             p2_l = p1_l;
%         end
%         fprintf('dtheta_u = %f degrees\n',dtheta_u*180/pi);
%         fprintf('theta2_u = %f degrees\n',theta2_u*180/pi);
%         fprintf('dtheta_l = %f degrees\n',dtheta_l*180/pi);
%         fprintf('theta2_l = %f degrees\n',theta2_l*180/pi);
        % Use shock-expansion method to compute local Mach number and pressure

        % Upper surface
        if( dtheta_u > 0.0 )
            %  Compression --- shock wave

            % Call Oblique shock wave angle function to get Beta
            beta_u = EstimateBeta(m1_u,dtheta_u,0.005);
            if isnan(beta_u)==0
                % Calculate the normal Mach number before the shock
                Mn1_u = m1_u*sin(beta_u);
                % Call Normal shock function to find Mach number (m2_u) and pressure ratio (p2_u)
                [p2_u,~,~,~,~,Mn2_u] = AppB(Mn1_u);
                m2_u = Mn2_u/sin(beta_u-dtheta_u);
%                 fprintf('Beta exists\n');
            else
%                 fprintf('Beta does not not exist\n');
                p2_u = p1_u;
                m2_u = p1_u;
            end
        else
             
            %  Expansion --- Prandtl-Meyer wave
            % Call Prandtl-Meyer function to calculate Mach number (m2_u) and pressure ratio (p2_u)

            [~,~,~,m2_u] = AppC(m1_u,-dtheta_u,0.005);
            [p0p1,~,~,~] = AppA(m1_u,gamma);
            [p0p2,~,~,~] = AppA(m2_u,gamma);
            p2_u = p0p1/p0p2;
        end

        %  Lower surface
        if( dtheta_l > 0.0 )
            %  Compression --- shock wave

            % Call Oblique shock wave angle function to get Beta
            beta_l = EstimateBeta(m1_l,dtheta_l,0.005);
            if isnan(beta_l)==0
                % Calculate the normal Mach number before the shock
                Mn1_l = m1_l*sin(beta_l);
                % Call Normal shock function to find Mach number (m2_l) and pressure ratio (p2_l)
                [p2_l,~,~,~,~,Mn2_l] = AppB(Mn1_l);
                m2_l = Mn2_l/sin(beta_l-dtheta_l);
            else
                p2_l = p1_l;
                m2_l = p1_l;
            end
        else
            %  Expansion --- Prandtl-Meyer wave

            % Call Prandtl-Meyer function to calculate Mach number (m2_l) and pressure ratio (p2_l)
            [~,~,~,m2_l] = AppC(m1_l,-dtheta_l,0.005);
            [p0p1,~,~,~] = AppA(m1_l,gamma);
            [p0p2,~,~,~] = AppA(m2_l,gamma);
            p2_l = p0p1/p0p2;
        end
%
         p2_u = p1_u*p2_u;
         p2_l = p1_l*p2_l;
%
         cp_u = qinf*(p2_u-1.0);
         cp_l = qinf*(p2_l-1.0);
%
         theta1_u = theta2_u;
         theta1_l = theta2_l;
         m1_u = m2_u;
         m1_l = m2_l;
         p1_u = p2_u;
         p1_l = p2_l;
%
         xm(i) = (x(i+1) + x(i))*0.5;
         ymu=(yu2+yu1)*0.5;
         yml=(yl2+yl1)*0.5;
         cpu(i)=cp_u;
         cpl(i)=cp_l;
%
%  Force components in the chord and its normal directions
         cn = (cp_l - cp_u)*dx;
         ca = - cp_l*dyl + cp_u*dyu;
         sum1 = sum1 + cn;
         sum2 = sum2 + ca;
%
%  Moment about the leading edge
         sum3 = sum3 - xm(i)*cn + ymu*cp_u*dyu - yml*cp_l*dyl;
%
         yu1 = yu2;
         yl1 = yl2;
%          clc;
     end
%%
%  Calculate Cl, Cd, and Cm
%%
      cl = sum1*cos(alpha) - sum2*sin(alpha);
      cd = sum2*cos(alpha) + sum1*sin(alpha);
      cm = sum3;
      t = toc(startTime);
%       close(f);
end