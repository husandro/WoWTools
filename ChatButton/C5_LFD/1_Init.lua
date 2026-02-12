







--[[
    LFG_CATEGORY_NAMES = {
        [LE_LFG_CATEGORY_LFD] = LOOKING_FOR_DUNGEON, 地下城查找器1
        [LE_LFG_CATEGORY_RF] = RAID_FINDER, 团队查找器 3
        [LE_LFG_CATEGORY_SCENARIO] = SCENARIOS, 场景战役 4
        [LE_LFG_CATEGORY_LFR] = LOOKING_FOR_RAID, 其他团队 2
        [LE_LFG_CATEGORY_FLEXRAID] = FLEX_RAID, 弹性团队 5
        [LE_LFG_CATEGORY_WORLDPVP] = WORLD_PVP, 阿什兰 6
        [LE_LFG_CATEGORY_BATTLEFIELD] = LFG_CATEGORY_BATTLEFIELD,乱斗 7
    }
]]


--节日, 提示, button.texture
--[[local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles()--额外 奖励
for shortageIndex=1, LFG_ROLE_NUM_SHORTAGE_TYPES or 3 do--3
    local eligible, forTank, forHealer, forDamage, itemCount= GetLFGRoleShortageRewards(dungeonID, shortageIndex)
    if eligible and itemCount~=0 and (forTank and canTank or forHealer and canHealer or forDamage and canDamage) then
        atlas= format('groupfinder-icon-role-large-%s', forTank and 'tank' or forHealer and 'heal' or 'dps')
        break
    end
end]]
local function Check_Holiday(dungeonIndex)
    local dungeonID, name = GetLFGRandomDungeonInfo(dungeonIndex)
    if not dungeonID or not name then
        return
    end

    local isAvailableForAll, isAvailableForPlayer = IsLFGDungeonJoinable(dungeonID)
    if not isAvailableForAll or not isAvailableForPlayer then
        return
    end

    local isHoliday, _, _, isTimeWalker = select(14, GetLFGDungeonInfo(dungeonID))
    if not isHoliday and not isTimeWalker then
        return
    end

--奖励物品
    local numRewards = select(6, GetLFGDungeonRewards(dungeonID)) or 0
    if numRewards==0 then
        return
    end

    local texturePath
    for rewardIndex=1 , numRewards do
        local _, texture, _, isBonusReward, rewardType= GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
        if texture then
            if rewardType == "currency"
                or rewardType=='item'
                or (isBonusReward and not texturePath)
            then
                texturePath= texture
                break
            end
        end
    end

    if texturePath then
        return dungeonID, name, texturePath
    end
end





local function Set_Holiday()
    local dungeonID, name, texture, atlas
    local group= IsInGroup()

    if group and UnitIsGroupLeader('player') or not group then
        for dungeonIndex=1, GetNumRandomDungeons() do
            dungeonID, name, texture= Check_Holiday(dungeonIndex)
            if dungeonID then
                break
            end
        end
    end

    local categoryType= dungeonID and LE_LFG_CATEGORY_LFD or nil

    WoWTools_LFDMixin:Set_LFDButton_Data(dungeonID, categoryType, WoWTools_TextMixin:CN(name), texture,  atlas)--设置图标
end











local function Init(btn)
    if not btn then
        return
    end

    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 5, -5)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -7, 7)

    --自动离开,指示图标
    btn.leaveInstance=btn:CreateTexture(nil, 'ARTWORK', nil, 1)
    btn.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    btn.leaveInstance:SetSize(12,12)
    btn.leaveInstance:SetAtlas('common-icon-rotateleft')
    btn.leaveInstance:Hide()


    function btn:set_tooltip()
        self:set_owner()
        WoWTools_ChallengeMixin:ActivitiesTooltip()--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(self.name..WoWTools_DataMixin.Icon.left)
        end
        --[[if _G['WoWToolsChatToolsLFDTooltipButton'] then
            _G['WoWToolsChatToolsLFDTooltipButton']:SetButtonState('PUSHED')
        end]]
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        if self.dungeonID then
            --print(self.dungeonID, self.type)
            if self.type==LE_LFG_CATEGORY_LFD then--1
                WoWTools_DataMixin:Call('LFDQueueFrame_SetType', self.dungeonID)
                WoWTools_DataMixin:Call('LFDQueueFrame_Join')
            elseif self.type==LE_LFG_CATEGORY_RF then--3
                WoWTools_DataMixin:Call('RaidFinderQueueFrame_SetRaid', self.dungeonID)
                WoWTools_DataMixin:Call('RaidFinderQueueFrame_Join')
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then--4

            end
            self:CloseMenu()
            self:set_tooltip()
        else
            return true
        end
    end


    --[[function btn:set_OnLeave()
        if _G['WoWToolsChatToolsLFDTooltipButton'] then
           _G['WoWToolsChatToolsLFDTooltipButton']:SetButtonState('NORMAL')
        end
    end]]

     EventRegistry:RegisterFrameEventAndCallback("LFG_UPDATE_RANDOM_INFO", Set_Holiday)
    C_Timer.After(2, Set_Holiday)


    WoWTools_LFDMixin:Init_Menu(btn)




    WoWTools_LFDMixin:Init_Queue_Status()--建立，小眼睛, 更新信息
    WoWTools_LFDMixin:Init_Loot_Plus()--历史, 拾取框
    WoWTools_LFDMixin:Init_Roll_Plus()--自动 ROLL
    WoWTools_LFDMixin:Init_RolePollPopup()
    WoWTools_LFDMixin:Init_Exit_Instance()--离开副本
    WoWTools_LFDMixin:Init_LFG_Plus()--
    WoWTools_LFDMixin:Init_Role_CheckInfo()--职责确认，信息
    WoWTools_LFDMixin:Init_RepopMe()--释放, 复活

    Init=function()end
end












local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['ChatButton_LFD']=  WoWToolsSave['ChatButton_LFD'] or {
        leaveInstance=WoWTools_DataMixin.Player.husandro,--自动离开,指示图标
        autoROLL= WoWTools_DataMixin.Player.husandro,--自动,战利品掷骰
        --disabledLootPlus=true 禁用，战利品Plus
        --hideDontEnterMenu=true 隐藏，不可能副本，列表
        ReMe=true,--仅限战场，释放，复活
        autoSetPvPRole=WoWTools_DataMixin.Player.husandro,--自动职责确认， 排副本
        autoSetRole=true,
        LFGPlus= WoWTools_DataMixin.Player.husandro,--预创建队伍增强
        tipsScale=1,--提示内容,缩放
        sec=3,--时间 timer
        wow={
            --['island']=0,
            --[副本名称]=0,
        },
    }

    if not WoWToolsSave['ChatButton_LFD'].sec then
        WoWToolsSave['ChatButton_LFD'].sec= 5
    end


    WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

    --WoWTools_ChatMixin:GetButtonForName('LFD')
    Init(
        WoWTools_ChatMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)
    )

    self:UnregisterEvent(event)
    self:SetScript('OnEvent', nil)
end)