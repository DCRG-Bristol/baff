function TemplateHdf5(filepath,loc)
    %create place holders
    h5create(filepath,sprintf('%s/Materials/E',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/G',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/rho',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/nu',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/Name',loc),[1 inf],"Chunksize",[1,10],"Datatype","string");
end