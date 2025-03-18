local e= select(2, ...)
local function Save()
    return WoWTools_InviteMixin.Save
end














--接受, 召唤
local function Init()
    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate",function(self)
        if IsModifierKeyDown() or self.isCancelledAuto or not Save().Summon then
            if not self.isCancelledAuto then
                e.Ccool(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
                if self.SummonTimer and not self.SummonTimer:IsCancelled() then self.SummonTimer:Cancel() end--取消，计时
            end
            self.isCancelledAuto=true
            return
        end

        if not UnitAffectingCombat("player") and PlayerCanTeleport() then--启用，召唤
            if not self.enabledAutoSummon then
                self.enabledAutoSummon= true
                if self.SummonTimer and not self.SummonTimer:IsCancelled() then
                    self.SummonTimer:Cancel()
                end
                e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
                self.SummonTimer= C_Timer.NewTimer(3, function()
                    if not UnitAffectingCombat("player") and PlayerCanTeleport() then
                        C_SummonInfo.ConfirmSummon()
                        StaticPopup_Hide("CONFIRM_SUMMON")
                        if not IsInGroup() or Save().notSummonChat then
                            return
                        end
                        local isInRaid= IsInRaid()
                        if isInRaid and Save().SummonThxInRaid or not isInRaid then
                            WoWTools_ChatMixin:Chat(Save().SummonThxText or WoWTools_InviteMixin.SummonThxText, nil, nil)
                        end
                    end
                end)
            end

        elseif self.enabledAutoSummon then--取消，召唤
            e.Ccool(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
            if self.SummonTimer and not self.SummonTimer:IsCancelled() then self.SummonTimer:Cancel() end--取消，计时
            self.enabledAutoSummon=nil
        end
    end)

    StaticPopupDialogs["CONFIRM_SUMMON"].OnHide= function(self)
        if self.SummonTimer then self.SummonTimer:Cancel() end
        self.enabledAutoSummon=nil
        self.isCancelled=nil
    end

    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnShow",function()--StaticPopup.lua
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        local name= C_SummonInfo.GetSummonConfirmSummoner()
        local info= e.GroupGuid[name]
        if info and info.guid then
            local playerInfo= WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {reLink=true})
            name= playerInfo~='' and playerInfo or name
        end
        print(e.Icon.icon2..WoWTools_InviteMixin.addName, e.onlyChinese and '召唤' or SUMMON, name, '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:', C_SummonInfo.GetSummonConfirmAreaName())
    end)
end












function WoWTools_InviteMixin:Init_Summon()
    Init()
end