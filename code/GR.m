% deltaDelta & delta unused
clc;
clear;
Fs = 16000;
ns = Fs * 0.060; %number of samples in 60 ms
overlap = Fs * 0.01; %number of samples to overlap 10 ms
step = ns - overlap; %length of each step --- 50ms 
for t=1:2608
    myFile = ['C:\Users\Ashkan\Documents\MATLAB\GenderRecognition\TIMIT\TIMIT_TrainM\trainMale (' int2str(t) ').wav'];
    [trainMaleSounds{t}, Fs] = audioread(myFile);
    maleFeature(t,2) = pitch(trainMaleSounds{t}, Fs); %first feature for male : pitch_period
    maleFeature(t,1) = 1; %male target = +1
    [maleMFCC, deltaMale, deltaDeltaMale] = mfcc(trainMaleSounds{t}, Fs, 'WindowLength', ns,'OverlapLength', overlap);
    meanMale = mean(maleMFCC,1);
    temp = meanMale;
    maleFeature(t,3:16) = temp; %14 MFCC coefficient for male
    shortTimeEnergyMale = ShortTimeEnergy(trainMaleSounds{t}, ns, ns-overlap);
    maleFeature(t,18) = mean(shortTimeEnergyMale); %short time energy feature for male
    spectralCentroidMale = SpectralCentroid(trainMaleSounds{t}, ns, ns-overlap, Fs);
    maleFeature(t,17) = mean(spectralCentroidMale); %spectral centroid feature for male
end
clear temp;
for t=1:1088
    myFile = ['C:\Users\Ashkan\Documents\MATLAB\GenderRecognition\TIMIT\TIMIT_TrainF\trainFemale (' int2str(t) ').wav'];
    [trainFemaleSounds{t}, Fs] = audioread(myFile);
    femaleFeature(t,2) = pitch(trainFemaleSounds{t}, Fs); %pitch_period feature for female : 
    femaleFeature(t,1) = -1; %female target = -1
    [femaleMFCC, deltaFemale, deltaDeltaFemale] = mfcc(trainFemaleSounds{t}, Fs, 'WindowLength', ns,'OverlapLength', overlap);
    meanFemale = mean(femaleMFCC,1);
    temp = meanFemale;
    femaleFeature(t,3:16) = temp; %14 MFCC coefficient for female
    shortTimeEnergyFemale = ShortTimeEnergy(trainFemaleSounds{t}, ns, ns-overlap);
    femaleFeature(t,18) = mean(shortTimeEnergyFemale); %short time energy feature for female
    spectralCentroidFemale = SpectralCentroid(trainFemaleSounds{t}, ns, ns-overlap, Fs);
    femaleFeature(t,17) = mean(spectralCentroidFemale); %spectral centroid feature for female


end
clear temp;
feature = [maleFeature; femaleFeature];

keepvars = {'feature', 'Fs', 'ns', 'overlap', 'QuadraticSVMModel', 'step'};
clearvars('-except', keepvars{:});

% Test Started Here
cnt = 1;
for t=1:896
    myFile = ['C:\Users\Ashkan\Documents\MATLAB\GenderRecognition\TIMIT\TIMIT_TestM\testMale (' int2str(t) ').wav'];
    [testMaleSounds{t}, Fs] = audioread(myFile);
    maleFeature(t,1) = pitch(testMaleSounds{t}, Fs); %first feature for male : pitch_period
%     maleFeature(t,1) = 1; %male target = +1
    [maleMFCC, deltaMale, deltaDeltaMale] = mfcc(testMaleSounds{t}, Fs, 'WindowLength', ns,'OverlapLength', overlap);
    meanMale = mean(maleMFCC,1);
    temp = meanMale;
    maleFeature(t,2:15) = temp; %14 MFCC coefficient for male
    shortTimeEnergyMale = ShortTimeEnergy(testMaleSounds{t}, ns, ns-overlap);
    maleFeature(t,17) = mean(shortTimeEnergyMale); %short time energy feature for male
    spectralCentroidMale = SpectralCentroid(testMaleSounds{t}, ns, ns-overlap, Fs);
    maleFeature(t,16) = mean(spectralCentroidMale); %spectral centroid feature for male
    labels(cnt) = 1;
    cnt = cnt+1;
end

clear temp;
for t=1:448
    myFile = ['C:\Users\Ashkan\Documents\MATLAB\GenderRecognition\TIMIT\TIMIT_TestF\testFemale (' int2str(t) ').wav'];
    [testFemaleSounds{t}, Fs] = audioread(myFile);
    femaleFeature(t,1) = pitch(testFemaleSounds{t}, Fs); %pitch_period feature for female : 
%     femaleFeature(t,1) = -1; %female target = -1
    [femaleMFCC, deltaFemale, deltaDeltaFemale] = mfcc(testFemaleSounds{t}, Fs, 'WindowLength', ns,'OverlapLength', overlap);
    meanFemale = mean(femaleMFCC,1);
    temp = meanFemale;
    femaleFeature(t,2:15) = temp; %14 MFCC coefficient for female
    shortTimeEnergyFemale = ShortTimeEnergy(testFemaleSounds{t}, ns, ns-overlap);
    femaleFeature(t,17) = mean(shortTimeEnergyFemale); %short time energy feature for female
    spectralCentroidFemale = SpectralCentroid(testFemaleSounds{t}, ns, ns-overlap, Fs);
    femaleFeature(t,16) = mean(spectralCentroidFemale); %spectral centroid feature for female
    labels(cnt) = -1;
    cnt = cnt+1;    

end
clear temp;
testFeatures = [maleFeature; femaleFeature];


predictions = QuadraticSVMModel.predictFcn(testFeatures);
labels = labels';

cnt = 0;
for i=1:length(predictions)
    if labels(i) ~= predictions(i)
        cnt = cnt+1;
    end
end

Accuracy = ((length(predictions) - cnt) / length(predictions)) *100;