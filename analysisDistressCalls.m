CONDS={'THREATLEVEL','TRIGGER','DISTONSET','DISTONSET2','M_APPROACH',...
    'M_VOC','M_COLLECTION','M_GAZE'};
TITL={'Context','Trigger [detailed]','Distance','Distance [detailed]',...
    'Mother''s approach','Mother''s collection','Mother''s vocalization','Mother''s gaze'};

figure(1)
subplot(3,3,4)
hold off
maxFeat=104;
numFeat=10;
RX=[];
PX=[];
for ux=1
    currfeat=RESULTS.CEP.(CONDS{ux}).ACCURACY.FEAT;
    currval=RESULTS.CEP.(CONDS{ux}).ACCURACY.RBF;

    if ux==1 
        ct=1;
        interst=[1,2,4];
        cols=[1 0 0; 0 0 1;0 1 0 ];
        for ik=1:length(interst)-1
            for ij=ik+1:length(interst)
                  xs1= currfeat{interst(ik)}.featnum(1:numFeat);
                  
                  xs2= currfeat{interst(ij)}.featnum(1:numFeat);
                  
                 loglog([0.1 100],[0.1 100],'-','Color',[.5 .5 .5])
                 hold on
                 loglog(xs2,xs1,'o','MarkerEdgeColor',cols(ct,:),'MarkerFaceColor',cols(ct,:),...
                    'Markersize',3)
                 hold on
                 [R,P]=corr(xs1',xs2','Type','Spearman')
                 Rx(ct)=R;
                 Px(ct)=P;
                 [b,bint]=regress(xs1',[ones(length(xs2),1),xs2'],0.05)
                 loglog(1:100,b(2) * [1:100] + b(1),'-','Color',cols(ct,:),'Linewidth',1)
                 ct=ct+1;
                 axis([1 maxFeat 1 maxFeat])
                 axis square
                
                set(gca, ...
                  'Box'         , 'off'     , ...
                  'TickDir'     , 'out'     , ...
                  'TickLength'  , [.01 .01] , ...
                  'XMinorTick'  , 'off'      , ...
                  'YMinorTick'  , 'off'      , ...
                  'XGrid'       , 'on'      , ...
                  'YGrid'       , 'on'      , ...
                  'XColor'      , [0 0 0], ...
                  'YColor'      , [0 0 0], ...
                  'XTick'       , [1,2,3,5,10,20,50,100], ...
                  'YTick'       , [1,2,3,5,10,20,50,100], ...
                  'LineWidth'   , 1         );
                axis([10^0 10^2 10^0 10^2])

                xlabel('Best features of comparison 1');
                ylabel('Best features of comparison 2')
%                   title(TITL(plotorder(ct)))
            end
        end
    end
end
text(.45,180,'C','Fontsize',18)

loglog(8,2,'<','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0])
text(10,2,'\it R','Interpreter','tex')
text(13,2,strcat(' = ',num2str(round(Rx(3),2))))

subplot(3,3,5)
hold off
plot([1 2]-2,[3 3],'r','LineWidth',2)
hold on
plot([1 2]-2,[2 2],'g','LineWidth',2)
plot([1 2]-2,[1 1],'b','LineWidth',2)
axis([-1 22 0 5])              
text(2.25, 3.2, 'No threat vs Threat &')
text(2.25, 2.8, 'No threat vs Separation')

text(2.25, 2.2, 'No threat vs Threat &')
text(2.25, 1.8, 'Threat vs Separation')

text(2.25, 1.2, 'No threat vs Separation &')
text(2.25, .8, 'Threat vs Separation')

axis square
axis off


numfeatures=[5:1:maxFeat];
RX=[];
PX=[];
for uz=1:length(numfeatures)
    numFeat=numfeatures(uz);
    ct=1;
    clear Px, clear Rx
    cols=[1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1]; % r g b y m t 
    for ux=5:7
        for uq=ux+1:8
            currfeat=RESULTS.CEP.(CONDS{ux}).ACCURACY.FEAT;
            currval=RESULTS.CEP.(CONDS{ux}).ACCURACY.RBF;
            xs1= currfeat{1}.featnum(1:numFeat);
            currfeat2=RESULTS.CEP.(CONDS{uq}).ACCURACY.FEAT;
            currval2=RESULTS.CEP.(CONDS{uq}).ACCURACY.RBF;
            xs2= currfeat2{1}.featnum(1:numFeat);

            [R,P]=corr(xs1',xs2','Type','Spearman','tail','both');
            Rx(ct)=R;
            Px(ct)=P;
            ct=ct+1;
        end
    end
    PX=[PX;Px];
    RX=[RX;Rx];
end
PX(find(PX>=.05))=0
PX(find(PX~=0))=1


figure(7)
set(gcf, 'Position',[100 100 1600 500]);

lab={'B','C','D','E'};
base=mean(METHDS{1});
for i=1:4
%     subplot(2,5,1+i)
    subplot(1,5,1+i)

    if i==1
        id1=1;
        id2=2;
    else
        id1=1;
        id2=2;
    end
    obs=METHDS{1};
    grp=eval(CONDS{4+i});
    obsx=obs(find(grp==id1 | grp==id2),:);
    grpx=grp(find(grp==id1 | grp==id2));  
    fs=RESULTS.CEP.(CONDS{4+i}).ACCURACY.FEAT{1}.featnum(1:10);
    
    hold off
    plot([-.075 .075],[-.075 .075],'-','Color','k')

    hold on
    plot(median(obsx(find(grpx==id1),:),1)-base,median(obsx(find(grpx==id2),:),1)-base,'.','MarkerEdgeColor',[.5 .5 .5],...
        'MarkerFaceColor',[.5 .5 .5])

    plot(median(obsx(find(grpx==id1),fs),1)-base(fs),...
        median(obsx(find(grpx==id2),fs),1)-base(fs),'bo')

    axis square
    set(gca, ...
      'Box'         , 'off'     , ...
      'TickDir'     , 'out'     , ...
      'TickLength'  , [.01 .01] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'XGrid'       , 'on'      , ...
      'YGrid'       , 'on'      , ...
      'XColor'      , [0 0 0], ...
      'YColor'      , [0 0 0], ...
      'XTick'       , [-.1 : .05:.1], ...
      'XTickLabel'       , {'-.1','-.05','0','.05','.1'}, ...
      'YTick'       , [-.1 : .05:.1], ...
      'YTickLabel'       , {'-.1','-.05','0','.05','.1'}, ...
      'LineWidth'   , 1         );
    axis([-.11 .11 -.11 .11])
    text(-.15,.16,lab{i},'Fontsize',18)
    if i==1
       ylabel('No')
       xlabel('Yes')
    end

end

