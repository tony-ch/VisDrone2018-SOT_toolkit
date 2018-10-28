# new readme
modify repo to run OPE with multi tracker

datasetPath:<br>
|---sequences<br>
|------test_seqs.txt (Optional, specify seqs to run evaluation)<br>
|------seq1<br>
|---------img1<br>
|---------img2<br>
|------seq2<br>
|---------img1<br>
|---------img2<br>
|---annotations<br>
|------seq1<br>
|------seq2<br>

resultPath:<br>
|---results_OPE<br>
|------Tracker1 (folder name should match with tracker name in PlotEval.m)<br>
|---------seq1.txt/mat (txt or mat file, its name should match with coresponding folder name under datasetPath/sequences)<br>
|---------seq2.txt/mat<br>
|------Tracker2<br>
|---------seq1.txt/mat<br>
|---------seq2.txt/mat<br>

- `datasetPath`: dataset path, put imgs and annotaions there
  - put images under `sequences`, each sequence has a floder
  - `test_seqs.txt` under `sequences` is used to specify sequences(if not all seqs under `sequences` have results) to run evaluation, each seq(folder) takes one line
  - put annatatons under `annotations`, each sequence folder has a txt file, both of them should have has the same name
  - the names of `sequences` and `annotations` under `datasetPath` can be changed in `plotEval.m`, find `configSeqs` and `annoPath` to locale them
- `resultPath`: results to evaluate, put txt(mat) files there
  - each txt(mat) file coresponds to a sequences under `dataPath/sequences/`, its name should match with coresponding sequences(folder) name
  - each tracker has a folder, folder names must match with names of trackers
  - Trackers can be added by modifying `plotEval.m`, insert a new line like `struct('name','ACT','namePaper','ACT')` to add a tracker.
- `datasetPath` and `resultPath` can be changed in `plotEval.m`


# original readme
VisDrone2018-SOT Tooklit for Single-Object Tracking


Introduction

This is the documentation of the VisDrone2018 competitions development kit for single-object tracking (SOT) challenge.

This code library is for research purpose only, which is modified based on the visual benchmark platform of Wu et al. [1]. 

The code is tested on the Windows 10 and macOS Sierra 10.12.6 systems, with the Matlab 2013a/2014b/2016b/2017b platforms.

If you have any questions, please contact us (email:tju.drone.vision@gmail.com).

Citation

If you use our toolkit or dataset, please cite our paper as follows:

@article{zhuvisdrone2018,

    title={Vision Meets Drones: A Challenge},

    author={Zhu, Pengfei and Wen, Longyin and Bian, Xiao and Haibin, Ling and Hu, Qinghua},

    journal={arXiv preprint:1804.07437},

    year={2018}

}

Dataset

For SOT competition, there are three sets of data and labels: training data, validation data, 
and test-challenge data. There is no overlap between the three sets. 

                                                         Number of snippets
    ----------------------------------------------------------------------------------------------
    Dataset                            Training              Validation            Test-Challenge
    ----------------------------------------------------------------------------------------------
    Signle object tracking             86 clips                  11 clips               35 clips
                                     69,941 frames              7,046 frames         29,367 frames
    ----------------------------------------------------------------------------------------------

For an input video sequence and the initial bounding box of the target object in the first frame, the challenge requires a participating algorithm to locate the target bounding boxes in the subsequent video frames. The objects to be tracked are of various types including pedestrians, cars, and animals. We manually annotate the bounding boxes of different objects in each video frame. Annotations on the training and validation sets are publicly available.

The link for downloading the data can be obtained by registering for the challenge at

    http://www.aiskyeye.com/
 

Evaluation Routines

The notes for the folders:
* The tracking results will be stored in the folder '.\results'.
* The folder '.\trackers' contains all the source codes for trackers (e.g., Staple)
* The folder '.\util' contains some scripts used in the main functions.
* main functions
     * main_running.m is the main function to run your tracker
	
       -put the source codes in ./trackers/ according to the source codes of Staple tracker
	
       -modify the dataset path in ./main_running.m    
	
       -input the method named in ./util/configTrackers.m
	
       -the results with mat format are saved in ./results/results_OPE/
	
     * perfPlot.m is the main function to evaluate your tracker based on the results with mat or txt format. 
       Besides, the visual attributes are defined as same as these in [2].
	
       -modify the dataset path in ./perfPlot.m (re-evaluate the results by setting the flag "reEvalFlag = 1")    
	
       -select a tracker named in ./util/configTrackers.m
	
       -select the rankingType e.g., AUC and threshold
	
       -check the tracking results in ./results/results_OPE/
	
       -the figures are saved in ./figs/overall/

     * drawResultBB.m is the main function used to show the results
	
       -modify the dataset path in ./drawResultBB.m  
	
       -select a tracker named in ./util/configTrackers.m
	
       -check the tracking results in ./results/results_OPE/
	
       -the visual results are saved in ./tmp/OPE/	
    
    
    
SOT submission format

Submission of the results will consist of TXT files with one line per predicted object or MAT files as same as that in [1].
For txt submission, it looks as follows:

    <bbox_left>,<bbox_top>,<bbox_width>,<bbox_height>


       Name	                                Description
    --------------------------------------------------------------------------------------------------
      <bbox_left>	    The x coordinate of the top-left corner of the predicted bounding box
   
      <bbox_top>	    The y coordinate of the top-left corner of the predicted object bounding box
      
      <bbox_width>      The width in pixels of the predicted object bounding box 
      
      <bbox_height>     The height in pixels of the predicted object bounding box.


For mat submission, it looks as follows:

     < results: {type = 'rect', res, fps, len, annoBegin = 1, startFrame = 1} >


      Variable	                                   Description
    ---------------------------------------------------------------------------------------------------------
       <type>	     The representation type of the predicted bounding box representation. 
                         It should be set as 'rect'.
	
       <res>	     The tracking results in the video clip. Notably, each row includes the frame index, 
                         the x and y coordinates of the top-left corner of the predicted bounding box, 
		             and the width and height in pixels of the predicted bounding box.
	
       <fps>	     The running speed of the evaluated tracker, namely frame-per-second.
	
       <len>	     The length of the evaluated sequence.
	
    <annoBegin>	     The start frame index for tracking. The default value is 1.
    
    <startFrame>         The start frame index of the video. The default value is 1.
	
	
The sample submission of the tracker can be found in our website.



References

[1] Y. Wu, J. Lim, and M.-H. Yang, "Online Object Tracking: A Benchmark", in CVPR 2013.

[2] M. Mueller, N. Smith, B. Ghanem, "A Benchmark and Simulator for UAV Tracking", in ECCV 2016.

-----------------------------------------------------------------
Version History

1.0.2 - May 7, 2018
  - Fix the bugs in the main_running and perPlot functions.

1.0.1 - May 3, 2018
  - Fix the bug in the genPerfMat function.
  
1.0.0 - Apr 19, 2018
  - Initial release.
