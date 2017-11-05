clear all;
% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();
%catDetector = vision.CascadeObjectDetector('cat.xml');
numDetector = vision.CascadeObjectDetector('number.xml');
extern=-1;
% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Create the webcam object.
cam = webcam();


% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

runLoop = true;
numPts = 0;
frameCount = 0;

%Serial Output
Serial = '0';
COM=serial('COM3');
set(COM,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none','FlowControl','none');
set(COM,'TimeOut',1);
fopen(COM);

flag = 9;
while runLoop %&& frameCount < 4000
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;
        
    if numPts < 25
        % Detection mode.
        if flag == 6
        bbox= numDetector.step(videoFrameGray);
        end
        if flag == 9
         bbox = faceDetector.step(videoFrameGray);
        end
        if ~isempty(bbox)
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);

            % Save a copy of the points.
            oldPoints = xyPoints;

            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));
            x=sum(bboxPoints(:,1))/4;
            y=sum(bboxPoints(:,2))/4;
            fprintf('Object Detected: %d\n',flag);
            
            if x >= 240 && x <= 400
                
                Serial = '0';
            elseif x < 240
                Serial = '1';
                else
                Serial = '2';
            end
            %{
            fprintf(COM,'%s',Serial);
            if abs(x-bboxPoints(1,1))>80
                Serial = '3';
            elseif abs(x-bboxPoints(1,1))<40
                Serial = '4';
            end
            %}
            %fprintf('SerialOut = %d',Serial);
            fprintf(COM,'%s',Serial);
            
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the detected face.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display detected corners.
            videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        end

    else
        % Tracking mode.
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);
        numPts = size(visiblePoints, 1);

        if numPts >= 25
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);
            x=sum(bboxPoints(:,1))/4;
            y=sum(bboxPoints(:,2))/4;
            fprintf('Object Captured: %d\n',flag);
            
           if x >= 240 && x <= 400
              
                Serial = '0';
                
            elseif x < 240
                Serial = '1';
                else
                Serial = '2';
           end
           %{
            fprintf(COM,'%s',Serial);
            if abs(x-bboxPoints(1,1))>80
                Serial = '3';
            elseif abs(x-bboxPoints(1,1))<40
                Serial = '4';
            end
           %}
           
            %fprintf('SerialOut = %d',Serial);
            fprintf(COM,'%s',Serial);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the face being tracked.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display tracked points.
            videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
            numPts = numPts -10;
        end
    
    end

    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    %UDP
    
    if(~mod(frameCount,30))
        
        fil = ['C:\\Users\\shishi\\curl-7.56.1-win64-mingw\\bin\\id\\1.txt'];
        A = load(fil);
        fprintf('A=%d\n',A);
        if flag~=A
            flag = A;
            numPts=0;
        end
        
        
    end
end

% Clean up.
fclose(COM);
clear cam;
release(videoPlayer);
release(pointTracker);
release(faceDetector);