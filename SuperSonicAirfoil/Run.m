%% Created by Luke Patterson - 1001420303 - for the purpose of designing a supersonic airfoil in aerodynamics of compressible flow with Dr. Han

clear
close all
clc

%% First define all airfoil parameters and constraints for the sin airfoil.
c = 1;
xt = 0.25:0.05:0.8;
tmax = 0.1;
tu = 0.09:-0.01:0.01;
nseg = 128;
Minf = 3;
alpha = -5:0.5:5;
N = length(xt)^2*length(tu)*length(alpha);
total_run_iterations = length(xt)^2*length(tu)*length(alpha) + (length(xt)*length(alpha))^5 + length(xt)*length(tu)*length(alpha) ;
total_run_percentile = 0;
%% Create One Place for all the airfoils that qualify

SortByLift = {};

SortByCM = {};

%% Run Biconvex Airfoil Calculations: Geometry #1
SymmetricSin = cell(length(xt),length(tu));
num = 0;
air = 0;
f = waitbar(0,'1','Name','Calculating Pressure Distribution');
% setappdata(f,'canceling',0);

for i=1:length(xt)
    for j=1:length(tu)
%         for k=1:length(xt)
            air = air + 1;
            [x,yu] = Sine(xt(i),tu(j),c,nseg);
            tl = -(tmax - tu(j));
            [~,yl] = Sine(xt(i),tl,c,nseg);
            SymmetricSin{i,j}.X = x;
            SymmetricSin{i,j}.Xt = xt(i);
            SymmetricSin{i,j}.t = [tu(j) tl];
            SymmetricSin{i,j}.c = c;
            SymmetricSin{i,j}.Yu = yu;
            SymmetricSin{i,j}.Yl = yl;
            SymmetricSin{i,j}.A = alpha;
            SymmetricSin{i,j}.Cl = zeros(1,length(alpha));
            SymmetricSin{i,j}.Cd = zeros(1,length(alpha));
            SymmetricSin{i,j}.Cm = zeros(1,length(alpha));
            SymmetricSin{i,j}.Type = 'Biconvex';
%             fl = figure();
            plot(x,yu,x,yl);
            ylim([-2*tmax 2*tmax]);
            for a=1:length(alpha)
                total_run_percentile = total_run_percentile + 1;
                num = num + 1;
                per = num/(length(xt)*length(tu)*length(alpha));
                [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,nseg);

                name = strcat('Calculating for biconvex airfoil:');
                s = strcat('Running biconvex airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)*length(tu)));
                waitbar(per,f,s,'Name',name);

                SymmetricSin{i,j}.Cl(a) = cl;
                SymmetricSin{i,j}.Cd(a) = cd;
                SymmetricSin{i,j}.Cm(a) = cm;
                SymmetricSin{i,j}.xm{a} = xm;
                SymmetricSin{i,j}.cpu{a} = cpu;
                SymmetricSin{i,j}.cpl{a} = cpl;
                if cl >= 0.2 && abs(cm) <= 0.05
                    fprintf('Biconvex airfoil of xt: %f\tand t_upper: %f\n',xt(i),tu(j));
                    new = SymmetricSin{i,j};
                    new.Aval = a;
                    SortByLift{length(SortByLift)+1} = new;
                    SortByCM{length(SortByCM)+1} = new;
                    break
                end
            end
%             close(fl)
%         end
    end
end


%% Run flat-bottom Biconvex airfoil: Geometry #2
FlatBottomSin = cell(length(xt),length(tu));
num = 0;
air = 0;
for i=1:length(xt)
    air = air + 1;
    [x,yl] = Sine(xt(i),-tmax,c,nseg);
    yu = zeros(1,nseg+1);
    FlatBottomSin{i}.X = x;
    FlatBottomSin{i}.Xt = xt(i);
    FlatBottomSin{i}.t = [0 tmax];
    FlatBottomSin{i}.c = c;
    FlatBottomSin{i}.Yu = yu;
    FlatBottomSin{i}.Yl = yl;
    FlatBottomSin{i}.A = alpha;
    FlatBottomSin{i}.Cl = zeros(1,length(alpha));
    FlatBottomSin{i}.Cd = zeros(1,length(alpha));
    FlatBottomSin{i}.Cm = zeros(1,length(alpha));
    FlatBottomSin{i}.Type = 'Flat Top Convex';
%     fl = figure();
    plot(x,yu,x,yl);
    ylim([-2*tmax 2*tmax]);
    for a=1:length(alpha)
        total_run_percentile = total_run_percentile + 1;
        num = num + 1;
        per = num/(length(xt)*length(alpha));

        [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,nseg);

        s = strcat('Running flat bottom convex airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)));
        name = strcat('Calculating for flat bottom convex airfoil');
        waitbar(per,f,s,'Name',name);

        FlatBottomSin{i}.Cl(a) = cl;
        FlatBottomSin{i}.Cd(a) = cd;
        FlatBottomSin{i}.Cm(a) = cm;
        FlatBottomSin{i}.xm{a} = xm;
        FlatBottomSin{i}.cpu{a} = cpu;
        FlatBottomSin{i}.cpl{a} = cpl;
        if cl >= 0.2 && abs(cm) <= 0.05
            fprintf('Flat bottom sin airfoil of xt: %f\tand t: %f\n',xt(i),tmax);
            new = FlatBottomSin{i};
            new.Aval = a;
            SortByLift{length(SortByLift)+1} = new;
            SortByCM{length(SortByCM)+1} = new;
            break
        end
    end
%     close(fl)
end

%% Run Flat-top Biconvex Airfoil: Geometry #3
FlatTopSin = cell(length(xt),length(tu));
num = 0;
air = 0;
for i=1:length(xt)
    air = air + 1;
    [x,yu] = Sine(xt(i),tmax,c,nseg);
    yl = zeros(1,nseg+1);
    FlatTopSin{i}.X = x;
    FlatTopSin{i}.Xt = xt(i);
    FlatTopSin{i}.t = [tmax 0];
    FlatTopSin{i}.c = c;
    FlatTopSin{i}.Yu = yu;
    FlatTopSin{i}.Yl = yl;
    FlatTopSin{i}.A = alpha;
    FlatTopSin{i}.Cl = zeros(1,length(alpha));
    FlatTopSin{i}.Cd = zeros(1,length(alpha));
    FlatTopSin{i}.Cm = zeros(1,length(alpha));
    FlatTopSin{i,j}.Type = 'Flat Bottom Convex';
%     fl = figure();
    plot(x,yu,x,yl);
    ylim([-2*tmax 2*tmax]);
    for a=1:length(alpha)
        total_run_percentile = total_run_percentile + 1;
        num = num + 1;
        per = num/(length(xt)*length(alpha));
        [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,nseg);
        
        s = strcat('Running flat top convex airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)));
        name = strcat('Calculating for flat top convex airfoil');
        waitbar(per,f,s,'Name',name);

        FlatTopSin{i}.Cl(a) = cl;
        FlatTopSin{i}.Cd(a) = cd;
        FlatTopSin{i}.Cm(a) = cm;
        FlatTopSin{i}.xm{a} = xm;
        FlatTopSin{i}.cpu{a} = cpu;
        FlatTopSin{i}.cpl{a} = cpl;
        if cl >= 0.2 && abs(cm) <= 0.05
            fprintf('Flat top airfoil of xt: %f\tand t: %f\n',xt(i),tmax);
            new = FlatTopSin{i};
            new.Aval = a;
            SortByLift{length(SortByLift)+1} = new;
            SortByCM{length(SortByCM)+1} = new;
            break
        end
    end
%     close(fl)
end


%% Run Triangular Airfoil: Geometry #4
num = 0;
air = 0;
TriangleAirfoil = cell(length(xt),length(tu));
for i=1:length(xt)
    for j=1:length(tu)
        air = air + 1;
        [x,yu] = Triangle(xt(i),tu(j),c);
        tl = -(tmax - tu(j));
        [~,yl] = Triangle(xt(i),tl,c);
        TriangleAirfoil{i,j}.X = x;
        TriangleAirfoil{i,j}.Xt = xt(i);
        TriangleAirfoil{i,j}.t = [tu(j) tl];
        TriangleAirfoil{i,j}.c = c;
        TriangleAirfoil{i,j}.Yu = yu;
        TriangleAirfoil{i,j}.Yl = yl;
        TriangleAirfoil{i,j}.A = alpha;
        TriangleAirfoil{i,j}.Cl = zeros(1,length(alpha));
        TriangleAirfoil{i,j}.Cd = zeros(1,length(alpha));
        TriangleAirfoil{i,j}.Cm = zeros(1,length(alpha));
        TriangleAirfoil{i,j}.Type = 'Symmetric Triangle';
%         fl = figure();
        plot(x,yu,x,yl);
        ylim([-2*tmax 2*tmax]);
        for a=1:length(alpha)
            total_run_percentile = total_run_percentile + 1;
            num = num + 1;
            per = num/(length(xt)*length(alpha)*length(tu));
            [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,2);

            s = strcat('Running symmetric triangle airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)*length(tu)));
            name = strcat('Calculating for triangular airfoil');
            waitbar(per,f,s,'Name',name);
            
            TriangleAirfoil{i,j}.Cl(a) = cl;
            TriangleAirfoil{i,j}.Cd(a) = cd;
            TriangleAirfoil{i,j}.Cm(a) = cm;
            TriangleAirfoil{i,j}.xm{a} = xm;
            TriangleAirfoil{i,j}.cpu{a} = cpu;
            TriangleAirfoil{i,j}.cpl{a} = cpl;
            if cl >= 0.2 && abs(cm) <= 0.05
                fprintf('Triangle airfoil of xt: %f\tand t: %f\n',xt(i),tu(j));
                new = TriangleAirfoil{i,j};
                new.Aval = a;
                SortByLift{length(SortByLift)+1} = new;
                SortByCM{length(SortByCM)+1} = new;
                break
            end
        end
%         close(fl)
    end
end

%% Run Top Trianglular Airfoil: Geometry #5
num = 0;
air = 0;

TriangleTopAirfoil = cell(length(xt));
for i=1:length(xt)
    air = air + 1;
    [x,yu] = Triangle(xt(i),tmax,c);
    yl = zeros(1,3);
    TriangleTopAirfoil{i}.X = x;
    TriangleTopAirfoil{i}.Xt = xt(i);
    TriangleTopAirfoil{i}.t = [tmax 0];
    TriangleTopAirfoil{i}.c = c;
    TriangleTopAirfoil{i}.Yu = yu;
    TriangleTopAirfoil{i}.Yl = yl;
    TriangleTopAirfoil{i}.A = alpha;
    TriangleTopAirfoil{i}.Cl = zeros(1,length(alpha));
    TriangleTopAirfoil{i}.Cd = zeros(1,length(alpha));
    TriangleTopAirfoil{i}.Cm = zeros(1,length(alpha));
    TriangleTopAirfoil{i}.Type = 'Flat Bottom Triangle';
%     fl = figure();
    plot(x,yu,x,yl);
    ylim([-2*tmax 2*tmax]);
    for a=1:length(alpha)
        total_run_percentile = total_run_percentile + 1;
        num = num + 1;
        per = num/(length(xt)*length(alpha));
        s = strcat('Running flat bottom triangular airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)));
        [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,2);

        name = strcat('Calculating for flat bottom triangular airfoil:');
        waitbar(per,f,s,'Name',name);

        TriangleTopAirfoil{i}.Cl(a) = cl;
        TriangleTopAirfoil{i}.Cd(a) = cd;
        TriangleTopAirfoil{i}.Cm(a) = cm;
        TriangleTopAirfoil{i}.xm{a} = xm;
        TriangleTopAirfoil{i}.cpu{a} = cpu;
        TriangleTopAirfoil{i}.cpl{a} = cpl;
        if cl >= 0.2 && abs(cm) <= 0.05
            fprintf('Flat bottom triangular airfoil of xt: %f\tand t: %f\n',xt(i),tmax);
            new = TriangleTopAirfoil{i};
            new.Aval = a;
            SortByLift{length(SortByLift)+1} = new;
            SortByCM{length(SortByCM)+1} = new;
            break
        end
    end
%     close(fl)
end


%% Run Bottom Trianglular Airfoil: Geometry #6
num = 0;
air = 0;
TriangleBottomAirfoil = cell(length(xt));
for i=1:length(xt)
    air = air + 1;
    [x,yl] = Triangle(xt(i),-tmax,c);
    yu = zeros(1,3);
    TriangleBottomAirfoil{i}.X = x;
    TriangleBottomAirfoil{i}.Xt = xt(i);
    TriangleBottomAirfoil{i}.t = [0 tmax];
    TriangleBottomAirfoil{i}.c = c;
    TriangleBottomAirfoil{i}.Yu = yu;
    TriangleBottomAirfoil{i}.Yl = yl;
    TriangleBottomAirfoil{i}.A = alpha;
    TriangleBottomAirfoil{i}.Cl = zeros(1,length(alpha));
    TriangleBottomAirfoil{i}.Cd = zeros(1,length(alpha));
    TriangleBottomAirfoil{i}.Cm = zeros(1,length(alpha));
    TriangleBottomAirfoil{i}.Type = 'Flat Top Triangle';
%     fl = figure();
    plot(x,yu,x,yl);
    ylim([-2*tmax 2*tmax]);
    for a=1:length(alpha)
        total_run_percentile = total_run_percentile + 1;
        num = num + 1;
        per = num/(length(xt)*length(alpha));
        s = strcat('Running flat top triangular airfoil ',{' '},num2str(air),{' of '},num2str(length(xt)));
        [cl,cd,cm,xm,cpu,cpl,t] = CalcCoefficients(Minf,alpha(a),x,yu,yl,2);
        
%         percent = total_run_percentile / total_run_iterations;
%         remaining = total_run_iterations - total_run_percentile;
%         time_remaining = remaining * t;
%         mins = time_remaining/60;
%         rmins = floor(mins);
%         seconds = floor((mins-rmins)*60);
        name = strcat('Calculating for flat bottom triangular airfoil');
        waitbar(per,f,s,'Name',name);

        TriangleBottomAirfoil{i}.Cl(a) = cl;
        TriangleBottomAirfoil{i}.Cd(a) = cd;
        TriangleBottomAirfoil{i}.Cm(a) = cm;
        TriangleBottomAirfoil{i}.xm{a} = xm;
        TriangleBottomAirfoil{i}.cpu{a} = cpu;
        TriangleBottomAirfoil{i}.cpl{a} = cpl;
        if cl >= 0.2 && abs(cm) <= 0.05
            fprintf('Flat bottom triangle airfoil of xt: %f\tand t: %f\n',xt(i),tmax);
            new = TriangleBottomAirfoil{i};
            new.Aval = a;
            SortByLift{length(SortByLift)+1} = new;
            SortByCM{length(SortByCM)+1} = new;
            break
        end
    end
%     close(fl)
end
close(f);
close all


%% Choose the best airfoil

    
for i=1:length(SortByLift)-1
    current = SortByLift{i};
    next = SortByLift{i+1};

    if max(current.Cl) < max(next.Cl)
        SortByLift{i} = next;
        SortByLift{i+1} = current;
    end

end

for i=1:length(SortByCM)-1
    current = SortByCM{i};
    next = SortByCM{i+1};

    if abs(max(current.Cm)) > abs(max(next.Cm))
        SortByCM{i} = next;
        SortByCM{i+1} = current;
    end

end

best = SortByLift{1};

cl = best.Cl;
cd = best.Cd;
clcd = cl/cd;

CLCD = {};

for i=1:length(SortByLift)-1
    current = SortByLift{i};
    next = SortByLift{i+1};
    cl = current.Cl;
    cd = current.Cd;
    clcd = cl./cd;
    SortByLift{i}.clcd = clcd;
    CLCD{i} = SortByLift{i};
end
%%
for k=1:length(CLCD)
    for i=1:length(CLCD)-1
        current = CLCD{i};
        next = CLCD{i+1};
        if current.clcd(current.Aval) < next.clcd(next.Aval)
            CLCD{i} = next;
            CLCD{i+1} = current;
        end
    end
end
%%
best = CLCD{1};
val = best.Aval;
x = best.X;
yu = best.Yu;
yl = best.Yl;
cpu = best.cpu{val};
cpl = best.cpl{val};
%% Plot Best Airfoil
x = 0:1/(nseg):1;
plot(x,yu,'-.k',x,yl,'-.k')
hold on
x = 0:1/(nseg-1):1;
p1=plot(x,cpu,'-*b');
p2=plot(x,cpl,'-or');
titl = strcat({'Best fit airfoil:'},{' '},best.Type);
title(titl)
xlabel('x chord');
ylabel('C_P');
legend([p1 p2],'Upper surface','Lower surface','Location','NorthEast');
s = sprintf('Mach No. = %d\nAoA = %.2f\nxt = %.2f\ntu = %.2f\ntl = %.2f\nN = %d\nC_L = %f\nC_D = %f\nC_M = %f\nC_L/C_D = %f',Minf,best.A(best.Aval),best.Xt,best.t(1),best.t(2),nseg,best.Cl(best.Aval),best.Cd(best.Aval),best.Cm(best.Aval),best.clcd(best.Aval));
text(.8,.45,s)
hold off

%% Plot Polar Graph
figure()
line(best.clcd,best.Cl,'Color','r','Marker','*')
blah = num2str(best.A');
blaher = cellstr(blah);
text(best.clcd+.1,best.Cl-.005,blaher,'FontSize',10);
xlabel('C_L/C_D');
ylabel('C_L');
ax = gca;
ax.XColor = 'k';
ax.YColor = 'k';

new_axis = axes('Position',ax.Position,'XAxisLocation','top','YAxisLocation','right','Color','none');
line(best.Cd,best.Cl,'Parent',new_axis,'Color','b','Marker','o');
bleh = num2str(best.A');
bleher = cellstr(bleh);
text(new_axis,best.Cd+.2,best.Cl-.005,bleher,'FontSize',10);
xlabel(new_axis,'C_D');
ylabel(new_axis,'C_L');









