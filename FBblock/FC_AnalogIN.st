FUNCTION FC_AnalogIN : REAL
VAR_INPUT
	rMeterValue1:REAL;//仪表测量值1
	rAnalog1:REAL;//测量值1对应的模拟量
	rMeterValue2:REAL;//仪表测量值2
	rAnalog2:REAL;//测量值2对应的模拟量
	rOffSet:REAL;//偏置补偿值
	iCutAnalog:INT;//模拟量当前值
END_VAR
VAR
	rRate:REAL;//比率
END_VAR
//1个模拟量对应的仪表工程值
IF rMeterValue2>rMeterValue1 AND rAnalog2>rAnalog1 THEN
	rRate:=(rMeterValue2-rMeterValue1)/( rAnalog2- rAnalog1);
END_IF

FC_AnalogIN:=INT_TO_REAL(iCutAnalog)*rRate+rOffSet;
END_FUNCTION

