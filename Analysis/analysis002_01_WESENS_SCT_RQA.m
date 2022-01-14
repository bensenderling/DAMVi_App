function results = analysis002_01_WESENS_SCT_RQA(data)

%%

x_RFoot = data.Lumbar.data.acc(:,1);
y_Lumbar = data.Lumbar.data.acc(:,2);
z_Lumbar = data.Lumbar.data.acc(:,3);
freq = data.Lumbar.freq;

[tau_x_Lumbar,AMI_x_Lumbar] =AMI_Thomas(x_RFoot, freq/2);
[tau_y_Lumbar,AMI_y_Lumbar] = AMI_Thomas(y_Lumbar, freq/2);
[tau_z_Lumbar,AMI_z_Lumbar] = AMI_Thomas(z_Lumbar, freq/2);

MaxDim = 12;
Rtol = 15;
Atol = 2;
speed = 0;
[dim_x_Lumbar, dE_x_Lumbar] = FNN(x_RFoot,tau_x_Lumbar(1),MaxDim,Rtol,Atol,speed);
[dim_y_Lumbar, dE_y_Lumbar] = FNN(y_Lumbar,tau_y_Lumbar(1),MaxDim,Rtol,Atol,speed);
[dim_z_Lumbar, dE_z_Lumbar] = FNN(z_Lumbar,tau_z_Lumbar(1),MaxDim,Rtol,Atol,speed);


TYPE = 'RQA';
ZSCORE = 1;
NORM = 'EUC';
SETPARA = 'recurrence';
SETVALUE = 2.5;
plotOption = 1;

[RP_x_Lumbar, RESULTS_x_Lumbar] = RQA(x_RFoot,TYPE,tau_x_Lumbar(1),dim_x_Lumbar,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_y_Lumbar, RESULTS_y_Lumbar] = RQA(y_Lumbar,TYPE,tau_y_Lumbar(1),dim_y_Lumbar,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_z_Lumbar, RESULTS_z_Lumbar] = RQA(z_Lumbar,TYPE,tau_z_Lumbar(1),dim_z_Lumbar,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);

results.segment1{1,1} = 'Lumbar';
results.component{1,1} = 'x';
results.tau{1,1} = tau_x_Lumbar;
results.tau_v2{1,1} = AMI_x_Lumbar;
results.maxdim{1,1} = MaxDim;
results.rtol{1,1} = Rtol;
results.atol{1,1} = Atol;
results.speed{1,1} = speed;
results.dim{1,1} = dim_x_Lumbar;
results.dim_v{1,1} = dE_x_Lumbar;
results.type{1,1} = TYPE;
results.zscore{1,1} = ZSCORE;
results.norm{1,1} = NORM;
results.setpara{1,1} = SETPARA;
results.setvalue{1,1} = SETVALUE;
results.recurrancePlot{1,1} = RP_x_Lumbar;
results.recurranceResults{1,1} = RESULTS_x_Lumbar;

%%

x_RFoot = data.Right_Foot.data.acc(:,1);
y_RFoot = data.Right_Foot.data.acc(:,2);
z_RFoot = data.Right_Foot.data.acc(:,3);

[tau_x_RFoot,AMI_x_RFoot] =AMI_Thomas(x_RFoot, 30);
[tau_y_RFoot,AMI_y_RFoot] = AMI_Thomas(y_RFoot, 30);
[tau_z_RFoot,AMI_z_RFoot] = AMI_Thomas(z_RFoot, 30);

MaxDim = 12;
Rtol = 15;
Atol = 2;
speed = 0;
[dim_x_RFoot, dE_x_RFoot] = FNN(x_RFoot,tau_x_RFoot(1),MaxDim,Rtol,Atol,speed);
[dim_y_RFoot, dE_y_RFoot] = FNN(y_RFoot,tau_y_RFoot(1),MaxDim,Rtol,Atol,speed);
[dim_z_RFoot, dE_z_RFoot] = FNN(z_RFoot,tau_z_RFoot(1),MaxDim,Rtol,Atol,speed);

TYPE = 'RQA';
ZSCORE = 1;
NORM = 'EUC';
SETPARA = 'recurrence';
SETVALUE = 2.5;
plotOption = 1;

[RP_x_RFoot, RESULTS_x_RFoot] = RQA(x_RFoot,TYPE,tau_x_RFoot(1),dim_x_RFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_y_RFoot, RESULTS_y_RFoot] = RQA(y_RFoot,TYPE,tau_y_RFoot(1),dim_y_RFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_z_RFoot, RESULTS_z_RFoot] = RQA(z_RFoot,TYPE,tau_z_RFoot(1),dim_z_RFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);

%%

x_LFoot = data.Left_Foot.data.acc(:,1);
y_LFoot = data.Left_Foot.data.acc(:,2);
z_LFoot = data.Left_Foot.data.acc(:,3);

[tau_x_LFoot,AMI_x_LFoot] =AMI_Thomas(x_LFoot, 30);
[tau_y_LFoot,AMI_y_LFoot] = AMI_Thomas(y_LFoot, 30);
[tau_z_LFoot,AMI_z_LFoot] = AMI_Thomas(z_LFoot, 30);

MaxDim = 12;
Rtol = 15;
Atol = 2;
speed = 0;
[dim_x_LFoot, dE_x_LFoot] = FNN(x_LFoot,tau_x_LFoot(1),MaxDim,Rtol,Atol,speed);
[dim_y_LFoot, dE_y_LFoot] = FNN(y_LFoot,tau_y_LFoot(1),MaxDim,Rtol,Atol,speed);
[dim_z_LFoot, dE_z_LFoot] = FNN(z_LFoot,tau_z_LFoot(1),MaxDim,Rtol,Atol,speed);


TYPE = 'RQA';
ZSCORE = 1;
NORM = 'EUC';
SETPARA = 'recurrence';
SETVALUE = 2.5;
plotOption = 1;

[RP_x_LFoot, RESULTS_x_LFoot] = RQA(x_LFoot,TYPE,tau_x_LFoot(1),dim_x_LFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_y_LFoot, RESULTS_y_LFoot] = RQA(y_LFoot,TYPE,tau_y_LFoot(1),dim_y_LFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);
[RP_z_LFoot, RESULTS_z_LFoot] = RQA(z_LFoot,TYPE,tau_z_LFoot(1),dim_z_LFoot,ZSCORE,NORM,SETPARA,SETVALUE,plotOption);












