%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)
%
% With this script regions of interest were defined. Start this script
% before motion energy analysis.


function [] = MEA_ROI_freehand_v04(video_file_name, frame_no)

    % *** proof input ***************************************************
    if nargin < 1,

        disp(' ')
        disp('Please select the video file which should be analysed.')
        
        [filename, PathName, ~] = uigetfile('*.avi');
    
        video_file_name = [PathName filename];        
        
    end
   
    

    % *** load video ****************************************************
    disp(['Open video: ' video_file_name ]);
    
    mov = VideoReader( video_file_name );

    disp(['Video size: ', num2str(mov.Height), ' x ', num2str(mov.Width) ]);
    disp(['Number of frame: ', num2str( mov.numberOfFrames ) ]);    
    disp(['Frame rate: ', num2str(mov.FrameRate) ]);
    
    
    
    % *** check example frame********************************************

        
    if nargin < 2,        
        frame_no = round( 0.1 * mov.numberOfFrames );
        
        disp(['For drawing ROI, no reference video frame was specified. The default (video duration / 10 = ' num2str(frame_no) ') is used.'])
    end
    
    
    if mov.numberOfFrames < frame_no,        
        frame_no = round( 0.1 * mov.numberOfFrames );
        
        disp(['The video duration is shorter than expected. Reference video frame is set to frame no. ' ...
              num2str(frame_no) '.'])    
    end
    
    
    
    
    
    % *** set coordinates of background ROI *****************************
    % please note, the one background ROi must consist 100 pixel
    
    if      mov.Height == 480  &&  mov.Width == 640,
        
        roi3 = [ 65    15   75   25 ]; % upper left
        roi4 = [ 65   615   75  625 ]; % upper rigth
        roi7 = [ 420   15  430   25 ]; % lower left
        roi8 = [ 420  615  430  625 ]; % lower right
        
    else
        
        roi3 = [ 65                       15             75            25 ]; % upper left
        roi4 = [ 65             mov.Width-25             75  mov.Width-15 ]; % upper rigth
        roi7 = [ mov.Height-60            15  mov.Height-50            25 ]; % lower left
        roi8 = [ mov.Height-60  mov.Width-25  mov.Height-50  mov.Width-15 ]; % lower right
        
    end
    

    % convert the coordinates of background ROI into matrizes
    [roi3] = compute_background_ROI( mov.Height, mov.Width, roi3 );
    [roi4] = compute_background_ROI( mov.Height, mov.Width, roi4 );
    
    [roi7] = compute_background_ROI( mov.Height, mov.Width, roi7 );
    [roi8] = compute_background_ROI( mov.Height, mov.Width, roi8 );


    % reference video frame is loaded *************************************
    frame_1 = rgb2gray( read( mov, frame_no) );
    

    % show video frame whereby background ROI marked as light grey areas
    frame_1b = frame_1 + 60*(roi3 + roi4 + roi7 + roi8);
    figure(1);
    imshow( frame_1b );


    % now, the use can draw the ROI for body and head (for both persons)
    disp(' ');
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
        
        background_ROI = false ; % indicate that upper noise ROI should be used
        disp('Upper background ROI were used.');
        
    elseif (add2_body == 0 && add2_head == 0 ),
        
        background_ROI = true ; % indicate that lower noise ROI should be used
        disp('Lower background ROI were used.');
        
        % later roi3 and roi4 where saved, thatswhy roi3 and roi4 gets the
        % coordinated of the lower background ROI (roi7 and roi8)
        roi3 = roi7;
        roi4 = roi8; 
        
        clear roi7 roi8;
        
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
                 sum(sum(roi6))];

   
    % SAVE: ROIs, background ROI indicator and size of ROIs    
    [file_path, file_name, ~] = fileparts(video_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end
        
    
    disp(' ');
    disp(['Save regions of interest in a *.mat file: ', ...
          file_path, file_name,'_rois.mat'])
    
    save([file_path, file_name,'_rois.mat'], ...
          'roi1', 'roi2', 'roi3', 'roi4', 'roi5', 'roi6', ...
          'size_roi', 'background_ROI' );

        
    
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