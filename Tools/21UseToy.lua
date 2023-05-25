local id, e = ...
local addName= SLASH_RANDOM3:gsub('/','').. TOY
local panel= CreateFrame('Frame')
local button
local ItemsTab={}--存放有效


local Save={
    items={
        [122129]=true,[169347]=true,[174873]=true,[140160]=true,[180873]=true,[188699]=true,[38301]=true,
        [147843]=true,[174830]=true,[32782]=true,[37254]=true,[186702]=true,[186686]=true,[64456]=true,
        [174924]=true,[169865]=true,[187139]=true,[183901]=true,[44719]=true,[188701]=true,[183988]=true,
        [141331]=true,[118937]=true,[88566]=true,[68806]=true,[104262]=true,[141862]=true,[127668]=true,
        [128807]=true,[103685]=true,[134031]=true,[127659]=true,[166678]=true,[86571]=true,[133511]=true,
        [166663]=true,[64646]=true,[134034]=true,[105898]=true,[134831]=true,[119215]=true,[1973]=true,
        [129149]=true,[142452]=true,[170198]=true,[129952]=true,[119421]=true,[118938]=true,[168014]=true,
        [129926]=true,[116115]=true,[116440]=true,[128310]=true,[127864]=true,[116758]=true,[163750]=true,
        [134032]=true,[87528]=true,[119092]=true,[113096]=true,[53057]=true,[116139]=true,[129938]=true,
        [35275]=true,[116067]=true,[104294]=true,[86568]=true,[118244]=true,[43499]=true,[128471]=true,
        [72159]=true,[122283]=true,[129093]=true,[167931]=true,[170154]=true,[179393]=true,[183986]=true,
        [190926]=true,[190457]=true,[120276]=true,[173984]=true,[187705]=true,[184318]=true,[184447]=true,
        [35227]=true,[169303]=true,[166779]=true,[79769]=true,[134022]=true,[174874]=true,[183903]=true,
        [122119]=true,[183856]=true,[64997]=true,[138900]=true,[49703]=true,[190333]=true,[184223]=true,
        [52201]=true,[166308]=true,[122117]=true,[129113]=true,
        [198537]=true,--[泰瓦恩的小号]
        [191891]=true,--[啾讽教授完美得无可置喙的鹰身人伪装]
        [202022]=true,--[耶努的风筝]
        [198039]=true,--感激之岩
        [202020]=true,--追逐风暴
        [205963]=true,--闻盐
    },
}



local ModifiedTab={
    alt=69775,--[维库饮水角]
    shift=134032,--[精英旗帜]
    ctrl=109183,--[世界缩小器]
}
for _, itemID in pairs(ModifiedTab) do
    e.LoadDate({id=itemID, type='item'})
end

--#########
--主图标冷却
--#########
local function setCooldown()--主图标冷却
    if button:IsShown() then
        e.SetItemSpellCool(button, button.itemID, nil)--冷却条
    end
end

local function getToy()--生成, 有效表格
    ItemsTab={}
    for itemID ,_ in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})
        if PlayerHasToy(itemID) then
            table.insert(ItemsTab, itemID)
        end
    end
end

local function setAtt()--设置属性
    if UnitAffectingCombat('player') or not button:IsShown() then
        return
    end

    local icon
    local tab={}

    for _, itemID in pairs(ItemsTab) do
        local duration, enable = select(2 ,GetItemCooldown(itemID))
        if duration<2 and enable==1 and C_ToyBox.IsToyUsable(itemID) then
            table.insert(tab, itemID)
        end
    end

    local num=#tab
    button.count:SetText(num)
    if num>0 then
        local itemID=tab[math.random(1, num)]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                button.texture:SetTexture(icon)
            end
            local  name= select(2, C_ToyBox.GetToyInfo(itemID)) or C_Item.GetItemNameByID(itemID) or itemID
            button:SetAttribute('item1', name)
            button.itemID=itemID
        end
    else
        button:SetAttribute('item1', nil)
        button.itemID=nil
    end
    setCooldown()--主图标冷却
    button.texture:SetShown(icon)
end

local function getAllSaveNum()--Save中玩具数量
    local num=0
    for _ in pairs(Save.items) do
        num= num +1
    end
    return num
end

--#############
--玩具界面, 菜单
--#############
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if not self.toy then
        self.toy= e.Cbtn(self,{size={16,16}, texture=133567})
        self.toy:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT', 16,0)
        self.toy:SetScript('OnLeave', function() e.tips:Hide() end)
        self.toy:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local itemID=self2:GetParent().itemID
            e.tips:AddDoubleLine(itemID and C_ToyBox.GetToyLink(itemID) or itemID, e.GetEnabeleDisable(not Save.items[self.itemID])..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id,'|T133567:0|t'..addName)
            e.tips:Show()
        end)
        self.toy:SetScript('OnClick', function(self2, d)
            if d=='LeftButton' then
                local frame=self2:GetParent()
                local itemID= frame and frame.itemID
                if Save.items[itemID] then
                    Save.items[itemID]=nil
                else
                    Save.items[itemID]=true
                end
                getToy()--生成, 有效表格
                setAtt()--设置属性
                securecallfunction(ToySpellButton_UpdateButton, frame)
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self2, 15, 0)
            end
        end)
    end
    self.toy:SetAlpha(Save.items[self.itemID] and 1 or 0.1)
end

--######
--快捷键
--######
local function set_KEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(button, true, Save.KEY)
        if #Save.KEY==1 then
            if not button.KEY then
                button.KEYstring=e.Cstr(button, {size=10, color=true})--10, nil, nil, true, 'OVERLAY')
                button.KEYstring:SetPoint('BOTTOMRIGHT', button.border, 'BOTTOMRIGHT',-4,4)
            end
            button.KEYstring:SetText(Save.KEY)
            if button.KEYtexture then
                button.KEYtexture:SetShown(false)
            end
        else
            if not button.KEYtexture then
                button.KEYtexture=button:CreateTexture(nil,'OVERLAY')
                button.KEYtexture:SetPoint('BOTTOM', button.border,'BOTTOM',-1,-5)
                button.KEYtexture:SetAtlas('NPE_ArrowDown')
                if not e.Player.useColor then
                    button.KEYtexture:SetDesaturated(true)
                end
                button.KEYtexture:SetSize(20,15)
            end
            button.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(button)
        if button.KEYstring then
            button.KEYstring:SetText('')
        end
        if button.KEYtexture then
            button.KEYtexture:SetShown(false)
        end
    end
end



StaticPopupDialogs[id..addName..'RESETALL']={--重置所有,清除全部玩具
    text=id..' '..addName..'|n'..CLEAR_ALL..'|n|n'.. RELOADUI,
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    button1='|cnRED_FONT_COLOR:'..RESET..'|r',
    button2=CANCEL,
    OnAccept = function(self, data)
        Save=nil
        e.Reload()
    end,
}


--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for _, itemID in pairs(ItemsTab) do
            local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
            info={
                text= toyName or itemID,
                icon= icon or C_Item.GetItemIconByID(itemID),
                colorCode=not PlayerHasToy(itemID) and '|cff606060',
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left,
                arg1= itemID,
                func=function(_, arg1)
                    if ToyBox and not ToyBox:IsVisible() then
                        ToggleCollectionsJournal(3)
                    end
                    local name= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                    if name then
                        C_ToyBoxInfo.SetDefaultFilters()
                        if ToyBox.searchBox then
                            ToyBox.searchBox:SetText(name)
                        end
                    end
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        return

    elseif menuList=='notTOY' then
        local num=0
        for itemID, _ in pairs(Save.items) do
            if not PlayerHasToy(itemID) then
                local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
                info={
                    text= toyName or itemID,
                    icon= icon or C_Item.GetItemIconByID(itemID),
                    colorCode='|cff606060',
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                    tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left,
                    arg1= itemID,
                    func=function(_, arg1)
                        if ToyBox and not ToyBox:IsVisible() then
                            ToggleCollectionsJournal(3)
                        end
                        local name= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                        if name then
                            C_ToyBoxInfo.SetDefaultFilters()
                            if ToyBox.searchBox then
                                ToyBox.searchBox:SetText(name)
                            end
                        end
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                num=num+1
            end
        end

        if num>0 then
            e.LibDD:UIDropDownMenu_AddSeparator(level)
        end
        info={
            text= '|cnRED_FONT_COLOR:#'..num..' '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..' ('..(e.onlyChinese and '未收集' or NOT_COLLECTED)..')',
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            func= function()
                local num2=0
                for itemID, _ in pairs(Save.items) do
                    if not PlayerHasToy(itemID) then
                        Save.items[itemID]= nil
                        num2= num2+1
                    end
                end
                print(id, addName, e.onlyChinese and '未收集' or NOT_COLLECTED, '|cnRED_FONT_COLOR:#'..num2..'|r', e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif menuList=='SETTINGS' then--设置菜单
        info={--快捷键,设置对话框
            text= e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
            checked=Save.KEY and true or nil,
            disabled=UnitAffectingCombat('player'),
            func=function()
                StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
                    text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
                    whileDead=1,
                    hideOnEscape=1,
                    exclusive=1,
                    timeout = 60,
                    hasEditBox=1,
                    button1= e.onlyChinese and '设置' or SETTINGS,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    button3= e.onlyChinese and '取消' or REMOVE,
                    OnShow = function(self2, data)
                        self2.editBox:SetText(Save.KEY or ';')
                        if Save.KEY then
                            self2.button1:SetText(SLASH_CHAT_MODERATE2:gsub('/', ''))--修该
                        end
                        self2.button3:SetEnabled(Save.KEY)
                    end,
                    OnAccept = function(self2, data)
                        local text= self2.editBox:GetText()
                        text=text:gsub(' ','')
                        text=text:gsub('%[','')
                        text=text:gsub(']','')
                        text=text:upper()
                        Save.KEY=text
                        set_KEY()--设置捷键
                    end,
                    OnAlt = function()
                        Save.KEY=nil
                        set_KEY()--设置捷键
                    end,
                    EditBoxOnTextChanged=function(self2, data)
                        local text= self2:GetText()
                        text=text:gsub(' ','')
                        self2:GetParent().button1:SetEnabled(text~='')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'KEY')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={--清除
            text='|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..(e.onlyChinese and '玩具' or TOY)..'|r '..#ItemsTab..'/'..getAllSaveNum(),
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '清除全部' or CLEAR_ALL,
            func=function ()
                StaticPopup_Show(id..addName..'RESETALL')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={--重置所有
            text= e.onlyChinese and '重置' or RESET,
            colorCode="|cffff0000",
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
            func=function ()
                StaticPopup_Show(id..addName..'RESETALL')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    info={
        text='|cnGREEN_FONT_COLOR:'..#ItemsTab..'|r '..(e.onlyChinese and '玩具' or TOY),
        notCheckable=true,
        menuList='TOY',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text=e.onlyChinese and '未收集' or NOT_COLLECTED,
        notCheckable=true,
        menuList='notTOY',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    
    -- e.LibDD:UIDropDownMenu_AddSeparator()
    info={
        text=Save.KEY or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL),
        notCheckable=true,
        menuList='SETTINGS',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

--####
--初始
--####
local function showTips(self)--显示提示
    if self.itemID then
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetToyByItemID(self.itemID)
        e.tips:AddLine(' ')
        for type, itemID in pairs(ModifiedTab) do
            if PlayerHasToy(itemID) then
                local name = C_Item.GetItemNameByID(itemID..'') or ('itemID: '..itemID)
                local icon = C_Item.GetItemIconByID(itemID..'')
                name= (icon and '|T'..icon..':0|t' or '')..name
                local cd
                local startTime, duration, enable = GetItemCooldown(itemID)
                if duration>0 and enable==1 then
                    local t=GetTime()
                    if startTime>t then t=t+86400 end
                    t=t-startTime
                    t=duration-t
                    cd= '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'
                elseif enable==0 then
                    cd= '|cnRED_FONT_COLOR:'..SPELL_RECAST_TIME_INSTANT..'|r'
                end

                e.tips:AddDoubleLine(name..(cd or ''), type..'+'..e.Icon.left)
            end
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
    else
        e.tips:Hide()
    end
end


local function Init()
    e.ToolsSetButtonPoint(button)--设置位置

    button.Menu=CreateFrame("Frame", id..addName..'Menu', button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    getToy()--生成, 有效表格
    setAtt()--设置属性
    if Save.KEY then set_KEY() end--设置捷键

    button:SetScript('OnShow', setAtt)

    for type, itemID in pairs(ModifiedTab) do
        button:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID..'') or itemID)
    end

    button:SetScript("OnEnter", showTips)
    button:SetScript("OnLeave",function() e.tips:Hide() end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)

    button:SetScript('OnMouseWheel',function(self,d)
        setAtt()--设置属性
        showTips(self)--显示提示
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then

                button=e.Cbtn2(id..'RandomToyButton', e.toolsFrame)
                button:SetAttribute("type1", "item")
                button:SetAttribute("alt-type1", "item")
                button:SetAttribute("shift-type1", "item")
                button:SetAttribute("ctrl-type1", "item")

                button.count=e.Cstr(button, {size=10, color=true})--10, nil,nil, true)
                button.count:SetPoint('TOPRIGHT',-3, -2)

                panel:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
                panel:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                panel:RegisterEvent('NEW_TOY_ADDED')
                panel:RegisterEvent('TOYS_UPDATED')
                panel:RegisterEvent('SPELL_UPDATE_USABLE')

                if not IsAddOnLoaded("Blizzard_Collections") then LoadAddOn('Blizzard_Collections') end
                C_Timer.After(2.1, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                        panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init()--初始
                    end
                end)
            else
                panel:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Collections' then
            --hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='SPELL_UPDATE_COOLDOWN' then
        setCooldown()--主图标冷却

    elseif event=='SPELL_UPDATE_USABLE' or event=='UNIT_SPELLCAST_SUCCEEDED' then
        setAtt()--设置属性

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            Init()--初始
            panel.combat= nil
        end
        panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)