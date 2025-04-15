classdef Model < handle
    properties
        Name = ""
        Beam (:,1) baff.Beam = baff.Beam.empty
        BluffBody (:,1) baff.BluffBody = baff.BluffBody.empty
        Constraint (:,1) baff.Constraint = baff.Constraint.empty
        Hinge (:,1) baff.Hinge = baff.Hinge.empty
        Mass (:,1) baff.Mass = baff.Mass.empty
        Fuel (:,1) baff.Fuel = baff.Fuel.empty
        Payload (:,1) baff.Payload = baff.Payload.empty
        Point (:,1) baff.Point = baff.Point.empty
        Wing (:,1) baff.Wing = baff.Wing.empty
        Orphans (:,1) baff.Element = baff.Beam.empty
    end
    methods
        function val = ne(obj1,obj2)
            val = ~(obj1.eq(obj2));
        end
        function val = eq(obj1,obj2)
            if length(obj1)>1 || length(obj1)~=length(obj2) || ~isa(obj2,'baff.Model')
                val = false;
                return
            end
            val = true;
            val = val && obj1.Orphans == obj2.Orphans;
        end
        function new = Rebuild(obj)
            new = baff.Model();
            new.Name = obj.Name;
            for i = 1:length(obj.Orphans)
                new.AddElement(obj.Orphans(i));
            end
        end
        function AddElement(obj,ele)
            % add element
            if isa(ele,'baff.Element')
                obj.(ele.Type)(end+1) = ele;
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
        function draw(obj,fig_handle)
            arguments
                obj
                fig_handle = figure;
            end
            hold on
            UserData.obj = obj;
            fig_handle.UserData = UserData;
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            set(fig_handle, 'WindowButtonDownFcn',    @baff.util.plotting.BtnDwnCallback, ...
                      'WindowScrollWheelFcn',   @baff.util.plotting.ScrollWheelCallback, ...
                      'KeyPressFcn',            @baff.util.plotting.KeyPressCallback, ...
                      'WindowButtonUpFcn',      @baff.util.plotting.BtnUpCallback)
            %draw the elements
            plt_obj = [];
            for i = 1:length(obj.Orphans)
                p = obj.Orphans(i).draw();
                plt_obj = [plt_obj,p];
            end
            [names,idx] = unique(arrayfun(@(x)string(x.Tag),plt_obj));
            lg = legend(plt_obj(idx),names,'ItemHitFcn', @baff.util.plotting.cbToggleVisible);
        end

        function UpdateIdx(obj)
            names = fieldnames(obj);
            idx = 1;
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    for j =1:length(obj.(names{i}))
                        obj.(names{i})(j).Index = idx;
                        idx=idx+1;
                    end
                end
            end
        end

        function ToBaff(obj,filename)
            date = datestr(now);
            h5write(filename,'/Version',string(baff.util.get_version));
            h5writeatt(filename,'/','BaffVersion', string(baff.util.get_version));
            h5writeatt(filename,'/','MatlabVersion', version);
            h5writeatt(filename,'/','Created', date);
            h5writeatt(filename,'/','Author', getenv('username'));
            h5writeatt(filename,'/','Computer', getenv('computername'));

            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    obj.(names{i}).ToBaff(filename,sprintf('/BAFF/%s',names{i}));
                end
            end
        end
        function val = GetMass(obj)
            val = 0;
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    tmp = obj.(names{i});
                    for j = 1:length(tmp)
                        val = val + tmp(j).GetElementMass();
                    end
                end
            end
        end
        function val = GetOEM(obj)
            val = 0;
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    tmp = obj.(names{i});
                    for j = 1:length(tmp)
                        val = val + tmp(j).GetElementOEM();
                    end
                end
            end
        end
        function [X,mass] = GetCoM(obj)
            masses = [0];
            Xs = [0;0;0];
            for i = 1:length(obj.Orphans)
                [tmpX,tmpM] = obj.Orphans(i).GetCoM();
                tmpX = obj.Orphans(i).A' * tmpX;
                tmpX = tmpX + repmat(obj.Orphans(i).Offset,1,length(tmpM)) + obj.Orphans(i).Offset;
                Xs = [Xs,tmpX];
                masses = [masses,tmpM];
            end
            masses = masses(2:end);
            Xs = Xs(:,2:end);
            mass = sum(masses);
            X = sum(Xs.*repmat(masses,3,1),2)./mass;
        end


        function AssignChildren(obj,filename)
            % get linker object
            linker = baff.Element.empty;
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    for j =1:length(obj.(names{i}))
                        linker(obj.(names{i})(j).Index) = obj.(names{i})(j);
                    end
                end
            end
            % populate parents and children
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans') && ~isempty(obj.(names{i}))
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
        function GenTempHdf5(filename)
            obj = baff.Model();
            h5create(filename,'/Version',[1 1],'Datatype','string');
            h5write(filename,'/Version',string(baff.util.get_version));
            h5writeatt(filename,'/','BaffVersion', string(baff.util.get_version));
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    baff.(names{i}).TemplateHdf5(filename,sprintf('/BAFF/%s',names{i}));
                end
            end
        end
        function obj = FromBaff(filename)
            obj = baff.Model();
            names = fieldnames(obj);
            for i = 1:length(names)
                if isa(obj.(names{i}),'baff.Element') && ~strcmp(names{i},'Orphans')
                    obj.(names{i}) = baff.(names{i}).FromBaff(filename,sprintf('/BAFF/%s',names{i}));
                end
            end
            obj.AssignChildren(filename);
        end
    end
end

