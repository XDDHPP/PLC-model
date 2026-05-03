PROGRAM A15
VAR
END_VAR


//读取设备当前运转参数/配方
//配方被操作中
GRCP.xSeting:= GRCP.xSelectInc OR GRCP.xSelectDec OR GRCP.xSelectOK OR GRCP.xSetOK;

//读取配方库的具体某个配方

 	IF NOT GRCP.xSeting THEN //没有操作任何配方按钮时
		GRCP.PvRcp:=GRCP.LibRcp[GRCP.PvNo];//PvNo :配方编号
 	END_IF;// 如果没有操作其他，直接读取配方库具体某个配方

//配方选择进入时，提前读取配方库数据
IF GRCP.xSelect THEN
	GRCP.PreRcp:=GRCP.LibRcp[GRCP.PvNo];//进入画面前，读取当前配方数据
	sys.ShowPic[0] := 105;//画面切换，配方选择
END_IF;


//配方选择，
IF GRCP.xSelectInc THEN //设定配方号，自动加按钮
	GRCP.SvNo:=GRCP.SvNo+1;//设定配方编号，自动加1
	
	//配方编号到最大时，自动切到零号配方
	IF GRCP.SvNo >50 THEN 
		GRCP.SvNo:=0;
	END_IF;
	
	GRCP.PreRcp:=GRCP.LibRcp[GRCP.SvNo];//预显示其中一个配方
	GRCP.xSelectInc:=FALSE;// 自动加按钮复位，实现上升沿触发
END_IF;

IF GRCP.xSelectDec THEN //设定配方号自动减
	GRCP.SvNo:=GRCP.SvNo-1; //设定配方编号自动减1
	
	//当配方编号到最小时，自动切换到最大配方号
	IF GRCP.SvNo <0 THEN
		GRCP.SvNo:=50;
	END_IF;
	
	GRCP.PreRcp:=GRCP.LibRcp[GRCP.SvNo]; //预显示其中一个配方
	GRCP.xSelectDec:=FALSE;//实现上升沿触发
END_IF;

IF GRCP.xSelectOK THEN//配方选择确认
	GRCP.PvNo:=GRCP.SvNo;//设定配方编号，传送到当前配方编号
	GRCP.LibRcp[GRCP.SvNo].No:=GRCP.SvNo;
	//设定配方号，传送到配方库中具体某一个配方的编号中
END_IF;



//配方设定 

//进入配方设定的页面，
//当前配方数据，传送到设定配方数据
IF GRCP.xRcpSet THEN
	GRCP.SvRcp:=GRCP.PvRcp;//配方数据传送
	GRCP.SvNo:=GRCP.PvNo;//配方编号传送
 	sys.ShowPic[0] := 115;//画面切换，配方设定
END_IF;

//按下配方设定时，设定配方传到设定配方库，修改配方库中当前配方参数
IF GRCP.xSetOK THEN //配方设定确认OK
	GRCP.LibRcp[GRCP.SvNo]:= GRCP.SvRcp;
END_IF;//数据传送到配方库中

//当修改数据有错误时，重新读取配方库原有数据
IF GRCP.xSetNg THEN //配方设定取消
 	GRCP.SvRcp:=GRCP.LibRcp[GRCP.SvNo];//重新读取配方库的数据
END_IF





