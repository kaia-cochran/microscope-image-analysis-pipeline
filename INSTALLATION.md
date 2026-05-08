# Installation: 

## Python Environment: 
Create a new python environment using terminal/anaconda prompt: This is called “mica_env” but you can change this name to anything you want, just remember that you must activate that environment every time you use these codes. bash the following commands:

```bash
conda create -n mica_env python=3.10
```

proceed with “y”

```bash
conda activate mica_env
```

```bash
pip install notebook
```

```bash
pip install pandas
```

```bash
pip install scikit-image
```

Use this link to find which version of pytorch is compatible with your computer, and install it: [Install pytorch](https://pytorch.org/get-started/locally/)

If you are using a department desktop, it’s best to install the correct GPU version for the PC, as it will significantly speed up a lot of the codes. To find which version you should install, see the “GPU type” section below.

## FIJI installation:
If you already have FIJI installed because you regularly use it, it’s recommended you download FIJI again, and have a dedicated version for this pipeline. Some plugins can interfere with the pipeline and stop it from working. 

Install the correct version of FIJI for your computer using the link: [download FIJI](https://imagej.net/software/fiji/downloads)

Save the folder to an easily accessible place e.g. your desktop. You can open the application by clicking on the “.exe” application. It is recommended that you pin the application to your taskbar to moniter the pipeline’s progress when running code.

Make sure the “bioformats” plugin is installed to FIJI. You can download this plugin by clicking “help” and then “updates…”, once the popup window is open click “manage update sites”, search for “bio-formats” and tick the box. Then click “apply and close”. 

## Pipeline Codes:
Open the “Kaias_pipeline” zip file wherever you want. 

Open Jupyter Notebook within your python environment by bashing:

```bash
conda activate mica_env
```

```bash
jupyter notebook
```

Open “Fiji_image_processing.ipynb” . 

Replace fiji_path with the path to your dedicated FIJI application (the one ending in “.exe”). 

Replace metadata_to_csv_macro_path with the path to the metadata_to_csv_python.ijm file in the FIJI_macros folder

Replace image_to_tif_no_edits_macro_path with the path to the Image_to_tif_no_edits_python.ijm file in the FIJI_macros folder

Replace image_to_masks_and_edited_tif_macro_path with the path to the combined_macro_python.ijm file in the FIJI_macros folder

## GPU type:
For desktops using Nvidia GPUs, bash:

```bash
nvidia-smi
```

This will return the GPU information, including which CUDA version is installed (e.g. 12.8). This is what you want to match the version of pytorch you install to. 

If, for whatever reason, the version is too old to be found in the link above, just replace the final 3 digits in the command with the same ones that match your CUDA version.
For example, if you have CUDA version = 12.4, you can change the prompt:
```
“pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu128”
```
to: 
```
“pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu124”
```
