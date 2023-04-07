function obj = DistributeMass(obj, mass, Nele,opts)
    arguments
        obj
        mass
        Nele
        opts.BeamOffset = 0;
        opts.tag = 'wing_mass';
        opts.Method string {mustBeMember(opts.Method,{'ByArea','ByVolume','Regular'})} = "ByArea";
    end
    % create N lumped masses spread across the wing with the fraction at each
    % point proportional to the chord at each point
    % if IncludeTips include masses at both ends, otherwise spread equally
    % across
    switch opts.Method
        case "ByArea"
            sec_etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,Nele+1);
            secs = obj.AeroStations.interpolate(sec_etas);
            etas = sec_etas(1:end-1) + (sec_etas(2:end) - sec_etas(1:end-1))*0.5;
            NormAreas = secs.GetNormAreas();
            masses = NormAreas./sum(NormAreas) * mass;
        case "ByVolume"
            sec_etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,Nele+1);
            secs = obj.AeroStations.interpolate(sec_etas);
            etas = sec_etas(1:end-1) + (sec_etas(2:end) - sec_etas(1:end-1))*0.5;
            NormVols = secs.GetNormVolumes();
            masses = NormVols./sum(NormVols) * mass;
        case "Regular"
            etas = linspace(obj.AeroStations(1).Eta,obj.AeroStations(end).Eta,Nele);
            masses = ones(1,Nele)/Nele * mass;
    end
    %create the point masses and add to the wing
    secs = obj.AeroStations.interpolate(etas);
    for i = 1:Nele
        tmp_mass = baff.Mass(masses(i),"eta",etas(i),"Name",sprintf('%s_%.0f',opts.tag,i));
        tmp_mass.Offset = [opts.BeamOffset*secs(i).Chord;0;0];
        obj.add(tmp_mass);
    end
end