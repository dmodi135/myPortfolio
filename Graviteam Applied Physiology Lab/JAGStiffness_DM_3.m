function [subject] = JAGStiffness_DM_3

    close all

    %Select subject numbers to include in analysis as not all numbers are used
    SubjectNumber = ['01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15'];
    SubjectNewton = ['690';'809';'673';'775';'900';'711';'680';'571';'504';'450';'557';'772';'636';'543';'540'];
    
    liftidx = [];
    
    %Go through each subject
    for i = 1:length(SubjectNumber)
        %% Code :D
        
        preFile = strcat('DhruvGRF/JAG_s',SubjectNumber(i,:),'/PRE/GRFR.txt');
        postFile = strcat('DhruvGRF/JAG_s',SubjectNumber(i,:),'/POST/GRFR.txt');
        lowFile = strcat('DhruvGRF/JAG_s',SubjectNumber(i,:),'/LOWG/GRFR.txt');
        
        preData = dlmread(preFile,'\t',5,1);
        postData = dlmread(postFile,'\t',5,1);
        lowData = dlmread(lowFile, '\t', 5, 1);
        
%          preTable = readtable(preFile);
%          postTable = readtable(postFile);
%         lowTable = readtable(lowFile);

        pre8 = preData(:,8);
        pre9 = preData(:,9);
        pre10 = preData(:,10);
        post1 = postData(:,1);
        low1 = lowData(:, 1);
        low50 = lowData(:, end);

        pre8 = pre8 ./ str2num(SubjectNewton(i,:));
        pre9 = pre9 ./ str2num(SubjectNewton(i,:));
        pre10 = pre10 ./ str2num(SubjectNewton(i,:));
        post1 = post1 ./ str2num(SubjectNewton(i,:));
        low1 = low1 ./ str2num(SubjectNewton(i,:));
        low50 = low50 ./ str2num(SubjectNewton(i,:));

        newData = {pre8,pre9,pre10,post1,low1,low50};
        
        for j = 1:length(newData)             %For all PRE trials collected, find lift and land events

            temp = newData{j};                   %Smooth the GRF data using a sliding average then find the minimum value
                   
            chunkMask = temp < (0.1+min(movmean(temp, 100)));              %Create a logical mask that finds everywhere that the force sensor readings < 10
            maxOnes = 0;
            counter = 0;
            for m = 1:length(chunkMask)         %Loop through entire mask to find biggest chunk (this is the location of air time)
                if chunkMask(m) == 1
                    counter = counter + 1;
                else
                    if counter > maxOnes
                        maxOnes = counter;
                    end
                    counter = 0;
                end
            end
            timeVec = ones(1, maxOnes);         %Vector of ones of length of air time

            for n = 1:length(chunkMask)         %The vector becomes the indeces of air time
                if timeVec == chunkMask(n:n+length(timeVec)-1)
                    timeIdx = n:n+length(timeVec); 
                    break
                else
                    continue
                end
            end

            liftidx(j) = min(timeIdx);       %Lift index is the first value that is less than grfthrehsold
            landidx(j) = max(timeIdx)+1;
            
            clear temp temp2 temp3 vals pks grfthreshold idx chunkMask maxOnes counter timeVec timeIdx

        end
        
        
        
        
        

        pre8lift = interpft(pre8(1:liftidx(1)),100);
        pre8land = interpft(pre8(landidx(1):end),100);
        
%         pre8liftstd = std(pre8lift);
%         pre8landstd = std(pre8land);
        
        pre9lift = interpft(pre9(1:liftidx(2)),100);
        pre9land = interpft(pre9(landidx(2):end),100);
        
%         pre9liftstd = std(pre9lift);
%         pre9landstd = std(pre9land);
        
        pre10lift = interpft(pre10(1:liftidx(3)),100);        
        pre10land = interpft(pre10(landidx(3):end),100);
        
%         pre10liftstd = std(pre10lift);
%         pre10landstd = std(pre10land);
        
        post1lift = interpft(post1(1:liftidx(4)),100);
        post1land = interpft(post1(landidx(4):end),100);
        
%         post1liftstd = std(post1lift);
%         post1landstd = std(post1land);
        
        
%         low1 = interpft(low1, 100);
%         low50 = interpft(low50, 100);
        
        
        avgPreLift = (pre8lift+pre9lift+pre10lift)/3;
        avgPreLand = (pre8land+pre9land+pre10land)/3;

        
       clear currentfile data
        
        %% Creating Structures
        
        subject(i).preAvgLift = avgPreLift;
        subject(i).preAvgLand = avgPreLand;
        subject(i).postLift = post1lift;
        subject(i).postLand = post1land;
        
%         subject(i).preAvgLiftStd = avgPreLiftStd;
%         subject(i).preAvgLandStd = avgPreLandStd;
%         subject(i).postLiftStd = post1liftstd;
%         subject(i).postLandStd = post1landstd;
        

        clear premagatland preact halfmagidx halfmag landidx liftidx airtime iEMG iEMGjump
    end
    
end