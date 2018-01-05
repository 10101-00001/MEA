%% writen and developed by Désirée Thielemann and Uwe Altmann
%% please cite: Altmann, U. Thielemann, D. et al. (submitted) Introduction, Practical Guide, and Validation Study for Measuring Body Movements Using Motion Energy Analysis



%Altmann, U. (2013). Synchronisation nonverbalen Verhaltens. Wiesbaden: VS Springer. ISBN 978-3-531-19815-6

%Matlab script for analysing Motion-Energy using an interface to draw ROI
%freehand

function [] = MEA_ROI_freehand_v03(workingDir, frame_no)

    % *** proof imput ***************************************************
    if nargin < 1,
        workingDir = 'C.\';
        disp('No working directory was specified. The default c:\ is used.')
    end
    
    if nargin < 2,
        frame_no = 25 * 60 * 2;
        disp('No frame was specified. The default frame no. 3000 (at time 2:00) is used.')
    end
    




    % *** Choose movie **************************************************
    % also for all other VideoReader supported file formats running on your platform
    % .avi works for every platform
    
    [filename, PathName, ~] = uigetfile([workingDir, '*.avi']);
    
    workingDir = PathName;

    

    % *** load video ****************************************************
    disp(['Open video: ' filename ]);
    mov = VideoReader([PathName filename]);

    
    % *** set coordinates of background ROI *****************************
    disp(['Video format is ', num2str(mov.Height), 'x', ...
          num2str(mov.Width) , ' pixel.']);


    if      mov.Height == 480  &&  mov.Width == 640,
        
        roi3 = [ 65    15   75   25 ]; 
        roi4 = [ 65   615   75  625 ]; 
        roi7 = [ 420   15  430   25 ]; 
        roi8 = [ 420  615  430  625 ];
        
    elseif  mov.Height < 480   &&  mov.Width < 640,
        
        error('The Video format must be 480x640 or larger.');
          
    else
        
        roi3 = [ 65                       15             75            25 ]; 
        roi4 = [ 65             mov.Width-25             75  mov.Width-15 ]; 
        roi7 = [ mov.Height-60            15  mov.Height-50            25 ]; 
        roi8 = [ mov.Height-60  mov.Width-25  mov.Height-50  mov.Width-15 ];
        
    end
    
    
    
    
    % first frame of movie is loaded *************************************
    frame_1 = rgb2gray( read( mov, frame_no) );


    % Specify background ROI (two in the upper frame and two in the lowerr
    % frame)
    [roi3] = compute_background_ROI( mov.Height, mov.Width, roi3 );
    [roi4] = compute_background_ROI( mov.Height, mov.Width, roi4 );
    
    [roi7] = compute_background_ROI( mov.Height, mov.Width, roi7 );
    [roi8] = compute_background_ROI( mov.Height, mov.Width, roi8 );



    % show video frame whereby background ROI marked as light grey areas
    frame_1b = frame_1 + 60*(roi3 + roi4 + roi7 + roi8);
    figure(1);
    imshow( frame_1b );


    % now, the use can draw the ROI for body and head (for both persons)
    disp('The four rectangles in the corners of the video frame mark ROI');
    disp('which are used later to detect noise. Please draw body ROI which does');
    disp('not overlap with these background ROI.');
    disp(' ');

    disp('1) Please draw PATIENT BODY, leave figure open.');
    roi1 = uint8( createMask( imfreehand(gca) ) ); 

    disp('2) Please draw THERAPIST BODY, leave figure open.');
    roi2 = uint8( createMask( imfreehand(gca) ) ); 

    disp('3) Please draw PATIENT HEAD, leave figure open.');
    roi5 = uint8( createMask( imfreehand(gca) ) );  

    disp('4) Please draw THERAPIST HEAD, leave figure open.');
    roi6 = uint8( createMask( imfreehand(gca) ) ); 



    % proof that background ROIs are not overlapping with person ROI

    % compute overlap of body ROI with upper background ROI 
    % measured by number of pixels whereby 0 = no overlap.
    % Remember, positions of background ROI were defined above
    add__body = sum( sum( (roi1+roi2+roi3+roi4) > 1 ) ); 
    
    % overlap of body ROI with lower noise ROI 
    add2_body = sum( sum( (roi1+roi2+roi7+roi8) > 1 ) );
    
    % overlap of head ROI with upper noise ROI
    add__head = sum( sum( (roi5+roi6+roi3+roi4) > 1 ) );
    
    % overlap of head ROI with lower noise ROI
    add2_head = sum( sum( (roi5+roi6+roi7+roi8) > 1 ) );
    
    
    % check for overlap of noise ROI with body and head ROI
    % Uses upper background ROIs per default
    % If body is overlapping with background ROIs: choose lower ROIs
    if     (add__body == 0 && add__head == 0 ),
        
        background_ROI = 0 ; % indicate that upper noise ROI should be used
        disp('Upper background ROI were used.');
        
    elseif (add2_body == 0 && add2_head == 0 ),
        
        background_ROI = 1 ; % indicate that lower noise ROI should be used
        disp('Lower background ROI were used.');
        
        % later roi3 and roi4 where saved, thatswhy roi3 and roi4 gets the
        % coordinated of the lower background ROI (roi7 and roi8)
        roi3 = roi7;
        roi4 = roi8;    
        
    else
        
        error('Background, body, and head ROI overlap. Please re-run the script.')
        
    end
    
    
    % close figure 
    close(1);
    

    % Size of body and head ROI which later can used for standardization 
    % background_ROI= 1 indicate that lower background ROIs were used, 
    % whereas background_ROI=0 means upper background ROI
    size_roi = [ sum(sum(roi1)); ...
                 sum(sum(roi2)); ...
                 sum(sum(roi3)); ...
                 sum(sum(roi4)); ...
                 sum(sum(roi5)); ...
                 sum(sum(roi6)); ...
                 background_ROI];

   
    % SAVE: ROIs, background ROI indicator and size of ROIs    
    disp(' ');
    disp('Save *.mat file in the directory of movie file.')
    [~, name, ~] = fileparts(filename);
    save([workingDir, name,'_rois.mat'], ...
          'roi1', 'roi2', 'roi3', 'roi4', 'roi5', 'roi6', 'size_roi');

    disp('Marking of ROIs are completed.')
    
    
end % of function





% ***********************************************************************
% ***********************************************************************
function [ROI] = compute_background_ROI( frame_Height, frame_Width, ROI_corners)

    % proof input
    if nargin < 3,
        error('Input is not complete. Specification of frame_Height, frame_Width, ROI_corners is needed.')
    end
    

    % *** compute vectores x and y coordinates of ROI corners
    x = [ROI_corners(2), ROI_corners(4), ROI_corners(4), ROI_corners(2)];
    y = [ROI_corners(1), ROI_corners(1), ROI_corners(3), ROI_corners(3)];

    % *** compute ROI as matrix
    ROI = uint8( poly2mask(x, y, frame_Height, frame_Width ) );

end