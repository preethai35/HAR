clc
clear all

% Load Datasets

Dataset = 'C:\Users\Preetha\Desktop\HAR\KTH Dataset\';   
Testset  = 'C:\Users\Preetha\Desktop\HAR\Test_Images\';


% we need to process the images first.
% Convert your images into grayscale
% Resize the images

width=100; height=100;
DataSet      = cell([], 1);

 for i=1:length(dir(fullfile(Dataset,'*.avi')))

     % Training set process
     k = dir(fullfile(Dataset,'*.avi'));
     k = {k(~[k.isdir]).name};
     for j=1:length(k)
        [Dataset,k{j}]
        I = VideoReader([Dataset,k{j}]);
        pause(3);
        nFrames = I.numberofFrames;
        vidHeight =  I.Height;
        vidWidth =  I.Width;
        mov(1:nFrames) = ...
        struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
               'colormap', []);
        WantedFrames = 50;
        for k = 1:WantedFrames
            mov(k).cdata = read( I, k);
            mov(k).cdata = imresize(mov(k).cdata,[256,256]);
            imwrite(mov(k).cdata,['Frames_Train\',num2str(k),'.jpg']);
        end

        im = imread('Frames_Train\25.jpg');
        tempImage       = im;
        imgInfo         = imfinfo('Frames_Train\25.jpg');

         % Image transformation
         if strcmp(imgInfo.ColorType,'grayscale')
            DataSet{j}   = double(imresize(tempImage,[width height])); % array of images
         else
            DataSet{j}   = double(imresize(rgb2gray(tempImage),[width height])); % array of images
         end
         
         delete('Frames_Train\*');
     end
 end
TestSet =  cell([], 1);
  for i=1:length(dir(fullfile(Testset,'*.avi')))

     % Training set process
     k = dir(fullfile(Testset,'*.avi'));
     k = {k(~[k.isdir]).name};
     for j=1:length(k)
        I = VideoReader([Testset,k{j}]);
        pause(3);
        nFrames = I.numberofFrames;
        vidHeight =  I.Height;
        vidWidth =  I.Width;
        mov(1:nFrames) = ...
        struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
               'colormap', []);
        WantedFrames = 50;
        for k = 1:WantedFrames
            mov(k).cdata = read( I, k);
            mov(k).cdata = imresize(mov(k).cdata,[256,256]);
            imwrite(mov(k).cdata,['Frames_Test\',num2str(k),'.jpg']);
        end
        
        im=imread('Frames_Test\25.jpg');
 
        tempImage       = im;
        imgInfo         = imfinfo('Frames_Test\25.jpg');

         % Image transformation
         if strcmp(imgInfo.ColorType,'grayscale')
            TestSet{j}   = double(imresize(tempImage,[width height])); % array of images
         else
            TestSet{j}   = double(imresize(rgb2gray(tempImage),[width height])); % array of images
         end
         
         delete('Frames_Test\*');
     end
  end

% Prepare class label for first run of svm
% I have arranged labels 1 & 2 as per my convenience.
% It is always better to label your images numerically
% Please note that for every image in our Dataset we need to provide one label.
% we have 30 images and we divided it into two label groups here.
train_label               = zeros(size(78,1),1);
train_label(1:40,1)   = 1;         % 1 = Jogging
train_label(41:78,1)  = 2;         % 2 = Walking

% Prepare numeric matrix for svmtrain
%Training_Set=[];
for i=1:length(DataSet)
    Training_Set_tmp   = reshape(DataSet{i},1, 100*100);
    Training_Set = [Training_Set Training_Set_tmp];
end

%Test_Set=[];
for j=1:length(TestSet)
    Test_set_tmp   = reshape(TestSet{j},1, 100*100);
    Test_Set=[Test_Set;Test_set_tmp];
end

% Perform first run of svm
size(DataSet)
size(train_label)
SVMStruct = svmtrain(Training_Set , train_label, 'kernel_function', 'linear');
Group       = svmclassify(SVMStruct, Test_Set);

