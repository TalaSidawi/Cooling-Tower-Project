%% Matlab software to read a thermocouple via arduino
% relies on a MAX31855 Breakout board and type K thermocouple
%{
Code borrowed heavily from the Adafruit forum post:
https://forums.adafruit.com/viewtopic.php?f=22&t=37534
%}

%% Create the Arduino object
% Close all possible open connections
fclose('all');
close all;
clear all;
clc;
% Create Arduino
clear a;
a = arduino('COM9','Uno','Libraries','SPI');

%% Define a bunch of stuff
% Chip select  (CS)   pin D10
% MISO         (DO)   pin 12, ICSP-1
% SCK          (CLK)  pin 13, ICSP-3
% MOSI(not used)
dev = spidev(a,'D10');

%Some other variables
t = 0;
temp = 0;
time = 0;

%% Unmodified Code
for i=1:100
    % write 2 pieces of info in order to receive 2 pieces of info
    dataIn = [1 1];
    
    % uint16 is the largest integer you can use with
    % this function therefore you need 2
    dataOut = writeRead (dev, dataIn, 'uint16');
    
    % since there are two separate pieces you
    % need to combine them to a 32-bit integer
    bytepack = uint32 (dataOut(1)); 
    
    % data(1) is the 1st half and is converted to uint32
    % and the data is shifted to the correct side.
    bytepack = bitshift (bytepack,16); 
    
    % data(2) is the 2nd half and bitor() is used
    % to place this into the correct side of uint32
    z = bitor (bytepack, uint32 (dataOut(2))); 
    
    %create a 32-bit binary number
    z = dec2bin (z,32); 
    
    % from the MAX31855 datasheet, bits 18-31 is the temperature in celcius.
    % These number are referenced backwards in matlab.
    centigrade = bin2dec (z(2:14))*0.25; 
    
    % I left out the 1st bit because it was the signed integer, which I didn't need.
    % Multiplied by 0.25 since the datasheet says the LSB is 0.25°C.
    % Check the adafruit Max31855 library for an in-depth look at processing these bits.
    temp = [temp, centigrade];
    t=t+1;
    time = [time, t];
    plot(time,temp);
    drawnow;
    pause (1);
end
