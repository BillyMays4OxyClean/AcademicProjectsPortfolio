%% Created by Luke Patterson for the Unpowered coast phase of Aspiration
clear
close all
clc

%% Unit Declaration
units = 'SI';

%% Full Ellipse All-Body Generation

Sref = 74;
Tau = 0.162;
Sweep = 74;
lpil = 0.667;

test = Ellipsoid_Body;
test.Units = units;
test.nseg = 2^6;
test = test.Generate_Ellipsoid_Body(Sref,Tau,Sweep,lpil);

fc = FlightCondition;
fc.Units = units;
fc.Name = 'Reentry';
fc.AoA = 15;

A = 100000:-1000:75000;
M = 1.5:.05:3.0;

for a = 1:length(A)
    for m = 1:length(M)
        An(a,m) = A(a);
        Mn(a,m) = M(m);
        fc.Altitude = A(a);
        fc = fc.SetSpeed("Mach",M(m));
        [CL(a,m),L(a,m)] = test.CalculateLift(fc);
        [CD(a,m),D(a,m),~] = test.CalculateDrag(fc);
        LD(a,m) = CL(a,m)/CD(a,m);
    end
end

if strcmp(units,'SI')
    unit = "N";
elseif strcmp(units,'FPS')
    unit = "lb_f";
end

%% Plotting Dimensionalized Values
close all
A = surf(An/1000,Mn,L);

title("Lift for Varied Altitude and Mach number")
xlabel("Altitude, km")
ylabel("Mach")
zlabel("Lift, "+unit)

A.FaceColor = 'b';
A.FaceAlpha = .75;
A.EdgeColor = 'none';

figure()
B = surf(An/1000,Mn,D);
B.FaceColor = 'k';
B.FaceAlpha = .75;
B.EdgeColor = 'none';

title("Drag for Varied Altitude and Mach number")
xlabel("Altitude, km")
ylabel("Mach")
zlabel("Drag, "+unit)

figure()
C = surf(An/1000,Mn,LD);
C.FaceColor = 'r';
C.FaceAlpha = .75;
C.EdgeColor = 'none';

title("L/D for Varied Altitude and Mach number")
xlabel("Altitude, km")
ylabel("Mach")
zlabel("L/D")

%% Ploting Nondimensionalized Values
figure()
A = surf(An/1000,Mn,CL);
A.FaceColor = 'b';
A.FaceAlpha = .75;
A.EdgeColor = 'none';

title("C_L for Varied Altitude and Mach number")
xlabel("Altitude, km")
ylabel("Mach")
zlabel("C_L")

figure()
B = surf(An/1000,Mn,CD);
B.FaceColor = 'k';
B.FaceAlpha = .75;
B.EdgeColor = 'none';

title("C_D for Varied Altitude and Mach number")
xlabel("Altitude, km")
ylabel("Mach")
zlabel("C_D")

