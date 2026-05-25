--Mango233's Skin Lua
--Lua by Mango233_QwQ (https://m.mugzone.net/accounts/user/1236961)
function Init()
    --^^^^^ 皮肤初始化时被调用 ^^^^^
    --====== 全局变量 ======
    Rate = Game:PlayMeta("speed") --Malody V 6.5.2引入的API 用于获取玩家使用的Mod 此处用于获取谱面播放速度

    --====== 偏移条初始化 ======
    OffsetBar = Module:Find("offset bar")
    OffsetBast = Module:Find("offset bast")
    OffsetCool = Module:Find("offset cool")
    OffsetGood = Module:Find("offset good")
    OffsetMiss = Module:Find("offset miss")
    OffsetT = Module:Find("offset T")

    --====== 谱面播放倒计时初始化 ======
    StartTime = Game:StartTime()
    CountdownText = Module:Find("StartTime")
    CountdownText.Alpha = 0
    CountdownDoAlpha = false
    
    --====== 偏移条玩家设置 ======
    OffsetSwitch = Module:GetBool("偏移指示器开关")
    if not OffsetSwitch then --如果玩家关闭偏移条的话则将"offset t"和"offset bar"透明度设置为"0"
        OffsetBar.Alpha = 0
        OffsetT.Alpha = 0
    end

    OffsetShadowsTimePlayer = tonumber(Module:GetString("偏移指示器阴影存活时间(ms)")) or 1500 --如果玩家键入参数错误则设置默认值1500
    OffsetTTime = tonumber(Module:GetString("偏移指示器指针移动速度(ms)")) or 500              --如果玩家键入参数错误则设置默认值500

    --====== 组件动效初始化 ======
    JudgeUI = Module:Find("Judge")
    JudgeUI.Alpha = 0

    --====== 轨道缩放以及屏幕比例适配 ======
    local sceneScale = Game:SceneScale() --获取轨道缩放
    local width = Game:Width()            --获取游戏窗口宽度
    if (width >= 1680) then
        ratioWidth = 1
    else
        ratioWidth = width / 1680
    end

    local timePos = Module:Find("time")
    local timePosFull = Module:Find("time-p")
    local hpPos = Module:Find("hp")
    local hpPosFull = Module:Find("hp-p")
    local namePos = Module:Find("Player Name")
    local scorePos = Module:Find("Score")
    local accPos = Module:Find("Acc")
    local lhPos = Module:Find("lh")

    timePos.X = -840 * sceneScale * ratioWidth - 13
    timePosFull.X = timePos.X
    hpPos.X = -timePos.X
    hpPosFull.X = hpPos.X
    namePos.X = -timePos.X + 5
    scorePos.X = namePos.X
    accPos.X = namePos.X
    lhPos.X = namePos.X + 312

    --====== 动画时间统一定义 ======
    TIME = {  
    OffsetShadows = math.floor(OffsetShadowsTimePlayer * Rate),
    OffsetT = math.floor(OffsetTTime * Rate),
    JudgeAlpha = math.floor(600 * Rate),
    JudgeMoveY = math.floor(100 * Rate),
    CountdownText = math.floor(1900 * Rate)
    }

    --====== 标题原文与艺术家原文修复 ======
    local title = Module:Find("Org Title")
    local art = Module:Find("Org Art.")
    local fixTitle = Game:ChartInfo("Title") or "[ERROR]Missing data!"
    local fixArt = Game:ChartInfo("Artist") or "[ERROR]Missing data!"

    if title.Text == "" then
        title.Text = fixTitle
    end
    if art.Text == "" then
        art.Text = fixArt
    end
    --当Meta中缺少标题原文与艺术家原文时自动调用歌曲名与艺术家添加至左下角(若连歌曲名与艺术家都未填写的话则显示[ERROR]Missing data!)

end

function Update()
    --^^^^^ 每一帧调用。函数为空时删除函数 ^^^^^^
    --====== 谱面播放倒计时函数设置 ======
    local currentTime = Game:Time()           --获取当前时间
    local remaining = StartTime - currentTime --计算剩余时间

    --====== 谱面播放倒计时 ======
    if remaining > 0 then
        if remaining > 1900 and CountdownDoAlpha then
            CountdownDoAlpha = false
        end
        if not CountdownDoAlpha then
            CountdownText.Alpha = 100
        end
        local seconds = remaining / 1000 / Rate
        CountdownText.Text = string.format("%.1fs", seconds)
        if remaining <= 1900 and not CountdownDoAlpha then
            CountdownDoAlpha = true
            CountdownText:DoAlpha({start=currentTime,finish=currentTime+TIME.CountdownText,from=100,to=0})
        end
    elseif remaining < 0 then
        CountdownText.Alpha = 0
        CountdownDoAlpha = false
    end

end

function OnHit()
    --^^^^^ 玩家击打时调用。函数为空时删除函数 在Composer中不会被调用 ^^^^^
    --====== 偏移条设置 ======
    local time = Game:Time()
    local hitEvent = Game:HitEvent()
    local judge = hitEvent:JudgeResult()
    local offset = hitEvent:Offset()

    --====== 偏移条 ======
    if OffsetSwitch then
        if judge == 1 then
            local offsetBastShadows = Module:Shadow(OffsetBast,TIME.OffsetShadows) --创建影子且设定存活时间为"OffsetShadows"(默认1500ms)
            offsetBastShadows.X = -offset --使影子的x坐标位置等于击打偏移
            offsetBastShadows:DoAlpha({start=time,finish=time+TIME.OffsetShadows,from=100,to=0}) --设置影子的存活时间以及渐入渐出效果
        elseif judge == 2 then
            local offsetCoolShadows = Module:Shadow(OffsetCool,TIME.OffsetShadows)
            offsetCoolShadows.X = -offset
            offsetCoolShadows:DoAlpha({start=time,finish=time+TIME.OffsetShadows,from=100,to=0})
        elseif judge == 3 then
            local offsetGoodShadows = Module:Shadow(OffsetGood,TIME.OffsetShadows)
            offsetGoodShadows.X = -offset
            offsetGoodShadows:DoAlpha({start=time,finish=time+TIME.OffsetShadows,from=100,to=0})
        elseif judge == 4 then
            local offsetMissShadows = Module:Shadow(OffsetMiss,TIME.OffsetShadows)
            offsetMissShadows.X = -offset
            offsetMissShadows:DoAlpha({start=time,finish=time+TIME.OffsetShadows,from=100,to=0})
        end
        if judge >=1 and judge <= 4 then
            OffsetT:DoMoveX({start=time,finish=time+TIME.OffsetT,from=OffsetT.X,to=-offset}) --瞬时击打偏移位置显示
        end
    end

    --====== 组件动效 ======
    if judge >=1 and judge <= 4 then
        JudgeUI:DoAlpha({start=time,finish=time+TIME.JudgeAlpha,from=100,to=0})
        JudgeUI:DoMoveY({start=time,finish=time+TIME.JudgeMoveY,from=240,to=245,ease=2})
    end

end
