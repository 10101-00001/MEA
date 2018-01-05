%% writen and developed by Désirée Thielemann 
%% please cite: Altmann, U. Thielemann, D. et al. (submitted) Introduction, Practical Guide, and Validation Study for Measuring Body Movements Using Motion Energy Analysis


function []=check_video_for_cutoff(videoNames);

  % check input arguments: file name? If no, select with file browser
    if nargin<1 || length(videoNames) == 0 ,

        disp('No video file name was given, please select one:');
        [videoNames pathstr] = uigetfile('*.avi');
        
        [leer, name, ext] = fileparts(videoNames);

    else
        
        [pathstr, name, ext] = fileparts(videoNames);
        
    end
    
    clear leer ext;
    
     if exist([pathstr, name,'_rois.mat']) == 2

        % Load ROIs from file
        roi1=load([pathstr, name,'_rois.mat'], 'roi1');
        roi2=load([pathstr,  name,'_rois.mat'], 'roi2');
        roi5=load([pathstr,  name,'_rois.mat'], 'roi5');
        roi6=load([pathstr,  name,'_rois.mat'], 'roi6');

        roi1=roi1.roi1;
        roi2=roi2.roi2;
        roi5=roi5.roi5;
        roi6=roi6.roi6;

    else

        error('ROI File does not exist - Please draw ROI first! Please use the MATLAB function MEA_ROI_freehand.m');

     end
 
    % check for overlap
    
    roi7 = [ 11 11 16 16 ]; % ROI coordinates
    x=[roi7(2), roi7(4), roi7(4), roi7(2)];
    y=[roi7(1), roi7(1), roi7(3), roi7(3)];
    roi7mask = poly2mask(x, y, 480,640); 
    roi7 = uint8(roi7mask);
    
    roi8 = [ 21 201 26 206 ]; % ROI coordinates
    x=[roi8(2), roi8(4), roi8(4), roi8(2)];
    y=[roi8(1), roi8(1), roi8(3), roi8(3)];
    roi8mask = poly2mask(x, y, 480,640); 
    roi8 = uint8(roi8mask);
 
    roi9 = [ 11 401 16 406 ]; % ROI coordinates
    x=[roi9(2), roi9(4), roi9(4), roi9(2)];
    y=[roi9(1), roi9(1), roi9(3), roi9(3)];
    roi9mask = poly2mask(x, y, 480,640); 
    roi9 = uint8(roi9mask);
    
    roi10 = [ 21 601 26 606 ]; % ROI coordinates
    x=[roi10(2), roi10(4), roi10(4), roi10(2)];
    y=[roi10(1), roi10(1), roi10(3), roi10(3)];
    roi10mask = poly2mask(x, y, 480,640); 
    roi10 = uint8(roi10mask);

    roi11 = [ 151 601 156 606 ]; % ROI coordinates
    x=[roi11(2), roi11(4), roi11(4), roi11(2)];
    y=[roi11(1), roi11(1), roi11(3), roi11(3)];
    roi11mask = poly2mask(x, y, 480,640); 
    roi11 = uint8(roi11mask);

    roi12 = [ 151 11 156 16 ]; % ROI coordinates
    x=[roi12(2), roi12(4), roi12(4), roi12(2)];
    y=[roi12(1), roi12(1), roi12(3), roi12(3)];
    roi12mask = poly2mask(x, y, 480,640); 
    roi12 = uint8(roi12mask);
    
    
    % overlap of body ROI with upper background ROI 
    % measured by number of pixels whereby 0 = no overlap.
    % Remember, positions of background ROI were defined above
    add__body = sum( sum( (roi1+roi2+roi7+roi8+roi9+roi10+roi11+roi12) > 1 ) ); 
    
    % check for overlap of noise ROI with body and head ROI
    if     (add__body ~= 0 ),
        error([num2str(name), '- Chose other file - background pixels are influenced by movement.']);
    else
        disp('Video can be used for threshold computation.')
    end
     
end
    