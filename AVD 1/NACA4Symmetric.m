%% Created by Luke Patterson for the purposes of generating a Four-Digit NACA Cambered or Uncambered Airfoil Section
function [xu,yu,xl,yl] = NACA4Symmetric(t,c,nseg)
    x = 0:c/(nseg-1):c;
    
    yt = t/0.2 * ( 0.29690*sqrt(x/c) - 0.12600*x/c - 0.35160 * (x/c).^2 + 0.28430 * (x/c).^3 - 0.10150 * (x/c).^4);
    
    xu = x;
    yu = yt;
    
    xl = x;
    yl = -yt;
    
    xl = xl * c;
    yl = yl * c;
    xu = xu * c;
    yu = yu * c;
    
    NACA = t*100;
    NACUh = string(sum(NACA));
    airfoil = cellstr(strcat({'Outputing a NACA'},{' 00'},NACUh,{' '},{'Wing Section\n'}));
    airfoil = string(airfoil);
    fprintf(airfoil) 
end