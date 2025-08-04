classdef Hinge < baff.Element
    %HINGE Hinge element
    properties
        HingeVector = [1;0;0]; % orientation of the hinge in the local coordinate system
        Rotation = 0; % rotation of the hinge around the hinge vector
        K = 1e-4; % stiffness of the hinge
        C = 0; % damping of the hinge
        isLocked = false; % whether the hinge is locked or not

        %% drawing properties
        RefLength = 1; % reference length for the hinge, used for drawing
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = getType(obj)
            %getType returns the type of the object as a string.
            val ="Hinge";
        end
    end
    methods
        function val = eq(obj1,obj2)
            %overloads the == operator to check the equality of two Hinge objects.
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Hinge')
                val = false;
                return
            end
            val = eq@baff.Element(obj1,obj2);
            for i = 1:length(obj1)
                val = val && all(obj1(i).HingeVector == obj2(i).HingeVector);
                val = val && obj1(i).Rotation == obj2(i).Rotation;
                val = val && obj1(i).K == obj2(i).K;
                val = val && obj1(i).C == obj2(i).C;
                val = val && obj1(i).isLocked == obj2(i).isLocked;
            end
        end
        function obj = Hinge(CompOpts,opts)
            %Hinge Construct an instance of the Hinge Baff element class
            %Args:
            %   CompOpts.eta: Eta value for the hinge
            %   CompOpts.Offset: Offset of the hinge element from its parent
            %   CompOpts.Name: Name of the hinge element
            %   opts.HingeVector: Orientation of the hinge in the local coordinate system
            %   opts.Rotation: Rotation of the hinge around the hinge vector
            %   opts.K: Stiffness of the hinge
            %   opts.C: Damping of the hinge
            %   opts.isLocked: Whether the hinge is locked or not
            arguments
                CompOpts.eta = 0; % Eta value for the hinge
                CompOpts.Offset (3,1) double = [0,0,0]; % Offset of the hinge element from its parent
                CompOpts.Name = "Hinge"; % Name of the hinge element
                opts.HingeVector (3,1) double = [1;0;0]; % Orientation of the hinge in the local coordinate system
                opts.Rotation (1,1) double = 0; % Rotation of the hinge around the hinge vector
                opts.K (1,1) double = 1e-4; % Stiffness of the hinge
                opts.C (1,1) double = 0; % Damping of the hinge
                opts.isLocked (1,1) logical = false; % Whether the hinge is locked or not
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            obj.HingeVector = opts.HingeVector;
            obj.K = opts.K;
            obj.C = opts.C;
            obj.isLocked = opts.isLocked;
            obj.Rotation = opts.Rotation;
        end
    end
end

