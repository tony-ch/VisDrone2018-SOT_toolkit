close all;
clear, clc;
warning off all;
addpath(genpath('.')); 

datasetPath = '/home/tony/app/ACT/dataset/data_sot/'; % the dataset path
seqs = configSeqs(fullfile(datasetPath,'sequences'), 'test_seqs.txt'); % the set of sequences

trackers = {
            struct('name','ACT','namePaper','ACT')
            struct('name','GT','namePaper','GT')
            struct('name','adnet','namePaper','ADNet')
            struct('name','sdnet','namePaper','meta-SDNet')
            }; % the set of trackers

evalType = 'OPE'; % the evaluation types such as OPE, SRE and TRE
resultPath = ['./results/results_' evalType '/']; % the folder containing the tracking results

drawResPath = './figs/box/';% the folder that will stores the images with overlaid bounding box

showLegend = true; % show legend or not
LineWidth = 2;
legendFontSize = 10;
plotSetting; % set plot style and color


rstIdx = 1; % the result index (1~20)
lenTotalSeq = 0;
resultsAll = [];
%% draw visual results for each sequence
for index_seq = 1:length(seqs)
    seq = seqs{index_seq};
    seq_name = seq.name;
    seq_length = seq.endFrame-seq.startFrame+1;
    lenTotalSeq = lenTotalSeq + seq_length;
    %% draw visual results of each tracker
    for index_algrm = 1:length(trackers)
        algrm = trackers{index_algrm};
        name = algrm.name;
        trackerNames{index_algrm} = name;
        
        % check the result format       
        res_mat = [resultPath name '/' seq_name '.mat'];
        if(~exist(res_mat, 'file'))
            res_txt = [resultPath name '/' seq_name '.txt'];
            res = load(res_txt);
        else
            res_mats = load(res_mat);
            res = res_mats.s.bb;
        end
        results = cell(1,1);
        results{1}.res = res;
        results{1}.len = size(results{1}.res, 1);
        
        res = results{1};
        
        for i = 2:res.len
            r = res.res(i,:);               
            if(isnan(r) | r(3)<=0 | r(4)<=0)
                res.res(i,:)=res.res(i-1,:);
            end
        end
        resultsAll{index_algrm} = res;
    end
           
    pathSave = [drawResPath seq_name '/'];
    if(~exist(pathSave,'dir'))
        mkdir(pathSave);
    end
    
    filenames = dir(fullfile(seq.path,'*.jpg'));
    for i = 1:seq_length
        filename = filenames(i).name; 
        id = filename(end-7:end-4);
        img = imread(fullfile(seq.path,filename));

        imshow(img);

        text(5, 20, ['#' id], 'Color','y', 'FontWeight','bold', 'FontSize',24);
        
        for j = 1:length(trackers)           
            LineStyle = plotDrawStyle{j}.lineStyle;
            
            rectangle('Position', resultsAll{j}.res(i,:), 'EdgeColor', plotDrawStyle{j}.color, 'LineWidth', LineWidth,'LineStyle',LineStyle);
            hline = line(NaN,NaN,'LineWidth',LineWidth,'LineStyle',LineStyle,'Color',plotDrawStyle{j}.color);
        end
        if showLegend
            legend(trackerNames(:),'Interpreter', 'none','fontsize',legendFontSize);
        end
        pause(0.1);
        imwrite(frame2im(getframe(gcf)), [pathSave  filename]);
    end
    clf
end