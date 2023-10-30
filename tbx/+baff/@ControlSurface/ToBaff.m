function ToBaff(obj,filepath,loc)
N = length(obj);
h5writeatt(filepath,[loc,'/ControlSurface/'],'Qty', N);
if N ~= 0
    h5write(filepath,sprintf('%s/ControlSurface/Names',loc),[obj.Name],[1 1],[1 N]);
    h5write(filepath,sprintf('%s/ControlSurface/Etas',loc),[obj.Etas],[1 1],[2 N]);
    h5write(filepath,sprintf('%s/ControlSurface/pChords',loc),[obj.pChord],[1 1],[2 N]);
end
end