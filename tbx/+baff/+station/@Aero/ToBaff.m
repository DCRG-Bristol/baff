function ToBaff(obj,filepath,loc)
    %% write mass specific items
    N = length(obj);
    if N == 0
        h5writeatt(filepath,[loc,'/AeroStations/'],'Qty', 0);
        return
    end

    h5write(filepath,sprintf('%s/AeroStations/Eta',loc),[obj.Eta],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/AeroStations/EtaDir',loc),[obj.EtaDir],[1 1],[3 N]);
    h5write(filepath,sprintf('%s/AeroStations/Chord',loc),[obj.Chord],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/AeroStations/Twist',loc),[obj.Twist],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/AeroStations/BeamLoc',loc),[obj.BeamLoc],[1 1],[1 N]);

    h5writeatt(filepath,[loc,'/AeroStations/'],'Qty', length(obj));
end