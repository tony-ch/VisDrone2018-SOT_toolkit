function plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName,xLabelName,yLabelName,figName,configPlot)

for idxTrk = 1:numTrk
    %each row is the sr plot of one sequence
    tmp = aveSuccessRatePlot(idxTrk, idxSeqSet,:);
    aa = reshape(tmp,[length(idxSeqSet),size(aveSuccessRatePlot,3)]);
    aa = aa(sum(aa,2)>eps,:);
    bb = mean(aa, 1);
    switch rankingType
        case 'AUC'
            perf(idxTrk) = mean(bb);
        case 'threshold'
            perf(idxTrk) = bb(rankIdx);
    end
end

[~,indexSort] = sort(perf,'descend');


fontSize = configPlot.fontSize;%16
fontSizeLegend = configPlot.fontSizeLegend;%10
lineWidth = configPlot.lineWidth;%2
fontSizeAxes = configPlot.fontSizeAxes;%14

i=1;
figure1 = figure;

axes1 = axes('Parent',figure1,'FontSize',fontSizeAxes,'FontName','Times New Roman');
for idxTrk = indexSort(1:rankNum)
    tmp = aveSuccessRatePlot(idxTrk,idxSeqSet,:);
    aa = reshape(tmp,[length(idxSeqSet),size(aveSuccessRatePlot,3)]);
    aa = aa(sum(aa,2)>eps,:);
    bb = mean(aa, 1);
    switch rankingType
        case 'AUC'
            score = mean(bb);
            tmp=sprintf('%.1f', score*100);
            disp([nameTrkAll{idxTrk} ' : ' tmp]);
        case 'threshold'
            score = bb(rankIdx);
            tmp=sprintf('%.1f', score*100);
            disp([nameTrkAll{idxTrk} ' : ' tmp]);
    end    
    
    tmpName{i} = [nameTrkAll{idxTrk} ' [' tmp ']'];
    % h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{i}.color, 'lineStyle', plotDrawStyle{i}.lineStyle,'lineWidth', 1,'Parent',axes1);
    h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{idxTrk}.color, 'lineStyle', plotDrawStyle{idxTrk}.lineStyle,'lineWidth', lineWidth,'Parent',axes1);
    hold on
    i=i+1;
end


legend(tmpName,'Interpreter', 'none','fontsize',fontSizeLegend,'FontName','Times New Roman');
title(titleName,'fontsize',fontSize,'FontName','Times New Roman');
xlabel(xLabelName,'fontsize',fontSize,'FontName','Times New Roman');
ylabel(yLabelName,'fontsize',fontSize,'FontName','Times New Roman');
hold off

saveas(gcf,figName,'png');

end