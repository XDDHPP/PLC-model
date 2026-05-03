FUNCTION_BLOCK Fb_Motor//电机控制功能块
VAR_INPUT
	State :ST_SYS ;//系统设备状态
	MotorRdy:ST_MotorRdy;//电机自动控制与安全信号
	MotorHMI:ST_MotorHMI;//电机手动控制
END_VAR
VAR_IN_OUT
	MotorAuto:ST_MotorCtrl;//电机自动控制与安全信号
END_VAR

VAR_OUTPUT
	MotorTip:ST_MotorTip;//电机反馈信号
END_VAR
VAR
	  vHMI:ST_MotorHMI;//电机手动输出
	  vTip:ST_MotorTip;//电机反馈信号
	  xIdle:BOOL;//电机待机中
	  vHomeOut:BOOL;//电机退
	  vWorkOut:BOOL;//电机进
	  iMove:INT;//电机移动字
END_VAR
//PLC上电,初始化数据
IF NOT State.xPLCOK THEN 
	MotorAuto.xAutoBW:=FALSE;
	MotorAuto.xAutofW:=FALSE;
	iMove:=0;//电机移动字
END_IF;
IF NOT State.xEstop OR NOT State.xStop OR NOT MotorRdy.xMotorRdy THEN 
	MotorAuto.xAutoBW:=FALSE;
	MotorAuto.xAutofW:=FALSE;
	iMove:=0;//电机移动字
	
END_IF;
IF vHomeOut AND NOT MotorRdy.xHomeSafe THEN 
	iMove:=0;//电机移动字
END_IF;

IF vWorkOut AND NOT MotorRdy.xWorkSafe THEN 
	iMove:=0;//电机移动字
END_IF;




//电机待机信号,没有手动操作也没有电机运转
xIdle:=NOT MotorHMI.xHomeTp AND NOT MotorHMI.xOnlineH AND NOT MotorHMI.xOnlineW 
       AND NOT MotorHMI.xWorkTp AND NOT vHomeOut AND NOT vWorkOut;

///*****电机手动运行********///
	
IF State.xManulEna AND  xidle AND MotorRdy.xMotorRdy  THEN 
	 //电机手动点动后退
 	IF MotorRdy.xHomeSafe AND MotorHMI.xHomeTp  THEN
		  iMove:=1;//电机手动点动
	END_IF;
	
	//电机手动点动前进
	IF  MotorRdy.xWorkSafe AND MotorHMI.xWorkTp THEN 
		  iMove:=2;//电机手动点动进	  
	END_IF;
	
END_IF;

IF  NOT MotorHMI.xHomeTp  AND iMove=1  THEN 
	  iMove:=0;//电机移动字
END_IF;

IF  NOT MotorHMI.xWorkTp  AND iMove=2   THEN 
	   iMove:=0;//电机移动字
END_IF;


 IF State.xManulEna AND xidle AND MotorRdy.xMotorRdy  THEN 
	//电机手动联动退
     IF  MotorHMI.xOnlineH AND MotorRdy.xHomeSafe THEN  
		 iMove:=3;//电机手动联动退
		 vTip.xHomePos:=FALSE;//电机退到位
	 END_IF;
	 //电机手动联动进
	IF  MotorHMI.xOnlineW AND MotorRdy.xWorkSafe THEN  
		 iMove:=4;//电机手动联动进
		 vTip.xWorkPos:=FALSE;//电机进到位
	 END_IF; 
END_IF;	 

//电机后退到位,停止启动
IF iMove=3 AND vTip.xHomePos  THEN
	  iMove:=0;//电机移动字
END_IF;

//电机前进到位,停止启动
IF iMove=4 AND vTip.xWorkPos  THEN
	  iMove:=0;//电机移动字
END_IF;


//电机自动运行
  //电机自动退

IF (State.xAutoStart OR State.xHoming) AND xidle AND MotorRdy.xMotorRdy  THEN 
	//电机手动联动退
     IF  MotorAuto.xAutoBW AND  MotorRdy.xHomeSafe THEN  
		 iMove:=5;//电机手动联动退
		 vTip.xHomePos:=FALSE;//电机退到位
	 END_IF;
	 //电机手动联动进
	IF  MotorAuto.xAutofW AND MotorRdy.xWorkSafe THEN  
		 iMove:=6;//电机手动联动进
		 vTip.xWorkPos:=FALSE;//电机进到位
	 END_IF; 
END_IF;	 

//电机后退到位,停止启动
IF iMove=5 AND vTip.xHomePos  THEN
	  MotorAuto.xAutoBW:=FALSE;
	  iMove:=0;//电机移动字
END_IF;

//电机前进到位,停止启动
IF iMove=6 AND vTip.xWorkPos  THEN
	  MotorAuto.xAutofW:=FALSE;
	  iMove:=0;//电机移动字
END_IF;

IF NOT State.xAutoEna  THEN
 
	IF NOT State.xHoming THEN 
		MotorAuto.xAutoBW:=FALSE;
	END_IF;
 ELSE 
   IF NOT State.xAutoStart THEN 
	   MotorAuto.xAutoBW:=FALSE;
	   MotorAuto.xAutofW:=FALSE;
   END_IF	
END_IF;


vTip.xHomeOut:= iMove=1 OR iMove=3 OR iMove=5;//电机后退输出
vtip.xWorkOut:= iMove=2 OR iMove=4 OR iMove=6;//电机前进输出
//电机后退到位信号
IF vTip.xHomeOut AND MotorRdy.xHomeSensor AND NOT vTip.xHomePos THEN
	vTip.xWorkPos:=FALSE;
	vTip.xHomePos:=TRUE;
END_IF;
IF NOT MotorRdy.xHomeSensor THEN
	vTip.xHomePos:=FALSE;
END_IF;

//电机前进到位信号
IF vtip.xWorkOut AND MotorRdy.xWorkSensor AND NOT vTip.xWorkPos THEN
	vTip.xHomePos:=FALSE;
	vTip.xWorkPos:=TRUE;
END_IF;
IF NOT MotorRdy.xWorkSensor THEN 
	vTip.xWorkPos:=FALSE;
END_IF;

vTip.xAlm:=NOT MotorRdy.xMotorRdy;


MotorTip:=vTip;


END_FUNCTION_BLOCK