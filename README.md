# Ordinal Depth Supervision for 3D Human Pose Estimation
## Georgios Pavlakos, Xiaowei Zhou, Kostas Daniilidis

This is the code for the paper **Ordinal Depth Supervision for 3D Human Pose Estimation**. Please follow the links to read the [paper](https://arxiv.org/abs/1805.04095) and visit the corresponding [project page](https://www.seas.upenn.edu/~pavlakos/projects/ordinal).

We provide code to test our model on [Human3.6M](http://vision.imar.ro/human3.6m/description.php). Please follow the instructions below to setup and use our code. The typical procedure is 1) apply the ConvNet models using a torch script through command line and then 2) run a MATLAB script (from folder ```matlab```) for visualization or evaluation. To run this code, make sure the following are installed:

- MATLAB
- [Torch7](https://github.com/torch/torch7)
- hdf5
- cudnn

We will soon update this repository with the training code.

### 1) Downloading models and data

We provide our models pretrained for Human3.6M. To get the models and the Human3.6M data to reproduce our results on this dataset, please run the following script (**be careful, since the size is over 8GB**)

```bash data.sh```

### 2) Evaluation on Human3.6M (sample)

We have provided a sample of Human3.6M images, following [previous work](https://fling.seas.upenn.edu/~xiaowz/dynamic/wordpress/monocap/). You can apply our model on this sample by running the command:

```
th main.lua h36m-sample
```

Then, to visualize the output, you can use the MATLAB script:

```
demoH36M.m
```

### 3) Evaluation on Human3.6M (full)

If you want to reproduce the results of our paper for Human3.6M, you need to download the full set of images we used for testing, by running the script ```data.sh``` as indicated above. These images are extracted from the videos of the [original dataset](http://vision.imar.ro/human3.6m/description.php), and correspond to the images used for testing by the most typical protocol. Please check the file:

```
data/h36m/annot/valid_images.txt
```

for the correspondence of images with the original videos.

Having downloaded the necessary images, to apply our model on the whole set of Human3.6M images, you can run:

```
th main.lua h36m
```

Then, to conclude the evaluation, you need to run the next MATLAB script:

```
evalH36M.m
```

This will print the output in a results.txt file.

### Citing

If you find this code useful for your research, please consider citing the following paper:

	@Inproceedings{pavlakos2018ordinal,
	  Title          = {Ordinal Depth Supervision for 3{D} Human Pose Estimation},
	  Author         = {Pavlakos, Georgios and Zhou, Xiaowei and Daniilidis, Kostas},
	  Booktitle      = {Computer Vision and Pattern Recognition (CVPR)},
	  Year           = {2018}
	}

### Acknowledgements

This code follows closely the [released code](https://github.com/anewell/pose-hg-demo) for the Stacked Hourglass networks by Alejandro Newell. If you use this code, please consider citing the [respective paper](http://arxiv.org/abs/1603.06937).

