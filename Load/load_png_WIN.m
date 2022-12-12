function data = load_png_WIN(file)
% [dataout] = load_png_WIN(file)
% inputs  - file, file path and name of a PNG image file
% outputs - dataout, structure containing the images from the PNG files
% Remarks
% - This function loads in PNG files and adds them to a structure.
% Future Work
% - None.
% Aug 2022 - Created by Ben Senderling, bsender@bu.edu
%% Begin Code

data.image.data.img = imread(file);

end
