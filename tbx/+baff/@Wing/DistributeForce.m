function obj = DistributeForce(obj,Nele,opts)
    arguments
        obj
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'wing_force';
        opts.EtaLimits (1,2) double = [nan nan];
        opts.Etas (1,:) double = [];
        opts.IncludeTips = false;
        opts.Force = [0 0 1];
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    % if IncludeTips include masses at both ends, otherwise spread equally
    % across
    if ~isempty(opts.Etas)
        etas = opts.Etas;
    else
        if isnan(opts.EtaLimits(1))
            Etas = [obj.AeroStations([1,end]).Eta];
        else
            Etas = opts.Etas;
        end
        if opts.IncludeTips
            etas = linspace(Etas(1),Etas(2),Nele);
        else
            etas = linspace(Etas(1),Etas(2),(2*Nele)+1);
            etas = etas(2:2:(end-1));
        end
    end
    
    secs = obj.AeroStations.interpolate(etas);
    for i = 1:length(etas)
        tmp_p = baff.Point("eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i),"Force",opts.Force);
        if opts.BeamOffset ~= 0
            tmp_p.Offset = secs(i).StationDir./norm(secs(i).StationDir)*opts.BeamOffset*secs(i).Chord;
        end
        obj.add(tmp_p);
    end
end