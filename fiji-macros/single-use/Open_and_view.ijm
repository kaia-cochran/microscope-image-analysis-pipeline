//inputs:
var path;
var perc_img

path = File.openDialog("Choose an image");

// percentage of image to keep when cropping
perc_img = 0.99;

run("Bio-Formats Importer", "open=[" + path + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT swap_dimensions z_1=1 c_1=3 t_1=1");
title_input_file = getTitle();   // store the title for later
title_input_basename = split(title_input_file, ".");

run("Duplicate...", "duplicate channels=1-3");
title_duplicate_file = getTitle()
selectImage(title_input_file);
close;

selectImage(title_duplicate_file);

// crop to retain central percentage of image (removing clipping issues)
getDimensions(width, height, channels, slices, frames);

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
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

// apoptosis stain channel
selectImage(c2);
run("Subtract Background...", "rolling=50 disable");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

selectImage(c3);
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

run("Merge Channels...", "c1="+c2+" c3="+c1+" c4="+c3+" create");
title_image_merged_channels = getTitle();

run("Stack to RGB");
title_output_file = getTitle();

selectImage(title_image_merged_channels);
close;

selectImage(title_output_file);