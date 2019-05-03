classdef thData
    properties
        Data table
        fn = ['Town Hall Exit Survey.csv'];
        varQNames
        varQText
        varQIndices = 11:25; %Survey questions begin at Q11, end at Q64
        varRText = {{'Faculty'; 'Undergraduate Researcher'; 'Graduate student'; 'Postdoc'; 'Research Staff'; 'Administrative Staff'};
            
        {'Yes';'No'};
        };
    varRIndices = [1, 2, 2, NaN, NaN, 2, NaN, NaN, NaN, NaN, 2, NaN, NaN, NaN]; %indices of which
    % questions correspond to which sets of response text
    chckboxQuestions = [];
    
    end
    
    properties (Hidden = true)
        titleLim = 60; %characters
    end
    
    methods
        function obj = thData()
            %%% Construct svshData object %%%
            opts = detectImportOptions(obj.fn);
            opts.VariableDescriptionsLine = 2;
            obj.Data = readtable(obj.fn,opts); %response table
            obj.varQNames = obj.Data.Properties.VariableNames;
            obj.varQText = obj.Data.Properties.VariableDescriptions;
            disp('Done.')
        end
        
        function qOutput = getQuestion(obj,qNumber,showSummary)
            if nargin < 3 || isempty(showSummary)
                showSummary = false;
            end
            qIndx = obj.varQIndices(qNumber);
            qOutput = table2array(obj.Data(:,qIndx));
            if showSummary
                summary(qOutput)
            end
        end
        
        function hF = plotHistogram(obj,qNumber,depIndx,newPlot)
            if nargin < 4 || isempty(newPlot)
                newPlot = true;
            end
            if nargin < 3 || isempty(depIndx)
                isDependent = false;
            else
                isDependent = true;
            end
            qOutput = obj.getQuestion(qNumber);
            if isDependent
                qOutput = qOutput(depIndx);
            end
            rIndx = obj.varRIndices(qNumber); %find appropriate response text
            rText = obj.varRText{rIndx};
            isChckbox = false;
            
            if any(qNumber == obj.chckboxQuestions)
                %some questions have a "checkbox" format, requiring dicing
                %up of responses
                isChckbox = true;
                rCount = obj.countResponses(qOutput,rText);
            elseif isnumeric(qOutput)
                %some versions of qualtrics csv have numeric answers
                %instead of text answers
                noAnswer = isnan(qOutput); %delete blanks
                qOutput(noAnswer) = [];
                
                rText = obj.normalizeCase(rText);
                qCat = categorical(rText(qOutput),rText,'Ordinal',true);
                qCat = reordercats(qCat,rText);
            else
                %text responses in qualtrics csv spreadsheet
                noAnswer = ismissing(qOutput);
                qOutput(noAnswer) = [];
                
                rText = obj.normalizeCase(rText);
                qCat = categorical(obj.normalizeCase(qOutput),rText,'Ordinal',true);
                qCat = reordercats(qCat,rText);
            end
            
            if newPlot
                figure;
            end
            
            if isChckbox && isDependent
                hA = histogram('Categories',rText,'BinCounts',rCount,'Normalization','probability');
            elseif isChckbox
                hA = histogram('Categories',rText,'BinCounts',rCount);
            elseif isDependent
                hA = histogram(qCat,'Normalization','probability');
            else
                hA = histogram(qCat);
            end
            set(hA,'linewidth',1);
            set(hA.Parent,'box','off');
            set(hA.Parent,'linewidth',1);
            hF = hA.Parent.Parent;
            %clunky title fix
            titleStr = cell2mat(obj.varQText(obj.varQIndices(qNumber)));
            titleChars = length(titleStr);
            if titleChars > 2*obj.titleLim
                titleStr = {titleStr(1:obj.titleLim); titleStr(1+obj.titleLim:obj.titleLim*2); titleStr(1+obj.titleLim*2:end)};
            elseif titleChars > obj.titleLim
                titleStr = {titleStr(1:obj.titleLim); titleStr(1+obj.titleLim:end)};
            end
            title(titleStr)
        end
        
        function plotHistogramDependent(obj,dependentQ,plotQ,savePlot)
            if nargin < 4 || isempty(savePlot)
                savePlot = false;
            end
            depAnswers = obj.getQuestion(dependentQ);
            rIndx = obj.varRIndices(dependentQ);
            depRText = obj.varRText{rIndx};
            nDependents = numel(depRText);
            for i = 1:nDependents
                depIndx = strcmpi(depRText{i},depAnswers);
                hF = obj.plotHistogram(plotQ,depIndx);
                ylabel([depRText{i} ' fraction']);
                ylim([0 1]);
                if savePlot
                    set(hF,'Renderer','painters');
                    saveName = sprintf('fig%i_%s',plotQ,depRText{i});
                    hgexport(hF,[saveName '.eps']);
                end
            end
            
        end
        
        function qNumber = getQNumber(obj,qName)
            listQNames = fieldnames(obj.Data);
            qMatch = strcmpi(listQNames,qName);
            if any(qMatch)
                qNumber = find(qMatch) - obj.varQIndices(1) + 1; %adjust for non-question data collection
            else
                error('Could not find a question matching the input string.')
            end
        end
        
    end
    
    methods (Static)
        
        function strOut = normalizeCase(strIn)
            if iscellstr(strIn)
                [nRows,~] = size(strIn);
            else
                error('Function only compatible for cell arrays of strings.')
            end
            strOut = lower(strIn);
            for i = 1:nRows
                caseIndx = regexp([' ' strOut{i}],'(?<=\s+)\S','start') - 1;
                strOut{i}(caseIndx) = upper(strOut{i}(caseIndx));
            end
        end
        
        function rCount = countResponses(strIn,rText)
            [nRows,~] = size(strIn);
            [nAnswers,~] = size(rText);
            rCount = zeros(nAnswers,1);
            for i = 1:nRows %for each resopndent
                rIndx = regexp(strIn{i,1},rText); %find reg exp matching known answers
                for j = 1:nAnswers %for each answer, add one if there was a matching reg exp
                    rCount(j) = rCount(j) + ~isempty(rIndx{j});
                end
            end
        end
        
    end
    
end