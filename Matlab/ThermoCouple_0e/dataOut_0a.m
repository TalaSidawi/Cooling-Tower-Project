%{
Subroutine for ThermoCouple.m
A function to write data to a file
Code writeen by James Findley de Regt, unless otherwise noted

Version ...0a is a proof of concept
%}

%% a function to write data to a file
% %{ Uncomment this bracket-open to comment out the whole function
function dataOut = dataOut_0a (dataStruct)
    % dataStruct is a three element structure
    % dataStruct.time, ...temp1, and ...temp2
    
    printData = [dataStruct.time; dataStruct.temp1; dataStruct.temp2];
    
    % print the data out
    fileID = fopen ('foo.txt', 'w');
    fprintf (fileID, '\r\n');
    fprintf (fileID, '%6s %12s %12s\r\n', 'Time', 'Temp1', 'Temp2');
    fprintf (fileID, '%6.2f %12.8f %12.8f\r\n', printData);
end

%} 