classdef Point < baff.Element
    %POINT Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Force = nan(3,1); % force applied to this gridpoint (in local coordinate system)
        Moment = nan(3,1); % moment applied to this gridpoint (in local coordinate system)
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = Type(obj)
            val ="Wing";
        end
    end
    methods
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.Point')
                val = false;
                return
            end
            val = eq@baff.Element(obj1,obj2);
            for i = 1:length(obj1)
                val = val && all(obj1(i).Force == obj2(i).Force);
                val = val && all(obj1(i).Moment == obj2(i).Moment);
            end
        end
        
        function obj = Point(CompOpts,opts)
            arguments
                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Point" 
                opts.Moment = nan(3,1);
                opts.Force = nan(3,1);
            end
            %MASS Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Element(CompStruct{:});
            obj.Moment = opts.Moment;
            obj.Force = opts.Force;
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
            p = plot3(Origin(1,:),Origin(2,:),Origin(3,:),'^m');
            p.MarkerFaceColor = 'g';
            p.Color = 'g';
            p.Tag = 'Point';
            %plot children
            optsCell = namedargs2cell(opts);
            plt_obj = draw@baff.Element(obj,optsCell{:});
            p = [p,plt_obj];
        end
    end
end

