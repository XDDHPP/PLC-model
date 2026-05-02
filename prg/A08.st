PROGRAM A08
VAR
	FbAxis:ARRAY[0..31] OF FB_AxisCtrl;//轴功能块

END_VAR

//X轴控制准备信号  1#轴
Axis.Cmd[1].EnaSafe.xActSafe:=TRUE;//允许定位安全信号
Axis.Cmd[1].EnaSafe.xAXread:=TRUE;//伺服通讯/就绪OK
Axis.Cmd[1].EnaSafe.xJogNsafe:=TRUE;//伺服点动正安全允许信号
Axis.Cmd[1].EnaSafe.xJogPsafe:=TRUE;//伺服点动负安全允许信号
Axis.Cmd[1].EnaSafe.xHaltSelect:=FALSE;//设备暂停，伺服是否停机


//Y轴控制准备信号 2#轴
Axis.Cmd[2].EnaSafe.xActSafe:=TRUE;//允许定位安全信号
Axis.Cmd[2].EnaSafe.xAXread:=TRUE;//伺服通讯/就绪OK
Axis.Cmd[2].EnaSafe.xJogNsafe:=TRUE;//伺服点动正安全允许信号
Axis.Cmd[2].EnaSafe.xJogPsafe:=TRUE;//伺服点动负安全允许信号
Axis.Cmd[2].EnaSafe.xHaltSelect:=FALSE;//设备暂停，伺服是否停机


//Z轴控制准备信号 3#轴
Axis.Cmd[3].EnaSafe.xActSafe:=TRUE;//允许定位安全信号
Axis.Cmd[3].EnaSafe.xAXread:=TRUE;//伺服通讯/就绪OK
Axis.Cmd[3].EnaSafe.xJogNsafe:=TRUE;//伺服点动正安全允许信号
Axis.Cmd[3].EnaSafe.xJogPsafe:=TRUE;//伺服点动负安全允许信号
Axis.Cmd[3].EnaSafe.xHaltSelect:=FALSE;//设备暂停，伺服是否停机


//	R轴控制准备信号 4#轴
Axis.Cmd[4].EnaSafe.xActSafe:=TRUE;//允许定位安全信号
Axis.Cmd[4].EnaSafe.xAXread:=TRUE;//伺服通讯/就绪OK
Axis.Cmd[4].EnaSafe.xJogNsafe:=TRUE;//伺服点动正安全允许信号
Axis.Cmd[4].EnaSafe.xJogPsafe:=TRUE;//伺服点动负安全允许信号
Axis.Cmd[4].EnaSafe.xHaltSelect:=FALSE;//设备暂停，伺服是否停机




//正常情况1#点位调用1#位置
//2#点位调用2$位置，

//当前点位编号需要计算时，偏移位置
//X轴定位位置，特殊点位换算
CASE Tip.AXOUT[1].iposID OF 
  10://10#位置需要特殊换算
     	GRCP.LibRcp[GRCP.PvNo].AX[1].aPOS[10]:=GRCP.LibRcp[GRCP.PvNo].AX[1].aPOS[6]+
							GRCP.LibRcp[GRCP.PvNo].AX[1].aPOS[8];
END_CASE



//X轴功能块调用
FbAxis[1](State:=Sys.State,//设备状态
	AxisName:=AXISX,//指定轴
	AxisIn:=Axis.Cmd[1],//轴控制输入信号
	Axhand:=HMI.Axis[1],//伺服手动控制
	AxisData:=GRCP.LibRcp[GRCP.PvNo].AX[1],//配方库，调用，示教轴定位数据
    AxisOut=>Tip.AXOUT[1]);//轴控反馈信号,放在触摸上
	
//Y轴功能块调用	
FbAxis[2](State:=Sys.State,//设备状态
	AxisName:=AXISY,//指定轴
	AxisIn:=Axis.Cmd[2],//轴控制输入信号
	Axhand:=HMI.Axis[2],//伺服手动控制
	AxisData:=GRCP.LibRcp[GRCP.PvNo].AX[2],//配方库，调用，示教轴定位数据
    AxisOut=>Tip.AXOUT[2]);//轴控反馈信号,放在触摸上
	
	
//Z轴功能块调用
FbAxis[3](State:=Sys.State,//设备状态
	AxisName:=AXISZ,//指定轴
	AxisIn:=Axis.Cmd[3],//轴控制输入信号
	Axhand:=HMI.Axis[3],//伺服手动控制
	AxisData:=GRCP.LibRcp[GRCP.PvNo].AX[3],//配方库，调用，示教轴定位数据
    AxisOut=>Tip.AXOUT[3]);//轴控反馈信号,放在触摸上
	
//R轴功能块调用
FbAxis[4](State:=Sys.State,//设备状态
	AxisName:=AXISR,//指定轴
	AxisIn:=Axis.Cmd[4],//轴控制输入信号
	Axhand:=HMI.Axis[4],//伺服手动控制
	AxisData:=GRCP.LibRcp[GRCP.PvNo].AX[4],//配方库，调用，示教轴定位数据
    AxisOut=>Tip.AXOUT[4]);//轴控反馈信号,放在触摸上
	
	
	



END_PROGRAM	