function [avgF0] = pitch(x, fs)
    x=x(:); %vectorize the speech signal
    % get the number of samples
    ns = length(x);
    % error checking on the signal level, remove the DC bias
    mu = mean(x);
    x = x-mu;
    % use a 60msec segment, choose a segment every 50msec
    % that means the overlap between segments is 10msec
    fRate = floor(120*fs/1000);
    updRate = floor(110*fs/1000);
    nFrames = floor(ns/updRate)-1;
    % the pitch contour is then a 1 x nFrames vector
    f0 = zeros(1, nFrames);
    f01 = zeros(1, nFrames);
    % get the pitch from each segmented frame
    k = 1;
    avgF0 = 0;
    m = 1;
    for i=1:nFrames %nframes means total no. of frames
        xseg = x(k:k+fRate-1);
        f01(i) = pitchacorr(fRate, fs, xseg); %f01 is the vector which contains
        %pitch of all frames
        % do some median filtering for every 3 frames so that less affected by the noise
        %if nframes<=3 i.e no. of frames is less than equal to 3 then no need to
        %median filtering.
        if i>2 & nFrames>3
            z = f01(i-2:i); %median filtering when nframes>3
            md = median(z);f0(i-2) = md;
            if md > 0
                avgF0 = avgF0 + md;
                m = m + 1;
            end
            elseif nFrames<=3 %no need of median filtering
                f0(i) = a;
                avgF0 = avgF0 + a;
                m = m + 1;
        end
        k = k + updRate;
    end
    if m==1
        avgF0 = 0;
    else
        avgF0 = avgF0/(m-1); %finally average f0 is calculated
    end
end
           

     
      

     