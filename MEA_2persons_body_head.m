%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)

% Before you run this script, please start "MEA_ROI_freehand_v04.m"
% to mark the regions of interest (ROI) which should be analysed.
% Output file of "MEA_ROI_freehand.m" is 
% required to run this script without errors.

% input parameter:
% videoNames = path + name of the concerning video file
% cut off = cut off for meaningful pixel changes

% Output of this function is a matrix with:
% 1. column: ME of left person upper body
% 2. column: ME of right person upper body
% 3. column: ME of left noise ROI
% 4. column: ME of right noise ROI
% 5. column: ME of left person head
% 6. column: ME of right person head
% the line refers to the video frame, in line 23 for example are the 
% motion energy values saved which were computed with frame 23 and 24.

function [] = MEA_2persons_body_head(video_file_name, cut_off)


    %% check input arguments: file name? If no, select with file browser
    if nargin<1 || isempty(video_file_name) ,

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
    w = mov.Width;
    numberFrames = mov.numberOfFrames;
    
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
        
        error( [ 'File ', video_file_name, ' does not exists. Please start "MEA_ROI_freehand_v04.m" to mark the regions of interest (ROI). Then run this script again.'] );
        
    end
    
    disp(['Open mat file: ' file_path, file_name,'_rois.mat' ]);
    
    load( [file_path, file_name,'_rois.mat'], '-mat');
    
    
    %% check input arguments: threshold for frame differencing 
    if nargin < 2,
        cut_off = 12; % this must be an integer
        disp(['No threshold for frame differencing was specified. The default (', ...
              num2str(cut_off), ...
              ') is applied.']);
    end
    
    
    
    %% *** Motion Energy Analysis ***************************************

    disp(' ')
    disp('Computation of motion energy. This takes a while.')
    
    % matrix to store motion energy values
    me = zeros(numberFrames-1, 6);
    
    
    % read the first frame
    frame_1 = rgb2gray(read(mov,1));  

    
    % compute for each frame pair the difference and based on it the ME
    for frame = 2:numberFrames,
        
        % Extract the frame from the movie structure
        frame_2 = rgb2gray( read(mov, frame) );

        
        % ROI for left person body, and ROI for right person body
        % 2-D median filter is used
        me(frame-1,1) = sum( sum( medfilt2( imabsdiff( ...
                        frame_1.*roi1, frame_2.*roi1 ),[5 5]) > cut_off ) ) ;

        me(frame-1,2) = sum( sum( medfilt2( imabsdiff( ...
                        frame_1.*roi2, frame_2.*roi2 ),[5 5]) > cut_off ) ) ;

        %ROI for checking background noise 
        me(frame-1,3) = sum( sum( imabsdiff( ...
                        frame_1.*roi3, frame_2.*roi3 ) > cut_off ) ) ;
        me(frame-1,4) = sum( sum( imabsdiff( ...
                        frame_1.*roi4, frame_2.*roi4 ) > cut_off ) ) ;

        % ROI for left person head, and ROI for right person head
        me(frame-1,5) = sum( sum( medfilt2( imabsdiff( ...
                        frame_1.*roi5, frame_2.*roi5 ),[5 5]) > cut_off ) ) ;
        me(frame-1,6) = sum( sum( medfilt2( imabsdiff( ...
                        frame_1.*roi6, frame_2.*roi6 ),[5 5]) > cut_off ) ) ;
                                
        frame_1 = frame_2;
    end
    
    disp('... finished.')
    
    
  
    %% *** save results ************************************************
    [file_path, file_name, ~] = fileparts(video_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end
        
    
    disp(' ');
    disp(['Save motion energy time series in the tab-spaced *.txt file: ', ...
          file_path, file_name,'_MEA_co' num2str(cut_off) '.txt'])
    disp(['Note, -co' num2str(cut_off) '- indicates the application of threshold respectively cut off = ' num2str(cut_off) '.']);
      
    dlmwrite([file_path, file_name,'_MEA_co' num2str(cut_off) '.txt'], me, '\t'); 
    
    
end