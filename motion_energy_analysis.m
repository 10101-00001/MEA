%% written and developed by Uwe Altmann
%% please cite: Altmann, U. (2013). Synchronisation nonverbalen Verhaltens. Wiesbaden: VS Springer. ISBN 978-3-531-19815-6


function [me] = motion_energy_analysis(videoNames, cut_off, numberFrames)

    % Before you run this script, please start "MEA_ROI_freehand.m"
    % to mark the regions of interest (ROI) which should be analysed.
    % Output file of "MEA_ROI_freehand.m" is 
    % required to run this script without errors.
    

    % check input arguments: time? If no, set default of 15min for 25fps
    if nargin<3,
        numberFrames = 22501;
        disp('Parameter number of frames is missing. On that reason');
        disp('MEA is analysed for the first 22501 frames ');
        disp('default, 15 min with 25fps + 1 frame = 22501 frames).');
    end


    % check input arguments: cutoff? If no, set default
    % the cutoff refers to the difference of gray intensity of one pixel
    % in frame t and the corresponding pixel in video fram t+1
    if nargin<2,
        cut_off = 15; % this must be an integer
        disp(['MEA cut off was set to default (', ...
              num2str(cut_off), ...
              ') because no value was transfered.']);
    end


    % check input arguments: file name? If no, select with file browser
    if nargin<1 || isempty(videoNames) ,

        disp('No video file name was given, please select one:');
        [videoNames, pathstr] = uigetfile('*.avi');
        
        [~, name, ext] = fileparts(videoNames);

    else
        
        [pathstr, name, ext] = fileparts(videoNames);
        
    end
    
    clear leer;
    
    
    % check that the video file exists
    if exist([pathstr, '\', name, ext], 'file') ~=2,
        
        error( [ 'File ', videoNames, ' does not exists.'] );
        
    end

    
    % Check if .mat File with ROIs is in folder (output of the script 
    % MEA_ROI_freehand.m)
    if exist([pathstr, '\', name,'_rois.mat']) == 2

        % Load ROIs from file
        roi1=load([pathstr,'\', name,'_rois.mat'], 'roi1');
        roi3=load([pathstr,'\', name,'_rois.mat'], 'roi3');
        roi4=load([pathstr,'\', name,'_rois.mat'], 'roi4');

        roi1=roi1.roi1;
        roi3=roi3.roi3;
        roi4=roi4.roi4;

    else

        error('ROI File does not exist - Please draw ROI first! Please use the MATLAB function MEA_ROI_freehand.m');

    end

    % Output directory name
    pathstr_results= ['MEA_', datestr(now, 'yyyy-mm-dd'), '_co', num2str(cut_off)];


    % Check if output directory of MEA already exists
    if exist(pathstr_results) == 7 && exist([pathstr_results, '_new']) ~=7
        cd(pathstr_results);
        % Check if output file in folder already exists
        if exist([name,'_MEA.txt']) == 2
            cd ..;
            warning('Analysis has been done before! - Rename folder using dialog box to continue analysis')
            disp('In case of renaming: _new will be added to the folder name')
            % Construct a questdlg with three options
            choice = questdlg('Do you want to rename the folder?', ...
                'Output directory already exists');
            % Handle response
            switch choice
                case 'Yes'              
                    % Construct a new filename.
                    pathstr_results = sprintf([pathstr_results,'_new']);
                    mkdir(pathstr_results);
                case 'No'
                    error(['Output directory ', pathstr_results, ...
                        ' already exists.' char(10) 'Copy existing folder in another folder or delete it.']);
                case 'Cancel'
                    error(['Output directory ', pathstr_results, ...
                        ' already exists.' char(10) 'Copy existing folder in another folder or delete it.']);
            end 
        end
    else
       mkdir([pathstr, '\', pathstr_results]) ;
    end 


    if exist(pathstr_results) == 7 && exist([pathstr_results, '_new']) == 7
        cd([pathstr_results, '_new']);
        if exist([name,'_MEA.txt']) ~= 2
            pathstr_results=[pathstr_results, '_new'];
        end
        if exist([name,'_MEA.txt']) == 2
            error('Analysis has been twice done before - Copy existing folder in another folder or delete it.')
        end   
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % --- Motion Energy Analysis ---


    % load video resp. Create object to read video files
    mov = VideoReader([pathstr, '\', name, ext]);  


    % get length of video in frames
    length_of_video = mov.numberOfFrames;


    % Calculate number of frames for which video should be analysed
    if length_of_video < numberFrames,

        disp(['Video is not ', num2str(numberFrames), ...
              ' long - calculation will be based on ',...
              num2str(length_of_video), ' frames']);

        numberFrames = length_of_video;

    end


    % define empthy array for motion energy
    % 1. column: ME of left person upper body
    % 2. column: ME of right person upper body
    % 3. column: ME of left noise ROI
    % 4. column: ME of right noise ROI
    % 5. column: ME of left person head
    % 6. column: ME of right person head
    % 7. column: ME of left person entire body
    % 8. column: ME of right person entire body
    % the line refer to the video frame, in line 23 for example are the 
    % motion energy values saved which computed with frame 23 and 24.
    me      = [];

    
    % read the first frame
    frame_1 = rgb2gray(read(mov,1));  

    
    % compute for each frame pair the difference and based on it the ME
    for frame = 2 : numberFrames,

        % Extract the frame from the movie structure
        frame_2 = rgb2gray(read(mov, frame));

        % ROI for left person body, and ROI for right person body
        % 2-D median filter is used
        me(frame-1,1) = sum( sum( medfilt2( imabsdiff( ...
                        frame_1.*roi1, frame_2.*roi1 ),[5 5]) > cut_off ) ) ;

        %ROI for checking background noise 
        me(frame-1,3) = sum( sum( imabsdiff( ...
                        frame_1.*roi3, frame_2.*roi3 ) > cut_off ) ) ;
        me(frame-1,4) = sum( sum( imabsdiff( ...
                        frame_1.*roi4, frame_2.*roi4 ) > cut_off ) ) ;

        frame_1 = frame_2;
    end
  
    % SAVE: ME time series to .txt file
    dlmwrite([pathstr, '\', pathstr_results, '\' , name,'_MEA.txt'], me, '\t'); 
    
end