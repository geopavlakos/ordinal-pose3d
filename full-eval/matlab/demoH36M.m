%% Visualization for Human3.6M sample data
% We assume that the network has already been applied on the Human3.6M sample images.
% This code reads the network predictions and visualizes them.
% The demo sequence is Posing_1 from Subject 9 and from camera with code 55011271.

clear; startup;

% define paths for data and predictions
datapath = '../../data/h36m-sample/';
predpath = '../exp/h36m-sample/';
annotfile = sprintf('%s/annot/valid.mat',datapath);
load(annotfile);

% main loop to read network output and visualize it
nPlot = 3;
h = figure('position',[300 300 200*nPlot 200]);
for img_i = 1:length(annot.imgname)
    
    % read input info
    imgname = annot.imgname{img_i};
    center = annot.center(img_i,:);
    scale = annot.scale(img_i);
    
    bbox = getHGbbox(center,scale);
    I = imread(sprintf('%s/images/%s.jpg',datapath,imgname));
    img_crop = cropImage(I,bbox);
    
    % read network's output
    joints = hdf5read([predpath 'valid_' num2str(img_i)  '.h5'],'preds3D');
    
    % reconstruct 3D skeleton
    S = 1000*joints
    
    % visualization
    clf;
    % image
    subplot('position',[0/nPlot 0 1/nPlot 1]);
    imshow(img_crop); hold on;
    % 3D reconstructed pose
    subplot('position',[1/nPlot 0 1/nPlot 1]);
    vis3Dskel(S,skel);
    % 3D reconstructed pose in novel view
    subplot('position',[2/nPlot 0 1/nPlot 1]);
    vis3Dskel(S,skel,'viewpoint',[-90 0]);
    camroll(10);
    pause(0.01);
    
end
