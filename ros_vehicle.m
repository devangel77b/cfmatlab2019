classdef ros_vehicle < matlab.mixin.SetGet
    % This class creates a matlab vehicle object which can be used to send
    % commands and receive data from ROS Enabled vehicles
    %   Detailed explanation goes here
    
    properties
        name;
        type;
        pose_topic
        vel_topic;
        desvel_topic;
        path_topic;
        traj_topic;
        wp_topic;
        path_pub;
        wp_pub;
        des_vel_pub;
        pose_sub;
        vel_sub;
        pos;vel;yaw,pose;rpy,des_vel;
        
    end
    
    methods
        function obj = ros_vehicle(varargin)
            obj.name = varargin{1};
            if(nargin>1); obj.type = varargin{2};end;
            
            
            obj.path_topic = sprintf('/%s/path',obj.name);
            obj.traj_topic = sprintf('/%s/trajectory',obj.name);
            obj.desvel_topic = sprintf('/%s/des_vel',obj.name);
            obj.wp_topic = sprintf('/%s/waypoint',obj.name);
            obj.path_pub = rospublisher(obj.path_topic,rostype.nav_msgs_Path);
            obj.wp_pub = rospublisher(obj.wp_topic,rostype.geometry_msgs_PoseStamped);
            obj.des_vel_pub = rospublisher(obj.desvel_topic,rostype.geometry_msgs_Twist);
            
            obj.vel_topic = sprintf('/vr/%s/vel',obj.name);
            obj.pose_topic = sprintf('/vrpn_client_node/%s/pose',obj.name);
            obj.pose_sub = rossubscriber(obj.pose_topic,rostype.geometry_msgs_PoseStamped,@obj.poseCallback);
            obj.vel_sub = rossubscriber(obj.vel_topic,rostype.geometry_msgs_Twist,@obj.velCallback);
%             obj.desvel_sub = rossubscriber(obj.desvel_topic,rostype.geometry_msgs_Twist,@obj.desVelCallback);
            obj.rpy = [0;0;0];
            obj.pos = [0;0;0];
            obj.vel = [0;0;0];
            
        end
        
        function poseCallback(obj,pose_sub,msg)
            obj.pos = [msg.Pose.Position.X;msg.Pose.Position.Y;msg.Pose.Position.Z];
            obj.rpy = [msg.Pose.Orientation.X; msg.Pose.Orientation.Y; msg.Pose.Orientation.Z];
%              [r,p,y]=quat2angle([msg.Pose.Orientation.W msg.Pose.Orientation.X msg.Pose.Orientation.Y msg.Pose.Orientation.Z],'XYZ');
%              obj.rpy = [r;p;y];
        end
        function velCallback(obj,vel_sub,msg)
              obj.vel = [msg.Linear.X;msg.Linear.Y;msg.Linear.Z];
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
        function dvel = get_des_vel(obj)
            
              dvel = obj.des_vel;
%             yaw = [msg.Pose.Orientation.Z]
        end        
        function send_vel(obj,vel)
            msg = rosmessage('geometry_msgs/Twist');
            msg.Linear.X = vel(1);
            msg.Linear.Y = vel(2);
            msg.Linear.Z = vel(3);
            send(obj.des_vel_pub,msg);
            
        end
        function send_wp(obj,pos)
            msg = rosmessage('geometry_msgs/PoseStamped');
            msg.Pose.Position.X = pos(1);
            msg.Pose.Position.Y = pos(2);
            msg.Pose.Position.Z = pos(3);
%             obj.wp_pub.send(msg);
            send(obj.wp_pub,msg);
            
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

