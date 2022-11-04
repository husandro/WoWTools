local id, e = ...
local addName=UNITNAME_SUMMON_TITLE14:format(PLAYER_DIFFICULTY5)--挑战的传送门 'ChallengersPath'
local panel=CreateFrame("Frame")
local buttons={}
local Save={
    list={--{spell=数字, ins=副本ID 数字 journalInstanceID, name=自定义名称 字符}
        {spell=367416, ins=1194},--街头商贩之路(集市)
        {spell=354469, ins=1189},--石头守望者之路(雷文德斯)
        {spell=354465, ins=1185},--罪魂之路(雷文德斯) 
        {spell=354468, ins=1188},--狡诈之神之路(炽蓝仙野) 
        {spell=354464, ins=1184},--雾林之路(炽蓝仙野)
        {spell=354462, ins=1182},--勇者之路(晋升堡垒) 
        {spell=354466, ins=1186},--升腾者之路(晋升堡垒) 
        {spell=354463, ins=1183},--瘟疫之路(玛卓克萨斯) 
        {spell=354467, ins=1187},--不败之路(玛卓克萨斯)
        {spell=373190, ins=1190},--纳斯利亚堡
        {spell=373191, ins=1193},--统御圣所
        {spell=373192, ins=1195},--初诞者圣墓

        {spell=159895, ins=385},--血槌之路
        {spell=159896, ins=558},--铁船之路(码头)
        {spell=159897, ins=547},--警戒者之路
        {spell=159898, ins=476},--通天之路
        {spell=159899, ins=537},--新月之路
        {spell=159900, ins=536},--暗轨之路(车站)
        {spell=159901, ins=556},--青翠之路
        {spell=159902, ins=559},--火山之路

        {spell=131222, ins=321},--魔古皇帝之路
        {spell=131204, ins=313},--青龙之路
        {spell=131205, ins=302},--烈酒之路
        {spell=131206, ins=312},--影踪派之路
        {spell=131225, ins=303},--残阳之路
        {spell=131231, ins=311},--血色利刃之路 血色大厅
        {spell=131229, ins=316},--血色法冠之路
        {spell=131232, ins=246},--通灵师之路
        {spell=131228, ins=324},--玄牛之路

        {spell=373262, ins=860},--堕落守护者之路(卡拉赞)
        {spell=373274, ins=1178},--机械王子之路(麦卡贡)
    }
}

for _, tab in pairs(Save.list) do
    if IsSpellKnown(tab.spell) then
        if not C_Spell.IsSpellDataCached(tab.spell) then C_Spell.RequestLoadSpellData(tab.spell) end
    end
end
local function setSpellCooldown(self, spellID)--冷却
    local start, duration, _, modRate = GetSpellCooldown(spellID)
    e.Ccool(self, start, duration, modRate, true, nil)
end

--#####
--对话框
--#####
local function getInstanceDate(text)--取得数据, 是否有效
    local spell,ins=text:match('(%d+).-(%d+)')
    local name=text:match('=(.+)')
    spell= spell and tonumber(spell)
    ins= ins and tonumber(ins)
    if spell and ins then
        local spellLink= GetSpellLink(spell)
        local insName= EJ_GetInstanceInfo(ins)
        if spellLink and insName then
            print(spellLink, insName, name)
            return spell, ins, name
        end
    end
end
StaticPopupDialogs[id..addName..'EDIT']={--修该,添加
    text=id..' '..addName..'\n\n'..SPELLS..': %s\n'..INSTANCE..': %s\n\n'..'|cnGREEN_FONT_COLOR:'..SPELLS..' ID|r|cffff0000,|r '..INSTANCE..' |cnGREEN_FONT_COLOR:journalInstanceID|r|cffff0000=|r'..NAME..'('..OPTIONAL..')',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    hasEditBox=1,
    button1='|cnGREEN_FONT_COLOR:'..SLASH_CHAT_MODERATE2:gsub('/','')..'|r',
    button2=CANCEL,
    button3='|cnRED_FONT_COLOR:'..REMOVE..'|r',
    OnShow = function(self, data)
        if not data.index then
            self.button1:SetText(ADD)
        end
        self.editBox:SetText((data.spell or '')..', '..(data.ins or ' ')..' ='..(data.name or ''))
        self.editBox:SetWidth(self:GetWidth())
        self.button3:SetEnabled(data.index and data.spell and data.ins)
	end,
    OnAccept = function(self, data)
        local find
        local spell, ins, name= getInstanceDate(self.editBox:GetText())
        if spell and ins then
            if name and name:gsub(' ','')=='' then
                name=nil
            end
            if data.index then
                if Save.list[data.index] then
                    Save.list[data.index].spell=spell
                    Save.list[data.index].ins=ins
                    Save.list[data.index].name=name
                    find=SLASH_CHAT_MODERATE2:gsub('/','')
                end
            else
                table.insert(Save.list, {spell=spell, ins=ins, name=name})
                find=ADD
            end
        end
        if find then
            local spellLink=GetSpellLink(spell) or (SPELLS..spell)
            local insName= EJ_GetInstanceInfo(ins) or (INSTANCE..ins)
            print(id, addName,'|cnGREEN_FONT_COLOR:'..find..'|r', COMPLETE, spellLink, insName, name, '|cnRED_FONT_COLOR:'..RELOADUI..'|r')
        else
            print(id,addName, '|cnRED_FONT_COLOR:'..ERRORS..'|r')
        end
	end,
    OnAlt = function(self, data)
        if data and data.index and Save.list[data.index] then
            local tab=Save.list[data.index]
            local spellLink=GetSpellLink(tab.spell) or (SPELLS..tab.spell)
            local insName= EJ_GetInstanceInfo(tab.ins) or (INSTANCE..tab.ins)
            table.remove(Save.list, data.index)
            print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r', COMPLETE, spellLink, insName, '|cnRED_FONT_COLOR:'..RELOADUI..'|r')
        else
            print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r', ERRORS)
        end
    end,
    EditBoxOnTextChanged=function(self, data)
        local spell, ins, name= getInstanceDate(self:GetText())
        self:GetParent().button1:SetEnabled(spell and ins)
    end,
    EditBoxOnEscapePressed = function(self)
        slef:GetParent():Hide()
    end,
}
StaticPopupDialogs[id..addName..'RESET']={--重置
    text=id..' '..addName..'\n\n'..RELOADUI,
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    button1='|cnRED_FONT_COLOR:'..RESET..'|r',
    button2=CANCEL,
    OnAccept = function()
      Save=nil
      C_UI.Reload()
	end,
}
--#####
--主菜单
--#####
local function InitMenu(self, leve, tab)--主菜单
    if not tab or not tab.spell or not tab.ins then
        return
    end
    local info={
        text= SLASH_CHAT_MODERATE2:gsub('/',''),
        notCheckable=true,
        func=function()
            local name=GetSpellInfo(tab.spell)
            name=name and name..' '..tab.spell or tab.spell
            local insName=EJ_GetInstanceInfo(tab.ins)
            insName = insName and insName.. ' '..tab.ins or tab.ins
            StaticPopup_Show(id..addName..'EDIT',name ,insName , tab)
        end,
    }
    UIDropDownMenu_AddButton(info, level)

    info={
        text= ADD,
        notCheckable=true,
        func=function()
            StaticPopup_Show(id..addName..'EDIT', NEED ,NEED , {})
        end,
    }
    UIDropDownMenu_AddButton(info, level)
    UIDropDownMenu_AddSeparator(level)
    info={
        text= '|cnRED_FONT_COLOR:'..RESET..'|r',
        notCheckable=true,
        func=function()
            StaticPopup_Show(id..addName..'RESET')
        end,
    }
    UIDropDownMenu_AddButton(info, level)
end
--####
--初始
--####
local function Init()
    local find
    for index, tab in pairs(Save.list) do
        if IsSpellKnown(tab.spell) then
            if not find then
                panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
                UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')
            end
            buttons[tab.spell]=e.Cbtn2(nil, e.toolsFrame, true)

            local name, _, icon = GetSpellInfo(tab.spell)
            buttons[tab.spell]:SetAttribute('type', 'spell')--设置属性
            buttons[tab.spell]:SetAttribute('spell', name or tab.spell)
            buttons[tab.spell].texture:SetTexture(icon)

            e.ToolsSetButtonPoint(buttons[tab.spell], not find)--设置位置
            find=true

            name = tab.ins and EJ_GetInstanceInfo(tab.ins) or name--设置名称
            if name then
                name = tab.name or e.WA_Utf8Sub(name, 2, 5)
                if not buttons[tab.spell].name then
                    local size=8
                    if e.toolsFrame.size and e.toolsFrame.size>30 then
                        if e.toolsFrame.size>40 then
                            size=12
                        elseif e.toolsFrame.size>30 then
                            size=10
                        end
                    end
                    buttons[tab.spell].name=e.Cstr(buttons[tab.spell], size, nil, nil, true, nil,'CENTER')
                end
                buttons[tab.spell].name:SetPoint('CENTER',0,-5)
                buttons[tab.spell].name:SetText(name)
            end

            buttons[tab.spell]:SetScript("OnEnter",function(self)--设置事件
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(tab.spell)
                e.tips:AddLine(' ')
                local insName, _, _, buttonImage1 = EJ_GetInstanceInfo(tab.ins)
                if tab.ins then
                    e.tips:AddDoubleLine((buttonImage1 and '|T'..buttonImage1..':0|t' or '')..(insName or ('journalInstanceID: '..tab.ins)), ADVENTURE_JOURNAL..e.Icon.right)
                end
                e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
                e.tips:Show()
            end)
            buttons[tab.spell]:SetScript('OnLeave', function() e.tips:Hide() end)

            buttons[tab.spell]:SetScript('OnMouseDown', function(self, d)
                if d=='RightButton' and tab.ins then
                    local frame=EncounterJournal;
                    if not frame or not frame:IsShown() then
                        ToggleEncounterJournal();
                    end
                    NavBar_Reset(EncounterJournal.navBar)
                    EncounterJournal_DisplayInstance(tab.ins)
                end
            end)
            buttons[tab.spell]:SetScript('OnMouseWheel', function(self, d)
                ToggleDropDownMenu(1,nil, panel.Menu, self, 15,0 , {spell=tab.spell, ins=tab.ins, name=tab.name, index=index})
            end)
            buttons[tab.spell]:RegisterEvent('PLAYER_REGEN_DISABLED')--设置, 冷却
            buttons[tab.spell]:RegisterEvent('PLAYER_REGEN_ENABLED')
            buttons[tab.spell]:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            buttons[tab.spell]:SetScript("OnEvent", function(self, event, arg1)
                if event=='PLAYER_REGEN_DISABLED' then
                    self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                elseif event=='PLAYER_REGEN_ENABLED' then
                    self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                elseif event=='SPELL_UPDATE_COOLDOWN' then
                    setSpellCooldown(self, tab.spell)--冷却
                end
            end)
            buttons[tab.spell]:SetScript('OnShow', function(self)
                setSpellCooldown(self, tab.spell)--冷却
            end)
            setSpellCooldown(buttons[tab.spell], tab.spell)--冷却
            buttons[tab.spell].cooldown:SetAlpha(0.5)
        end
    end
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
      Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.8, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                    panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
                end
            end)
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            Init()
            panel.combat=nil
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)