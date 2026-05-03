FUNCTION_BLOCK FB_Clock
VAR_INPUT
	rScanTime:REAL;//PLC扫描周期  单位 ms
	rFlipTime:REAL;//震荡周期，单位ms
END_VAR
VAR_OUTPUT
	xPulse:BOOL;//脉冲输出信号
END_VAR
VAR
	uSetICT:UINT;//设定计数个数
	uPreICT:UINT;//当前个数
END_VAR

uSetICT:=REAL_TO_UINT(rFlipTime/rScanTime);//设定扫描周期个数
xPulse:=(uPreICT < uSetICT/2);//脉冲输出信号
uPreICT :=uPreICT+1;//当前扫描周期计数
IF uPreICT> uSetICT THEN
	uPreICT:=0;
END_IF;

END_FUNCTION_BLOCK