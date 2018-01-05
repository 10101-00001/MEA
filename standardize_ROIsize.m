%% writen and developed by Désirée Thielemann 
%% please cite: Altmann, U. Thielemann, D. et al. (submitted) Introduction, Practical Guide, and Validation Study for Measuring Body Movements Using Motion Energy Analysis


function[data_st] = standardize_ROIsize(Names, ROIsize)
    %standardize

    % check input arguments: Name of MEA_timeseries and ROI size file given?
    % MEA time series has to have 6 columns: patient upper body, therapist
    % upper body, background_roi1, background_roi2, patient_head,
    % therapist_head
    
    if nargin<2,
        disp('ROI size file not given.');
         disp('Plese choose working directory.');
        pathstr_ROI = uigetdir;
            disp('Plese choose ROI size file.');
        ROI_size = uigetfile('.mat');
        [leer, name_ROI, ext_ROI]=fileparts(ROI_size);
    else
        [pathstr_ROI, name_ROI, ext_ROI] = fileparts(ROIsize);
    end
    
    if nargin<1,
        disp('MEA time series not given.');
        disp('Plese choose working directory.');
        pathstr = uigetdir;
        disp('Plese choose MEA time series. MEA time series has to have 6 columns.');
        name_MEA = uigetfile('.txt');
        [leer, name, ext]=fileparts(name_MEA);     
    else
        [pathstr, name, ext] = fileparts(Names);
    end

    
  %%%%%%%%%%%%%%%%%%%%%make folder for results & check if existing
  
  % Output directory name
pathstr_results= ['MEA_', datestr(now, 'yyyy-mm-dd'), '_standardized'];


% Check if output directory of MEA already exists
if exist(pathstr_results) == 7 & exist([pathstr_results, '_new']) ~=7
    cd(pathstr_results);
    % Check if output file in folder already exists
    if exist([name,'_stand.txt']) == 2
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
    else
        cd ..;
    end
else
   mkdir(pathstr_results) 
end 


if exist(pathstr_results) == 7 & exist([pathstr_results, '_new']) == 7
    cd([pathstr_results, '_new']);
    if exist([name,'_stand.txt']) ~= 2
        pathstr_results=[pathstr_results, '_new'];
        cd ..;
    end
    if exist([name,'_stand.txt']) == 2
        cd ..;
        error('Analysis has been twice done before - Copy existing folder in another folder or delete it.')
    end   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute standardized values on ROI size 
% 100% means that whole ROI area changed
    
    data=dlmread([pathstr, '\', name, ext]);
    load([pathstr_ROI,'\', name_ROI, ext_ROI]);
    size=[sum(sum(roi1)); sum(sum(roi2));sum(sum(roi3));sum(sum(roi4));sum(sum(roi5));sum(sum(roi6));];

        for g=1:6
        data_st(:,g)=data(:,g)/size(g,1)*100;
        end
 
    dlmwrite([pathstr,'\', pathstr_results, '\' ,name,'_stand.txt'], data_st, '\t');

end