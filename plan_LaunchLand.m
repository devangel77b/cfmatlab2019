function [agent, t_end] = plan_LaunchLand(makeLaunch, makeLand, cf, agent, j, h, vStar, t_hover)
% Launch & Land
% 06AUG18
% J. Gainer
% The following code creates launch and land trajectories for
% implementation with Crazyflie 2.0 on board poisition controller


% I. Grab Current Position 
[pos,~] = cf{j}.get_pose();
% Get data for the specified agent
pause(0.001);  % -> CHECK NEED FOR PAUSE
% -> Get current position, orientation (roll, pitch, yaw)

if pos(3) < 0 
    pos(3) = 0;
end

%% II. Create Path

if makeLaunch 
    %Make start behavior: launch
    fprintf('Making launch trajectory...\n');
    %No change in X/Y position, immediately above start point
    launch_init = pos;
    launch_fin = [pos(1); pos(2); h];
    %Create Path Params
    mL =  launch_fin(3) - launch_init(3); 
    Coef_L = [mL, launch_init(3)];
    mag = h - pos(3); 
elseif makeLand
    %Make end behavior: land
    fprintf('Making landing trajectory...\n');
    %No change in X/Y position, immediately above start point
    land_init = pos;
    land_fin = [pos(1); pos(2); 0]; 
    %Create Path Params
    mL = land_fin(3) - land_init(3); 
    Coef_L = [mL, land_init(3)];
    mag = pos(3); 
end

%Make pp for rT
breaks = [1,2]; 
ppL = mkpp(breaks, Coef_L);

%Differentiate pp for rTdot
[breaks,coefs,l,k,d] = unmkpp(ppL);
dppL = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);

% III. Evaluate for s(t)
%Create st
st_max = max(breaks);
st = 1; ii = 1;
tstep = 0.01;
%CALCULATE NUMERICAL DERIVATIVES
dsdt = vStar/mag;
while st < st_max
    %CALCULATE INSTANTANEOUS TRAJECTORY
    %Evalutae pp over time
    z = ppval(ppL, st); 
    dz = ppval(dppL, st);  

    % Assemble rT, rTdot, rTddot, and PsiT for control
    rT_tmp = [pos(1); pos(2); z];
    rTdot_tmp = [0; 0; dz*dsdt];
    agent(j).desired.rT(:,ii)     = rT_tmp;
    agent(j).desired.rTdot(:,ii)  = rTdot_tmp;

    %EULER INTEGRATION
    st = st + dsdt*tstep;
    ii = ii + 1;
end
%Add additional hover points
hovIDX = t_hover/.01; 
agent(j).desired.rT(:,ii:ii+hovIDX-1) = repmat(agent(j).desired.rT(:,ii-1),1,hovIDX);
agent(j).desired.rTdot(:,ii:ii+hovIDX-1) = repmat(agent(j).desired.rTdot(:,ii-1),1,hovIDX);
%Truncate any old data points
agent(j).desired.rT(:,ii+hovIDX:end) = [];
agent(j).desired.rTdot(:,ii+hovIDX:end) = []; 
t_end = length(agent(j).desired.rT(1,:))/100; 
end