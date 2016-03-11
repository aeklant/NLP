function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS

  csc401_a2_defns
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  outSentence = regexprep(outSentence, ['(\S)(\.|\?|!)+(\s{1})' (CSC401_A2_DEFNS.SENTEND)], ['$1 $2$3' CSC401_A2_DEFNS.SENTEND]);

  outSentence = regexprep(outSentence, '(`*|,|;|:|\(|\)|[|]|-|\+|=|<|>|"){1}', ' $1 ');

  switch language
   case 'e'
     outSentence = regexprep(outSentence, '(\''s|\''re|\''m|\''ve|\''d|\''ll|n\''t|\'' )', ' $1 ');

   case 'f'
     outSentence = regexprep(outSentence, '(\s(?=[a-z])[^aeiou]\'')', ' $1 ');
     outSentence = regexprep(outSentence, '(\s(qu)\'')', ' $1 ');
     outSentence = regexprep(outSentence, '(\s(puisqu|lorsqu)\'')', ' $1 ');

     outSentence = regexprep(outSentence, '\s(d'')\s(abord|accord|habitude|ailleurs)', ' $1$2 ');

  end

  outSentence = regexprep(outSentence, '\s+', ' ');

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

