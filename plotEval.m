close all;
clear, clc;
warning off all;
addpath(genpath('.'));

%% path config
datasetPath = '/home/tony/data/2018/1027_drone/drone2018/'; % the dataset path
seqs = configSeqs(fullfile(datasetPath,'sequences'), 'test_seqs.txt'); % the set of sequences
annoPath = fullfile(datasetPath, 'annotations');

evalType = 'OPE'; % the evaluation type such as 'OPE','SRE','TRE'
trackResPath = ['./trackRes/results_' evalType '/'];
trackers = {
            struct('name','ACT','namePaper','ACT')
            struct('name','GT','namePaper','GT')
            struct('name','adnet','namePaper','ADNet')
            struct('name','sdnet','namePaper','meta_SDNet')
            }; % the set of trackers

attrPath = fullfile(datasetPath, 'attributes');  % the folder that contains the annotation files for sequence attributes
attName = {'Aspect Ratio Change','Background Clutter','Camera Motion','Fast Motion','Full Occlusion','Illumination Variation','Low Resolution',...
           'Out-of-View','Partial Occlusion','Similar Object','Scale Variation','Viewpoint Change'};
attFigName = {'Aspect_Ratio_Change','Background_Clutter','Camera_Motion','Fast_Motion','Full_Occlusion','Illumination_Variation','Low_Resolution',...
           'Out_of_View','Partial_Occlusion','Similar_Object','Scale_Variation','Viewpoint_Change'};

%% plot config     
configPlot.fontSize = 16;
configPlot.fontSizeLegend = 12;
configPlot.lineWidth = 2;
configPlot.fontSizeAxes = 14;

%%

reEvalFlag = 1; % the flag to re-evaluate trackers
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
    att(idxSeq,:) = load([attrPath '/' s.name '_attr.txt']);
end

attNum = size(att,2);

evalResPath = './evalRes';
figPath = './evalRes/figs/overall/';
perfMatPath = './evalRes/perfMat/overall/';
attrSeqListPath = './evalRes/attrSeqList';
attrResPath = './evalRes/attrRes';

for path_item = {figPath,perfMatPath,attrSeqListPath,attrResPath,evalResPath}
    if ~exist(path_item{1},'dir')
        mkdir(path_item{1});
    end
end

metricTypeSet = {'overlap','error'};
result = struct();

rankNum = -1;%number of plots to show------------------------------------------------------------------------
%plotDrawStyle = getDrawStyle(rankNum);
plotSetting;

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;

%%% 
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
            configPlot.location = 'southwest';
        case 'error'
            configPlot.location = 'southeast';
            titleName = ['Precision plots of ' evalType];
    end
    disp(titleName);
    
    dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];

    % If the performance Mat file, dataName, does not exist, it will call genPerfMat to generate the file.
    if(~exist(dataName, 'file') || reEvalFlag)
        genPerfMat(annoPath, seqs, trackers, evalType, trackResPath, nameTrkAll, perfMatPath);
    end        

    load(dataName);
    numTrk = size(aveSuccessRatePlot,1);        
    if(rankNum > numTrk || rankNum <0)
        rankNum = numTrk;
    end

    figName = [figPath 'quality_plot_' plotType '_' rankingType];
    idxSeqSet = 1:length(seqs);

    %% draw and save the overall performance plot
    eval_res = plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,configPlot);
    fid = fopen([attrResPath '/' titleName '.txt'],'w');
    for idx = 1:numTrk
        fprintf(fid,'%s\t%s\n',eval_res{idx}{1},eval_res{idx}{2});
        result.(metricType).(eval_res{idx}{1}).all = str2double(eval_res{idx}{2});
    end
    fclose(fid);
    %% draw and save the performance plot for each attribute
    attTrld = 0;
    for attIdx = 1:attNum
        idxSeqSet = find(att(:,attIdx)>attTrld);
        if(length(idxSeqSet)<2)
            continue;
        end
        disp([attName{attIdx} ' ' num2str(length(idxSeqSet))])
        fid = fopen([attrSeqListPath '/' attName{attIdx} '.txt'],'w');
        for idx = 1:length(idxSeqSet)
            s = seqs{idxSeqSet(idx)};
            disp(s.name);
            fprintf(fid,'%s\n',s.name);
        end
        fclose(fid);
        figName = [figPath attFigName{attIdx} '_'  plotType '_' rankingType];
        titleName = ['Plots of ' evalType ': ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];

        switch metricType
            case 'overlap'
                 configPlot.location = 'southwest';
                titleName = ['Success plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
            case 'error'
                configPlot.location = 'southeast';
                titleName = ['Precision plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
        end

        eval_res = plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,configPlot);
        fid = fopen([attrResPath '/' titleName '.txt'],'w');
        for idx = 1:numTrk
            fprintf(fid,'%s\t%s\n',eval_res{idx}{1},eval_res{idx}{2});
            result.(metricType).(eval_res{idx}{1}).(attFigName{attIdx}) = str2double(eval_res{idx}{2});
        end
        fclose(fid);
    end
end
save("./evalRes/result.mat",'result');
