function TemplateHdf5(filepath,loc)
    %create placeholders
    h5create(filepath,sprintf('%s/AeroStations/Eta',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/AeroStations/EtaDir',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/AeroStations/StationDir',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/AeroStations/Chord',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/AeroStations/Twist',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/AeroStations/BeamLoc',loc),[1 inf],"Chunksize",[1,10]);
end

