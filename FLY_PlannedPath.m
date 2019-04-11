function [data,ct] = FLY_PlannedPath(cf,agent,data,ct,t_end, N, t_exp)
%FLY_PLANNEDPATH - Structured loops to 
%   Detailed explanation goes here
%Prep Experiment
idx = zeros(1,N); %Initialize idx to 0
t_cur = zeros(1,N); %Initalize t_cur to 0
%t_ag = zeros(N,1);
wp = zeros(N,3); d_vel = zeros(N,3); %Initalize t_cur to 0

%Start Timers
t_start = tic;
for i = 1:N
    t_ag(i) = tic;
end
%Execute Flight Path
while(toc(t_start) < t_end-1)
    %Update experiment time
    fprintf('Running experiment \n')
    toc(t_start)
    
    % Cycle through each agent
    for j = 1:N
        % Get agent time to sent waypoints
        % -> This estimates the index value *assuming* the time is evolving at
        %    100 Hz
        t_cur(j) = toc(t_ag(j));
        idx(j) = round(t_cur(j)*100);
        % -> Force first index value if index is less than 1
        if idx(j) < 1
            idx(j) = 1;
        elseif idx(j) > length(agent(j).desired.rT)
           idx(j) = length(agent(j).desired.rT); 
        end
        
        % Isolate data to send to agent
        wp(j,:) = agent(j).desired.rT(:,idx(j));
        d_vel(j,:) = agent(j).desired.rTdot(:,idx(j));
        
        %Test
%          wp(j,:)
%          pause()
        % Send data to agent
        cf{j}.send_wp(wp(j,:));             % Send position waypoint
        %         cf{j}.send_vel(d_vel(j,:));         % Send velocity waypoint
        
        % Get data for the specified agent
        pause(0.001);  % -> CHECK NEED FOR PAUSE
        % -> Get current position, orientation (roll, pitch, yaw)
        [pos,rpy] = cf{j}.get_pose();
        % -> Get current velocity
        pause(0.001);  % -> MAY NEED TO UNCOMMENT
        vel = cf{j}.get_vel();
        % -> Get current battery
        pause(0.001);  % -> MAY NEED TO UNCOMMENT
        batt_tmp =  cf{j}.get_batt();
        if isempty(batt_tmp)
            batt = 0;
        else
            batt = batt_tmp;
        end
        
        % -> Structure data
        data(j).t(:,ct) = toc(t_exp);
        data(j).pos(:,ct) = pos;
        data(j).rpy(:,ct) = rpy;
        data(j).vel(:,ct) = vel;
        data(j).des_pos(:,ct) = wp(j,:);
        data(j).des_vel(:,ct) = d_vel(j,:);
        data(j).batt(:,ct) = batt;
    end
    ct = ct +1; % Cycle data index
end

end

