_: let 
      font = "JetBrainsMono Nerd Font";
   in '' 

  * {
    border: none;
    font-family: JetBrainsMono Nerd Font;
    font-size: 14px;
  }
     
  window#waybar { 
    background-color: #1E1E2E; 
    color: #cdd6f4;   
  }

  .modules-left {
	  background-color: #1E1E2E;
	  padding: 0px 0px 0px 0px;
  }

  .modules-right {
	  background-color: #1E1E2E;
	  padding: 0px 6px 0px 0px;
  }

  #workspaces button {
    margin: 0px 3px;
	  padding: 0px 11px 0px 11px; 
 	  min-width: 1px;
	  color: #888888;
  }

  #workspaces button.active {
    padding: 0px 11px 0px 11px;
    background-color: #40404D;
    color: #ffffff;
  }

  #workspaces button.focused { 
	  padding: 0px 11px 0px 11px; 
	  background-color: #343442;
	  color: #ffffff;
  }

  #workspaces button.urgent {
    color: #ded571;
  }

  #mode { 
	  background-color: #900000;
	  color: #ffffff;
    padding: 0px 5px 0px 5px;
  }

  #window {
    color: #ffffff;
    background-color: #1E1E2E;
    padding: 0px 10px 0px 10px;
  }

  window#waybar.empty #window {
	  background-color: transparent;
    color: transparent;
  }

  window#waybar.empty {
	  background-color: #1E1E2E;
  }

  #clock,
  #battery,
  #cpu,
  #memory,
  #network,
  #pulseaudio,
  #tray,
  #mode {
    padding: 0px 10px;
    margin: 3px 0px;
    border-radius: 4px;
    color: white;
    background-color: #3C4048;
  }

  #clock {
    margin-right: 7px;
  }

  #tray{
    padding: 0px 8px 0px 5px;
    margin: 0px 5px 0px 5px;
  }

  ''

