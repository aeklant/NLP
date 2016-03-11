%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
%trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/'
trainDir      = './train_test/'
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = './fn_LME';
fn_LMF       = './fn_LMF';
lm_type      = 'smooth';
delta        = 0.5;
% vocabSize    = TODO; 
numSentences = 1000;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
fields = fieldnames(LME.bi);

for i=1:length(fields)
  subfields = fieldnames(LME.bi.(fields{i}));
  for j=length(subfields)
    fields{i}
    subfields{j}
    LME.bi.(fields{i}).(subfields{j})
  end
  %['the word ', fields{i}, ' appears ', LME.uni.(fields{i}), ' times']
end

LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences, 5, './am_FE' )
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');

for l=1:length(lines)
  fre = preprocess(lines{l}, 'f');

  vocabSize = length(fieldnames(LME.uni));
  % Decode the test sentence 'fre'
  eng = decode( fre, LME, AMFE, lm_type, delta, vocabSize );
end

% TODO: perform some analysis
% add BlueMix code here 

[status, result] = unix('')
