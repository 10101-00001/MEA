%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)

% this script load a tab spaced file with motion energy time series and
% applies a moving median on each time series. 

% Input parameter
% TXT_file_name: string with directory anf file name of TXT file 
% bandwidth: window width of moving median (number of neighboring values
% which used to compute a local median; default is 5)

function [] = moving_median_for_txt_file( TXT_file_name, bandwidth )

    % check input parameter: TXT file
    if nargin < 1,
        
        disp(' ')
        disp('Please choose the TXT file with standardized motion energy time series (output of the script standardize_ROIsize.m).');
        
        [filename, PathName, ~] = uigetfile('*.txt');
    
        TXT_file_name = [PathName filename];  
    else
        % check that the video file exists
        if exist(TXT_file_name, 'file') ~=2,

            error( [ 'File with time series (', TXT_file_name, ') does not exists.'] );

        end
    end  
    
    
    
    % check input papramert: bandwidth
    if nargin < 2,
        bandwidth = 5 ; % bandwidth 
        
        disp(' ')
        disp(['No value for parameter bandwidth is given. Default value (', ...
             num2str(bandwidth), ') is used.']);
    end


    if bandwidth / 2 == ceil(bandwidth / 2),
        bandwidth = bandwidth + 1;
        disp(' ')
        disp(['Parameter bandwidth must be a uneven number. Is is changed to ', ...
              num2str(bandwidth)]);
    end
    
    
    % load time series and ROI size
    disp(' ')
    disp(['Load TXT file with standardized motion enery time series: ' TXT_file_name]);
    
    data = dlmread( TXT_file_name );
    
    
    
    % check dimensions of data matrix
    data_size = size( data );
    
    if length( data_size ) ~= 2 || data_size(2)~=6, 
        error('The TXT file should contain a two dimensional matrix with 6 columns.')
    end
    
    
    
    % apply moving median on each column / time series
    disp(' ')
    disp('Apply moving median on time series.') 
        
    data_new = zeros( size(data) );
    
    data_new(:,1) = moving_median( data(:,1), bandwidth );
    data_new(:,2) = moving_median( data(:,2), bandwidth );
    data_new(:,3) = moving_median( data(:,3), bandwidth );
    data_new(:,4) = moving_median( data(:,4), bandwidth );
    data_new(:,5) = moving_median( data(:,5), bandwidth );
    data_new(:,6) = moving_median( data(:,6), bandwidth );
    
    
    % save results
    [file_path, file_name, ~] = fileparts(TXT_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end
    
    disp(' ');
    disp(['Save motion energy time series (which smoothed by moving median) in the tab-spaced *.txt file: ', ...
          file_path, file_name, '_mm.txt'])
      
    dlmwrite([file_path, file_name, '_mm.txt'], data_new, '\t');       

end



%% *********************************************************************
% sub-function

function [mm] = moving_median( me, bandwidth )

    % length of original time series
    N_steps = length(me);


    % add first measurement point and last measurment poist, so that the moving 
    % median can be computed also for the real first element and for real last
    % element.
    me= [  me( (floor(bandwidth/2):-1:1)' ,1 ) ; me ; me( end:-1:(length(me)-ceil(bandwidth/2))' ,1 ) ];


    % position within the window (the middle)
    pos = ceil(bandwidth/2); 

    % compute median step by step
    for n=1:N_steps,

       time_series_part = sort(me( n:n+bandwidth-1, 1));

       mm(n,1) = time_series_part(pos);

    end
end