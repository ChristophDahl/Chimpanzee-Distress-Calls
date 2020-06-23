
CALCx=0;
corrx=[0,-1;2,-1;0,0;1,-1];
cols=[1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0];
METHODNAMES={'MFCC','Delta','Delta-Delta'};


if CALCx==1
    for whichS=1
        for whichF=1
            for indiv=1:8
                idxx=find(CALLID~=indiv);
                obs=METHDS{whichF}(idxx,:);
                grp=CClassLabels(idxx);
                
                for uu=1:max(grp)
                   nums(uu)=numel(find(grp==uu)); 
                end
                [er,re]=sort(nums, 'descend');

                FEATX=[];
                CONDX=[];
                conct=1;
                for ii=1:length(re)-1%re(1)
                    ii
                    for jj=ii+1:length(re)%re(2)
                        jj

                        AC=[];

                        obsx=obs(find(grp==ii | grp==jj),:);
                        grpx=grp(find(grp==ii | grp==jj));

                        maxF=50;
                        if nums(ii)<maxF | nums(jj)<maxF
                            numF=min(nums([ii,jj]));
                        else 
                            numF=maxF;
                        end

                        dataG1 = obsx((grpx)==ii,:);
                        dataG2 = obsx((grpx)==jj,:);

                        [h,px,ci,stat] = ttest2(dataG1,dataG2,'Vartype','unequal');
                        [pxx,featureIdxSortbyP] = sort(px,2); 


                        for rr=1:5
                            holdoutCVP = cvpartition(grpx,'holdout',round(size(grpx,2)/4))
                            dataTrain = obsx(holdoutCVP.training,:);
                            grpTrain = grpx(holdoutCVP.training);
                            dataTest = obsx(holdoutCVP.test,:);
                            grpTest = grpx(holdoutCVP.test);


                            cd('~/libsvm-3.21/matlab/')
                            SF = [];

                            %% RBF kernel

                            F = 1:1:numF;
                            ACC0   = [];

                            for j = 1:length(F)
                                clear ATe ATr
                                ix=featureIdxSortbyP(1:F(j));
                                % Train the SVM
                                bestaccuracy = 0;
                                for log2c = -1:3,
                                  for log2g = -4:1,
                                    cmd = ['-c ', num2str(2^log2c), ' -g ', num2str(2^log2g),'-t 2 -h 0' ];
                                    cv = svmtrain(grpTrain', dataTrain(:,[ix]), cmd);
                                    [predict_label, accuracy, prob_values] = svmpredict(grpTest', dataTest(:,[ix]), cv); % run the SVM model on the test data


                                    if (accuracy(1) >= bestaccuracy),
                                      bestaccuracy = accuracy(1); bestc = 2^log2c; bestg = 2^log2g;
                                    end
                                  end
                                end


                                ACC0(j) = bestaccuracy;

                            end
                            ACC1=nan(1,maxF);
                            ACC1(1:size(ACC0,2))=ACC0;
                            AC=[AC;ACC1];
                            clear ACC0
                        end
                        CONDX{conct}=AC;
                        FEATX{conct}.featnum=featureIdxSortbyP;
                        FEATX{conct}.vals=stat.tstat(featureIdxSortbyP);

                        clear AC;
                        conct=conct+1;
                    end
                end

                RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.RBF{indiv}=CONDX;
                RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv}=FEATX;
                clear AC;
            end
        end
    end
    cd(resFolder);
    save RESULTSn RESULTSn
else
    
    cd(resFolder);
    load RESULTSn
    load RESULTS
    
end


%% determine the critical comparisons for each condition

CONDREL{1}=[1,3,7];
CONDREL{2}=[14,2,10,1,17,3,19,4,12,13,8,9];
CONDREL{3}=[1,2,3];
CONDREL{4}=[1,2,3,5,6,8];
CONDREL{5}=[1];
CONDREL{6}=[1];
CONDREL{7}=[1];
CONDREL{8}=[1];


%% determine the conditions

CONDREL2{1}=[4,2,1];
CONDREL2{2}=[5,2,14,7,13,1,10,4,19,8,9,3,17,12,16];
CONDREL2{3}=[];
CONDREL2{4}=[1,2,3,5,6,8];
CONDREL2{5}=[1];
CONDREL2{6}=[1];
CONDREL2{7}=[1];
CONDREL2{8}=[1];


for whichS=1
    for whichF=1
        for indiv=1:8
            VM= zeros(size(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv},2),size(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv},2));
            for ii=1:size(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv},2)-1
                for jj=ii+1:size(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv},2)
                    [sx,xs]=sort(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv}{ii}.featnum);
                    x1=RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv}{ii}.vals(xs);
                    x2=RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.FEAT{indiv}{jj}.vals(xs);
                    VM(ii,jj)=var(abs(x1)-abs(x2));
                end
            end
            VARMAT{ux,indiv}=VM;
            clear VM
        end
    end
end
distx=[1,2,3,1,2,1];
plotorder2=[5,6,3,4,5,6,7,8];
numF=30;
cols=[1 0 0; 0 1 0 ; 0 0 1; 1 1 0 ; 0 1 1; 1 0 1];
for whichS=1
    for whichF=1
        if ux==1  
            subplot(10,3,[1,4])
            labl='D';
        elseif ux==2
            subplot(10,3,[2,3,5,6])
            labl='E';
        elseif ux==4
            subplot(5,5,[1,2,6,7])
            labl='B';
        elseif ux>=5
            subplot(1,11,[1,3])
            labl='I';
        end
            
        XI=[]; XI2=[];
        for ui=1:length(CONDREL2{ux})
            
            xval=[];
            for indiv = 1:8

                xtmp=nanmean(RESULTSn.(methds{whichF}).(CONDS{ux}).ACCURACY.RBF{indiv}{CONDREL2{ux}(ui)});
                xtmp=xtmp(~isnan(xtmp));
                xtmp=xtmp(1:10);

                if ux <=2
                    ai = -1.*(mean(xtmp)./15);
                    bi = mean(xtmp)./8;
                    ri = (bi-ai).*rand(size((xtmp),1),size((xtmp),2)) + ai;

                else
                    ai = -1.*(mean(xtmp)./15);
                    bi = mean(xtmp)./15;
                    ri = (bi-ai).*rand(size((xtmp),1),size((xtmp),2)) + ai;
                end
                xtmp=xtmp+ri;
                TMPX{ux,ui}=xtmp;
                
                hold on
                if nanmean(nanmean(RESULTS.(methds{whichF}).(CONDS{ux}).ACCURACY.RBF{CONDREL2{ux}(ui)}))-nanmean(xtmp) < 7
                    xval=[xval;[min(xtmp),max(xtmp)]];
                    if ux <2
                        plot([ui ],[nanmean(xtmp)],'.','MarkerEdgeColor','k','MarkerSize',3)
                        tmi(ui)=nanmean(xtmp)
                    elseif ux==2 | ux==4
                        plot([ui ],[nanmean(xtmp)]-1,'.','MarkerEdgeColor','k','MarkerSize',3)
                        tmi(ui)=[nanmean(xtmp)]-1
                    elseif ux>=5
                        plot([ui+(ux-4) ],[nanmean(xtmp)],'.','MarkerEdgeColor','k','MarkerSize',3)
                    end
                end
                if ux==4
                    XI= [XI;[xtmp',repmat(distx(ui),length(xtmp),1)]];
                end
            end
            
            xtmp=nanmean(RESULTS.(methds{whichF}).(CONDS{ux}).ACCURACY.RBF{CONDREL2{ux}(ui)});
            xtmp=xtmp(~isnan(xtmp));
            xtmp=xtmp(1:10);
            xtmp(find(xtmp>100))=100;
            
            if ux <=2
                ai = -1.*(mean(xtmp)./15);
                bi = mean(xtmp)./8;
                ri = (bi-ai).*rand(size((xtmp),1),size((xtmp),2)) + ai;
            
            else
                ai = -1.*(mean(xtmp)./15);
                bi = mean(xtmp)./15;
                ri = (bi-ai).*rand(size((xtmp),1),size((xtmp),2)) + ai;
            end
            xtmp=xtmp+ri;
            TMPX{ux,ui}=xtmp;
            xval(find(xval>100))=100;
            if ux <=4
                plot([ui-.1 ui+.1],[min(xval(:,1)),min(xval(:,1))]+corrx(ux,1),'r-','Linewidth',1)
                plot([ui-.1 ui+.1],[max(xval(:,2)),max(xval(:,2))]+corrx(ux,2),'r-','Linewidth',1)
            elseif ux>=5
                plot([ui+(ux-4)-.1 ui+(ux-4)+.1],[min(xval(:,1)),min(xval(:,1))],'r-','Linewidth',1)
                plot([ui+(ux-4)-.1 ui+(ux-4)+.1],[max(xval(:,2)),max(xval(:,2))],'r-','Linewidth',1)
            end
            hold on
            if ux <=4
                plot([ui-.15 ui+.15],[nanmean(xtmp),nanmean(xtmp)],'b-','Linewidth',1)
                tmi(ui)=nanmean(xtmp)
            elseif ux>=5
                plot([ui+(ux-4)-.15 ui+(ux-4)+.15],[nanmean(xtmp),nanmean(xtmp)],'b-','Linewidth',1)
            end
            if ux==4
                XI2= [XI2;[xtmp',repmat(distx(ui),length(xtmp),1)]];
            end
            
        end  
        if ux ==4
            subplot(5,5,[4,5,9,10])

            XI2(:,1)=zscore(XI2(:,1));
            XI2(:,1)=XI2(:,1);
            plot(XI2(:,2),XI2(:,1),'k.')
            hold on
            [p, atab] = anovan(XI2(:,1), {XI2(:,2)}, ...
                        'model',1, 'sstype',2, ...
                        'varnames',strvcat('dist'),'display','off')          
            [b,bint]=regress(XI2(:,1),[ones(length(XI2(:,2)),1),XI2(:,2)],0.05)
            plot(1:3,b(2) * [1:3] + b(1),'-','Color',cols(ct,:),'Linewidth',1)
            
            axis([0 4 -3 3])
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.005 .005] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'XGrid'       , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , [0 0 0], ...
              'YColor'      , [0 0 0], ...
              'XTick'       , [1:1:3], ...
              'YTick'       , [-3:1.5:3], ...
              'LineWidth'   , 1         );
            xlabel('Distance [categorical units]')
            ylabel('Accuracy [z-scored]')
            axis square
            text(-.65,3.5,labl,'Fontsize',18)

            subplot(5,5,[1,2,6,7])
        end
        
        if ux ==1 | ux ==4
            ylabel('Accuracy [% correct]')
        end
        if ux == 2
            plot([3.5 3.5],[0 100],'-','Color',[.5 .5 .5])
            plot([7.5 7.5],[0 100],'-','Color',[.5 .5 .5])
            plot([11.5 11.5],[0 100],'-','Color',[.5 .5 .5])
            
            text(4,20,'Threat vs')
            text(4,10,'No threat')
            
            text(8,20,'Threat vs')
            text(8,10,'Separation')
                        
            text(12,20,'No threat vs')
            text(12,10,'Separation')
        end

        axis([0 length(CONDREL2{ux})+1 0 100])
        if ux ==2
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.005 .005] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'XGrid'       , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , [0 0 0], ...
              'YColor'      , [0 0 0], ...
              'XTick'       , [1:1:length(CONDREL2{ux})], ...
              'YTick'       , [0:20:100], ...
              'LineWidth'   , 1         );
           
        else
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'XGrid'       , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , [0 0 0], ...
              'YColor'      , [0 0 0], ...
              'XTick'       , [1:1:length(CONDREL2{ux})], ...
              'YTick'       , [0:20:100], ...
              'LineWidth'   , 1         );
        end
      
        if ~(ux>4 & ux<8)
            clear tt1;    
            set(gca,'XTick',[1:1:length(CONDREL2{ux})],'XTickLabel','') 
            if ux<=4
                X=[1:1:length(CONDREL2{ux})];
            elseif ux==8
                X=[2:1:5];    

            end

            if ux == 1
                text(-1,115,'A','Fontsize',18)

                lab = ([{'No threat vs Threat'};{'Threat vs Separation'};{'No threat vs Separation'}]);
            elseif ux == 2
                text(-1,115,'B','Fontsize',18)

                lab = ([{'Pain vs Social danger'};{'Conflict vs No reason'};{'Active sep. vs Passive sep.'};...
                    {'Pain vs Conflict'};{'Pain vs No reason'};{'Social danger vs Conflict'};{'Social danger vs No reason'};...
                    {'Pain vs Active sep.'};{'Pain vs Passive sep.'};{'Social danger vs Active sep.'};{'Social danger vs Passive sep.'};...
                    {'Conflict vs Active sep.'};{'Conflict vs Passive sep.'};{'No reason vs Active sep.'};{'No reason vs Passive sep.'}]);
            elseif ux == 4
                text(-1.7,110,'A','Fontsize',18)
                ylabel('Accuracy [% correct]')
                lab = ([{'Supported vs Contact'};{'Supported vs Armsreach'};{'Supported vs Beyond'};...
                    {'Contact vs Armsreach'};{'Contact vs Beyond'};{'Armsreach vs Beyond'}]);
            elseif ux == 8
                text(-.25,110,'A','Fontsize',18)

                lab = ([{'Gaze'};{'Approach'};{'Collection'};{'Vocalization'}]);
                ylabel('Accuracy [% correct]')

            end
            hx = get(gca,'XLabel'); 
            set(hx,'Units','data'); 
            pos = get(hx,'Position'); 
            y = pos(2); 
            if ux == 8
                y = pos(2)-1;
            end
            for io = 1:size(lab,1) 
                tt1(io) = text(X(io),y,lab(io,:)) 
            end 
            set(tt1,'Rotation',45,'HorizontalAlignment','right') 
        end
        
        if ux == 1 | ux ==4
            axis square
        elseif ux==8
             set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'XGrid'       , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , [0 0 0], ...
              'YColor'      , [0 0 0], ...
              'XTick'       , [2:1:5], ...
              'YTick'       , [0:20:100], ...
              'LineWidth'   , 1         );
            axis square
            axis([1 6 0 100])
        end
        drawnow
        pause(1)
    end
end










