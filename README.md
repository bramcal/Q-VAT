# **Quantitative Vascular Analysis Tool (Q-VAT)**

<img src="Images/Q-vat%20logo.png" width="300" align="right">

Q-VAT is an ImageJ tool to perform automated quantification of the vasculature in tiled, segmented two-dimensional images.





# **Q-VAT masking Tool**

The Q-VAT masking Tool  uses a succession of several ImageJ commands to automatically create a vascular mask and tissue mask from stitched immuno-stained images. The generation of these masks consist of two parts First, the input image is used to create a Tissue mask. Next, the input images and the Tissue mask are used to create a vascular mask containing only the vasculature. Both masks are saved as whole images and as separate tiles that can be analyzed using the Q-VAT tool. 

<img src="Images/Masking_tool_brain.png" width="600" align="center">


**File organization:**

<img src="Images/file_organisation_masking_tool.PNG" width="200" align="right">

The Q-VAT masking tool requires a fixed file organisation. The Q-VAT maksing tool will automatically loop over the different subfolders and load the correct files. It is therefore important to maintain a fixed order of the files. The exact naming of the file is not important. Within the Input directory there should be a sub-directory for each sample that you want to processed. Each of these subdirectories (e.g. subj001) should have the following files: 

- Dimension file (.txt): **The first file in the folder** should be a .txt file that contains:

   - Width of the tiles you want to analyse (px)
   - Height of the tiles in pixels you want to analyse (px)
   - Percentage overlap that has been used to acquire the tiles (%).

        This is important if you want to split the original image into the original acquisition tiles removing the overlapping parts (Q-VAT masking tool assumes Down&Ritght stitching). Use 0 if no overlap was used or if you want to split the original images in tiles with a fixed size.
        
        Example: 00_dimensions.txt
    
           2048
           2044
           7

- Single channel stitched High resolution (immuno-stained) images. One image if you want to analyse only a single channel. Two or three images if you want to analyse one or two co-localized channels. The main channels should always be the first image file in the folder (e.g. image_Chan1.tif, image_Chan2.tif, image_Chan3.tif). 


**Input Parameters:**
- Input Directory: Input directory containing sub-directories for each sample.
- Pixel Calibration (µm/px): calibration of the pixels in the original image.
- Radius of the biggest Object (µm): Estimate of the radius of the biggest object in the original image (used as biggest feauture diameter for the rolling ball method in during the Convoluted backgroud substraction)
- Particle size lower range (µm²): Minimum area of particles that should be included in the tissue mask (Analyze particles).
- Radius for median filtering (µm): Radius that is used for median filtering.
- File extension: File extension of the original images.


**Graphical User Interface:**

<img src="Images/Q-VAT%20masking%20tool%20GUI.PNG" width="600" align="center">

**Output Parameters:**

The Q-VAT masking tool will automatically generate the following sub-directories/files within each sample folder:
- 01_split_vascular_mask: Sub-directory that contains the Segmented tiles obtained by dividing the vascular mask into smaller tiles (.tif)
- [02_co_localized_chan1:  Sub-directory that contains the Segmented tiles of the first co-localized channel (.tif) ]
- [03_col_localized_chan2: Sub-directory that contains the Segmented tiles of the second co-localized channel (.tif)]
- 04_Tissue_mask: Sub-directory that contains the segmented tissue mask obtained by dividing the tissue mask into tiles (.tif)
- 05_dimensions.txt: text file with the tile dimensions used to generate the smaller tiles (.txt)
- TissueMask: Sub-directory that contains the Tissue mask as a whole image with the same dimensions as the original image.
- VascularMask: Sub-directory that contains the segmented vascular mask as a whole image with the same dimensions as the original image.
 

# **Q-VAT**

EXPLAIN Q-VAT - 


**File organization**

done autmatically when the Q-VAT masking tool is used
order of the files is important! (names are not important)

#Input Parameters
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
