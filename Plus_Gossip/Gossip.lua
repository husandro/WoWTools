
local GossipButton

local function Save()
    return WoWToolsSave['Plus_Gossip']
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
        if WoWTools_AuraMixin:Debuff('player', nil, 'HARMFUL', {
            [57723]= true,
            [57724]= true,
            [264689]= true,
            [80354]= true,
            [390435]= true,
         }) then
            return true
        end
    elseif AutoRepairTab[gossipID] then
        local value= select(2, WoWTools_DurabiliyMixin:Get()) or 100
        if value<95 then
            return true
        end

    elseif AutoGossipTab[gossipID]==numGossip then--自动，对话 [gossipID]=总数
        return true
    end
end















--自定义，对话，文本
local function Set_Gossip_Text(self, info)
    local save= Save()
    if save.not_Gossip_Text_Icon then
        return
    end

    local size= save.Gossip_Text_Icon_Size
    local isChangFont= save.Gossip_Text_Icon_cnFont

    local text
    local gossipOptionID= info and info.gossipOptionID
    if gossipOptionID and info.name then
        local zoneInfo= Save().Gossip_Text_Icon_Player[gossipOptionID] or WoWTools_GossipMixin:Get_GossipData()[gossipOptionID]
        if zoneInfo then
            local icon= select(3, WoWTools_TextureMixin:IsAtlas(zoneInfo.icon, size))
            local name= zoneInfo.name or WoWTools_TextMixin:CN(info.name, {questID=info.questID, isName=true})
            local hex= zoneInfo.hex
            text= (icon or '')..name
            if hex then
                text= '|c'..hex..text..'|r'
            end
        else
            text= WoWTools_TextMixin:CN(info.name, {questID=info.questID, isName=true})
        end
    end

    if text=='' or text==info.name then
        text=nil
    end


    if text then
        if isChangFont then
            self:GetFontString():SetFont('Fonts\\ARHei.ttf', size)
        else
            self:GetFontString():SetFontObject('QuestFontLeft')
        end
        self:SetText(text)
        self:SetHeight(size+4)
    else
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
            check:SetScript("OnEnter", function(self)--GameTooltip:SetSpellByID(self.spellID)
                local f= GossipButton:isShow_Gossip_Text_Icon_Frame()
                GameTooltip:SetOwner(f or self, f and "ANCHOR_BOTTOM" or "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_GossipMixin.addName)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG), WoWTools_TextMixin:GetEnabeleDisable(Save().gossip))
                GameTooltip:AddDoubleLine(' ')
                GameTooltip:AddDoubleLine('|T'..(self.icon or 0)..':0|t'..(self.name or ''), 'gossipOption: |cnGREEN_FONT_COLOR:'..self.id..'|r')
                if f and not ColorPickerFrame:IsShown() then
                   f.Menu:set_date(self.id)--设置，数据
                elseif not Save().not_Gossip_Text_Icon and (Save().Gossip_Text_Icon_Player[self.id] or WoWTools_GossipMixin:Get_GossipData()[self.id]) then
                    for _, info2 in pairs( C_GossipInfo.GetOptions() or {}) do
                        if info2.gossipOptionID==self.id and info.name then
                            GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..info2.name)
                            break
                        end
                    end
                end
                 GameTooltip:Show()
                self:SetAlpha(1)
            end)

            check:SetScript("OnMouseDown", function(self)
                Save().gossipOption[self.id]= not Save().gossipOption[self.id] and (self.name or '') or nil
                if Save().gossipOption[self.id] and not IsModifierKeyDown() and Save().gossip then
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r %d', self.name or '', self.id))
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
    GossipButton= WoWTools_ButtonMixin:Cbtn(--闲话图标
        nil,
        {
            size=22,
            name='WoWTools_GossipButton'}
        )
    WoWTools_GossipMixin.GossipButton= GossipButton

    GossipButton.texture= GossipButton:CreateTexture()
    GossipButton.texture:SetAllPoints()


    --打开，自定义，对话，文本，按钮
    GossipButton.gossipFrane_Button= WoWTools_ButtonMixin:Cbtn(GossipFrame, {size=20})
    GossipButton.gossipFrane_Button:SetPoint('TOP', GossipFrameCloseButton, 'BOTTOM', -2, -4)
    GossipButton.gossipFrane_Button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            WoWTools_GossipMixin:Init_Options_Frame()
            local frame= _G['Gossip_Text_Icon_Frame']
            if frame and frame:IsShown() then
                frame:ClearAllPoints()
                frame:SetPoint('TOPLEFT', GossipFrame, 'TOPRIGHT')
            end
        else
            MenuUtil.CreateContextMenu(self, function(_, root) WoWTools_GossipMixin:Init_Menu_Gossip(GossipButton, root) end)
        end
    end)
    GossipButton.gossipFrane_Button:SetAlpha(0.3)
    GossipButton.gossipFrane_Button:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
    GossipButton.gossipFrane_Button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)

    function GossipButton:isShow_Gossip_Text_Icon_Frame()
        local frame= WoWTools_GossipMixin.Frame
        return  frame and frame:IsShown() and frame or false
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
        local atlas= Save().gossip and 'SpecDial_LastPip_BorderGlow' or WoWTools_DataMixin.Icon.icon
        self.texture:SetAtlas(atlas)
        self.gossipFrane_Button:SetNormalAtlas(atlas)
        self:set_Alpha()
    end
    function GossipButton:tooltip_Show()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_Mixin.onlyChinese and '对话' or ENABLE_DIALOG)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scale or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..WoWTools_TextMixin:GetEnabeleDisable(Save().gossip), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), WoWTools_DataMixin.Icon.mid)
        --GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '选项' or OPTIONS, WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
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
            --WoWTools_PanelMixin:Open('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_Mixin.onlyChinese and '对话和任务' or WoWTools_GossipMixin.addName))
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
                MenuUtil.CreateContextMenu(self, function(...) WoWTools_GossipMixin:Init_Menu_Gossip(...) end)
            end
        end
    end)


    GossipButton:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_Alpha() end)
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
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, WoWTools_Mixin.onlyChinese and '对话' or ENABLE_DIALOG,
                            '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                            'movieID|cnGREEN_FONT_COLOR:',
                            arg1
                        )
                        return
                    end
                else
                    Save().movie[arg1]= date("%d/%m/%y %H:%M:%S")
                end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|cnGREEN_FONT_COLOR:movieID', arg1)
            end

        elseif event=='ADDON_ACTION_FORBIDDEN'  then
            if Save().gossip then
                if StaticPopup1:IsShown() then
                    StaticPopup1:Hide()
                end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|n|cnRED_FONT_COLOR:',  format(WoWTools_Mixin.onlyChinese and '%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN, arg1 or '', ...))
            end
        end
    end)

    if Save().gossip then
        StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= 0.3
    end




    --禁用此npc闲话选项
    GossipFrame.WoWToolsSelectNPC=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.WoWToolsSelectNPC:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.WoWToolsSelectNPC.Text:SetText(WoWTools_Mixin.onlyChinese and '禁用' or DISABLE)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnLeave", GameTooltip_Hide)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save().NPC[self.npc]= not Save().NPC[self.npc] and self.name or nil
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, self.name, self.npc, WoWTools_TextMixin:GetEnabeleDisable(Save().NPC[self.npc]))
    end)
    GossipFrame.WoWToolsSelectNPC:SetScript('OnEnter',function (self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_GossipMixin.addName)
        if self.npc and self.name then
            GameTooltip:AddDoubleLine(self.name, 'NPC |cnGREEN_FONT_COLOR:'..self.npc..'|r')
        else
            GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '无' or NONE, 'NPC ID')
        end
        GameTooltip:Show()
    end)


    GossipFrame:SetScript('OnShow', function (self)
        WoWTools_GossipMixin.QuestButton.questSelect={}--已选任务, 提示用
        GossipButton.selectGissipIDTab={}
        local npc=WoWTools_UnitMixin:GetNpcID('npc')
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
        local npc=WoWTools_UnitMixin:GetNpcID('npc')

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
                name= WoWTools_TextMixin:CN(info.name)..'<|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '任务' or QUESTS_LABEL)..'|r>'
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif allGossip==1 and Save().unique  then--仅一个
           -- if not getMaxQuest() then
            local isQuestTrivialTracking= WoWTools_GossipMixin.isQuestTrivialTracking
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
            if Get_Auto_Instance_Gossip(index, allGossip) then
                C_GossipInfo.SelectOption(index)
                find=true
            end
        end


        if find then
            GossipButton.selectGissipIDTab[index]=true
            print(
                '|A:SpecDial_LastPip_BorderGlow:0:0|a'..WoWTools_UnitMixin:Get_NPC_Name()
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
                GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_GossipMixin.addName2)
                GameTooltip:AddDoubleLine(' ')
                if frame.id and frame.text then
                    GameTooltip:AddDoubleLine(frame.text, 'ID |cnGREEN_FONT_COLOR:'..frame.id..'|r')
                else
                    GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '无' or NONE, (WoWTools_Mixin.onlyChinese and '任务' or  QUESTS_LABEL)..' ID',1,0,0)
                end
                GameTooltip:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                GameTooltip:Hide()
            end)
            self.sel:SetScript("OnMouseDown", function (frame)
                if frame.id and frame.text then
                    Save().questOption[frame.id]= not Save().questOption[frame.id] and frame.text or nil
                    if Save().questOption[frame.id] then
                        C_GossipInfo.SelectAvailableQuest(frame.id)
                    end
                else
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName2, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '无' or NONE)..'|r', WoWTools_Mixin.onlyChinese and '任务' or QUESTS_LABEL,'ID')
                end
            end)
        end

        local npc=WoWTools_UnitMixin:GetNpcID('npc')
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

        local npc=WoWTools_UnitMixin:GetNpcID('npc')

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