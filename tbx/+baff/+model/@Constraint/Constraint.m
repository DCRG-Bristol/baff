classdef Constraint < baff.model.Element
    %POINT Summary of this class goes here
    %   Detailed explanation goes here
    properties
        ComponentNums = 123456;
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Constraint(CompOpts,opts)
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Point" 
                opts.ComponentNums = 123456;
            end
            %MASS Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.model.Element(CompStruct{:});
            obj.ComponentNums = opts.ComponentNums;
        end
        function draw(obj,opts)
            arguments
                obj
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
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
            draw@baff.model.Element(obj,optsCell{:});
        end
    end
end

