
local GossipButton, GButton2, NumGossipCNLabel

local function Save()
    return WoWToolsSave['Plus_Gossip']
end







--自动，对话 [gossipID]=总数
local AutoGossipTab={
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
local SXBuff={
    [57723]= true,--筋疲力尽
    [57724]= true,--心满意足
    [264689]= true,--疲倦
    [80354]= true,--时空错位
    [390435]= true,--筋疲力尽

}
--[466904]= true,--鹞鹰尖啸 LR

--自定义NPC对话
local NpcGossipTab={
    ['217863']={--任务 大概没事吧
        [121100]=1,
        [121103]=1,
    }
}





--自动对话
local function Get_Auto_Instance_Gossip(gossipID, numGossip)
    if gossipID==107571 then--挑战，模式，去 SX buff
        if WoWTools_AuraMixin:Get('player', SXBuff, AuraUtil.AuraFilters.Harmful) then
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
        local zoneInfo= WoWToolsPlayerDate['GossipTextIcon'][gossipOptionID] or WoWTools_GossipMixin:Get_GossipData()[gossipOptionID]
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
            --self:GetFontString():SetFont('Interface\\AddOns\\WoWTools\\Source\\ARHei.TTF', size)
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


































--###########
--对话，初始化
--###########
local function Init()
    GossipButton= WoWTools_ButtonMixin:Cbtn(nil, {--闲话图标
        size=22,
        name='WoWToolsGossipButton',
        icon='hide',
    })
    --WoWTools_GossipMixin.GossipButton= GossipButton
    GossipButton.texture= GossipButton:CreateTexture()
    GossipButton.texture:SetAllPoints()



    function GossipButton:Is_ShowOptionsFrame()
        local frame=_G['WoWToolsGossipTextIconOptionsFrame']
        if frame and frame:IsShown() then
            return frame
        end
    end



    function GossipButton:set_Point()--设置位置
        self:ClearAllPoints()
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
        if Save().gossip then
            self.texture:SetAtlas('SpecDial_LastPip_BorderGlow')
            GButton2:SetNormalAtlas('SpecDial_LastPip_BorderGlow')
        else
            self.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
            GButton2:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
        self:set_Alpha()
    end
    function GossipButton:tooltip_Show()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_DataMixin.onlyChinese and '对话' or ENABLE_DIALOG)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scale or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..WoWTools_TextMixin:GetEnabeleDisable(Save().gossip), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), WoWTools_DataMixin.Icon.mid)
        --GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS, WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
        self.texture:SetAlpha(1)
    end
    function GossipButton:set_shown()
        self:SetShown(not C_PetBattles.IsInBattle())
    end



    GossipButton:SetMovable(true)--移动
    GossipButton:SetClampedToScreen(true)
    GossipButton:RegisterForDrag('RightButton')
    GossipButton:SetScript('OnDragStart',function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    GossipButton:SetScript('OnDragStop', function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
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
            WoWTools_GossipMixin:Init_Options_Frame(d==1)
            --WoWTools_PanelMixin:Open('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '对话和任务' or WoWTools_GossipMixin.addName))
        end
    end)


    GossipButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动
            SetCursor('UI_MOVE_CURSOR')
        else
            local key=IsModifierKeyDown()
            if d=='LeftButton' and not key then--禁用，启用
                Save().gossip= not Save().gossip and true or false
                WoWTools_GossipMixin:Init_Gossip_Data()
                self:set_Texture()--设置，图片
                self:tooltip_Show()
                WoWTools_GossipMixin:Init_Gossip()

            elseif d=='RightButton' and not key then--菜单
                WoWTools_GossipMixin:Init_Menu_Gossip(self)
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
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, WoWTools_DataMixin.onlyChinese and '对话' or ENABLE_DIALOG,
                            '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                            'movieID|cnGREEN_FONT_COLOR:',
                            arg1
                        )
                        return
                    end
                else
                    Save().movie[arg1]= date("%d/%m/%y %H:%M:%S")
                end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|cnGREEN_FONT_COLOR:movieID', arg1, ...)
            end

        elseif event=='ADDON_ACTION_FORBIDDEN'  then
            if Save().gossip then
                print(
                    WoWTools_DataMixin.Icon.icon2
                    ..WoWTools_GossipMixin.addName,
                    '|n|cnRED_FONT_COLOR:',
                    format(WoWTools_DataMixin.onlyChinese and '%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN,
                    arg1 or '',
                    ...
                ))
            end
        end
    end)






    --禁用此npc闲话选项
    GossipFrame.WoWToolsSelectNPC=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.WoWToolsSelectNPC:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.WoWToolsSelectNPC.Text:SetText(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnLeave", GameTooltip_Hide)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save().NPC[self.npc]= not Save().NPC[self.npc] and self.name or nil
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName,
            self.name,
            self.npc,
            WoWTools_TextMixin:GetEnabeleDisable(Save().NPC[self.npc])
        )
    end)
    GossipFrame.WoWToolsSelectNPC:SetScript('OnEnter',function (self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        if self.npc and self.name then
            GameTooltip:AddDoubleLine(self.name, 'NPC |cnGREEN_FONT_COLOR:'..self.npc..'|r')
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '无' or NONE, 'NPC ID')
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

















--打开，自定义，对话，文本，按钮
    GButton2= WoWTools_ButtonMixin:Cbtn(GossipFrame, {
        size=20,
        name='WoWToolsOpenGossipIconTextButton'
    })

    GButton2:SetAlpha(0.3)
    GButton2:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip:Hide() end)
    GButton2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)
    GButton2:SetPoint('TOP', GossipFrameCloseButton, 'BOTTOM', -3, -4)
    GButton2:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            WoWTools_GossipMixin:Init_Options_Frame()
        else
            WoWTools_GossipMixin:Init_Menu_Gossip(self)
        end
    end)


--当前对话， 有多少已修该
    NumGossipCNLabel= WoWTools_LabelMixin:Create(GButton2, {
        name= 'WoWToolsOpenGossipNumCNLabel',
    })
    NumGossipCNLabel:SetText(0)
    NumGossipCNLabel:SetPoint('TOPRIGHT', 3, 4)
    hooksecurefunc(GossipFrame, 'Update', function()
        local num= 0
        for _, info in pairs(C_GossipInfo.GetOptions()) do
            if not WoWToolsPlayerDate['GossipTextIcon'][info.gossipOptionID] and not WoWTools_GossipMixin:Get_GossipData()[info.gossipOptionID] then
                num= num +1
            end
        end
        NumGossipCNLabel:SetText(num)
    end)












    GossipButton:set_Texture()
    GossipButton:set_Scale()
    GossipButton:set_Point()
    GossipButton:set_shown()

    StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= Save().gossip and 0.1 or nil

    Init=function()
        StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= Save().gossip and 0.1 or nil
    end
end































--建立，自动选取，选项
local function Create_GossipOptionCheckBox(frame, info)
    if frame.gossipCheckBox then
        frame.gossipCheckBox:set_data(info)
        return
    end


    frame.gossipCheckBox= CreateFrame("CheckButton", nil, frame, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
    frame.gossipCheckBox:SetPoint("RIGHT")
    frame.gossipCheckBox:SetSize(18, 18)

    frame.gossipCheckBox.Text:ClearAllPoints()
    frame.gossipCheckBox.Text:SetPoint('RIGHT', frame.gossipCheckBox, 'LEFT')
    frame.gossipCheckBox.Text:SetFontObject('QuestFontLeft')
--调整，宽度
    frame:GetFontString():SetPoint('RIGHT', frame.gossipCheckBox.Text, 'LEFT',-2, 0)

    frame.gossipCheckBox:SetScript('OnLeave', function(self)
        self:settings()
        GameTooltip:Hide()
    end)
    frame.gossipCheckBox:SetScript("OnEnter", function(self)--GameTooltip:SetSpellByID(self.spellID)
        local showFrame= GossipButton:Is_ShowOptionsFrame()
        GameTooltip:SetOwner(showFrame or self, showFrame and "ANCHOR_BOTTOM" or "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG), WoWTools_TextMixin:GetEnabeleDisable(Save().gossip))
        GameTooltip:AddDoubleLine(' ')
        if self.gossipOptionID then
            GameTooltip:AddDoubleLine(
                '|T'..(self.icon or 0)..':0|t'
                ..(self.name or ''),

                'gossipOptionID: |cnGREEN_FONT_COLOR:'
                ..self.gossipOptionID
            )
        end

        if self.spellID then
            GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetLink(self.spellID, true), 'spellID '.. self.spellID)
        end


        if showFrame and not ColorPickerFrame:IsShown() then
            _G['WoWToolsGossipTextIconOptionsList']:set_date(self.gossipOptionID)--设置，数据

        elseif not Save().not_Gossip_Text_Icon and (WoWToolsPlayerDate['GossipTextIcon'][self.gossipOptionID] or WoWTools_GossipMixin:Get_GossipData()[self.gossipOptionID]) then
            for _, info2 in pairs( C_GossipInfo.GetOptions() or {}) do
                if info2.gossipOptionID==self.gossipOptionID and info.name and info.name~=self.name then
                    GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..info2.name)
                    break
                end
            end
        end
        GameTooltip:Show()
        self:SetAlpha(1)
    end)

    frame.gossipCheckBox:SetScript("OnMouseDown", function(self)
        Save().gossipOption[self.gossipOptionID]= not Save().gossipOption[self.gossipOptionID] and (self.name or '') or nil
        if Save().gossipOption[self.gossipOptionID] and not IsModifierKeyDown() and Save().gossip then
            C_GossipInfo.SelectOption(self.gossipOptionID)
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName,
                '|cnGREEN_FONT_COLOR:',
                self.name,
                self.gossipOptionID)
        end
    end)

    function frame.gossipCheckBox:settings()
        local showFrame= GossipButton:Is_ShowOptionsFrame()
        self:SetAlpha((showFrame or Save().gossipOption[self.gossipOptionID]) and 1 or 0)
        self.Text:SetText(showFrame and self.gossipOptionID or '')
    end

    function frame.gossipCheckBox:set_data(data)
        local gossipOptionID, name, spellID, icon
        if data then
            gossipOptionID= data.gossipOptionID
            icon= data.overrideIconID or data.icon
            name= data.name
            spellID= data.spellID
        end
        frame.gossipCheckBox.gossipOptionID= gossipOptionID
        frame.gossipCheckBox.name= name
        frame.gossipCheckBox.spellID= spellID
        frame.gossipCheckBox.icon= icon
        frame.gossipCheckBox:SetChecked(gossipOptionID and Save().gossipOption[gossipOptionID] and true or false)
        frame.gossipCheckBox:settings()

        frame.gossipCheckBox:SetShown(gossipOptionID and true or false)
    end

    frame.gossipCheckBox:SetScript('OnHide', function(self)
        self.gossipOptionID= nil
        self.name= nil
        self.spellID= nil
        self.icon= nil
    end)

    frame:HookScript('OnLeave', function(self)
        self.gossipCheckBox:settings()
    end)
    frame:HookScript('OnEnter', function(self)
        self.gossipCheckBox:SetAlpha(1)
    end)

    frame.gossipCheckBox:set_data(info)
end













local function Create_AvailableQuestCheck(btn, info)
    if btn.availableQuestCheckBox then
        btn.availableQuestCheckBox:set_data(info)
        return
    end

    btn.availableQuestCheckBox=CreateFrame("CheckButton", nil, btn, 'InterfaceOptionsCheckButtonTemplate')
    btn.availableQuestCheckBox:SetPoint("RIGHT", -2, 0)
    btn.availableQuestCheckBox:SetSize(18, 18)

    btn.availableQuestCheckBox:SetScript("OnLeave", function ()
        GameTooltip:Hide()
    end)
    btn.availableQuestCheckBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName2)
        GameTooltip:AddLine(' ')

        if self.questID and self.text then
            GameTooltip:AddDoubleLine(self.text, 'questID |cnGREEN_FONT_COLOR:'..self.questID..'|r')
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '无' or NONE, (WoWTools_DataMixin.onlyChinese and '任务' or  QUESTS_LABEL)..' ID',1,0,0)
        end
        GameTooltip:Show()
    end)

    btn.availableQuestCheckBox:SetScript("OnMouseDown", function (self)
        if self.questID and self.text then
            Save().questOption[self.questID]= not Save().questOption[self.questID] and self.text or nil
            if Save().questOption[self.questID] then
                C_GossipInfo.SelectAvailableQuest(self.questID)
            end
        else
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName2,
                '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r',
                WoWTools_DataMixin.onlyChinese and '任务' or QUESTS_LABEL,
                'ID'
            )
        end
    end)

    btn.availableQuestCheckBox:SetScript('OnHide', function(self)
        self.questID= nil
        self.text= nil
    end)

    function btn.availableQuestCheckBox:set_data(data)
        local questID, text
        if data then
            questID= data.questID or self:GetParent():GetID()
            text= info.title
        end

        self.questID=  questID
        self.text= text
        self:SetShown(questID and text)
    end

    btn.availableQuestCheckBox:set_data(info)
end














local function Init_Hook()



--自定义闲话选项, 按钮 GossipFrameShared.lua https://wago.io/MK7OiGqCu https://wago.io/hR_KBVGdK
    hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, info)--GossipFrameShared.lua
        Create_GossipOptionCheckBox(self, info)--建立，自动选取，选项
        Set_Gossip_Text(self, info)--自定义，对话，文本

        if not info
            or not info.gossipOptionID
            or not Save().gossip
            or (WoWTools_DataMixin.Player.husandro and LOCALE_zhCN and NumGossipCNLabel:GetText()~='0')
        then
            return
        end

        local index= info.gossipOptionID
        local gossip= C_GossipInfo.GetOptions() or {}
        local allGossip= #gossip
        local name=info.name
        local npc=WoWTools_UnitMixin:GetNpcID('npc')--npc是字符 不是数字

        if IsModifierKeyDown() or not index or GossipButton.selectGissipIDTab[index] then
            return
        end

        local find
        local isSaveActiveQuest= Save().quest
        local quest= FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend)--local quest= FlagsUtil.IsAnySet(info.flags, bit.bor(Enum.GossipOptionRecFlags.QuestLabelPrepend, Enum.GossipOptionRecFlags.PlayMovieLabelPrepend))

--自定义对话
        if Save().gossipOption[index] then
            C_GossipInfo.SelectOption(index)
            find=true

--禁用NPC
        elseif (npc and Save().NPC[npc]) then
            return

--自定义NPC对话
        elseif NpcGossipTab[npc] then
            if NpcGossipTab[npc][index] then
                C_GossipInfo.SelectOption(index)
                find=true
            end

        elseif isSaveActiveQuest and (
                quest
                or name:find('0000FF')--PURE_BLUE_COLOR
               -- or name:find('0000ff')
                --or FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.PlayMovieLabelPrepend)
                or name:find(QUESTS_LABEL)
                or name:find(LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST)
                or name:find(RENOWN_LEVEL_UP_SKIP_BUTTON)
            )
        then--任务
            if quest then
                name= WoWTools_TextMixin:CN(info.name)..'<|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '任务' or QUESTS_LABEL)..'|r>'
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif allGossip==1 and Save().unique  then--仅一个

            local tab= C_GossipInfo.GetActiveQuests() or {}
            for _, questInfo in pairs(tab) do
                if questInfo.questID and questInfo.isComplete and (isSaveActiveQuest or Save().questOption[questInfo.questID]) then
                    return
                end
            end

            tab= C_GossipInfo.GetAvailableQuests() or {}

            local isQuestTrivialTracking= WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, false)
            for _, questInfo in pairs(tab) do
                if questInfo.questID
                    and (isSaveActiveQuest or Save().questOption[questInfo.questID])
                    and (isQuestTrivialTracking and questInfo.isTrivial or not questInfo.isTrivial)
                then
                    return
                end
            end


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
                ..'|T'..(info.overrideIconID or info.icon or 0)..':0|t|cnGREEN_FONT_COLOR:'..(name or '')
                --, index
            )
        end
    end)























    --自动接取任务,多个任务GossipFrameShared.lua questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)

        Set_Gossip_Text(self, info)--自定义，对话，文本

        Create_AvailableQuestCheck(self, info)

        local questID=info and info.questID or self:GetID()
        if not questID or not Save().quest or IsModifierKeyDown() then
            return
        end

        local npc=WoWTools_UnitMixin:GetNpcID('npc')

        if Save().questOption[questID] then--自定义
           C_GossipInfo.SelectAvailableQuest(questID)--or self:GetID()

        elseif WoWTools_GossipMixin.QuestButton:not_Ace_QuestTrivial(questID) or Save().NPC[npc] then--or getMaxQuest()
            return

        else
            C_GossipInfo.SelectAvailableQuest(questID)
        end
    end)

















    --完成已激活任务,多个任务GossipFrameShared.lua
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
        Create_GossipOptionCheckBox(self, info)--建立，自动选取，选项
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



    Init_Hook= function()end
end













function WoWTools_GossipMixin:Init_Gossip()
    Init()
    Init_Hook()
end