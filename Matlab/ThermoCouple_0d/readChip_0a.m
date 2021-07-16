%{
A function to return the values on a MAX31855 breakout board

Version ...0a is a proof of concept for functions in separate files
%}
%% a function to read the temperature of a termocouple in Celcius
% %{ Uncomment this bracket-open to comment out the whole function
function centigrade = readChip_0a (thermocouple)
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