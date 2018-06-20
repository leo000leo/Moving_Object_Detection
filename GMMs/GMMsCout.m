function GMMsCout()
% Create System objects used for reading video, detecting moving objects,
% and displaying the results.
obj = setupSystemObjects();

% counter initialize
k = 1; 
front = 1; 
lgh = 0;
% Detect moving objects, and track them across video frames.
while ~isDone(obj.reader)
    frame = readFrame();
    [~, ~, mask] = detectObjects(frame);
    
    [~, ~, bboxes] = obj.blobAnalyser.step(mask);
    %bboxes = step(obj.blobAnalyser, mask);

    % Draw bounding boxes around the detected cars
    %result = insertShape(frame, 'Rectangle', bboxes, 'Color', 'green');

    % Display the number of cars found in the video frame
    nums = size(bboxes, 1);
%     frame = insertText(result, [10 10], nums, 'BoxOpacity', 1, ...
%         'FontSize', 14);
    displayTrackingResults();
    
    %counter the Frame 
    if(nums>0) 
        lgh = lgh +1;
    else
        if(lgh>0) 
            disp(strcat(num2str(front),'-',num2str(front+lgh-1)));
            lgh = 0;
        end
        front = k;
    end
    
    imwrite(frame,strcat('D:\用户目录\我的文档\MATLAB\`mathmatics\pic\',num2str(k),'.jpg'),'jpg');
    imwrite(mask,strcat('D:\用户目录\我的文档\MATLAB\`mathmatics\pic2\',num2str(k),'.jpg'),'jpg');
    k = k+1;
end

    function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.

        % Create a video file reader.
        obj.reader = vision.VideoFileReader('D:\用户目录\我的文档\MATLAB\`mathmatics\11.avi');

        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 350, 200]);
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 350, 200]);

        % Create System objects for foreground detection and blob analysis

        % The foreground detector is used to segment moving objects from
        % the background. It outputs a binary mask, where the pixel value
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.

        obj.detector = vision.ForegroundDetector('NumGaussians', 4, ...
            'NumTrainingFrames', 50, 'MinimumBackgroundRatio', 0.6);

        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis System object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.

        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 320);
    end

    function frame = readFrame()
        frame = obj.reader.step();
    end

    function [centroids, bboxes, mask] = detectObjects(frame)

        % Detect foreground.
        mask = obj.detector.step(frame);

        % Apply morphological operations to remove noise and fill in holes.
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [13, 13]));
        mask = imfill(mask, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end

    function displayTrackingResults()
        % Display the mask and the frame.
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);

    end
end
