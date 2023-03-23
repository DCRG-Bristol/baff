function TemplateHdf5(filepath,loc)
    %create placeholders
    h5create(filepath,sprintf('%s/ControlSurface/Names',loc),[1 inf],"Chunksize",[1,10],"Datatype","string");
    h5create(filepath,sprintf('%s/ControlSurface/Etas',loc),[2 inf],"Chunksize",[2,10]);
    h5create(filepath,sprintf('%s/ControlSurface/pChords',loc),[2 inf],"Chunksize",[2,10]);
end

