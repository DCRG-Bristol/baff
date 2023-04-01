function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'wing_mass';
        opts.IncludeTips = false;
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,Nele+1);
    secs = obj.AeroStations.interpolate(etas);
    NormAreas = secs.GetNormAreas();
    masses = NormAreas./sum(NormAreas) * mass;
    % get postions of the masses
    if opts.IncludeTips
        etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,Nele);
    else
        etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,(2*Nele)+1);
        etas = etas(2:2:(end-1));
    end
    secs = obj.AeroStations.interpolate(etas);
    %create the point masses and add to the wing
    for i = 1:Nele
        tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        tmp_mass.Offset = [opts.BeamOffset*secs(i).Chord;0;0];
        obj.add(tmp_mass);
    end
end