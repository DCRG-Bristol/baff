classdef Model < handle
    properties
        Name = ""
        Beam (:,1) baff.model.Beam = baff.model.Beam.empty
        Constraint (:,1) baff.model.Constraint = baff.model.Constraint.empty
        Hinge (:,1) baff.model.Hinge = baff.model.Hinge.empty
        Mass (:,1) baff.model.Mass = baff.model.Mass.empty
        Point (:,1) baff.model.Point = baff.model.Point.empty
        Wing (:,1) baff.model.Wing = baff.model.Wing.empty
        Orphans (:,1) baff.model.Element = baff.model.Beam.empty
    end
    methods
        function AddElement(obj,ele)
            % add the element
            switch class(ele)
                case "baff.model.Beam"
                    obj.Beam(end+1) = ele;
                case "baff.model.Constraint"
                    obj.Constraint(end+1) = ele;
                case "baff.model.Hinge"
                    obj.Hinge(end+1) = ele;
                case "baff.model.Mass"
                    obj.Mass(end+1) = ele;
                case "baff.model.Point"
                    obj.Point(end+1) = ele;
                case "baff.model.Wing"
                    obj.Wing(end+1) = ele;
            end
            % add its Children
            for cIdx = 1:length(ele.Children)
                obj.AddElement(ele.Children(cIdx));
            end
            % if Orphan add to the list
            if isempty(ele.Parent)
                obj.Orphans(end+1) = ele;
            end
        end
        function draw(obj)
            for i = 1:length(obj.Orphans)
                obj.Orphans(i).draw();
            end
        end

        function UpdateIdx(obj)
            names = fieldnames(obj);
            idx = 1;
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.model.Element') && ~strcmp(names{i},'Orphans')
                    for j =1:length(obj.(names{i}))
                        obj.(names{i})(j).Index = idx;
                        idx=idx+1;
                    end
                end
            end
        end

        function ToBaff(obj,filename)
            date = datestr(now);
            h5create(filename,'/Version',[1 1],'Datatype','string');
            h5write(filename,'/Version',string(baff.util.get_version));
            h5writeatt(filename,'/','BaffVersion', string(baff.util.get_version));
            h5writeatt(filename,'/','MatlabVersion', version);
            h5writeatt(filename,'/','Created', date);
            h5writeatt(filename,'/','Author', getenv('username'));
            h5writeatt(filename,'/','Computer', getenv('computername'));

            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.model.Element') && ~strcmp(names{i},'Orphans')
                    obj.(names{i}).ToBaff(filename,sprintf('/BAFF/%s',names{i}));
                end
            end
        end

        function AssignChildren(obj,filename)
            % get linker object
            linker = baff.model.Element.empty;
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.model.Element') && ~strcmp(names{i},'Orphans')
                    for j =1:length(obj.(names{i}))
                        linker(obj.(names{i})(j).Index) = obj.(names{i})(j);
                    end
                end
            end
            % populate parents and children
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.model.Element') && ~strcmp(names{i},'Orphans')
                    obj.(names{i}).LinkElements(filename,sprintf('/BAFF/%s',names{i}),linker);
                    %populate orphans
                    for j = 1:length(obj.(names{i}))
                        if isempty(obj.(names{i})(j).Parent)
                            obj.Orphans(end+1) = obj.(names{i})(j);
                        end
                    end
                end
            end
        end
    end
    methods(Static)
        function obj = FromBaff(filename)
            obj = baff.model.Model();
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.model.Element') && ~strcmp(names{i},'Orphans')
                    obj.(names{i}) = baff.model.(names{i}).FromBaff(filename,sprintf('/BAFF/%s',names{i}));
                end
            end
            obj.AssignChildren(filename);
        end
    end
end

