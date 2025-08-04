classdef Payload < baff.Mass
    %Payload class for payload elements in a Baff model
    
    properties
        FillingLevel = 1; % Filling level of the payload, default is 1 (full), this can be set to a value between 0 and 1
    end
    properties(Dependent)
        Capacity; %Maximum payload capacity of this Element (if filling level =1
    end
    methods(Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end

    methods
        function val = getType(obj)
            val ="Payload";
        end
    end
    methods
        function obj = Payload(capacity,opts)
            %Payload Construct an instance of this class
            %Args:
            %   capacity (double): capacity of the payload object
            %   opts.Ixx (double): Inertia tensor component Ixx
            %   opts.Iyy (double): Inertia tensor component Iyy
            %   opts.Izz (double): Inertia tensor component Izz
            %   opts.Ixy (double): Inertia tensor component Ixy
            %   opts.Ixz (double): Inertia tensor component Ixz
            %   opts.Iyz (double): Inertia tensor component Iyz
            %   opts.eta (double): Eta value for the payload
            %   opts.Offset (3,1) double: Offset of the payload element from its parent
            %   opts.Name (string): Name of the payload element
            %   opts.Force (3,1) double: Force applied to the payload
            %   opts.Moment (3,1) double: Moment applied to the payload
            arguments
                capacity
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
            obj = obj@baff.Mass(capacity,'Ixx',opts.Ixx,'Iyy',opts.Iyy,'Izz',opts.Izz,'Ixy',...
                opts.Ixy,'Ixz',opts.Ixz,'Iyz',opts.Iyz,'eta',opts.eta,'Offset',...
                opts.Offset,'Name',opts.Name,'Force',opts.Force,'Moment',opts.Moment);
        end
        function val = get.Capacity(obj)
            %Capacity returns the maximum payload capacity of this Element (if filling level =1)
            val = [obj.mass];
        end
        function val = GetElementMass(obj)
            %GetElementMass returns the mass of the payload element, at current filling level
            val = [obj.mass].*[obj.FillingLevel];
        end
        function val = GetElementOEM(obj)
            %GetElementOEM returns the operational empty mass of the payload element(e.g. zero...)
            val = zeros(size(obj));
        end
        function [Xs,masses] = GetElementCoM(obj)
            %GetElementCoM returns the center of mass and masses of the payload element, at current filling level
            masses = [obj.mass].*[obj.FillingLevel];
            Xs = zeros(3,length(obj));
            % for i = 1:length(obj)
            %     Xs(:,i) = obj(i).GetGlobalPos(0,obj(i).Offset);
            % end
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
            p.Tag = 'Payload';
            %plot children
            optsCell = namedargs2cell(opts);
            plt_obj = draw@baff.Element(obj,optsCell{:});
            p = [p,plt_obj];
        end
    end
end

