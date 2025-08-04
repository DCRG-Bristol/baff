function TemplateHdf5(filepath,loc)
%TEMPLATEHDF5 Create a template for the Beam BAFF object in an HDF5 file.
%Args:
%   filepath (string): Path to the HDF5 file
%   loc (string): Location in the file where the Beam data will be stored
    baff.Element.TemplateHdf5(filepath,loc);
    %create place holders
    h5create(filepath,sprintf('%s/ComponentNums',loc),[1 inf],"Chunksize",[1,10]);
end

