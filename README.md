# microscope-image-analysis-pipeline
A pipeline to estimate proportion of cell death in fluorescence microscopy images. Code is written in Python for Jupyter Notebook, and uses FIJI macros to open .lof files in a readble format. 

Conda activate mica_env before opening Jupyter!
Run rename_files.ipynb  and move_lofs.ipnyb (if necessary) before running the main pipeline script

## Concept:
This pipeline is based from the hypothesis that the proportion cell death induced is equal to the proportion of nuclear/membrane area that is within one cell membrane radius of cell death stain. This holds for large sample sizes. For membrane-stained images, some form of z-stacking is necessary (so the full cell area is membrane stained), as we need there to be a strong cell distribution.
Unwashed images are incompatible with the pipeline, smudges heavily affect the results, so need to be avoided in image acquisition, and if necessary, can be filtered out using the maximum thresholding size in the main pipeline script (but this doesn’t work perfectly). Basically, if you want to make a change to image acquisition, the main thing that needs to be preserved is the fact that there’s a strong cell size distribution throughout the samples. 

## What does each code do? 
### FIJI_image_processing.ipynb – main pipeline script. 
#### Inputs:
image_directory – the folder with all your .lof images (not in subfolders, so make sure to have named them with identifying details)
all other inputs are paths to the fiji macros they call, don’t touch these, I’ll make sure they’re linked to the right place when I handover. 
#### What it does: 
Goes through all the images in the directory and takes out the metadata, and cell death/nucleus data and masks, as well as creates a tif of the lof files so you can look at the images easily without having to open them in FIJI). After you run all the cells, the image tifs will be in the same place as all the lof files, but the metadata, masks, individual images data (data), and results will be moved to subfolders in the image directory to remove clutter. It can also produce images without any editing at all, but I’ve commented this line out as often the images are just black before any scaling. 
It's worth scrolling through all the images once image processing is done, as images with lots of background noise may be giving dodgy results. You can identify these by comparing the images with their corresponding mask images in the masks folder, the white parts are where the masks have been drawn. ALSO some images haven’t merged correctly and they will be obvious to you by eye.
#### What it can’t do:
It won’t be able to open any images without 3 channels, so make sure you go through your data beforehand to ensure no brightfield-only images sneak in. it also can’t open the unmerged images if when you open them in FIJI it’s an image that opens as several tiles (it can handle smaller image planes though, just the tiles need to be separated to different .lof files). 

### FIJI macros: 
### called in code:
By and large don’t touch these much, however there are a few inputs you need to know about. All these codes are written in the imageJ language.

### combined_macro_python.ijm:
This macro takes masks of significant signal within death stained channel and cell nucleus/membrane channel, and creates a .tif file of the .lof image with background subtraction, and brightness/contrast autoscaling to provide an easy reference image for the user.

#### inputs:
You can edit these values by opening FIJI -> Plugins -> macros -> edit… and open the macro in the window that pops up. Once you change the value, save and quit before running the python code.

You can change the amount each image is cropped to by changing the “perc_img” variable. 
Example:
perc_img = 0.85; (every line MUST end with a ; in the macro coding language!)
crops the image to only the central 85%.

pbmc_nucleus_area is set to the values I found using the large PBMC only images I had. It is used as a maximum PBMC nucleus size to filter out PBMCs from cell line death measurements.

UPPL_nucleus_radius_microns is the average radius of your cell line, the cell death mask is dilated by this radius and all nuclear stain found within this area is called dead membrane. It can be changed to whatever radius you expect your cell of interest to have (nucleus or membrane depending on the staining you use). Note that if this value is changing between images you’ll have to separate these images into their own directories and run the code separately as the macro inputs cannot change between runs.

Uppl_max_nucleus_area is the maximum area you want to be measured, feel free to play around with this value, it’s currently set very high at 1000 square microns.

### Image_to_tif_no_edits_python.ijm:
saves a .tif image of the raw .lof image without any brightness/contrast autoscaling or background subtraction for reference

### metadata_to_csv_python.ijm:
saves the embedded .lof file's metadata as a .csv file for reference

### PBMC_mask_info_python.ijm:
Does not only have to be used for PBMCs, returns a .csv file of all individual nuclear/membrane mask areas in a mask image for cell size analysis

### Single use: 
### Open_and_view.ijm:
A macro that I made for you to check your data before running your code in full.
You can open it in FIJI by clickinf Plugins -> macros -> edit… and open the macro in the window that pops up. Once it opens, press run and a pop-up window will ask you to select the image you want to open. If it fails to open, your images will either be brightfield only, or unmerged, in which case the pipeline won’t be able to open them. If they open as RGB it means they’re images you took without staining. Either way, remove these from the dataset you are running the code on. You don’t have to do this for every image, I just did it for one image per well plate just to make sure all images are compatible with the code.

### Helper codes:
### Visualise_mask.ipynb: 
put the image and its masks in the inputs and it will produce images with the masks overlayed, so you can check by eye if you’re suspicious about a result. Output_folder input is where you want these images to go to see them (they will not output in the Jupyter notebook itself.)

### Rename_files.ipynb: 
super simple, changes all spaces in all the folder/files in a directory (input) to underscores so they can be read by the pipeline (python hates spaces). Worth running on your image directory before you run the pipeline.

### Move_lofs.ipnyb:
moves all the files with a given ending (e.g.”_merged.lof”) inside subfolders in your image directory out to the main directory, renaming them so that they are identifiable and unique (e.g.file1 inside subfolder2 inside subfolder1 will be renamed “subfolder1_subfolder2_file1”). 

### FIJI_nucleus_size_data.ipnyb: 
This isn’t directly related to the pipeline, but can help determine some of the input values. If you have a dataset of several images that contain only one type of cell (e.g. UPPL or PBMC) with a nuclear/membrane stain, you can run these images through the pipeline with no lower size threshold, and then add the nuclear masks to a directory which you can then run through this code, which will return a lognormal distribution of the nucleus/membrane area. 

## Calculations:
percentage live remaining = (1 – total_dead_area/total_nucleus_area)*100
where total_dead_area is the total area of nucleus associated with apoptosis. 
