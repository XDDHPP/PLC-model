PROGRAM A05 //设备整体复位-三轴码垛XYZ回原
VAR
	流程: INT := 10;
	iStep: INT; //分支计数变量，bit0=X完成, bit1=Y完成, bit2=Z完成
	xZReady: BOOL; //Z轴待机位标志
END_VAR

//Z轴待机位时XY才能运动
xZReady:=tip.AXOUT[3].SVOUT.xHomeOK AND (tip.AXOUT[3].iPosID=8);

CASE 流程 OF
	10:// Z轴回原
	IF NOT tip.AXOUT[3].SVOUT.xHomeOK THEN
		Axis.Cmd[3].Autoin.xHome:=TRUE;
	ELSE
		Axis.Cmd[3].Autoin.xHome:=FALSE;
		流程:=20;
	END_IF;

	20:// Z轴去待机位
	IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
		Axis.Cmd[3].Autoin.xAbs:=TRUE;
		Axis.Cmd[3].iAposID:=8;//8#待机位
	ELSE
		Axis.Cmd[3].iAposID:=0;
		流程:=30;
	END_IF;

	30:// XY同时回原
	IF NOT tip.AXOUT[1].SVOUT.xHomeOK THEN
		Axis.Cmd[1].Autoin.xHome:=TRUE;
	END_IF;
	IF NOT tip.AXOUT[2].SVOUT.xHomeOK THEN
		Axis.Cmd[2].Autoin.xHome:=TRUE;
	END_IF;
	iStep:=0;//清除位锁存
	IF Axis.Cmd[1].Autoin.xHome AND Axis.Cmd[2].Autoin.xHome THEN
		流程:=40;
	END_IF;

	40://XY回原完成信号判断
	IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
		流程:=30;
	END_IF;
	//位锁存：bit0=X完成, bit1=Y完成
	IF tip.AXOUT[1].SVOUT.xHomeOK THEN
		iStep:=iStep OR 1;
	END_IF;
	IF tip.AXOUT[2].SVOUT.xHomeOK THEN
		iStep:=iStep OR 2;
	END_IF;
	IF iStep=3 THEN
		Axis.Cmd[1].Autoin.xHome:=FALSE;
		Axis.Cmd[2].Autoin.xHome:=FALSE;
		流程:=50;
	END_IF;

	50:// XY去待机位（Z必须在待机位）
	IF xZReady THEN
		IF NOT tip.AXOUT[1].SVOUT.xAbsOK THEN
			Axis.Cmd[1].Autoin.xAbs:=TRUE;
			Axis.Cmd[1].iAposID:=8;//8#待机位X
		END_IF;
		IF NOT tip.AXOUT[2].SVOUT.xAbsOK THEN
			Axis.Cmd[2].Autoin.xAbs:=TRUE;
			Axis.Cmd[2].iAposID:=8;//8#待机位Y
		END_IF;
		IF Axis.Cmd[1].Autoin.xAbs AND Axis.Cmd[2].Autoin.xAbs THEN
			iStep:=0;//清除位锁存
			流程:=60;
		END_IF;
	END_IF;

	60://XY待机位完成信号判断
	IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
		流程:=50;
	END_IF;
	//位锁存：bit0=X完成, bit1=Y完成
	IF tip.AXOUT[1].SVOUT.xAbsOK THEN
		iStep:=iStep OR 1;
	END_IF;
	IF tip.AXOUT[2].SVOUT.xAbsOK THEN
		iStep:=iStep OR 2;
	END_IF;
	IF iStep=3 THEN
		Axis.Cmd[1].iAposID:=0;
		Axis.Cmd[2].iAposID:=0;
		流程:=100;
	END_IF;

	100://复位完成标记

END_CASE

END_PROGRAM
