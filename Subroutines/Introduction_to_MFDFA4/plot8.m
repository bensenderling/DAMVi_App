X1=cumsum(multifractal-mean(multifractal));
X2=cumsum(monofractal-mean(monofractal));
X3=cumsum(whitenoise-mean(whitenoise));
X1=transpose(X1);
X2=transpose(X2);
X3=transpose(X3);

scmin=16;
scmax=1024;
scres=19;
exponents=linspace(log2(scmin),log2(scmax),scres);
scale1=round(2.^exponents);
q1=linspace(-5,5,101);
qindex=[21,41,61,81];
m1=1;
for ns=1:length(scale1),
    segments1(ns)=floor(length(X1)/scale1(ns));
    for v=1:segments1(ns),
        Index1=((((v-1)*scale1(ns))+1):(v*scale1(ns)));
        C1=polyfit(Index1,X1(Index1),m1);
        C2=polyfit(Index1,X2(Index1),m1);
        C3=polyfit(Index1,X3(Index1),m1);
        fit1=polyval(C1,Index1);
        fit2=polyval(C2,Index1);
        fit3=polyval(C3,Index1);
        RMS_scale1{ns}(v)=sqrt(mean((X1(Index1)-fit1).^2));
        RMS_scale2{ns}(v)=sqrt(mean((X2(Index1)-fit2).^2));
        RMS_scale3{ns}(v)=sqrt(mean((X3(Index1)-fit3).^2));
    end
    for nq=1:length(q1),
        qRMS1{ns}=RMS_scale1{ns}.^q1(nq);
        qRMS2{ns}=RMS_scale2{ns}.^q1(nq);
        qRMS3{ns}=RMS_scale3{ns}.^q1(nq);
        Fq1(nq,ns)=mean(qRMS1{ns}).^(1/q1(nq));
        Fq2(nq,ns)=mean(qRMS2{ns}).^(1/q1(nq));
        Fq3(nq,ns)=mean(qRMS3{ns}).^(1/q1(nq));
    end
end
for nq=1:length(q1),
    Ch1 = polyfit(log2(scale1),log2(Fq1(nq,:)),1);
    Hq1(nq) = Ch1(1);
    RegLine1(nq,1:length(scale1)) = polyval(Ch1,log2(scale1));
    
    Ch2 = polyfit(log2(scale1),log2(Fq2(nq,:)),1);
    Hq2(nq) = Ch2(1);
    RegLine2(nq,1:length(scale1)) = polyval(Ch2,log2(scale1));

    Ch3 = polyfit(log2(scale1),log2(Fq3(nq,:)),1);
    Hq3(nq) = Ch3(1);
    RegLine3(nq,1:length(scale1)) = polyval(Ch3,log2(scale1));
end
if isempty(find(q1==0, 1))==0,
    qzero=find(q1==0);
    Hq1(qzero)=(Hq1(qzero-1)+Hq1(qzero+1))/2;
    Hq2(qzero)=(Hq2(qzero-1)+Hq2(qzero+1))/2;
    Hq3(qzero)=(Hq3(qzero-1)+Hq3(qzero+1))/2;
end

clear X1 X2 X3
X1=log2(scale1);
YMatrix1=[log2(Fq1(qindex,:));RegLine1(qindex,:)];
YMatrix2=[log2(Fq2(qindex,:));RegLine2(qindex,:)];
YMatrix3=[log2(Fq3(qindex,:));RegLine3(qindex,:)];
X2=q1;
YMatrix4=[Hq1;Hq2;Hq3];
X3=q1(qindex);
YMatrix5=[Hq1(qindex);Hq2(qindex);Hq3(qindex)];
clear scale1 Hq1 Hq2 Hq3 segments1 RegLine1 RegLine2 RegLine3 Ch1 Ch2 Ch3 qRMS1 qRMS2 qRMS3 q1 qindex qzero Fq1 Fq2 Fq3 m1 sindex2 scmin scmax scres exponents RMS_scale1 RMS_scale2 RMS_scale3 fit1 fit2 fit3 C1 C2 C3 Index1

% Create figure
figure1 = figure('PaperSize',[20.98 29.68],'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1,...
    'YTickLabel',{'0.0625','0.125','0.25','0.5','1','2','4','8','16','32'},...
    'YTick',[-4 -3 -2 -1 0 1 2 3 4 5],...
    'XTickLabel',{'16','32','64','128','256','512','1024'},...
    'XTick',[4 5 6 7 8 9 10],...
    'Position',[0.13 0.6013 0.291 0.3412],...
    'LineWidth',2,...
    'FontSize',12);
ylim(axes1,[-4 5]);
hold(axes1,'all');

% Create multiple lines using matrix input to plot
pplot1 = plot(X1,YMatrix1,'Parent',axes1,'LineWidth',2,'Color',[0 0 1]);
set(pplot1(1),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot1(2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot1(3),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none',...
    'LineWidth',0.5);
set(pplot1(4),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot1(7),'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[1 1 1]);

% Create xlabel
xlabel('scale (segment sample size)','FontSize',13);

% Create ylabel
ylabel('Fq in Matlab code 8','FontSize',13);

% Create axes
axes2 = axes('Parent',figure1,...
    'YTickLabel',{'0.0625','0.125','0.25','0.5','1','2','4','8','16','32'},...
    'YTick',[-4 -3 -2 -1 0 1 2 3 4 5],...
    'XTickLabel',{'16','32','64','128','256','512','1024'},...
    'XTick',[4 5 6 7 8 9 10],...
    'Position',[0.5391 0.6013 0.2908 0.3412],...
    'LineWidth',2,...
    'FontSize',12);
xlim(axes2,[4 10]);
ylim(axes2,[-4 5]);
hold(axes2,'all');

% Create multiple lines using matrix input to plot
pplot2 = plot(X1,YMatrix2,'Parent',axes2,'MarkerFaceColor',[1 0 0],...
    'MarkerEdgeColor',[0 0 0],...
    'LineWidth',2,...
    'Color',[1 0 0]);
set(pplot2(1),'Marker','o','LineStyle','none');
set(pplot2(2),'Marker','o','LineStyle','none');
set(pplot2(3),'Marker','o','LineStyle','none');
set(pplot2(4),'Marker','o','LineStyle','none');
set(pplot2(5),'MarkerFaceColor','none','MarkerEdgeColor','auto');
set(pplot2(6),'MarkerFaceColor','none','MarkerEdgeColor','auto');

% Create xlabel
xlabel('scale (segment sample size)','FontSize',13);

% Create axes
axes3 = axes('Parent',figure1,...
    'YTickLabel',{'0.0625','0.125','0.25','0.5','1','2','4','8','16','32'},...
    'XTickLabel',{'16','32','64','128','256','512','1024'},...
    'Position',[0.13 0.11 0.291 0.3412],...
    'LineWidth',2,...
    'FontSize',12);
xlim(axes3,[4 10]);
ylim(axes3,[-4 5]);
hold(axes3,'all');

% Create multiple lines using matrix input to plot
pplot3 = plot(X1,YMatrix3,'Parent',axes3,'LineWidth',2,...
    'Color',[0 0.749 0.749]);
set(pplot3(1),'MarkerFaceColor',[0 0.749 0.749],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot3(2),'MarkerFaceColor',[0 0.749 0.749],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot3(3),'MarkerFaceColor',[0 0.749 0.749],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');
set(pplot3(4),'MarkerFaceColor',[0 0.749 0.749],'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none');

% Create xlabel
xlabel('scale (segment sample size)','FontSize',13);

% Create ylabel
ylabel('Fq in Matlab code 8','FontSize',13);

% Create axes
axes4 = axes('Parent',figure1,...
    'XTickLabel',{'-5','-4','-3','-2','-1','0','1','2','3','4','5'},...
    'XTick',[-5 -4 -3 -2 -1 0 1 2 3 4 5],...
    'Position',[0.5018 0.07806 0.4027 0.4347],...
    'LineWidth',2,...
    'FontSize',13);
ylim(axes4,[0.4 1.6]);
hold(axes4,'all');

% Create multiple lines using matrix input to plot
pplot4 = plot(X2,YMatrix4,'Parent',axes4,'LineWidth',2);
set(pplot4(1),'Color',[0 0 1],'DisplayName','Multifractal');
set(pplot4(2),'Color',[1 0 0],'DisplayName','Monofractal');
set(pplot4(3),'Color',[0 0.749 0.749],'DisplayName','White noise');

% Create multiple lines using matrix input to plot
pplot5 = plot(X3,YMatrix5,'Parent',axes4,'MarkerEdgeColor',[0 0 0],...
    'Marker','o',...
    'LineStyle','none',...
    'LineWidth',2);
set(pplot5(1),'MarkerFaceColor',[0 0 1],'Color',[0 0 1],'LineWidth',0.5);
set(pplot5(2),'MarkerFaceColor',[1 0 0],'Color',[1 0 0]);
set(pplot5(3),'MarkerFaceColor',[0 0.749 0.749],'Color',[0 0.749 0.749]);

% Create xlabel
xlabel('q-order','FontSize',13);

% Create ylabel
ylabel('q-order Hurst exponent Hq','FontSize',13);

% Create legend
legend1 = legend(axes4,'Multifractal','Monofractal','White noise');
set(legend1,'Position',[0.7429 0.3717 0.1319 0.1018]);

% Create line
annotation(figure1,'line',[0.5816 0.5816],[0.07841 0.4065],'LineStyle',':',...
    'LineWidth',2);

% Create line
annotation(figure1,'line',[0.6623 0.6623],[0.07841 0.319],'LineStyle',':',...
    'LineWidth',2);

% Create line
annotation(figure1,'line',[0.7439 0.7431],[0.07841 0.249],'LineStyle',':',...
    'LineWidth',2);

% Create line
annotation(figure1,'line',[0.8238 0.8238],[0.07706 0.1871],'LineStyle',':',...
    'LineWidth',2);

% Create line
annotation(figure1,'line',[0.2778 0.3542],[0.7702 0.7712],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[0 0 1]);

% Create line
annotation(figure1,'line',[0.3533 0.3533],[0.7702 0.8493],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[0 0 1]);

% Create textbox
annotation(figure1,'textbox',[0.1426 0.6627 0.0589 0.04441],...
    'String',{'q = -3'},...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.1425 0.7566 0.0589 0.04441],...
    'String',{'q = 1'},...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.1426 0.7097 0.0589 0.04441],...
    'String',{'q = -1'},...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.1425 0.8089 0.0589 0.04441],...
    'String',{'q = 3'},...
    'FontWeight','bold',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.1434 0.9273 0.1804 0.04038],...
    'String',{'Multifractal time series'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.1434 0.4322 0.1605 0.04038],...
    'String',{'White noise'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.5549 0.9275 0.1899 0.04038],...
    'String',{'Monofractal time series'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create line
annotation(figure1,'line',[0.6267 0.7231],[0.7968 0.7968],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[1 0 0]);

% Create line
annotation(figure1,'line',[0.724 0.7231],[0.7958 0.856],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[1 0 0]);

% Create textbox
annotation(figure1,'textbox',[0.3534 0.7591 0.1231 0.07806],...
    'String',{'q-order Hurst','exponent Hq'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create line
annotation(figure1,'line',[0.2023 0.2882],[0.2789 0.2799],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[0 0.749 0.749]);

% Create line
annotation(figure1,'line',[0.2891 0.2891],[0.2789 0.3122],'LineStyle',':',...
    'LineWidth',2,...
    'Color',[0 0.749 0.749]);

% Create textbox
annotation(figure1,'textbox',[0.7224 0.7525 0.1405 0.07806],...
    'String',{'Constant Hq = H'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.2893 0.2346 0.1405 0.07806],...
    'String',{'Constant Hq = H'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.05308 0.9085 0.04674 0.0821],'String',{'A'},...
    'FontSize',30,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.05485 0.4201 0.04674 0.0821],'String',{'C'},...
    'FontSize',30,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.4715 0.9073 0.04674 0.0821],'String',{'B'},...
    'FontSize',30,...
    'FitBoxToText','off',...
    'LineStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.4316 0.4684 0.03893 0.08345],'String',{'D'},...
    'FontSize',30,...
    'FitBoxToText','off',...
    'LineStyle','none');


clear pplot1 pplot2 pplot3 pplot4 pplot5 legend1 axes1 axes2 axes3 axes4 figure1 ans X1 X2 X3 YMatrix1 YMatrix2 YMatrix3 YMatrix4 YMatrix5
nq=1;ns=1;v=1;