

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
%% FLIGHT TEST
clear data wp
pause(0.01) 
data.vehicles=[];
data.time=[];
N=1; %number of agents
h=[0 0 0.31];
wp_init=zeros(N,3);    
% Grab Current Position 
for ii=1:N
[pos,~] = cf{ii}.get_pose();
% Get data for the specified agent
pause(0.001);  % -> CHECK NEED FOR PAUSE
% -> Get current position, orientation (roll, pitch, yaw)

if pos(3) < 0 
    pos(3) = 0;
end


figure(1)
clf
hold on
vic=plot3(cf{ii}.pos(1),cf{ii}.pos(2),cf{ii}.pos(3),'go');
%start time
tic 
wp_init(ii,1:3)=cf{ii}.get_pose()';
end
%Launch Test
ct=1; %initialize counter
while(toc<10)
    for ii=1:N
        wp=cf{ii}.pos';
    if toc<4
        cf{ii}.send_wp(wp_init(ii,1:3)+h);
    elseif toc>4 && toc<8
        cf{ii}.send_wp(wp_init(ii,1:3)+[0 0 0.5]);
    %elseif toc>=6 && toc<20
    %    cf{ii}.send_wp([0.3*sin(2*pi/15*toc) 0.3*cos(2*pi/15*toc) 0.3]);
    else
        cf{ii}.send_wp(wp_init(ii,1:3)+[0 0 0.2]);
    end
    
    
    
      data.vehicles(ii).pos(ct,1:3)=cf{ii}.get_pose()';
      if data.vehicles(ii).pos(ct,3)<0
         data.vehicles(ii).pos(ct,3)=0; 
      end
      data.vehicles(ii).rpy(ct,1:3)=cf{ii}.rpy()';
      data.time(ct,1)=toc;
      pause(0.001) %for some reason this is required for data logging
      set(vic,'XData',data.vehicles(ii).pos(ct,1),'YData',data.vehicles(ii).pos(ct,1),'ZData',data.vehicles(ii).pos(ct,1))
    end  % end for
      toc
      ct=ct+1;
end %end while

figure(2)
clf
hold on
plot3(data.vehicles(1).pos(:,1),data.vehicles(1).pos(:,2),data.vehicles(1).pos(:,3))
xlabel('X')
ylabel('Y')
zlabel('Z')

figure(3)
clf
hold on
plot(data.vehicles(1).pos(:,1),data.vehicles(1).pos(:,2))
xlabel('X')
ylabel('Y')