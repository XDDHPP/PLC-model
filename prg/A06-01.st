PROGRAM A06_01 //三轴码垛XYZ-真空吸-8*8托盘
VAR
	流程: INT := 10;
	iStep: INT;         //分支计数变量，bit0=X完成, bit1=Y完成
	iStepZ: INT;        //Z轴完成标志
	选择: INT;          //配方选择（产品类型）
	iRow: INT;          //当前行（0-7）
	iCol: INT;          //当前列（0-7）
	iCount: INT;        //计数（0-63）
END_VAR

CASE 流程 OF
	10://初始化，气缸回原，真空破
	IF NOT tip.CylOut[1].xHomePos THEN
		Cyl.cmd[1].xAutoctr:=TRUE;
		Cyl.cmd[1].iAutoCtr:=1;//气缸回原位
	ELSE
		Cyl.cmd[1].iAutoCtr:=0;
		流程:=20;
	END_IF;

	20://真空破
	IF NOT tip.CylOut[4].xHomePos THEN
		Cyl.cmd[4].xAutoctr:=TRUE;
		Cyl.cmd[4].iAutoCtr:=1;//真空破-回原位
	ELSE
		Cyl.cmd[4].iAutoCtr:=0;
		流程:=30;
	END_IF;

	30://Z轴去待机位（安全位）
	IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
		Axis.Cmd[3].Autoin.xAbs:=TRUE;
		Axis.Cmd[3].iAposID:=8;//8#待机位
	ELSE
		Axis.Cmd[3].iAposID:=0;
		流程:=40;
	END_IF;

	40://XY移动到取料位
	IF NOT tip.AXOUT[1].SVOUT.xAbsOK THEN
		Axis.Cmd[1].Autoin.xAbs:=TRUE;
		Axis.Cmd[1].iAposID:=5;//5#取料位X
	END_IF;
	IF NOT tip.AXOUT[2].SVOUT.xAbsOK THEN
		Axis.Cmd[2].Autoin.xAbs:=TRUE;
		Axis.Cmd[2].iAposID:=5;//5#取料位Y
	END_IF;
	iStep:=0;//清除位锁存
	IF Axis.Cmd[1].Autoin.xAbs AND Axis.Cmd[2].Autoin.xAbs THEN
		流程:=45;
	END_IF;

	45://XY定位完成信号判断
	IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
		流程:=40;
	END_IF;
	//位锁存：bit0=X完成, bit1=Y完成, 3=XY都完成
	IF tip.AXOUT[1].SVOUT.xAbsOK THEN
		iStep:=iStep OR 1;
	END_IF;
	IF tip.AXOUT[2].SVOUT.xAbsOK THEN
		iStep:=iStep OR 2;
	END_IF;
	IF iStep=3 THEN
		Axis.Cmd[1].iAposID:=0;
		Axis.Cmd[2].iAposID:=0;
		流程:=50;
	END_IF;

	50://Z轴下降到取料位
	IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
		Axis.Cmd[3].Autoin.xAbs:=TRUE;
		Axis.Cmd[3].iAposID:=6;//6#取料位Z
	ELSE
		Axis.Cmd[3].iAposID:=0;
		流程:=60;
	END_IF;
	

	60://真空吸取
	IF NOT tip.CylOut[4].xWorkPos THEN
		Cyl.cmd[4].xAutoctr:=TRUE;
		Cyl.cmd[4].iAutoCtr:=2;//真空吸合-到工位
	ELSE
		Cyl.cmd[4].iAutoCtr:=0;
		流程:=70;
	END_IF;

	70://Z轴回到待机位（单轴，一步即可）
	IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
		Axis.Cmd[3].Autoin.xAbs:=TRUE;
		Axis.Cmd[3].iAposID:=8;//8#待机位
	ELSE
		Axis.Cmd[3].iAposID:=0;
		流程:=80;
	END_IF;

	80://计算托盘位置（8*8=64个位置）
	//位置ID = 10 + row*8 + col （10-73）
	iRow:=iCount / 8;//行0-7
	iCol:=iCount MOD 8;//列0-7

	//XY移动到托盘位置（Z必须在待机位）
	
	IF NOT tip.AXOUT[1].SVOUT.xAbsOK THEN
		Axis.Cmd[1].Autoin.xAbs:=TRUE;
		Axis.Cmd[1].iAposID:=10 + iRow * 8 + iCol;
	END_IF;
	IF NOT tip.AXOUT[2].SVOUT.xAbsOK THEN
		Axis.Cmd[2].Autoin.xAbs:=TRUE;
		Axis.Cmd[2].iAposID:=10 + iRow * 8 + iCol;
	END_IF;
	 iStep:=0;//清除位锁存
	IF Axis.Cmd[1].Autoin.xAbs AND Axis.Cmd[2].Autoin.xAbs THEN
			流程:=85;
	END_IF;


	85://XY定位完成信号判断
	IF Sys.State.xAutoEna AND NOT Sys.State.xAutoStart THEN
		流程:=80;
	END_IF;
	//位锁存：bit0=X完成, bit1=Y完成, 3=XY都完成
	IF tip.AXOUT[1].SVOUT.xAbsOK THEN
		iStep:=iStep OR 1;
	END_IF;
	IF tip.AXOUT[2].SVOUT.xAbsOK THEN
		iStep:=iStep OR 2;
	END_IF;
	IF iStep=3 THEN
		Axis.Cmd[1].iAposID:=0;
		Axis.Cmd[2].iAposID:=0;
		流程:=90;
	END_IF;

	90://Z轴下降到托盘位
		IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
			Axis.Cmd[3].Autoin.xAbs:=TRUE;
			Axis.Cmd[3].iAposID:=10 + iRow * 8 + iCol + 1;//+1区分Z高度
		ELSE
			Axis.Cmd[3].iAposID:=0;
			流程:=100;
		END_IF;

	100://真空破-放料
	IF NOT tip.CylOut[4].xHomePos THEN
		Cyl.cmd[4].xAutoctr:=TRUE;
		Cyl.cmd[4].iAutoCtr:=1;//真空破-回原位
	ELSE
		Cyl.cmd[4].iAutoCtr:=0;
		流程:=110;
	END_IF;

	110://Z轴回到待机位（单轴，一步即可）
	IF NOT tip.AXOUT[3].SVOUT.xAbsOK THEN
		Axis.Cmd[3].Autoin.xAbs:=TRUE;
		Axis.Cmd[3].iAposID:=8;//8#待机位
	ELSE
		Axis.Cmd[3].iAposID:=0;
		iCount:=iCount+1;
		IF iCount>=64 THEN
			流程:=200;//码垛完成
		ELSE
			流程:=40;//继续下一个位置
		END_IF;
	END_IF;

	200://码垛完成，等待复位
	iCount:=0;
	流程:=200;

END_CASE

END_PROGRAM
