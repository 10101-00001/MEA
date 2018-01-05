%% written and developed by Désirée Thielemann 
%% please cite: Altmann, U. Thielemann, D. et al. (submitted) Introduction, Practical Guide, and Validation Study for Measuring Body Movements Using Motion Energy Analysis


%Matlab script for computing cut-off value for changes in intensity
%data driven

function [] = MEA_cut_off(workingDir, numberFrames);

% please set a working directory in which your video files are stored
% video files has to be in .avi format

    % check input arguments: working directory? If no, select with file browser
    if nargin<1,

        disp('No working directory was set, please select one:');
        workingDir = uigetdir;
        
        [pathstr, name, ext] = fileparts(workingDir);

    else
        
        [pathstr, name, ext] = fileparts(workingDir);
        
    end

    if nargin<2,
        numberFrames = 15000;
        disp('Parameter number of frames is missing. On that reason');
        disp('MEA is analysed for the first 15000 frames. ');
    end

    
cd(workingDir); 
mkdir(workingDir,'MEA_Cut-off');

videoNames = dir(fullfile(workingDir,'*.avi'));
videoNames = {videoNames.name}';

h = waitbar(0,'Analysing Motion-Energy - Please wait...', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');    
setappdata(h,'canceling',0)
for g = 1:length(videoNames)
              % Check for Cancel button press
            if getappdata(h,'canceling')
                 break
            end
    % Load video file
    mov=VideoReader(fullfile(workingDir,videoNames{g}));
    numberOfFrames = mov.NumberOfFrames;
    

    % define empthy array for cutoff computation
    diff = [];
    diff_all=[];
    frame=[];
    
    %Load first frame of Video
    frame_1 = rgb2gray(read(mov,1));    
 
    % get length of video in frames
    length_of_video = mov.numberOfFrames;

    numberFrames2=numberFrames;
    
    % Calculate number of frames for which video should be analysed
    if length_of_video < numberFrames2,

        disp(['Video is not ', num2str(numberFrames), ...
              ' long - calculation will be based on ',...
              num2str(length_of_video), ' frames']);

        numberFrames2 = length_of_video;

    end
   
   
	for frame = 2 : numberFrames2
        
		% Extract the frame from the movie structure.
	        frame_2 = rgb2gray(read(mov, frame));
                
               diff_frame=[];
               diff_frame = imabsdiff(frame_1, frame_2);
               
                for pixel = 1:5
                    diff(frame,pixel) = diff_frame(10+pixel,10+pixel);
                    diff(frame,pixel+5) = diff_frame(20+pixel,200+pixel);
                    diff(frame,pixel+10) = diff_frame(10+pixel,400+pixel);
                    diff(frame,pixel+15) = diff_frame(20+pixel,600+pixel);
                    diff(frame,pixel+20) = diff_frame(150+pixel,600+pixel);
                    diff(frame,pixel+25) = diff_frame(150+pixel,10+pixel);
                end
                
         frame_1 = frame_2;
    end
   
   
   filename = ['MEA_Cutoff_' videoNames{g} '.txt']; 
   dlmwrite((fullfile(workingDir,'MEA_Cut-off',filename)), diff); %Adjust
   waitbar(g / length(videoNames))     
end
 delete(h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate some statistics for estimation of Cut-off value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('MEA_Cut-off'); 

meaNames = dir(fullfile(workingDir,'MEA_cut-off','*.txt'));
meaNames = {meaNames.name}';
     max_value=[];
     quant95=[];
     quant99=[];
     quant_max=[];
     data_all=[];

%Merge noise data from all videos to one dataset     
     for k = 1:length(meaNames)
         data=dlmread(fullfile(workingDir,'MEA_cut-off',meaNames{k}));
         max_value(k,1:30)=max(data);
         quant95(k,1:30) = quantile(data,0.95);
         quant99(k,1:30) = quantile(data,0.99);
         quant_max(k,1) = max(quantile(data,0.95));
         quant_max(k,2) = max(quantile(data,0.99));
         data_all=[data_all;data];      
     end

 %Calculate maximal values for intensity change in background pixel
 %Calculate 0.95 and 0.99 quantile for intensity change

     max_value_all=max(data_all);
     quant95_all = quantile(data_all,0.95);
     quant99_all = quantile(data_all,0.99);
     quant_max_all = [max(quantile(data_all,0.95)),max(quantile(data_all,0.99))];
 
 %Check quantile_cutoff.txt for 0.95 quantile and 0.99 quantile of
 %intensity change --> Set Cut-off for 0.99 quantile
     fid = fopen('quantile_cutoff.txt','wt');
     fprintf(fid,'Results of data driven estimation of cut-off values for intensity differences in background \n')
     fprintf(fid,'Intensity change cut-off for 0.95 quantile is %.0f and for 0.99 quantile is %.0f.', quant_max_all(1,1), quant_max_all(1,2));
     fclose(fid);
     
     cd ..;
     
end
