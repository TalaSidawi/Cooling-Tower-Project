%% MatLab code to run the cooling tower
%{
Here's a comment block describing the functionality of this code.
%}

function CoolingTower
%% Initial Definitions

% Initiate the arduino connections
% Close all possible open connections
fclose('all');
close all;
clear all;
clc;

% Create the Arduino object
clear a;
%channel = inputdlg ('Arduino Port (i.e. COM4)', 'Port', 1, {'COM4'});
channel = 'COM4';
a = arduino(channel, 'Uno', 'Libraries', 'PaulStoffregen/OneWire');

% Generate any global variable and functions
% All the temperatures we will want to display
tempAiWB = 99;
tempAiDB = 98;
tempAoWB = 97;
tempAoDB = 96;
tempWo   = 95;
tempWi   = 94;
tempBath = 93;


%% Defining the GUI

% This defines the overall GUI window
f = figure('Visible','off',...
    'Position', [010 010 800 600],...
    'Name','Arduino Cooling Tower',...
    'NumberTitle','off',...
    'MenuBar','none');

% I want two panels, one on the left showing a schematic and one on the
% right with user inputs and data display.

% the panel contaning the cooling tower schematic
panelSchema = uipanel('Title', 'Cooling Tower Schematic', ...
    'BackgroundColor', 'white', ...
    'Position',[.05 .05 .40 .90]);
% the panel for user inputs
panelInputs = uipanel('Title', 'Inputs', ...
    'BackgroundColor', 'white', ...
    'Position',[.55 .05 .40 .90]);

% The cooling tower schematic shows the tower and the bath 
panelTower = uipanel('Parent', panelSchema, ...
    'Title', 'Cooling Tower', ...
    'Position', [.10 .05 .40 .90]);
panelBath = uipanel('Parent', panelSchema, ...
    'Title', 'Bath', ...
    'Position', [.50 .05 .40 .40]);

% Panels to display the points of interest
% Air Intake
panelAi = uipanel('Parent', panelTower, ...
    'Title', 'Air Intake', ...
    'Position', [.05 .05 .90 .20]);
% Air Outlet
panelAo = uipanel('Parent', panelTower, ...
    'Title', 'Air Outlet', ...
    'Position', [.05 .75 .90 .20]);

% Create some text fields to show the temperatures
% Air Intake Wet Bulb
dispAiWBtext = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', 'Wet Bulb', ...
    'Position', [005 020 070 015]);
dispAiWBtemp = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', tempAiWB, ...
    'Position', [005 005 020 015]);
dispAiWBdegC = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 005 090 015]);
% Air Intake Dry Bulb
dispAiDBtext = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', 'Dry Bulb', ...
    'Position', [005 055 070 015]);
dispAiDBtemp = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', tempAiDB, ...
    'Position', [005 040 020 015]);
dispAiDBdegC = uicontrol('Parent', panelAi, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 040 090 015]);

% Air Outlet Wet Bulb
dispAoWBtext = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', 'Wet Bulb', ...
    'Position', [005 020 070 015]);
dispAoWBtemp = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', tempAoWB, ...
    'Position', [005 005 020 015]);
dispAoWBdegC = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 005 090 015]);
% Air Outlet Dry Bulb
dispAoDBtext = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', 'Dry Bulb', ...
    'Position', [005 055 070 015]);
dispAoDBtemp = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', tempAoDB, ...
    'Position', [005 040 020 015]);
dispAoDBdegC = uicontrol('Parent', panelAo, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 040 090 015]);

% Water Outlet
dispWoText = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'Water Outlet', ...
    'Position', [005 120 070 015]);
dispWoTemp = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', tempWo, ...
    'Position', [005 105 020 015]);
dispWoDegC = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 105 090 015]);
% Water Bath
dispWbText = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'Bath', ...
    'Position', [005 075 070 015]);
dispWbTemp = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', tempBath, ...
    'Position', [005 060 020 015]);
dispWbDegC = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 060 090 015]);
% Water Inlet
dispWiText = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'Water Inlet', ...
    'Position', [005 020 070 015]);
dispWiTemp = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', tempWi, ...
    'Position', [005 005 020 015]);
dispWiDegC = uicontrol('Parent', panelBath, ...
    'Style', 'text', ...
    'String', 'degrees Celcius', ...
    'Position', [025 005 090 015]);

% Button to begin temperature acquisition
bttnGetTemps = uicontrol('Parent', panelSchema, ...
    'Style','togglebutton',...
    'String', 'Temp Acq',...
    'FontUnits','normalized',...
    'Position',[005 005 090 020], ...
    'Callback',{@callbackGetTemps});

% This panel will show inputs for the system
% This block is for the heater stuff
dispSetBathTemp = uicontrol ('Parent', panelInputs, ...
    'Style', 'text', ...
    'String', 'Set bath temperature', ...
    'Position', [005 025 150 015]);

editSetBathTemp = uicontrol ('Parent', panelInputs, ...
    'Style', 'edit', ...
    'Position', [005 005 150 015], ...
    'Callback', {@callbackSetBathTemp});

% This is buttons for the blower and the pump
bttnBlower = uicontrol('Parent', panelInputs, ...
    'Style','togglebutton',...
    'String', 'Blower',...
    'FontUnits','normalized',...
    'Position',[005 055 090 020], ...
    'Callback',{@callbackBlower});
dispBlower = uicontrol('Parent', panelInputs, ...
    'Style', 'text', ...
    'String', 'Blower Status', ...
    'Position', [095 055 150 015]);


bttnPump = uicontrol('Parent', panelInputs, ...
    'Style','togglebutton',...
    'String', 'Pump',...
    'FontUnits','normalized',...
    'Position',[005 075 090 020], ...
    'Callback',{@callbackPump});
dispPump = uicontrol('Parent', panelInputs, ...
    'Style', 'text', ...
    'String', 'Pump Status', ...
    'Position', [095 075 150 015]);

% Maybe a panel showing a little historical graph?


%% Callback Functions - Live Temp Schematic
    function callbackGetTemps (source, eventdata)
        %disp ('Begining Data Acquisition');
        i = 0;
        while bttnGetTemps.Value == 1
            if bttnGetTemps.Value == 0
                %disp ('Halting Data Acquisition');
                break;
            end
            
            %code that actually acquires temps here
            fluc = ((randn * 5) - 2);
            tempBath = tempBath + fluc;
            dispWbTemp.String = tempBath;
            
            i = i + 1;
            pause (0.1);
            
        end
    end

    function callbackSetBathTemp (source, eventdata)
        input = str2double (editSetBathTemp.String);
        if isnan (input)
            errordlg ('You must enter a numeric value', 'Invalid Input', 'modal')
            uicontrol (editSetBathTemp);
            return
        else
            tempBath = input;
            dispWbTemp.String = tempBath;
            disp (input);
        end
    end

    function callbackBlower (source, eventdata)
        if bttnBlower.Value == 1
            dispBlower.BackgroundColor = 'red';
            dispBlower.String = 'Blower On';
        end
        if bttnBlower.Value == 0
            dispBlower.BackgroundColor = 'green';
            dispBlower.String = 'Blower Off';
        end
    end

    function callbackPump (source, eventdata)
        if bttnPump.Value == 1
            dispPump.BackgroundColor = 'red';
            dispPump.String = 'Pump On';
        end
        if bttnPump.Value == 0
            dispPump.BackgroundColor = 'green';
            dispPump.String = 'Pump Off';
        end
    end

%% Callback Functions - System Inputs

%% Callback Functions - Heater Stuff

%% Display the Window
% Show Window
movegui(f,'center')
f.Visible='on';
end