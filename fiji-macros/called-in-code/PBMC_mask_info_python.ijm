// Macro removes small objects (<30 square microns) from nucleus mask and then saves all the 
// individual mask areas as a .csv

path = getArgument();
if (path == "") exit();
if (!File.exists(path)) exit("ERROR: Image file does not exist: " + path);

dir = File.getParent(path) + File.separator;
name = File.getNameWithoutExtension(path);

open(path);
title_input_file = getTitle();
title_input_basename = split(title_input_file, ".");

run("Duplicate...", " ");
title_duplicate_file = getTitle();

selectImage(title_input_file);
close;

selectImage(title_duplicate_file);
run("Analyze Particles...", "size=30-300 show=[Overlay Masks] display include");

save_path = dir + name + "_mask_info.csv";

saveAs("Results", save_path);
run("Quit");