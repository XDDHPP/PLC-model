# PLC-Model 项目文档

## 项目概述

本项目是一个基于 Structured Text (ST) 语言的 PLC 控制程序模型，采用 TwinCAT3 开发环境。主要用于自动化设备的控制系统，包含气缸控制、伺服轴控、电机控制、模拟量处理等功能。

---

## 目录结构

```
PLC-model/
├── dut/                    # 数据类型定义 (User Defined Types)
│   ├── axis/              # 伺服轴相关数据类型
│   │   ├── ST_AxHmi.udt       # HMI 轴数据
│   │   ├── ST_AxisCtrl.udt   # 轴控制数据
│   │   ├── ST_AxisOUT.udt    # 轴输出数据
│   │   ├── ST_SVdata.udt     # 伺服定位数据
│   │   ├── ST_SVEna.udt      # 伺服使能数据
│   │   ├── ST_SVIN.udt       # 伺服输入数据
│   │   ├── ST_SVOUT.udt      # 伺服输出数据
│   │   ├── ST_SVPAR.udt      # 伺服参数数据
│   │   ├── ST_SVPARLR.udt    # 伺服参数(LREAL类型)
│   │   └── ST_SVSTATE.udt    # 伺服状态数据
│   ├── cyl/               # 气缸相关数据类型
│   │   ├── ST_CylAuto.udt    # 气缸自动控制
│   │   ├── ST_CylHMI.udt     # 气缸HMI数据
│   │   ├── ST_CylRdy.udt     # 气缸就绪数据
│   │   └── ST_CYLTiP.udt     # 气缸提示反馈数据
│   ├── motor/            # 电机相关数据类型
│   │   ├── ST_MotorCtrl.udt  # 电机控制数据
│   │   ├── ST_MotorHMI.udt  # 电机HMI数据
│   │   ├── ST_MotorRdy.udt   # 电机就绪数据
│   │   └── ST_MotorTip.udt   # 电机提示反馈数据
│   └── sys/              # 系统相关数据类型
│       ├── ST_bit16.udt      # 16位状态标志
│       ├── ST_button.udt     # 按钮数据结构
│       ├── ST_RCP.udt        # 配方数据
│       ├── ST_Report.udt     # 报告/产量数据
│       ├── ST_SYS.udt        # 系统状态
│       └── ST_Warn.udt       # 报警信息
├── FBblock/              # 功能块 (Function Blocks)
│   ├── FB_AxisCtrl.st        # 伺服轴控制功能块
│   ├── FB_Clock.st           # 时钟/脉冲发生器
│   ├── FB_Fliter.st          # 模拟量滤波功能块
│   ├── FB_System.st          # 系统控制功能块
│   ├── Fb_cylctrl.st         # 气缸控制功能块
│   ├── Fb_Motor.ST           # 电机控制功能块
│   ├── FC_AnalogIN.st        # 模拟量输入转换
│   └── FC_AnalogOut.st       # 模拟量输出转换
├── GVL/                  # 全局变量列表 (Global Variable Lists)
│   ├── flow/             # 流程控制变量
│   │   ├── Axis.tcgvl        # 轴变量
│   │   ├── Cyl.tcgvl         # 气缸变量
│   │   └── Motor.tcgvl       # 电机变量
│   ├── hmi/              # HMI相关变量
│   │   ├── AlmTip.tcgvl      # 报警提示变量
│   │   ├── GRCP.tcgvl        # 配方变量
│   │   ├── HMI.tcgvl         # HMI变量
│   │   ├── Sys.tcgvl         # 系统变量
│   │   └── Tip.tcgvl         # 提示变量
│   └── inx.tcgvl            # 输入配置变量
└── prg/                  # 程序 (Programs)
    ├── A01.st               # 输入信号延时滤波映射
    ├── A02.st               # 上电数据初始化
    ├── A03.st               # 系统状态与报警处理
    ├── A04.st               # 手动控制 (空，待完善)
    ├── A05.st               # 设备整体复位 (空，待完善)
    ├── A06.st               # 设备自动运行流程 (CASE状态机)
    ├── A07.st               # 气缸功能块调用 (6组气缸)
    ├── A08.st               # 轴功能块调用 (X/Y/Z/R四轴)
    ├── A09.st               # 电机功能块调用 (2个电机)
    ├── A14.st               # 报警汇总与安全提示
    └── A15.st               # 配方管理 (配方选择/设定)
```

---

## 功能块说明

### FB_AxisCtrl - 伺服轴控制功能块

伺服轴控制是本系统的核心功能块，负责伺服电机的点动、回原、定位等控制。

**主要功能：**
- 手动/自动模式切换
- 伺服使能控制 (MC_Power)
- 点动控制 (MC_Jog) - 正/负方向
- 回原控制 (MC_Home)
- 绝对定位 (MC_MoveAbsolute)
- 相对定位 (MC_MoveRelative)
- 暂停/急停/复位控制
- 手自动状态不一致锁机保护

**安全特性：**
- 每次模式切换时检查手自动状态一致性
- 安全信号丢失时立即停止轴运动
- 急停信号触发时执行快速停止

**TwinCAT MC 指令信号行为（重要）：**
- MC 功能块（MC_MoveAbsolute / MC_Home / MC_Jog 等）的反馈信号（Done、Busy、Error 等）**跟随 Execute 实时变化**：
  - `Execute=TRUE` 时，Busy/Done 根据运动状态实时更新
  - `Execute=FALSE` 时，Done 立即变 FALSE（**不锁存**）
- 本 FB 内部通过 `xAbsAct → TAbs(10ms) → vSvin.xAbs → MC.Execute` 链路驱动
- 当 `vSvout.xAbsOK=TRUE` 时，复位逻辑将 `xAbsAct:=FALSE`，导致 Execute 归 FALSE，Done 随之自动归 FALSE
- 因此流程侧 **不需要** 手动清除 `Autoin.xAbs`，`xAbsOK` 会随 Execute 自动复位，下一步的 `IF NOT xAbsOK THEN` 条件自然成立

### Fb_cylctrl - 气缸控制功能块

气缸控制功能块管理气动执行元件，支持手动和自动两种控制模式。

**主要功能：**
- 气缸回原位控制 (iMode=1)
- 气缸到工位控制 (iMode=2)
- 超时报警检测
- 传感器双信号检测 (防止全亮/全灭故障)

**控制模式：**
| 模式 | 描述 |
|------|------|
| 1 | 报警不断气 |
| 2 | 暂停断气 |
| 3 | 仅急停断气 |

**安全特性：**
- 安全信号丢失时强制停止
- 自动锁机防止手动/自动状态不一致

### Fb_Motor - 电机控制功能块

电机控制功能块用于管理 DC/步进电机的运动。

**主要功能：**
- 手动点动控制 (前进/后退)
- 联动控制
- 自动运行控制
- 到位检测

### FB_System - 系统控制功能块

系统控制功能块是整个设备状态机的核心，管理设备运行状态。

**设备状态流程：**
```
待机 (xIdle) → 回原 (xHoming) → 回原完成 (xHomeOK) → 自动 (xAutoStart)
```

**主要状态：**
| 状态 | 描述 |
|------|------|
| xIdle | 设备待机中 |
| xManulEna | 手动允许 |
| xHoming | 设备回原中 |
| xHomeOK | 回原OK标记 |
| xAutoEna | 自动状态 |
| xAutoStart | 自动运行中 |
| xAutoHalt | 自动暂停中 |
| xAlming | 报警中 |

### FB_Clock - 脉冲发生器

生成固定周期的脉冲信号，用于PLC内部定时。

**输出脉冲：**
- 10ms脉冲
- 100ms脉冲
- 1s脉冲

### FB_Fliter - 模拟量滤波

对模拟量输入信号进行多级滤波处理，减少信号波动。

**滤波级别：** 0-10级 (可配置)

**算法：** 滑动窗口平均值滤波，每级采集10个样本求平均

### FC_AnalogIN - 模拟量输入转换

将模拟量原始值转换为实际工程值。

```
工程值 = (模拟量 / 比率) + 偏置
```

### FC_AnalogOut - 模拟量输出转换

将工程值转换为模拟量输出值。

---

## 数据类型说明

### ST_SYS - 系统状态结构体

```st
TYPE ST_SYS :
STRUCT
    xEstop:BOOL;      // 急停按钮
    xStop:BOOL;       // 停止按钮
    xHalt:BOOL;       // 暂停按钮
    xStart:BOOL;      // 启动按钮
    xAlmRst:BOOL;     // 报警复位
    xSysRst:BOOL;     // 系统复位
    xPlcOk:BOOL;      // PLC上电OK
    xIdle:BOOL;       // 设备待机中
    xManulEna:BOOL;   // 手动允许
    xAlming:BOOL;     // 报警中
    xHoming:BOOL;     // 设备回原中
    xHomeDone:BOOL;   // 回原完成
    xHomeOK:BOOL;     // 回原OK标记
    xAutoEna:BOOL;    // 自动状态
    xAutoStart:BOOL;  // 自动运行中
    xAutoHalt:BOOL;   // 自动暂停中
    xAutoLock:BOOL;   // 自动锁机
END_STRUCT
END_TYPE
```

### ST_Report - 生产报告结构体

```st
TYPE ST_Report :
STRUCT
    dDayOutput:DINT;   // 日产量
    dDayNG:DINT;       // 日不良品
    dDayOK:DINT;       // 日良品
    dTotalOutput:DINT; // 总产品
    dTotalNG:DINT;     // 总不良品
    dTotalOK:DINT;     // 总良品
    iHour:INT;         // 运行时数
    iMin:INT;          // 运行时分
    iSec:INT;          // 运行时秒
    iCT:INT;           // 设备节拍计数
END_STRUCT
END_TYPE
```

---

## 程序说明

### A01 - 输入信号延时滤波映射

**功能：** 对输入信号进行延时滤波处理

**处理内容：**
- 急停、手自动切换、启动、停止、暂停、报警复位、系统复位等按钮信号 (10ms滤波)
- 气缸原位/工位传感器信号 (不同气缸配置不同延时)
- 真空吸/破信号

### A02 - 上电数据初始化

**功能：** PLC上电时的数据初始化和周期计数

**处理内容：**
- PLC上电OK信号检测 (5秒延时)
- 脉冲信号生成 (10ms/100ms/1s)
- 气缸控制字初始化
- 轴定位编号初始化
- 产品计数 (OK/NG)
- 设备运行时间统计

### A03 - 系统状态与报警处理

**功能：** 系统状态管理和报警汇总

**处理内容：**
- 设备报警字统计 (遍历alm数组)
- 手自动切换安全检测 (Automanul数组)
- 硬件按钮信号映射
- FBSystem功能块调用
- 系统状态指示灯控制

### A06 - 设备自动运行流程

**功能：** 设备自动运行主流程控制 (CASE状态机)

**新增变量：**
| 变量 | 类型 | 用途 |
|------|------|------|
| iStep | INT | 分支位锁存计数器（bit0=轴1完成, bit1=轴2完成） |

**流程步骤：**
| 步骤 | 内容 |
|------|------|
| 10 | 气缸自动升 (1#气缸回原位) |
| 20 | 气缸自动降 (1#气缸到工位) |
| 30 | 气缸自动升 (循环回原位) |
| 40 | 轴去待机位 (5#位置) |
| 60 | 轴去8#位置 |
| 100 | 两轴同时回原（触发步） |
| 105 | 回原完成判断（位锁存，iStep=3→跳110） |
| 110 | 两轴同时定位（触发步） |
| 115 | 定位完成判断（位锁存，iStep=3→跳120） |
| 120 | 继续后续流程 |

**多轴同步模式：** 触发步→等待步 解耦设计，触发后立即跳转，等待步用位锁存 `iStep OR 1/2` 累计完成信号，支持脉冲信号非同时完成的场景。

### A07 - 气缸功能块调用

**功能：** 实例化并调用气缸控制功能块

**控制的6组气缸：**
| 索引 | 气缸名称 | 用途 |
|------|----------|------|
| 1 | 左升降缸 | 升降动作 |
| 2 | 右升降缸/旋转缸 | 前后/旋转动作 |
| 3 | 固定缸 | 固定定位 |
| 4 | 真空吸 | 吸取物料 |
| 5 | 搬运缸 | 物料搬运 |
| 6 | 取料缸 | 取料动作 |

每个气缸报警超时时间设置为5秒，断气模式 iMode=3 (仅急停断气)

### A08 - 轴功能块调用

**功能：** 实例化并调用4轴伺服控制功能块 (X/Y/Z/R)

**轴配置：**
- 1#轴: X轴
- 2#轴: Y轴  
- 3#轴: Z轴
- 4#轴: R轴 (旋转轴)

**功能：**
- 配置各轴安全信号 (xActSafe, xAXread, xJogPsafe, xJogNsafe)
- 配方位置数据换算 (特殊点位10#需要换算)
- 调用FB_AxisCtrl功能块控制每个轴

### A09 - 电机功能块调用

**功能：** 实例化并调用电机控制功能块

**控制的电机：**
- 1#电机
- 2#电机

每个电机配置正反转安全信号和就绪信号。

### A14 - 报警汇总与安全提示

**功能：** 汇总所有报警信号和手自动切换安全提示

**报警汇总：** 将6组气缸的到位超时报警汇总到 alm[0..9]

**手自动安全提示：** 汇总气缸手自动状态不一致提示到 Automanul[0..5]

**操作提示：** 预留设备操作提示数组 tip[0..n] (待根据实际设备填充)

### A15 - 配方管理

**功能：** 配方的选择、设定、保存

**配方操作：**
- 配方选择 (增/减/确认)
- 配方设定 (进入/确认/取消)
- 配方编号范围: 0-50
- 配方选择时预读取当前配方数据
- 配方设定后保存到配方库

**画面切换：**
- 配方选择: 105
- 配方设定: 115

---

## 全局变量说明

### INX (输入配置)

```st
VAR_GLOBAL
    T0[0..7]:TON;           // 按钮输入延时
    CylHP[0..500]:BOOL;     // 气缸原位信号
    CylWP[0..500]:BOOL;     // 气缸工位信号
    Sensor[0..500]:BOOL;    // 传感器信号
END_VAR
```

### Sys (系统变量)

```st
VAR_GLOBAL
    xP_On:BOOL;             // 常通信号
    xP_Frist:BOOL;          // 上电第一次扫描
    xP_Off:BOOL;            // 常断信号
    xP_10ms:BOOL;           // 10ms脉冲
    xP_100ms:BOOL;          // 100ms脉冲
    xP_1s:BOOL;             // 1s脉冲
    State:ST_SYS;           // 系统状态
    Warn:ST_Warn;           // 报警信息
    Report:ST_Report;       // 生产报告
    HmiB:ST_button;         // 触摸屏按钮
    HardB:ST_button;        // 硬件按钮
END_VAR
```

---

## 安全机制

### 手自动切换保护

当设备从自动模式切换到手动模式时，系统会检查当前轴位置/气缸状态是否与自动运行时的目标位置一致。如果不一致，会触发自动锁机 (xAutoLock)，防止在状态不一致的情况下重新启动自动运行。

### 安全信号检测

所有运动控制 (轴点动、气缸动作) 都必须满足安全信号条件：
- 轴点动：需要JogPsafe/JogNsafe信号
- 气缸动作：需要HomeSafe/WorkSafe信号

安全信号丢失时，相关运动立即停止。

### 急停处理

急停信号触发时：
1. 所有轴执行 MC_Stop (快速停止，减速度10000)
2. 所有气缸根据iMode设置决定是否断气
3. 设备状态保持，直到急停复位

---

## 版本信息

- **创建日期:** 2026/05/02
- **开发环境:** TwinCAT3
- **语言:** Structured Text (ST)
