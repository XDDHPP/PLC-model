PROGRAM A07
VAR
	FbCyl:ARRAY[0..50] OF Fb_cylctrl;//气缸功能块实例化
	
	
END_VAR

//左升降准备信号
FbCyl[1].CylRdy.xHomeSensor:=INX.CylHP[1];//气缸原位信号
FbCyl[1].CylRdy.xWorkSensor:=INX.CylWP[1];//气缸工位信号
FbCyl[1].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[1].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号



//右升降缸准备信号
FbCyl[2].CylRdy.xHomeSensor:=INX.CylHP[2];//气缸原位信号
FbCyl[2].CylRdy.xWorkSensor:=INX.CylWP[2];//气缸工位信号
FbCyl[2].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[2].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号


//左升降真空准备信号
FbCyl[3].CylRdy.xHomeSensor:=INX.CylHP[3];//气缸原位信号
FbCyl[3].CylRdy.xWorkSensor:=INX.CylWP[3];//气缸工位信号
FbCyl[3].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[3].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号


//右升降真空准备信号
FbCyl[4].CylRdy.xHomeSensor:=INX.CylHP[4];//气缸原位信号
FbCyl[4].CylRdy.xWorkSensor:=INX.CylWP[4];//气缸工位信号
FbCyl[4].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[4].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号


//移栽左真空准备信号
FbCyl[5].CylRdy.xHomeSensor:=INX.CylHP[5];//气缸原位信号
FbCyl[5].CylRdy.xWorkSensor:=INX.CylWP[5];//气缸工位信号
FbCyl[5].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[5].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号


//移栽右真空准备信号
FbCyl[6].CylRdy.xHomeSensor:=INX.CylHP[6];//气缸原位信号
FbCyl[6].CylRdy.xWorkSensor:=INX.CylWP[6];//气缸工位信号
FbCyl[6].CylRdy.xHomeSafe:=TRUE;//允许气缸回原位安全信号
FbCyl[6].CylRdy.xWorkSafe:=TRUE;//允许气缸到工位安全信号




//升降缸功能块
FbCyl[1](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[1],//气缸手动控制
	AutoCyl:=Cyl.Cmd[1] , 
	CylTip:=TiP.CYLOUT[1]);//气缸状态反馈，四组八个信号

	
//前后缸功能块 //旋转缸
FbCyl[2](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[2],//气缸手动控制
	AutoCyl:=Cyl.Cmd[2] , 
	CylTip:=TiP.CYLOUT[2]);//气缸状态反馈，四组八个信号

//固定缸功能块
FbCyl[3](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[3],//气缸手动控制
	AutoCyl:=Cyl.Cmd[3] , 
	CylTip:=TiP.CYLOUT[3]);//气缸状态反馈，四组八个信号


//真空吸控制
FbCyl[4](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[4],//气缸手动控制
	AutoCyl:=Cyl.Cmd[4] , 
	CylTip:=TiP.CYLOUT[4]);//气缸状态反馈，四组八个信号

	
//搬运缸控制
FbCyl[5](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[5],//气缸手动控制
	AutoCyl:=Cyl.Cmd[5] , 
	CylTip:=TiP.CYLOUT[5]);//气缸状态反馈，四组八个信号

//取料缸控制
FbCyl[6](
	State:=sys.State ,//设备当前状态 
	TTimer:=T#5S , //气缸报警时间
	iMode:=3 , //气缸断气选择(单控/双控)
	HmiCYL:=HMI.Cyl[6],//气缸手动控制
	AutoCyl:=Cyl.Cmd[6] , 
	CylTip:=TiP.CYLOUT[6]);//气缸状态反馈，四组八个信号

	
	
	
//升降缸
//%QX0.0:=CylTiP.CyL[1].xHomeOut;电磁阀控制信号
//%QX0.1:=CylTiP.CyL[1].xWorkOut;电磁阀控制信号

//前后缸
//%QX0.2:=CylTiP.CyL[2].xHomeOut;电磁阀控制信号
//%QX0.3:=CylTiP.CyL[2].xWorkOut;电磁阀控制信号


//固定缸
//%QX0.4:=CylTiP.CyL[3].xHomeOut;电磁阀控制信号
//%QX0.5:=CylTiP.CyL[3].xWorkOut;电磁阀控制信号


//真空吸
//%QX0.4:=CylTiP.CyL[4].xHomeOut;电磁阀控制信号
//%QX0.5:=CylTiP.CyL[4].xWorkOut;电磁阀控制信号


//搬运缸
//%QX0.4:=CylTiP.CyL[5].xHomeOut;电磁阀控制信号
//%QX0.5:=CylTiP.CyL[5].xWorkOut;电磁阀控制信号



//取料缸
//%QX0.4:=CylTiP.CyL[6].xHomeOut;电磁阀控制信号
//%QX0.5:=CylTiP.CyL[6].xWorkOut;电磁阀控制信号

END_PROGRAM