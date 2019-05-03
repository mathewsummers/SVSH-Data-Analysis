if ~exist('d','var')
    d = svshData();
end
qList = [45:51];
yBounds = [0 200];%[0 50];%[0 150];
%[]; 1
%[]; 2 (also saved maximized version + emf)
%[0 120]; 3
%[0 50]; 4:6
%[0 200]; 7:9
%[0 180]; 10:16
%[0 150]; 17:30
%[]; 31
%[0 160]; [32 34] (emf too)
%[0 120]; 36:38
%[0 150]; [39 43] (emf too)
%[0 90]; 41:42
%[0 200]; 45:51

saveFolder = 'C:\Users\Mathew\Desktop\ForMathew\SVSH\Report Figures\Vector Format';
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