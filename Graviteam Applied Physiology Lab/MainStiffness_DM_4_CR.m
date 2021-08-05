function MainStiffness_DM_4_CR

[subject] = JAGStiffness_DM_3();

SubjectNewton = ['690';'809';'673';'775';'900';'711';'680';'571';'504';'450';'557';'772';'636';'543';'540'];

SubjectKilo = SubjectNewton ./ 9.81;

x = [1:100];

sumPreLift = 0;
sumPreLand = 0;
sumPostLift = 0;
sumPostLand = 0;
sumLow1 = 0;
sumLow50 = 0;

sumPreLiftStd = 0;
sumPreLandStd = 0;
sum1postliftstd = 0;
sum1postlandstd = 0;

PreLift = [];
PreLand = [];
PostLift = [];
PostLand = [];

for i = 1:15
    
    PreLift = [PreLift subject(i).preAvgLift];
    PreLand = [PreLand subject(i).preAvgLand];
        
    PostLift = [PostLift subject(i).postLift];
    PostLand = [PostLand subject(i).postLand];

end

meanPreLift = mean(PreLift.');
meanPreLand = mean(PreLand.');

meanPostLift = mean(PostLift.');
meanPostLand = mean(PostLand.');

stdPreLift = std(PreLift.');
stdPreLand = std(PreLand.');

stdPostLift = std(PostLift.');
stdPostLand = std(PostLand.');

%% Plotting

figure(1)
subplot(1,2,1)
hold on
p1 = patch([x fliplr(x)], [meanPreLift+stdPreLift  fliplr(meanPreLift-stdPreLift)],'b');
p2 = patch([x fliplr(x)], [meanPostLift+stdPostLift  fliplr(meanPostLift-stdPostLift)],'r');
alpha(0.1)
p1.EdgeColor = 'none';
p2.EdgeColor = 'none';

plot(meanPreLift,'b','LineWidth',2)
plot(meanPostLift,'r','LineWidth',2)

legend("+/-std", "+/-std","AvgPreLift", "AvgPostLift");

subplot(1,2,2)
hold on
p1 = patch([x fliplr(x)], [meanPreLand+stdPreLand  fliplr(meanPreLand-stdPreLand)],'b');
p2 = patch([x fliplr(x)], [meanPostLand+stdPostLand  fliplr(meanPostLand-stdPostLand)],'r');
alpha(0.1)
p1.EdgeColor = 'none';
p2.EdgeColor = 'none';
plot(meanPreLand,'b','LineWidth',2)
plot(meanPostLand,'r','LineWidth',2)

legend("+/-std", "+/-std", "AvgPreLand", "AvgPostLand");

%% Other Graphs

PreLiftAccel = [];
PreLandAccel = [];
PostLiftAccel = [];
PostLandAccel = [];

%Get acceleration vals via F=ma 
for i = 1:15
    PreLiftAccel(:, i) = PreLift(:, i) ./ SubjectKilo(i);
    PreLandAccel(:, i) = PreLand(:, i) ./ SubjectKilo(i);
        
    PostLiftAccel(:, i) = PostLift(:, i) ./ SubjectKilo(i);
    PostLandAccel(:, i) = PostLand(:, i) ./ SubjectKilo(i);
end

    %Velocity
    
    PreLiftVel = cumtrapz(x, PreLiftAccel);
    PreLandVel = cumtrapz(x, PreLandAccel);
        
    PostLiftVel = cumtrapz(x, PostLiftAccel);
    PostLandVel = cumtrapz(x, PostLandAccel);
    
    %Highpass
    
    for i=1:15
    if i==6 || i==8
        
    PreLiftVel(:, i) = highpass(PreLiftVel(:, i), 0.5, 1080);
    PreLandVel(:, i) = highpass(PreLandVel(:, i), 0.5, 1080);
        
    PostLiftVel(:, i) = highpass(PostLiftVel(:, i), 0.5, 1080);
    PostLandVel(:, i) = highpass(PostLandVel(:, i), 0.5, 1080);
    
    else
        
    PreLiftVel(:, i) = highpass(PreLiftVel(:, i), 0.5, 960);
    PreLandVel(:, i) = highpass(PreLandVel(:, i), 0.5, 960);
        
    PostLiftVel(:, i) = highpass(PostLiftVel(:, i), 0.5, 960);
    PostLandVel(:, i) = highpass(PostLandVel(:, i), 0.5, 960); 
    
    end
    end
    
    %Position
    
    PreLiftPos = cumtrapz(x, PreLiftVel);
    PreLandPos = cumtrapz(x, PreLandVel);
        
    PostLiftPos = cumtrapz(x, PostLiftVel);
    PostLandPos = cumtrapz(x, PostLandVel);
    
    %Highpass
    
    for i=1:15
    if i==6 || i==8
      
    PreLiftPos(:, i) = highpass(PreLiftPos(:, i), 0.5, 1080);
    PreLandPos(:, i) = highpass(PreLandPos(:, i), 0.5, 1080);
        
    PostLiftPos(:, i) = highpass(PostLiftPos(:, i), 0.5, 1080);
    PostLandPos(:, i) = highpass(PostLandPos(:, i), 0.5, 1080);
        
    else
        
    PreLiftPos(:, i) = highpass(PreLiftPos(:, i), 0.5, 960);
    PreLandPos(:, i) = highpass(PreLandPos(:, i), 0.5, 960);
        
    PostLiftPos(:, i) = highpass(PostLiftPos(:, i), 0.5, 960);
    PostLandPos(:, i) = highpass(PostLandPos(:, i), 0.5, 960);
    
    end
    end
    
    %Averages
    %SUGGESTION: A more succint way to do this would be PreLiftAccel = mean(PreLiftAccel.').';    
    AvgPreLiftAccel = mean(PreLiftAccel.');
    AvgPreLandAccel = mean(PreLandAccel.');   
    AvgPostLiftAccel = mean(PostLiftAccel.');
    AvgPostLandAccel = mean(PostLandAccel.');
    
    AvgPreLiftVel = mean(PreLiftVel.');
    AvgPreLandVel = mean(PreLandVel.'); 
    AvgPostLiftVel = mean(PostLiftVel.');
    AvgPostLandVel = mean(PostLandVel.');
    
    AvgPreLiftPos = mean(PreLiftPos.');
    AvgPreLandPos = mean(PreLandPos.');
    AvgPostLiftPos = mean(PostLiftPos.');
    AvgPostLandPos = mean(PostLandPos.');

    
    %Standard Devs
    stdPreLiftAccel = std(PreLiftAccel.');
    stdPreLandAccel = std(PreLandAccel.');
    stdPostLiftAccel = std(PostLiftAccel.');
    stdPostLandAccel = std(PostLandAccel.');
    
    stdPreLiftVel = std(PreLiftVel.');
    stdPreLandVel = std(PreLandVel.');
    stdPostLiftVel = std(PostLiftVel.');
    stdPostLandVel = std(PostLandVel.');
    
    stdPreLiftPos = std(PreLiftPos.');
    stdPreLandPos = std(PreLandPos.');
    stdPostLiftPos = std(PostLiftPos.');
    stdPostLandPos = std(PostLandPos.');
    
    
    %Graphs

    figure(2);
    subplot(1,2,1)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLiftAccel+stdPreLiftAccel  fliplr(AvgPreLiftAccel-stdPreLiftAccel)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLiftAccel+stdPostLiftAccel  fliplr(AvgPostLiftAccel-stdPostLiftAccel)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';

    plot(AvgPreLiftAccel,'b','LineWidth',2)
    plot(AvgPostLiftAccel,'r','LineWidth',2)

    legend("+/-std", "+/-std","AvgPreLiftAccel", "AvgPostLiftAccel");

    subplot(1,2,2)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLandAccel+stdPreLandAccel  fliplr(AvgPreLandAccel-stdPreLandAccel)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLandAccel+stdPostLandAccel  fliplr(AvgPostLandAccel-stdPostLandAccel)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';
    
    plot(AvgPreLandAccel,'b','LineWidth',2)
    plot(AvgPostLandAccel,'r','LineWidth',2)

    legend("+/-std", "+/-std", "AvgPreLandAccel", "AvgPostLandAccel");
    
    
    
    figure(3);
    subplot(1,2,1)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLiftVel+stdPreLiftVel  fliplr(AvgPreLiftVel-stdPreLiftVel)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLiftVel+stdPostLiftVel  fliplr(AvgPostLiftVel-stdPostLiftVel)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';

    plot(AvgPreLiftVel,'b','LineWidth',2)
    plot(AvgPostLiftVel,'r','LineWidth',2)

    legend("+/-std", "+/-std","AvgPreLiftVel", "AvgPostLiftVel");

    subplot(1,2,2)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLandVel+stdPreLandVel  fliplr(AvgPreLandVel-stdPreLandVel)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLandVel+stdPostLandVel  fliplr(AvgPostLandVel-stdPostLandVel)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';
    
    plot(AvgPreLandVel,'b','LineWidth',2)
    plot(AvgPostLandVel,'r','LineWidth',2)

    legend("+/-std", "+/-std", "AvgPreLandVel", "AvgPostLandVel");
    
    
    
    figure(4);
    subplot(1,2,1)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLiftPos+stdPreLiftPos  fliplr(AvgPreLiftPos-stdPreLiftPos)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLiftPos+stdPostLiftPos  fliplr(AvgPostLiftPos-stdPostLiftPos)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';

    plot(AvgPreLiftPos,'b','LineWidth',2)
    plot(AvgPostLiftPos,'r','LineWidth',2)

    legend("+/-std", "+/-std","AvgPreLiftPos", "AvgPostLiftPos");

    subplot(1,2,2)
    hold on
    p1 = patch([x fliplr(x)], [AvgPreLandPos+stdPreLandPos  fliplr(AvgPreLandPos-stdPreLandPos)],'b');
    p2 = patch([x fliplr(x)], [AvgPostLandPos+stdPostLandPos  fliplr(AvgPostLandPos-stdPostLandPos)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';
    
    plot(AvgPreLandPos,'b','LineWidth',2)
    plot(AvgPostLandPos,'r','LineWidth',2)

    legend("+/-std", "+/-std", "AvgPreLandPos", "AvgPostLandPos");
    
    
    
    figure(5)
    subplot(1,2,1)
    hold on
    p1 = patch([x fliplr(x)], [meanPreLift+stdPreLift  fliplr(meanPreLift-stdPreLift)],'b');
    p2 = patch([x fliplr(x)], [meanPostLift+stdPostLift  fliplr(meanPostLift-stdPostLift)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';

    plot(AvgPreLiftPos, meanPreLift,'b','LineWidth',2)
    plot(AvgPostLiftPos, meanPostLift,'r','LineWidth',2)

    legend("+/-std", "+/-std","PreLift", "PostLift");

    subplot(1,2,2)
    hold on
    p1 = patch([x fliplr(x)], [meanPreLand+stdPreLand  fliplr(meanPreLand-stdPreLand)],'b');
    p2 = patch([x fliplr(x)], [meanPostLand+stdPostLand  fliplr(meanPostLand-stdPostLand)],'r');
    alpha(0.1)
    p1.EdgeColor = 'none';
    p2.EdgeColor = 'none';
    plot(AvgPreLandPos, meanPreLand,'b','LineWidth',2)
    plot(AvgPostLandPos, meanPostLand,'r','LineWidth',2)

    legend("+/-std", "+/-std", "PreLand", "PostLand");


end