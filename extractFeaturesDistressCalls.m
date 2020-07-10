%% This is a simplified version of the script used in Dezecache et al., under Revision (2020).
%% Modify according to your own data set, conditions, etc. Get a mfcc function from Mathworks.

fs=44100;
thres=.04;
thres2=.12;

features=[];
DEL=[];
DEL2=[];
CEP=[];
DA=[];IDX=[];
INDEXES=[];
CALLID=[];
ctr=0;
counter=0;

for i=1:size(info,2) %% loop through your structure of calls
    currelements = info{i};  
    for j=1:length(currelements.segmenton)
        ctr=ctr+1;
        %% apply certain length criteria
        if ((currelements.segmentoff{j}-currelements.segmenton{j})/fs)>thres & ...   
                ((currelements.segmentoff{j}-currelements.segmenton{j})/fs)<thres2
            
            x=currelements.audio(currelements.segmenton{j}:currelements.segmentoff{j});
            counter=counter+1;
            INDEXES=[INDEXES;[i,j,ctr counter]];
            
            %% param def
            L=length(x)./fs; % length in sec
            win=.025;
            step=.01;

            %% MFCCs and deltas  (get your own mfcc function from Mathworks)

            [cepstra,aspectrum,pspectrum] = melfcc(x, fs, ...
             'wintime', win, 'hoptime', step, ...
             'numcep', 13, 'lifterexp', 0.6, 'sumpower', 1, 'preemph', 0.97, ...
             'dither', 0, 'minfreq',  50, 'maxfreq', 4000, ...
             'nbands', 26, 'bwidth', 3.0, 'dcttype', 2, ...
             'fbtype', 'mel', 'usecmp', 0, 'modelorder', 0, ...
             'broaden', 0, 'useenergy', 0);
 

            xpw=9;
            CEP{counter}=cepstra;
            DEL{counter} = deltas(cepstra,xpw);
            DEL2{counter} = deltas(deltas(cepstra,xpw),xpw);
            IDX=[IDX;[i j ctr]];
            CALLID=[CALLID;[callerID(i)]];
        end
    end

end
    
%% normalization
for tt=1:size(DA1,2)
    DA1(:,tt)=(DA1(:,tt)-nanmin(DA1(:,tt)))./(nanmax(DA1(:,tt))-nanmin(DA1(:,tt)));
end


























    
    




































