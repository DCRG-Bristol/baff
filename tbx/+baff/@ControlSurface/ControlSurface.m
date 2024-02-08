classdef ControlSurface
    properties
        Name string = ""    % Name
        Etas (2,1) double = [0;1];       % start and end eta along the wing
        pChord (2,1) double = [0.1;0.1]; % Percentage of chord that is control surface at either end

        % linked control surface (control surface the motion of this one is linked to)
        LinkedSurface = baff.ControlSurface.empty;
        LinkedCoefficent = 1; % gain of the linked surface
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    
    methods
        function val = ne(obj1,obj2)
            val = ~(obj1.eq(obj2));
        end
        function val = eq(obj1,obj2)
            if length(obj1)~= length(obj2) || ~isa(obj2,'baff.ControlSurface')
                val = false;
                return
            end
            val = true;
            for i = 1:length(obj1)
                val = val && obj1(i).Name == obj2(i).Name;
                val = val && all(obj1(i).Etas == obj2(i).Etas);
                val = val && all(obj1(i).pChord == obj2(i).pChord);
            end
        end
        function obj = ControlSurface(name,etas,pChords)
            arguments
                name string
                etas (2,1) double
                pChords (2,1) double
            end
            obj.Name = name;
            obj.Etas = etas;
            obj.pChord = pChords;
        end
        function p = draw(obj,Parent,opts)
            arguments
                obj
                Parent baff.Wing
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            p = [];
            for i = 1:length(obj)
                beamLoc = [Parent.Stations.GetPos(obj(i).Etas(1)),Parent.Stations.GetPos(obj(i).Etas(2))];
                aeroLoc = [Parent.AeroStations.GetPos(obj(i).Etas(1),[1-obj(i).pChord(1),1]),...
                    Parent.AeroStations.GetPos(obj(i).Etas(2),[1,1-obj(i).pChord(2)])];
                points = beamLoc(:,[1,1,2,2]).*Parent.EtaLength + aeroLoc;
                points = repmat(opts.Origin,1,4) + opts.A*points;
                p = patch(points(1,:)',points(2,:)',points(3,:)',[1 1 1],'FaceAlpha',.5);
                p.Tag = 'Control Surfaces';
            end
        end
    end
end

