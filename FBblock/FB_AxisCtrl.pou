FUNCTION_BLOCK FB_AxisCtrl//伺服轴控功能块
VAR_INPUT
	State:ST_SYS;//当前设备系统状态
END_VAR
VAR_IN_OUT
	AxisName: AXIS_REF_SM3;//指定轴
	AxisIn: ST_AxisCtrl;//轴控制允许以及自动控制
	Axhand:ST_AxHmi;//伺服手动控制
    AxisData : ST_SVDATA;//伺服定位数据
END_VAR

VAR_OUTPUT
	AxisOut: ST_AxisOut;//轴控反馈的所有信号
END_VAR
VAR //定位控制编号处理
    buffer:ARRAY [0..31] OF BOOL;//手动定位的32位
	i:INT;
	j:INT;
	iHposID:INT;//手动编号预显示
    iPosID:INT;//定位，示教编号
	VDoneID:INT;//定位完成ID
	xAutoLock:BOOL;// 自动锁机
	Axpar:ST_SVPARLR;//伺服定位参数
	lrActPos:LREAL;//当前位置	
	lrActVel:LREAL;//当前速度
	lrActTor:LREAL;//当前扭矩
	AxStation:ST_SVSTATE;//设备
	PMPower:R_TRIG;//伺服手动使能上升沿功能块
	xPowerPulse:BOOL;//伺服手动使能沿
	iPower:INT;//轴使能流程
	xAutoPower:BOOL;//伺服自动使能
	vSvIn:ST_SVIN;//轴控制信号
	vSvout:ST_SVOUT;//轴空指令反馈信号
	xJogBusy:BOOL;
	xAxRdy:BOOL;//伺服准备OK
	iJog:INT;//轴点动流程
	xCtrlEna:BOOL;//伺服手动控制允许信号
	xAbsAct:BOOL;   //伺服自动绝对定位
	xRelateAct:BOOL;//伺服自动相对定位
	TAbs:TON;//绝对定位延时
	TRelate:TON;//相对定位延时
	TRdy:TON;//伺服定位准备OK
	FbMCPOWER: MC_Power;
	FbMCJOG: MC_Jog;
	FbMCHOME: MC_Home;
	FbMCABSOLUTE: MC_MoveAbsolute;
	FbMCRELATE: MC_MoveRelative;
	FbRDERR:MC_ReadAxisError;
	FbMCHALT: MC_Halt;
	FbMCSTOP: MC_Stop;
	FbMCRST: MC_Reset;
    ERRID:ARRAY[0..4]OF SMC_ERROR;

END_VAR



IF State.xManulEna AND  vSvout.xActRDY  THEN 
	FOR i:=0 TO 15 BY 1 DO
		IF Axhand.Buttonin[i] AND NOT buffer[i] THEN 	
			//缓存清除
			FOR j:=0 TO 15 BY 1 DO
				buffer[j]:=FALSE;
	    	END_FOR;	
			//记忆按钮操作信号
			IF Axhand.Buttonin[i] THEN 
				buffer[i]:=TRUE;
			ELSE
				buffer[i]:=FALSE;
			END_IF;	
			Axhand.Buttonin:=buffer;//数据反向输出
			//第几位按钮状态为ON 
			IF buffer[i] THEN 
				iHposID:=i;//手动定位编号，
			END_IF;
		END_IF;
	END_FOR;	
	
END_IF;



//手动定位编号与自动定位编号的传送
AxisOut.iHposID:=iHposID;//对外显示的手动定位编号

//手动定位编号传送到定位编号
IF State.xManulEna AND  ( TAbs.in OR TRelate.IN) AND vSvout.xhomeMark  THEN
	AxisOut.iposID:=iHposID;//手动编号
	iPosID:=iHposID;//手动定位编号，调用位置
END_IF;
//自动运行时，把自动编号传送到定位编号
IF State.xAutoStart AND AxisIn.Autoin.xAbs AND vSvout.xhomeMark THEN
	AxisOut.iPosID:=AxisIn.iAposID;//自动编号
	iPosID:=AxisIn.iAposID;//自动定位编号，调用位置
END_IF;


//伺服上电处理，手动和自动上电
//手动使能上升沿处理
PmPower(CLK:=Axhand.Handin.xPwoer , Q=>xPowerPulse );
//使能手动触发
vSvin.xPwoer:= xPowerPulse AND NOT vSvout.xAxisErr AND state.xEstop ;
IF vSvin.xPwoer THEN
	iPower:=iPower+1;
END_IF;

//使能自动触发，当设备复位或者自动时，
IF state.xHoming OR state.xAutoStart THEN
	iPower:=1;
END_IF;

//使能信号 复位       急停					轴报警
IF iPower>1 OR (NOT state.xEstop) OR  
   (vSvout.xAxisErr AND NOT VSVOUT.xpowerOK)   THEN
   
	iPower:=0;
	
END_IF;

//轴使能流程控制
CASE iPower OF
	0://伺服使能断开
    	xAutoPower:=FALSE;
    1://伺服使能打开
		xAutoPower:=TRUE;
END_CASE;

//伺服准备ok，就绪信号,伺服通讯OK
xAxRdy:=xAutoPower AND AxisIn.EnaSafe.xAXread AND VSVOUT.xpowerOK AND NOT vSvout.xAxisErr ;

//**//***************伺服点动控制******************//**//
//伺服手动控制允许信号 
xCtrlEna:= xAxRdy AND NOT vSvin.xHome AND 
				NOT vSvin.xAbs AND NOT vSvin.xRelat;
				 
//1.伺服允许定位RDY信号
TRdy(IN:=xCtrlEna ,PT:=T#100MS  );//回原OK，并且没有其他动作
vSvout.xActRDY:=TRdy.Q; //伺服动作允许信号				 
				 
	
IF 	vSvout.xActRDY AND State.xManulEna  THEN
      //伺服手动点动正控制     
		IF Axhand.Handin.xJogp  AND AxisIn.EnaSafe.xJogPsafe   THEN
		 	iJog:=1;
	    END_IF;
	 //伺服手动点动负控制
		IF Axhand.Handin.xJogn  AND AxisIn.EnaSafe.xJogNsafe  THEN
		 	iJog:=2;
		END_IF;	
END_IF;		 

IF 	State.xAutoStart THEN 
	//伺服自动控制，点动正向运行
	IF AxisIn.Autoin.xJogP  AND AxisIn.EnaSafe.xJogPsafe THEN
		 iJog:=1;
	END_IF;
	//伺服自动控制，点动负向运行
	IF AxisIn.Autoin.xJogN  AND AxisIn.EnaSafe.xJogNsafe THEN
		 iJog:=2;
	END_IF;
END_IF;	


	//伺服手动点动停止
	IF State.xManulEna AND NOT Axhand.Handin.xJogn AND NOT Axhand.Handin.xJogp THEN
		 iJog:=0;
	END_IF;

	//伺服自动控制，点动停止
	IF  State.xAutoStart AND NOT AxisIn.Autoin.xJogN  AND NOT AxisIn.Autoin.xJogP THEN
		 iJog:=0;
	END_IF;
	//轴在运行中,安全信号丢失
	IF iJog=1 AND NOT AxisIn.EnaSafe.xJogPsafe THEN
		iJog:=0;
	END_IF;
	IF iJog=2 AND NOT AxisIn.EnaSafe.xJogNsafe THEN
		iJog:=0;
	END_IF;
	
	//设备暂停，自动点动停止
	IF  State.xAutoHalt THEN 
		 iJog:=0;
	END_IF;
	//急停拍下或者伺服未准备就绪
	IF 	(NOT state.xEstop) OR (NOT xAxRdy) THEN
		 iJog:=0;
	END_IF;
	
//轴点动流程
CASE iJog OF
	0://点动信号复位
	vSvin.xJogn:=FALSE;
	vSvin.xJogp:=FALSE;
	1://伺服点动正
	 vSvin.xJogn:=FALSE;
	vSvin.xJogp:=TRUE;
	2://伺服点动负
	vSvin.xJogn:=TRUE;
	vSvin.xJogp:=FALSE;
END_CASE;
//**//***************伺服点动控制******************//**//

///********伺服回原控制*********////  
//伺服手动回原 
IF State.xManulEna AND  vSvout.xActRDY THEN
   IF AxisIn.EnaSafe.xActSafe AND Axhand.Handin.xHome THEN
	  vSvin.xHome:=TRUE;
	  AxisOut.xhomeMark:=FALSE;
   END_IF;
END_IF;   

//伺服自动回原 
IF (State.xAutoStart OR State.xHoming)  THEN
    IF AxisIn.EnaSafe.xActSafe AND AxisIn.Autoin.xHome THEN 
	   vSvin.xHome:=TRUE;
	   AxisOut.xhomeMark:=FALSE;
  END_IF;
END_IF;


//回原信号复位处理，回原OK，急停，伺服未就绪
IF vSvout.xHomeOK  OR (NOT state.xEstop) 
   OR (NOT xAxRdy) OR (NOT AxisIn.EnaSafe.xActSafe)    THEN
	vSvin.xHome:=FALSE;
END_IF;


//伺服回原OK标记，复位
IF NOT state.xEstop OR (NOT xAxRdy)  THEN
	AxisOut.xhomeMark:=FALSE;
END_IF;

//伺服回原OK标记， 增量式自动回原，绝对式强制原点OK信号
IF vSvout.xHomeOK OR AxisIn.xAbsolute THEN
	vSvout.xHomeMark:=TRUE;
END_IF;

//伺服绝对定位控制
//伺服手动定位
IF State.xManulEna AND  vSvout.xActRDY AND vSvout.xhomeMark THEN
   IF AxisIn.EnaSafe.xActSafe AND Axhand.Handin.xAbs THEN
	   xAbsAct:=TRUE;
   END_IF;
END_IF;   

//伺服自动定位
IF (State.xAutoStart OR State.xHoming) AND  vSvout.xActRDY AND vSvout.xhomeMark  THEN
    IF AxisIn.EnaSafe.xActSafe AND AxisIn.Autoin.xAbs THEN 
	   xAbsAct:=TRUE;
  	END_IF;
END_IF;


//伺服定位信号,复位处理，
IF vSvout.xAbsOK  OR (NOT state.xEstop) 
   OR (NOT xAxRdy) OR (NOT AxisIn.EnaSafe.xActSafe)  THEN
	 xAbsAct:=FALSE;
END_IF;


//伺服手动与自动定位汇总

TAbs (IN:= xAbsAct AND AxisIn.EnaSafe.xActSafe,
       PT:=T#10MS,Q=>vSvin.xAbs);


//伺服相对定位控制
//伺服手动定位
IF State.xManulEna AND  vSvout.xActRDY AND vSvout.xhomeMark THEN
   IF AxisIn.EnaSafe.xActSafe AND Axhand.Handin.xRelat THEN
	   xRelateAct:=TRUE;
   END_IF;
END_IF;   

//伺服自动定位
IF (State.xAutoStart OR State.xHoming) AND  vSvout.xActRDY AND vSvout.xhomeMark  THEN
    IF AxisIn.EnaSafe.xActSafe AND AxisIn.Autoin.xRelat THEN 
	  xRelateAct:=TRUE;
  	END_IF;
END_IF;


//伺服定位信号,复位处理，
IF vSvout.XRelatOK  OR (NOT state.xEstop) 
   OR (NOT xAxRdy) OR (NOT AxisIn.EnaSafe.xActSafe)  THEN
	 xRelateAct:=FALSE;
END_IF;

//伺服手动与自动定位汇总
TRelate(IN:=xRelateAct AND AxisIn.EnaSafe.xActSafe ,
        PT:=T#10MS,Q=>vSvin.xRelat);

//手动调试，示教位置保存到伺服数据库*****///
IF State.xManulEna AND Axhand.Handin.xTeachSave AND vSvout.xhomeMark THEN
	AxisData.aPOS[iHposID]  :=LREAL_TO_REAL(lrActPos);
END_IF;
//手动调试，示教位置保存到伺服数据库*****///

//自动/手动定位时，调用伺服数据库，具体某个位置
IF (vSvin.xRelat OR vSvin.xAbs) AND vSvout.xhomeMark THEN
	AxPar.LrAbsPos:=REAL_TO_LREAL(AxisData.aPos[iPosID]);
	AxPar.LrRelatePos:=REAL_TO_LREAL(AxisData.aPos[iPosID]);
END_IF;

AxPar.LrJogVel:=REAL_TO_LREAL(Axhand.SVPAR.rJogVel);//点动速度
AxPar.LrAcce:=REAL_TO_LREAL(Axhand.SVPAR.rAcce);//加速度
AxPar.LrDece:=REAL_TO_LREAL(Axhand.SVPAR.rDece);//减速度
AxPar.LrZeroPos:=REAL_TO_LREAL(Axhand.SVPAR.rZeroPos);//零点标定

AxStation.rActPos:=LREAL_TO_REAL(lrActPos);//当前位置
AxStation.rActVel:=LREAL_TO_REAL(lrActVel);//当前速度
AxStation.rActTor:=LREAL_TO_REAL(lrActTor);//当前扭矩





//手动定位速度
IF State.xManulEna THEN
	AxPar.LrAbsVel:=AxPar.LrJogVel;
END_IF;
//自动定位速度
IF (State.xAutoStart OR State.xHoming) AND  vSvout.xhomeMark THEN
	AxPar.LrAbsVel:=REAL_TO_LREAL(AxisData.aVel[iPosID]);
END_IF;

//轴暂停处理
vSvin.xHalt:=( NOT AxisIn.EnaSafe.xHaltSelect AND 
              (NOT State.xHalt OR  State.xAlming OR 
              NOT  AxisIn.EnaSafe.xActSafe  OR State.xAutoHalt))
			  OR( AxisIn.EnaSafe.xHaltSelect AND AxisIn.Autoin.xHalt);
			  
			  


//伺服使能
FbMCPOWER(//三个触发信号分开，Enable,bRegulatorOn,bDriveStart
	Axis:=AxisName , 
	Enable:=1 , 
	bRegulatorOn:= xAutoPower , 
	bDriveStart:= xAutoPower, 
	Status=>VSVOUT.xpowerOK , 
	Busy=>VSVOUT.xPowerBusy , 
	ErrorID=>ERRID[0]);

//伺服点动控制
FbMCJOG(
	Axis:=AxisName , 
	JogForward:=vSvin.xJogP , 
	JogBackward:=vSvin.xJogn , 
	Velocity:=AxPar.LrJogVel , 
	Acceleration:=AxPar.LrAcce , 
	Deceleration:=AxPar.LrDece , 
	Busy=>xJogBusy , 
	ErrorID=>ERRID[1]);
//	伺服回原
FbMCHOME(
	Axis:=AxisName , 
	Execute:=vSvin.xHome , 
	Position:=AxPar.LrZeroPos , 
	Done=>VSVOUT.xhomeOK , 
	Busy=>VSVOUT.xhomeBusy , 
	ErrorID=>ERRID[2]);
//伺服绝对定位
FbMCABSOLUTE(
	Axis:=AxisName , 
	Execute:=vSvin.xAbs , 
	Position:=AxPar.LrAbsPos , 
	Velocity:=AxPar.LrAbsVel , 
	Acceleration:=AxPar.LrAcce , 
	Deceleration:=AxPar.LrDece, 
	Done=>VSVOUT.xabsOK , 
	Busy=>VSVOUT.xabsBusy , 
	ErrorID=>ERRID[3]);
	
//伺服相对定位
FbMCRELATE(
	Axis:=AxisName , 
	Execute:=vSvin.xRelat , 
	Distance:=AxPar.LrRelatePos , 
	Velocity:=AxPar.LrAbsVel , 
	Acceleration:=AxPar.LrAcce, 
	Deceleration:=AxPar.LrDece , 
	Done=>VSVOUT.XRelatOK , 
	Busy=>VSVOUT.XRelatBusy , 
	ErrorID=>ERRID[4]);
	
//伺服当前状态,位置，速度，扭矩，错误代码
	
lrActPos:=AxisName.fActPosition;//位置
lrActVel:=AxisName.fActVelocity;//速度
lrActTor:=AxisName.fActTorque;//扭矩
VSVOUT.xAxisErr:=AxisName.bError;//轴错误
FbRDERR(//错误代码
	Axis:=AxisName , 
	Enable:=1 , 
	ErrorID=>AxStation.uActSvErr , 
	AxisErrorID=>AxStation.DActAxisErr );


//轴暂停
FbMCHALT(
	Axis:=AxisName , 
	Execute:= vSvin.xHalt , 
	Deceleration:=2000  );
//轴急停
FbMCSTOP(
	Axis:=AxisName , 
	Execute:=NOT State.xEstop , 
	Deceleration:=10000  );
//轴复位
FbMCRST(Axis:=AxisName , 
	Execute:= VSVOUT.xAxisErr AND State.xAlmRst );	
	

	
	
//设备复位时，默认手自动状态一致
IF State.xHoming THEN
	xAutoLock:=FALSE;//自动锁机信号解锁
	VDoneID:=AxisIn.iAposID;//自动定位编号赋值
END_IF;

//在手动点动调试伺服时，把VDoneID的数值清零
IF State.xManulEna AND (Vsvin.xJogn OR Vsvin.xJogp OR Vsvin.xHome) THEN
	VDoneID:=0;
END_IF;

//手动定位伺服完成时，把手动编号赋值给定位完成ID
IF State.xManulEna AND vSvout.xAbsOK THEN
	VDoneID:=iHposID;
END_IF;

//自动切到手动，在切自动，是否可以正常运行
IF State.xAutoHalt AND NOT State.xManulEna THEN //自动状态下
    IF  xAutoLock THEN  //手自动状态不一致锁机
	 		AxisOut.xTIP:=TRUE;//手自动安全提示置位
	    	AxisOut.iPOSTIP:=AxisIn.iAposID;//提示手动定位伺服到自动停机前的位置编号
		ELSE //设备没有锁机时
			VDoneID:=AxisIn.iAposID;//	实时更新轴当前状态
			AxisOut.xTIP:=FALSE;//手自动安全提示复位  
	 END_IF;
END_IF;

IF State.xManulEna THEN //手动模式下
   IF  VDoneID=AxisIn.iAposID THEN
	     xAutoLock :=FALSE;//当前状态与期望状态一致，解锁自动运行 
		ELSE
		 xAutoLock :=TRUE;//当前状态与期望状态一致，锁定自动运行
   END_IF 
END_IF;//手自动状态不一致，需要按照手动提示操作



//伺服状态信号汇总
//1.伺服手动点动反馈信号	  
Axisout.SVOUT.xJogPout:=Vsvin.xJogp AND xJogBusy;//点动正
Axisout.SVOUT.xJogNout:=Vsvin.xJogN AND xJogBusy;//点动负
//2.轴空指令反馈
AxisOut.SVOUT:=vSvout;
//3.伺服当前状态
AxisOut.Station:=AxStation;






