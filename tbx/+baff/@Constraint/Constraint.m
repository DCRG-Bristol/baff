classdef Constraint < baff.Element
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
        function val = Type(obj)
            val ="Constraint";
        end
    end
    methods
        function val = eq(obj1,obj2)
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
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Point" 
                opts.ComponentNums = 123456;
            end
            %MASS Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            obj.ComponentNums = opts.ComponentNums;
        end
        function p = draw(obj,opts)
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
            plt_obj = draw@baff.Element(obj,optsCell{:});
            p = [p,plt_obj];
        end
    end
end

