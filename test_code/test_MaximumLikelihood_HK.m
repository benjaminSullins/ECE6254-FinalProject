% ECE 6254: Statistical Machine Learning
% Benjamin Sullins
% GTID: 903232988
% Distance Learning Student
% School of Electrical and Computer Engineering 
% Georgia Instiute of Technology 
%
% Final Project
% Missile/Drone Tracking
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date Modified : 2/5/2017 - Ben Sullins
% - Initial design implementation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References
% ----
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Routine Maintenance
clear;
close all;
% clc;

addpath( strcat( fileparts(pwd), '\matlab\code'  ) );

%% Load Image

% Manual Image Selection
% path = strcat( fileparts(pwd), '\images');
% [filename,filepath] = uigetfile(fullfile(path , '*'), 'Select an Image');

% Auto Image Selection
filepath = strcat( fileparts(pwd), '\matlab\images\');
filename = 'cloud1.jpg';

fprintf('Loading Input Image: %s \n', filename);
benchmarkImage = loadImage( strcat(filepath, filename)  );

%% Initialization
% Program init functions and corresponding variables.
[frameInfo.vlin frameInfo.vpix] = size(benchmarkImage);
frameInfo.numBits               = ceil(log2(max(max(benchmarkImage))));

% Clutter Characteristics
clutterInfo.mean     =  64;
clutterInfo.variance =  0.2;

% Target Characteristics
targetInfo.sizeX =  64;
targetInfo.sizeY =  64;
targetInfo.mean  = 200;
targetInfo.stdX  =  16;
targetInfo.stdY  =  16;

% Target Movement Characteristics
targetLocationInfo.x      = frameInfo.vpix / 2;
targetLocationInfo.y      = frameInfo.vlin / 2;
targetLocationInfo.speedX = 10;
targetLocationInfo.speedY = 10;

% Display Settings
displayInfo.numFrames   = 100;
plotlocation.x          = frameInfo.vpix / 2;
plotlocation.y          = frameInfo.vlin / 2;

figure('Name','Missile/Drone Tracking Example','NumberTitle','off');
colorbar;

%% Generate Clutter
% Begin by generating a background based on a weighted Power Spectrum
% Distribution (PSD) of a collection of reference frames. These reference
% frames provide the cornerstone of the underlying clutter.
% 
% Notes: As we progress through the project, we will develop a better model
% of what clutter really is. This would use the PSD of reference images
% found online. For now, just generate a gaussian noise image using the
% parameters in the init.
% [ clutterImage ] = genClutter( frameInfo, clutterInfo );

clutterImage = benchmarkImage;

%% Generate Target
% The target can be classified by generic distributions. These will also be
% developed as we  enhance our algorithms. For now, just generate a
% gaussian target with the parameters above.
[ targetImage ] = genTarget( frameInfo, targetInfo );
mle_top = [];
mle_bottom = [];
mle_left = [];
mle_right = [];
mle_image_thresh=[];
mle_data = [];
% This loop creates a "video" like representation with each frame being
% generated on the fly.
delta_data = [0,0,0,0];
updatedLocations.x = 0;
updatedLocations.y = 0;
for frameNumber = 1 : displayInfo.numFrames

    %% Add Target Movement
    % This function adds movement to the target within in the frame. We can
    % modify this function to add specific movement patterns which reflect
    % that of an actual target. For now, just generate some random
    % patterns.
    prev_targetLocation.x = updatedLocations.x;
    prev_targetLocation.y = updatedLocations.y;
    [ targetMovImage, updatedLocations] = moveTarget( frameInfo, targetImage, targetLocationInfo );
    
%     imshow(targetMovImage)
    % Lowpass the location movements so it doesnt look so crazy
    % Lowpassing the target locations can be done to give the targets a
    % more "organic" movement quality to them.
    targetLocationInfo.x = updatedLocations.x;
    targetLocationInfo.y = updatedLocations.y;
    
    %% Frame Combining
    % Adding all the frames correctly is a little more complicated than
    % what's shown. Nothing too bad, but for now just add away.
    finalImage = clutterImage + targetMovImage;

    %% Target Analysis
    % This would be the meat and potatoes. We'd be taking a stab at
    % understanding the underlying distributions for the target.
    % Effectively, we'd be disseminating between what is or isn't a target
    % (binomial for now). We can enhance this as we progress.


    %% Target Tracking
    % Next, after finding the target, we'd like to understand what kind of
    % offset is attributed to the targets motion from the previous frame.
    % This offset tells the next frame where to place our location
    % estimates to perform "tracking".
    
    [ top, left, right, bottom, target,imageOverlay] = MLE_AcquireRegions_HK( finalImage, frameInfo, targetInfo, targetLocationInfo);
    [phat,image_thresh]=MLE_HK( top, left, right, bottom, target);
%     mle_top = [mle_top;phat_top];
%     mle_bottom = [mle_bottom;phat_bottom];
%     mle_left = [mle_left;phat_left];
%     mle_right = [mle_right;phat_right];
%     mle_data
    mle_data = [mle_data;phat];
    mle_image_thresh=[mle_image_thresh;image_thresh];
%     mle_top = phat_top(1);
%     mle_bottom = phat_bottom(1);
%     mle_left = phat_left(1);
%     mle_right = phat_right(1);
    %% Fix the target tracking using the MLE threshold

    %% Future Target Location Estimation
    % Temporal estimation techniques (extended kalman filters) can be used
    % to improve the tracking performance.

    %% Display Image
    % Finally, just display the image so that the user has some
    % understanding of what is going on. Im invisioning having a "truth"
    % and an "actual" target location to help give some quality metrics on
    % how we are performing. We can also throw in some other goodness if we
    % want. 
    
    % Update location for plotting
    plotlocation.x = [plotlocation.x, targetLocationInfo.x];
    plotlocation.y = [plotlocation.y, targetLocationInfo.y];
     
    % subplot(2,2,[1,3]);
    fig = imshow( imageOverlay, [] );
    
    % imagesc( finalImage );
    title(sprintf('Frame: %d of %d', frameNumber, displayInfo.numFrames));
    cd 'E:\ece6254 project\ECE6254-FinalProject-master\test_code\frames\frame2'
    saveas(fig,['Frame_' num2str(frameNumber) '.png']) 
    cd 'E:\ece6254 project\ECE6254-FinalProject-master\test_code'
    %subplot(2,2,2);
    %plot( plotlocation.x );
    %title(sprintf('X Location & Performance'));
    
    %subplot(2,2,4);
    %plot( plotlocation.y );
    %title(sprintf('Y Location & Performance'));
    
    drawnow;

end






