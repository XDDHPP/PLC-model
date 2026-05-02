PROGRAM A01//输入信号延时滤波映射
VAR
	T10:ARRAY[0..50] OF TON;//气缸原位
	T11:ARRAY[0..50] OF TON;//气缸工位

END_VAR

INX.T0[0](IN:=%IX0.0,PT:=T#0.01S);//急停按钮
INX.T0[1](IN:=%IX0.1,PT:=T#0.01S);//手自动切换按钮
INX.T0[2](IN:=%IX0.2,PT:=T#0.01S);//启动按钮
INX.T0[3](IN:=%IX0.3,PT:=T#0.01S);//停止按钮
INX.T0[4](IN:=%IX0.4,PT:=T#0.01S);//暂停按钮
INX.T0[5](IN:=%IX0.5,PT:=T#0.01S);//报警复位
INX.T0[6](IN:=%IX0.6,PT:=T#0.01S);//系统复位
INX.T0[7](IN:=%IX0.7,PT:=T#0.01S);//预留

T10[1](IN:=TiP.CYLOUT[1].xHomeOut,PT:=T#3S,Q=>INX.CylHP[1]);//左升降缸上位
T11[1](IN:=TiP.CYLOUT[1].xWorkOut,PT:=T#3S,Q=>INX.CylWP[1]);//左升降缸下位
T10[2](IN:=TiP.CYLOUT[2].xHomeOut,PT:=T#3S,Q=>INX.CylHP[2]);//右升降缸上位
T11[2](IN:=TiP.CYLOUT[2].xWorkOut,PT:=T#0.01S,Q=>INX.CylWP[2]);//右升降缸下位
T10[3](IN:=TiP.CYLOUT[3].xHomeOut,PT:=T#1.5S,Q=>INX.CylHP[3]);//左升降真空破
T11[3](IN:=TiP.CYLOUT[3].xWorkOut,PT:=T#2S,Q=>INX.CylWP[3]);//左升降真空吸
T10[4](IN:=TiP.CYLOUT[4].xHomeOut,PT:=T#1.5S,Q=>INX.CylHP[4]);//右升降真空破
T11[4](IN:=TiP.CYLOUT[4].xWorkOut,PT:=T#2S,Q=>INX.CylWP[4]);//右升降真空吸

T10[5](IN:=TiP.CYLOUT[5].xHomeOut,PT:=T#1.5S,Q=>INX.CylHP[5]);;//移栽左真空破
T11[5](IN:=TiP.CYLOUT[5].xWorkOut,PT:=T#2S,Q=>INX.CylWP[5]);//移栽左真空吸
T10[6](IN:=TiP.CYLOUT[6].xHomeOut,PT:=T#1.5S,Q=>INX.CylHP[6]);//移栽右真空破
T11[6](IN:=TiP.CYLOUT[6].xHomeOut,PT:=T#2S,Q=>INX.CylWP[6]);//移栽右真空吸
T10[7](IN:=%IX1.0,PT:=T#1.5S,Q=>INX.CylHP[7]);;//
T11[7](IN:=%IX1.2,PT:=T#2S,Q=>INX.CylWP[7]);//
T10[8](IN:=%IX1.1,PT:=T#1.5S,Q=>INX.CylHP[8]);//
T11[8](IN:=%IX1.3,PT:=T#2S,Q=>INX.CylWP[8]);//

T10[9](IN:=%IX1.0,PT:=T#1.5S,Q=>INX.CylHP[9]);;//
T11[9](IN:=%IX1.2,PT:=T#2S,Q=>INX.CylWP[9]);//
T10[10](IN:=%IX1.1,PT:=T#1.5S,Q=>INX.CylHP[10]);//
T11[10](IN:=%IX1.3,PT:=T#2S,Q=>INX.CylWP[10]);//



