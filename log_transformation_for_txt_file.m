%% writen and developed by Uwe Altmann and Désirée Schönherr (née Thielemann)

% this script load a tab spaced file with motion energy time series and
% applies a logarithmic transformation on each time series. 

% Input parameter
% TXT_file_name: string with directory anf file name of TXT file 

function [] = log_transformation_for_txt_file( TXT_file_name )

    % check input parameter: TXT file
    if nargin < 1,
        
        disp(' ')
        disp('Please choose the TXT file with motion energy time series.');
        
        [filename, PathName, ~] = uigetfile('*.txt');
    
        TXT_file_name = [PathName filename];  
    else
        % check that the video file exists
        if exist(TXT_file_name, 'file') ~=2,

            error( [ 'File with time series (', TXT_file_name, ') does not exists.'] );

        end
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
    
    
    % check value range of time series
    number_of_negative_values = [ sum( data(:,1) < 0 ) ...
                                  sum( data(:,2) < 0 ) ...
                                  sum( data(:,3) < 0 ) ...
                                  sum( data(:,4) < 0 ) ...
                                  sum( data(:,5) < 0 ) ...
                                  sum( data(:,6) < 0 ) ];
    
    if number_of_negative_values(1) > 0,
        
        error(['Negative values (' num2str(number_of_negative_values(1)) ...
               ' of ' num2str(data_size(1)) ...
               ') found in column 1 (body patient).'])
    
    end
                              
    
    if number_of_negative_values(2) > 0,
        
        error(['Negative values (' num2str(number_of_negative_values(2)) ...
               ' of ' num2str(data_size(1)) ...
               ') found in column 2 (body patient).'])
    
    end
    
    
    if number_of_negative_values(3) > 0,
        
        warning(['Negative values (' num2str(number_of_negative_values(3)) ...
               ' of ' num2str(data_size(2)) ...
               ') found in column 3 (background ROI left).'])
    
    end
    
    
    if number_of_negative_values(4) > 0,
        
        warning(['Negative values (' num2str(number_of_negative_values(4)) ...
               ' of ' num2str(data_size(1)) ...
               ') found in column 4 (background ROI right).'])
    
    end
    
    
    if number_of_negative_values(5) > 0,
        
        error(['Negative values (' num2str(number_of_negative_values(5)) ...
               ' of ' num2str(data_size(1)) ...
               ') found in column 5 (head patient).'])
    
    end
    
    
    if number_of_negative_values(6) > 0,
        
        error(['Negative values (' num2str(number_of_negative_values(6)) ...
               ' of ' num2str(data_size(1)) ...
               ') found in column 6 (head patient).'])
    
    end
    
                              
    % apply moving median on each column / time series
    disp(' ')
    disp('Apply log transformation on time series.') 
        
    data_new = zeros( size(data) );
    
    data_new(:,1) = log( data(:,1) + 1 );
    data_new(:,2) = log( data(:,2) + 1 );
    data_new(:,3) = log( data(:,3) + 1 );
    data_new(:,4) = log( data(:,4) + 1 );
    data_new(:,5) = log( data(:,5) + 1 );
    data_new(:,6) = log( data(:,6) + 1 );
    
    
    % save results
    [file_path, file_name, ~] = fileparts(TXT_file_name);
    
    if file_path(end) ~= '\',
        file_path = [ file_path '\'];
    end
    
    disp(' ');
    disp(['Save log transformed time series in the tab-spaced *.txt file: ', ...
          file_path, file_name, '_lt.txt'])
      
    dlmwrite([file_path, file_name, '_lt.txt'], data_new, '\t');       

end
