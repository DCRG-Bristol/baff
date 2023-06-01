function TemplateHdf5(filepath,loc)
    %create placeholders
    h5create(filepath,sprintf('%s/BodyStations/Eta',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/EtaDir',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/BodyStations/StationDir',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/BodyStations/Radius',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/A',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/I',loc),[9 inf],"Chunksize",[9,10]);
    h5create(filepath,sprintf('%s/BodyStations/J',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/Tau',loc),[9 inf],"Chunksize",[9,10]);
    h5create(filepath,sprintf('%s/BodyStations/E',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/G',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/rho',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/BodyStations/nu',loc),[1 inf],"Chunksize",[1,10]);
end

