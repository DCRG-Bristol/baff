function ToBaff(obj,filepath,loc)
    % write default items
    PropToBaff(obj,filepath,loc);
    %% write mass specific items
    N = length(obj);
    if N == 0
        h5writeatt(filepath,[loc,'/'],'Qty', 0);
        return
    end
    %% sort out beam stations
    BNs = arrayfun(@(x)length(x.Stations),obj);
    BN = sum(BNs);

    %fill data
    BN_idx = [0,cumsum(BNs)']+1;
    for i = 1:length(obj)
        h5write(filepath,sprintf('%s/Stations/eta',loc),arrayfun(@(x)x.eta,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/A',loc),arrayfun(@(x)x.A,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/Ixx',loc),arrayfun(@(x)x.Ixx,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/Izz',loc),arrayfun(@(x)x.Izz,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/E',loc),arrayfun(@(x)x.Mat.E,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/G',loc),arrayfun(@(x)x.Mat.G,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/rho',loc),arrayfun(@(x)x.Mat.rho,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/Stations/nu',loc),arrayfun(@(x)x.Mat.nu,[obj(i).Stations]),[1 BN_idx(i)],[1 BNs(i)]);
    end
    h5writeatt(filepath,sprintf('%s/Stations/',loc),'Qty', BN);
    h5writeatt(filepath,sprintf('%s/Stations/',loc),'Idx', BNs);

    %% sort out Aero stations
    BNs = arrayfun(@(x)length(x.AeroStations),obj);
    BN = sum(BNs);

    %fill data
    BN_idx = [0,cumsum(BNs)']+1;
    for i = 1:length(obj)
        h5write(filepath,sprintf('%s/AeroStations/eta',loc),arrayfun(@(x)x.eta,[obj(i).AeroStations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/AeroStations/Chord',loc),arrayfun(@(x)x.Chord,[obj(i).AeroStations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/AeroStations/Twist',loc),arrayfun(@(x)x.Twist,[obj(i).AeroStations]),[1 BN_idx(i)],[1 BNs(i)]);
        h5write(filepath,sprintf('%s/AeroStations/BeamLoc',loc),arrayfun(@(x)x.BeamLoc,[obj(i).AeroStations]),[1 BN_idx(i)],[1 BNs(i)]);
    end
    h5writeatt(filepath,sprintf('%s/AeroStations/',loc),'Qty', BN);
    h5writeatt(filepath,sprintf('%s/AeroStations/',loc),'Idx', BNs);

    h5writeatt(filepath,[loc,'/'],'Qty', length(obj));
end