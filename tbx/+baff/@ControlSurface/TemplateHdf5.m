function TemplateHdf5(filepath,loc)
%TEMPLATEHDF5 Create a template for the Beam BAFF object in an HDF5 file.
%Args:
%   filepath (string): Path to the HDF5 file
%   loc (string): Location in the file where the Beam data will be stored
    %create placeholders
    h5create(filepath,sprintf('%s/ControlSurface/Names',loc),[1 inf],"Chunksize",[1,10],"Datatype","string");
    h5create(filepath,sprintf('%s/ControlSurface/Etas',loc),[2 inf],"Chunksize",[2,10]);
    h5create(filepath,sprintf('%s/ControlSurface/pChords',loc),[2 inf],"Chunksize",[2,10]);
end

