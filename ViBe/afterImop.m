clear
close all
clc
videoObj = VideoReader('D:\用户目录\我的文档\MATLAB\`mathmatics\10.avi');  
numFrames = get(videoObj, 'NumberOfFrames');  
  
FRAME_HEIGHT = 240;  
FRAME_WIDTH =  320;  

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 160);
videoPlayer = vision.VideoPlayer('Name', 'Detected Objects');
videoPlayer2 = vision.VideoPlayer('Name', 'Original');

vibe = VIBE();  
k = 1; 
front = 1; 
lgh = 0;
for ii = 1:numFrames   
    im = read(videoObj, ii);  
    im = double(imresize(im, [FRAME_HEIGHT, FRAME_WIDTH]));  
      
    frimg = vibe.GetfrImageC3R(uint8(im));  
    
    mask = imopen(frimg, strel('rectangle', [3,3]));
    mask = imclose(mask, strel('rectangle', [13, 13]));
    mask = imfill(mask, 'holes'); 
    imwrite(uint8(im),strcat('D:\用户目录\我的文档\MATLAB\`mathmatics\pic\',num2str(k),'.jpg'),'jpg');
    imwrite(mask,strcat('D:\用户目录\我的文档\MATLAB\`mathmatics\pic2\',num2str(ii),'.jpg'),'jpg');
%    se = strel('square', 3);
%    filteredForeground = imopen(frimg, se);
%% count
    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, logical(mask));

    % Draw bounding boxes around the detected cars
    result = insertShape(mask, 'Rectangle', bbox, 'Color', 'green');

    % Display the number of cars found in the video frame
    nums = size(bbox, 1);
    result = insertText(result, [10 10], nums, 'BoxOpacity', 1, ...
        'FontSize', 14);
    
 %% count and disp 
%      if(nums>0) 
%         lgh = lgh +1;
%     else
%         if(lgh>0) 
%             disp(strcat(num2str(front),'-',num2str(front+lgh-1)));
%             lgh = 0;
%         end
%         front = k;
%     end
% 
%     k = k+1;
 
    step(videoPlayer, result);
    step(videoPlayer2, uint8(im));
    %figure(50), imshow(uint8(im))  
end 