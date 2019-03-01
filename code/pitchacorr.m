% Pitch estimation using the autocorrelation method
function [f0] = pitchacorr(len, fs, xseg)
    % LPF at 900Hz
    [bf0, af0] = butter(4, 900/(fs/2));
    xseg = filter(bf0, af0, xseg);
    % find the clipping level, CL
    i13 = len/3;
    maxi1 = max(abs(xseg(1:i13)));
    i23 = 2 * len/3;
    maxi2 = max(abs(xseg(i23:len)));
    if maxi1>maxi2
        CL=0.68*maxi2;
    else
        CL= 0.68*maxi1;
    end
% Center clip waveform, and compute the autocorrelation
    clip = zeros(len,1);
    ind1 = find(xseg>=CL);
    clip(ind1) = xseg(ind1) - CL;
    ind2 = find(xseg <= -CL);
    clip(ind2) = xseg(ind2)+CL;engy = norm(clip,2)^2; %energy of clipped waveform
    RR = xcorr(clip); %compute autocorrelation function of clipped waveform
    m = len;
    % Find the max autocorrelation in the range 60 <= f <= 320 Hz
    LF = floor(fs/320);
    HF = floor(fs/60);
    Rxx = abs(RR(m+LF:m+HF));
    [rmax, imax] = max(Rxx);
    imax = imax + LF;
    f0 = fs/imax;
    % Check max RR against V/UV threshold
    silence = 0.4*engy;
    if (rmax > silence) & (f0 > 60) & (f0 <= 320)
        f0 = fs/imax;
    else % -- its unvoiced segment ---------
        f0 = 0;
    end
end