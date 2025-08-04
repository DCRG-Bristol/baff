function TemplateHdf5(filepath,loc)
%TEMPLATEHDF5 Create a template for the Beam BAFF object in an HDF5 file.
%Args:
%   filepath (string): Path to the HDF5 file
%   loc (string): Location in the file where the Beam data will be stored
    %create place holders
    h5create(filepath,sprintf('%s/Materials/E',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/G',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/rho',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/nu',loc),[1 inf],"Chunksize",[1,10]);
    h5create(filepath,sprintf('%s/Materials/Name',loc),[1 inf],"Chunksize",[1,10],"Datatype","string");
end