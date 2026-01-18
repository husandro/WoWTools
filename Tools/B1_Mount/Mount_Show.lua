--坐骑秀
local function Save()
    return WoWToolsSave['Tools_Mounts']
end




local function Init()
    local Frame=CreateFrame('Frame', 'WoWToolsToolsMountFrame', WoWTools_ToolsMixin:Get_ButtonForName('Mount'), nil)
    Frame:SetAllPoints()
    Frame:Hide()

    function Frame:get_mounts()--得到，有效坐骑，表
        WoWTools_LoadUIMixin:Journal()
        self.tabs={}
        C_MountJournal.SetDefaultFilters()
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
        for index=1, C_MountJournal.GetNumDisplayedMounts() do
            local _, _, _, isActive, isUsable, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(index)
            if not isActive and isUsable and mountID then
                table.insert(self.tabs, mountID)
            end
        end
        local num= #self.tabs
        if num==0 then
            self:Hide()
        end
        return num
    end

    function Frame:initSpecial()--启用，坐骑特效
        self:rest()
        self.specialEffects= true
        self:set_shown()
    end

    function Frame:set_shown()--设置，是否显示
        if not self:CanChangeAttribute() then
            return
        end
        local show= true
        if InCombatLockdown() or IsIndoors() then
            show=false

        elseif self.specialEffects and not IsMounted() then
            C_MountJournal.SummonByID(0)
        end
        self:SetShown(show)
    end

    function Frame:initMountShow()--启用，坐骑秀
        self:rest()
        self:set_shown()
    end

    function Frame:rest()--重置
        self.elapsed=Save().mountShowTime or 3
        self.specialEffects=nil
        self.tabs={}
        WoWTools_CooldownMixin:Setup(self)
        self:SetShown(false)
    end

    function Frame:set_evnet()--AFK, 事件
        self:UnregisterAllEvents()
        if Save().AFKRandom then
            self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
    end

    Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_FLAGS_CHANGED' then
            if UnitIsAFK('player') then
                self:set_shown()
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:UnregisterEvent('PLAYER_FLAGS_CHANGED')
        end
    end)


    Frame:SetScript('OnUpdate', function(self, elapsed)--启用
        self.elapsed= self.elapsed  + elapsed

        if IsIndoors() or PlayerIsInCombat() or IsPlayerMoving() or UnitIsDeadOrGhost('player') then
            self:Hide()
            self.specialEffects=nil
            return

        elseif self.elapsed> Save().mountShowTime then
            self.elapsed=0

            WoWTools_CooldownMixin:Setup(self, nil, Save().mountShowTime, 0, true,false, true )--冷却条

            if self.specialEffects then
                DEFAULT_CHAT_FRAME.editBox:SetText(EMOTE171_CMD2)
                ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)

            else
                do
                    if #self.tabs==0 then
                        if self:get_mounts()==0 then
                            self:Hide()
                            return
                        end
                    end
                end
                local index= math.random(1, #self.tabs)
                C_MountJournal.SummonByID(self.tabs[index] or 0)
                table.remove(self.tabs, index)
            end
        end
    end)
    Frame:SetScript('OnHide', function(self)
        self:rest()
    end)

    Frame:set_evnet()
    Frame:rest()

    Init=function()end
end










function WoWTools_MountMixin:Init_Mount_Show()
    Init()
end