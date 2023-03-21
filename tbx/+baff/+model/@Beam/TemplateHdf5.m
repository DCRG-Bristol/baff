function TemplateHdf5(filepath,loc)
    baff.model.Element.TemplateHdf5(filepath,loc);
    %create placeholders
    h5create(filepath,sprintf('%s/Stations/eta',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/A',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/Ixx',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/Izz',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/E',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/G',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/rho',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Stations/nu',loc),[1 inf],"Chunksize",[1,10]);
end

