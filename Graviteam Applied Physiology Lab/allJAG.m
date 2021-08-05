%%JAG import and calculate preactivation timing ONLY FOR PRE AND POST
%%Created by Chase Rock, hello@chasegrock.com
%%Imports data from JAG protocol, following V3D scripts: HOP_ANALYSIS,
%%SQUAT_ANALYSIS, EMGchannels, EMG_FORCE_EXPORT, RECT_EMG_FORCE_EXPORT
%%Calculates EMG magnitude at landing and preactivation timing

function [subject] = allJAG(lr, pp, toPlotOrNotToPlot)

    close all

    %Select subject numbers to include in analysis as not all numbers are used
    SubjectNumber = ['01';'06';'07';'08';'10';'11';'12';'13';'14';'15';'16'];

    %Go through each subject
    for i = 1:length(SubjectNumber)
        %% MAX

        %Set filepath
        filepath = 'Z:\crock\JAG\RAW\OUTPUT\JAG_s';

        %Cycle through channels, loading each file and extracting max value from all MAX trials
        for channel = 1:16

            currentfile = strcat(filepath,SubjectNumber(i,:),'\MAX\EMG',num2str(channel),'.txt');

            data = dlmread(currentfile,'\t',5,1);           %Read file data for each channel

            slidingaverage = movmean(data,96);              %Calculate sliding average with a window size of 96 frames (100 ms)
            maxemg(channel,1) = max(max(slidingaverage));   %Caclulate maximum of maximums and save to maxemg

            clear data currentfile slidingaverage
        end
        
        if i == 3
            maxemg(12,1) = maxemg(8,1)/2;
        end

        maxsubject(i).emg = maxemg;
        clear maxemg

        %% STAND

        %Get mean standing EMG values from each channel
        currentfile = strcat(filepath,SubjectNumber(i,:),'\STANDEMG.txt');
        data = dlmread(currentfile,'\t',5,1);

        restemg(:,i) = mean(data(end-960:end,:));           %restemg is the mean of the last second of the stand trial
        stdemg(:,i) = std(data(end-960:end,:));             %stdemg is the standard deviation of the last second of the stand trial
        restemg(:,i) = restemg(:,i) + stdemg(:,i);          %restemg is updated to represent the mean plus one standard deviation

        clear currentfile data

        %% Code :D

        currentfile = strcat(filepath,SubjectNumber(i,:),strcat('\', pp, '_GRFR_', lr, '.txt'));
        data = dlmread(currentfile,'\t',5,1);

        for j = 1:length(data(1,:))             %For all PRE trials collected, find lift and land events

            temp = data(:,j);                   %Smooth the GRF data using a sliding average then find the minimum value

            chunkMask = temp < 10;              %Create a logical mask that finds everywhere that the force sensor readings < 10
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

            prelandidx(j) = max(timeIdx)+1;     %Land index is the fram after the last value that is less than grfthreshold
            preliftidx(j) = min(timeIdx);       %Lift index is the first value that is less than grfthrehsold

            clear temp temp2 temp3 vals pks grfthreshold idx I chunkMask maxOnes counter timeVec timeIdx

        end

        airtime = prelandidx - preliftidx;      %Total airtime is the difference between the lift index and land index
        subject(i).grfr = data;                 %Save GRFR data to PRE structure

        clear currentfile data

        %% EMG Analysis
        
        if strcmp(lr, 'L')                      %Determine which EMG channels to use depending on in Right/Left data is called
            if i == 1
                vec = [1:2:6];
            else
                vec = [9:2:16];
            end
        elseif strcmp(lr, 'R')
            if i == 1
                vec = [2:2:6];
            else
                vec = [10:2:16];
            end
        end

        for channel = vec                       %Loop through all of the EMG channels

            currentfile = strcat(filepath,SubjectNumber(i,:),strcat('\', pp, '\EMG'),num2str(channel),'.txt');

            %Find maximum EMG value
            dataE = dlmread(currentfile,'\t',5,1);
            dataE = dataE./maxsubject(i).emg(channel);              %Divide EMG data by that channels maximum value (calculated in max section)
            dataE(dataE == 0) = NaN;                                %Set zeros to NaN
            
            for j = 1:length(dataE(1,:))
                
                if j == 1 && i == 11 && channel == 15 && lr == 'L' && pp(2) == 'R'
                    continue
                end

                premagatland(channel,j) = dataE(prelandidx(j),j);   %Magatland is the EMG magnitude at the land index
                
                clear currentfile filepath

                filepath = 'Z:\crock\JAG\RAW\OUTPUT\RECT\JAG_s';    %Get RECT data and find the pre-activation time during airtime

                currentfile = strcat(filepath,SubjectNumber(i,:),strcat('\', pp, '\EMG'),num2str(channel),'.txt');
                data = dlmread(currentfile,'\t',5,1);

                preact(channel,j) = 1000;                           %Set preact to a high value to enter the while-loop
                jumpend = prelandidx(j);
                jumpstart = preliftidx(j);

                %% %Finds preactivation time, adjusting frame forward until the time is greater tahn 1/3 of the air time
               
                while preact(channel,j) > airtime(j)/1.5            

                    aircumint = cumtrapz(data(jumpstart:jumpend,j));
                    aircumintnorm = aircumint./max(aircumint);

                    airtimenorm = ((1:length(aircumint))./length(aircumint))';
                    airdiff = airtimenorm - aircumintnorm;

                    [~,airidx] =  max(airdiff);
                    preact(channel,j) = prelandidx(j) - (airidx + preliftidx(j));


                    %% Plots for checking data
                    if toPlotOrNotToPlot == 1           %Declares if plotting is wanted; From input condition
                        figure(1)

                        subplot(4,1,1)
                        plot(subject(i).grfr(1:jumpstart ,j),'k','LineWidth',2)
                        hold on
                        plot(jumpstart:jumpend,subject(i).grfr((jumpstart:jumpend),j),'r','LineWidth',2)
                        plot(jumpend:length(subject(i).grfr(:,j)),subject(i).grfr(jumpend:end,j),'k','LineWidth',2)
                        plot([airidx+jumpstart airidx+jumpstart],[0 max(subject(i).grfr(:,j))],'c','LineWidth',2)
                        title(strcat('LEFT-',pp,'-Subject-',SubjectNumber(i,:),' , Trial-', num2str(j),' , Channel-', num2str(channel)))
                        hold off

                        subplot(4,1,2)
                        plot(data(1:jumpstart ,j),'k','LineWidth',2)
                        hold on
                        plot(jumpstart:jumpend,data((jumpstart:jumpend),j),'r','LineWidth',2)
                        plot(jumpend:length(subject(i).grfr(:,j)),data((jumpend:end),j),'k','LineWidth',2)
                        plot([airidx+jumpstart airidx+jumpstart],[0 max(data(:,j))],'c','LineWidth',2)
                        hold off

                        subplot(4,1,3)
                        plot(data((jumpstart:jumpend),j),'r','LineWidth',2)
                        hold on
                        plot([airidx airidx],[0 max(data((jumpstart:jumpend),j))],'c','LineWidth',2)
                        xlim([0 prelandidx(j)-jumpstart])
                        hold off

                        subplot(4,1,4)
                        plot(airtimenorm,aircumintnorm,'r','LineWidth',2)
                        hold on
                        plot(airtimenorm,airtimenorm,'k','LineWidth',2)
                        plot([airtimenorm(airidx) airtimenorm(airidx)],[0 1],'c','LineWidth',2)
                        hold off

                        pause on
                        pause

                    end

                    jumpend = jumpend+1;
                    jumpstart = jumpstart+1;
                end
            clear idx airdata aircumint airtimenorm aircumintnorm airdiff airidx jumpend jumpstart
            end
            
            if i == 5 && lr == 'L' && pp(3) == 'S'
                preact(11,1) = 0.0469;
            elseif i == 10 && lr == 'L' && pp(3) == 'S'
                preact(11,1) = 0.0719;
                preact(13,1) = 0.0708;
            elseif i == 6 && lr == 'R' && pp(3) == 'S'
                preact(16,1) = 0.0656;
            end
        
        
            %Integral b/w preactivation time and landing time
            for j = 1:length(dataE(1,:))
                iEMGjumptemp = cumtrapz(dataE(1:preliftidx(j),j));
                iEMGjump(channel, j) = iEMGjumptemp(end);
                
                iEMGtempvec = cumtrapz(dataE(prelandidx(j) - preact(channel,j):prelandidx(j),j));
                iEMG(channel, j) = iEMGtempvec(end);
                
                if i == 2 || i == 4 
                    
                iEMGirtemp = cumtrapz(dataE(prelandidx(j):prelandidx(j)+32,j));
                iEMGir(channel,j) = iEMGirtemp(end);
                
                iEMGslrtemp = cumtrapz(dataE(prelandidx(j)+33:prelandidx(j)+64,j));
                iEMGslr(channel,j) = iEMGslrtemp(end);
                
                iEMGmlrtemp = cumtrapz(dataE(prelandidx(j)+65:prelandidx(j)+97,j));
                iEMGmlr(channel,j) = iEMGmlrtemp(end);
                
                iEMGllrtemp = cumtrapz(dataE(prelandidx(j)+98:prelandidx(j)+130,j));
                iEMGllr(channel,j) = iEMGllrtemp(end);
                
                else
                    
                iEMGirtemp = cumtrapz(dataE(prelandidx(j):prelandidx(j)+29,j));
                iEMGir(channel,j) = iEMGirtemp(end);
                
                iEMGslrtemp = cumtrapz(dataE(prelandidx(j)+30:prelandidx(j)+57,j));
                iEMGslr(channel,j) = iEMGslrtemp(end);
                
                iEMGmlrtemp = cumtrapz(dataE(prelandidx(j)+58:prelandidx(j)+86,j));
                iEMGmlr(channel,j) = iEMGmlrtemp(end);
                
                iEMGllrtemp = cumtrapz(dataE(prelandidx(j)+87:prelandidx(j)+115,j));
                iEMGllr(channel,j) = iEMGllrtemp(end);
                
                end
                clear iEMGtempvec iEMGjumptemp iEMGirtemp iEMGslrtemp iEMGmlrtemp iEMGllrtemp
            end
            
            subject(i).emg(channel).trial = data;

            clear currentfile idx minacts minact iEMGtempvec dataE

        end

        if i == 2 || i == 4             %Changes Hertz to seconds of EMG data; Diff. conversions for diff. subjects
            preact = preact./1080;
            airtime = airtime./1080;
        else
            preact = preact./960;
            airtime = airtime./960;
        end

        if i == 5 && lr == 'L' && pp(3) == 'S'
            preact(11,1) = 0.0469;
        elseif i == 10 && lr == 'L' && pp(3) == 'S'
            preact(11,1) = 0.0719;
            preact(13,1) = 0.0708;
        elseif i == 6 && lr == 'R' && pp(3) == 'S'
            preact(16,1) = 0.0656;
        end
        
        %% Creating Structures
        
        subject(i).prelandidx = prelandidx;
        subject(i).preliftidx = preliftidx;
        subject(i).airtime = airtime;
        subject(i).premagatland = premagatland;
        subject(i).preact = preact;
        subject(i).actdelay = airtime - preact;
        subject(i).percentact = preact./airtime;
        subject(i).iemgpreact = iEMG;
        subject(i).iemgjump = iEMGjump;
        subject(i).iemgir = iEMGir;
        subject(i).iemgslr = iEMGslr;
        subject(i).iemgmlr = iEMGmlr;
        subject(i).iemgllr = iEMGllr;
        

        if i == 1 && lr == 'L'
            subject(i).preact(6,:) = zeros(1,length(subject(i).preact(5,:)));
            subject(i).premagatland(6,:) = zeros(1,length(subject(i).preact(5,:)));
            subject(i).actdelay(6,:) = zeros(1,length(subject(i).preact(5,:)));
            subject(i).percentact(6,:) = zeros(1,length(subject(i).preact(5,:)));
            subject(i).iemgpreact(6,:) = zeros(1,length(subject(i).preact(5,:)));
            subject(i).iemgjump(6,:) = zeros(1,length(subject(i).preact(5,:)));
        elseif lr == 'L'
            subject(i).preact(16,:) = zeros(1,length(subject(i).preact(15,:)));
            subject(i).premagatland(16,:) = zeros(1,length(subject(i).preact(15,:)));
            subject(i).actdelay(16,:) = zeros(1,length(subject(i).preact(15,:)));
            subject(i).percentact(16,:) = zeros(1,length(subject(i).preact(15,:)));
            subject(i).iemgpreact(16,:) = zeros(1,length(subject(i).preact(15,:)));
            subject(i).iemgjump(16,:) = zeros(1,length(subject(i).preact(15,:)));
        end

        clear premagatland preact halfmagidx halfmag prelandidx preliftidx airtime iEMG iEMGjump
    end
end