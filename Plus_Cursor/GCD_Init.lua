--GCD, 模块
local function Save()
    return WoWTools_CursorMixin.Save
end




--随机GCD，图片
local function set_GCD_Texture()
    local index= Save().randomTexture and random(1, #Save().GCDTexture) or Save().gcdTextureIndex
    WoWTools_CursorMixin.GCDFrame.cooldown:SetSwipeTexture(Save().GCDTexture[index] or WoWTools_CursorMixin.DefaultGCDTexture)
end


--设置,GCD,位置
local function set_GCD_Frame_Point()
    local x, y = GetCursorPosition()
    WoWTools_CursorMixin.GCDFrame:SetPoint("BOTTOMLEFT", x-Save().gcdSize+Save().gcdX, y-Save().gcdSize+Save().gcdY)
end












--GCD, 初始化
local function Init()
    local Frame= CreateFrame('Frame')
    WoWTools_CursorMixin.GCDFrame= Frame

    Frame:SetFrameStrata("TOOLTIP")

    Frame.cooldown= CreateFrame("Cooldown", nil, Frame, 'CooldownFrameTemplate')
    Frame.cooldown:SetHideCountdownNumbers(true)--隐藏数字
    Frame.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    Frame.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
    Frame.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
    Frame:SetShown(false)

    Frame:SetScript('OnEvent', function(self)
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

    Frame:SetScript('OnShow', set_GCD_Frame_Point)

    Frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 0.01) + elapsed
        if self.elapsed>0.01 then
            self.elapsed=0
            set_GCD_Frame_Point()
        end
    end)

    WoWTools_CursorMixin:GCD_Settings()--设置 GCD
end






--设置 GCD
function WoWTools_CursorMixin:GCD_Settings()
    if not self.GCDFrame then
        return
    end
    self.GCDFrame.cooldown:Clear()
    if Save().disabledGCD then
        self.GCDFrame:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
        self.GCDFrame:SetShown(false)
    else
        self.GCDFrame:SetSize(Save().gcdSize*2, Save().gcdSize*2)
        set_GCD_Texture()
        if not Save().notUseColor then
            self.GCDFrame.cooldown:SetSwipeColor(WoWTools_CursorMixin.Color.r, WoWTools_CursorMixin.Color.g, WoWTools_CursorMixin.Color.b, WoWTools_CursorMixin.Color.a)
        end
        if Save().randomTexture then
            self.GCDFrame:SetScript('OnHide', set_GCD_Texture)
        else
            self.GCDFrame:SetScript('OnHide', nil)
        end
        self.GCDFrame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        self.GCDFrame:SetAlpha(Save().gcdAlpha)
        self.GCDFrame.cooldown:SetReverse(Save().gcdReverse)--控制冷却动画的方向
        self.GCDFrame.cooldown:SetDrawBling(Save().gcdDrawBling)--闪光
    end
end


--显示GCD图片, 提示用
function WoWTools_CursorMixin:ShowGCDTips()
    if self.GCDFrame then
        self.GCDFrame:SetShown(false)
        self:GCD_Settings()
        self.GCDFrame.cooldown:SetCooldown(GetTime(), 1.171)
        self.GCDFrame:SetShown(true)
    end
end



function WoWTools_CursorMixin:Init_GCD()
    Init()
end