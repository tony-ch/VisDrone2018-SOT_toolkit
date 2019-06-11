clear; close all; clc;
% load('./evalRes/attr.mat');
% attr_result = result;
% attr_names = {'Overall','Occlusion','Camera~motion','Size~change',...
%    'Illumination~change','Motion~change', 'Unassigned'};

load('./evalRes/result.mat');
metricType = {'overlap','error'};
attr_result = result.(metricType{2});
num_tracker_show = 4; % only write top4
attr_names = {'Overall','Aspect Ratio~Change','Background~Clutter','Camera~Motion','Fast~Motion','Full~Occlusion','Illumination~Variation','Low Resolution',...
           'Out~of~View','Partial~Occlusion','Similar~Object','Scale~Variation','Viewpoint~Change'};

tracker_names = fieldnames(attr_result);
legend_names = fieldnames(attr_result.(tracker_names{1}));
num_tracker = length(tracker_names);
num_attr = length(legend_names);
attrRes = zeros(num_tracker,num_attr);
for i = 1:num_tracker
    for j = 1:num_attr
        attrRes(i,j) = attr_result.(tracker_names{i}).(legend_names{j});
    end
end
[s,sorted_index] = sort(attrRes(:,1),'descend'); % rank by baseline eao

tracker_names = tracker_names(sorted_index(1:num_tracker_show));
attrRes = attrRes(sorted_index(1:num_tracker_show),:);

attrRes(:,num_attr+1) = attrRes(:,1);

a_min = min(attrRes,[],1);
a_max = max(attrRes,[],1);

t = (0:1/num_attr:1)*2*pi;
h = [];
masker_shape = {'x','.'};
masker_size = {10,40};
color_masker = hsv(num_tracker_show);
color_line = color_masker*0.4 +ones(num_tracker_show,3)*0.6;
ax = polaraxes;

for i = 1:num_tracker_show
    h(i) = polarplot(t, (attrRes(i,:)-a_min)./(a_max-a_min)+0.2, 'MarkerSize',masker_size{mod(i,2)+1},...
        'Marker',masker_shape{mod(i,2)+1},'LineWidth',2,...
        'Color',color_line(i,:),'MarkerEdgeColor',color_masker(i,:)); hold on;
end

polarplot(t, 0.5, 'LineWidth',2, 'Color',[0,0,0]); hold on;


grid off
legend_names = attr_names;
for i = 1:num_attr
    legend_names{i} = ['\begin{tabular}{c}', legend_names{i}, '\\',...
        [num2str(a_min(i),'(%.3f,') num2str(a_max(i),'%.3f)')], '\end{tabular}'];
end
ax.ThetaTickLabels = legend_names;
ThetaTick = (0:1/num_attr:1)*360;
ax.ThetaTick = ThetaTick(1:end-1);
ax.RTickLabels = [];
ax.TickLabelInterpreter = 'latex';

for i = 1:num_tracker_show %
    tracker_names{i} = strrep(tracker_names{i},'_','\_');
end 

ah1 = gca;
legend1=legend(ah1,h(1:num_tracker_show/2),tracker_names(1:num_tracker_show/2),'Orientation','horizontal','Location','southoutside');
ah2=axes('position',get(gca,'position'), 'visible','off');
legend2=legend(ah2,h(num_tracker_show/2+1:num_tracker_show),tracker_names(num_tracker_show/2+1:num_tracker_show),'Orientation','horizontal','Location','southoutside');
set(legend1,'Box','off')
set(legend2,'Box','off')
legend1_pos = get(legend1,'Position');
set(legend2,'Position',legend1_pos-[0,legend1_pos(4)*1.2,0,0]);

% set(gcf, 'position', [500 300 800 800]);
saveas(gcf,'./evalRes/figs/attr_result','pdf')
saveas(gcf,'./evalRes/figs/attr_result','png')

