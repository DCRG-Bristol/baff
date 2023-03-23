classdef Hinge < baff.Element
    %HINGE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        HingeVector = [1;0;0];
        Rotation = 0;
        K = 1e-4;
        C = 0;
        isLocked = false;
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Hinge(CompOpts,opts)
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Beam" 
                opts.HingeVector = [1;0;0];
                opts.K = 1e-4;
                opts.C = 1e-4;
                opts.isLocked = false;
            end
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            obj.HingeVector = opts.HingeVector;
            obj.K = opts.K;
            obj.C = opts.C;
            obj.isLocked = opts.isLocked;
        end
    end
end

