function seqs = configSeqs(datasetPath, seqlistPath)

test_seq_file = fullfile(datasetPath,seqlistPath);
if exist(test_seq_file,'file')
    % run eval on seq listed in this file
    nameFolds = importdata(test_seq_file);
else
    d = dir(datasetPath);
    isub = [d(:).isdir]; 
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
end

seqs = cell(1, length(nameFolds));
for i = 1:length(nameFolds)
    seq.name = nameFolds{i};
    seq.path = fullfile(datasetPath, nameFolds{i});
    seq.startFrame = 1;
    seq.endFrame = length(dir(fullfile(seq.path,'*.jpg')));
    seqs{i} = seq;
end
