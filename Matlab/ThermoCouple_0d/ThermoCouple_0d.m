%% Matlab software to read a thermocouple via arduino
% relies on a MAX31855 Breakout board and type K thermocouple
%{
Software developed by James Findley de Regt
Inspiration taken from sources listed in comments throughout

...0d is intended to move the reading of the chip to a separate .m file
%}

%% Create the Arduino object
% Close all possible open connections
fclose('all');
close all;
clear all;
clc;
% Create Arduino object
clear a;
a = arduino('COM9','Uno','Libraries','SPI');

%% Define a bunch of stuff
% %{ Uncomment this bracket-open to comment out the definitions
% MOSI         (not used)
% MISO         (DO)   pin 12, ICSP-1
% SCK          (CLK)  pin 13, ICSP-3
% Chip select  (CS)   varies per board
TC1 = spidev (a, 'D2');
TC2 = spidev (a, 'D3');

%Some other variables
t = 0;
time = 0;
% readTemp returns the current temperature of a thermocouple
temp1 = readChip_0a (TC1)
temp2 = readChip_0a (TC2)
%}

%% The main event
% relies upon the subroutine readChip_0a

% %{ Uncomment this bracket-open to comment out the whole for loop
for i=1:100
    
    %% Start with TC1 
    centigrade = readChip_0a (TC1);
    temp1 = [temp1, centigrade];
    
    %% Then do TC2
    centigrade = readChip_0a (TC2);
    temp2 = [temp2, centigrade];
    
    %% And then plot both of them
    t=t+1;
    time = [time, t];
    plot (time, temp1);
    hold on;
    plot (time, temp2);
    hold off;
    drawnow;
    pause (0.1);
end
%}

