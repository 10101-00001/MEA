% The script standardize the motion energy time series of txt file with the
% size of ROI, so that the value rang is 0 to 100. 0 means no motion at
% time point t and 100 means all pixel of the ROI were acitiveted (maximal
% movement intensity).

% This script load a txt file which is the output of the script
% MEA_2persons_body_head.m Furthermore it load the corresponding *mat file
% in which the ROI respectively the size of ROI is saved. 

% Output of the script is a matrix which size and sturtur is equal to the
% input matrix storred in the txt file.


%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)

function [] = standardize_ROIsize( TXT_file_name, MAT_file_name)

    %% ********************************************************************
    % check input arguments: Name of MEA time series
    % MEA time series has to have 6 columns: patient upper body, therapist
    % upper body, background_roi1, background_roi2, patient_head,
    % therapist_head

    if nargin < 1,
        
        disp(' ')
        disp('Please choose the TXT file with MEA time series (output of the script MEA_2persons_body_head.m).');
        
        [filename, PathName, ~] = uigetfile('*.txt');
    
        TXT_file_name = [PathName filename];  
    end


    %% ********************************************************************
    % load time series and ROI size
    
    disp(' ')
    disp(['Load TXT file with motion enery time series: ' TXT_file_name]);
    
    data = dlmread( TXT_file_name );
    
    
    %% ********************************************************************
    % *.mat file with ROI information
    
    if nargin < 2,
        
        disp(' ')
        disp('Please choose the MAT file with ROI information (output of the script MEA_ROI_freehand_v04.m).');
        
        [filename, PathName, ~] = uigetfile('*.mat');
    
        MAT_file_name = [PathName filename];  
        
    else
        % check that the video file exists
        if exist(MAT_file_name, 'file') ~=2,

            error( [ 'File with ROI information (', MAT_file_name, ') does not exists. Please start "MEA_ROI_freehand_v04.m" to mark the regions of interest (ROI). Then run this script again.'] );

        end
    end
    
    disp(' ')
    disp(['Load MAT file: ' MAT_file_name '_rois.mat' ]);
    
    load( MAT_file_name, '-mat');




    %% ********************************************************************
    % compute size of all ROI and store the values in a vector

    size_of_all_ROI = [ sum(sum(roi1)); ...
                        sum(sum(roi2)); ...
                        sum(sum(roi3)); ...
                        sum(sum(roi4)); ...
                        sum(sum(roi5)); ...
                        sum(sum(roi6)) ];

                    
    %% ********************************************************************
    % Compute standardized values on ROI size 
    % equation: new = old / ROI_size * 100
    % 100% means that whole ROI area changed, 0% corresponds to no motion
    
    disp(' ')
    disp('Proceed standardization of time series.')
    
    data_st = zeros( size(data) );
    
    for g = 1:6,
        data_st(:,g) = data(:,g) / size_of_all_ROI(g) * 100;
    end
    
    
    
    %% ********************************************************************
    % save results
    
    [file_path, file_name, ~] = fileparts(TXT_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end
    
    disp(' ');
    disp(['Save standardized motion energy time series in the tab-spaced *.txt file: ', ...
          file_path, file_name, '_stand.txt'])
      
    dlmwrite([file_path, file_name, '_stand.txt'], data_st, '\t');

end