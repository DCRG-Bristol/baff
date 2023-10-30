function TemplateHdf5(filepath,loc)
    baff.Mass.TemplateHdf5(filepath,loc);
    %create place holders
    h5create(filepath,sprintf('%s/FillingLevel',loc),[1 inf],"Chunksize",[1,10]);
end

