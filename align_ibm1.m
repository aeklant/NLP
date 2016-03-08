function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  %eng = {};
  %fre = {};

  i = 0;
  files_eng = dir([mydir, '*.e' ]);
  files_fre = dir([mydir, '*.f' ]);
  for file = files_eng'
    f_name = [mydir, file.name];
    fid = fopen(f_name);
    
    tline = fgetl(fid);
    while ischar(tline)
      if i >= numSentences
        break;
      end
      eng{i+1} = strsplit(preprocess(tline, 'e'), ' ');
      tline = fgetl(fid);

      i = i + 1;
    end
  end

  i = 0;
  for file = files_fre'
    f_name = [mydir, file.name];
    fid = fopen(f_name);
    
    tline = fgetl(fid);
    while ischar(tline)
      if i >= numSentences
        break;
      end
      fre{i+1} = strsplit(preprocess(tline, 'f'), ' ');
      tline = fgetl(fid);

      i = i + 1;
    end
    if i >= numSentences
      break;
    end
  end

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;

    for i=1:length(eng)
      celldata_eng = cellstr(eng{i});
      celldata_fre = cellstr(fre{i});
      for j=2:length(celldata_eng)-1
        for k=2:length(celldata_fre)-1
          % if isfield(AM, celldata_eng{j}) == 1
            % if isfield(AM.(celldata_eng{j}), celldata_fre{k}) == 1
            %   AM.(celldata_eng{j}).(celldata_fre{k}) = 1/((1/AM.(celldata_eng{j}).(celldata_fre{k}) + 1));
            % else
              AM.(celldata_eng{j}).(celldata_fre{k}) = 1;
            % end
          % else
            % AM.(celldata_eng{j}).(celldata_fre{k}) = 1;
          % end
        end
      end
    end 

    % TODO: Make sure to print the values and then double check
    % for fields = fieldnames(AM)
    %   AM.(fields)
    %   for subfields = fieldnames(AM.(fields))
    %     AM.(fields).(subfields)
    %   end
    % end
    %
    fields = fieldnames(AM);
    for i=1:length(fields)
      % field = fields{i}
      subfields = fieldnames(AM.(fields{i}));
      for j=1:length(subfields)
        % subfield = subfields{j}
        AM.(fields{i}).(subfields{j}) = 1/length(subfields);
        AM.(fields{i}).SENTSTART = 0;
        AM.(fields{i}).SENTEND = 0;
        % value = AM.(fields{i}).(subfields{j})
      end
    end
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  tcount = {}; 
  total = {}; 
    fields = fieldnames(t);
    for i=1:length(fields)
      % field = fields{i}
      subfields = fieldnames(t.(fields{i}));
      for j=1:length(subfields)
        % subfield = subfields{j}
        fields{i}; 
        subfields{j};
        t.(fields{i}).(subfields{j});
        % value = AM.(fields{i}).(subfields{j})
      end
    end

  for i=1:length(eng)
    celldata_eng = cellstr(eng{i})
    celldata_fre = cellstr(fre{i})
    for j=2:length(celldata_fre)-1
      denom_c = 0;
     for k=2:length(celldata_eng)-1
       freq = sum(strcmp(celldata_fre{j}, celldata_fre));
       celldata_eng{k}
       celldata_fre{j}
       denom_c = denom_c + t.(celldata_eng{k}).(celldata_fre{j}) * freq;
     end
     for k=2:length(celldata_eng)-1
       freq_fre = sum(strcmp(celldata_fre{j}, celldata_fre));
       freq_eng = sum(strcmp(celldata_eng{k}, celldata_eng));

       % if isfield(tcount, celldata_eng{k}) & strcmp(celldata_eng{k}, 'SENTSTART') == 0 & strcmp(celldata_eng{k}, 'SENTEND') == 0
       if isfield(tcount, celldata_eng{k}) 
         if isfield(tcount.(celldata_eng{k}), celldata_fre{j}) 
           tcount.(celldata_eng{k}).(celldata_fre{j}) = tcount.(celldata_eng{k}).(celldata_fre{j}) + (t.(celldata_eng{k}).(celldata_fre{k}) * freq_fre * freq_eng / denom_c)
         else
           tcount.(celldata_eng{k}).(celldata_fre{j}) = t.(celldata_eng{k}).(celldata_fre{k}) * freq_fre * freq_eng / denom_c
         end
       else
         % if strcmp(celldata_eng{k}, 'SENTSTART') == 0 & strcmp(celldata_eng{k}, 'SENTEND') == 0 & strcmp(celldata_fre{j}, 'SENTSTART') == 0 & strcmp(celldata_fre{j}, 'SENTEND') == 0
           tcount.(celldata_eng{k}).(celldata_fre{j}) = t.(celldata_eng{k}).(celldata_fre{k}) * freq_fre * freq_eng / denom_c
         % end
       end

      end
      for w_eng = total
        for w_fre = tcount.(w_eng)
          t.(w_eng).(w_fre) = tcount.(w_eng).(w_fre) / total.(w_eng)
        end
      end
    end
  end
  
end
