function [a,c,type,enum] = returnA(n,m,ks,kc,kb,h,s,Tinf,q_dot)
    if m==1 && n~=10 && (n~=1 || n~=19)  % node type 1 boundary condition 1
        a = [0 1/2 1 1/2 -2];
        c = 0;
        type = 1;
        enum = 1;
    elseif m==28 && n~=10 && (n~=1 || n~=19) % node type 1 boundary condition 2
        a = [1 1/2 0 1/2 -2];
        c = 0;
        type = 1;
        enum = 1.5;
    end

    if (n==19) && (m~=1 || m~=28) % node type 2 boundary condition 1
        a = [ 1 0 1 2 -2*(2+h*s/ks) ];
        c = -2*h*s*Tinf/ks;
        type = 2;
        enum = 2;
    elseif (n==1) && (m~=1 || m~=28) % node type 2 boundary condition 2
        a = [ 1 2 1 0 -2*(2+h*s/kb) ];
        c = -2*h*s*Tinf/kb;
        type = 2;
        enum = 2.5;
    end

    if (n~=1 && n~=10 && n~=19) && (m>1 && m<28) % node type 3 boundary condition 1
        a = [1 1 1 1 -4];
        c = 0;
        type = 3;
        enum = 3;
    end

    if (n==10) && (m<10 || m>19) % node type 4 boundary condition 1
        a = [(ks+kb)/2 ks (ks+kb)/2 kb (-2*ks-2*kb)];
        c = 0;
        type = 4;
        enum = 4;
    end
    if n==10 && m==1 % node type 4 boundary condition 2
        a = [0 ks (ks+kb)/2 kb -3/2*(ks+kb)];
        c = 0;
        type = 4;
        enum = 4.3;
    end
    if n==10 && m==28 % node type 4 boundary condition 3
        a = [(ks+kb)/2 ks 0 kb -3/2*(ks+kb)];
        c = 0;
        type = 4;
        enum = 4.6;
    end

    if n==7 && m==19 % node type 5 boundary condition 1
        a = [ (kc+kb)/2 (kc+kb)/2 kb kb -(kc+3*kb) ];
        c = -q_dot*s^2/4;
        type = 5;
        enum = 5;
    elseif n==7 && m==10 % node type 5 boundary condition 2
        a = [ kb (kc+kb)/2 (kc+kb)/2 kb -(kc+3*kb) ];
        c = -q_dot*s^2/4;
        type = 5;
        enum = 5.5;
    end

    if (n==1 && m==1) % node type 6 boundary condition 1
        a = [ 0 1 1 0 -(h*s/kb + 2) ];
        c = -h*s*Tinf/kb;
        type = 6;
        enum = 6;
    elseif n==19 && m==1 % node type 6 boundary condition 2
        a = [ 0 0 1 1 -(h*s/ks + 2) ];
        c = -h*s*Tinf/ks;
        type = 6;
        enum = 6.25;
    elseif n==1 && m==28 % node type 6 boundary condition 3
        a = [ 1 1 0 0 -(h*s/kb + 2) ];
        c = -h*s*Tinf/kb;
        type = 6;
        enum = 6.5;
    elseif n==19 && m==28 % node type 6 boundary condition 4
        a = [ 1 0 0 1 -(h*s/ks + 2) ];
        c = -h*s*Tinf/ks;
        type = 6;
        enum = 6.75;
    end

    if n==7 && (m<19 && m>10) % node type 7 boundary condition 1
        a = [ (kb+kc)/2 kc (kb+kc)/2 kb -(2*kb+2*kc) ];
        c = -q_dot*s^2/2;
        type = 7;
        enum = 7;
    elseif n==10 && (m<19 && m>10) % node type 7 boundary condition 2
        a = [ (ks+kc)/2 ks (ks+kc)/2 kc -(2*ks+2*kc) ];
        c = -q_dot*s^2/2;
        type = 7;
        enum = 7.25;
    elseif m==10 && (n<10 && n>7) % node type 7 boundary condition 3
        a = [ kb (kb+kc)/2 kc (kb+kc)/2 -(2*kb+2*kc) ];
        c = -q_dot*s^2/2;
        type = 7;
        enum = 7.5;
    elseif m==19 && (n<10 && n>7) % node type 7 boundary condition 3
        a = [ kc (kb+kc)/2 kb (kb+kc)/2 -(2*kb+2*kc) ];
        c = -q_dot*s^2/2;
        type = 7;
        enum = 7.75;
    end

    if (n<10 && n>7) && (m>10 && m<19) % node type 8 boundary condition 1
        a = [1 1 1 1 -4];
        c = -q_dot*s^2/kc;
        type = 8;
        enum = 8;
    end

    if n==10 && m==19 % node type 9 boundary condition 1
        a = [ (ks+kc)/2 ks (kb+ks)/2 (kc+kb)/2 (-(ks+kc)/2-ks-(kb+ks)/2-(kc+kb)/2) ];
        c = -q_dot*s^2/4;
        type = 9;
        enum = 9;
    elseif n==10 && m==10 % node type 9 boundary condition 2
        a = [ (kb+ks)/2 ks (ks+kc)/2 (kc+kb)/2 (-(ks+kb)/2-ks-(kc+ks)/2-(kc+kb)/2) ];
        c = -q_dot*s^2/4;
        type = 9;
        enum = 9.5;
    end
    
end