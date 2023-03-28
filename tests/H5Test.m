classdef H5Test < matlab.unittest.TestCase
    properties
        Model1;
        Model2;
    end
    % build some objects to compare
    methods(TestClassSetup)
        function buildModels(testCase)
            %build some elements with non-default values
            mat1 = baff.Material(1,2,3);
            st = baff.station.Beam(0,"A",2,"EtaDir",rand(3,1),"I",rand(3),"tau",rand(3),"Mat",mat1);
            beam1 = baff.Beam("eta",0,"Stations",st + [0,0.5,1]);
            bst = baff.station.Body(0,"A",2,"EtaDir",[0;0.4;0],"I",rand(3),"radius",rand(1));
            body1 = baff.BluffBody("eta",0,"Stations",bst + [0:0.1:1],"Offset",rand(3,1));
            ast = baff.station.Aero(0,rand(1),rand(1),"EtaDir",rand(3,1),"Twist",rand(1));
            wing1 = baff.Wing(ast + [0:0.25:1],"BeamStations",st + [0,0.5,1],"eta",0,"EtaLength",2);
            wing2 = baff.Wing(ast + [0:0.25:1],"BeamStations",st + [0:0.5:1],"eta",1,"EtaLength",2);
            control1 = baff.ControlSurface('Test',[0.5,0.75],[0.2,0.2]);
            control2 = baff.ControlSurface('Test2',[0.25,0.5],[0.2,0.2]);
            wing2.ControlSurfaces = [control1,control2];
            con1 = baff.Constraint("ComponentNums",123456);
            hinge1 = baff.Hinge("HingeVector",rand(3,1),"Rotation",rand(1),"eta",1);
            mass1 = baff.Mass(rand(1),"Iyy",rand(1),"eta",0.6);
            point1 = baff.Point("Force",rand(3,1),"Moment",rand(3,1),"Offset",rand(3,1));
            %create some child dependencies
            con1.add(beam1);
            beam1.add(hinge1);
            hinge1.add(mass1);
            %create a model
            model1 = baff.Model();
            model1.AddElement(con1);
            model1.AddElement(body1);
            model1.AddElement(wing1);
            model1.AddElement(wing2);
            model1.AddElement(point1);
            %create H5 file
            filename = 'test.h5';
            if exist(filename, 'file') == 2
                delete(filename)
            end
            baff.Model.GenTempHdf5(filename);
            model1.UpdateIdx();
            model1.ToBaff(filename);
            %load h5 as a seperate model
            model2 = baff.Model.FromBaff(filename);
            testCase.Model1 = model1;
            testCase.Model2 = model2;
        end
    end
   
    
    methods(Test)
        % Test methods
        function CompareBeamsTest(testCase)
            testCase.assertTrue(testCase.Model1.Beam == testCase.Model2.Beam);
        end
        function CompareBodysTest(testCase)
            testCase.assertTrue(testCase.Model1.BluffBody == testCase.Model2.BluffBody);
        end
        function CompareConstraintTest(testCase)
            testCase.assertTrue(testCase.Model1.Constraint == testCase.Model2.Constraint);
        end
        function CompareHingeTest(testCase)
            testCase.assertTrue(testCase.Model1.Hinge == testCase.Model2.Hinge);
        end
        function CompareMassTest(testCase)
            testCase.assertTrue(testCase.Model1.Mass == testCase.Model2.Mass);
        end
        function ComparePointTest(testCase)
            testCase.assertTrue(testCase.Model1.Point == testCase.Model2.Point);
        end
        function CompareWingTest(testCase)
            testCase.assertTrue(testCase.Model1.Wing == testCase.Model2.Wing);
        end
    end
    
end