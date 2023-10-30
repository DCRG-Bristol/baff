function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'wing_mass';
        opts.Method string {mustBeMember(opts.Method,{'ByArea','ByVolume','Regular'})} = "ByArea";
        opts.isFuel logical = false;
        opts.isPayload logical = false;
        opts.Etas (1,2) double = [nan nan];
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    % if IncludeTips include masses at both ends, otherwise spread equally
    % across
    if isnan(opts.Etas(1))
        Etas = [obj.AeroStations([1,end]).Eta];
    else
        Etas = opts.Etas;
    end
    switch opts.Method
        case "ByArea"
            sec_etas = linspace(Etas(1),Etas(2),Nele+1);
            secs = obj.AeroStations.interpolate(sec_etas);
            etas = sec_etas(1:end-1) + (sec_etas(2:end) - sec_etas(1:end-1))*0.5;
            NormAreas = secs.GetNormAreas();
            masses = NormAreas./sum(NormAreas) * mass;
        case "ByVolume"
            sec_etas = linspace(Etas(1),Etas(2),Nele+1);
            secs = obj.AeroStations.interpolate(sec_etas);
            etas = sec_etas(1:end-1) + (sec_etas(2:end) - sec_etas(1:end-1))*0.5;
            NormVols = secs.GetNormVolumes();
            masses = NormVols./sum(NormVols) * mass;
        case "Regular"
            etas = linspace(Etas(1),Etas(2),Nele);
            masses = ones(1,Nele)/Nele * mass;
    end
    %create the point masses and add to the wing
    secs = obj.AeroStations.interpolate(etas);
    for i = 1:Nele
        if opts.isFuel
            tmp_mass = baff.Fuel(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        elseif opts.isPayload
            tmp_mass = baff.Payload(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        else
            tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        end
        if opts.BeamOffset ~= 0
            tmp_mass.Offset = secs(i).StationDir./norm(secs(i).StationDir)*opts.BeamOffset*secs(i).Chord;
        end
        obj.add(tmp_mass);
    end
end