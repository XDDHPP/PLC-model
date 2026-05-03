FUNCTION_BLOCK FB_System
VAR_INPUT
	HmiB:ST_button;//触摸屏按钮
	HardB:ST_button;//硬件接线按钮
	xPlcOk:BOOL;//PLC上电OK
	xHomeDone:BOOL;//回原完成
	iCurrentPic:INT;//触摸屏当前页面
	iMode1:INT;//手动时，0设备进入停止，1设备进入暂停
	Warn:ST_Warn;//警告提示汇总
END_VAR
VAR_OUTPUT
	State :ST_SYS ;//系统设备状态
	
END_VAR
VAR_IN_OUT
	ShowPic:ARRAY[0..2] OF INT;//切换画面
END_VAR
VAR
	THalt:TON;//暂停定时器
	TRst:TON;//报警复位定时器
	TT:TON;//切换画面变量延时清零
	SysB:ST_button;//系统按钮
	xHomePage:BOOL;//触摸屏主页
	Tpage:TON;//主页延时输出
	
	xIdle:BOOL;//设备待机中
	xManulEna:BOOL;//手动允许
	xAlming:BOOL;//报警中
	xHoming:BOOL;//设备回原中
	xHomeOK:BOOL;//回原OK标记
	
	xAutoEna:BOOL;//自动状态
	xAutoStart:BOOL;//自动运行中
	xAutoHalt:BOOL;//自动暂停中
	xAutoLock:BOOL;//自动锁机
	//手自动状态不一致，禁止自动
END_VAR


xAutoLock:=Warn.iSwitch<>0;//设备锁机
xAlming:=Warn.ialming<>0;//设备报警中
//设备在停机中
xIdle:=SysB.xEstop AND NOT xAlming AND NOT xManulEna AND NOT xHoming AND NOT xAutoStart;

//ACT1 触摸屏按钮和硬件按钮汇总
//急停按钮汇总，硬件按钮和触摸屏按钮
SysB.xEstop:=HardB.xEstop AND NOT HmiB.xEstop;



//启动按钮汇总,硬件按钮和触摸屏按钮，只要触发一个就有信号
  SysB.xStart:= HardB.xStart OR HmiB.xStart;
  
 //停止按钮汇总，
  SysB.xStop:=HardB.xStop AND NOT HmiB.xStop AND NOT THalt.Q; 
  
 // 暂停按钮汇总 ，硬件按钮和触摸屏按钮同时接通
 SysB.xHalt:=HardB.xHalt AND NOT HmiB.xHalt;
 
 //暂停按钮长按3S, 也可作为停止按钮使用
 THalt(IN:= NOT HardB.xHalt  OR HmiB.xHalt,PT:=T#3S);
 
  
  //报警复位按钮汇总
  SysB.xAlmRst:=HardB.xAlmRst OR HmiB.xAlmRst;
  
  //报警复位按钮长按3s，也可以作为系统复位按钮使用
  TRst(IN:=HardB.xAlmRst OR HmiB.xAlmRst,PT:=T#3S);
  
  //系统复位按钮汇总
  SysB.xSysRst:=HardB.xSysRst OR HmiB.xSysRst OR TRst.Q;
  
  //参数设置按钮
  SysB.xPar:=HmiB.xPar;//只是有触摸屏按钮
  //手动画面切换按钮
  SysB.xManulTp:=HmiB.xManulTp;//只是有触摸屏按钮
  
//ACT2，手动运行允许以及画面切换
	




//手动允许操作信号
IF sysB.xEstop AND NOT xHomePage THEN 
	IF xIdle AND sysB.xManulTp THEN 
		xManulEna:=TRUE;//手动状态
	END_IF
ELSE
 xManulEna:=FALSE;//手动状态
END_IF
			
// 手动画面切换
IF xManulEna AND SysB.xManulTp THEN
	ShowPic[0]:=40;//第四十画面是手动控制
END_IF;

//触摸屏进入主页判断
Tpage(IN:=iCurrentPic=10,PT:=T#0.5S);
xHomePage:=Tpage.IN AND NOT Tpage.Q;





//触摸屏当前画面 传动PLC

//设备报警实时画面
IF SysB.xEstop AND xAlming THEN
	ShowPic[0]:=150;//第150画面，实时报警
END_IF

//拍下急停报警画面
IF NOT SysB.xEstop THEN
	ShowPic[0]:=151;//第151画面，急停报警
END_IF;

//设备复位回原画面切换
IF xHoming AND SysB.xSysRst THEN
	ShowPic[0]:=30;//第30页，设备初始化界面
END_IF;

//设备复位回原OK后，回到主页
IF xHomeDone THEN
	ShowPic[0]:=10;//第10页，主页面
END_IF;

//设备自动运转时，切换画面
IF (xAutoEna OR xAutoStart ) AND SysB.xStart AND NOT xAlming  THEN
	ShowPic[0]:=20;//
END_IF;

//参数设置切换画面
IF HmiB.xpar AND NOT xAutoStart THEN
	ShowPic[0]:=100;//
END_IF;

//威纶通触摸屏BUG，切换变量不清零，
//造成画面切换失败，利用延时清零
TT(IN:=ShowPic[0]<>0,PT:=T#1S);
IF TT.Q THEN 
	ShowPic[0]:=0;
END_IF;



//ACT3，设备初始化的运作条件
	//设备允许回原点初始化的逻辑条件
// 设备也没报警，也没急停，停止，当设备待机中 才可以复位
IF  SysB.xEstop   AND SysB.xStop  AND NOT  xAlming THEN//按钮正常  	
			IF SysB.xSysRst AND xIdle THEN//按下复位按钮
				xHoming:=TRUE;//设备进入初始中
			END_IF;	  	
  ELSE
  xHoming:=FALSE;//设备初始化停止	
END_IF
	   			   			   
//设备回原OK标记，置位
IF xHomeDone THEN 
	xHomeOK:=TRUE;
	xHoming:=FALSE;
END_IF;

 //设备回原OK标记信号复位，
//拍下急停，手动，自动，或者重新复位	   
 IF   NOT SysB.xEstop OR xManulEna OR xAutoStart 
      OR (SysB.xSysRst AND  xHoming)      THEN
	 xHomeOK:=FALSE;//设备初始化OK信号复位
 END_IF;
 
 

//ACT4，设备自动运转条件
	
//设备进入自动状态	  //Imode>0 手自动随意切换
IF SysB.xEstop AND Sysb.xStop AND  (NOT xManulEna OR iMode1>0 )  THEN //急停和停止正常 设备在待机中
	 
	 IF xHomeOK AND xIdle AND SysB.xStart  THEN//设备回原OK，并且打到自动
		 xAutoEna:=TRUE; //设备进入自动状态
      END_IF;
	  
 ELSE //急停或者停止不正常，自动状态停止
 	 xAutoEna:=FALSE;	
END_IF;
//设备在自动暂停时，不处于待机状态时
IF xAutoHalt AND NOT xIdle  AND NOT xAlming  THEN 
	 xAutoEna:=FALSE;	
END_IF

	
//设备自动运行
 IF NOT SysB.xHalt OR  xAlming THEN 
	 xAutoStart:=FALSE;	//设备自动运行停止
 END_IF;
 
IF  xAutoEna AND NOT xAutoLock  AND NOT xManulEna  THEN //设备进入自动状态并且手自动状态一致
          
	 IF SysB.xStart THEN //按下启动
		 xAutoStart:=TRUE;	//设备自动运行
     END_IF;
			
ELSE//
 	  xAutoStart:=FALSE;	//设备自动运行停止 
  END_IF;	
		 
//设备自动暂停中
xAutoHalt:=xAutoEna AND NOT xAutoStart;	

//ACT5，设备状态结构体封装
//通过结构体封装打包 设备系统状态 
State.xPlcOk:=xPlcOk;//PLC上电OK
State.xEStop:=sysb.xEstop;//急停
State.xStop:=sysb.xStop;//停止按钮
State.xHalt:=sysb.xHalt;//暂停按钮
State.xStart:=sysb.xStart;//启动按钮
State.xAlmRst:=sysb.xAlmRst;//报警复位
State.xSysRst:=sysb.xSysRst;//系统复位
State.xIdle:=xIdle;//设备在待机中
State.xManulEna:=xManulEna;//手动允许
State.xAlming:=xAlming;//报警中
State.xHoming:=xHoming;//设备回原中
State.xHomeDone:=xHomeDone;//设备回原完成
State.xHomeOK:=xHomeOK;//设备回原OK标记
State.xAutoEna:=xAutoEna;//自动状态
State.xAutoStart:=xAutoStart;//自动运行
State.xAutoHalt:=xAutoHalt;//自动暂停
State.xAutoLock:=xAutoLock;//手自动状态不一致

END_FUNCTION_BLOCK