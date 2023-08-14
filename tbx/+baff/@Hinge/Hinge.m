classdef Hinge < baff.Element
    %HINGE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        HingeVector = [1;0;0];
        Rotation = 0;
        K = 1e-4;
        C = 0;
        isLocked = false;

        %% drawing properties
        RefLength = 1;
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = Type(obj)
            val ="Hinge";
        end
    end
    methods
        function val = eq(obj1,obj2)
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
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Beam" 
                opts.HingeVector = [1;0;0];
                opts.K = 1e-4;
                opts.C = 1e-4;
                opts.isLocked = false;
                opts.Rotation = 0;
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

