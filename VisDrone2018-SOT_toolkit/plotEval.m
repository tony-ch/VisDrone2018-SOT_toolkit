close all;
clear, clc;
warning off all;
addpath(genpath('.')); 

datasetPath = '/home/tony/app/ACT/dataset/data_sot/'; % the dataset path
trackers = configTrackers; % the set of trackers
reEvalFlag = 1; % the flag to re-evaluate trackers
evalType = 'OPE'; % the evaluation type such as 'OPE','SRE','TRE'
resultPath = ['./results/results_' evalType '/'];
% rankingType = 'AUC'; %AUC, threshold
seqs = configSeqs(fullfile(datasetPath,'sequences')); % the set of sequences
annoPath = fullfile(datasetPath, 'annotations');
       
numSeq = length(seqs);
numTrk = length(trackers);

nameTrkAll = cell(numTrk,1);
for idxTrk = 1:numTrk
    t = trackers{idxTrk};
    nameTrkAll{idxTrk} = t.namePaper;
end

nameSeqAll = cell(numSeq,1);
numAllSeq = zeros(numSeq,1);

att = [];
for idxSeq = 1:numSeq
    s = seqs{idxSeq};
    nameSeqAll{idxSeq} = s.name;    
    s.len = s.endFrame - s.startFrame + 1;
    numAllSeq(idxSeq) = s.len;
end

figPath = './figs/overall/';

perfMatPath = './perfMat/overall/';

if ~exist(figPath,'dir')
    mkdir(figPath);
end

metricTypeSet = {'overlap','error'};

rankNum = 10;%number of plots to show------------------------------------------------------------------------
plotDrawStyle = getDrawStyle(rankNum);

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;

for i = 1:length(metricTypeSet)
    metricType = metricTypeSet{i};%error,overlap
    
    switch metricType
        case 'overlap'
            thresholdSet = thresholdSetOverlap;
            rankIdx = 11;
            xLabelName = 'Overlap threshold';
            yLabelName = 'Success rate';
        case 'error'
            thresholdSet = thresholdSetError;
            rankIdx = 21;
            xLabelName = 'Location error threshold';
            yLabelName = 'Precision';
    end  
        
    % if(strcmp(metricType,'error') && strcmp(rankingType,'AUC') || strcmp(metricType,'overlap') && strcmp(rankingType,'threshold'))
    %    continue;
    % end
    if (strcmp(metricType, 'error'))
        rankingType='threshold';
    else
        rankingType='AUC';
    end
    
    tNum = length(thresholdSet);                    
    plotType = [metricType '_' evalType];

    switch metricType
        case 'overlap'
            titleName = ['Success plots of ' evalType];
        case 'error'
            titleName = ['Precision plots of ' evalType];
    end

    dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];

    % If the performance Mat file, dataName, does not exist, it will call genPerfMat to generate the file.
    if(~exist(dataName, 'file') || reEvalFlag)
        genPerfMat(annoPath, seqs, trackers, evalType, resultPath, nameTrkAll, perfMatPath);
    end        

    load(dataName);
    numTrk = size(aveSuccessRatePlot,1);        
    if(rankNum > numTrk || rankNum <0)
        rankNum = numTrk;
    end

    figName = [figPath 'quality_plot_' plotType '_' rankingType];
    idxSeqSet = 1:length(seqs);

    %% draw and save the overall performance plot
    plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName);      
end
