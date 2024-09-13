local e= select(2, ...)
local addName
local addName2
local GossipButton

local function Save()
    return WoWTools_GossipMixin.Save
end








local AutoGossipTab={--自动，对话 [gossipID]=总数
    [56363]=3,--奥达曼， 传送门
    [56364]=2,
    [56365]=1,

    [107451]=1,--魔馆，传送门
    [107092]=2,
    [107093]=3,
}
local AutoRepairTab={--修理
    [107572]=true,--挑战，模式, 修理
    [122661]=true,--地下堡
}









--自动对话
local function Get_Auto_Instance_Gossip(gossipID, numGossip)
    if gossipID==107571 then--挑战，模式，去 SX buff
        if e.WA_GetUnitDebuff('player', nil, 'HARMFUL', {
            [57723]= true,
            [57724]= true,
            [264689]= true,
            [80354]= true,
            [390435]= true,
         }) then
            return true
        end
    elseif AutoRepairTab[gossipID] then
        local value= select(2, e.GetDurabiliy()) or 100
        if value<95 then
            return true
        end

    elseif AutoGossipTab[gossipID]==numGossip then--自动，对话 [gossipID]=总数
        return true
    end
end















--自定义，对话，文本
local function Set_Gossip_Text(self, info)
    if not Save().gossip then
        return
    end
    local text
    local gossipOptionID= info and info.gossipOptionID
    if not Save().not_Gossip_Text_Icon and gossipOptionID and info.name then
        local zoneInfo= Save().Gossip_Text_Icon_Player[gossipOptionID] or WoWTools_GossipMixin:Get_GossipData()[gossipOptionID]
        if not zoneInfo then
            if not IsInInstance() then
                text= e.cn(info.name)
            end
        else
            local icon
            local name
            if zoneInfo.icon then
                local isAtlas, texture= e.IsAtlas(zoneInfo.icon)
                if isAtlas then
                    icon= format('|A:%s:%d:%d|a', texture, Save().Gossip_Text_Icon_Size, Save().Gossip_Text_Icon_Size)
                else
                    icon= format('|T%s:%d|t', texture, Save().Gossip_Text_Icon_Size)
                end
            end
            name= zoneInfo.name
            if zoneInfo.hex then
                name= '|c'..zoneInfo.hex..(name or info.name)..'|r'
            end
            if icon or name then
                text= format('%s%s', icon or '', name or '')
            end
            if text=='' then
                text= nil
            end
        end
    end
    if not text and info.questID then
        text= e.cn(nil, {questID=info.questID, isName=true})
    end

    if text then
        if Save().Gossip_Text_Icon_cnFont then
           self:GetFontString():SetFont('Fonts\\ARHei.ttf', 14)
        end
        info.name= text
        self:SetText(text)
    elseif Save().Gossip_Text_Icon_cnFont then
        self:GetFontString():SetFontObject('QuestFontLeft')
    end
end


















--建立，自动选取，选项
local function Create_CheckButton(frame, info)
    local gossipOptionID= info and info.gossipOptionID
    local check= frame.gossipCheckButton
    if gossipOptionID then
        if not check then
            check= CreateFrame("CheckButton", nil, frame, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
            frame.gossipCheckButton= check
            check.Text:ClearAllPoints()
            check.Text:SetPoint('RIGHT', check, 'LEFT')
            check.Text:SetFontObject('QuestFontLeft')
            check:SetPoint("RIGHT")
            check:SetSize(18, 18)
            check:SetScript("OnEnter", function(self)--e.tips:SetSpellByID(self.spellID)
                local f= GossipButton:isShow_Gossip_Text_Icon_Frame()
                e.tips:SetOwner(f or self, f and "ANCHOR_BOTTOM" or "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, addName)
                e.tips:AddDoubleLine(e.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG), e.GetEnabeleDisable(Save().gossip))
                e.tips:AddDoubleLine(' ')
                e.tips:AddDoubleLine('|T'..(self.icon or 0)..':0|t'..(self.name or ''), 'gossipOption: |cnGREEN_FONT_COLOR:'..self.id..'|r')
                if f and not ColorPickerFrame:IsShown() then
                   f.menu:set_date(self.id)--设置，数据
                elseif not Save().not_Gossip_Text_Icon and (Save().Gossip_Text_Icon_Player[self.id] or WoWTools_GossipMixin:Get_GossipData()[self.id]) then
                    for _, info2 in pairs( C_GossipInfo.GetOptions() or {}) do
                        if info2.gossipOptionID==self.id and info.name then
                            e.tips:AddLine('|cnGREEN_FONT_COLOR:'..info2.name)
                            break
                        end
                    end
                end
                 e.tips:Show()
                self:SetAlpha(1)
            end)

            check:SetScript("OnMouseDown", function(self)
                Save().gossipOption[self.id]= not Save().gossipOption[self.id] and (self.name or '') or nil
                if Save().gossipOption[self.id] and not IsModifierKeyDown() and Save().gossip then
                    print(e.addName, addName, format('|cnGREEN_FONT_COLOR:%s|r %d', self.name or '', self.id))
                    C_GossipInfo.SelectOption(self.id)
                end
            end)

            function check:set_settings()
                local showFrame= GossipButton:isShow_Gossip_Text_Icon_Frame()
                self:SetAlpha((showFrame or Save().gossipOption[self.id]) and 1 or 0)
                self.Text:SetText(showFrame and self.id or '')
            end
            check:SetScript('OnLeave', function(self) self:set_settings() GameTooltip_Hide() end)
            frame:HookScript('OnLeave', function(self) self.gossipCheckButton:set_settings() end)
            frame:HookScript('OnEnter', function(self) self.gossipCheckButton:SetAlpha(1) end)

             --调整，宽度
            frame:GetFontString():SetPoint('RIGHT', check.Text, 'LEFT',-2, 0)
        end
        check.id= gossipOptionID
        check.name= info.name
        --check.spellID= info.spellID
        check.icon= info.overrideIconID or info.icon
        check:SetChecked(Save().gossipOption[gossipOptionID] and true or false)
        check:set_settings()
    end
    if check then
        check:SetShown(gossipOptionID and true or false)
    end
end




















--###########
--对话，初始化
--###########
local function Init()
    GossipButton= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={16,16}, name='WoWTools_GossipButton'})--闲话图标
    WoWTools_GossipMixin.GossipButton= GossipButton

    GossipButton.texture= GossipButton:CreateTexture()
    GossipButton.texture:SetAllPoints(GossipButton)

    GossipButton.Menu=CreateFrame("Frame", nil, GossipButton, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(GossipButton.Menu, WoWTools_GossipMixin.Init_Menu_Gossip, 'MENU')

    --打开，自定义，对话，文本，按钮
    GossipButton.gossipFrane_Button= WoWTools_ButtonMixin:Cbtn(GossipFrame, {size={20,20}, icon='hide'})
    GossipButton.gossipFrane_Button:SetPoint('TOP', GossipFrameCloseButton, 'BOTTOM', -2, -4)
    GossipButton.gossipFrane_Button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            WoWTools_GossipMixin:Init_Options_Frame()
            if Gossip_Text_Icon_Frame and Gossip_Text_Icon_Frame:IsShown() then
                Gossip_Text_Icon_Frame:ClearAllPoints()
                Gossip_Text_Icon_Frame:SetPoint('TOPLEFT', GossipFrame, 'TOPRIGHT')
            end
        else
            e.LibDD:ToggleDropDownMenu(1, nil, GossipButton.Menu, self, 15, 0)
        end
    end)
    GossipButton.gossipFrane_Button:SetAlpha(0.3)
    GossipButton.gossipFrane_Button:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
    GossipButton.gossipFrane_Button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    function GossipButton:isShow_Gossip_Text_Icon_Frame()
        return Gossip_Text_Icon_Frame and Gossip_Text_Icon_Frame:IsShown() and Gossip_Text_Icon_Frame or false
    end

    function GossipButton:update_gossip_frame()
        if GossipFrame:IsShown() then
            GossipFrame:Update()
        end
    end

    function GossipButton:set_Point()--设置位置
        if Save().point then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        else
            self:SetPoint('BOTTOM', _G['!KalielsTrackerFrame'] or ObjectiveTrackerFrame, 'TOP', 0 , 0)
        end
    end
    function GossipButton:set_Scale()--设置，缩放
        self:SetScale(Save().scale or 1)
    end
    function GossipButton:set_Alpha()
        self.texture:SetAlpha(Save().gossip and 1 or 0.3)
    end
    function GossipButton:set_Texture()--设置，图片 
        local atlas= Save().gossip and 'SpecDial_LastPip_BorderGlow' or e.Icon.icon
        self.texture:SetAtlas(atlas)
        self.gossipFrane_Button:SetNormalAtlas(atlas)
        self:set_Alpha()
    end
    function GossipButton:tooltip_Show()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, e.onlyChinese and '对话' or ENABLE_DIALOG)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..e.GetEnabeleDisable(not Save().gossip), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), e.Icon.mid)
        --e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.mid)
        e.tips:Show()
        self.texture:SetAlpha(1)
    end
    function GossipButton:set_shown()
        self:SetShown(not C_PetBattles.IsInBattle())
    end

    GossipButton:set_Texture()
    GossipButton:set_Scale()
    GossipButton:set_Point()
    GossipButton:set_shown()

    GossipButton:SetMovable(true)--移动
    GossipButton:SetClampedToScreen(true)
    GossipButton:RegisterForDrag('RightButton')
    GossipButton:SetScript('OnDragStart',function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    GossipButton:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        ResetCursor()
        Save().point={self:GetPoint(1)}
        Save().point[2]=nil
    end)
    GossipButton:SetScript('OnMouseUp', ResetCursor)
    GossipButton:SetScript('OnMouseWheel', function(self, d)
        if IsAltKeyDown() then
            local n= Save().scale or 1
            if d==-1 then
                n= n+ 0.05
            elseif d==1 then
                n= n- 0.05
            end
            n= n>3 and 3 or n
            n= n< 0.4 and 0.4 or n
            Save().scale=n
            self:set_Scale()
            self:tooltip_Show()
        elseif not IsModifierKeyDown() then
            if not Gossip_Text_Icon_Frame then
                WoWTools_GossipMixin:Init_Options_Frame()
            else
                Gossip_Text_Icon_Frame:SetShown(d==-1)
            end
            --e.OpenPanelOpting('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName))
        end
    end)
    GossipButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动
            SetCursor('UI_MOVE_CURSOR')
        else
            local key=IsModifierKeyDown()
            if d=='LeftButton' and not key then--禁用，启用
                Save().gossip= not Save().gossip and true or nil
                self:set_Texture()--设置，图片
                self:tooltip_Show()
            elseif d=='RightButton' and not key then--菜单                
                e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
            end
        end
    end)


    GossipButton:SetScript('OnLeave', function(self) e.tips:Hide() self:set_Alpha() end)
    GossipButton:SetScript('OnEnter', GossipButton.tooltip_Show)

    GossipButton.selectGissipIDTab={}--GossipFrame，显示时用

    GossipButton:RegisterEvent('PLAY_MOVIE')--movieID
    GossipButton:RegisterEvent('PET_BATTLE_OPENING_DONE')
    GossipButton:RegisterEvent('PET_BATTLE_CLOSE')
    GossipButton:RegisterEvent('ADDON_ACTION_FORBIDDEN')
    GossipButton:SetScript('OnEvent', function(self, event, arg1, ...)
        if event=='PET_BATTLE_OPENING_DONE' or event=='PET_BATTLE_CLOSE' then
            self:set_shown()
        elseif event=='PLAY_MOVIE' then
            if arg1 then
                if Save().movie[arg1] then
                    if Save().stopMovie then
                        MovieFrame:StopMovie()
                        print(e.addName, addName, e.onlyChinese and '对话' or ENABLE_DIALOG,
                            '|cnRED_FONT_COLOR:'..(e.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                            'movieID|cnGREEN_FONT_COLOR:',
                            arg1
                        )
                        return
                    end
                else
                    Save().movie[arg1]= date("%d/%m/%y %H:%M:%S")
                end
                print(e.addName, addName, '|cnGREEN_FONT_COLOR:movieID', arg1)
            end

        elseif event=='ADDON_ACTION_FORBIDDEN'  then
            if Save().gossip then
                if StaticPopup1:IsShown() then
                    StaticPopup1:Hide()
                end
                print(e.addName, addName, '|n|cnRED_FONT_COLOR:',  format(e.onlyChinese and '%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN, arg1 or '', ...))
            end
        end
    end)
  --"%s已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。"
    if Save().gossip then
        StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= 0.3
    end


    --[[hooksecurefunc(StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"], "OnShow",function(s)
        if Save().gossip then
            local text= StaticPopup1Text and StaticPopup1Text:GetText() or (e.onlyChinese and '%s已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN)
            print(e.addName, addName, '|n|cnRED_FONT_COLOR:', text)
            s:Hide()
        end
    end)]]




    --禁用此npc闲话选项
    GossipFrame.WoWToolsSelectNPC=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.WoWToolsSelectNPC:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.WoWToolsSelectNPC.Text:SetText(e.onlyChinese and '禁用' or DISABLE)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnLeave", GameTooltip_Hide)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save().NPC[self.npc]= not Save().NPC[self.npc] and self.name or nil
        print(e.addName, addName, self.name, self.npc, e.GetEnabeleDisable(Save().NPC[self.npc]))
    end)
    GossipFrame.WoWToolsSelectNPC:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC |cnGREEN_FONT_COLOR:'..self.npc..'|r')
        else
            e.tips:AddDoubleLine(e.onlyChinese and '无' or NONE, 'NPC ID')
        end
        e.tips:Show()
    end)


    GossipFrame:SetScript('OnShow', function (self)
        WoWTools_GossipMixin.QuestButton.questSelect={}--已选任务, 提示用
        GossipButton.selectGissipIDTab={}
        local npc=e.GetNpcID('npc')
        self.WoWToolsSelectNPC.npc=npc
        self.WoWToolsSelectNPC.name=UnitName("npc")
        self.WoWToolsSelectNPC:SetChecked(Save().NPC[npc])
    end)

























    --自定义闲话选项, 按钮 GossipFrameShared.lua https://wago.io/MK7OiGqCu https://wago.io/hR_KBVGdK
    hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, info)--GossipFrameShared.lua
        Create_CheckButton(self, info)--建立，自动选取，选项
        Set_Gossip_Text(self, info)--自定义，对话，文本

        if not info or not info.gossipOptionID or not Save().gossip then
            return
        end

        local index= info.gossipOptionID
        local gossip= C_GossipInfo.GetOptions() or {}
        local allGossip= #gossip
        local name=info.name
        local npc=e.GetNpcID('npc')

        if IsModifierKeyDown() or not index or GossipButton.selectGissipIDTab[index] then
            return
        end

        local find
        local quest= FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend)

        if Save().gossipOption[index] then--自定义
            C_GossipInfo.SelectOption(index)
            find=true

        elseif (npc and Save().NPC[npc]) then--禁用NPC
            return

        elseif Save().quest and (quest or name:find('0000FF') or  name:find(QUESTS_LABEL) or name:find(LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST)) then--任务
            if quest then
                name= e.cn(info.name)..'<|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '任务' or QUESTS_LABEL)..'|r>'
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif allGossip==1 and Save().unique  then--仅一个
           -- if not getMaxQuest() then
            local isQuestTrivialTracking= self:get_set_IsQuestTrivialTracking()
                local tab= C_GossipInfo.GetActiveQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and questInfo.isComplete and (Save().quest or Save().questOption[questInfo.questID]) then
                        return
                    end
                end

                tab= C_GossipInfo.GetAvailableQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and (Save().quest or Save().questOption[questInfo.questID]) and (isQuestTrivialTracking and questInfo.isTrivial or not questInfo.isTrivial) then
                        return
                    end
                end
           -- end

            C_GossipInfo.SelectOption(index)
            find=true

        elseif IsInInstance() then--自动对话
            if Get_Auto_Instance_Gossip(index, allGossip, true) then
                C_GossipInfo.SelectOption(index)
                find=true
            end
        end


        if find then
            GossipButton.selectGissipIDTab[index]=true
            print(
                e.Icon.icon2..WoWTools_UnitMixin:Get_NPC_Name('npc', nil)
                ..'|T'..(info.overrideIconID or info.icon or 0)..':0|t|cff00ff00'..(name or '')
                --, index
            )
        end
    end)



















    --自动接取任务,多个任务GossipFrameShared.lua questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)
        Set_Gossip_Text(self, info)--自定义，对话，文本

        local questID=info and info.questID or self:GetID()
        if not questID or not Save().quest then
            return
        end

        if not self.sel then
            self.sel=CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')
            self.sel:SetPoint("RIGHT", -2, 0)
            self.sel:SetSize(18, 18)
            self.sel:SetScript("OnEnter", function(frame)
                e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, addName2)
                e.tips:AddDoubleLine(' ')
                if frame.id and frame.text then
                    e.tips:AddDoubleLine(frame.text, 'ID |cnGREEN_FONT_COLOR:'..frame.id..'|r')
                else
                    e.tips:AddDoubleLine(e.onlyChinese and '无' or NONE, (e.onlyChinese and '任务' or  QUESTS_LABEL)..' ID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnMouseDown", function (frame)
                if frame.id and frame.text then
                    Save().questOption[frame.id]= not Save().questOption[frame.id] and frame.text or nil
                    if Save().questOption[frame.id] then
                        C_GossipInfo.SelectAvailableQuest(frame.id)
                    end
                else
                    print(e.addName, addName2, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r', e.onlyChinese and '任务' or QUESTS_LABEL,'ID')
                end
            end)
        end

        local npc=e.GetNpcID('npc')
        self.sel.id= questID
        self.sel.text= info.title

        if IsModifierKeyDown() then
            return

        elseif Save().questOption[questID] then--自定义
           C_GossipInfo.SelectAvailableQuest(questID)--or self:GetID()

        elseif WoWTools_GossipMixin.QuestButton:not_Ace_QuestTrivial(questID) or Save().NPC[npc] then--or getMaxQuest()
            return

        else
            C_GossipInfo.SelectAvailableQuest(questID)
        end
    end)

















    --完成已激活任务,多个任务GossipFrameShared.lua
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
        Create_CheckButton(self, info)--建立，自动选取，选项
        Set_Gossip_Text(self, info)--自定义，对话，文本

        local npc=e.GetNpcID('npc')

        local questID=info.questID or self:GetID()
        if not questID or IsModifierKeyDown() then
            return

        elseif Save().questOption[questID] then--自定义
            C_GossipInfo.SelectActiveQuest(questID)
            return

        elseif not Save().quest or Save().NPC[npc] then--禁用任务, 禁用NPC
            return

        elseif C_QuestLog.IsComplete(questID) then
            C_GossipInfo.SelectActiveQuest(questID)
        end
    end)




    --[[if not StaticPopupDialogs['SPELL_CONFIRMATION_PROMPT'].OnShow then
        StaticPopupDialogs['SPELL_CONFIRMATION_PROMPT'].OnShow=function(self, data)
            if not self.button1:IsEnabled() or not Save().gossip or IsModifierKeyDown() then
                return
            end
            if data==424700 then--离开地下堡
               self.button1:Click() 
            end
        end
    end]]
end











function WoWTools_GossipMixin:Init_Gossip()
    Init()
end