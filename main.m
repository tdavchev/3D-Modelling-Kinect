function [] = main(frame3dArray)
%{
#Naming Conventions
 Bg - background
 Fg - foreground

#Input
  * frame3DArray - cell of 3d frames (pcl_cell from av_pcl.mat file)

#General Algorithm
for each 3D frame:
  * Extracting foreground using PCA and remove noise by using percentile 
    statistics (relying on the fact that overwhelming majority of 
    cloud points belongs to the background). Due to that most of outliers 
    are removed on this stage.
  * Use DBscan clustering to allocate initial clusters 
  * Select clusters which belongs to spheres using geometric information 
    that spheres form outer triangle
  * Compute color histograms of each spheres and compare it to the anchor 
    3D frame and align sphere indices
  * Find the rotation and translation of coordinate frame via PCA
  * Apply rotation and translation to the cube cluster and store it 
 
After that merge all cube cloud points from each 3D frame and utilize 
patch growing algorithm to select 9 planes. On this stage sampling 
is used to reduce the number of cloud points and reduce load 
on patch growing algorithm.
%}  
%[xyzFg, rgbFg] = getForeground(

  %close all opened windows
  close all;
  %---------- PARAMETERS FOR PLOTTING ----------------
  %Each plot is shown for a specific frames.
  %Set to [-1] in order to avoid showing them.
  %global plotForegroundFrame3d;
  %shows foreground cloud points for specific frames
  PLOT_FOREGROUND_FRAME3D = [1:length(frame3dArray)];
  %shows distribution of all cloud points along background normal
  PLOTPOSITIONS_ALONG_BG_NORMAL = [-1];
  %shows background normal vector
  SHOW_BG_NORMAL = -1;
  for iFrame3d = 1:length(frame3dArray)
    fprintf('Process frame3d %d\n', iFrame3d);
    frame3d = frame3dArray{iFrame3d};
    
    % ------------------- EXTRACTING FOREGROUND --------------------------

    fprintf('Extracting foreground\n');
    
    [xyzFg, rgbFg, planeBgNormal, planeBgPoint] = getForeground(frame3d,...
      ismember(iFrame3d, PLOTPOSITIONS_ALONG_BG_NORMAL));
    
    fprintf('Number of foreground cloud points: %d\n', size(xyzFg, 1));
    if ismember(iFrame3d, PLOT_FOREGROUND_FRAME3D);
      if SHOW_BG_NORMAL == 1
        plotFrame3d(xyzFg, rgbFg, planeBgNormal, planeBgPoint);
      else
        plotFrame3d(xyzFg, rgbFg);
      end
    end
    
    % ----------------------- CLUSTERING  --------------------------
    
  end
end

