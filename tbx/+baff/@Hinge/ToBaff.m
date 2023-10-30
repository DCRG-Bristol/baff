function ToBaff(obj,filepath,loc)
N = length(obj);
h5writeatt(filepath,[loc,'/'],'Qty', N);
if N ~= 0
    % write default items
    ToBaff@baff.Element(obj,filepath,loc);
    h5write(filepath,sprintf('%s/HingeVector',loc),[obj.HingeVector],[1,1],[3,N]);
    h5write(filepath,sprintf('%s/Rotation',loc),[obj.Rotation],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/K',loc),[obj.K],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/C',loc),[obj.C],[1,1],[1,N]);
    h5write(filepath,sprintf('%s/isLocked',loc),double([obj.isLocked]),[1,1],[1,N]);
end
end