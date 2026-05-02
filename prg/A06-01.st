PROGRAM A06_01
VAR
    // 系统状态
    流程 : INT := 0;
    启动 : BOOL;
    停止 : BOOL;
    复位 : BOOL;
    自动运行 : BOOL;
    原点完成 : BOOL;
    
    // 码垛参数
    托盘列数 : INT := 8;  // 8列
    托盘行数 : INT := 8;  // 8行
    当前列 : INT := 0;
    当前行 : INT := 0;
    当前层 : INT := 0;
    总数量 : INT := 64;   // 8*8=64个
    已完成数量 : INT := 0;
    
    // 位置参数
    取料位X : REAL := 100.0;   // 固定取料位置X
    取料位Y : REAL := 0.0;     // 固定取料位置Y
    取料位Z : REAL := 50.0;    // 取料高度
    安全高度 : REAL := 200.0;  // 安全抬升高度
    
    // 托盘参数
    托盘起点X : REAL := 300.0;  // 托盘左下角起点X
    托盘起点Y : REAL := 100.0;  // 托盘左下角起点Y
    托盘起点Z : REAL := 0.0;    // 托盘基准面Z
    工件间距X : REAL := 50.0;   // X方向间距
    工件间距Y : REAL := 50.0;   // Y方向间距
    工件高度 : REAL := 20.0;    // 单个工件高度
    
    // 真空控制
    真空请求 : BOOL;
    真空到位 : BOOL;
    真空压力 : REAL;
    真空检测阈值 : REAL := -60.0;  // kPa, 负压阈值
    吸取延时 : TON;
    释放延时 : TON;
    
    // 轴控制目标位置
    目标位置X : REAL;
    目标位置Y : REAL;
    目标位置Z : REAL;
    
    // 计算变量
    计算位置 : BOOL;
    蛇形排列 : BOOL := TRUE;  // TRUE=蛇形，FALSE=单向
    
END_VAR

// ============================================================================
// 主状态机
// ============================================================================
CASE 流程 OF
    0: // 待机状态
        自动运行 := FALSE;
        IF 启动 THEN
            流程 := 10;
        END_IF;
        
    10: // 回原点
        // 检查三轴是否都完成原点回归
        IF Tip.AXOUT[1].SVOUT.xHomeOK AND Tip.AXOUT[2].SVOUT.xHomeOK AND Tip.AXOUT[3].SVOUT.xHomeOK THEN
            原点完成 := TRUE;
            流程 := 20;
        ELSE
            // 执行回原点命令
            Axis.Cmd[1].Autoin.xHome := TRUE;  // X轴回原点
            Axis.Cmd[2].Autoin.xHome := TRUE;  // Y轴回原点
            Axis.Cmd[3].Autoin.xHome := TRUE;  // Z轴回原点
        END_IF;
        
    20: // 计算下一个放置位置
        计算位置 := TRUE;
        
        // 判断是否完成一托盘
        IF 已完成数量 >= 总数量 THEN
            流程 := 100; // 完成，进入结束状态
        ELSE
            // 计算当前行列
            当前列 := 已完成数量 MOD 托盘列数;
            当前行 := 已完成数量 / 托盘列数;
            
            // 蛇形排列逻辑
            IF 蛇形排列 THEN
                IF (当前行 MOD 2) = 0 THEN
                    // 偶数行：从左到右
                    目标位置X := 托盘起点X + (REAL(当前列) * 工件间距X);
                ELSE
                    // 奇数行：从右到左
                    目标位置X := 托盘起点X + (REAL(托盘列数 - 1 - 当前列) * 工件间距X);
                END_IF;
            ELSE
                // 单向排列：始终从左到右
                目标位置X := 托盘起点X + (REAL(当前列) * 工件间距X);
            END_IF;
            
            目标位置Y := 托盘起点Y + (REAL(当前行) * 工件间距Y);
            目标位置Z := 托盘起点Z + (REAL(当前层) * 工件高度);
            
            计算位置 := FALSE;
            流程 := 30;
        END_IF;
        
    30: // 移动到取料位置上方（安全高度）
        目标位置X := 取料位X;
        目标位置Y := 取料位Y;
        目标位置Z := 安全高度;
        
        IF NOT Tip.AXOUT[1].SVOUT.xAbsOK OR NOT Tip.AXOUT[2].SVOUT.xAbsOK OR NOT Tip.AXOUT[3].SVOUT.xAbsOK THEN
            Axis.Cmd[1].Autoin.xAbs := TRUE;
            Axis.Cmd[1].rAposX := 目标位置X;
            Axis.Cmd[2].Autoin.xAbs := TRUE;
            Axis.Cmd[2].rAposX := 目标位置Y;
            Axis.Cmd[3].Autoin.xAbs := TRUE;
            Axis.Cmd[3].rAposX := 目标位置Z;
        ELSE
            流程 := 40;
        END_IF;
        
    40: // 下降到取料位置
        目标位置Z := 取料位Z;
        
        IF NOT Tip.AXOUT[3].SVOUT.xAbsOK THEN
            Axis.Cmd[3].Autoin.xAbs := TRUE;
            Axis.Cmd[3].rAposX := 目标位置Z;
        ELSE
            流程 := 50;
        END_IF;
        
    50: // 开启真空吸取
        真空请求 := TRUE;
        吸取延时(IN := TRUE, PT := T#500MS);  // 500ms延时确保吸取稳定
        
        IF 吸取延时.Q AND 真空压力 <= 真空检测阈值 THEN
            真空到位 := TRUE;
            吸取延时(IN := FALSE);
            流程 := 60;
        ELSIF 吸取延时.Q AND 真空压力 > 真空检测阈值 THEN
            // 真空检测失败报警
            吸取延时(IN := FALSE);
            流程 := 200; // 故障处理
        END_IF;
        
    60: // 抬升到安全高度
        目标位置Z := 安全高度;
        
        IF NOT Tip.AXOUT[3].SVOUT.xAbsOK THEN
            Axis.Cmd[3].Autoin.xAbs := TRUE;
            Axis.Cmd[3].rAposX := 目标位置Z;
        ELSE
            流程 := 70;
        END_IF;
        
    70: // 移动到放料位置上方（安全高度）
        // 目标位置已在步骤20计算好
        目标位置Z := 安全高度;
        
        IF NOT Tip.AXOUT[1].SVOUT.xAbsOK OR NOT Tip.AXOUT[2].SVOUT.xAbsOK OR NOT Tip.AXOUT[3].SVOUT.xAbsOK THEN
            Axis.Cmd[1].Autoin.xAbs := TRUE;
            Axis.Cmd[1].rAposX := 目标位置X;
            Axis.Cmd[2].Autoin.xAbs := TRUE;
            Axis.Cmd[2].rAposX := 目标位置Y;
            Axis.Cmd[3].Autoin.xAbs := TRUE;
            Axis.Cmd[3].rAposX := 目标位置Z;
        ELSE
            流程 := 80;
        END_IF;
        
    80: // 下降到放料位置
        // 目标位置Z已在步骤20计算好（包含层高）
        
        IF NOT Tip.AXOUT[3].SVOUT.xAbsOK THEN
            Axis.Cmd[3].Autoin.xAbs := TRUE;
            Axis.Cmd[3].rAposX := 目标位置Z;
        ELSE
            流程 := 90;
        END_IF;
        
    90: // 关闭真空释放工件
        真空请求 := FALSE;
        释放延时(IN := TRUE, PT := T#300MS);  // 300ms延时确保释放完全
        
        IF 释放延时.Q THEN
            释放延时(IN := FALSE);
            已完成数量 := 已完成数量 + 1;
            
            // 更新层数
            IF (已完成数量 > 0) AND (已完成数量 MOD 总数量) = 0 THEN
                当前层 := 当前层 + 1;
            END_IF;
            
            流程 := 20; // 返回计算下一个位置
        END_IF;
        
    100: // 完成状态
        自动运行 := FALSE;
        // 等待复位或新的启动命令
        IF 复位 THEN
            已完成数量 := 0;
            当前层 := 0;
            流程 := 0;
        END_IF;
        
    200: // 故障处理
        自动运行 := FALSE;
        真空请求 := FALSE;
        IF 复位 THEN
            流程 := 0;
        END_IF;
        
END_CASE

// ============================================================================
// 停止处理
// ============================================================================
IF 停止 THEN
    自动运行 := FALSE;
    真空请求 := FALSE;
    流程 := 0;
END_IF;

// ============================================================================
// 轴使能输出（始终使能）
// ============================================================================
Axis.Cmd[1].xEnable := TRUE;  // X轴使能
Axis.Cmd[2].xEnable := TRUE;  // Y轴使能
Axis.Cmd[3].xEnable := TRUE;  // Z轴使能

// ============================================================================
// 真空输出映射
// ============================================================================
// 假设真空电磁阀连接到气缸输出口或专用输出口
// Cyl.cmd[4].xOut := 真空请求;  // 根据实际硬件配置调整

END_PROGRAM
