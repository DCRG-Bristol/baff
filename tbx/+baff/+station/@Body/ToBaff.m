function ToBaff(obj,filepath,loc)
    %% write mass specific items
    Ne = obj.N;
    if Ne == 0
        h5writeatt(filepath,[loc,'/BodyStations/'],'Qty', 0);
        return
    end

    h5write(filepath,sprintf('%s/BodyStations/Eta',loc),obj.Eta,[1 1],[1 Ne]);
    h5write(filepath,sprintf('%s/BodyStations/EtaDir',loc),obj.EtaDir,[1 1],[3 Ne]);
    h5write(filepath,sprintf('%s/BodyStations/StationDir',loc),obj.StationDir,[1 1],[3 Ne]);
    h5write(filepath,sprintf('%s/BodyStations/A',loc),obj.A,[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/I',loc),reshape(obj.I,9,[]),[1 1],[9 N]);
    h5write(filepath,sprintf('%s/BodyStations/J',loc),obj.J,[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/Tau',loc),reshape(obj.tau,9,[]),[1 1],[9 N]);
    h5write(filepath,sprintf('%s/BodyStations/Radius',loc),obj.Radius,[1 1],[1 N]);

    h5writeatt(filepath,[loc,'/BodyStations/'],'Qty', Ne);
    %% sort out Material
    Mats = [obj.Mat];
    % only save unique Materials
    [~,ia,ic] = unique([Mats.Hash]);
    Mats(ia).ToBaff(filepath,loc);
    h5writeatt(filepath,sprintf('%s/',loc),'MatsIdx', ic);
end