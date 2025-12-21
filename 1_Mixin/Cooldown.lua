WoWTools_CooldownMixin={}
--[[
Cooldown.lua
CooldownFrame_Set(self.SpellButton.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled)
CooldownFrame_Clear(self.SpellButton.Cooldown);
CooldownFrame_SetDisplayAsPercentage(self, percentage)
]]





function WoWTools_CooldownMixin:GetText(spellID, itemID)--法术,物品,冷却
    if spellID then
        if not C_Spell.GetOverrideSpell(spellID) then
            return
        end
        local data= C_Spell.GetSpellCooldown(spellID)
        if data then
            if data.duration>0 then
                local t= GetTime()
                while t<data.startTime do
                    t= t+86400
                end
                t= t-data.startTime
                t= data.duration-t
                t= t<0 and 0 or t
                return '|cnWARNING_FONT_COLOR:'..SecondsToTime(t)..'|r'

            elseif data.isEnabled==false then
                return '|cff626262'..(WoWTools_DataMixin.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
            end
        end
    elseif itemID then
        local startTime, duration, enable = C_Item.GetItemCooldown(itemID)
        if duration and duration>0 then
            local t= GetTime()
            while t<startTime do
                t= t+86400
            end
            t= t-startTime
            t= duration-t
            t= t<0 and 0 or t
            if enable==false then
                return '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
            else
                return '|cnWARNING_FONT_COLOR:'..SecondsToTime(t)..'|r'
            end
        end
    end
end



--{item=, spell=, type=, isUnit=true} type=true圆形，false方形
function WoWTools_CooldownMixin:SetFrame(frame, tab)
    if not frame or not tab then
        return
    end

    local item= tab.itemID
    local spellID= tab.spellID
    local type= tab.type
    local unit= tab.unit



    if spellID then
        local data= C_Spell.GetSpellCooldown(spellID)
        if data then-- and not issecretvalue(data) and data.duration>0 then
            self:Setup(frame, data.startTime, data.duration, data.modRate, true, nil, not type)--冷却条
        else
            self:Setup(frame)
        end

    elseif unit then
        local texture, startTime, endTime, duration, channel

        if UnitExists(unit) then
            texture, startTime, endTime= select(3, UnitChannelInfo(unit))

            if not (texture and startTime and endTime) then
                texture, startTime, endTime= select(3, UnitCastingInfo(unit))
            else
                channel= true
            end
            if not issecurevalue(startTime) and not issecurevalue(endTime) and texture and startTime and endTime then
                duration= (endTime - startTime) / 1000
                self:Setup(frame, nil, duration, nil, true, channel, nil,nil)
                return texture
            else
                self:Setup(frame)
            end
        end

    elseif item then
        local startTime, duration = C_Item.GetItemCooldown(item)
        self:Setup(frame, startTime, duration, nil, true, nil, not type)

    elseif frame.Cooldown then
        self:Setup(frame)
    end

end





--CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)

--Cooldown.xml
--StaticPopupTimeoutSec = 60
function WoWTools_CooldownMixin:Setup(frame, start, duration, modRate, HideCountdownNumbers, Reverse, setSwipeTexture, hideDrawBling)--冷却条
    if not frame then
        return
    elseif not duration then
        if frame.Cooldown then
            frame.Cooldown:Clear()
        end
        return
    end
    if not frame.Cooldown then
        frame.Cooldown= CreateFrame("Cooldown", nil, frame, 'CooldownFrameTemplate')
         frame.Cooldown:SetFrameLevel(frame:GetFrameLevel()+5)
        frame.Cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        frame.Cooldown:SetDrawBling(not hideDrawBling)--闪光
        frame.Cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        frame.Cooldown:SetHideCountdownNumbers(HideCountdownNumbers)--隐藏数字
        frame.Cooldown:SetReverse(Reverse)--控制冷却动画的方向
        frame.Cooldown:SetAlpha(0.7)
        frame.Cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
        if setSwipeTexture then
            frame.Cooldown:SetSwipeTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')--圆框架
        end
        frame:HookScript('OnHide', function(f)
            if f.Cooldown then
                f.Cooldown:Clear()
            end
        end)
    end
    start=start or GetTime()
    frame.Cooldown:SetCooldown(start, duration, modRate)
end