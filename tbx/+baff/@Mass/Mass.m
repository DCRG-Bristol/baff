classdef Mass < baff.Point
    %MASS Summary of this class goes here
    %   Detailed explanation goes here
    properties
        mass (1,1) double;
        InertiaTensor (3,3) double= zeros(3);
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function obj = Mass(mass,opts,CompOpts)
            arguments
                mass
                opts.Ixx = 0;
                opts.Iyy = 0;
                opts.Izz = 0;
                opts.Ixy = 0;
                opts.Ixz = 0;
                opts.Iyz = 0;

                CompOpts.eta = 0
                CompOpts.Offset
                CompOpts.Name = "Point Mass" 
                CompOpts.Force = nan(3,1);
                CompOpts.Moment = nan(3,1);
            end
            %MASS Construct an instance of this class
            %   Detailed explanation goes here
            CompStruct = namedargs2cell(CompOpts);
            obj = obj@baff.Point(CompStruct{:});
            obj.mass = mass;
            obj.InertiaTensor = [opts.Ixx,opts.Ixy,opts.Ixz;...
                                opts.Ixy,opts.Iyy,opts.Iyz;...
                                opts.Ixz,opts.Iyz,opts.Izz];
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
            p.MarkerFaceColor = 'b';
            p.Color = 'b';
            p.Tag = 'Mass';
            %plot children
            optsCell = namedargs2cell(opts);
            draw@baff.Element(obj,optsCell{:});
        end
    end
end

