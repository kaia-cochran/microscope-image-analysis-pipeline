// Get arguments from Python
path = getArgument();
if (path == "") exit("ERROR: no image path recieved");
if (!File.exists(path)) exit("ERROR: Image file does not exist: " + path);

// Extract directory + filename for save
dir = File.getParent(path) + File.separator;
name = File.getNameWithoutExtension(path);

out = dir + name + "_unedited.tif";

run("Bio-Formats Importer", "open=[" + path + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT swap_dimensions z_1=1 c_1=3 t_1=1");
title_input_file = getTitle();
title_input_basename = split(title_input_file, ".");

run("Duplicate...", "duplicate channels=1-3");
title_duplicate_file = getTitle();
selectImage(title_input_file);
close;

selectImage(title_duplicate_file);

// convert image to 8-bit if it's not already
if (bitDepth() != 8) {
	setOption("ScaleConversions", true);
	run("8-bit");
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

run("Merge Channels...", "c1="+c2+" c3="+c1+" c4="+c3+" create");
title_image_merged_channels = getTitle();

run("Stack to RGB");
title_output_file = getTitle();

selectImage(title_image_merged_channels);
close;

selectImage(title_output_file);
saveAs("Tiff", out);

run("Quit");