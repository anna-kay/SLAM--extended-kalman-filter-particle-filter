%----------------------Question 2 - Particle Filter-------------------------
clear;
clc;
run('question1.m');
rng(1234);

% sampling frequency = 10Hz
dt = 0.1;

% Define Obstacles positions
A = CorrectedState(4:5,100);
B = CorrectedState(6:7,100);

% Defintion of the Particle Filter & necessary functions
myPF = particleFilter(@myVehicleStateTranstionFcn, @myLikelihoodMeasurementFcn);

% Initialization of the Particle Filter
initialize(myPF, 1000, [0, 0, 0], zeros(3,3), 'CircularVariables', [0 0 1], 'StateOrientation', 'row'); 

myPF.ResamplingPolicy.MinEffectiveParticleRatio = 0.75;

% Particle Filter Parameters
myPF.StateEstimationMethod = 'mean';  % (maxweight, mean)
myPF.ResamplingMethod = 'stratified'; %('multinomial', 'stratified', 'systematic')

% Resampling Policy Parameters

% myPF.ResamplingPolicy.TriggerMethod = 'ratio';
% myPF.ResamplingPolicy.TriggerMethod = 'interval';
% myPF.ResamplingPolicy.SamplingInterval = 1; % Applied only when
% TriggerMethod = 'intreval'

control = csvread('datasets/control1.csv');
radar = csvread('datasets/radar1.csv');
radar(:,2) = wrapToPi(radar(:,2));
radar(:,4) = wrapToPi(radar(:,4));

PredictedStatePF = zeros(3,100);
PredictedStateCovariancePF = zeros(3,3,100);
CorrectedStatePF = zeros(3,100);
CorrectedStateCovariancePF = zeros(3,3,100);

% Prediction and Correction 
for k=1:length(control)
    [PredictedStatePF(:,k), PredictedStateCovariancePF(:,:,k)] = predict(myPF, dt ,control(k,:));
    [CorrectedStatePF(:,k), CorrectedStateCovariancePF(:,:,k)] = correct(myPF, radar(k,:), A, B);
    
    % ----------------------- Resampling --------------------------
    % Resampling of particles is required to update your estimation as the state changes in subsequent iterations. 
    % This step triggers resampling based on the ResamplingMethod and ResamplingPolicy properties.
    % Resample particles: This step is not separately called, but is executed when you call correct. 
end

figure(2)
plot(PredictedStatePF(1,:),PredictedStatePF(2,:), CorrectedStatePF(1,:),CorrectedStatePF(2,:))
hold on
plot(A(1),A(2), 'x')
hold on
plot(B(1),B(2), 'ro')
legend('Predicted', 'Corrected', 'Obstacle1', 'Obstacle2')
grid on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';