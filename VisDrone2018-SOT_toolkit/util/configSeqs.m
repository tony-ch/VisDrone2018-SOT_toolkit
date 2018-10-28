function seqs = configSeqs(datasetPath)

d = dir(datasetPath);
isub = [d(:).isdir]; 
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

seqs = cell(1, length(nameFolds));
for i = 1:length(nameFolds)
    seq.name = nameFolds{i};
    seq.startFrame = 1;
    seq.endFrame = length(dir(fullfile(datasetPath, nameFolds{i})));
    seqs{i} = seq;
end
