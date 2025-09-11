function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'beam_mass';
        opts.isFuel logical = false;
        opts.isPayload logical = false;
        opts.Etas (1,2) double = [nan nan];
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    % if IncludeTips include masses at both ends, otherwise spread equally
    % across
    Etas = opts.Etas;
    if isnan(Etas(1))
        Etas(1) = obj.Stations.Eta(1);
    end
    if isnan(Etas(2))
        Etas(2) = obj.Stations.Eta(end);
    end
    
    etas = linspace(Etas(1),Etas(2),Nele);
    masses = ones(1,Nele)/Nele * mass;
    %create the point masses and add to the wing
    secs = obj.Stations.interpolate(etas);
    for i = 1:Nele
        if opts.isFuel
            tmp_mass = baff.Fuel(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        elseif opts.isPayload
            tmp_mass = baff.Payload(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        else
            tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        end
        if opts.BeamOffset ~= 0
            tmp_mass.Offset = secs.StationDir(:,i)./norm(secs.StationDir(:,i))*opts.BeamOffset;
        end
        obj.add(tmp_mass);
    end
end