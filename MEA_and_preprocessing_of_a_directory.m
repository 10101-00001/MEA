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

function [] = MEA_and_preprocessing_of_a_directory(directory_name)


    % settings
    cut_off = 12; % default is 12
    
    video_format = 'avi';  % default is 'avi'
    
    
    % check input arguments: file name? If no, select with file browser
    if nargin<1 || isempty(video_file_name) ,

        disp(' ')
        disp('Please select the directory in which the video files and the corresponding MAT file (with ROI informations) are stored.')
        
        directory_name = uigetdir;
        
    else
    
        if exist( directory_name, 'dir') ~= 7
            
            error(['The specified directory (' directory_name ...
                   ') is not a folder or does not exist.'])
        
        end
        
    end
    
    disp(' ')
    disp(['Selected directory is ' directory_name])
    
    
    
    % *** create a list with video files ********************************

    Names = dir( fullfile(directory_name, ['*.' video_format]) );
    Names = {Names.name}';
    Names = fullfile(directory_name, Names);

    n_videos = length(Names);
    
    disp(' ')
    disp(['Found ' num2str(n_videos) ' video files.'])
    
    
    % *** MEA and pre-processing steps for each video file **************
    for n = 1:n_videos,
        
        MEA_and_preprocessing_of_a_video( Names{n} )
        
    end % for
    
    disp(' ')
    disp(['Analysis of video files in the directory ' directory_name ...
          ' finished. Please check for warnings in the log-file. ' ...
          'A warning is given when a MAT file (with informations about ' ...
          'ROI) is not found for the video file.'])
    
end % function