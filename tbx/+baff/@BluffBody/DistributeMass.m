function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.Offset = [0;0;0];
        opts.tag = 'body_mass';
        opts.IncludeTips = false;
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    etas = linspace(obj.Stations(1).Eta,obj.Stations(end).Eta,Nele+1);
    secs = obj.Stations.interpolate(etas);
    NormVols = secs.GetNormVolumes();
    masses = NormVols./sum(NormVols) * mass;
    % get postions of the masses
    if opts.IncludeTips
        etas = linspace(obj.Stations(1).Eta,obj.Stations(end).Eta,Nele);
    else
        etas = linspace(obj.Stations(1).Eta,obj.Stations(end).Eta,(2*Nele)+1);
        etas = etas(2:2:(end-1));
    end
    %create the point masses and add to the wing
    for i = 1:Nele
        tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        tmp_mass.Offset = opts.Offset;
        obj.add(tmp_mass);
    end
end