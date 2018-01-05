%% written and developed by Désirée Thielemann & Uwe Altmann
%% please cite: Altmann, U. Thielemann, D. et al. (submitted) Introduction, Practical Guide, and Validation Study for Measuring Body Movements Using Motion Energy Analysis


function [TS_new, video_errors] = filter_video_errors_in_TS(TS_old, ...
                        handle_as_split_screen_video, ...
                        cut_off_background, cut_off_body, cut_off_head)
                                    
% This function filter video errors in the given time series. The errors
% are characterized by "strong and short jumps". This function finds such
% jumps, set them to missing and impute the missings.


% TS_old = original time series with video errors = output of
% function motion_energy_analysis.m which produce a matrix with 6 coloumns
% 1. column: ME of patients  body
% 2. column: ME of therapist body
% 3. column: ME of left  noise ROI  (background ROI for patient)
% 4. column: ME of right noise ROI  (background ROI for therapist)
% 5. column: ME of patients  head
% 6. column: ME of therapist head
% Such a matrix is expected as input for this function.

% IMPORTANT: We recommend a linear tranformation using the function 
% standardize_ROIsize.m before running this function (the result is
% that 0 = no motion and 100 = 100% of ROI was activated). Using this
% function before, here a cutoff=25 means 25% of ROI.

%handle_as_split_screen_video = boolean (true / false) which indicate that 
%the corresponding video of the given time series is a split screen, 
%if no split screen, values of patient AND therapist are set to missing 
%value if an error occurred
%if it is a split screen video, then only for one  person the value is set 
%to missing if an error occurred 


% cut_off_background = if the amount of background ROI is lager then this
% cut off, then we expect a video error and set the time series values to
% missing value (normally, in the background ROI is no activity resp. all 
% values are zero for such ROI)
% default is 5

% cut_off_body = we computed the change from t to t+1. if the amount of 
% change at one time point is larger than this cout off value, then the
% time series of BODY movements is set to missing at this time point.
% default is 15

% cut_off_head = we computed the change from t to t+1. if the amount of 
% change at one time point is larger than this cout off value, then the
% time series of HEAD movements is set to missing at this time point.
% default is 25

% TS_new = output with the same size like TS_old; if no video errors occur,
% then the values of TS_new and TS_old are equal; 

% video_errors = matrix with same size like like TS_old; optional output;
% it indicates with zero and ones  at which time point a video error
% occured


% ***********************************************************************
% check input parameter

if nargin < 5,
    cut_off_head = 25;
end

if nargin < 4,
    cut_off_body = 15;
end

if nargin < 3,
    cut_off_background = 5;
end

if nargin < 2,
    handle_as_split_screen_video = false;
end

if nargin < 1,
    error('Input needed: 2 dimensional matrix with 6 columns (output of function motion_energy_analysis.m');
end

s = size(TS_old);
if length(s) ~=2 || s(2) ~=6,
    error('The input parameter TS_old must be a 2 dimensional matrix with 6 columns (output of function motion_energy_analysis.m).')
end


% Set parameters regarding to length of interval with video error
error_interval_length_warning      = 5;

error_interval_length_breaking_off = 8;



% define output matrix
TS_new = TS_old;



% make sure that the cut offs are postive

cut_off_head       = abs( cut_off_head );

cut_off_body       = abs( cut_off_body );

cut_off_background = abs( cut_off_background );





% ***********************************************************************
% check video errors

% define matrix in which the results saved; the columns refer to
% 1. column: ME of patients  body
% 2. column: ME of therapist body
% 3. column: ME of left  noise ROI  (background ROI for patient)
% 4. column: ME of right noise ROI  (background ROI for therapist)
% 5. column: ME of patients  head
% 6. column: ME of therapist head
% "true" indicates that in the corresponding column at the time point under
% study a video error was found. For example: line 2, column 3 = true means
% that at time point 2 in the patient's background ROI (column 3) an error
% was found.
video_errors = false( s );


% check for activity in the background ROI
video_errors( TS_old(:,3) > cut_off_background, 3 ) = true; % left / background patient
video_errors( TS_old(:,4) > cut_off_background, 4 ) = true; % left / background therapist


% check for large INCREASE in BODY ROI 
video_errors( [0; TS_old( 2:end,1) - TS_old( 1:(end-1),1)] > cut_off_body, 1) = true; % patient body movements
video_errors( [0; TS_old( 2:end,2) - TS_old( 1:(end-1),2)] > cut_off_body, 2) = true; % therapist body movements


% check for large DECREASE in BODY ROI 
video_errors( [TS_old( 1:(end-1),1) - TS_old( 2:end,1); 0] > cut_off_body, 1) = true; % patient body movements
video_errors( [TS_old( 1:(end-1),2) - TS_old( 2:end,2); 0] > cut_off_body, 2) = true; % therapist body movements


% check for large INCREASE in HEAD ROI
video_errors( [0; TS_old( 2:end,5) - TS_old( 1:(end-1),5)] > cut_off_head, 5) = true; % patient head movements
video_errors( [0; TS_old( 2:end,6) - TS_old( 1:(end-1),6)] > cut_off_head, 6) = true; % therapist head movements


% check for large DECREASE in HEAD ROI
video_errors( [TS_old( 1:(end-1),5) - TS_old( 2:end,5); 0] > cut_off_head, 5) = true; % patient head movements
video_errors( [TS_old( 1:(end-1),6) - TS_old( 2:end,6); 0] > cut_off_head, 6) = true; % therapist head movements



% ***********************************************************************
% at time points with video erros, set time series values to missing values

% depending on split screen video yes / no
if handle_as_split_screen_video == false,
    
   % if video error found on left or right video side,
   % then set both time series to missing at corresponding time point
   TS_new( video_errors(:,1) == true | ...
           video_errors(:,2) == true | ...
           video_errors(:,3) == true | ...
           video_errors(:,4) == true | ...
           video_errors(:,5) == true | ...
           video_errors(:,6) == true , :) = NaN;
    
else
    
   % separate for the patient side
   TS_new( video_errors(:,1) == true | ...
           video_errors(:,3) == true | ...
           video_errors(:,5) == true , [1 3 5]) = NaN;

   % separate for the therapist side
   TS_new( video_errors(:,2) == true | ...
           video_errors(:,4) == true | ...
           video_errors(:,6) == true , [2 4 6]) = NaN;

end % if



% ***********************************************************************
% check and report length of intervall with video errors

% first find intervalls with video errors and compute begin and end of
% these intervals, 1st column of list_of_intervals indicate with one and
% zero that the corresponding interval is an error or non-error interval

if handle_as_split_screen_video == true,
    
    % for the patient 
    list_of_intervals_p = compute_list_of_intervals( isnan(TS_new(:,1)) ); 

    % for the therapist
    list_of_intervals_t = compute_list_of_intervals( isnan(TS_new(:,2)) );

else 

    % for the patient 
    list_of_intervals_p = compute_list_of_intervals( isnan(TS_new(:,1)) ); 

    % for therapist
    list_of_intervals_t = list_of_intervals_p;
    
    
end % if



% compute the length of error intervals
[~,~,N_intervals_triggers_breaking_off_p, ...
 ~,~,N_intervals_triggers_breaking_off_t ] =    ...
        check_length_of_intervals_with_error( ...
                     list_of_intervals_p, list_of_intervals_t, ...
                     error_interval_length_warning, ...
                     error_interval_length_breaking_off);

% breaking off, if an interval length > error_interval_length_breaking_off
if N_intervals_triggers_breaking_off_p > 0 || N_intervals_triggers_breaking_off_t > 0,

    %error(['The input time series incorporates error intervals with length>', ...
    %      num2str(error_interval_length_breaking_off), '.'] );
    
    beep;
    warning(['The input time series incorporates error intervals with length>', ...
            num2str(error_interval_length_breaking_off), '.'] );

end



% ***********************************************************************
% linear imputation of missing values

% compute number of time points 
N_time_points = length(TS_old(:,1));

% define time vector 
t = (1:N_time_points)';

% imputation columnwise
for c = [1 2 5 6],

    % time points with missings
    cases = isnan( TS_new(:,c) );
    
    % linear interpolation 
    % only the error intervals, all other values were not changed
    % if missings exists ;)
    if sum( cases > 0), 
        TS_new(:,c) = interp1( t(~cases), TS_old(~cases,c), t, 'linear');


        % add some time series-specific noise to avoid detection of artificiell 
        % synchronization (only the error intervals, all other values were not changed)
        random_std = std( TS_old( TS_old(~cases,c)>0, c) ) / 1000; % SD of noise depends on SD of time series

        % we used the absolute amount of random number to aviod negative 
        % motion energy values
        TS_new(:,c) = TS_new(:,c) + ...
            abs(cases.*random('Normal', 0, random_std, N_time_points, 1));
    
    end % if
    
    
end % for



end % function



% ************************************************************************
% ************************************************************************
% sub-function for separation of intervals
function list_of_intervals = compute_list_of_intervals( me_bin )

    % me_bin = input = column vector with binary values (0 = no error, 1 = error
    % at this time point)

    % list_of_intervals = output = list with
    % 1st column: motion interval (0 = no , 1 = yes),
    % 2nd column: interval begin (resp corresponding frame number)
    % 3rd column: interval end   (resp corresponding frame number)

    % convert input into binary vector; if me_bin is not binar, then an
    % error occures
    % me_bin = logical( me_bin );
    
    
    % define output
    list_of_intervals = [];
    
    
    % define time vector
    t = (1:length(me_bin))';

    
    % convert vector into list 
    while ~isempty( me_bin ),

        interval_value = me_bin(1);

        interval_begin = t(1);

        interval_end   = min( t(me_bin ~= interval_value) );

        if isempty( interval_end ),
            interval_end = t(end);
        else
            interval_end = interval_end - 1;
        end


        % add new interval
        list_of_intervals = [list_of_intervals ; ...
                             interval_value interval_begin interval_end ];


        % delete the detected interval from time series
        me_bin( t <= interval_end ) = [];
        t( t <= interval_end ) = [];


    end % while

    
    % delete intervals without error)
    if ~isempty( list_of_intervals ),
        list_of_intervals( list_of_intervals(:,1) == 0, :) = [];
    end
    
end % sub-function



% ************************************************************************
% ************************************************************************
% sub-function for compute and report length of intervals with error
function [N_intervals_ok_p, ...
          N_intervals_triggers_warning_p, ...
          N_intervals_triggers_breaking_off_p, ...
          N_intervals_ok_t, ...
          N_intervals_triggers_warning_t, ...
          N_intervals_triggers_breaking_off_t ] = ...
            check_length_of_intervals_with_error( ...
                 list_of_intervals_p, list_of_intervals_t, ...
                 error_interval_length_warning, ...
                 error_interval_length_breaking_off)
             
    
    % patient / left video side
    if isempty(list_of_intervals_p),
        
        N_intervals_ok_p = 0;
        N_intervals_triggers_warning_p = 0;
        N_intervals_triggers_breaking_off_p = 0;
        
    else
 
        % Length Of Intervals 
        loi = list_of_intervals_p(:,3)-list_of_intervals_p(:,2) + 1; 
        
        
        N_intervals_ok_p               = ...
            sum( (loi >  0) & ...
                 (loi <= error_interval_length_warning) );

        N_intervals_triggers_warning_p = ...
            sum( (loi >  error_interval_length_warning) & ...
                 (loi <= error_interval_length_breaking_off  ) );

        N_intervals_triggers_breaking_off_p = ...
            sum( (loi >  error_interval_length_breaking_off  ) );

    end
    
    
    % therapist / right video side
    if isempty(list_of_intervals_t),
        
        N_intervals_ok_t = 0;
        N_intervals_triggers_warning_t = 0;
        N_intervals_triggers_breaking_off_t = 0;
        
    else

        % Length Of Intervals 
        loi = list_of_intervals_p(:,3)-list_of_intervals_p(:,2) + 1; 
        
        N_intervals_ok_t               = ...
            sum( (loi >  0) & ...
                 (loi <= error_interval_length_warning) );

        N_intervals_triggers_warning_t = ...
            sum( (loi >  error_interval_length_warning) & ...
                 (loi <= error_interval_length_breaking_off  ) );

        N_intervals_triggers_breaking_off_t = ...
            sum( (loi >  error_interval_length_breaking_off  ) );

    end
    

    % reporting
    disp('Report about the length of intervals with video errors (PATIENT / left video side):')
    disp(['Number of intervals with length 1<= ... <=', ...
        num2str(error_interval_length_warning), ': ', ...
        num2str( N_intervals_ok_p ) ]);

    disp(['Number of intervals with length 5<  ... <=', ...
        num2str(error_interval_length_breaking_off), ': ', ...
        num2str( N_intervals_triggers_warning_p ) ]);

    disp(['Number of intervals with length          <', ...
        num2str(error_interval_length_breaking_off), ': ', ...
        num2str( N_intervals_triggers_breaking_off_p ) ]);

    disp(' ');

    disp('Report about the length of intervals with video errors (THERAPIST / right video side):')
    disp(['Number of intervals with length 1<= ... <=', ...
        num2str(error_interval_length_warning), ': ', ...
        num2str( N_intervals_ok_t ) ]);

    disp(['Number of intervals with length 5<  ... <=', ...
        num2str(error_interval_length_breaking_off), ': ', ...
        num2str( N_intervals_triggers_warning_t ) ]);

    disp(['Number of intervals with length          <', ...
        num2str(error_interval_length_breaking_off), ': ', ...
        num2str( N_intervals_triggers_breaking_off_t ) ]);

    
end % sub-function