PROGRAM A09
VAR
	FbMotor:ARRAY[0..20] OF Fb_Motor;//电机功能块
	
END_VAR

//1#电机准备信号
FbMotor[1].MotorRdy.xHomeSafe:=TRUE;//电机反转安全信号
FbMotor[1].MotorRdy.xWorkSafe:=TRUE;//电机正转安全信号
FbMotor[1].MotorRdy.xMotorRdy:=TRUE;//电机就绪信号，未报警
FbMotor[1].MotorRdy.xHomeSensor:=SYS.xP_1s;//电机反转到位
FbMotor[1].MotorRdy.xWorkSensor:=NOT SYS.xP_1s;//电机正转到位



//2#电机准备信号
FbMotor[2].MotorRdy.xHomeSafe:=TRUE;//电机反转安全信号
FbMotor[2].MotorRdy.xWorkSafe:=TRUE;//电机正转安全信号
FbMotor[2].MotorRdy.xMotorRdy:=TRUE;//电机就绪信号，未报警
FbMotor[2].MotorRdy.xHomeSensor:=SYS.xP_1s;//电机反转到位
FbMotor[2].MotorRdy.xWorkSensor:=NOT SYS.xP_1s;//电机正转到位



//电机1调用功能块

FbMotor[1](
	State:=sys.State , 
	MotorHMI:=Hmi.Motor[1] , 
	MotorAuto:=Motor.Cmd[1] , 
	MotorTip=>Tip.Motor[1] );	
	
	//电机2调用功能块
FbMotor[2](
	State:=sys.State , 
	MotorHMI:=Hmi.Motor[2]  , 
	MotorAuto:=Motor.Cmd[2] , 
	MotorTip=>Tip.Motor[2] );
	





//电机1#
//%QX0.0:=Tip.MotorOut[1].xHomeOut;反转控制信号
//%QX0.1:=Tip.MotorOut[1].xWorkOut;正转控制信号


//电机2#
//%QX0.0:=Tip.MotorOut[2].xHomeOut;反转控制信号
//%QX0.1:=Tip.MotorOut[2].xWorkOut;正转控制信号

END_PROGRAM
