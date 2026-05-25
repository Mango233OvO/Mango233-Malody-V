--Mango233's Skin Lua
--Lua by Mango233_QwQ (https://m.mugzone.net/accounts/user/1236961)
function Init()
    --^^^^^ 皮肤初始化时被调用 ^^^^^
    --====== 全局变量 ======
    rate = Game:PlayMeta("speed") --Malody V 6.5.2引入的API 用于获取玩家使用的Mod 此处用于获取谱面播放速度

    --====== 偏移条初始化 ======
    offsetBar = Module:Find("offset bar")
    offset_bast = Module:Find("offset bast")
    offset_cool = Module:Find("offset cool")
    offset_good = Module:Find("offset good")
    offset_miss = Module:Find("offset miss")
    offset_T = Module:Find("offset T")

    --====== 谱面播放倒计时初始化 ======
    startTime = Game:StartTime()
    countdownText = Module:Find("StartTime")
    countdownText.Alpha = 0
    countdownDoAlpha = false
    
    --====== 偏移条玩家设置 ======
    offset_switch = Module:GetBool("偏移指示器开关")
    if not offset_switch then --如果玩家关闭偏移条的话则将"offset t"和"offset bar"透明度设置为"0"
        offset_T.Alpha = 0
        offsetBar.Alpha = 0
    end

    offset_shadows_time_player = tonumber(Module:GetString("偏移指示器阴影存活时间(ms)")) or 1500 --如果玩家键入参数错误则设置默认值1500
    offset_T_time = tonumber(Module:GetString("偏移指示器指针移动速度(ms)")) or 500 --如果玩家键入参数错误则设置默认值500

    --====== 组件动效初始化 ======
    judge_ui = Module:Find("Judge")
    judge_ui.Alpha = 0

    --====== 轨道缩放以及屏幕比例适配 ======
    local scene_scale = Game:SceneScale() --获取轨道缩放
    local width = Game:Width() --获取游戏窗口宽度
    if (width >= 1680) then
        ratio_width = 1
    else
        ratio_width = width / 1680
    end

    local True_Time_1 = Module:Find("time")
    local True_Time_2 = Module:Find("time-p")
    local True_HP_1 = Module:Find("hp")
    local True_HP_2 = Module:Find("hp-p")
    local True_Name = Module:Find("Player Name")
    local True_Score = Module:Find("Score")
    local True_Acc = Module:Find("Acc")
    local True_Png = Module:Find("lh")

    True_Time_1.X = -840 * scene_scale * ratio_width - 13
    True_Time_2.X = True_Time_1.X
    True_HP_1.X = -True_Time_1.X
    True_HP_2.X = True_HP_1.X
    True_Name.X = -True_Time_1.X + 5
    True_Score.X = True_Name.X
    True_Acc.X = True_Name.X
    True_Png.X = True_Name.X + 312

    --====== 动画时间统一定义 ======
    TIME = {  
    offset_shadows = math.floor(offset_shadows_time_player * rate),
    offset_T = math.floor(offset_T_time * rate),
    Judge_Alpha = math.floor(600 * rate),
    Judge_MoveY = math.floor(100 * rate),
    countdownText_time = math.floor(1900 * rate)
    }

    --====== 标题原文与艺术家原文修复 ======
    local Title = Module:Find("Org Title")
    local Art = Module:Find("Org Art.")
    local fixTitie = Game:ChartInfo("Title") or "[ERROR]Missing data!"
    local fixArt = Game:ChartInfo("Artist") or "[ERROR]Missing data!"

    if Title.Text == "" then
        Title.Text = fixTitie
    end
    if Art.Text == "" then
        Art.Text = fixArt
    end
    --当Meta中缺少标题原文与艺术家原文时自动调用歌曲名与艺术家添加至左下角(若连歌曲名与艺术家都未填写的话则显示[ERROR]Missing data!)

end

function Update()
    --^^^^^ 每一帧调用。函数为空时删除函数 ^^^^^^
    --====== 谱面播放倒计时函数设置 ======
    local currentTime = Game:Time() --获取当前时间
    local remaining = startTime - currentTime --计算剩余时间

    --====== 谱面播放倒计时 ======
    if remaining > 0 then
        if not countdownDoAlpha then
            countdownText.Alpha = 100
        end
        local seconds = remaining / 1000 / rate
        countdownText.Text = string.format("%.1fs", seconds)
        if remaining <= 1900 and not countdownDoAlpha then
            countdownDoAlpha = true
            countdownText:DoAlpha({start=currentTime,finish=currentTime+TIME.countdownText_time,from=100,to=0})
        end
    elseif remaining < 0 then
        countdownText.Alpha = 0
        countdownDoAlpha = false
    end

end

function OnHit()
    --^^^^^ 玩家击打时调用。函数为空时删除函数 在Composer中不会被调用 ^^^^^
    --====== 偏移条设置 ======
    local time = Game:Time()
    local hitEvent = Game:HitEvent()
    local judge = hitEvent:JudgeResult()
    local Offset = hitEvent:Offset()

    --====== 偏移条 ======
    if offset_switch then
        if judge == 1 then
            local offset_bast_shadows = Module:Shadow(offset_bast,TIME.offset_shadows) --创建影子且设定存活时间为"offset_shadows"(默认1500ms)
            offset_bast_shadows.X = -Offset --使影子的x坐标位置等于击打偏移
            offset_bast_shadows:DoAlpha({start=time,finish=time+TIME.offset_shadows,from=100,to=0}) --设置影子的存活时间以及渐入渐出效果
        end
        if judge == 2 then
            local offset_cool_shadows = Module:Shadow(offset_cool,TIME.offset_shadows)
            offset_cool_shadows.X = -Offset
            offset_cool_shadows:DoAlpha({start=time,finish=time+TIME.offset_shadows,from=100,to=0})
        end
        if judge == 3 then
            local offset_good_shadows = Module:Shadow(offset_good,TIME.offset_shadows)
            offset_good_shadows.X = -Offset
            offset_good_shadows:DoAlpha({start=time,finish=time+TIME.offset_shadows,from=100,to=0})
        end
        if judge == 4 then
            local offset_miss_shadows = Module:Shadow(offset_miss,TIME.offset_shadows)
            offset_miss_shadows.X = -Offset
            offset_miss_shadows:DoAlpha({start=time,finish=time+TIME.offset_shadows,from=100,to=0})
        end
        if judge >=1 and judge <= 4 then
            offset_T:DoMoveX({start=time,finish=time+TIME.offset_T,from=offset_T.X,to=-Offset}) --瞬时击打偏移位置显示
        end
    end

    --====== 组件动效 ======
    if judge >=1 and judge <= 4 then
        judge_ui:DoAlpha({start=time,finish=time+TIME.Judge_Alpha,from=100,to=0})
        judge_ui:DoMoveY({start=time,finish=time+TIME.Judge_MoveY,from=240,to=245,ease=2})
    end

end
