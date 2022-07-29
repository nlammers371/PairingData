clear
close all

% load data
load('./dat/CompiledParticlesPlusGP256.mat')
et(1) = load('./dat/ElapsedTimeGP2.mat');
et(2) = load('./dat/ElapsedTimeGP5.mat');
et(3) = load('./dat/ElapsedTimeGP6.mat');

mkdir('./out');

% generate data structure with interpolated traces
tresInterp = 30; % upsample slightly to get to 30 seconds
maxTime = ceil(max([et(1).ElapsedTime et(2).ElapsedTime et(3).ElapsedTime]*60)/tresInterp)*tresInterp;
et_vec = [2 5 6];
timeGrid = 0:tresInterp:maxTime;

spot_struct = struct;

iter = 1;
for i = 1:length(CompiledParticlesPlusGP256{1})
    for ch = 1:2
        % basic metadata
        setID = str2num(CompiledParticlesPlusGP256{ch}(i).Prefix(end));
        spot_struct(iter).setID = setID;        
        op = CompiledParticlesPlusGP256{ch}(i).OriginalParticle;
        spot_struct(iter).OriginalParticle = op;
        spot_struct(iter).particleID = eval([num2str(setID) '.' sprintf('%04d',op)]);
        Nucleus = CompiledParticlesPlusGP256{ch}(i).Nucleus;
        spot_struct(iter).Nucleus = Nucleus;
        spot_struct(iter).ncID = eval([num2str(setID) '.' sprintf('%04d',Nucleus)]);
        spot_struct(iter).ch = ch;
        spot_struct(iter).cpGroup = (ch-1)*2 + CompiledParticlesPlusGP256{ch}(i).Paired;
        spot_struct(iter).Paired = CompiledParticlesPlusGP256{ch}(i).Paired;
        % raw time and fluo
        et_ft = et_vec==spot_struct(iter).setID;
        spot_struct(iter).frames = CompiledParticlesPlusGP256{ch}(i).Frame;
        spot_struct(iter).time = et(et_ft).ElapsedTime(spot_struct(iter).frames)*60;
        spot_struct(iter).fluo = CompiledParticlesPlusGP256{ch}(i).Fluo;
        % interpolate
        start_i = find(timeGrid<=spot_struct(iter).time(1),1,'last');
        stop_i = find(timeGrid>=spot_struct(iter).time(end),1);
        spot_struct(iter).timeInterp = timeGrid(start_i:stop_i);
        spot_struct(iter).fluoInterp = interp1(spot_struct(iter).time, spot_struct(iter).fluo, spot_struct(iter).timeInterp,'linear','extrap');
        % add dummy variables
        spot_struct(iter).APPosParticleInterp = ones(size(spot_struct(iter).timeInterp));
        spot_struct(iter).TraceQCFlag = 1;
        % increment
        iter = iter + 1;
    end
end    

% calculate a cross-calibration factor
ch1_fluo_vec = [spot_struct(1:2:end).fluo];
ch2_fluo_vec = [spot_struct(2:2:end).fluo];
cc_factor = mean(ch2_fluo_vec) / mean(ch1_fluo_vec);
for i = 1:length(spot_struct)
    spot_struct(i).fluoInterpOrig = spot_struct(i).fluoInterp;
    if mod(i,2)==1
        spot_struct(i).fluoInterp = spot_struct(i).fluoInterp*cc_factor;
    end
end

% save
save('./out/spot_struct.mat','spot_struct')