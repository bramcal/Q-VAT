/* Script to split ROI MASKs into tiles for use in the Q-VAT software
 *  
 * Author: Bram Callewaert
 * Contact: bram.callewaert@kuleuven.be
 * 
 * Copyright 2022 Bram Callewaert, Leuven Univeristy, Departement of Cardiovascular Sciences, Center for Molecular and Vascular Biology (CMVB)
 */

			ROI_name = "Thalamus.tif";
			tilewidth = 2048;
			tileheight = 2044;
			tileoverlap=10;
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			ROI_name_tiffless = replace(ROI_name, ".tif", ""); //remove the ".tif extension"
			ouputDirname = "04_Tissue_mask_" + ROI_name_tiffless
			title = ROI_name_tiffless + "_ROI_";

			//			C:\Users\u0135611\OneDrive - KU Leuven\Desktop\split_ROIs_Test
			path = "select file directory";
			inputDir1 = getDirectory(path); //get path to inputdir: 
			
			
			setBatchMode(true );
			inputDir = inputDir1 + '\\';
			subFolderList = getFileList(inputDir);
			
			//loop over all the folders (i.e. subjects) within the selected input directory
			for (k=0; k<subFolderList.length;k++){
			
			//get a list of all folders in the sub-directory (i.e. subjects)
			subdir= subFolderList[k];
						
			TissueMaskDir = inputDir1 + subdir + "TissueMASK" + "\\";
			
			
			open(TissueMaskDir + ROI_name);
			
			
			File.makeDirectory(	TissueMaskDir  + ouputDirname);
			
				
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
						saveAs("Tiff",TissueMaskDir +  "\\" + ouputDirname + "\\"  + tileTitle);
						close(tileTitle + ".tif");					
				 }
			}
			close(ROI_name);		
		}			
			
			

					
			