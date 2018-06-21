%% Evaluation for Human3.6M full test set
% We assume that the network has already been applied on the Human3.6M sample images.
% This code reads the network predictions.
% Full results for the Human3.6M dataset (subjects S9 and S11) are printed in file H36M.txt

clear; startup;

% define paths for data and predictions
datapath = '../../data/h36m/';
predpath = '../exp/h36m/';
annotfile = sprintf('%s/annot/valid.mat',datapath);
load(annotfile);
Nimg = length(annot.imgname);

% Recover 3D predictions
Sall = zeros(Nimg,3,numKps);
for img_i = 1:Nimg
    
    % read network's output
    joints = hdf5read([predpath 'valid_' num2str(img_i)  '.h5'],'preds3D');

    Sall(img_i,:,:) = 1000*S;

end

% Print results in file H36M.txt
errorH36M(Sall,annot.S,annot.imgname);
