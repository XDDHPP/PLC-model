PROGRAM A03
VAR
	FBSystem:FB_System;//系统状态
	i:INT;
	j:INT;
END_VAR

		
//设备报警字
Sys.Warn.ialming:=0;
FOR i:=0 TO 499 BY 1 DO
	IF almtip.alm[i] THEN
		Sys.Warn.ialming:=i+1;
	END_IF;
END_FOR;
//手自动状态不一致
Sys.Warn.iSwitch:=0;
FOR j:=0 TO 499 BY 1 DO
	IF almtip.Automanul[j] THEN
		Sys.Warn.iSwitch:=j+1;
	END_IF;
END_FOR;

//硬件按钮信号映射
Sys.HardB.xEstop:=TRUE OR INX.T0[0].Q;//急停按钮
Sys.HardB.xStart:=INX.T0[2].Q;//启动按钮
Sys.HardB.xStop:=TRUE OR INX.T0[3].Q;//停止按钮
Sys.HardB.xHalt:=TRUE OR INX.T0[4].Q;//暂停按钮
Sys.HardB.xAlmRst:=INX.T0[5].Q;//报警解除
Sys.HardB.xSysRst:=INX.T0[6].Q;//系统复位

FBSystem(
	HmiB:= Sys.HmiB , //触摸屏按钮 
	HardB:=Sys.HardB , //硬件按钮 
	xPlcOk:=Sys.xPlcOk , //PLC上电OK
	xHomeDone:=SYS.xHomeDone,//设备回原完成
	iCurrentPic:=sys.CurrentPic,//触摸屏当前画面
	iMode1:=0 , //在自动下调试手动，0设备进入停止，1设备进入暂停
	Warn:=Sys.Warn,//警示字
	State=>Sys.State , //系统当前状态
	ShowPic:=sys.ShowPic );//切换触摸屏画面

//手动允许状态灯	
SYS.Tip.A1:=Sys.State.xManulEna	AND SYS.xP_1s;
//设备允许自动运行状态灯
Sys.Tip.A2 :=((Sys.State.xAutoEna OR Sys.State.xHomeOK) AND SYS.xP_1s )
			 OR Sys.State.xAutoStart  ;
//黄灯
Sys.Tip.A3:=Sys.State.xHoming OR (Sys.State.xManulEna AND NOT Sys.State.xAlming AND sys.xP_1s);
//绿灯
Sys.Tip.A4:=Sys.State.xAutoStart OR (Sys.State.xAutoHalt AND NOT Sys.State.xAlming AND sys.xP_1s );
//红灯
Sys.Tip.A5:=Sys.State.xAlming AND sys.xP_1s;
//蜂鸣器			 
Sys.Tip.A6:=Sys.State.xAlming AND sys.xP_1s;		 
			 


END_PROGRAM