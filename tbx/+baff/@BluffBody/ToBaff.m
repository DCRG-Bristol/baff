function ToBaff(obj,filepath,loc)
%% write mass specific items
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Element(obj,filepath,loc);
    % Bluff Body Specific
    Bstations = [obj.Stations];
    Bstations.ToBaff(filepath,loc);
    BNs = arrayfun(@(x)length(x.Stations),obj);
    h5writeatt(filepath,sprintf('%s/',loc),'BodyStationsIdx', BNs);
end
end