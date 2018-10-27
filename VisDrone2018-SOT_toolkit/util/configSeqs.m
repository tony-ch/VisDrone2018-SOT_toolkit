function seqs = configSeqs(datasetPath)

d = dir(datasetPath);
isub = [d(:).isdir]; 
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

seqs = cell(1, length(nameFolds));
for i = 1:length(nameFolds)
    seq.name = nameFolds{i};
    seq.path = fullfile(datasetPath, nameFolds{i});
    seq.startFrame = 1;
    seq.endFrame = length(dir(fullfile(seq.path)));
    seqs{i} = seq;
end
