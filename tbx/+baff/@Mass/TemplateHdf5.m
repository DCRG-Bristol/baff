function TemplateHdf5(filepath,loc)
    baff.Element.TemplateHdf5(filepath,loc);
    %create place holders
    h5create(filepath,sprintf('%s/InertiaTensor',loc),[9 inf],"Chunksize",[9,10]);
    h5create(filepath,sprintf('%s/Force',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/Moment',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/Mass',loc),[1 inf],"Chunksize",[1,10]);
end

