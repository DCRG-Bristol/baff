%% create a single Station
st1 = baff.station.Aero(0,1,0.25);

%% Test 1: test equality
st1 = baff.station.Aero(0,1,0.25);
st2 = baff.station.Aero(0,1,0.25);
st3 = baff.station.Aero(1,1,0.25);
%manually test
assert(st1.Eta == st2.Eta);
assert(all(st1.EtaDir == st2.EtaDir));
assert(all(st1.StationDir == st2.StationDir));
assert(st1.Chord == st2.Chord);
assert(st1.Twist == st2.Twist);
assert(st1.BeamLoc == st2.BeamLoc);
assert(st1.Airfoil == st2.Airfoil);
assert(st1.ThicknessRatio == st2.ThicknessRatio);
assert(st1.LiftCurveSlope == st2.LiftCurveSlope);
assert(st1.LinearDensity == st2.LinearDensity);
assert(all(st1.LinearInertia(:) == st2.LinearInertia(:)));
assert(st1.MassLoc == st2.MassLoc);

% use inbuilt check
assert(st1==st2);
assert(st1~=st3);

%% Test 2: test concatination
st1 = baff.station.Aero(0,1,0.25);
st2 = baff.station.Aero(1,1,0.25);
sts = st1 & st2;
assert(all(sts.Eta == [st1.Eta,st2.Eta]));
assert(all(sts.EtaDir == [st1.EtaDir,st2.EtaDir],"all"));
assert(all(sts.Chord == [st1.Chord,st2.Chord]));
assert(all(sts.Twist == [st1.Twist,st2.Twist]));
assert(all(sts.BeamLoc == [st1.BeamLoc,st2.BeamLoc]));
assert(all(sts.Airfoil == [st1.Airfoil,st2.Airfoil]));
assert(all(sts.ThicknessRatio == [st1.ThicknessRatio,st2.ThicknessRatio]));
assert(all(sts.LiftCurveSlope == [st1.LiftCurveSlope,st2.LiftCurveSlope]));
assert(all(sts.LinearDensity == [st1.LinearDensity,st2.LinearDensity]));
assert(all(sts.LinearInertia == cat(3,st1.LinearInertia,st2.LinearInertia),"all"));
assert(all(sts.MassLoc == [st1.MassLoc,st2.MassLoc]));

%% Test 3: distribute station from 0 to 1 eta
st1 = baff.station.Aero(0,1,0.25);
sts = st1.Duplicate(0:0.1:1);
assert(sts.N == 11);
%extract the 5th element
st5 = sts.GetIndex(5);
assert(st5.Eta == 0.4);

%% Test 4: interpolation
st1 = baff.station.Aero(0,1,0.25);
st2 = baff.station.Aero(1,0.5,0.5);
sts = [st1 st2];
sts_i = sts.interpolate(6,"linear");
st_test = sts_i.GetIndex(3);
assert(st_test.Chord==0.8);
assert(st_test.BeamLoc==0.35);

sts_i2 = copy(sts_i);

sts_i2.SetIndex(3,st2);
st_test = sts_i2.GetIndex(3);
assert(st_test.Chord==0.5);
assert(st_test.BeamLoc==0.5);
assert(sts_i2.GetIndex(3)~=sts_i.GetIndex(3))
%% Test 5: Area & Volume Calcs
st1 = baff.station.Aero(0,1,0.25);
st2 = baff.station.Aero(1,0.5,0.5);
sts = [st1 st2];
sts_i = sts.interpolate(6,"linear");

A_actual = (1+0.5)/2;
assert(sts_i.GetNormArea == A_actual)
assert(sts_i.GetMeanChord == 0.75)
assert(round(sts_i.GetMGC,2) == 0.79)
assert(round(sts_i.GetNormVolume,2) == 0.40)
assert(round(sts_i.GetNormVolume([0.15 0.55]),2) == 0.22)





