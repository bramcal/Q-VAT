/* Quantitative Vascular Analysis Tool (Q-VAT)
 *  
 * 		ImageJ macro to perform automated quantification of the vasculature in tiled, segmented two-dimensional images.
 * 
 * 		Use: Open in Fiji < Press Run < Select input directory and input parameters < Press OK. 
 * 		A more detailed manual can be found on GitHub: link to page
 *  
 *  	Before running Q-VAT the following plugins should be installed: 
 *  		-  BioVoxxel Toolbox. Installation: https://imagej.net/plugins/biovoxxel-toolbox
 *  		-  Read and Write Excell. Installation: https://imagej.net/plugins/read-and-write-excel
 *  		-  3D ImageJ Suite. Installation: https://imagej.net/plugins/3d-imagej-suite/
 *  	 - Download and unzip the Prune_Skeleton_Ends.bsh (https://gist.github.com/lacan/0a12113b1497db86d7df3ef102efd34d) file and copy it into the FIji plugins folder (e.g. \fiji-win64\Fiji.app\plugins). Then, restart ImageJ. 
 *  
 * Author: Bram Callewaert
 * Contact: bram.callewaert@kuleuven.be
 * 
 * Copyright 2022 Bram Callewaert, Leuven Univeristy, Departement of Cardiovascular Sciences, Center for Molecular and Vascular Biology (CMVB)
 * This script is is licensed under the GNU general Pubic License v3.0? 
 * 
 * if using Q-VAT please cite: link to paper
 */
  
#@ String (visibility=MESSAGE, value="<font size=20><b> Q-VAT: Quantitative Vascular Analysis Tool </b></font>", required=false)msg
#@ File (label="Select a directory", style="directory") inputDir1
#@ Float (label="Calibration (µm/px)", min=0, value= 0.642776, persist=false, style="format:#.######") calibration
#@ Float (label="<html> Vascular compartement <br/> separation threshold (µm) <html>", min=0, value=10, persist=false, style="format:#.######") ThresholdDiameter
#@ Float (label="close labels radius (µm)", min=0, value=3, persist=false, style="format:#.######") FillHolesThreshold
#@ Float (label="Prune ends threshold (µm)", min=0, value=5, persist=false, style="format:#.######") PruneEndsThreshold
#@ String (choices={"Yes", "No"}, style="radioButtonHorizontal") Save_Output_Figures
#@ String (visibility=MESSAGE, value="<font size=5> Inculde additional channels with co-localized staining: </font>", required=false) msg2
#@ String (choices={"None","Channel 2", "Channel 2 & 3"}, style="listbox") colocalization_channels


setBatchMode( true );
// Make a list of the subfolders inside the input directory
inputDir = inputDir1 + "\\"
subFolderList = getFileList(inputDir);

Threshold = ThresholdDiameter/calibration //convert threshold from µm to pixels
Threshold_Fillholes = FillHolesThreshold/calibration //set max radius for the Close labels tool
voxel_size = calibration*calibration; //voxel area (µm^2)
prune_threshold = PruneEndsThreshold/calibration; // convert from µm to pixels 
//loop over all the folders (i.e. subjects) within the selected input directory
for (k=0; k<subFolderList.length;k++){
	
	//get a list of all folders in the sub-directory (i.e. subjects)
	subdir= subFolderList[k];
	subdirList = getFileList(inputDir + subdir);
	
	//First folder in the sub-directory contains binary vascular masks (first channel)
	srcDir = inputDir + subdir + subdirList[0];
	fileList = getFileList(srcDir); // filelist of all vascular mask tiles
	

	if (colocalization_channels == "None") {
		//second folder in the sub-directory contains binary tissue masks
		ROIsrcDir = inputDir+subdir+subdirList[1];
		filenumber = newArray(fileList.length); //get the number of files in the folder (i.e. number of tiles)
	}
	if (colocalization_channels == "Channel 2") {
		//second folder in the sub-directory contains the second channel of the staining
		srcDir_two = inputDir+subdir+subdirList[1];
		fileList_channel2 = getFileList(srcDir_two); 
		//third folder in the sub-directory contains binary tissue masks
		ROIsrcDir = inputDir+subdir+subdirList[2];		
	}
	
	if (colocalization_channels == "Channel 2 & 3") {
		//second folder in the sub-directory contains the second channel of the staining
		srcDir_two = inputDir+subdir+subdirList[1];
		fileList_channel2 = getFileList(srcDir_two); 
		srcDir_three = inputDir+subdir+subdirList[2];
		fileList_channel3 = getFileList(srcDir_three); 
		//third folder in the sub-directory contains binary tissue masks
		ROIsrcDir = inputDir+subdir+subdirList[3];		
	}
	

	//Create empty arrays for ouptut maps (each channel)
	vascular_density_chan1 = newArray(fileList.length);
	mean_Diameter_chan1 = newArray(fileList.length);
	vessel_length_density_chan1 = newArray(fileList.length);
	branch_density_chan1 = newArray(fileList.length);
	cluster_density_chan1 = newArray(fileList.length);
	branch_point_density_chan1 = newArray(fileList.length);
	endpoint_density_chan1 = newArray(fileList.length);
	
	diameter_above_chan1 = newArray(fileList.length);
	vascular_dens_above_chan1 =  newArray(fileList.length);
	vessellength_dens_above_chan1 =  newArray(fileList.length);
	branch_dens_above_chan1 =  newArray(fileList.length);
	diameter_below_chan1 =  newArray(fileList.length);
	vascular_dens_below_chan1 =  newArray(fileList.length);
	vessellength_dens_below_chan1 =  newArray(fileList.length);
	branch_dens_below_chan1 =  newArray(fileList.length);
	
	if (colocalization_channels == "Channel 2" || colocalization_channels == "Channel 2 & 3"){
		//Create empty arrays for ouptut maps (each channel)
		vascular_density_chan2 = newArray(fileList.length);
		mean_Diameter_chan2 = newArray(fileList.length);
		vessel_length_density_chan2 = newArray(fileList.length);
		branch_density_chan2 = newArray(fileList.length);
		cluster_density_chan2 = newArray(fileList.length);
		branch_point_density_chan2 = newArray(fileList.length);
		endpoint_density_chan2 = newArray(fileList.length);
		
		diameter_above_chan2 = newArray(fileList.length);
		vascular_dens_above_chan2 =  newArray(fileList.length);
		vessellength_dens_above_chan2 =  newArray(fileList.length);
		branch_dens_above_chan2 =  newArray(fileList.length);
		diameter_below_chan2 =  newArray(fileList.length);
		vascular_dens_below_chan2 =  newArray(fileList.length);
		vessellength_dens_below_chan2 =  newArray(fileList.length);
		branch_dens_below_chan2 =  newArray(fileList.length);
		
	}
	
	if (colocalization_channels == "Channel 2 & 3") {
		//Create empty arrays for ouptut maps (each channel)
		vascular_density_chan3 = newArray(fileList.length);
		mean_Diameter_chan3 = newArray(fileList.length);
		vessel_length_density_chan3 = newArray(fileList.length);
		branch_density_chan3 = newArray(fileList.length);
		cluster_density_chan3 = newArray(fileList.length);
		branch_point_density_chan3 = newArray(fileList.length);
		endpoint_density_chan3 = newArray(fileList.length);
		
		diameter_above_chan3 = newArray(fileList.length);
		vascular_dens_above_chan3 =  newArray(fileList.length);
		vessellength_dens_above_chan3 =  newArray(fileList.length);
		branch_dens_above_chan3 =  newArray(fileList.length);
		diameter_below_chan3 =  newArray(fileList.length);
		vascular_dens_below_chan3 =  newArray(fileList.length);
		vessellength_dens_below_chan3 =  newArray(fileList.length);
		branch_dens_below_chan3 =  newArray(fileList.length);
	}
	
	outputDir1 = ROIsrcDir + "masked_file"+ "\\" + "channel1";
	outputDir2 = ROIsrcDir + "masked_file"+ "\\" + "channel2";
	outputDir3 = ROIsrcDir + "masked_file"+ "\\" + "channel3";
			
	//remove output files if they already exist (to avoid adding lines to an exsisting excel file)
	if (File.exists(outputDir1 + "\\")){
		list = getFileList(outputDir1 + "\\");
		for (j=0; j<list.length; j++){					
			ok=File.delete(outputDir1 + "\\" + list[j]);
		}
		ok=File.delete(outputDir1 + "\\");
	}
	if (File.exists(outputDir2 + "\\")){
		list = getFileList(outputDir2 + "\\");
		for (j=0; j<list.length; j++){					
			ok=File.delete(outputDir2 + "\\" + list[j]);
		}
		ok=File.delete(outputDir2 + "\\");
	}
	if (File.exists(outputDir3 + "\\")){
		list = getFileList(outputDir3 + "\\");
		for (j=0; j<list.length; j++){					
			ok=File.delete(outputDir3 + "\\" + list[j]);
		}
		ok=File.delete(outputDir3 + "\\");
	}	
	
	if (File.exists(ROIsrcDir + "masked_file" + "\\")){
		ok=File.delete(ROIsrcDir + "masked_file" + "\\");
		ROIfileList = getFileList(ROIsrcDir); // list of al	tissue mask tiles
	}				
	else{
		ROIfileList = getFileList(ROIsrcDir); // list of al	tissue mask tiles
	}
	File.makeDirectory(ROIsrcDir + "masked_file"); //make a subdirectory in the MASK folder
	File.makeDirectory(outputDir1); //make a subdirectory in the MASK folder
		
	if (colocalization_channels == "Channel 2") {
			File.makeDirectory(outputDir2); //make a subdirectory in the MASK folder
	}
	if (colocalization_channels == "Channel 2 & 3") {
			File.makeDirectory(outputDir2); //make a subdirectory in the MASK folder
			File.makeDirectory(outputDir3); //make a subdirectory in the MASK folder
	}
		

// check whether the length of fileList and ROIfileList are the same
if (fileList.length == ROIfileList.length) {

	filename = File.getParent(srcDir); //get the name of the directory
	name = File.getName(filename);

	//loop over all tiles: 
	for ( i = 0; i < fileList.length; i++ ) {
			if ( endsWith( fileList[i], ".tif" )) { //only loop over .tif files 
				
				
				open (ROIsrcDir + ROIfileList[i] ); //open one ROI tile image
				Stack.setXUnit("pixel");
				Stack.setYUnit("pixel");
				run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //set unit to 1 pixel 
				rename("ROI");
				run("8-bit"); //convert to 8bit (needed for analyze particles)
				
				//Tissue mask or ROI mask: 
				width = getWidth; //number of colums of Tile image
				height = getHeight; //number of rows of Tile image
				Values = newArray(width*height); // create 1D array with  voxel values
				total_tile_area = width*height;

				//loop over all voxels to get the values
				mask_count= 0; // number of voxels that are part of the mask ! 
				background_count=0;// number of voxels that are part of the mask ! 
				for (j=0; j<height; j++) {
		        	for (a=0; a<width; a++) {
			            v = getPixel(a, j);

						Values[a + (width)*j] = v;
					if (v == 255){ // all voxels that are equal to 255 are part of the tissue mask 
						mask_count++;
						}
					else{
						background_count++;
						}
		        	}
		     	}	     	
		     	
		     	Array.getStatistics(Values, min, max, mean, stdDev);  //get statistics of the Values (min, max, mean, stdev)
				
				if (min==max){
					if (min == 0){mask_area = 0; masked_voxel_area =0;} //if min and max are zero --> the percentage of the voxel that is mask = 0; masked_voxel_area = area of the voxel that is masked
					if (min == 255){mask_area = 100; masked_voxel_area = total_tile_area;} //if min and max are 255 --> the percentage of the voxel that is mask = 100%
				}
				else{
					masked_voxel_area = mask_count; //area of the voxel that is masked (pixels)
				}
				
				if(masked_voxel_area == 0){
					close("ROI"); 
				}

				if (masked_voxel_area > 0){
					
					Analyze_Tile(srcDir, fileList[i], "None", "None", outputDir1, masked_voxel_area, Threshold_Fillholes, Save_Output_Figures,prune_threshold,calibration, voxel_size );
					selectWindow("Results"); // there is no results table if output figure is empty! 
					vasculardens_chan1 = Table.getColumn("Vascular density (%)");
					if (vasculardens_chan1[0] == -1){
						close("Results");
					}
					else{
						selectWindow("Results");
						diameter_chan1 = Table.getColumn("Mean vessel diameter (µm)");
						vasculardens_chan1 = Table.getColumn("Vascular density (%)");
						vessellengthdens_chan1 = Table.getColumn("Vessel length density (mm/mm²)");
						branchdens_chan1 = Table.getColumn("Branch density(#/mm²)");
						clusterdens_chan1 = Table.getColumn("Cluster density (#/mm²)"); 
						branchpointdens_chan1 = Table.getColumn("Branchpoint density (#/mm²)"); 
						endpointdensdens_chan1 = Table.getColumn("Endpoint density (#/mm²)");
						 
						diameterabove_chan1 = Table.getColumn("Mean vessel diameter above threshold (µm)"); 
						vasculardensabove_chan1 = Table.getColumn("Vascular density above threshold (%)");
						vessellengthdensabove_chan1 = Table.getColumn("Vessel length density above threshold (mm/mm²)");
						branchdensabove_chan1 = Table.getColumn("Branch density above threshold (#/mm²)");
						diameterbelow_chan1 = Table.getColumn("Mean vessel diameter below threshold (µm)"); 
						vasculardensbelow_chan1 = Table.getColumn("Vascular density below threshold (%)");
						vessellengthdensbelow_chan1 = Table.getColumn("Vessel length density below threshold (mm/mm²)");
						branchdensbelow_chan1 = Table.getColumn("Branch density below threshold (#/mm²)");						
						close("Results");
						
						vascular_density_chan1[i] = vasculardens_chan1[0];
						mean_Diameter_chan1[i] = diameter_chan1[0];
						vessel_length_density_chan1[i] = vessellengthdens_chan1[0];
						branch_density_chan1[i] = branchdens_chan1[0];
						cluster_density_chan1[i] = clusterdens_chan1[0];
						branch_point_density_chan1[i] = branchpointdens_chan1[0];
						endpoint_density_chan1[i] = endpointdensdens_chan1[0];
							
						diameter_above_chan1[i] = diameterabove_chan1[0]; 
						vascular_dens_above_chan1[i] = vasculardensabove_chan1[0]; 
						vessellength_dens_above_chan1[i] = vessellengthdensabove_chan1[0]; 
						branch_dens_above_chan1[i] = branchdensabove_chan1[0];
						diameter_below_chan1[i] = diameterbelow_chan1[0]; 
						vascular_dens_below_chan1[i] = vasculardensbelow_chan1[0]; 
						vessellength_dens_below_chan1[i] = vessellengthdensbelow_chan1[0]; 
						branch_dens_below_chan1[i] =branchdensbelow_chan1[0];
	
					}			
												
						
					if (colocalization_channels == "Channel 2" || colocalization_channels == "Channel 2 & 3") {						
						if (fileList.length == fileList_channel2.length){
							Analyze_Tile(srcDir, fileList[i], srcDir_two, fileList_channel2[i],outputDir2, masked_voxel_area, Threshold_Fillholes, Save_Output_Figures,prune_threshold,calibration, voxel_size);
							
							selectWindow("Results"); // there is no results table if output figure is empty! 
							vasculardens_chan2 = Table.getColumn("Vascular density (%)");
							if (vasculardens_chan2[0] == -1){
								close("Results");
							}
							else{
								selectWindow("Results");
								diameter_chan2 = Table.getColumn("Mean vessel diameter (µm)");
								vasculardens_chan2 = Table.getColumn("Vascular density (%)");
								vessellengthdens_chan2 = Table.getColumn("Vessel length density (mm/mm²)");
								branchdens_chan2 = Table.getColumn("Branch density(#/mm²)");
								clusterdens_chan2 = Table.getColumn("Cluster density (#/mm²)"); 
								branchpointdens_chan2 = Table.getColumn("Branchpoint density (#/mm²)"); 
								endpointdensdens_chan2 = Table.getColumn("Endpoint density (#/mm²)");
								
								diameterabove_chan2 = Table.getColumn("Mean vessel diameter above threshold (µm)"); 
								vasculardensabove_chan2 = Table.getColumn("Vascular density above threshold (%)");
								vessellengthdensabove_chan2 = Table.getColumn("Vessel length density above threshold (mm/mm²)");
								branchdensabove_chan2 = Table.getColumn("Branch density above threshold (#/mm²)");
								diameterbelow_chan2 = Table.getColumn("Mean vessel diameter below threshold (µm)"); 
								vasculardensbelow_chan2 = Table.getColumn("Vascular density below threshold (%)");
								vessellengthdensbelow_chan2 = Table.getColumn("Vessel length density below threshold (mm/mm²)");
								branchdensbelow_chan2 = Table.getColumn("Branch density below threshold (#/mm²)");			
								close("Results");

								vascular_density_chan2[i] = vasculardens_chan2[0];
								mean_Diameter_chan2[i] = diameter_chan2[0];
								vessel_length_density_chan2[i] = vessellengthdens_chan2[0];
								branch_density_chan2[i] = branchdens_chan2[0];
								cluster_density_chan2[i] = clusterdens_chan2[0];
								branch_point_density_chan2[i] = branchpointdens_chan2[0];
								endpoint_density_chan2[i] = endpointdensdens_chan2[0];
									
								diameter_above_chan2[i] = diameterabove_chan2[0]; 
								vascular_dens_above_chan2[i] = vasculardensabove_chan2[0]; 
								vessellength_dens_above_chan2[i] = vessellengthdensabove_chan2[0]; 
								branch_dens_above_chan2[i] = branchdensabove_chan2[0];
								diameter_below_chan2[i] = diameterbelow_chan2[0]; 
								vascular_dens_below_chan2[i] = vasculardensbelow_chan2[0]; 
								vessellength_dens_below_chan2[i] = vessellengthdensbelow_chan2[0]; 
								branch_dens_below_chan2[i] =branchdensbelow_chan2[0];	
							
							
								filename = newArray(1);	
								vasculardensity_ratio = newArray(1);			
								vessellengthdensity_ratio = newArray(1);
								branchdensity_ratio = newArray(1);
								clusterdensity_ratio = newArray(1);
								branchpointdensty_ratio = newArray(1);
								endpointdensity_ratio = newArray(1);
								vasculardensityabove_ratio = newArray(1);
								vessellengthdensityabove_ratio = newArray(1);
								branchdensityabove_ratio = newArray(1);
								vasculardensitybelow_ratio = newArray(1);
								vessellengthdensitybelow_ratio = newArray(1);
								branchdensitybelow_ratio =newArray(1);
								
								filename[0] = fileList[i];	
								vasculardensity_ratio[0] = (vasculardens_chan2[0]/vasculardens_chan1[0])*100;
								vessellengthdensity_ratio[0]  = (vessellengthdens_chan2[0]/vessellengthdens_chan1[0])*100;
								branchdensity_ratio[0]  = (branchdens_chan2[0]/branchdens_chan1[0])*100;
								clusterdensity_ratio[0]  = (clusterdens_chan2[0]/clusterdens_chan1[0])*100;
								branchpointdensty_ratio[0]  = (branchpointdens_chan2[0]/branchpointdens_chan1[0])*100;
								endpointdensity_ratio[0]  = (endpointdensdens_chan2[0]/endpointdensdens_chan1[0])*100;
								vasculardensityabove_ratio[0]  = (vasculardensabove_chan2[0]/vasculardensabove_chan1[0])*100;
								vessellengthdensityabove_ratio[0]  = (vessellengthdensabove_chan2[0]/vessellengthdensabove_chan1[0])*100;
								branchdensityabove_ratio[0]  = (branchdensabove_chan2[0]/branchdensabove_chan1[0])*100;
								vasculardensitybelow_ratio[0]  = (vasculardensbelow_chan2[0]/vasculardensbelow_chan1[0])*100;
								vessellengthdensitybelow_ratio[0]  = (vessellengthdensbelow_chan2[0]/vessellengthdensbelow_chan1[0])*100;
								branchdensitybelow_ratio[0]  = (branchdensbelow_chan2[0]/branchdensbelow_chan1[0])*100;
								
								Table.create("Results");	
								
								Table.setColumn("Label", filename);
								Table.setColumn("Vascular density ratio (chan2/chan1)", vasculardensity_ratio)
								Table.setColumn("Vessel length density ratio (chan2/chan1)", vessellengthdensity_ratio)
								Table.setColumn("Branch density ratio (chan2/chan1)", branchdensity_ratio)
								Table.setColumn("Cluster density ratio (chan2/chan1)", clusterdensity_ratio)
								Table.setColumn("Branchpoint density ratio (chan2/chan1)", branchpointdensty_ratio)
								Table.setColumn("Endpoint density ratio (chan2/chan1)", endpointdensity_ratio)
								Table.setColumn("Vascular density ratio above threshold (chan2/chan1)", vasculardensityabove_ratio)
								Table.setColumn("Vessel length density ratio above threshold (chan2/chan1)", vessellengthdensityabove_ratio)
								Table.setColumn("Brach density ratio (chan2/chan1)", branchdensityabove_ratio)
								Table.setColumn("Vascular density ratio below threshold (chan2/chan1)", vasculardensitybelow_ratio)
								Table.setColumn("Vessel length density ratio below threshold (chan2/chan1)", vessellengthdensitybelow_ratio)
								Table.setColumn("Brach density ratio below threshold (chan2/chan1)", branchdensitybelow_ratio)
								
								
								run("Read and Write Excel", "file=["+ outputDir2 + "//" + name + "_vascular_density.xlsx], stack_results, sheet=co-localization_Chan2/Chan1"); //save output in excell file in the folder of the ROI						
								close("Results");
							}
						}
					}
					if (colocalization_channels == "Channel 2 & 3") {							
							Analyze_Tile(srcDir, fileList[i], srcDir_three, fileList_channel3[i], outputDir3, masked_voxel_area, Threshold_Fillholes, Save_Output_Figures,prune_threshold,calibration, voxel_size );		 
							
							selectWindow("Results"); // there is no results table if output figure is empty! 
							vasculardens_chan3 = Table.getColumn("Vascular density (%)");
							if (vasculardens_chan3[0] == -1){
								close("Results");
							}
							else{
								selectWindow("Results");
								diameter_chan3 = Table.getColumn("Mean vessel diameter (µm)");
								vasculardens_chan3 = Table.getColumn("Vascular density (%)");
								vessellengthdens_chan3 = Table.getColumn("Vessel length density (mm/mm²)");
								branchdens_chan3 = Table.getColumn("Branch density(#/mm²)");
								clusterdens_chan3 = Table.getColumn("Cluster density (#/mm²)"); 
								branchpointdens_chan3 = Table.getColumn("Branchpoint density (#/mm²)"); 
								endpointdensdens_chan3 = Table.getColumn("Endpoint density (#/mm²)");
								
								diameterabove_chan3 = Table.getColumn("Mean vessel diameter above treshold (µm)"); 
								vasculardensabove_chan3 = Table.getColumn("Vascular density above threshold (%)");
								vessellengthdensabove_chan3 = Table.getColumn("Vessel length density above threshold (mm/mm²)");
								branchdensabove_chan3 = Table.getColumn("Branch density above threshold (#/mm²)");
								diameterbelow_chan3 = Table.getColumn("Mean vessel diameter below threshold (µm)"); 
								vasculardensbelow_chan3 = Table.getColumn("Vascular density below threshold (%)");
								vessellengthdensbelow_chan3 = Table.getColumn("Vessel length density below threshold (mm/mm²)");
								branchdensbelow_chan3 = Table.getColumn("Branch density below threshold (#/mm²)");												
								close("Results");
								
								vascular_density_chan3[i] = vasculardens_chan3[0];
								mean_Diameter_chan3[i] = diameter_chan3[0];
								vessel_length_density_chan3[i] = vessellengthdens_chan3[0];
								branch_density_chan3[i] = branchdens_chan3[0];
								cluster_density_chan3[i] = clusterdens_chan3[0];
								branch_point_density_chan3[i] = branchpointdens_chan3[0];
								endpoint_density_chan3[i] = endpointdensdens_chan3[0];
									
								diameter_above_chan3[i] = diameterabove_chan3[0]; 
								vascular_dens_above_chan3[i] = vasculardensabove_chan3[0]; 
								vessellength_dens_above_chan3[i] = vessellengthdensabove_chan3[0]; 
								branch_dens_above_chan3[i] = branchdensabove_chan3[0];
								diameter_below_chan3[i] = diameterbelow_chan3[0]; 
								vascular_dens_below_chan3[i] = vasculardensbelow_chan3[0]; 
								vessellength_dens_below_chan3[i] = vessellengthdensbelow_chan3[0]; 
								branch_dens_below_chan3[i] =branchdensbelow_chan3[0];
								
								
								filename = newArray(1);	
								vasculardensity_ratio = newArray(1);			
								vessellengthdensity_ratio = newArray(1);
								branchdensity_ratio = newArray(1);
								clusterdensity_ratio = newArray(1);
								branchpointdensty_ratio = newArray(1);
								endpointdensity_ratio = newArray(1);
								vasculardensityabove_ratio = newArray(1);
								vessellengthdensityabove_ratio = newArray(1);
								branchdensityabove_ratio = newArray(1);
								vasculardensitybelow_ratio = newArray(1);
								vessellengthdensitybelow_ratio = newArray(1);
								branchdensitybelow_ratio =newArray(1);
								
								filename[0] = fileList[i];	
								vasculardensity_ratio[0] = (vasculardens_chan3[0]/vasculardens_chan1[0])*100;
								vessellengthdensity_ratio[0]  = (vessellengthdens_chan3[0]/vessellengthdens_chan1[0])*100;
								branchdensity_ratio[0]  = (branchdens_chan3[0]/branchdens_chan1[0])*100;
								clusterdensity_ratio[0]  = (clusterdens_chan3[0]/clusterdens_chan1[0])*100;
								branchpointdensty_ratio[0]  = (branchpointdens_chan3[0]/branchpointdens_chan1[0])*100;
								endpointdensity_ratio[0]  = (endpointdensdens_chan3[0]/endpointdensdens_chan1[0])*100;
								vasculardensityabove_ratio[0]  = (vasculardensabove_chan3[0]/vasculardensabove_chan1[0])*100;
								vessellengthdensityabove_ratio[0]  = (vessellengthdensabove_chan3[0]/vessellengthdensabove_chan1[0])*100;
								branchdensityabove_ratio[0]  = (branchdensabove_chan3[0]/branchdensabove_chan1[0])*100;
								vasculardensitybelow_ratio[0]  = (vasculardensbelow_chan3[0]/vasculardensbelow_chan1[0])*100;
								vessellengthdensitybelow_ratio[0]  = (vessellengthdensbelow_chan3[0]/vessellengthdensbelow_chan1[0])*100;
								branchdensitybelow_ratio[0]  = (branchdensbelow_chan3[0]/branchdensbelow_chan1[0])*100;
								
								Table.create("Results");	
								
								Table.setColumn("Label", filename);
								Table.setColumn("Vascular density ratio (chan3/chan1)", vasculardensity_ratio)
								Table.setColumn("Vessel length density ratio (chan3/chan1)", vessellengthdensity_ratio)
								Table.setColumn("Branch density ratio (chan3/chan1)", branchdensity_ratio)
								Table.setColumn("Cluster density ratio (chan3/chan1)", clusterdensity_ratio)
								Table.setColumn("Branchpoint density ratio (chan3/chan1)", branchpointdensty_ratio)
								Table.setColumn("Endpoint density ratio (chan3/chan1)", endpointdensity_ratio)
								Table.setColumn("Vascular density ratio above threshold (chan3/chan1)", vasculardensityabove_ratio)
								Table.setColumn("Vessel length density ratio above threshold (chan3/chan1)", vessellengthdensityabove_ratio)
								Table.setColumn("Brach density ratio (chan3/chan1)", branchdensityabove_ratio)
								Table.setColumn("Vascular density ratio below threshold (chan3/chan1)", vasculardensitybelow_ratio)
								Table.setColumn("Vessel length density ratio below threshold (chan3/chan1)", vessellengthdensitybelow_ratio)
								Table.setColumn("Brach density ratio below threshold (chan3/chan1)", branchdensitybelow_ratio)
								
								run("Read and Write Excel", "file=["+ outputDir3 + "//" + name + "_vascular_density.xlsx], stack_results, sheet=co-localization_Chan3/Chan1"); //save output in excell file in the folder of the ROI						
								close("Results"); 
							
								filename = newArray(1);	
								vasculardensity_ratio = newArray(1);			
								vessellengthdensity_ratio = newArray(1);
								branchdensity_ratio = newArray(1);
								clusterdensity_ratio = newArray(1);
								branchpointdensty_ratio = newArray(1);
								endpointdensity_ratio = newArray(1);
								vasculardensityabove_ratio = newArray(1);
								vessellengthdensityabove_ratio = newArray(1);
								branchdensityabove_ratio = newArray(1);
								vasculardensitybelow_ratio = newArray(1);
								vessellengthdensitybelow_ratio = newArray(1);
								branchdensitybelow_ratio =newArray(1);
								
								filename[0] = fileList[i];	
								vasculardensity_ratio[0] = (vasculardens_chan3[0]/vasculardens_chan2[0])*100;
								vessellengthdensity_ratio[0]  = (vessellengthdens_chan3[0]/vessellengthdens_chan2[0])*100;
								branchdensity_ratio[0]  = (branchdens_chan3[0]/branchdens_chan2[0])*100;
								clusterdensity_ratio[0]  = (clusterdens_chan3[0]/clusterdens_chan2[0])*100;
								branchpointdensty_ratio[0]  = (branchpointdens_chan3[0]/branchpointdens_chan2[0])*100;
								endpointdensity_ratio[0]  = (endpointdensdens_chan3[0]/endpointdensdens_chan2[0])*100;
								vasculardensityabove_ratio[0]  = (vasculardensabove_chan3[0]/vasculardensabove_chan2[0])*100;
								vessellengthdensityabove_ratio[0]  = (vessellengthdensabove_chan3[0]/vessellengthdensabove_chan2[0])*100;
								branchdensityabove_ratio[0]  = (branchdensabove_chan3[0]/branchdensabove_chan2[0])*100;
								vasculardensitybelow_ratio[0]  = (vasculardensbelow_chan3[0]/vasculardensbelow_chan2[0])*100;
								vessellengthdensitybelow_ratio[0]  = (vessellengthdensbelow_chan3[0]/vessellengthdensbelow_chan2[0])*100;
								branchdensitybelow_ratio[0]  = (branchdensbelow_chan3[0]/branchdensbelow_chan2[0])*100;
								
								Table.create("Results");	
								
								Table.setColumn("Label", filename);
								Table.setColumn("Vascular density ratio (chan3/chan2)", vasculardensity_ratio)
								Table.setColumn("Vessel length density ratio (chan3/chan2)", vessellengthdensity_ratio)
								Table.setColumn("Branch density ratio (chan3/chan2)", branchdensity_ratio)
								Table.setColumn("Cluster density ratio (chan3/chan2)", clusterdensity_ratio)
								Table.setColumn("Branchpoint density ratio (chan3/chan2)", branchpointdensty_ratio)
								Table.setColumn("Endpoint density ratio (chan3/chan2)", endpointdensity_ratio)
								Table.setColumn("Vascular density ratio above threshold (chan3/chan2)", vasculardensityabove_ratio)
								Table.setColumn("Vessel length density ratio above threshold (chan3/chan2)", vessellengthdensityabove_ratio)
								Table.setColumn("Brach density ratio (chan3/chan2)", branchdensityabove_ratio)
								Table.setColumn("Vascular density ratio below threshold (chan3/chan2)", vasculardensitybelow_ratio)
								Table.setColumn("Vessel length density ratio below threshold (chan3/chan2)", vessellengthdensitybelow_ratio)
								Table.setColumn("Brach density ratio below threshold (chan3/chan2)", branchdensitybelow_ratio)
								
								run("Read and Write Excel", "file=["+ outputDir3 + "//" + name + "_vascular_density.xlsx], stack_results, sheet=co-localization_Chan3/Chan2 "); //save output in excell file in the folder of the ROI						
								close("Results");
							}
						}

					close ("ROI");
				}
		
				filename = replace(fileList[i], ".tif", ""); //remove the ".tif extension"
				underscore_index = lastIndexOf(filename, "_");
				filenameColumns = substring(filename, 0, underscore_index);
				underscore_index2 = lastIndexOf(filenameColumns, "_");
				Rownumber = substring(filename,underscore_index +1, underscore_index +4 );
				Columnnumber = substring(filenameColumns, underscore_index2+1, underscore_index2+4 );
						
				//Remove the zero's fromt he row and column numbers (e.g. 001 --> 1 or 010 --> 10) [First tile should start at 001_001]
				for ( indx = 0; indx < Rownumber.length; indx++ ) {
					Row_zero_index = indexOf(Rownumber, "0");
						if (Row_zero_index==0){
							Rownumber = substring(Rownumber,Row_zero_index+1, Rownumber.length);
						}
				}
				
				for ( indxx = 0; indxx < Columnnumber.length; indxx++ ) {
					column_zero_index = indexOf(Columnnumber, "0");
						if (column_zero_index==0){
							Columnnumber = substring(Columnnumber,column_zero_index+1, Columnnumber.length);
						}
				}

				Columnnumber = parseInt(Columnnumber);
				Rownumber = parseInt(Rownumber);

				
			if (Columnnumber*Rownumber == fileList.length){

				
				
				if (Save_Output_Figures == "Yes") {
						
							makefigure(vascular_density_chan1,"vascular_density_chan1", 0, 35, "physics", outputDir1,Columnnumber, Rownumber);	
							makefigure(mean_Diameter_chan1, "mean_Diameter_chan1", 0, 30, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(vessel_length_density_chan1, "vessel_length_density_chan1", 0, 50, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(branch_density_chan1, "branch_density_chan1", 0, 2000, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(cluster_density_chan1, "cluster_density_chan1", 0, 1000, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(branch_point_density_chan1, "branch_point_density_chan1", 0, 500, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(endpoint_density_chan1, "endpoint_density_chan1", 0, 2000, "physics", outputDir1,Columnnumber, Rownumber);
							
							makefigure(vascular_dens_above_chan1,"vascular_dens_above_chan1", 0, 35, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(diameter_above_chan1, "diameter_above_chan1", 0, 25, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(vessellength_dens_above_chan1, "vessellength_dens_above_chan1", 0, 50, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(branch_dens_above_chan1, "branch_dens_above_chan1", 0, 2000, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(vascular_dens_below_chan1, "vascular_dens_below_chan1", 0, 35, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(diameter_below_chan1, "diameter_below_chan1", 0, 25, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(vessellength_dens_below_chan1, "vessellength_dens_below_chan1", 0, 50, "physics", outputDir1,Columnnumber, Rownumber);
							makefigure(branch_dens_below_chan1, "branch_dens_below_chan1", 0, 2000, "physics", outputDir1,Columnnumber, Rownumber);
																				

							if(colocalization_channels == "Channel 2" || colocalization_channels == "Channel 2 & 3") {
														
							makefigure(vascular_density_chan2,"vascular_density_chan2", 0, 35, "physics", outputDir2,Columnnumber, Rownumber);	
							makefigure(mean_Diameter_chan2, "mean_Diameter_chan2", 0, 30, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(vessel_length_density_chan2, "vessel_length_density_chan2", 0, 50, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(branch_density_chan2, "branch_density_chan2", 0, 1000, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(cluster_density_chan2, "cluster_density_chan2", 0, 1000, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(branch_point_density_chan2, "branch_point_density_chan2", 0, 500, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(endpoint_density_chan2, "endpoint_density_chan2", 0, 2000, "physics", outputDir2,Columnnumber, Rownumber);
							
							makefigure(vascular_dens_above_chan2,"vascular_dens_above_chan2", 0, 35, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(diameter_above_chan2, "diameter_above_chan2", 0, 25, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(vessellength_dens_above_chan2, "vessellength_dens_above_chan2", 0, 50, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(branch_dens_above_chan2, "branch_dens_above_chan2", 0, 1000, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(vascular_dens_below_chan2, "vascular_dens_below_chan2", 0, 35, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(diameter_below_chan2, "diameter_below_chan2", 0, 25, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(vessellength_dens_below_chan2, "vessellength_dens_below_chan2", 0, 50, "physics", outputDir2,Columnnumber, Rownumber);
							makefigure(branch_dens_below_chan2, "branch_dens_below_chan2", 0, 2000, "physics", outputDir2,Columnnumber, Rownumber);
							}
							
							if(colocalization_channels == "Channel 2 & 3") {
												
							makefigure(vascular_density_chan3,"vascular_density_chan3", 0, 35, "physics", outputDir3,Columnnumber, Rownumber);	
							makefigure(mean_Diameter_chan3, "mean_Diameter_chan3", 0, 30, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(vessel_length_density_chan3, "vessel_length_density_chan3", 0, 50, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(branch_density_chan3, "branch_density_chan3", 0, 1000, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(cluster_density_chan3, "cluster_density_chan3", 0, 1000, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(branch_point_density_chan3, "branch_point_density_chan3", 0, 500, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(endpoint_density_chan3, "endpoint_density_chan3", 0, 2000, "physics", outputDir3,Columnnumber, Rownumber);
							
							makefigure(vascular_dens_above_chan3,"vascular_dens_above_chan3", 0, 35, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(diameter_above_chan3, "diameter_above_chan3", 0, 25, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(vessellength_dens_above_chan3, "vessellength_dens_above_chan3", 0, 50, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(branch_dens_above_chan3, "branch_dens_above_chan3", 0, 1000, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(vascular_dens_below_chan3, "vascular_dens_below_chan3", 0, 35, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(diameter_below_chan3, "diameter_below_chan3", 0, 25, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(vessellength_dens_below_chan3, "vessellength_dens_below_chan3", 0, 50, "physics", outputDir3,Columnnumber, Rownumber);
							makefigure(branch_dens_below_chan3, "branch_dens_below_chan3", 0, 2000, "physics", outputDir3,Columnnumber, Rownumber);
								
							}
				}
				
			}				
			close("IMG");
			}
		}

	}
		
}
close("Log"); 
setBatchMode(false);
exit();


function Analyze_Tile(Dir, Chan1List, chanDir, ChanList, savedir, masked_voxel_area, Threshold_Fillholes, Save_Output_Figures, prune_threshold, calibration, voxel_size ){					

	open(Dir + Chan1List); //open one tile image
	Stack.setXUnit("pixel");
	Stack.setYUnit("pixel");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //set unit to 1 pixel 
	rename("IMG");
	
	run("8-bit"); //convert to 8bit (needed for analyze particles)
	setOption("BlackBackground", false); 	//set unit to 1 pixel 
	run("Convert to Mask"); //convert to mask

	imageCalculator("Multiply create", "ROI" ,"IMG"); //Multiply TIssue mask and vascular mask
	
	close("IMG");
	selectWindow("Result of ROI");
	
	if (chanDir == "None"){}
	else {
		open(chanDir + ChanList ); //open one tile image
		Stack.setXUnit("pixel");
		Stack.setYUnit("pixel");
		run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1"); //set unit to 1 pixel 
		rename("IMG");
		
		run("8-bit"); //convert to 8bit (needed for analyze particles)
		setOption("BlackBackground", false); 	//set unit to 1 pixel 
		run("Convert to Mask"); //convert to mask

		imageCalculator("Multiply create", "Result of ROI" ,"IMG"); //Multiply TIssue mask and vascular mask
		
		close("Result of ROI");
		selectWindow("Result of Result of ROI");
		rename("Result of ROI");
		close("IMG");
		
		}
	
	
	//create label image using 3D Simple segmentation (3D ImageJ Suite)
	selectWindow("Result of ROI");
	run("3D Simple Segmentation", "low_threshold=128 min_size=0 max_size=-1"); 
	close("Bin"); 
	//Fill the holes in the vasculature mask using 3D Binary Close labels (3D Imagej Suite)
	run("3D Binary Close Labels", "radiusxy=Threshold_Fillholes radiusz=0 operation=Close"); 
	close("Seg"); 
	close("Result of ROI");
	
	selectWindow("CloseLabels");
	rename("Masked_IMG"); 
	selectWindow("Masked_IMG");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Convert to Mask");
	
	//SAVE output figures							
	if (Save_Output_Figures == "Yes") {
		if (chanDir == "None"){
			saveAs("Tiff", savedir + "//" + "output_" + Chan1List);
			selectWindow("output_" + Chan1List);
		}
		else{
			saveAs("Tiff", savedir + "//" + "output_" + ChanList);
			selectWindow("output_" + ChanList);
		}
		rename("Masked_IMG"); 
		selectWindow("Masked_IMG");
	}

	if (Save_Output_Figures == "No") {
		selectWindow("Masked_IMG");
	}
			
		
	//run("Set Measurements...", "area mean min feret's redirect=None decimal=3");
	run("Set Measurements...", "area mean min  redirect=None decimal=3");
	run("Analyze Particles...", "display summarize clear include");
		
	selectWindow("Summary");
	analyze_area = Table.getColumn( "Total Area" ); //get the area that is covered by vessels
	

	if(analyze_area[0] == 0){

		NumberOfBranches=0;
		meanBranchLength=0;
		meanDiameter=0;
		meantortuosity=0;
		totalvessellength=0;
		numClusters=0;					
		numJunctions= 0; 
		numEndpoints = 0;
		vascular_density = 0; 
		
		meanDiameterAboveThreshold=0;
		meanDiameterBelowThreshold=0;
		meantortuosity_indexAboveThreshold=0;
		meantortuosity_indexBelowThreshold=0;
		vascular_densityAboveThreshold=0;
		vascular_densityBelowThreshold=0;
		totalvessellengthAboveThreshold=0;
		totalvessellengthBelowThreshold=0;
		meanBranchLengthAboveThreshold=0;
		meanBranchLengthBelowThreshold=0;
		BranchesAboveThresholdCount=0;
		BranchesBelowThresholdCount=0;	

		close("Summary");
		close("Masked_IMG");
		
		// create empty table
		Table.create("Results");	
		tilename = newArray(1);
		density = newArray(1);
		tilename[0] = "test";
		density[0] = -1;
		Table.setColumn("Label", tilename);
		Table.setColumn("Vascular density (%)", density);
		
	}
		
	else{
	
		close("Summary");
		close("Results");			
					
		//Skeletonize the image (Skeletonize(2D))
		selectWindow("Masked_IMG");
		run("Duplicate...", " ");
		selectWindow("Masked_IMG");				
		run("Skeletonize (2D/3D)");
		run("Prune Skeleton Ends", "threshold=" + prune_threshold); //prune ends in the skeletonized image
		close("Masked_IMG");
		selectWindow("Masked_IMG-pruned");
		rename("Masked_IMG"); 
		run("Divide...", "value=255.000"); // create skeleton with values of 1 and background 0 (instead of 255 and 0)
		selectWindow("Masked_IMG-1"); 
		run("Local Thickness (complete process)", "threshold=255");
		imageCalculator("Multiply create", "Masked_IMG-1_LocThk","Masked_IMG");
		selectWindow("Result of Masked_IMG-1_LocThk");
		setOption("ScaleConversions", false); 
		run("8-bit");
		run("Analyze Skeleton (2D/3D)", "prune=none show"); // analyze the pruned skeleton 
		close("Tagged skeleton");
		close("Masked_IMG");
		close("Masked_IMG-1_LocThk");
		close("Result of Masked_IMG-1_LocThk");
		close("Masked_IMG-1"); 
		selectWindow("Results");
		
		if(Table.columnExists("# Branches")){
			numBranchespervessel = Table.getColumn("# Branches");
			numJunctionspervessel= Table.getColumn("# Junctions");
			numEndpointspervessel = Table.getColumn("# End-point voxels");
			numClusters = numBranchespervessel.length;
		}
		else{
			numBranchespervessel= newArray(1); 
			numBranchespervessel[0] = 0;
		}

		Array.getStatistics(numBranchespervessel, minimumnumBranchespervessel, maximumnumBranchespervessel, meannumBranchespervessel); 
		
		
		//get branch length information for all the separate branches
		if(maximumnumBranchespervessel == 0){
			NumberOfBranches=0;
			meanBranchLength=0;
			meanDiameter=0;
			meantortuosity_index=0;
			totalvessellength=0;
			numClusters=0;					
			numJunctions= 0; 
			numEndpoints = 0;
			vascular_density = 0; 
			
			meanDiameterAboveThreshold=0;
			meanDiameterBelowThreshold=0;
			meantortuosity_indexAboveThreshold=0;
			meantortuosity_indexBelowThreshold=0;
			vascular_densityAboveThreshold=0;
			vascular_densityBelowThreshold=0;
			totalvessellengthAboveThreshold=0;
			totalvessellengthBelowThreshold=0;
			meanBranchLengthAboveThreshold=0;
			meanBranchLengthBelowThreshold=0;
			BranchesAboveThresholdCount=0;
			BranchesBelowThresholdCount=0;						
			
			close("Results");
			close("Branch information");
		}
		
		else{ 
			selectWindow("Branch information");
			BranchLength = Table.getColumn("Branch length"); // euclidian distance in pixels
			SkeletonID = Table.getColumn("Skeleton ID");
			Diameter = Table.getColumn("average intensity");
			Euclidian_distance = Table.getColumn("Euclidean distance");
			tortuosity_index = newArray(Euclidian_distance.length); 
			vessel_area = newArray(BranchLength.length); 
			for ( q = 0; q < tortuosity_index.length ; q++ ) {
				if (Euclidian_distance[q]==0){
					tortuosity_index[q]=-1; // set tortuosity of looping vessels to -1 so that we can remove it later on
				}
				else{
					tortuosity_index[q] = BranchLength[q]/Euclidian_distance[q];
				}
			}
			
			for (q = 0; q < BranchLength.length ; q++ ) {
					vessel_area [q] = BranchLength[q]*Diameter[q];
			}
			

					
			//Vascular metrics:
			Array.getStatistics(BranchLength, minimum, maximum, meanBranchLength); //mean branch length per tile (pixels)
			Array.getStatistics(Diameter, minimum, maximum, meanDiameter); //mean branch diameter all vessels (pixels)
			tortuosity_index_corr = Array.deleteValue(tortuosity_index, -1); // Returns a version of array where all numeric or string elements in the array that contain value have been deleted (examples). Requires 1.52o.
			Array.getStatistics(tortuosity_index_corr, minimum, maximum, meantortuosity_index); //mean tortuosity index per tile for all vessels (arc-chord ratio)
			//the total branch length can be computed by multiplying the mean branch length by the number of branches
			NumberOfBranches = BranchLength.length; // tota number of branches per tile (#)
			totalvessellength = meanBranchLength*NumberOfBranches; //total vessel length per tile (pixels)
			Array.getStatistics(vessel_area, minimum, maximum, meanvessel_area); //mean branch diameter all vessels (pixels)
			totalvesselArea = NumberOfBranches*meanvessel_area; // area of the tile that is covered by vessels (pixels) needs to be normalized by the area that is coverd by tissue
			vascular_density = (totalvesselArea/masked_voxel_area)*100; // vascular density (%)
			
											
			Array.getStatistics(numJunctionspervessel, minimum, maximum, mean);
			//If pixels does not contain any junction the mean value will be NaNs --> Set value to zero 
			if (isNaN(mean)){
				mean=0;
			}
			numJunctions = mean*numClusters; //number of junctions per tile (#)
			
			Array.getStatistics(numEndpointspervessel, minimum, maximum, mean);
			//If pixels does not contain any endpoint the mean value will be NaNs --> Set value to zero 
			if (isNaN(mean)){
				mean=0;
			}
			numEndpoints = mean*numClusters; //number of endpoints per tile (#)
											

			BranchesAboveThresholdCount = 0; 
			BranchesBelowThresholdCount = 0; 
			BranchLengthAboveThresholdArray = newArray;
			BranchLengthBelowThresholdArray = newArray;
			DiameterAboveThresholdArray = newArray; 
			DiameterBelowThresholdArray = newArray; 
			tortuosity_indexAboveThresholdArray = newArray; 
			tortuosity_indexBelowThresholdArray = newArray; 
			vessel_areaAboveThresholdArray = newArray; 	
			vessel_areaBelowThresholdArray = newArray; 
			
			//loop over branches: 
			for ( k = 0; k < Diameter.length; k++ ) {

				//Split metrics based on Diameter
				if (Diameter[k] >= Threshold){
					BranchesAboveThresholdCount++; //number of branches above threshold
					BranchLengthAboveThresholdArray = Array.concat(BranchLengthAboveThresholdArray,BranchLength[k]);
					DiameterAboveThresholdArray = Array.concat(DiameterAboveThresholdArray,Diameter[k]);
					tortuosity_indexAboveThresholdArray = Array.concat(tortuosity_indexAboveThresholdArray,tortuosity_index[k]);
					vessel_areaAboveThresholdArray = Array.concat(vessel_areaAboveThresholdArray,vessel_area[k]);
				}
				if (Diameter[k] < Threshold){
					BranchesBelowThresholdCount++; //number of branches below threshold
					BranchLengthBelowThresholdArray = Array.concat(BranchLengthBelowThresholdArray,BranchLength[k]);
					DiameterBelowThresholdArray = Array.concat(DiameterBelowThresholdArray,Diameter[k]);
					tortuosity_indexBelowThresholdArray = Array.concat(tortuosity_indexBelowThresholdArray,tortuosity_index[k]);
					vessel_areaBelowThresholdArray = Array.concat(vessel_areaBelowThresholdArray,vessel_area[k]);
				}
																																																		
			}	
			
			close("Results");																																																													
			close("Branch information");
			
			//Vascular metrics - Split in two compartments: 
			
			//create empty array if there are no branches above/below threshold																
			if (BranchesAboveThresholdCount == 0) {
					BranchLengthAboveThresholdArray = newArray(1);
					DiameterAboveThresholdArray = newArray(1);
					tortuosity_indexAboveThresholdArray = newArray(1);
					vessel_areaAboveThresholdArray = newArray(1);
			}
			if (BranchesBelowThresholdCount == 0) {
					BranchLengthBelowThresholdArray = newArray(1);
					DiameterBelowThresholdArray = newArray(1);
					tortuosity_indexBelowThresholdArray = newArray(1);
					vessel_areaBelowThresholdArray = newArray(1);
			}
						
			Array.getStatistics(BranchLengthAboveThresholdArray, minimum, maximum, meanBranchLengthAboveThreshold); //mean branch length above threshold (pixels)
			Array.getStatistics(DiameterAboveThresholdArray, minimum, maximum, meanDiameterAboveThreshold); //mean branch diameter above threshold (pixels)
			Array.getStatistics(tortuosity_indexAboveThresholdArray, minimum, maximum, meantortuosity_indexAboveThreshold); //mean tortuosity index per tile above threshold (arc-chord ratio)
			Array.getStatistics(vessel_areaAboveThresholdArray, minimum, maximum, meanvessel_areaAboveThresholdArray); 
				
			totalvessellengthAboveThreshold = meanBranchLengthAboveThreshold*BranchesAboveThresholdCount; 
			totalvesselAreaAboveThreshold = BranchesAboveThresholdCount*meanvessel_areaAboveThresholdArray; // area of the tile that is covered by vessels (pixels) needs to be normalized by the area that is coverd by tissue
			vascular_densityAboveThreshold = (totalvesselAreaAboveThreshold/masked_voxel_area)*100; // vascular density above threshold (%)
			
			Array.getStatistics(BranchLengthBelowThresholdArray, minimum, maximum, meanBranchLengthBelowThreshold); //mean branch length below threshold (pixels)
			Array.getStatistics(DiameterBelowThresholdArray, minimum, maximum, meanDiameterBelowThreshold); //mean branch diameter below threshold (pixels)
			Array.getStatistics(tortuosity_indexBelowThresholdArray, minimum, maximum, meantortuosity_indexBelowThreshold); //mean tortuosity index per tile above threshold (arc-chord ratio)
			Array.getStatistics(vessel_areaBelowThresholdArray, minimum, maximum, meanvessel_areaBelowThresholdArray); 

			totalvessellengthBelowThreshold = meanBranchLengthBelowThreshold*BranchesBelowThresholdCount; 
			totalvesselAreaBelowThreshold = BranchesBelowThresholdCount*meanvessel_areaBelowThresholdArray; // area of the tile that is covered by vessels (pixels) needs to be normalized by the area that is coverd by tissue
			vascular_densityBelowThreshold = (totalvesselAreaBelowThreshold/masked_voxel_area)*100; // vascular density above threshold (%)
				
			if(vascular_density > 100) {									

				NumberOfBranches=0;
				meanBranchLength=0;
				meanDiameter=0;
				meantortuosity_index=0;
				totalvessellength=0;
				numClusters=0;					
				numJunctions= 0; 
				numEndpoints = 0;
				vascular_density = 0; 
				
				meanDiameterAboveThreshold=0;
				meanDiameterBelowThreshold=0;
				meantortuosity_indexAboveThreshold=0;
				meantortuosity_indexBelowThreshold=0;
				vascular_densityAboveThreshold=0;
				vascular_densityBelowThreshold=0;
				totalvessellengthAboveThreshold=0;
				totalvessellengthBelowThreshold=0;
				meanBranchLengthAboveThreshold=0;
				meanBranchLengthBelowThreshold=0;
				BranchesAboveThresholdCount=0;
				BranchesBelowThresholdCount=0;
			}
				
			if (vascular_density==0){							
				NumberOfBranches=0;
				meanBranchLength=0;
				meanDiameter=0;
				meantortuosity_index=0;
				totalvessellength=0;
				numClusters=0;					
				numJunctions= 0; 
				numEndpoints = 0;
				vascular_density = 0; 
				
				meanDiameterAboveThreshold=0;
				meanDiameterBelowThreshold=0;
				meantortuosity_indexAboveThreshold=0;
				meantortuosity_indexBelowThreshold=0;
				vascular_densityAboveThreshold=0;
				vascular_densityBelowThreshold=0;
				totalvessellengthAboveThreshold=0;
				totalvessellengthBelowThreshold=0;
				meanBranchLengthAboveThreshold=0;
				meanBranchLengthBelowThreshold=0;
				BranchesAboveThresholdCount=0;
				BranchesBelowThresholdCount=0;
			}
		}

		Table.create("Results");	
		//table needs arrays as input --> create arrays
		tilename = newArray(1);
		density = newArray(1);
		diameter = newArray(1); 
		Tortuosity = newArray(1); 
		NumberOfClusters_norm= newArray(1); 
		NumberOfBranches_norm= newArray(1); 
		numJunctions_norm= newArray(1); 
		numEndpoints_norm = newArray(1); 
		branchlength = newArray(1);
		totallength = newArray(1);
		
		DiameterBelowThreshold = newArray(1); 
		DiameterAboveThreshold = newArray(1); 
		TortuosityAboveThreshold = newArray(1);
		TortuosityBelowThreshold = newArray(1);
		BranchesAboveThreshold = newArray(1);  
		BranchesBelowThreshold = newArray(1);  
		totallengthAboveThreshold = newArray(1); 
		totallengthBelowThreshold = newArray(1); 
		densityAboveThreshold = newArray(1); 
		densityBelowThreshold = newArray(1); 
		branchlengthAboveThreshold = newArray(1); 
		branchlengthBelowThreshold = newArray(1); 

		if (masked_voxel_area==0){}
		else{
			
			tilename[0] = Chan1List;
			diameter[0] = meanDiameter * calibration; // mean diameter (µm)
			density[0] =vascular_density; //ROI_voxel_percentage; // (%)
			Tortuosity[0] = meantortuosity_index; //(arc-chord ratio)
			totallength[0] = totalvessellength*calibration*1000/(masked_voxel_area*voxel_size); //vessel length density (mm/mm^2)
			branchlength[0]= (meanBranchLength)*calibration ; // mean branchlength (µm)
			NumberOfBranches_norm[0]=NumberOfBranches*1000000/(masked_voxel_area*voxel_size); // branch density (#/mm²)
			NumberOfClusters_norm[0]= numClusters*1000000/(masked_voxel_area*voxel_size);  // cluster density (#/mm²) [*1000000 to go from µm² -->mm^²]					
			numJunctions_norm[0]=numJunctions*1000000/(masked_voxel_area*voxel_size); // junction density (#/mm²)
			numEndpoints_norm[0]=numEndpoints*1000000/(masked_voxel_area*voxel_size); // endpoint density (#/mm²)
		
			DiameterAboveThreshold[0] = meanDiameterAboveThreshold*calibration; 
			DiameterBelowThreshold[0] = meanDiameterBelowThreshold*calibration;
			TortuosityAboveThreshold[0] = meantortuosity_indexAboveThreshold;
			TortuosityBelowThreshold [0]= meantortuosity_indexBelowThreshold;
			densityAboveThreshold[0]= vascular_densityAboveThreshold; 
			densityBelowThreshold[0]= vascular_densityBelowThreshold; 
			totallengthAboveThreshold[0] = totalvessellengthAboveThreshold*calibration*1000/(masked_voxel_area*voxel_size); 
			totallengthBelowThreshold[0] = totalvessellengthBelowThreshold*calibration*1000/(masked_voxel_area*voxel_size);
			branchlengthAboveThreshold[0]= (meanBranchLengthAboveThreshold)*calibration ;
			branchlengthBelowThreshold[0]= (meanBranchLengthBelowThreshold)*calibration ; 
			BranchesAboveThreshold[0] = BranchesAboveThresholdCount*1000000/(masked_voxel_area*voxel_size); 
			BranchesBelowThreshold[0] = BranchesBelowThresholdCount*1000000/(masked_voxel_area*voxel_size);   
		}			
		

		//Total vascular metrics
		Table.setColumn("Label", tilename);
		Table.setColumn("Mean vessel diameter (µm)", diameter);
		Table.setColumn("Vascular density (%)", density);
		Table.setColumn("Vessel length density (mm/mm²)", totallength);
		Table.setColumn("Mean branch length (µm)", branchlength);
		Table.setColumn("Branch density(#/mm²)", NumberOfBranches_norm);
		Table.setColumn("Tortuosity index", Tortuosity);
		Table.setColumn("Cluster density (#/mm²)", NumberOfClusters_norm);
		Table.setColumn("Branchpoint density (#/mm²)", numJunctions_norm);
		Table.setColumn("Endpoint density (#/mm²)", numEndpoints_norm);
		
		//vascular metrics above threshold
		Table.setColumn("Mean vessel diameter above threshold (µm)", DiameterAboveThreshold); 
		Table.setColumn("Vascular density above threshold (%)", densityAboveThreshold); 
		Table.setColumn("Vessel length density above threshold (mm/mm²)", totallengthAboveThreshold); 
		Table.setColumn("Mean branch length above threshold (µm)", branchlengthAboveThreshold); 
		Table.setColumn("Branch density above threshold (#/mm²)", BranchesAboveThreshold); 
		Table.setColumn("Tortuosity index above threshold", TortuosityAboveThreshold);

		//vascular metrics Below threshold
		Table.setColumn("Mean vessel diameter below threshold (µm)", DiameterBelowThreshold); 
		Table.setColumn("Vascular density below threshold (%)", densityBelowThreshold); 
		Table.setColumn("Vessel length density below threshold (mm/mm²)", totallengthBelowThreshold); 
		Table.setColumn("Mean Branch length below threshold (µm)", branchlengthBelowThreshold);
		Table.setColumn("Branch density below threshold (#/mm²)", BranchesBelowThreshold);
		Table.setColumn("Tortuosity index below threshold", TortuosityBelowThreshold);
	
		filename = File.getParent(Dir); //get the name of the directory
		name = File.getName(filename);
		
		run("Read and Write Excel", "file=["+ savedir + "//" + name + "_vascular_density.xlsx], stack_results, sheet=Channel"); //save output in excell file in the folder of the ROI
	}
}

function makefigure(channel_array, channel_name, min, max, LUTname, output, numCol, numRow) {
	newImage(channel_name, "16-bit black", numCol, numRow, 1);	
	selectWindow(channel_name);
		
	for (a=0; a<(numCol); a++) {
		for (j=0; j<(numRow); j++) {
    		selectWindow(channel_name);
			setPixel(a, j, channel_array[(j) + (numRow)*(a)]);
    	}
	}
					
	setMinAndMax(min, max);
	run(LUTname);
	saveAs("Tiff", output + "//" + channel_name);
	selectWindow(channel_name + ".tif");
	run("Calibration Bar...", "location=[Separate Image] fill=White label=Black number=5 decimal=0 font=10 zoom=2 bold");
	selectWindow("CBar"); 
	saveAs("Tiff", output + "//" + channel_name + "_CBar");
	close(channel_name + "_CBar.tif");
	selectWindow(channel_name + ".tif");
	close(channel_name + ".tif");											
}






