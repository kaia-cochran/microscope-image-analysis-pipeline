// Recieve path from Python
path = getArgument();
if (path == "") exit();
if (!File.exists(path)) exit("ERROR: Image file does not exist: " + path);

// Extract directory + filename for save
dir = File.getParent(path) + File.separator;
name = File.getNameWithoutExtension(path);

out = dir + name + ".csv";
print(out);

// convert metadata to CSV and save 
run("Bio-Formats Importer",
    "open=" + path + " color_mode=Composite display_metadata rois_import=[ROI manager] view=[Metadata only] stack_order=Default");

saveAs("text", out);
run("Close");

print("CSV saved as:");
print(out);
run("Quit");
