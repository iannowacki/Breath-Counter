clc
clear
close all

% Extract sample data and sample rate from test recording file.
[fullwav, Fs] = audioread('191106_342_mono4FILTERED.wav');

% Set size (in seconds) of segments to be analysed.
segmentsize = 20

% Find out how many of these segments are in test file (eg. 1hr long file
% contains 180 x 20second segments. 
segments = floor((length(fullwav)/Fs)/segmentsize);


% For loop will iterate for the number of segments
for n = 1:segments
    
    % Create cell structure to hold each of the 20 second segments
    A{n} = fullwav((n*(Fs*segmentsize)):(n*(Fs*segmentsize))+(Fs*segmentsize));
    % Cell structure to hold the sum of the frequency content for each
    % segment
    B{n} = sum(abs(fft(A{n})));
    
    % If statement to select only segments of a particular frequency
    % content sum value (manual listening test show sounds outwith this band
    % are nearly always unusable (too much background noise usually)
    if B{n} > 2.0000e+06 && B{n} < 4.0000e+06
        
       % Segments which meet this criteria are then tested to see if a Breaths Per Minute value can be obtained 
       z = A{n};
       t = length(z)/Fs;
       % 3rd order low pass butterworth filter.
       [a,b] = butter(3,1/(Fs/2.15), 'low');
       
       % Absolute positive values obtained and saved for each sample value.
       yabs = abs(z);
       
       % Implement filter which gives us a smoothed envelope for easier
       % feature analysis
       env = filter(a,b,yabs);
    
       % Create cell structure to store each of each of these envelopes for
       % manual analysis
       ENV{n} = env;
       
       % findpeaks() function searching for peaks in the envelope of a
       % minimum prominence from surrounding peaks. b1 output is number of
       % peaks found
       [b1, a1] = findpeaks(env, 'MinPeakProminence', 0.005);
       % Save the number of peaks found in this segment (this will be part of BPM
       % calculation)
       g = length(b1);
       % New cell structure called BPM which, if the if condition above is
       % met, will receive calculated BPM values. 60 is a full minute which
       % is divided by segment size to give number of segments per minute
       % (ie there are 3x 20 second segments per minute so number of
       % breaths per minute is calculated by multiplying number of breaths
       % in 20 seconds then multiplying by 3 -this limits the resolution to 3
  
       BPM{n} = g*(60/segmentsize);
    
       % Second condition set that BPM must be within a certain range
       % (15-40 in this case)
       % Manual listening shows that when a BPM is detected outwith this it is erroneous
       if BPM{n} > 15 && BPM{n} < 40
           % If segment meets this second criteria then a corresponding '1'
           % is recorded on a vector at the index of the current outer for loop iteration.
            detected(n) = 1;
       else
           % If both conditions aren't met then BPM is not saved and a
           % corresponding '0' is saved on the 'detected' vector.
            BPM{n} = 0;
            detected(n) = 0;
       end
    
    else
    % If sound is not within lower and upper limits of the sum of spectral
    % power then detected '0' is marked on corresponding index of 'detected' vector
    detected(n) = 0;
end   
  
    
end

% Area for manual listening tests - type in which segment you would like to
% analyse:
testseg = 221

% Plot smoothed envelope line graph for easy manual time domain analysis. 
% If the plot is blank it means breath was not successfully detected in that segment 
figure(1);
plot(ENV{testseg})

% sound() function to listen back to test segment/
sound(A{testseg}, Fs)

% displaying results

% Cell saving whether each individual segment can be breath detected or not (1 for
% yes, detected. 0 for not detected.
detected

% Shows cell structure holding BPM values for each segment.
BPM

% Cell structure of sums of frequency content for each segment.
B
% displays total number of segments detected
Total_Segments = segments

% Adding up all the 1s to show number of successfully detected segments
Detected_Segments = sum(detected)

% Calculate overall what percentage of how many cells were successfully
% detected and analysed vs total overall cells.
Detection_Percentage = Detected_Segments/segments

% Write BPM values to excel file for further analysis (changing columns to
% rows with ' operator
writecell(BPM', 'BPM.xls');
