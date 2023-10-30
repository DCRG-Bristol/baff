function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.Offset = [0;0;0];
        opts.tag = 'body_mass';
        opts.IncludeTips = false;
        opts.isFuel logical = false;
        opts.isPayload logical = false;
        opts.Etas (1,2) double = [nan nan];
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    if isnan(opts.Etas(1))
        Etas = [obj.Stations([1,end]).Eta];
    else
        Etas = opts.Etas;
    end
    etas = linspace(Etas(1),Etas(2),Nele+1);
    secs = obj.Stations.interpolate(etas);
    NormVols = secs.GetNormVolumes();
    masses = NormVols./sum(NormVols) * mass;
    % get postions of the masses
    if opts.IncludeTips
        etas = linspace(Etas(1),Etas(2),Nele);
    else
        etas = linspace(Etas(1),Etas(2),(2*Nele)+1);
        etas = etas(2:2:(end-1));
    end
    %create the point masses and add to the wing
    for i = 1:Nele
        if opts.isFuel
            tmp_mass = baff.Fuel(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        elseif opts.isPayload
            tmp_mass = baff.Payload(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        else
            tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        end
        tmp_mass.Offset = opts.Offset;
        obj.add(tmp_mass);
    end
end