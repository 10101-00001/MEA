%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)

% Before you run this script, please start "MEA_ROI_freehand_v04.m"
% to mark the regions of interest (ROI) which should be analysed.
% Output file of "MEA_ROI_freehand.m" is 
% required to run this script without errors.

% input parameter:
% video_file_name = path + name of the concerning video file


function [] = MEA_and_preprocessing_of_a_video(video_file_name)


    % settings
    
    cut_off = 12; % default is 12
    
    
    % check input arguments: file name? If no, select with file browser
    if nargin<1 || isempty(video_file_name) ,

        disp(' ')
        disp('Please select the video file which should be analysed.')
        
        [filename, PathName, ~] = uigetfile('*.avi');
    
        video_file_name = [PathName filename];   
        
    end
    
    
    % *** load video ***************************************************
    disp(' ')
    disp(['Open video file: ' video_file_name ]);
    
    mov = VideoReader( video_file_name );

    hei = mov.Height;
    w   = mov.Width;
    numberFrames = mov.numberOfFrames ;
    
    disp(['Video size: ', num2str(hei), ' x ', num2str(w) ]);
    disp(['Number of frame: ', num2str(numberFrames) ]);    
    disp(['Frame rate: ', num2str(mov.FrameRate) ]);
    
    

    % *** load mat file for the positions of both background ROI *******
    
    [file_path, file_name, ~] = fileparts(video_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end  

    % check that the video file exists
    
    
    if exist( [file_path, file_name,'_rois.mat'], 'file') ~=2,
        
        disp(' ')
        disp(' ')
        warning( [ 'File ' file_path file_name '_rois.mat' ...
                   ' does not exists. Please start "MEA_ROI_freehand_v04.m" to '...
                   'mark the regions of interest (ROI). This script ended without MEA and preprocessing.'] );
        disp(' ')
        disp(' ')
    else
        
        %
        disp(' ')
        disp('Proceed MEA and all preprocessing steps with default values ...')
        
        
        % file names
        MAT_file_name = [file_path, file_name,'_rois.mat'];
        TXT_file_name_1 = [file_path, file_name,'_MEA_co' num2str(cut_off) '.txt'];
        TXT_file_name_2 = [TXT_file_name_1(1:end-4) '_stand.txt']; 
        TXT_file_name_3 = [TXT_file_name_2(1:end-4) '_vef.txt']; 
        TXT_file_name_4 = [TXT_file_name_3(1:end-4) '_mm.txt']; 
        
        % MEA and pre-processing
        
        MEA_2persons_body_head(video_file_name);
        
        standardize_ROIsize( TXT_file_name_1, MAT_file_name);

        filter_video_errors( TXT_file_name_2 );
    
        moving_median_for_txt_file( TXT_file_name_3 );
        
        log_transformation_for_txt_file( TXT_file_name_4 );

    end % if
    
end % function