--GCD, 模块
local function Save()
    return WoWToolsSave['Plus_Cursor']
end

local GCDFrame


--随机GCD，图片
local function set_GCD_Texture()
    local index= Save().randomTexture and random(1, #Save().GCDTexture) or Save().gcdTextureIndex
    GCDFrame.cooldown:SetSwipeTexture(Save().GCDTexture[index] or WoWTools_CursorMixin.DefaultGCDTexture)
end


--设置,GCD,位置
local gcdSize, gcdX, gcdY
local function Set_Point()
    local x, y = GetCursorPosition()
    GCDFrame:SetPoint("BOTTOMLEFT", x-gcdSize+gcdX,  y-gcdSize+gcdY)
end















local function GCD_Settings(isTest)
    if Save().disabledGCD then
        if GCDFrame then
            GCDFrame:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
            GCDFrame:SetShown(false)
        end
        return
    end

    gcdSize, gcdX, gcdY= Save().gcdSize, Save().gcdX, Save().gcdY

    GCDFrame:SetSize(gcdSize*2, gcdSize*2)

    set_GCD_Texture()

    GCDFrame.cooldown:SetSwipeColor(WoWTools_CursorMixin.Color.r, WoWTools_CursorMixin.Color.g, WoWTools_CursorMixin.Color.b, WoWTools_CursorMixin.Color.a)

    if Save().randomTexture then
        GCDFrame:SetScript('OnHide', function()
            set_GCD_Texture()
        end)
    else
        GCDFrame:SetScript('OnHide', nil)
    end

    GCDFrame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    GCDFrame:SetAlpha(Save().gcdAlpha)

    GCDFrame.cooldown:SetReverse(Save().gcdReverse)--控制冷却动画的方向
    GCDFrame.cooldown:SetDrawBling(Save().gcdDrawBling)--闪光

    if isTest then
        GCDFrame:SetShown(false)
        GCDFrame.cooldown:Clear()
        GCDFrame.cooldown:SetCooldown(GetTime(), 1.171)
        GCDFrame:SetShown(true)
    end
end












--GCD, 初始化
local function Init()
    if Save().disabledGCD then
        return
    end

    GCDFrame= CreateFrame('Frame', 'WoWToolsGCDFrame')
    GCDFrame:SetFrameStrata("TOOLTIP")

    GCDFrame.cooldown= CreateFrame("Cooldown", nil, GCDFrame, 'CooldownFrameTemplate')
    GCDFrame.cooldown:SetHideCountdownNumbers(true)--隐藏数字
    GCDFrame.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    GCDFrame.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
    GCDFrame.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
    GCDFrame:Hide()

    GCDFrame:SetScript('OnEvent', function(self)
        local data= C_Spell.GetSpellCooldown(61304)

        if not data then
            return
        end

        if data.isEnabled and data.startTime and data.startTime > 0 and data.duration and data.duration > 0 then
            self.cooldown:SetCooldown(data.startTime, data.duration, data.modRate)
            self:SetShown(true)
        else
            self:SetShown(false)
        end
    end)

    GCDFrame:SetScript('OnShow', function()
        Set_Point()
    end)

    GCDFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 0.01) + elapsed
        if self.elapsed>0.01 then
            self.elapsed=0
            Set_Point()
        end
    end)

    GCD_Settings()--设置 GCD

    Init=function(isTest2)
        GCD_Settings(isTest2)
    end
end













--设置 GCD
function WoWTools_CursorMixin:GCD_Settings(isTest)
    Init(isTest)
end
