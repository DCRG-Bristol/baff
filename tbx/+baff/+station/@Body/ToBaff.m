function ToBaff(obj,filepath,loc)
    %% write mass specific items
    N = length(obj);
    h5writeatt(filepath,[loc,'/BodyStations/'],'Qty', N);
    if N == 0
        return
    end

    h5write(filepath,sprintf('%s/BodyStations/Eta',loc),[obj.Eta],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/EtaDir',loc),[obj.EtaDir],[1 1],[3 N]);
    h5write(filepath,sprintf('%s/BodyStations/Radius',loc),[obj.Radius],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/A',loc),[obj.Eta],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/Ixx',loc),[obj.Eta],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/Izz',loc),[obj.Eta],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/E',loc),arrayfun(@(x)x.Mat.E,obj),[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/G',loc),arrayfun(@(x)x.Mat.G,obj),[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/rho',loc),arrayfun(@(x)x.Mat.rho,obj),[1 1],[1 N]);
    h5write(filepath,sprintf('%s/BodyStations/nu',loc),arrayfun(@(x)x.Mat.nu,obj),[1 1],[1 N]);
end