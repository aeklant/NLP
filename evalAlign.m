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
lm_type      = '';
delta        = 0;
vocabSize    = 0; 
numSentences = 1000;

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train( trainDir, 'e', fn_LME );
LME = load('fn_LM_e', '-mat', 'LM');
fields = fieldnames(LME.LM.bi);

%{
for i=1:length(fields)
  subfields = fieldnames(LME.LM.bi.(fields{i}));
  for j=length(subfields)
    fields{i};
    subfields{j};
    LME.LM.bi.(fields{i}).(subfields{j});
  end
  %['the word ', fields{i}, ' appears ', LME.uni.(fields{i}), ' times']
end
%}

%LMF = lm_train( trainDir, 'f', fn_LMF );
LMF = load('fn_LM_f', '-mat', 'LM');

% Train your alignment model of French, given English 
%AMFE = align_ibm1( trainDir, numSentences, 5, './am_FE' )

AMFE = load('am.mat', '-mat', 'AM');
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
lines = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');

reference1 = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');
reference2 = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e', '%s', 'delimiter', '\n');
reference3 = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');

for l=1:length(lines)
  fre = preprocess(lines{l}, 'f');

  vocabSize = length(fieldnames(LME.LM.uni));
  % Decode the test sentence 'fre'
  eng = decode( fre, LME.LM, AMFE.AM, lm_type, delta, vocabSize );

  % Calculate brevity
  if abs(length(eng) - length(strsplit(' ', reference1{l}))) < abs(length(eng) - length(strsplit( ' ', reference2{l})))
    if abs(length(eng) - length(strsplit( ' ', reference1{l}))) < abs(length(eng) - length(strsplit( ' ', reference3{l})))
      nearest_length = length(strsplit( ' ', reference1{l}));
    else
      nearest_length = length(strsplit( ' ', reference3{l}));
    end
  else
    if abs(length(eng) - length(strsplit( ' ', reference2{l}))) < abs(length(eng) - length(strsplit( ' ', reference3{l})))
      nearest_length = length(strsplit( ' ', reference2{l}));
    else
      nearest_length = length(strsplit( ' ', reference3{l}));
    end
  end

  brevity = nearest_length/length(eng);
  if brevity < 1
    BP = 1;
  else
    BP = exp(1-brevity);
  end

 % Calculate unigram precision
  unigram_count = 0;

  ref1_split = strsplit(' ', reference1{l});
  ref2_split = strsplit(' ', reference2{l});
  ref3_split = strsplit(' ', reference3{l});

  for i=1:length(eng)
  % Check references
    if ~isempty(find(strcmp(eng{i}, ref1_split))) || ~ isempty(find(strcmp(eng{i}, ref2_split))) || ~isempty(find(strcmp(eng{i}, ref3_split)))
      unigram_count = unigram_count + 1;
      continue;
    end
  end
 
  % Calculate BLEU score
  BLEU_score = BP * unigram_count
end
