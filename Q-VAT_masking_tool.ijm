/* Q-VAT masking tool
 *  
 *  	Pre-processing tool to create vascular and binary mask from immuno-stained microscopy images. 
 *  	The output masks are saved as whole images and as separate tiles that can be analyzed using Q-VAT.
 *  	
 * 		Use: Open in Fiji < Press Run < Select input directory and input parameters < Press OK. 
 *		A more detailed manual can be found on GitHub: link to page
 *  
 * 	 	Before running the Q-VAT masking tool the BioVoxxel Toolbox should be installed:
 *  	https://imagej.net/imagej-wiki-static/BioVoxxel_Toolbox
 *  	
 * Author: Bram Callewaert
 * Contact: bram.callewaert@kuleuven.be
 * 
 * Copyright 2022 Bram Callewaert, Leuven Univeristy, Departement of Cardiovascular Sciences, Center for Molecular and Vascular Biology (CMVB)
 * This script is is licensed under the Creative Commons Attribution 4.0 International License
 * 
 * if using Q-VAT Masking Tool please cite: https://doi.org/10.3389/fcvm.2023.1147462
 */

#@ String (visibility=MESSAGE, value="<font size=20><b> Q-VAT masking tool </b></font>", required=false)msg
#@ File (label="Select a directory", style="directory") inputDir1
#@ Float (label="Calibration (µm/px)", min=0, value=0.642776, persist=false, style="format:#.######") calibration
#@ Float (label="Radius of biggest object (µm)", min=0, value=16, persist=false, style="format:###") Biggest_feature_radius
#@ Float (label="Particle size lower range (µm^2)", min=0, value=10000, persist=false, style="format:#.######") particle_size_lower_range_um
#@ Float (label="Radius for median filtering (µm)", min=0, value=15, persist=false, style="format:#.######") median_filt_radius
#@ Float (label="Remove small particles (µm^2)", min=0, value=10, persist=false, style="format:#.######") remove_small_particles
#@ String (choices={"Default","Huang", "Otsu"}, style="listbox") Thresholding_method
#@ String (choices={".tif", ".tiff", ".png", ".jpg"}, style="listBox") file_extension
#@ String (choices={"Yes", "No"}, style="radioButtonHorizontal") save_validation_image



setBatchMode(true );
inputDir = inputDir1 + File.separator;
subFolderList = getFileList(inputDir);
			
//loop over all the folders (i.e. subjects) within the selected input directory
for (k=0; k<subFolderList.length;k++){
	
	//get a list of all folders in the sub-directory (i.e. subjects)
	subdir= subFolderList[k]; 
	subdirList = getFileList(inputDir + subdir); //files in the folder of each subject
	if (File.exists(inputDir + subdir +  "vascularMASK" + File.separator)){
		list = getFileList(inputDir + subdir +  "vascularMASK" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "vascularMASK"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "vascularMASK" + File.separator);
	}
	
	if (File.exists(inputDir + subdir +  "TissueMASK" + File.separator)){
		list = getFileList(inputDir + subdir +  "TissueMASK" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "TissueMASK"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "TissueMASK" + File.separator);
	}
	
	if (File.exists(inputDir + subdir +  "04_Tissue_mask" + File.separator)){
		list = getFileList(inputDir + subdir +  "04_Tissue_mask" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "04_Tissue_mask"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "04_Tissue_mask" + File.separator);
	}
	
	if (File.exists(inputDir + subdir +  "01_split_vascular_mask" + File.separator)){
		list = getFileList(inputDir + subdir +  "01_split_vascular_mask" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "01_split_vascular_mask"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "01_split_vascular_mask" + File.separator);
	}

	if (File.exists(inputDir + subdir +  "02_co_localized_chan1" + File.separator)){
		list = getFileList(inputDir + subdir +  "02_co_localized_chan1" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "02_co_localized_chan1"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "02_co_localized_chan1" + File.separator);
	}
	
	if (File.exists(inputDir + subdir +  "03_co_localized_chan2" + File.separator)){
		list = getFileList(inputDir + subdir +  "03_co_localized_chan2" + File.separator);
		for (j=0; j<list.length; j++){					
			ok=File.delete(inputDir + subdir +  "03_co_localized_chan2"+ File.separator + list[j]);
		}
		ok=File.delete(inputDir + subdir +  "03_co_localized_chan2" + File.separator);
	}

	for ( i = 0; i < subdirList.length; i++ ) {
			
		//read image size and overlap from .TXT file: (needs to contain width, height, %overlap)
		if (endsWith(subdirList[i], ".txt")){
			Table.open(inputDir + subdir +  subdirList[i]); //Open text file
			saveAs("text", inputDir + subdir + "05_dimensions.txt");
			widthheightoverlap = Table.getColumn("C1"); 
			tilewidth = widthheightoverlap[0];
			tileheight = widthheightoverlap[1];
			tileoverlap = widthheightoverlap[2];
			close("05_dimensions.txt");
			//close(subdirList[i]);
			File.delete(inputDir + subdir + subdirList[i]);  //remove the .txt file
			close("Log");
		}
		
		if ( endsWith( subdirList[i], file_extension) ) { 
			open( inputDir + subdir +  subdirList[i] ); //open stitched images
			
			if (i==1){
				outputname = "01_split_vascular_mask";
			}
			if (i==2) {
				outputname = "02_co_localized_chan1";
			}
			
			if(i==3){
				outputname = "03_co_localized_chan2";
			}
			
			run("Properties...", "channels=1 slices=1 frames=1 unit=pixels pixel_width=1 pixel_height=1 voxel_depth=1"); //set unit to 1 pixel 
			rename("IMG");
			//run("8-bit"); //convert to 8bit (needed for analyze particles)
			run("Duplicate...", "duplicate"); // duplicate image, to keep the raw image
			selectWindow("IMG-1"); 
			//remove noise from the images using despeckle: 
			run("Despeckle");
			// Smooth - This filter replaces each pixel with the average of its 3x3 neighborhood
			run("Smooth");
			// Background substraction: 
			run("Convoluted Background Subtraction", "convolution=Gaussian radius=" + Biggest_feature_radius/calibration); // convoluted background subtraction
			//run("Convoluted Background Subtraction", "convolution=Gaussian radius=" + 16/14.43); // convoluted background subtraction
		
			
			if (i==1){
			/// CREATE Tissue MASK and multiply to remove background signal ///
				selectWindow("IMG");
				run("8-bit"); //convert to 8bit (needed for analyze particles)
				run("Enhance Contrast...", "saturated=60"); //enhance the contrast of the image
				run("Apply LUT"); //apply the LUT (after saturation)
				run("Smooth");
				
				setAutoThreshold("Huang dark");
				run("Threshold...");
				call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
				close("Threshold");	
				setOption("BlackBackground", false); 	//necessary for Analyze particles
				
				//convert image to a binary image
				run("Convert to Mask");
				
				run("Median...", "radius=" + median_filt_radius/calibration);
				//run("Median...", "radius=" + 15/0.65);
							
				
				//only invert if background = 255 (check this by checking the 4 corners)
				width = getWidth(); //width of the stitched image
				height = getHeight(); //height of the stitched image
				topleft=getValue(0,0);
				topright=getValue(width-1,0);
				bottomleft=getValue(0,height-1);
				bottomright=getValue(width-1,height-1);
				sum = topleft + topright + bottomleft + bottomright; // background will be 0 is sum is 0, background will be 255 if sum is above zero
				if (sum>0) {run("Duplicate...", "duplicate"); rename("IMG-2");  selectWindow("IMG"); run("Invert"); setOption("BlackBackground", false); }
				else{run("Duplicate...", "duplicate"); run("Invert"); rename("IMG-2"); } // duplicate image, to 8-bit grayscale image
				selectWindow("IMG");
								
				run("Analyze Particles...", " size=" + particle_size_lower_range_um/(calibration*calibration) + "-Infinity show=Nothing display clear summarize add in_situ"); //run analyze particles; WITHOUT FILL HOLES!!!
				//run("Analyze Particles...", " size=" + 10000/(0.642776*0.642776) + "-Infinity show=Nothing display clear summarize add in_situ"); //run analyze particles; WITHOUT FILL HOLES!!!
				

				count = roiManager("count");
				//rename("MAX_Stack");
				array = newArray(count);
				//if(array.length==0){run("Select None"); run("Create Mask"); run("Subtract...", "value=255");}//create empty MASK 
				//if(array.length==0){run("Select None"); selectWindow("IMG"); run("Create Mask"); run("Subtract...", "value=255");}//create empty MASK 
				if(array.length==0){run("Select None"); selectWindow("IMG"); run("Duplicate...", "duplicate"); rename("Mask"); run("Subtract...", "value=255");}//create empty MASK 
				
				  for (r=0; r<array.length; r++) {
				  	  if(r>0){selectWindow("Mask"); rename("previous_Mask");} 
				      selectWindow("IMG");
				      array[r] = r;
				      roiManager("select", r);
				      run("Create Mask");
				      if(r>0){imageCalculator("Add", "Mask","previous_Mask"); close("previous_Mask");}
				  }
				selectWindow("Mask");	
				rename("tissue_Mask"); 				
				close("Summary");
				close("results");
				close("ROI manager"); 
				
				selectWindow("IMG-2");
				run("Analyze Particles...", " size=" + particle_size_lower_range_um/(calibration*calibration) + "-Infinity show=Nothing display clear summarize add in_situ"); //run analyze particles; WITHOUT FILL HOLES!!!
				//run("Analyze Particles...", " size=" + 10000/(0.642776*0.642776) + "-Infinity show=Nothing display clear summarize add in_situ"); //run analyze particles; WITHOUT FILL HOLES!!!
				
				count = roiManager("count");
				//rename("MAX_Stack");
				array = newArray(count);
				if(array.length==0){run("Select None"); selectWindow("IMG-2"); run("Duplicate...", "duplicate"); rename("Mask"); run("Subtract...", "value=255");}//create empty MASK 
				if(array.length==1){run("Select None"); selectWindow("IMG-2"); run("Duplicate...", "duplicate"); rename("Mask"); run("Subtract...", "value=255");}//create empty MASK 
				  for (r=1; r<array.length; r++) { //i=0 is the background--> ignore this one (should be the largest one)
				  	  if(r>1){selectWindow("Mask"); rename("previous_Mask");} 
				      selectWindow("IMG-2");
				     // array[r] = r;
				      roiManager("select", r);
				      run("Create Mask");
				      if(r>1){imageCalculator("Add", "Mask","previous_Mask"); close("previous_Mask");}
				  }
				selectWindow("Mask");	
				run("Divide...", "value=2");
				imageCalculator("Subtract", "tissue_Mask","Mask");
				selectWindow("tissue_Mask");
				setOption("BlackBackground", false);
				run("Convert to Mask");	
				
				width = getWidth(); //width of the stitched image
				height = getHeight(); //height of the stitched image
				topleft=getValue(0,0);
				topright=getValue(width-1,0);
				bottomleft=getValue(0,height-1);
				bottomright=getValue(width-1,height-1);
				sum = topleft + topright + bottomleft + bottomright; // background will be 0 is sum is 0, background will be 255 if sum is above zero
				if (sum>0) {run("Invert"); }
				close("Mask"); 
				close("IMG-2");
				close("IMG"); 
				
				close("Summary"); 
				close("Results"); 
				run("Select None");
				close("ROI manager"); 
				
				selectWindow("tissue_Mask");
								
				title = replace(subdirList[i], file_extension, "");  //remove the ".tif extension"
	
				File.makeDirectory(inputDir + subdir + File.separator + "04_Tissue_mask"); //make a subdirectory in the ROI folder
				getLocationAndSize(locX, locY, sizeW, sizeH); 
				width = getWidth(); //width of the stitched image
				height = getHeight(); //height of the stitched image
				
				tileWidthoverlap = tilewidth - ((tilewidth/100)*tileoverlap);
				numCol = round((width - tilewidth)/tileWidthoverlap)+1; 
				tileHeightoverlap = tileheight - ((tilewidth/100)*tileoverlap);
				numRow = round((height - tileheight)/tileHeightoverlap)+1; 
				
				for (x = 0; x < numCol; x++) { 
						if(x==0){
							offsetX = 0 ;						
						}
						else{
							offsetX = tilewidth + (x-1) * tileWidthoverlap;
						}
					for (y = 0; y < numRow; y++) { 
						if (y==0) {
							offsetY= 0 ;
						}
						else{
							offsetY = tileheight + (y-1) * tileHeightoverlap;	
						}	
						if (offsetX > width){offsetX = width;} // stop if the end of the image is reached
						if (offsetY > height){offsetY = height;}
					 	call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
						
						if(x+1<10){
							xnum= "00" + x+1; 
						}
						if(x+1<1000 && x+1>=10){
							xnum ="0" + x+1;
						}
						if(x+1>=10000){
							xnum= "" + x+1;
						}
						
						if(y+1<10){
							ynum= "00" + y+1; 
						}
						if(y+1<1000 && y+1>=10){
							ynum ="0" + y+1;
						}
						if(y+1>=10000){
							ynum= "" + y+1;
						}
					 	
						tileTitle = title + "_" + xnum + "_" + ynum; 
	 					run("Duplicate...", "title=" + tileTitle); 
	 					if (x==0 && y==0){
	 					makeRectangle(offsetX, offsetY, tilewidth, tileheight); 
	 					}
	 					if (x==0 && y>0){
	 					makeRectangle(offsetX, offsetY, tilewidth, tileHeightoverlap); 
	 					}
	 					if (x>0 && y==0){
	 					makeRectangle(offsetX, offsetY, tileWidthoverlap, tileheight); 
	 					}
	 					if (x>0 && y>0){
	 					makeRectangle(offsetX, offsetY, tileWidthoverlap, tileHeightoverlap); 
	 					}
	 					run("Crop"); 
	 					saveAs("Tiff",inputDir + subdir + File.separator + "04_Tissue_mask" + File.separator  + tileTitle);
	 					close(tileTitle + ".tif");					
					 }
				}
					
				File.makeDirectory(inputDir + subdir + File.separator + "TissueMASK"); //make a subdirectory in the ROI folder
				//save output mask 
				saveAs("Tiff",inputDir + subdir + File.separator + "TissueMASK" + File.separator + title + "TissueMASK.tif");
			}
			
			if (i==2 || i==3){
				tissuetitle = replace(subdirList[1], file_extension, "");  //remove the ".tif extension"
				open( inputDir + subdir + File.separator + "TissueMASK" + File.separator + tissuetitle + "TissueMASK.tif" ); //open tissue mask
				title = replace(subdirList[i], file_extension, "");  //remove the ".tif extension"
			}
			rename("IMG");		
			run("Divide...","value=255.000");
			imageCalculator("Multiply", "IMG-1","IMG");
			close("IMG"); 
			selectWindow("IMG-1");
			
			// Auto Threhsold: 	(Default, Huang or Otsu)
			setAutoThreshold(Thresholding_method  + " dark");
			run("Threshold...");
			call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
			close("Threshold");	
			run("Convert to Mask");		
			
			
			run("Analyze Particles...", "size="  + remove_small_particles/(calibration*calibration) + "-Infinity show=Masks clear");
			close("IMG-1");
			selectWindow("Mask of IMG-1");
			rename("IMG-1");		
			
	
			
			File.makeDirectory(inputDir + subdir + File.separator + outputname); //make a subdirectory in the ROI folder
			 for (x = 0; x < numCol; x++) { 
						if(x==0){
							offsetX = 0;						
						}
						else{
							offsetX = tilewidth + (x-1) * tileWidthoverlap;
						}
				for (y = 0; y < numRow; y++) { 
						if (y==0) {
							offsetY= 0 ;
						}
						else{
							offsetY = tileheight + (y-1) * tileHeightoverlap;	
						}	
				 	call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
					
					if(x+1<10){
						xnum= "00" + x+1; 
					}
					if(x+1<1000 && x+1>=10){
						xnum ="0" + x+1;
					}
					if(x+1>=10000){
						xnum= "" + x+1;
					}
					
					if(y+1<10){
						ynum= "00" + y+1; 
					}
					if(y+1<1000 && y+1>=10){
						ynum ="0" + y+1;
					}
					if(y+1>=10000){
						ynum= "" + y+1;
					}
				 	
					tileTitle = title + "_" + xnum + "_" + ynum; 
 					run("Duplicate...", "title=" + tileTitle); 
 					if (x==0 && y==0){
	 					makeRectangle(offsetX, offsetY, tilewidth, tileheight); 
	 				}
	 				if (x==0 && y>0){
	 					makeRectangle(offsetX, offsetY, tilewidth, tileHeightoverlap); 
	 				}
	 				if (x>0 && y==0){
	 					makeRectangle(offsetX, offsetY, tileWidthoverlap, tileheight); 
	 				}
	 				if (x>0 && y>0){
	 					makeRectangle(offsetX, offsetY, tileWidthoverlap, tileHeightoverlap); 
					}
 					run("Crop"); 
 					saveAs("Tiff",inputDir + subdir + File.separator + outputname + File.separator  + tileTitle);
 					close(tileTitle + ".tif" );					
				 }
			}	
			File.makeDirectory(inputDir + subdir + File.separator + "vascularMASK"); //make a subdirectory in the ROI folder
			//save output mask 
			saveAs("Tiff",inputDir + subdir + File.separator + "vascularMASK" + File.separator + title + "vascularMASK_chan" + i + ".tif");
			close("IMG-1");
			
			if (save_validation_image == "Yes") {
			
				open( inputDir + subdir +  subdirList[i] ); //open stitched images
				rename("IMG");
				
				open( inputDir + subdir + File.separator + "TissueMASK" + File.separator + title + "TissueMASK.tif" ); //open tissue mask
				rename("tissueMask");
				run("Divide...", "value=255");
				
				imageCalculator("Multiply", "IMG", "tissueMask");
				run("Enhance Contrast", "saturated=0.35");
				run("RGB Color");
				close("tissueMask"); 
				
				selectWindow(title + "vascularMASK_chan" + i + ".tif");
				run("Invert LUT");
				getLut(reds, greens, blues);
				reds[255]=0;
				greens[255]=0;
				blues[255]=255;
				setLut(reds, greens, blues); //red[255]=0, green[255]=0, blue[255]=255
				
				imageCalculator("Add", "IMG",title + "vascularMASK_chan" + i + ".tif");
				selectWindow("IMG");
				saveAs("Tiff",inputDir + subdir + File.separator + "vascularMASK" + File.separator + title + "vascularMASK_chan" + i + "_validation_image.tif");
				close(title + "vascularMASK_chan" + i + "_validation_image.tif");
			}
			//
			
			close(title + "vascularMASK_chan" + i + ".tif");
			
		}
	}
}
setBatchMode( false );
exit();
