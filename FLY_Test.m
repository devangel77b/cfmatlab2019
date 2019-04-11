%% Fly_LawnMower
% 10JUL18
% J. Gainer

% The following code establishes a ROS connection with Crazyflie 2.0s to
% fly them in a lawn mower searching trajectory.

%Section Outline
%I. Establish ROS Connection
%II. Create Crazyflie Objects
%III. Create Lawn Mower Pattern
%IV. Execute Experiment
%V. Post Processing Figures

close all
clearvars -except cf1 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
clc

%% I. Establish ROS Connection

initROScon = input('Establish ROS connection? (y/n): ', 's');

if initROScon == 'y'
    rosinit('10.1.1.200'); %Establish connection with odriod
    rostopic list %Verify connection
end
%rostopic echo /crazyflie1/battery %Check connection

%% II. Create Crazyflie Objects

%Create cf objects
initcf = input('Create cf objects? (y/n): ', 's');

if initcf == 'y'
    numAgent = input('Enter number of active agents: ');
    N = numAgent;
    agentInput = input('Enter agent ID numbers: ', 's');
    idAgent = str2num(agentInput);
    cf = cell(numAgent,1); 
    for i = 1:numAgent
        cf{i} = crazyflie(idAgent(i));
    end
else
   numAgent = numel(cf); 
   N = numel(cf); 
   idAgent = 1:numel(cf);
end

%% III. Run Waypoint Test

%Prep experiment timers
% t_start = tic; 
% t_end = 30; 
% z = 1.5; 
% 
% while toc(t_start) < t_end
%     xtmp = 0.5*square(2*pi*toc(t_start)/4);
% %     ytmp = square((2*pi*toc(t_start))/10+pi/2);
%     ytmp = 0;
%     WPtmp = [xtmp; ytmp; z];
%     fprintf('X: %0.1f \nY: %0.1f \nZ: %0.1f \n', xtmp, ytmp, z);
%     cf{1}.send_vel(WPtmp);
%     pause(0.1);
% end
% 
% fprintf('Done sending waypoints.\n'); 

%% IV. Test Launch

t_exp = tic; 

%Run Launching Sequence
%Prep experiment
makeLand = false; makeLaunch = true; h = 1; vStar = 0.5; t_end = zeros(N,1); agent = struct([]); data = struct([]); ct = 1; t_hover = 3; 
for i = 1:N
    [agent, t_end(i)] = plan_LaunchLand(makeLaunch, makeLand, cf, agent, i, h, vStar, t_hover); 
end
%Execute flight path 
[data,ct] = FLY_PlannedPath(cf,agent,data,ct,t_end, N, t_exp);



%V. Test LM Pattern

% %Load waypoints
% load('PrePlanned_Paths/4_Agent_4_Partitions_0.50msSpeed_0.25mSensorRad.mat')
% 
% %Prep experiment timers
% t_end = agent(1).sTime(1,end); 
% idx = 0; 
% t_start = tic; t_path = tic; 
% 
% while toc(t_start) < t_end-1
%     t_cur = toc(t_path);
%     idx = round(t_cur*100);
%     % -> Force first index value if index is less than 1
%     if idx < 1
%         idx = 1;
%     end
%     
%     % Isolate data to send to agent
%     WPtmp = agent(1).desired.rT(:,idx);
%     % Send data to agent
%     fprintf('X: %0.3f \nY: %0.3f \nZ: %0.3f \n', WPtmp(1),WPtmp(2),WPtmp(3));
%     cf{1}.send_wp(WPtmp);
%     pause(0.001);
% end
% 
% fprintf('Done sending waypoints.\n'); 


%VI. Test Landing 

%Prep experiment
makeLand = true; makeLaunch = false; h = 0.5; vStar = 0.25; t_hover = 0; 
for i = 1:N
    [agent, t_end(i)] = plan_LaunchLand(makeLaunch, makeLand, cf, agent, i, h, vStar, t_hover); 
end
%Execute Flight Path
[data,ct] = FLY_PlannedPath(cf,agent,data,ct,t_end, N, t_exp);
