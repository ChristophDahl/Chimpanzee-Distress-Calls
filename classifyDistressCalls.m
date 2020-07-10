%% This is a simplified version of the script used in Dezecache et al., under Revision (2020).
%% Modify according to your own data set, conditions, etc.


CALCx=0;
corrx=[0,-1;2,-1;0,0;1,-1];
cols=[1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0];
METHODNAMES={'MFCC','Delta','Delta-Delta'};
numberIndividuals = 8;

for indiv=1:numberIndividuals %% modify this variable above
    idxx=find(CALLID~=indiv); %% CALLID is a vector indicating which individual produced the call at given position. 
    obs=METHDS{1}(idxx,:); %% METHDS contains the MFCCs, the Deltas, and the Delta-deltas; 1 refers to MFCCs.
    grp=CClassLabels(idxx); %% CClasslabels is a vector containing information about what class the call belongs to. Usually 0 or 1.

    for uu=1:max(grp)
       nums(uu)=numel(find(grp==uu)); 
    end
    [er,re]=sort(nums, 'descend');

    FEATX=[];
    CONDX=[];
    conct=1;
    for ii=1:length(re)-1
        for jj=ii+1:length(re) %% compare each class with each other
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

            [h,px,ci,stat] = ttest2(dataG1,dataG2,'Vartype','unequal'); %% feature evaluation
            [pxx,featureIdxSortbyP] = sort(px,2); 


            for rr=1:10 %% cross-validation: how many times?
                holdoutCVP = cvpartition(grpx,'holdout',round(size(grpx,2)/4))
                dataTrain = obsx(holdoutCVP.training,:);
                grpTrain = grpx(holdoutCVP.training);
                dataTest = obsx(holdoutCVP.test,:);
                grpTest = grpx(holdoutCVP.test);


                cd('~/libsvm-3.21/matlab/')  %% make sure you find all the necessary functions.
                SF = [];

                %% RBF kernel
                F = 1:1:numF;
                ACC0   = [];

                for j = 1:length(F)
                    clear ATe ATr
                    ix=featureIdxSortbyP(1:F(j));
                    %% Train the SVM
                    bestaccuracy = 0;
                    %% optimize parameters
                    for log2c = -1:3,
                      for log2g = -4:1,
                        cmd = ['-c ', num2str(2^log2c), ' -g ', num2str(2^log2g),'-t 2 -h 0' ];
                        cv = svmtrain(grpTrain', dataTrain(:,[ix]), cmd);
                        [predict_label, accuracy, prob_values] = svmpredict(grpTest', dataTest(:,[ix]), cv); %% run the SVM model on the test data
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
    %% write out and store your structures
    RESULTS. ...   =CONDX;
    RESULTS. ...   =FEATX;
    clear AC;
end

