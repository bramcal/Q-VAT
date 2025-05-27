# **Perform Region-specific analysis using Q-VAT**

Instead of using Q-VAT for the entire tissue mask, you can also perform region-specific analysis. This allows you to investigate a specific region, ignore parts of the sample that are not stained well, or compare differences between different ROIs. To perform Q-VAT on an ROI, you should provide Q-VAT with an ROI rather than the tissue mask of the entire tissue section. 

Currently, the Q-VAT tool is limited to a single mask, but multiple ROIs can be analyzed by repeating the analysis using different input masks.

## Manual Delineation of Regions Of Interest in Imagej:

**steps:**

1) Open an image in ImageJ.
2) Open the ROI Manager via Analyze → Tools → ROI Manager or search for "ROI Manager."
3) Select a drawing tool to delineate your ROI.

    **Polygon Tool:**
    
      - Draw your ROI by left-clicking along the edge of the region, placing points to define its shape.
      - The closer the points, the finer the detail.
      - To finish the shape, right-click, completing the last line between the final two points.
      - If a point needs adjustment, hover over the white square and drag it to reposition.
      - To start over, simply click outside the ROI, which will erase the entire drawing—use caution with complex ROIs.
      - To create an ROI with a hole, complete your shape first, then hold Alt and draw the hole within the ROI.
          Note that you can’t adapt the points after this, so you should do that first
      -  (optional) To create a ROI consisting of multiple parts (e.g., separate regions in the left and right brain hemispheres), follow these steps:
    
          1) Hold Shift on your keyboard and draw a second ROI outside of the previous one.
              Note:You should only hold Shift or Alt for the first point of the second ROI or the ‘hole’ in the ROI. Holding Shift or Alt throughout the entire process will prevent you from properly drawing the ROI.
    
          2) Press Add [t] in the ROI Manager to save the finished ROI. You can update the ROI later if you need to make modifications.
    
          3) Adding a second ROI: Start drawing a new one, but note that the previous ROI will (by default) disappear. To keep previous ROIs visible, select "Show All" in the ROI Manager. Only ROIs that have been added to the ROI Manager will remain in memory—make sure to add your ROI before starting a second one.
    
          4) Selecting and saving ROIs:
          
          - When you click on an ROI in the ROI Manager, the selected ROI will become highlighted in blue.
          - To save an ROI, press "More" in the ROI Manager, then "Save", select the output folder, rename the file, and save it as a .roi file.
          - The saved .roi file can be opened in ImageJ at any time using "More > Open".
          - ROI files allow modifications, except for ROIs with holes or separate parts (e.g., Q-VAT-related ROIs).
              Note: Saving the ROI is optional, but it’s useful if you plan to make changes later.
            
    **Freehand selection tool:**
  
      - Draw the ROI by holding the left mouse button and moving around the desired area.
      - Finish the ROI by right-clicking, which will connect the first and last points with a straight line.
      - Add the ROI to the ROI Manager and save it using the same steps as described above.
      
## create a ROI mask that can be used in Q-VAT:

1) Select the ROI that you want to convert into a mask.

2) Generate the mask:

    - Go to Edit → Selection → Create Mask.
    - This will create an image called "Mask", where:
        - The background is white (pixel value 0).
        - The ROI is black (pixel value 255).
      Note: You can verify pixel values by hovering your mouse over the ROI/background and checking the FIJI menu bar for the values at position x = … , y = ….

3) Save the mask:

    - Select the image and go to File → Save As → TIFF.
    - Choose the directory where you want to save your mask files.
    - Rename the file from "Mask" to something meaningful, e.g., "Cortex.tif".
    - Save the file.

## Use the generated mask in Q-VAT:

To use a generated ROI mask in Q-VAT instead of a whole tissue mask, follow these steps:

1)  Save the ROI Masks
     - Save the ROI masks in the TissueMask subfolder of each subject.
     - If you masked a specific ROI in all subjects (e.g., Cortex), save all masks with the same filename (e.g., "Cortex.tif"). 
      Important: The code uses filenames to locate the correct file, and it is case-sensitive.

2) Run the ImageJ Script
    - Open the ImageJ script: "split_ROIs_overlap_loop.ijm".
    - Adapt the ROI name to match the correct filename (e.g., "Cortex.tif").
    - Adjust the tile width and tile height to the correct dimensions.
    - Set the tile overlap percentage to match your acquisition settings.
    - Run the script on your input directory.
        - The script will loop over all subject folders, open the ROI mask file (e.g., "Cortex.tif"), and split it into correctly sized tiles.
        - The output will be saved in the TissueMask folder as a directory: "04_Tissue_MASK_" + ROI name (e.g., "04_Tissue_MASK_Cortex").

3) Running Q-VAT with the ROI Mask
    - Move the "04_Tissue_MASK" folder inside the Subject folder to the TissueMask folder. This ensures you retain the tissue mask for future analysis.
    - Copy the split ROI mask folder (e.g., "04_Tissue_MASK_Cortex") to the subject folder.
      Note: Repeat this step for all subjects.

4) Running Q-VAT
    - Run Q-VAT as usual, but instead of using the whole tissue mask, it will now use the provided ROI mask.
    - If you want to analyze multiple ROIs, repeat the process for each ROI.
    - After running Q-VAT, move "04_Tissue_MASK_Cortex" back to the TissueMask subfolder and select another ROI mask for analysis.

5) Output Files & Storage
    The output files are saved inside the "04_Tissue_MASK_" folder and can be used for quantification.
    Important: Do not delete the "04_Tissue_MASK_" folder if you plan to analyze another ROI—deleting it will also remove the output files.
