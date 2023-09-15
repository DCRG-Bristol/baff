function BaffToProp(obj,filepath,loc)
Fs = h5read(filepath,sprintf('%s/FillingLevel',loc));
for i = 1:length(obj)
    obj(i).FillingLevel = Fs(i);
end
BaffToProp@baff.Mass(obj,filepath,loc)
end