function BaffToProp(obj,filepath,loc)
Is = h5read(filepath,sprintf('%s/InertiaTensor',loc));
ms = h5read(filepath,sprintf('%s/Mass',loc));
for i = 1:length(obj)
    obj(i).mass = ms(i);
    obj(i).InertiaTensor = reshape(Is(:,i),3,3);
end
BaffToProp@baff.Point(obj,filepath,loc)
end