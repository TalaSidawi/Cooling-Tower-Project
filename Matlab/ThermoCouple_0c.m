%% Matlab software to read a thermocouple via arduino
% relies on a MAX31855 Breakout board and type K thermocouple
%{
Software developed by James Findley de Regt
Inspiration taken from sources listed in comments throughout

...0c is intended to separate the reading of the chip to a function
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
temp1 = readTemp (TC1);
temp2 = readTemp (TC2);
%}

%% The main event
% %{ Uncomment this bracket-open to comment out the whole for loop
for i=1:100
    
    %% Start with TC1 
    centigrade = readTemp (TC1);
    temp1 = [temp1, centigrade];
    
    %% Then do TC2
    centigrade = readTemp (TC2);
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

%% a function to read the temperature of a termocouple in Celcius
% %{ Uncomment this bracket-open to comment out the whole function
function centigrade = readTemp (thermocouple)
    %{
    This code was taken from the Adafruit forum post:
    https://forums.adafruit.com/viewtopic.php?f=22&t=37534

    A lot of "magic" happens here, but it's been pretty well commented    
    
    For further reference, check the MAX31855 datasheet:
    https://cdn-shop.adafruit.com/datasheets/MAX31855.pdf
    
    And the Adafruit MAX31855 library:
    https://www.arduino.cc/reference/en/libraries/adafruit-max31855-library/
    %}

    % write 2 pieces of info in order to receive 2 pieces of info
    dataIn = [1 1];
    
    % uint16 is the largest integer you can use with
    % this function therefore you need 2
    dataOut = writeRead (thermocouple, dataIn, 'uint16');
    
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
    % I left out the 1st bit because it was the signed integer, which I didn't need.
    centigrade = bin2dec (z(2:14))*0.25; 
    % Multiplied by 0.25 since the datasheet says the LSB is 0.25°C.
    % Check the adafruit Max31855 library for an in-depth look at processing these bits.

end
%}