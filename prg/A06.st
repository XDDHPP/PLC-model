PROGRAM A06
VAR
	
	
	流程: INT	:=3;
	选择:INT;
END_VAR

CASE 流程 OF  
	10://气缸自动升
	IF NOT tip.CylOut[1].xHomePos THEN
		    Cyl.cmd[1].xAutoctr:=TRUE;//气缸启动
		    Cyl.cmd[1].iAutoCtr:=1;;//气缸回原味
			ELSE
	    Cyl.cmd[1].iAutoCtr:=0;//气缸启动
	 流程:=20;
	END_IF;
	
	20://气缸自动降
	IF NOT tip.CylOut[1].xWorkPos THEN
		     Cyl.cmd[1].xAutoctr:=TRUE;//气缸启动
		     Cyl.cmd[1].iAutoCtr:=2;;//气缸到工位
			ELSE
	    Cyl.cmd[1].iAutoCtr:=0;//气缸启动
	流程:=30;
	END_IF;
	
	30://气缸自动升
	IF NOT tip.CylOut[1].xHomePos THEN
		    Cyl.cmd[1].xAutoctr:=TRUE;//气缸启动
		   Cyl.cmd[1].iAutoCtr:=1;;//气缸回原味
			ELSE
	   Cyl.cmd[1].iAutoCtr:=0;//气缸启动
	 流程:=40;
	END_IF;
	
	40://控制轴去待机位  5#位置
	IF NOT Tip.AXOUT[1].SVOUT.xAbsOK THEN
		Axis.Cmd[1].Autoin.xAbs:=TRUE;//轴启动
		Axis.Cmd[1].iAposID:=5;//轴待机位 5#位
		ELSE
		Axis.Cmd[1].iAposID:=0;//轴启动
		流程:=60;
	END_IF
	60://控制轴去 8#位置
	IF NOT Tip.AXOUT[1].SVOUT.xAbsOK THEN
			Axis.Cmd[1].Autoin.xAbs:=TRUE;//轴启动
			Axis.Cmd[1].iAposID:=8;//轴待机位 8#位
			ELSE
			Axis.Cmd[1].iAposID:=0;//轴启动
			流程:=80;
	END_IF
END_CASE

END_PROGRAM