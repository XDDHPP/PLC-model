PROGRAM A02//上电数据初始化
VAR
	InS10ms:FB_Clock;//10ms功能块
	InS100ms:FB_Clock;//100ms功能块
	InS1s:FB_Clock;//1s功能块
    INS100msP:R_TRIG;//100ms脉冲沿
	Ins1SP:R_TRIG;//1s脉冲沿
	CutOKP:R_TRIG;//产品OK计数沿
	CutNGP:R_TRIG;//产品OK计数沿
	
END_VAR//

//PLC上电第一次扫描
Sys.xP_Frist:= NOT Sys.xP_On;
//PLC运行常通信号
Sys.xP_On:=TRUE;
//PLC运行常断信号
Sys.xP_Off:=FALSE;

//PLC上电OK信号
Sys.TPlcOk(IN:=1,PT:=T#5S,Q=>Sys.xPlcOk);

//10ms脉冲信号      10/5=2 PLC当前扫描周期5MS
InS10ms(rScanTime:=5 , rFlipTime:=10 , xPulse=>sys.xP_10ms );

//100ms脉冲信号 	100/5=20 PLC当前扫描周期5MS
InS100ms(rScanTime:=5 , rFlipTime:=100 , xPulse=>Sys.xP_100ms );

//1s脉冲信号 		1000/5=200   PLC当前扫描周期5MS
InS1s(rScanTime:=5 , rFlipTime:=1000 , xPulse=>Sys.xP_1s);


//PLC上电时，数据参数初始化处理
IF NOT Sys.xPlcOk  OR NOT sys.State.xAutoEna OR sys.State.xHomeOK  THEN
	Cyl.cmd[1].iAutoCtr:=0;
	Cyl.cmd[2].iAutoCtr:=0;
	Cyl.cmd[3].iAutoCtr:=0;
	Cyl.cmd[4].iAutoCtr:=0;
	Cyl.cmd[5].iAutoCtr:=0;
	Axis.Cmd[1].iAposID:=0;
	Axis.Cmd[2].iAposID:=0;
	Axis.Cmd[3].iAposID:=0;
	Axis.Cmd[4].iAposID:=0;
END_IF;



//设备节拍记录
INS100msP(CLK:=Sys.xP_100ms);
IF SYS.State.xAutoStart AND INS100msP.Q THEN
	sys.Report.iCT:=sys.Report.iCT+1;
END_IF

//节拍清零，设备复位或者自动流程最后一步
//自动流程最后一步替换false
IF SYS.State.xHoming OR FALSE THEN
	sys.Report.iCT:=0;
END_IF


//产品OK NG 计数
CutOKP(CLK:=FALSE);//产品OK沿触发
CutNGP(CLK:=FALSE);//产品NG沿触发
IF CutOKP.Q THEN
	sys.Report.dDayOK:=sys.Report.dDayOK+1;//日良品
	sys.Report.dTotalOK:=sys.Report.dTotalOK+1;//总良品
END_IF;

IF CutNGP.Q THEN
	sys.Report.dDayNG:=sys.Report.dDayNG+1;//日不良品
	sys.Report.dTotalNG:=sys.Report.dTotalNG+1;//总不良品
END_IF;

//日产量
sys.Report.dDayOutput:=sys.Report.dDayOK+sys.Report.dDayNG;
IF sys.xClear THEN //日产量清零
	sys.Report.dDayOK:=0;
	sys.Report.dDayNG:=0;
END_IF

//总产量
sys.Report.dTotalOutput:=sys.Report.dTotalOK+sys.Report.dTotalNG;
IF SYS.xTotClear THEN //总产量清零
	sys.Report.dTotalOK:=0;
	sys.Report.dTotalNG:=0;
END_IF;


//设备自动运转总时间
Ins1SP(CLK:=Sys.xP_1s);
IF Ins1SP.Q AND SYS.State.xAutoStart  THEN
	sys.Report.iSec:=sys.Report.iSec+1;
END_IF;
//满60S进位，分钟加一
IF sys.Report.iSec>=60 THEN
	sys.Report.iMin:=sys.Report.iMin+1;
	sys.Report.iSec:=0;
END_IF;

//满60分进位，小时加一
IF sys.Report.iMin>=60 THEN
	sys.Report.iHour:=sys.Report.iHour+1;
	sys.Report.iMin:=0;
END_IF;

//运行时间清零
IF SYS.xdateClear THEN
	sys.Report.iSec:=0;
	sys.Report.iMin:=0;
	sys.Report.iHour:=0;
END_IF;





END_PROGRAM