function TemplateHdf5(filepath,loc)
    baff.Element.TemplateHdf5(filepath,loc);
    %create place holders
    h5create(filepath,sprintf('%s/ComponentNums',loc),[1 inf],"Chunksize",[1,10]);
end

