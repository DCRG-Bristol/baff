%% create a single Station
st1 = baff.station.Body(0,A=1,J=0.1,radius=2);

%% Test 1: test equality
st1 = baff.station.Body(0,A=1,J=0.1,radius=2);
st2 = baff.station.Body(0,A=1,J=0.1,radius=2);
st3 = baff.station.Body(0,A=1,J=0.1,radius=1);
%manually test
assert(st1.Eta == st2.Eta);
assert(all(st1.EtaDir == st2.EtaDir));
assert(all(st1.StationDir == st2.StationDir));
assert(st1.A == st2.A);
assert(all(st1.I(:) == st2.I(:)));
assert(st1.J == st2.J);
assert(all(st1.tau(:) == st2.tau(:)));
assert(st1.Mat == st2.Mat);
assert(st1.Radius == st2.Radius);
% use inbuilt check
assert(st1==st2);
assert(st1~=st3);

%% Test 2: test concatination
st1 = baff.station.Body(0,A=1,J=0.1,radius=2);
st2 = baff.station.Body(1,A=0.5,J=0.01,radius=1);
sts = st1 & st2;
assert(all(sts.Eta == [st1.Eta,st2.Eta]));
assert(all(sts.EtaDir == [st1.EtaDir,st2.EtaDir],"all"));
assert(all(sts.StationDir == [st1.StationDir,st2.StationDir],"all"));
assert(all(sts.A == [st1.A,st2.A]));
assert(all(sts.J == [st1.J,st2.J]));
assert(all(sts.I == cat(3,st1.I,st2.I),"all"));
assert(all(sts.tau == cat(3,st1.tau,st2.tau),"all"));
assert(all(sts.Mat == [st1.Mat,st2.Mat]));
assert(all(sts.Radius == [st1.Radius,st2.Radius]));

%% Test 3: distribute station from 0 to 1 eta
st1 = baff.station.Body(0,A=1,J=0.1,radius=2);
sts = st1.Duplicate(0:0.1:1);
assert(sts.N == 11);
%extract the 5th element
st5 = sts.GetIndex(5);
assert(st5.Eta == 0.4);

%% Test 4: interpolation
st1 = baff.station.Body(0,A=1,J=0.1,radius=2);
st2 = baff.station.Body(1,A=0.5,J=0.05,radius=1);
sts = [st1 st2];
sts_i = sts.interpolate(6,"linear");
st_test = sts_i.GetIndex(3);
assert(st_test.A==0.8);
assert(st_test.J==0.08);
assert(st_test.Radius==1.6);

sts_i2 = copy(sts_i);
sts_i2.SetIndex(3,st2);
st_test = sts_i2.GetIndex(3);
assert(st_test.A==0.5);
assert(st_test.Radius==1);
assert(sts_i2.GetIndex(3)~=sts_i.GetIndex(3))

%% Test 5: Volume
st1 = baff.station.Body(0,A=1,J=0.1,radius=1);
st2 = baff.station.Body(1,A=0.5,J=0.01,radius=1);
sts = [st1 st2];
assert(sts.GetNormVolume == pi)






