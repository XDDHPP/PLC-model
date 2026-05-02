FUNCTION FC_AnalogOut : INT
VAR_INPUT
	rMeterValue1:REAL;//输出模拟量电压1，对应的量程
	rAnalog1:REAL;//数值1对应的模拟量
	rMeterValue2:REAL;//输出模拟量电压2，对应的量程
	rAnalog2:REAL;//数值1对应的模拟量
	rOffSet:REAL;//偏置补偿值
	rMeterSetValue:REAL;//仪表设备设定值
END_VAR
VAR
		rRate:REAL;//比率
END_VAR
//1个模拟量对应的仪表工程值
IF rMeterValue2>rMeterValue1 AND rAnalog2>rAnalog1 THEN
	rRate:=(rMeterValue2-rMeterValue1)/( rAnalog2- rAnalog1);
END_IF;
IF rRate>0 THEN
FC_AnalogOut:=REAL_TO_INT(rMeterSetValue/rRate);
END_IF;

END_FUNCTION