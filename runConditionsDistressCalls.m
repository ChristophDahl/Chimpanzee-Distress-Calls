close all
labelX={'D','E','','C','B','C','D','E'};

CONDS={'THREATLEVEL','TRIGGER','DISTONSET','DISTONSET2','M_GAZE','M_APPROACH',...
    'M_COLLECTION','M_VOC'};
TITL={'Type of trigger','Trigger [detailed]','Distance','Distance [detailed]',...
    'Gaze','Approach','Collection','Vocalization'};

plotorder=[1,2,3,4,8,5,6,7];
figure('Position',[100 100 1000 1000])
ct=1;
cx=1;
cz=1;
ct2=1;
ct3=1;
VARMAT= [];
TMPX=[];

for ux=[1,2,4,5,6,7,8]%1:length(CONDS)
    if ux == 1
        figure(1)
        set(gcf, 'Position',[100 100 1200 1450]);
    elseif ux == 4
        ct=1;
        figure(2)
        set(gcf, 'Position',[100 100 1200 1200]);
    elseif ux == 5
        ct=1;
        figure(3)
        set(gcf, 'Position',[100 100 1400 600]);
    end
    clear nums
    load(CONDS{ux})
    load datastr

    tmpcond=eval(CONDS{ux});
    
    for i=1:length(datastr)
       tmpi=datastr(i,:); 
       POS(i)=INDEXES(find(INDEXES(:,[1])==tmpi(1) & INDEXES(:,[2])==tmpi(2)),4); 
    end


    CClassLabels=makeLabelWhimpers(tmpcond,IDX(:,1));
    CClassLabels=CClassLabels(POS);

    for i=1:max(CClassLabels)
       nums(i)=numel(find(CClassLabels==i)); 
    end
    idx=(find(nums>10))
    samples=10;
    Ids=zeros(1,length(CClassLabels)).*nan;
    for i=1:size(idx,2)
       Ids(find(CClassLabels==i))=i;
    end
    CClassLabels=Ids;
    
    classifyDistressCalls
    ct2=ct2+1;
   
end