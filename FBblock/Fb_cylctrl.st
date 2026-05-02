FUNCTION_BLOCK Fb_cylctrl//气缸控制功能块
VAR_INPUT
	State :ST_SYS ;//系统设备状态
	CylRdy:ST_CylRdy;//气缸自动控制与安全信号
	TTimer:TIME;//报警时间设定
	iMode:INT;//1 报警不断气，2 暂停断气 3. 仅急停断
	HmiCYL:ST_CylHMI;//气缸手动控制
END_VAR
VAR_IN_OUT
	AutoCyl:ST_CylAuto;//气缸自动控制信号
	CylTip:ST_CYLTiP;//气缸反馈信号
END_VAR
VAR
	iManulCtr:INT;//气缸手动控制字
	iTotCtr:INT;//控制字汇总，手动/自动
	VxHomeOut:BOOL;//气缸回原位输出中转
	VxWorkOut:BOOL;//气缸到工位输出中转
	Vxbool:BOOL;//气缸上传感器全亮或者 全灭
	THomeAlm:TON;//气缸原位报警定时器
	TWorkAlm:TON;//气缸工位报警定时器
	VAutoLock:BOOL;// 自动锁机
END_VAR

//PLC上电，数据初始化
IF NOT State.xPlcOk THEN
	iManulCtr:=0;//气缸手动控制字
	iTotCtr:=0;//气缸控制字汇总
	AutoCyl.iAutoCtr:=0;//气缸自动控制字
	AutoCyl.xAutoctr:=FALSE;//自动启动复位
END_IF;
//设备初始化复位时，手动控制数值初始化
IF State.xHoming OR State.xHomeOK THEN
	  iManulCtr:=AutoCyl.iAutoCtr;//气缸手动控制字
	  VAutoLock:=FALSE;//自动锁机复位
END_IF;


//******气缸手动控制 气缸手动控制 气缸手动控制********//////
IF State.xManulEna   THEN //手动允许下
	//气缸手动回原位控制
	 IF HmiCYL.xHomeTp AND  CylRdy.xHomeSafe AND  NOT HmiCYL.xWorkTp THEN
		 iManulCtr:=1;//气缸手动控制字
		 iTotCtr:= iManulCtr;//手动字赋值控制字汇总
	 END_IF;
	 
	 //气缸手动到工位控制
	IF HmiCYL.xWorkTp AND CylRdy.xWorkSafe AND NOT HmiCYL.xHomeTp THEN
		 iManulCtr:=2;//气缸手动控制字
		 iTotCtr:= iManulCtr;
	END_IF;
		
END_IF;
// ******气缸手动控制 气缸手动控制 气缸手动控制********///

//气缸自动控制 控制 
//气缸复位回原点
 IF State.xHoming AND CylRdy.xHomeSafe THEN
     IF AutoCyl.iAutoCtr=1 AND AutoCyl.xAutoctr  THEN
	   iTotCtr:=1;//气缸复位回原位
	 END_IF;  
 END_IF;

//气缸自动控制 
IF State.xAutoStart THEN //设备自动运行时
	//气缸自动回原位
  	IF   CylRdy.xHomeSafe AND AutoCyl.xAutoCtr AND AutoCyl.iAutoCtr=1 THEN
		 iTotCtr:=1;
  	END_IF;
	//气缸自动工位
	IF  CylRdy.xWorkSafe AND AutoCyl.xAutoCtr AND AutoCyl.iAutoCtr=2 THEN
		iTotCtr:=2;
	END_IF
END_IF;  

//气缸自动信号复位
IF NOT State.xManulEna THEN 
	IF CylTip.xHomePos AND iTotCtr=1 THEN 
	    AutoCyl.xAutoCtr:=FALSE;
	END_IF;
	IF CylTip.xWorkPos AND iTotCtr=2 THEN 
	    AutoCyl.xAutoCtr:=FALSE;
	END_IF;
END_IF;

IF NOT State.xAutoEna  THEN
 
	IF NOT State.xHoming THEN 
		AutoCyl.xAutoCtr:=FALSE;
	END_IF;
	
 ELSE 
  
   IF NOT State.xAutoStart THEN 
	   AutoCyl.xAutoCtr:=FALSE;
   END_IF	
END_IF;






//气缸暂停控制 
CASE iMode OF
	1://只是拍下急停，断气
		IF NOT State.xEstop THEN
		 iTotCtr:=0;
		END_IF
	
	2://故障时或者按下暂停，断气暂停
	IF  State.xAlming OR NOT  State.xHalt THEN
		 iTotCtr:=0;
	END_IF
	
	3://故障时,气缸不断气
     ;//气缸保持之前的状态

END_CASE

//气缸在运行中,安全信号丢失
IF  State.xManulEna   THEN //手动允许下
 //气缸手动控制时，遇到碰到风险时
	IF (iTotCtr=1 AND NOT CylRdy.xHomeSafe) OR
       (iTotCtr=2 AND  NOT CylRdy.xWorkSafe) THEN
		 iManulCtr:=0;//气缸手动控制字
		 iTotCtr:= iManulCtr;
	END_IF;	 
END_IF;	
//设备在初始化或者自动时
IF (State.xHoming OR State.xAutoStart) AND AutoCyl.xAutoCtr  THEN 
	IF (iTotCtr=1 AND NOT CylRdy.xHomeSafe) OR
       (iTotCtr=2 AND  NOT CylRdy.xWorkSafe) THEN
		 iManulCtr:=0;//气缸手动控制字
		 iTotCtr:= iManulCtr;
	END_IF;	 
END_IF;


//气缸电磁阀输出控制

VxHomeOut := (iTotCtr=1);//气缸原位输出中转
CylTip.xHomeOut:=VxHomeOut;//气缸原位输出
VxWorkOut:=  (iTotCtr=2);//气缸工位输出中转
CylTip.xWorkOut:=VxWorkOut; //气缸工位输出

//气缸提示信号

//VXBOOL.气缸信号全亮或者全灭
Vxbool:= (CylRdy.xHomeSensor AND CylRdy.xWorkSensor) 
		OR (NOT CylRdy.xHomeSensor AND NOT CylRdy.xWorkSensor) ;

//气缸到位信号
CylTip.xHomePos:= VxHomeOut AND CylRdy.xHomeSensor AND NOT Vxbool;
CylTip.xWorkPos:= VxWorkOut AND CylRdy.xWorkSensor AND NOT Vxbool;


//气缸回原位超时报警
 THomeAlm(IN:= VxHomeOut AND (NOT CylRdy.xHomeSensor OR Vxbool)  , PT:=TTimer  );
  IF THomeAlm.Q THEN
	  CylTip.xHomeAlm:=TRUE;
  END_IF
 
//气缸到工位超时报警
TWorkAlm(IN:=VxWorkOut AND( NOT CylRdy.xWorkSensor OR Vxbool ), PT:=TTimer  );
IF TWorkAlm.Q THEN
	CylTip.xWorkAlm:=TRUE;
END_IF
//报警解除
IF State.xAlmRst THEN
	CylTip.xHomeAlm:=FALSE;
	CylTip.xWorkAlm:=FALSE;
END_IF


// 气缸自动且手动，再切自动，继续跑自动，安全提示
//自动锁机信号处理
IF State.xManulEna  THEN //手动模式下
	 IF  iManulCtr =  AutoCyl.iAutoCtr THEN //手自动状态不一致
		  VAutoLock := FALSE; // 当前状态与期望状态一致，解锁自动运行
		 CYLTiP.xHomeTip:=FALSE ;//气缸不在原位,无法启动
	 	 CYLTiP.xWorkTip:= FALSE ;//气缸不在工位,无法启动
	ELSE
		VAutoLock := TRUE; // 当前状态与期望状态不一致，锁定自动运行;
	END_IF	;
END_IF;


IF State.xAutoEna AND NOT State.xManulEna THEN //自动状态下
	IF VAutoLock THEN //自动状态锁机
		CylTip.xHomeTip:=AutoCyl.iAutoCtr=1;//提示气缸手动移到原位
	    CylTip.xWorkTip:=AutoCyl.iAutoCtr=2;//提示气缸手动移到工位
	ELSE
	iManulCtr :=AutoCyl.iAutoCtr;	//设备未锁机时,实时更新数据	
	END_IF;	
END_IF;



END_FUNCTION_BLOCK