clear all

fus_rad = 0.055;
span = 1.5;
hinge_eta = 0.8;
beam_loc = 0.25;
Chord = 0.12;
flare = 20;
fold = 45;

%empenage setting
hSpan = 0.4;
hChord = 0.07;
vSpan = 0.15;
vChord = 0.07;

%% create fuselage
cockpit = baff.model.BluffBody.SemiSphere(0.15,0.055);

fus_body = baff.model.BluffBody.Cylinder(0.652-0.082,0.055);

fus_tail = baff.model.BluffBody.Cone(0.14,0.055,0.02);
[fus_tail.Stations.EtaDir] = deal([0;0.14;0.005-0.02-0.005]./0.14);

fuselage = cockpit + fus_body + fus_tail;
fuselage.A
%% create Wing
Wing = baff.model.Wing.UniformWing(span*hinge_eta,0.1,0.1,...
    baff.model.Material.Stiff,Chord,beam_loc,"NAeroStations",11);
Wing.A = baff.util.rotz(-90);
Wing.Eta = 0.5;
Wing.Offset = [-span*hinge_eta*0.5;0;fus_rad*0.66];
fuselage.add(Wing);

%% create RHS Wingtip
hinge_rhs = baff.model.Hinge();
hinge_rhs.HingeVector = baff.util.rotz(flare)*[1;0;0];
hinge_rhs.Rotation = -fold;
hinge_rhs.Eta = 1;
hinge_rhs.Offset = [(beam_loc-0.5)*Chord 0 0];
hinge_rhs.Name = 'SAH_RHS';
Wing.add(hinge_rhs);

Wingtip_rhs = baff.model.Wing.UniformWing(span*(1-hinge_eta)*0.5,0.1,0.1,...
    baff.model.Material.Stiff,Chord,beam_loc,"NAeroStations",5);
Wingtip_rhs.Offset = [-(beam_loc-0.5)*Chord;0;0];
hinge_rhs.add(Wingtip_rhs);

%% create RHS Wingtip
hinge_lhs = baff.model.Hinge();
hinge_lhs.HingeVector = baff.util.rotz(-flare)*[1;0;0];
hinge_lhs.Rotation = fold;
hinge_lhs.Eta = 0;
hinge_lhs.Offset = [(beam_loc-0.5)*Chord 0 0];
hinge_lhs.Name = 'SAH_lhs';
Wing.add(hinge_lhs);

Wingtip_lhs = baff.model.Wing.UniformWing(span*(1-hinge_eta)*0.5,0.1,0.1,...
    baff.model.Material.Stiff,Chord,beam_loc,"NAeroStations",5);
Wingtip_lhs.Offset = [-(beam_loc-0.5)*Chord;0;0];
Wingtip_lhs.A = baff.util.rotx(180);
hinge_lhs.add(Wingtip_lhs);


%% create htp
Htp = baff.model.Wing.UniformWing(hSpan,0.1,0.1,...
    baff.model.Material.Stiff,hChord,beam_loc,"NAeroStations",11);
Htp.A = baff.util.rotz(-90);
Htp.Eta = 0.93;
Htp.Offset = [-hSpan*0.5;0;-fus_rad*0.25];
fuselage.add(Htp);

%% create vtp
Vtp = baff.model.Wing.UniformWing(vSpan,0.1,0.1,...
    baff.model.Material.Stiff,vChord,beam_loc,"NAeroStations",11);
Vtp.A = baff.util.rotz(-90)*baff.util.rotx(-90);
Vtp.Eta = 0.93;
Vtp.Offset = [0;0;-fus_rad*0.25];
fuselage.add(Vtp);

%% create model
delete test.h5
baff.model.Model.GenTempHdf5('test.h5');

tic;
model = baff.model.Model;
model.AddElement(fuselage);
model.UpdateIdx();
model.ToBaff('test.h5');
toc;

figure(1);
clf;
hold on
model.draw()
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal

%% read file and plot again
tic;
model2 = baff.model.Model.FromBaff('test.h5');
toc;
figure(2);
clf;
hold on
model2.draw;
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal