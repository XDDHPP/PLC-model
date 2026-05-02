FUNCTION_BLOCK FB_Fliter
VAR_INPUT
	CTval:DINT;//模拟量实时值
	ilevel:INT;//级别
	timer:TIME;//滤波时间
END_VAR
VAR_OUTPUT
	diResult:DINT;//滤波处理后的结果
	aLVResult:ARRAY[0..10]OF DINT;//等级结果
	
END_VAR
VAR
	buffer:ARRAY[0..10]OF ST_buffer;//缓存数据
	aVCTval:ARRAY[0..10]OF DINT;//采样值中转
	T:ARRAY[0..10]OF TON;
	aAVG:ARRAY[0..10]OF DINT;//平均值
	airam:ARRAY[0..10]OF INT;//缓存索引
	aisum:ARRAY[0..10]OF INT;//求和索引
	aDSUM:ARRAY[0..10]OF DINT;//求和
	i: INT;
END_VAR


aVCTval[0]:=CTval;//0级滤波采样
aVCTval[1]:=aAVG[0];//1级滤波采样
aVCTval[2]:=aAVG[1];//2级滤波采样
aVCTval[3]:=aAVG[2];//3级滤波采样
aVCTval[4]:=aAVG[3];//4级滤波采样
aVCTval[5]:=aAVG[4];//5级滤波采样
aVCTval[6]:=aAVG[5];//6级滤波采样
aVCTval[7]:=aAVG[6];//7级滤波采样
aVCTval[8]:=aAVG[7];//8级滤波采样
aVCTval[9]:=aAVG[8];//9级滤波采样

T[0](IN:=NOT T[0].Q  , PT:=timer );//0级滤波采样中断
T[1](IN:=NOT T[1].Q  , PT:=timer );//1级滤波采样中断
T[2](IN:=NOT T[2].Q  , PT:=timer );//2级滤波采样中断
T[3](IN:=NOT T[3].Q  , PT:=timer );//3级滤波采样中断
T[4](IN:=NOT T[4].Q  , PT:=timer );//4级滤波采样中断
T[5](IN:=NOT T[5].Q  , PT:=timer );//5级滤波采样中断
T[6](IN:=NOT T[6].Q  , PT:=timer );//6级滤波采样中断
T[7](IN:=NOT T[7].Q  , PT:=timer );//7级滤波采样中断
T[8](IN:=NOT T[8].Q  , PT:=timer );//8级滤波采样中断
T[9](IN:=NOT T[9].Q  , PT:=timer );//9级滤波采样中断

FOR i:=0 TO ilevel BY 1 DO
	//存储十个缓存数据，循环采集数据
   IF  T[i].Q THEN
	   buffer[i].Cache[airam[i]]:=aVCTval[i];
	   airam[i]:=airam[i]+1;
	  IF airam[i]>9 THEN
	  	airam[i]:=0;
	  END_IF;
   END_IF;
	//采集的十个数据求和
	aDSUM[i]:=0;
	FOR aisum[i]:=0 TO 9 BY 1 DO
	aDSUM[i]:=aDSUM[i]+buffer[i].Cache[aisum[i]];
	END_FOR
	//平均值
	aAVG[i]:=aDSUM[i]/10;
END_FOR;

diResult:=aAVG[ilevel];//当前级别输出的滤波结果
aLVResult:=aAVG;//每个级别输出的滤波结果



END_FUNCTION_BLOCK