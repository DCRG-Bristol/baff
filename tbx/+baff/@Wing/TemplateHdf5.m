function TemplateHdf5(filepath,loc)
    baff.Element.TemplateHdf5(filepath,loc);
    baff.station.Beam.TemplateHdf5(filepath,loc);
    baff.station.Aero.TemplateHdf5(filepath,loc);
    baff.ControlSurface.TemplateHdf5(filepath,loc);
end

