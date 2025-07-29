clear all
adp = TAW();
tic;
for i = 1:1
    adp.BuildBaff();
end
toc

f = figure(1);
clf;
adp.Baff.draw(f,Type="surf");
axis equal
lighting gouraud