classdef Fuel < baff.Mass
    %FUEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        FillingLevel (1,1) double {mustBeFinite} = 1;
    end
    properties(Dependent)
        Capacity
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    methods
        function val = Type(obj)
            val = "Fuel";
        end
    end
    methods
        function obj = Fuel(mass,opts)
            %FUEL Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                mass
                opts.Ixx = 0;
                opts.Iyy = 0;
                opts.Izz = 0;
                opts.Ixy = 0;
                opts.Ixz = 0;
                opts.Iyz = 0;

                opts.eta = 0
                opts.Offset = [0;0;0];
                opts.Name = "Fuel" 
                opts.Force = nan(3,1);
                opts.Moment = nan(3,1);
            end
            obj = obj@baff.Mass(mass,'Ixx',opts.Ixx,'Iyy',opts.Iyy,'Izz',opts.Izz,'Ixy',...
                opts.Ixy,'Ixz',opts.Ixz,'Iyz',opts.Iyz,'eta',opts.eta,'Offset',...
                opts.Offset,'Name',opts.Name,'Force',opts.Force,'Moment',opts.Moment);
        end
        function val = get.Capacity(obj)
            val = [obj.mass];
        end
        function val = GetElementMass(obj)
            val = [obj.mass].*[obj.FillingLevel];
        end
        function val = GetElementOEM(obj)
            val = zeros(size(obj));
        end
        function [Xs,masses] = GetElementCoM(obj)
            masses = [obj.mass].*[obj.FillingLevel];
            Xs = zeros(3,length(obj));
            % for i = 1:length(obj)
            %     Xs(:,i) = obj(i).GetGlobalPos(0,obj(i).Offset);
            % end
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
            p.MarkerFaceColor = 'r';
            p.Color = 'r';
            p.Tag = 'Fuel';
            %plot children
            optsCell = namedargs2cell(opts);
            plt_obj = draw@baff.Element(obj,optsCell{:});
            p = [p,plt_obj];
        end
    end
end

