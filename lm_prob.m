function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = 0;
    % vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = 0;
    % vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
  res = 1;

  for element=1:length(words)-1
    %biword = strcat(words(element), {'_SPACE_'}, words(element+1));
    word0 = words(element);
    word1 = words(element+1);
    wt0 = char(word0);
    %unigram = char(word);
    wt1 = char(word1);
    %bigram = char(biword);

    if isfield(LM.bi, wt0) == 0
        count_wt0_wt1 = 0;
      if isfield(LM.uni, wt0) == 0
        count_wt0 = 0;
      else
        count_wt0 = LM.uni.(wt0);
      end
    else
      if isfield(LM.bi.(wt0), wt1) == 0
        count_wt0_wt1 = 0;
      else
        count_wt0_wt1 = LM.bi.(wt0).(wt1);
      end
      if isfield(LM.uni, wt0) == 0
        count_wt0 = 0;
      else
        count_wt0 = LM.uni.(wt0);
      end
    end
 
    numerator = count_wt0_wt1 + delta;
    denominator = count_wt0 + (delta * vocabSize);
    
    if (numerator == 0) && (denominator == 0)
      res = 0;
      break;
      % res = res + logProb;
    else
      res = res * (numerator/denominator);
    end
  end
logProb = log2(res);
