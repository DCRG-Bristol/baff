% model = baff.Model;
% model.Name = 'DemoWing';
clear all

BarThickness = 4e-3;
BarWidth = 25e-3;
WingChord = 0.12;
BarChordwisePos = 0.25;
L = 1;
eta_hinge = 0.8;
% Make Aero Bar
mainBeam = baff.Wing.UniformWing(L*eta_hinge,BarThickness,BarWidth...
    ,baff.Material.Stainless400,WingChord,BarChordwisePos,"NAeroStations",10);
mainBeam.Name = 'Wing 1';
twists = linspace(0,10,10);
for i = 1:10
    mainBeam.AeroStations(i).Twist = twists(i);
end
% Add Control Surface
mainBeam.ControlSurfaces(1) =  baff.ControlSurface("Ail",[0.7 0.9],[0.25 0.25]);

% Add Masses
xs = [-21,-21,-21,-21,-21,-17]*1e-3 + (BarChordwisePos-0.25)*WingChord;
ys = [100,240,380,520,660,767]*1e-3;
mass = [ones(1,5)*0.075,0.056];
inertias = [ones(1,5)*82,26;ones(1,5)*73,32;ones(1,5)*151,56]*1e-6;
% load('Wing2ndMass.mat')
for i = 1:length(xs)
    tmp_mass = baff.Mass(mass(i));
    tmp_mass.Eta = ys(i)/(L*eta_hinge);
    tmp_mass.Offset(1) = xs(i);
    tmp_mass.Name = sprintf('tmp_mass_%.0f',i);
    tmp_mass.InertiaTensor = diag(inertias(:,i)');
    tmp_mass.mass= mass(i);
    mainBeam.add(tmp_mass);
end

% Add Constraint
con = baff.Constraint("ComponentNums",123456,"eta",0,"Name","Root Connection");
con.add(mainBeam);

%draw
f = figure(1);
clf;
hold on
con.draw();
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal

delete test.h5
baff.Model.GenTempHdf5('test.h5');

tic;
model = baff.Model;
model.AddElement(con);
model.UpdateIdx();
model.ToBaff('test.h5');
toc;

tic;
model2 = baff.Model.FromBaff('test.h5');
toc;

f = figure(2);
clf;
hold on
model2.draw(f);
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal





