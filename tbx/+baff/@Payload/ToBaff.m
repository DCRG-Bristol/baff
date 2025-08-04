function ToBaff(obj,filepath,loc)
%TOBAFF Write a beam BAFF object to a HDF5 file.
%Args:
%   filepath (string): Path to file
%   loc (string): Location in file
    N = length(obj);
    h5writeatt(filepath,[loc,'/'],'Qty', N);
    if N ~= 0
        % write default items
        ToBaff@baff.Mass(obj,filepath,loc);
        % write fuel data
        h5write(filepath,sprintf('%s/FillingLevel',loc),[obj.FillingLevel],[1,1],[1,N]);
    end
end