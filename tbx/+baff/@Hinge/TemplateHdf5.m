function TemplateHdf5(filepath,loc)
    baff.Element.TemplateHdf5(filepath,loc);
    %create place holders
    h5create(filepath,sprintf('%s/HingeVector',loc),[3 inf],"Chunksize",[3,10]);
    h5create(filepath,sprintf('%s/Rotation',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/K',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/C',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/isLocked',loc),[1 inf],"Chunksize",[1,10]);
end

