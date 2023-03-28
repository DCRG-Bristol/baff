classdef EqualityTest < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test base Elements
        function ElementEqTest(testCase)
            ele1 = baff.Element("A",rand(3),"Offset",rand(3,1),"eta",0.5,"Name","Test");
            ele2 = baff.Element("A",rand(3),"Offset",rand(3,1),"eta",0.5,"Name","Test2");
            ele3 = baff.Element("A",ele1.A,"Offset",ele1.Offset,"eta",0.5,"Name","Test3");
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function MaterialEqTest(testCase)
            ele1 = baff.Material(1,2,3);
            ele2 = baff.Material(1,3,3);
            ele3 = baff.Material(1,2,3);

            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);
            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function ControlSurfacelEqTest(testCase)
            ele1 = baff.ControlSurface('test',rand(1,2),rand(1,2));
            ele2 = baff.ControlSurface('test',rand(1,2),rand(1,2));
            ele3 = baff.ControlSurface('test',ele1.Etas,ele1.pChord);

            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);
            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        %% test stations
        function BeamStationsEqTest(testCase)
            st1 = baff.station.Beam(0,"A",2,"EtaDir",[0;0.4;0],"I",rand(3),"tau",rand(3));
            st2 = baff.station.Beam(0,"A",2,"EtaDir",[0;0.4;0],"I",rand(3),"tau",rand(3));
            st3 = baff.station.Beam(0,"A",2,"EtaDir",[0;0.4;0],"I",st1.I,"tau",st1.tau);
            testCase.assertTrue(st1 == st3);
            testCase.assertFalse(st1 ~= st3);

            testCase.assertFalse(st1 == st2);
            testCase.assertTrue(st1 ~= st2);
        end
        function BodyStationsEqTest(testCase)
            st1 = baff.station.Body(0,"A",2,"EtaDir",[0;0.4;0],"I",rand(3),"radius",rand(1));
            st2 = baff.station.Body(0,"A",2,"EtaDir",[0;0.4;0],"I",rand(3),"radius",rand(1));
            st3 = baff.station.Body(0,"A",2,"EtaDir",[0;0.4;0],"I",st1.I,"radius",st1.Radius);
            testCase.assertTrue(st1 == st3);
            testCase.assertFalse(st1 ~= st3);

            testCase.assertFalse(st1 == st2);
            testCase.assertTrue(st1 ~= st2);
        end
        function AeroStationsEqTest(testCase)
            st1 = baff.station.Aero(0,rand(1),rand(1),"EtaDir",rand(3,1),"Twist",rand(1));
            st2 = baff.station.Aero(0.1,rand(1),rand(1),"EtaDir",rand(3,1),"Twist",rand(1));
            st3 = baff.station.Aero(0,st1.Chord,st1.BeamLoc,"EtaDir",st1.EtaDir,"Twist",st1.Twist);
            testCase.assertTrue(st1 == st3);
            testCase.assertFalse(st1 ~= st3);

            testCase.assertFalse(st1 == st2);
            testCase.assertTrue(st1 ~= st2);
        end
        %% test beam-like Elements
        function BeamEqTest(testCase)
            st = baff.station.Beam(0) + [0,0.5,1];
            ele1 = baff.Beam("eta",0,"Stations",st);
            ele2 = baff.Beam("eta",0.5,"Stations",st(1) + (0:0.2:1));
            ele3 = baff.Beam("eta",0,"Stations",st);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function BodyEqTest(testCase)
            st = baff.station.Body(0,"radius",2) + [0,0.5,1];
            ele1 = baff.BluffBody("eta",0,"Stations",st);
            ele2 = baff.BluffBody("eta",0.5,"Stations",st(1) + (0:0.2:1));
            ele3 = baff.BluffBody("eta",0,"Stations",st);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function WingEqTest(testCase)
            st = baff.station.Beam(0) + [0,0.5,1];
            aSt = baff.station.Aero(0,2,0.4) + (0:0.3:1.2);
            ele1 = baff.Wing(aSt,"BeamStations",st,"eta",0,"EtaLength",2);
            ele2 = baff.Wing(aSt(1) + (0:0.2:1),"BeamStations",st,"eta",0.3,"EtaLength",1);
            ele3 = baff.Wing(aSt,"BeamStations",st,"eta",0,"EtaLength",2);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        %% test other elements
        function ConstraintEqTest(testCase)
            ele1 = baff.Constraint("ComponentNums",123456);
            ele2 = baff.Constraint("ComponentNums",1256);
            ele3 = baff.Constraint("ComponentNums",123456);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function HingeEqTest(testCase)
            ele1 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele2 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele3 = baff.Hinge("HingeVector",ele1.HingeVector,"Rotation",ele1.Rotation);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function MassEqTest(testCase)
            ele1 = baff.Mass(rand(1),"Iyy",rand(1));
            ele2 = baff.Mass(rand(1),"Iyy",rand(1));
            ele3 = baff.Mass(ele1.mass,"Iyy",ele1.InertiaTensor(2,2));
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        function PointEqTest(testCase)
            ele1 = baff.Point("Force",rand(3,1),"Moment",rand(3,1));
            ele2 = baff.Point("Force",rand(3,1),"Moment",rand(3,1));
            ele3 = baff.Point("Force",ele1.Force,"Moment",ele1.Moment);
            testCase.assertTrue(ele1 == ele3);
            testCase.assertFalse(ele1 ~= ele3);

            testCase.assertFalse(ele1 == ele2);
            testCase.assertTrue(ele1 ~= ele2);
        end
        %% test model
        function ChildrenEqTest(testCase)
            ele1 = baff.Constraint("ComponentNums",123456);
            ele2 = baff.Beam("eta",0);
            ele3 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele2.add(ele3);
            ele1.add(ele2);

            ele4 = baff.Constraint("ComponentNums",123456);
            ele5 = baff.Beam("eta",0);
            ele6 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele5.add(ele6);
            ele4.add(ele5);

            ele7 = baff.Constraint("ComponentNums",123456);
            ele8 = baff.Beam("eta",0);
            ele9 = baff.Hinge("HingeVector",ele3.HingeVector,"Rotation",ele3.Rotation);
            ele8.add(ele9);
            ele7.add(ele8);

            testCase.assertTrue(ele1 == ele7);
            testCase.assertFalse(ele1 ~= ele7);

            testCase.assertFalse(ele1 == ele4);
            testCase.assertTrue(ele1 ~= ele4);
        end
        function ModelEqTest(testCase)
            ele1 = baff.Constraint("ComponentNums",123456);
            ele2 = baff.Beam("eta",0);
            ele3 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele2.add(ele3);
            ele1.add(ele2);
            mod1 = baff.Model();
            mod1.AddElement(ele1);

            ele4 = baff.Constraint("ComponentNums",123456);
            ele5 = baff.Beam("eta",0);
            ele6 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1));
            ele5.add(ele6);
            ele4.add(ele5);
            mod2 = baff.Model();
            mod2.AddElement(ele4);

            ele7 = baff.Constraint("ComponentNums",123456);
            ele8 = baff.Beam("eta",0);
            ele9 = baff.Hinge("HingeVector",ele3.HingeVector,"Rotation",ele3.Rotation);
            ele8.add(ele9);
            ele7.add(ele8);
            mod3 = baff.Model();
            mod3.AddElement(ele7);

            testCase.assertTrue(mod1 == mod3);
            testCase.assertFalse(mod1 ~= mod3);

            testCase.assertFalse(mod1 == mod2);
            testCase.assertTrue(mod1 ~= mod2);
        end
    end
    
end