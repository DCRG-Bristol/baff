classdef Constraint < baff.Element
    %Constraint class to respresent a constraint in the baff framework
    properties
        ComponentNums = 123456; % constrained component numbers (123 XYZ, 456 rotation about XYZ). 
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = getType(obj)
            val ="Constraint";
        end
    end
    methods
        function val = eq(obj1,obj2)
            %overloads the == operator to check the equality of two Constraint objects.
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Constraint')
                val = false;
                return
            end
            val = eq@baff.Element(obj1,obj2);
            for i = 1:length(obj1)
                val = val && obj1(i).ComponentNums == obj2(i).ComponentNums;
            end
        end
        function obj = Constraint(CompOpts,opts)
            %CONSTRAINT Construct an instance of the Constraint Baff element class
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Point"
                opts.ComponentNums = 123456;
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            obj.ComponentNums = opts.ComponentNums;
        end
        function p = draw(obj,opts)
            %Draw draw an element in 3D Space
            %Args:
            %   opts.Origin: Origin of the beam element in 3D space
            %   opts.A: Rotation matrix to beam coordinate system
            %   opts.Type: plot type
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
                opts.Type string {mustBeMember(opts.Type,["stick","surf","mesh"])} = "stick";
            end
            Origin = opts.Origin + opts.A*(obj.Offset);
            Rot = opts.A*obj.A;
            %plot mass
            p = plot3(Origin(1,:),Origin(2,:),Origin(3,:),'^');
            p.MarkerFaceColor = 'm';
            p.Color = 'm';
            p.Tag = 'Constraint';
            %plot children
            optsCell = namedargs2cell(opts);
            plt_obj = draw@baff.Element(obj,optsCell{:});
            p = [p,plt_obj];
        end
    end
end

