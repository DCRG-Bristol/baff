function ToBaff(obj,filepath,loc)
    %% write mass specific items
    Ne = obj.N;
    if Ne == 0
        h5writeatt(filepath,[loc,'/BeamStations/'],'Qty', 0);
        return
    end
    h5write(filepath,sprintf('%s/BeamStations/Eta',loc),obj.Eta,[1 1],[1 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/EtaDir',loc),obj.EtaDir,[1 1],[3 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/StationDir',loc),obj.StationDir,[1 1],[3 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/A',loc),obj.A,[1 1],[1 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/I',loc),reshape(obj.I,9,[]),[1 1],[9 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/J',loc),obj.J,[1 1],[1 Ne]);
    h5write(filepath,sprintf('%s/BeamStations/Tau',loc),reshape(obj.tau,9,[]),[1 1],[9 Ne]);

    h5writeatt(filepath,[loc,'/BeamStations/'],'Qty', Ne);

    %% sort out Material
    Mats = [obj.Mat];
    % only save unique Materials
    [~,ia,ic] = unique([Mats.Hash]);
    Mats(ia).ToBaff(filepath,loc);
    h5writeatt(filepath,sprintf('%s/',loc),'MatsIdx', ic);
end