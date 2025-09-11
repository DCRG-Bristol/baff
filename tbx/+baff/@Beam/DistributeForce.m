function obj = DistributeForce(obj,Nele,opts)
    arguments
        obj
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'orce';
        opts.Etas (1,2) double = [nan nan];
        opts.IncludeTips = false;
        opts.Force = [0 0 1];
        opts.Moment = [0 0 0];
        opts.Distribute = true;
    end
    % create N forces spread across the beam with a fraction at each
    % if IncludeTips include force at both ends, otherwise spread equally
    % across
    Etas = opts.Etas;
    if isnan(Etas(1))
        Etas(1) = obj.Stations.Eta(1);
    end
    if isnan(Etas(2))
        Etas(2) = obj.Stations.Eta(end);
    end
    
    etas = linspace(Etas(1),Etas(2),Nele);
    if opts.Distribute
        fraction = ones(1,Nele)/Nele;
    else
        fraction = ones(1,Nele);
    end

    secs = obj.Stations.interpolate(etas);
    for i = 1:length(etas)
        tmp_p = baff.Point("eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i),"Force",opts.Force.*fraction(i),"Moment",opts.Moment.*fraction(i));
        if opts.BeamOffset ~= 0
            tmp_p.Offset = secs.StationDir(:,i)./norm(secs.StationDir(:,i))*opts.BeamOffset;
        end
        obj.add(tmp_p);
    end
end