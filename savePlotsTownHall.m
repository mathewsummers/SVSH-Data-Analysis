if ~exist('d','var')
    d = thData();
end
qList = [1 2 3 6 11];
yBounds = [0 50];%
%[]; 1
%[0 160]; [32 34] (emf too)
%[0 120]; 36:38
%[0 150]; [39 43] (emf too)
%[0 90]; 41:42
%[0 200]; 45:51

saveFolder = 'C:\Users\Mathew\Desktop\ForMathew\SVSH\Exit Survey Figures';
oldDir = cd(saveFolder);

nFigs = numel(qList);
for i = 1:nFigs
    hF = d.plotHistogram(qList(i));
    if ~isempty(yBounds)
        ylim(yBounds);
    end
    set(hF,'Renderer','painters');
    %set(hF.Children.Children,'FaceColor','red');
    fn = sprintf('fig%i',qList(i));
    hgexport(hF,[fn '.eps']);
    %saveas(hF,fn,'eps');
end

cd(oldDir);