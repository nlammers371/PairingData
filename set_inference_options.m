% Script to call primary cpHMM wrapper function

clear
close all
warning('off','all') %Shut off Warnings
addpath(genpath('utilities'))

inferenceInfo = struct;

% set project identifiers (only applicable if running this on savio)
inferenceInfo.projectNameCell = {'pairing_project'}; % {'2xDl-Ven_hbP2P-mCh'};

% set inference options
inferenceInfo.ProteinBinFlag = 0;
inferenceInfo.FluoBinFlag = 0;
inferenceInfo.timeBins = {[0 60*60]}; % should be >= than 15min
inferenceInfo.apBins = [];%linspace(-.2,.2,10);
inferenceInfo.Tres = 30;

% set core model specs
inferenceInfo.modelSpecs.nStates = 3; % number of states in system
inferenceInfo.modelSpecs.nSteps = 6; % number of steps to traverse gene
inferenceInfo.modelSpecs.alphaFrac =  1302/6444;%1275 / 4670;%

% other info
inferenceInfo.AdditionalGroupingVariable = 'ch';%'Stripe'
inferenceInfo.SampleSize = 3000;
inferenceInfo.useQCFlag = true;
inferenceInfo.n_localEM = 25;

% Get basic project info and determing file paths
% liveProject = LiveEnrichmentProject(inferenceInfo.projectNameCell{1});

% save
% slashes = regexp(liveProject.dataPath,'/|\');
% dataDir = liveProject.dataPath(1:slashes(end-1));
inferenceDir = './out/inferenceDirectory/';
mkdir(inferenceDir)
save([inferenceDir 'inferenceInfo.mat'],'inferenceInfo')