clear,clc
fold  = 'C:\Users\Zoe\cov study\country\';
MyFileInfo = dir([fold '*.csv']);% data from 
nfiles = size(MyFileInfo,1);
%% check if all data from same date and end same date
for i = 1:nfiles
    file = MyFileInfo(i).name;
    fileID = fopen(file);
    c = textscan(fileID,'%s %s %s %s %s %s %s %s %s','Delimiter',',');
    fclose(fileID);
    firstday = c{1}{2};
    lastday = c{1}{end};
    country = c{3}{2};
    if firstday == '2020/01/22' & lastday == '2020/05/04'
    else
        disp(country)
        disp(firstday)
        disp(lastday)
        return
    end
end
% all csv files has the same first and last day. great
%% import data to a three dimensional matrix for ease of analyse
data = nan(104,3,213); % 104 days, 3 info, 213 countries
text = [];
for i = 1:nfiles
    file = MyFileInfo(i).name;
    data(:,:,i) = csvread([fold file],1,6);
    text = [text; MyFileInfo(i).name(1:2)];
end
c = colormap(jet(nfiles));
close
%%  look at daily new cases, growth rate, recovered rate, death rate, and more

recovered_r = nan(104,213);
death_r = nan(104,213);
daily =  nan(104,213);
growth_r = nan(104,213);
for i = 1:nfiles
    confirmed = data(:,1,i); 
    recovered = data(:,2,i);
    death = data(:,3,i);
    recovered_r(:,i) = recovered./confirmed;
    death_r(:,i) = death./confirmed;
    daily(:,i) = [nan; confirmed(2:end) - confirmed(1:end-1)];
    growthrate = [nan; (daily(2:end,i) - daily(1:end-1,i))./daily(1:end-1,i)*100];
    growthrate(growthrate == Inf) = nan;
    growth_r(:,i) = growthrate; % unit in daily %
end

%% find the countries that are over threat, looking for stablized date
% united state: 198; china:42
% fit a linear line to last 10 days, if daliy_slop near 0 & recovered near 0, then save the countries as done.

slop_d = nan(1,213);
slop_r = nan(1,213);
stablized_d = nan(1,213);
for i = 1%[1:188 190:213] %189 only have one data set
    x = 1:104;
%     linear = fittype('b*x+m');
%         fres_d = fit(x(end-9:end)', daily(end-9:end,i),linear);
%         fres_r = fit(x(end-9:end)', recovered_r(end-9:end,i),linear);
%         slop_d(i) = fres_d.b;
%         slop_r(i) = fres_r.b;  
    exponantial_d = fittype('a*exp(x/b)+c');

    g_fit = growth_r(:,i);
    g_fit(g_fit == Inf & g_fit == -Inf) = nan;
    x(isnan(g_fit)) = [];
    g_fit(isnan(g_fit)) = [];
    fres_g = fit(x', g_fit,exponantial_d);
%     stablized_d(i) = 
end
% find(slop_d < 0 & slop_r < 0.05)


%% plots
close
hold on;
% plot(1:104,recovered_r(:,42),'-.','color',c(42,:),'linewidth',2);  
% plot(1:104,recovered_r(:,198),'-.','color',c(198,:),'linewidth',2); 
plot(1:104,smooth(growth_r(:,42)),'-.','color',c(42,:),'linewidth',2);  
plot(1:104,smooth(growth_r(:,198)),'-.','color',c(198,:),'linewidth',2); 
legend('China','US')
% ylim([0 1])
hold off
xlabel('date since 01/22/2019','fontsize',30)
% ylabel('recovered / confirmed','fontsize',30)
ylabel('smoothed growth rate(daily %)','fontsize',30)
ylim([-50 300])
set(gca,'fontsize',30,'linewidth',4)
set(gcf,'Units','normalized','position', [0 0 1 1])
box on


