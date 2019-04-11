classdef crazyflie < matlab.mixin.SetGet
    % This class creates a matlab vehicle object which can be used to send
    % commands and receive data from ROS Enabled vehicles
    %   Detailed explanation goes here
    
    properties
        name;
        type;
        id;
%         fig;
        axs;
        pos_plt; des_plt;aux_plt;tail_plt;
        pose_topic;vel_topic;batt_topic;desvel_topic;cmd_acc_topic;path_topic;traj_topic;
        wp_topic;
        ref_pos_topic;
        ref_vel_topic;
        rssi_topic;
        loiter_topic; 
        path_pub;
        wp_pub;
        ref_pos_pub;
        ref_vel_pub;
        des_vel_pub;
        des_acc_pub;
        loiter_pub; 
        pose_sub;
        vel_sub;
        batt_sub;
        rssi_sub;
        pos;vel;batt;yaw,pose;rpy,des_vel;rssi;
        my_color;
        aux_pos;
        batt_vals; 
        
    end
    
    methods
        function obj = crazyflie(varargin)
            
            switch (length(varargin))
                case 1
                    obj.id = varargin{1};
                case 2
                    obj.id = varargin{1};
%                     obj.fig = varargin{2};
%                     obj.axs = get(obj.fig,'Children');
%                     obj = init_plots(obj);
                otherwise 
            end
            color_array = colormap('lines');
            %obj.my_color = color_array(obj.id,:);
            obj.name = sprintf('crazyflie%d',obj.id);
            obj.path_topic = sprintf('/%s/path',obj.name);
            obj.traj_topic = sprintf('/%s/trajectory',obj.name);
            obj.desvel_topic = sprintf('/%s/des_vel',obj.name);
            obj.cmd_acc_topic = sprintf('/%s/cmd_acc',obj.name);
            obj.ref_pos_topic = sprintf('/%s/ref_pos',obj.name);
            obj.ref_vel_topic = sprintf('/%s/ref_vel',obj.name);
            obj.wp_topic = sprintf('/%s/waypoint',obj.name);
            obj.loiter_topic = sprintf('/%s/loiter',obj.name);
            obj.rssi_topic = sprintf('/%s/rssi',obj.name);        
            obj.path_pub = rospublisher(obj.path_topic,rostype.nav_msgs_Path);
            obj.wp_pub = rospublisher(obj.wp_topic,rostype.geometry_msgs_PoseStamped);
            obj.loiter_pub = rospublisher(obj.loiter_topic,rostype.geometry_msgs_PoseStamped);
            obj.des_vel_pub = rospublisher(obj.desvel_topic,rostype.geometry_msgs_Twist);
            obj.des_acc_pub = rospublisher(obj.cmd_acc_topic,rostype.geometry_msgs_Twist);
            obj.ref_pos_pub = rospublisher( obj.ref_pos_topic,rostype.geometry_msgs_PoseStamped);
            obj.ref_vel_pub = rospublisher( obj.ref_vel_topic,rostype.geometry_msgs_Twist);
            obj.vel_topic = sprintf('/%s/vel',obj.name);
            obj.pose_topic = sprintf('/vrpn_client_node/%s/pose',obj.name);
            obj.batt_topic = sprintf('/%s/battery',obj.name);
            %Change topics
            obj.pose_sub = rossubscriber(obj.pose_topic,rostype.geometry_msgs_PoseStamped,@obj.poseCallback);
            obj.vel_sub = rossubscriber(obj.vel_topic,rostype.geometry_msgs_Twist,@obj.velCallback);
            obj.batt_sub = rossubscriber(obj.batt_topic,rostype.std_msgs_Float32,@obj.battCallback);
            obj.rssi_sub = rossubscriber(obj.rssi_topic,rostype.std_msgs_Float32,@obj.rssiCallback);
            obj.rpy = [0;0;0];
            obj.pos = [0;0;0];
            obj.vel = [0;0;0];
            obj.batt_vals = [0,0,0]; 
            
        end
%         function obj = init_plots(obj)
%         set(obj.axs,'XLim',[-3 3],'YLim',[-3 3])
%         plot(obj.axs,0,0)
%         hold(obj.axs,'on')
%         grid(obj.axs,'on')
%         obj.pos_plt = plot(obj.axs,0,0);
%         obj.des_plt = plot(obj.axs,0,0);
%         obj.aux_plt = plot(obj.axs,0,0);
%         end
%         function poseCallback(obj,pose_sub,msg)
%              obj.pos = [msg.Transform.Translation.X;msg.Transform.Translation.Y;msg.Transform.Translation.Z];
%              obj.rpy = [msg.Transform.Rotation.X; msg.Transform.Rotation.Y; msg.Transform.Rotation.Z];                           
%         end
        function poseCallback(obj,pose_sub,msg)
            obj.pos = [msg.Pose.Position.X;msg.Pose.Position.Y;msg.Pose.Position.Z];
            obj.rpy = [msg.Pose.Orientation.X; msg.Pose.Orientation.Y; msg.Pose.Orientation.Z];
        end
        function velCallback(obj,vel_sub,msg)
              obj.vel = [msg.Linear.X;msg.Linear.Y;msg.Linear.Z];
        end
        function battCallback(obj,batt_sub,msg)
            obj.batt_vals(1) = obj.batt_vals(2);
            obj.batt_vals(2) = obj.batt_vals(3);
            obj.batt_vals(3) = msg.Data;
        end
        function rssiCallback(obj,rssi_sub,msg)
              obj.rssi = msg.Data;
        end        
        function desVelCallback(obj,desvel_sub,msg)
              obj.des_vel = [msg.Linear.X;msg.Linear.Y;msg.Linear.Z];
        end
        
        function [pos,rpy] = get_pose(obj)            
            pos = obj.pos;
            rpy = obj.rpy;    
        end
        
        function vel = get_vel(obj)
            
              vel = obj.vel;
%             yaw = [msg.Pose.Orientation.Z]
        end
        
        function batt = get_batt(obj)
            batt = mean(obj.batt_vals);              
        end
        function rssi = get_rssi(obj)
            rssi = obj.rssi;            
        end        
        
        function dvel = get_des_vel(obj)
            
              dvel = obj.des_vel;
%             yaw = [msg.Pose.Orientation.Z]
        end 
        function set_aux(obj,pos)
            obj.aux_pos = pos;
           
        end
        function send_vel(obj,vel)
            msg = rosmessage('geometry_msgs/Twist');
            msg.Linear.X = vel(1);
            msg.Linear.Y = vel(2);
            msg.Linear.Z = vel(3);
            send(obj.des_vel_pub,msg);
            
        end
        function send_ref(obj,pos,vel)
                  
            msg = rosmessage('geometry_msgs/PoseStamped');
            msg.Pose.Position.X = pos(1);
            msg.Pose.Position.Y = pos(2);
            msg.Pose.Position.Z = pos(3);
            send(obj.ref_pos_pub,msg);

            msg2 = rosmessage('geometry_msgs/Twist');
            msg2.Linear.X = vel(1);
            msg2.Linear.Y = vel(2);
            msg2.Linear.Z = vel(3);
            send(obj.ref_vel_pub,msg2);
            
            
        end
        function send_wp(obj,pos)
            msg = rosmessage('geometry_msgs/PoseStamped');
            msg.Pose.Position.X = pos(1);
            msg.Pose.Position.Y = pos(2);
            msg.Pose.Position.Z = pos(3);
            msg.Pose.Orientation.W = 1; 
%             obj.wp_pub.send(msg);
            send(obj.wp_pub,msg);
%             if(ishandle(obj.fig))
%                set(obj.pos_plt,'XData',obj.pos(1),'YData',obj.pos(2),'Marker','*')                
%                set(obj.aux_plt,'XData',obj.aux_pos(1),'YData',obj.aux_pos(2),'Marker','x','Color',obj.my_color)
%                set(obj.des_plt,'XData',pos(1),'YData',pos(2),'Marker','s','Color',obj.my_color)
%                drawnow;
%             end
            
        end
        function goto_loiter(obj,pos)
            msg = rosmessage('geometry_msgs/PoseStamped');
            msg.Pose.Position.X = pos(1);
            msg.Pose.Position.Y = pos(2);
            msg.Pose.Position.Z = pos(3);
%             yaw = angle2quat(
            msg.Pose.Orientation.W = 1; 
            send(obj.loiter_pub,msg);
%             if(ishandle(obj.fig))
%                set(obj.pos_plt,'XData',obj.pos(1),'YData',obj.pos(2),'Marker','*')                
%                set(obj.aux_plt,'XData',obj.aux_pos(1),'YData',obj.aux_pos(2),'Marker','x','Color',obj.my_color)
%                set(obj.des_plt,'XData',pos(1),'YData',pos(2),'Marker','s','Color',obj.my_color)
%                drawnow;
%             end
            
        end
        
        function send_path(obj,path)
            msg = rosmessage('nav_msgs/Path');
            tmp_pose = rosmessage('geometry_msgs/PoseStamped');
            [m,n] = size(path);
            for i=1:m
               
               msg.Poses(i).Pose.Position.X = path(i,1);
               msg.Poses(i).Pose.Position.Y = path(i,2);
               msg.Poses(i).Pose.Position.Z = path(i,3);
            end
            
            
        end
        
        %         function obj = poseCallBack(obj,pose_sub,msg)
        %             obj.pos = [msg.Pose.Position.X;msg.Pose.Position.Y;msg.Pose.Position.Z];
        %             obj.pos = pos;
        %             [roll,pitch,yaw] = quat2angle([msg.Pose.Orientation.W,msg.Pose.Orientation.X,msg.Pose.Orientation.Y,msg.Pose.Orientation.Z],'XYZ');
        %             obj.rpy = [roll;pitch;yaw];
        %         end
        
    end
    methods (Static)
        
    end
    
end

