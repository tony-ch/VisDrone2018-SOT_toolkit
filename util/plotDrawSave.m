function eval_res = plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName,xLabelName,yLabelName,figName,configPlot)

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
location = configPlot.location;

i=1;

figure1 = figure;

axes1 = axes('Parent',figure1);


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
    eval_res{i} = {nameTrkAll{idxTrk},tmp};
    % h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{i}.color, 'lineStyle', plotDrawStyle{i}.lineStyle,'lineWidth', 1,'Parent',axes1);
    h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{idxTrk}.color, 'lineStyle', plotDrawStyle{idxTrk}.lineStyle,'lineWidth', lineWidth,'Parent',axes1);
    hold on
    i=i+1;
end

axes1.FontName = 'Times New Roman';
axes1.FontSize = fontSizeAxes;
axes1.FontWeight = 'bold';

legend(tmpName,'Interpreter', 'none','fontsize',fontSizeLegend,'FontWeight','bold','FontName','Times New Roman','Location',location);
title(titleName,'fontsize',fontSize,'FontWeight','bold','FontName','Times New Roman');
xlabel(xLabelName,'fontsize',fontSize,'FontWeight','bold','FontName','Times New Roman');
ylabel(yLabelName,'fontsize',fontSize,'FontWeight','bold','FontName','Times New Roman');
hold off

saveas(gcf,figName,'png');

end