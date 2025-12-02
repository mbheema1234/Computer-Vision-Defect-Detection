%ECET 36900
%Final Project
%Arnav Pai and Mahit Bheema
%Topic: Finding defect detection using color

%Clear the homescreen and close all output windows.
clc; 
clear;
close all;

%Create function to find RGB Averages from the inputs.
function avgRGB = getAvg(filename)

%Read the file inputted
img = imread(filename);
%Find the average filter
filter_val = fspecial('average',[3 3]);
% Find the average color image and overwrite the original image.
img = imfilter(img, filter_val);  

%Find the gray image using rgb2gray
gray = rgb2gray(img);
BW = gray < 100;   % Let us assume a threshold for background pixels.

%Let us replace each color channel depending on the threshold
%If BW is true, set the pixel to zero. We get the banana only image now.
%The new image is called banana now after segmentation.
for i = 1:3
    ch = img(:,:,i);
    ch(BW) = 0;
    banana(:,:,i) = ch;
end

%Find the columns and bins from histogram method to find the averages.
%Bins = pixel values, Count = Frequency
[countR,binsR] = imhist(banana(:,:,1));
[countG,binsG] = imhist(banana(:,:,2));
[countB,binsB] = imhist(banana(:,:,3));

%We need to skip black pixels (=0), so we start from 2 of the matrix
%MATLAB takes the vectorized sum, so no for loop is needed.
Red_avg   = sum(countR(2:end).*binsR(2:end)) / sum(countR(2:end));
Green_avg = sum(countG(2:end).*binsG(2:end)) / sum(countG(2:end));
Blue_avg  = sum(countB(2:end).*binsB(2:end)) / sum(countB(2:end));

avgRGB = [Red_avg Green_avg Blue_avg]; %Return
end

%This is training data:

good1 = getAvg('Yellow4.jpeg');
good2 = getAvg('Yellow5.jpeg');
good3 = getAvg('Yellow 6.png'); 
%Yellow 6.png : Image from shutterstock. To include bright images as well. 
% All inclusive cases then

bad1  = getAvg('green1.png');
bad2  = getAvg('green2.jpeg');
bad3  = getAvg('Green5.png');

%Create the training matrix now
Training = [
    good1
    good2
    good3
    bad1
    bad2
    bad3
];

%Label each row as good or bad
Labels = ["Good"; "Good"; "Good"; "Bad"; "Bad"; "Bad"];

%Image testing:

%Load the image
k = imread('Yellow2.heic');

%Find the average colored image using fspecial and imfilter.
lb_avg_filter = fspecial('average', [3 3]);
Filtered_img = imfilter(k, lb_avg_filter);

%Display the original and filtered image side by side
figure;
subplot(1, 2, 1), imshow(k), title('Original Image');
subplot(1, 2, 2), imshow(Filtered_img), title('Average Colored Image');

%Find the gray image now using same method as in function
gray_img = rgb2gray(Filtered_img);
BW = gray_img < 100; %Approximate threshold

%Replace the pixel with 0, if BW=1 meaning it is background pixel.
for i = 1:3
    channel = Filtered_img(:,:,i);
    channel(BW) = 0;
    banana_only(:,:,i) = channel;
end

%Display the average colored image and segmented image side by side.
figure;
subplot(1,2,1); imshow(Filtered_img); title('Average Colored Image');
subplot(1,2,2); imshow(banana_only); title('Banana Segmented');

%Same method for finding the averages
Red   = banana_only(:,:,1);
Green = banana_only(:,:,2);
Blue  = banana_only(:,:,3);

[countR,binsR]=imhist(Red);
[countG,binsG]=imhist(Green);
[countB,binsB]=imhist(Blue);

%Skip the black pixels when taking average.:
Red_avg   = sum(countR(2:end).*binsR(2:end)) / sum(countR(2:end));
Green_avg = sum(countG(2:end).*binsG(2:end)) / sum(countG(2:end));
Blue_avg  = sum(countB(2:end).*binsB(2:end)) / sum(countB(2:end));

%Print the RGB averages of inputted image.
fprintf('Red Average: %.2f\n', Red_avg);
fprintf('Green Average: %.2f\n', Green_avg);
fprintf('Blue Average: %.2f\n', Blue_avg);

%Store the RGB averages of the inputted images.
test_features = [Red_avg Green_avg Blue_avg];

%Decision time using KNN - K Nearest Neighbor
%Only the closest neighbor:
idx = knnsearch(Training, test_features, "K", 1);   
knn_result = Labels(idx); %Find label corresponding to training matrix                          
%Finds whether inputted coordinates are closer to good or bad banana.
%Find, print the status, both in the output window as well as figure window

%Decision Time (final)
if knn_result == "Good" 
    status = "Good (Yellow Banana)";
else
    status = "Bad (Greenish Banana)";
end
%Stored in 'status'

%Need to print in output window
fprintf('=========================\n');
fprintf('Banana Status Report\n');
fprintf('=========================\n');
fprintf('   %s\n', status);

%Print in figure window:
msg = sprintf(['=========================\n' ...
               'Banana Status Report\n' ...
               '=========================\n\n' ...
               'Status of Banana: %s'], status);

figure;
text(0.3, 0.5, msg, 'FontSize', 14); %Find the coordinates on the graph.
axis off; %Dont need axis

%Display training matrix 

fprintf('\nTraining Matrix: \nFirst three rows are Good, Last three rows are Bad');

Training

%End of program
