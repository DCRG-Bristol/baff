function ToBaff(obj,filepath,loc)
N = length(obj);
if N == 0
    h5writeatt(filepath,[loc,'/Materials/'],'Qty', 0);
    return
end
h5writeatt(filepath,[loc,'/Materials/'],'Qty', N);

h5write(filepath,sprintf('%s/Materials/Name',loc),[obj.Name],[1 1],[1 N]);
h5write(filepath,sprintf('%s/Materials/E',loc),[obj.E],[1 1],[1 N]);
h5write(filepath,sprintf('%s/Materials/G',loc),[obj.G],[1 1],[1 N]);
h5write(filepath,sprintf('%s/Materials/rho',loc),[obj.rho],[1 1],[1 N]);
h5write(filepath,sprintf('%s/Materials/nu',loc),[obj.nu],[1 1],[1 N]);
end