clear all
adp = TAW();
adp.HingeEta = 0.8;
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