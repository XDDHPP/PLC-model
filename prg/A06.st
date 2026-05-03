PROGRAM A06
VAR


	流程: INT	:=3;
	选择:INT;
	iStep:INT;//分支位锁存计数器（bit0=轴1, bit1=轴2）
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

//========== 示例：两轴同时回原 ==========
100:// 触发两轴回原
    IF NOT Tip.AXOUT[1].SVOUT.xHomeOK THEN
        Axis.Cmd[1].Autoin.xHome:=TRUE;
    END_IF;
    IF NOT Tip.AXOUT[2].SVOUT.xHomeOK THEN
        Axis.Cmd[2].Autoin.xHome:=TRUE;
    END_IF;
    iStep:=0;// 清除位锁存
	IF Axis.Cmd[1].Autoin.xHome AND Axis.Cmd[2].Autoin.xHome THEN
		流程:=105;
	END_IF;
105://回原完成信号判断
    IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
        流程:=100;
    END_IF;
    // 位锁存：bit0=轴1完成, bit1=轴2完成, 3=两轴都完成
    IF Tip.AXOUT[1].SVOUT.xHomeOK THEN
		iStep:=iStep OR 1;
	END_IF;
    IF Tip.AXOUT[2].SVOUT.xHomeOK THEN
		iStep:=iStep OR 2;
	END_IF;
    IF iStep=3 THEN
        流程:=110;
    END_IF;

//========== 示例：两轴同时定位 ==========
110:// 触发两轴定位
    IF NOT Tip.AXOUT[1].SVOUT.xAbsOK THEN
        Axis.Cmd[1].Autoin.xAbs:=TRUE;
        Axis.Cmd[1].iAposID:=5;
    END_IF;
    IF NOT Tip.AXOUT[2].SVOUT.xAbsOK THEN
        Axis.Cmd[2].Autoin.xAbs:=TRUE;
        Axis.Cmd[2].iAposID:=5;
    END_IF;
    iStep:=0;// 清除位锁存
	IF Axis.Cmd[1].Autoin.xAbs AND Axis.Cmd[2].Autoin.xAbs THEN
		流程:=115;
	END_IF;
115://定位完成信号判断
    IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
        流程:=110;
    END_IF;
    // 位锁存：bit0=轴1完成, bit1=轴2完成, 3=两轴都完成
    IF Tip.AXOUT[1].SVOUT.xAbsOK THEN
		iStep:=iStep OR 1;
	END_IF;
    IF Tip.AXOUT[2].SVOUT.xAbsOK THEN
		iStep:=iStep OR 2;
	END_IF;
    IF iStep=3 THEN
        流程:=120;
    END_IF;

120:// 继续后续流程...

END_CASE

END_PROGRAM
