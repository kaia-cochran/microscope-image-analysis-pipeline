// INPUTS -------------------------------------------------------- 
// percentage of image to keep when cropping
perc_img = 0.99;

// PBMC nucleus area (in square microns) for thresholding - this is the maximum area you 
// would attribute to being a PBMC (not necessarily the mean), and is therefore the minimum size
// you want to measure being sure it's not a PBMC.
pbmc_min_nucleus_area = 82.066;

// Maximum counted area (square microns), imposed to reduce effects of smudging, adjustable at 
// user's discretion
uppl_max_nucleus_area = 1000;

// UPPL_cell_nucleus_radius (in microns) for dilation
UPPL_nucleus_radius_microns = 5.33;

// MAIN SCRIPT ------------------------------------------------------

path = getArgument();
if (path == "") exit("ERROR: no image path recieved");
if (!File.exists(path)) exit("ERROR: Image file does not exist: " + path);

// directory & filename for saving
dir = File.getParent(path) + File.separator;
name = File.getNameWithoutExtension(path);

run("Bio-Formats Importer", "open=[" + path + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT swap_dimensions z_1=1 c_1=3 t_1=1");
title_input_file = getTitle();   // store the title for later
title_input_basename = split(title_input_file, ".");

run("Duplicate...", "duplicate channels=1-3");
title_duplicate_file = getTitle();
selectImage(title_input_file);
close;

selectImage(title_duplicate_file);

// necessary info taken from image metadata to edit image
getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);
if (unit != "microns") {
	exit("Error: scaling info is not in microns");
}
pixel_scaling = maxOf(pixelWidth, pixelHeight);
UPPL_nucleus_radius_pixels = round(UPPL_nucleus_radius_microns/pixel_scaling);

// crop to retain central percentage of image (removing clipping issues)
if (perc_img <= 1) {
	x = round(0.5 * width * (1 - sqrt(perc_img)));
	y = round(0.5 * height * (1 - sqrt(perc_img)));
	new_width = round(sqrt(perc_img) * width);
	new_height = round(sqrt(perc_img) * height);
	makeRectangle(x, y, new_width, new_height);
	run("Crop");
}

run("Split Channels");

// Get a list of all open image titles
titles = getList("image.titles");

// Identify only the channel windows
c1 = "";
c2 = "";
c3 = "";

for (i = 0; i < titles.length; i++) {
    if (startsWith(titles[i], "C1")) c1 = titles[i];
    if (startsWith(titles[i], "C2")) c2 = titles[i];
    if (startsWith(titles[i], "C3")) c3 = titles[i];
}

// nuclear stain channel
selectImage(c1);

// remove background
run("Subtract Background...", "rolling=50 disable");

// duplicate channel for visualisation
run("Duplicate...", " ");
title_duplicate_c1 = getTitle();

// create a mask over image with only significantly bright pixels (nuclear signal)
selectImage(c1);
getStatistics(area_c1, mean_c1, min_c1, max_c1, std_c1);
thresh_c1 = Math.ceil(mean_c1 + 2 * std_c1);
setThreshold(thresh_c1, max_c1, "black & white");
run("Convert to Mask");
run("Analyze Particles...", "size="+pbmc_min_nucleus_area+"-"+uppl_max_nucleus_area+" show=Masks display clear include");
// run("Analyze Particles...", "size="+uppl_min_nucleus_area+"-"+uppl_max_nucleus_area+" show=Masks display clear include");
title_mask_c1 = getTitle();
save_path_live_csv = dir + name + "_nuclear_mask_info.csv";
saveAs("Results", save_path_live_csv);

selectImage(c1);
close;

selectImage(title_mask_c1);
save_path_c1_mask = dir + name + "_nuclear_mask.tif";
saveAs("Tiff", save_path_c1_mask);
close;

// apoptosis stain channel
selectImage(c2);

// remove background
run("Subtract Background...", "rolling=50 disable");

// duplicate channel for visualisation
run("Duplicate...", " ");
title_duplicate_c2 = getTitle();

// create a mask over image with only significantly bright pixels (apoptosis signal)
selectImage(c2);
getStatistics(area_c2, mean_c2, min_c2, max_c2, std_c2);
thresh_c2 = Math.ceil(mean_c2 + 2 * std_c2);
setThreshold(thresh_c2, max_c2, "black & white");
run("Convert to Mask");
run("Analyze Particles...", "size="+pbmc_min_nucleus_area+"-"+uppl_max_nucleus_area+" show=Masks display clear include");
title_mask_c2 = getTitle();

selectImage(c2);
close;

// dilate this mask by the expeceted radius of UPPL cell nucleus to create a mask of 
// areas over which nuclei are "associated with death"
selectImage(title_mask_c2);
run("Options...", "iterations="+UPPL_nucleus_radius_pixels+" count=1 do=Dilate");

save_path_c2_mask = dir + name + "_apoptosis_mask.tif";
saveAs("Tiff", save_path_c2_mask);
close;

// create a mask of overlap between nucleus mask, and nuclei associated with death mask
open(save_path_c1_mask);
live_mask = getTitle();

open(save_path_c2_mask);
dilated_mask = getTitle();

imageCalculator("AND create", live_mask, dilated_mask);
overlap_mask = getTitle();

selectImage(live_mask);
close;

selectImage(dilated_mask);
close;

selectImage(overlap_mask);
save_path_overlap_mask = dir + name + "_overlap_mask.tif";
saveAs("Tiff", save_path_overlap_mask);

run("Analyze Particles...", "display clear include");
save_path_overlap_csv = dir + name + "_overlap_mask_info.csv";
saveAs("Results", save_path_overlap_csv);
close;

//create an image for visualisation:
selectImage(title_duplicate_c1);
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

selectImage(title_duplicate_c2);
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

selectImage(c3);
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

run("Merge Channels...", "c1="+title_duplicate_c1+" c3="+title_duplicate_c2+" c4="+c3+" create");
title_image_merged_channels = getTitle();

run("Stack to RGB");
title_output_file = getTitle();

selectImage(title_image_merged_channels);
close;

save_path = dir + name + ".tif";

selectImage(title_output_file);
saveAs("Tiff", save_path);
close;

run("Quit");