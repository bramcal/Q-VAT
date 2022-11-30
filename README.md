# Quantitative Vascular Analysis Tool (Q-VAT)

<img src="Images/Q-vat%20logo.png" width="300" align="right">

Q-VAT is an ImageJ tool to perform automated quantification of the vasculature in tiled, segmented two-dimensional images.





# Q-VAT masking Tool

The Q-VAT masking Tool  uses a succession of several ImageJ commands to automatically create a vascular mask and tissue mask from stitched immuno-stained images. The generation of these masks consist of two parts. First, the input image is used to create a Tissue mask. Next, the input images and the Tissue mask are used to create a vascular mask containing only the vasculature. Both masks are saved as whole images and as separate tiles that can be analyzed using the Q-VAT tool. 

**File organization:**
explain required file organisation
txt file with tile size and % overlap


**Input Parameters**
- Input Directory:
- Pixel Calibration (µm/px):
- Radius of the biggest Object  (µm):
- Particle size lower range (µm²):
- Radius for median filtering (µm):
- File extension: 

<img src="Images/Q-VAT%20masking%20tool GUI.PNG" width="600" align="center">

**Output Parameters**
The Q-VAT masking tool will automatically generate the following ouptut within each sample folder:
- 01_split_vascular_mask:
- ()
- ()
- 04_Tissue_mask: 
- 05_dimensions.txt:
- TissueMask
- VascularMask

# Q-VAT

**File organization**
done autmatically when the Q-VAT masking tool is used
order of the files is important! (names are not important)

**Input Parameters**
- Input directory:
- Pixel calibration (µm/px):
- Vascular compartement separation threshold (µm):
- Close label radius (µm):
- Prune ends threshold (µm):
- Save_Output_Figures (Yes/No):
- Colocalization_channels (None, Channel2, Channel 2 &3): 

<img src="Images/Q-VAT-GUI.png" width="600" align="center">

**Output Parameters**
- Output....

# Requirements:

Before using the Q-VAT you should install the following plugins: 

- FIJI is Just ImageJ. Download instructions: https://imagej.net/Fiji/Downloads
- BioVoxxel Toolbox. Installation: https://imagej.net/plugins/biovoxxel-toolbox
- Read and Write Excell. Installation: https://imagej.net/plugins/read-and-write-excel
- 3D ImageJ Suite. Installation: https://imagej.net/plugins/3d-imagej-suite/
- [Prune_Skeleton_Ends.bsh](https://gist.github.com/lacan/0a12113b1497db86d7df3ef102efd34d#file-prune_skeleton_ends-bsh)
Download and Unzip the Prune_Skeleton_Ends.bsh file and copy it into the FIji plugins folder (e.g. \fiji-win64\Fiji.app\plugins). Then,  restart ImageJ. 

#  How to cite:

If using Q-VAT, please cite: (link paper)
