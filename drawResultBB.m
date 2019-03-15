close all;
clear, clc;
warning off all;
addpath(genpath('.')); 

%% path config
datasetPath = '/home/tony/data/2018/1027_drone/drone2018/'; % the dataset path
seqs = configSeqs(fullfile(datasetPath,'sequences'), 'test_seqs.txt'); % the set of sequences

trackers = {
            struct('name','ACT','namePaper','ACT')
            struct('name','GT','namePaper','GT')
            struct('name','adnet','namePaper','ADNet')
            struct('name','sdnet','namePaper','meta-SDNet')
            }; % the set of trackers
trackNum = length(trackers);
halfTrackNum = floor(trackNum/2);

evalType = 'OPE'; % the evaluation types such as OPE, SRE and TRE
resultPath = ['./trackRes/results_' evalType '/']; % the folder containing the tracking results

drawResPath = './evalRes/figs/box/';% the folder that will stores the images with overlaid bounding box

%% plot config
showLegend = true; % show legend or not
legendOut = true;
legBoxOff = true;
LineWidth = 4;
idFontSize = 24;
legendFontSize = 20;
legendPadding = 8; % set padding between legend items
plotSetting; % set plot style and color

%% 
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
    for index_algrm = 1:trackNum
        algrm = trackers{index_algrm};
        name = algrm.name;
        trackerNames{index_algrm} = [ name repmat(char(3),1,legendPadding) 0];
        
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
    clf
    for i = 1:seq_length
        filename = filenames(i).name; 
        id = filename(end-7:end-4);
        img = imread(fullfile(seq.path,filename));

        imshow(img,'border','tight');

        text(5, 20, ['#' id], 'Color','y', 'FontWeight','bold', 'FontSize',idFontSize,'FontName','Times New Roman');
        hlines = [];
        for j = 1:trackNum           
            LineStyle = plotDrawStyle{j}.lineStyle;
            
            rectangle('Position', resultsAll{j}.res(i,:), 'EdgeColor', plotDrawStyle{j}.color, 'LineWidth', LineWidth,'LineStyle',LineStyle);
            hline = line(NaN,NaN,'LineWidth',LineWidth,'LineStyle',LineStyle,'Color',plotDrawStyle{j}.color);
            hlines(j) = hline;
        end
        if showLegend
            ah1 = gca;
            pos = 'south';
            if legendOut
                pos = 'southoutside';
            end
            [legend1,OBJH1,~,~] = legend(ah1,hlines(1:halfTrackNum),trackerNames(1:halfTrackNum),'Interpreter', 'none','FontWeight','bold','fontsize',legendFontSize,'FontName','Times New Roman','Location',pos,'Orientation','Horizontal');
            ah2=axes('position',get(gca,'position'), 'visible','off');
            [legend2,OBJH2,~,~] = legend(ah2,hlines(halfTrackNum+1:trackNum),trackerNames(halfTrackNum+1:trackNum),'Interpreter', 'none','FontWeight','bold','fontsize',legendFontSize,'FontName','Times New Roman','Location',pos,'Orientation','Horizontal');
            
            legend1_pos = get(legend1,'Position');
            set(legend2,'Position',legend1_pos+[0,legend1_pos(4)*1,0,0]);
            
            for j=1:halfTrackNum
                set(OBJH1(j),'String',trackers{j}.name);
            end
            for j=halfTrackNum+1:trackNum
                set(OBJH2(j-halfTrackNum),'String',trackers{j}.name);
            end
            if legBoxOff
                set(legend1,'Box','off')
                set(legend2,'Box','off')
            end
        end
        pause(0.3);
        imwrite(frame2im(getframe(gcf)), [pathSave  filename]);
    end
end