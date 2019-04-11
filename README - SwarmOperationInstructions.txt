Title: Crazyflie Swarm Operation Instructions and Hints
Author: ENS J. Gainer
Date: 22AUG18


Record: 
22Aug18 - Created 


Document: 
Hardware Needed: 
-Odroid (ROS Master)
-Ethernet network switch (all computers used connected via ethernet)
-OptiTrack Computer (Runs Motive Software, gives positions to ROS)
-Linux Computer (Runs ROS interface)
-MATLAB Comptuer (Runs MATLAB experiment, talks to ROS)
-Crazyradios (plugged into USB hub if needed)
-Crazyflies with prop guards and OptiTrack Markers 


Swarm Operation Startup Instructions: 
1. Turn on PowerStrip for odroid and OptiTrack Cameras
2. Turn on OptiTrack Computer, Launch Motive Software
	-- While this is powering up, turn on Linux Computers and MATLAB Computers
3. OptiTrack Computer: Load OptiTrack Project (Titled: Swarm.tpp)
	-- Ensure all OptiTrack cameras have blue ring lit up. 
	-- Change Motive Layout to "Capture" -> Make sure you see your rigid bodies
4. Linux Computer: Open up a new terminal 
	-- ssh into odroid (ssh odroid @10.1.1.200)
	-- Run OptiTrack bridge (roslaunch optitrack_bringup optitrack.launch)
5. Turn on Crazyflies you plan to use
	-- Ensure they are visible to the OptiTrack the rigid bodies are selected active and have accurate tracking
	-- Generally good idea to leave plugged into charger during initial connection to save battery
6. Linux Computer: Open up a new terminal (ctrl+shift+n) if in terminal window
	-- Navigate to CrazyWorkspace (cd CrazyWorkspace)
	-- Load radio addresses (rosparam load uri_list.yaml)	
	-- Ensure that 9 CrazyRadios are connected if loading addresses up to 25 agents (other wise you will get an errror checking for a radio that doesn't exist) -> Can change as needed
	-- Run crazyflie server (rosrun crazyflie_driver crazyflie_server)
7. Linux Computer: Open 'crazy_pos_ctrl.launch' in gedit located in CrazyWorkspace
	-- Change boolean statement to "true" for all crazyflies intended for flight
	-- Save the new form of the file 
8. Linux Computer: Open up a new terminal (ctrl+shift+n) if in terminal window
	-- Run the launch file (roslaunch crazy_pos_ctrl.launch)
--Update: You should see several status messages coming accross in the server about getting connection
--Update: You should see green and red lights flickering on the crazyflie during the connection sequence 
9. Test connections, check a battery level 
	-- rostopic echo /crazyflie#/battery
-----NOT SURE WHY WE NEED TO DO STEPS 10-13, FURTHER CHECKS NEEDED---------
10. Power cycle all crazyflies. Ensure they are set down level on the ground when powering up to pass self tests
11. Linux Computer: Ctrl-C (end) the 'crazy_pos_ctrl.launch' terminal 
	-- Wait for full shutdown
12. Linux Computer: Relaunch 'crazy_pos_ctrl.launch' 
	-- Run the launch file (roslaunch crazy_pos_ctrl.launch)
13. Recheck connections, check a battery level 
	-- rostopic echo /crazyflie#/battery
14. MATLAB Computer: Create cf objects -> see MATLAB code Gainer - Research\01 - Swarm Ops\FLY_(anytitle) will be in the first sections 
	-- Ensure to enter agent ids in array '[#,#,#,#...}'
--Update: You are now ready to fly from a MATLAB script 
--Note: I generally like to run a test launch land to make sure that the crazyflie is working properly and streaming back the correct data
16. Setup and start cameras if desired 
15. MATLAB Computer: Run your MATLAB experiment. Further instructions in MATLAB documentation
	


Swarm Maintenance Hints: 
	Propellor Guards - 	3D Printed on MakerBots in Gamma Lab (ensure Prof. Bishop gives permission) using normal PLA. If possible, Tough PLA works better. 
				Use the part found at the following path: Gainer - Research\08 - CAD Development\CrazyFlie2PropGuard.stl. Upload the part into the Maker
				Ware software and copy it (Ctrl-C after selecting the part) to arrange 4 per build plate. Go into the MakerWare print settings and INCREASE
				the raft/base layer to first layer distance. If you don't do this you will have a lot of trouble removing the thin guards from the build raft. 
				Increasing this distance does not affect the print and reduces the adhesion of the part to the support material. Use an exacto knife to trace the
				edges of the part and then use a scraper to gently remove the part from the raft (they break easily). 
	Prop Guard Placement -	Use hot glue to affix the prop guards to the plastic landing feet of the crazyflies. Remove all props to put new prop guards on. When 
				glueing hold the prop guard away from the motor housing and place a small blob of glue on the motor near the top of the plastic motor housing 
				in between the two plastic landing feet. Then push the prop guard down onto the glue to get a good stick. 
	OptiTrack Markers - 	Refer to the naming guidance README found at: Gainer - Research\01 - Swarm Ops\Naming Database\README.txt
	 				