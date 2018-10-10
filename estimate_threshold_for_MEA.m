%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)
%
% The motion energy analys compare the color intensity of a pixel at t and
% the corresponding pixel at t+1 and cound pixels with significant change.
% The "significance of change" is quantified with a threshold.
% With this script estimates the threshold using background ROI.

% Before you start this script, please define regions of interest using the
% script MEA_ROI_freehand_v01.m


function [q99, q95] = estimate_threshold_for_MEA(video_file_name)

    % check input argument: Is the video file spezified?
    if nargin < 1,

        disp(' ')
        disp('Please select the video file which should be analysed.')
        
        [filename, PathName, ~] = uigetfile('*.avi');
    
        video_file_name = [PathName filename];   

    end

    
    %% *** load video ***************************************************
    disp(' ')
    disp(['Open video file: ' video_file_name ]);
    
    mov = VideoReader( video_file_name );

    hei = mov.Height;
    w   = mov.Width;
    numberFrames = mov.numberOfFrames ;
    
    disp(['Video size: ', num2str(hei), ' x ', num2str(w) ]);
    disp(['Number of frames: ', num2str(numberFrames) ]);    
    disp(['Frame rate: ', num2str(mov.FrameRate) ]);
    
    

    %% *** load mat file for the positions of both background ROI *******
    
    [file_path, file_name, ~] = fileparts(video_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end    

    % check that the video file exists
    if exist([file_path, file_name,'_rois.mat'], 'file') ~=2,
        
        error( [ 'File ' file_path, file_name,'_rois.mat'...
                 ' does not exists. Please start "MEA_ROI_freehand_v04.m" to mark the regions of interest (ROI). Then run this script again.'] );
        
    end
    
    disp(['Open mat file: ' file_path, file_name,'_rois.mat' ]);
    
    load( [file_path, file_name,'_rois.mat'], '-mat');
    
    
    %% *** compute size of both background ROI **************************
    background_ROI = roi3 + roi4;

    background_ROI_size = sum( sum( background_ROI ));
    

    % define empthy array to store all difference values
    diff_values = zeros(numberFrames, background_ROI_size );
    
    
    
	
    %% ** compute difference values ************************************* 
    disp(' ')
    disp('Computation of difference values for both background ROI. This takes a while.')
    
    
    % load the first frame of Video and convert in grey scale
    frame_1 = rgb2gray( read(mov, 1) );
    
    % loop
    for frame = 2:numberFrames,
        
        % Extract the frame from the movie structure.
        frame_2 = rgb2gray( read(mov, frame));

        diff_frame = imabsdiff(frame_1(background_ROI==1), frame_2(background_ROI==1) );

        diff_values(frame-1,:) = diff_frame';
        
        % for the next round, now frame 2 (t+1) is now 1 (t)
        frame_1 = frame_2;
    end
   
    clear  frame_1  frame_2  diff_frame;
    
    disp('... finished')
       
    
    %% ** compute statistics respectively the outout parameter ********** 
    
    % reshape all difference values to an vector which values ordered
    diff_values = sort(reshape( diff_values, [], 1));
    n_diff_values = length( diff_values );
    
    % 99 percent quantil is the first threshold (recommended, more
    % conservative)
    q99 = diff_values( round( 0.99 * n_diff_values ) );
    
    % 95 percent quantil is the second threshold 
    q95 = diff_values( round( 0.95 * n_diff_values ) );
    
    disp(' ')
    disp(['1st threshold (99% quantile): ' num2str( q99 ) ' (recommended for MEA)'] )
    disp(['2st threshold (95% quantile): ' num2str( q95 ) ] )
    disp(['minimum was: ' num2str( diff_values(1) ) ] )
    disp(['maximum was: ' num2str( diff_values(end) ) ] )
    
    
end
