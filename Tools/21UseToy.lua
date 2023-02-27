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
    },
}



local ModifiedTab={
    alt=69775,--[维库饮水角]
    shift=134032,--[精英旗帜]
    ctrl=109183,--[世界缩小器]
}
for _, itemID in pairs(ModifiedTab) do
    e.LoadSpellItemData(itemID)--加载法术, 物品数据
end

--#########
--主图标冷却
--#########
local function setCooldown()--主图标冷却
    if button:IsShown() then
        if button.itemID then
            local start, duration = GetItemCooldown(button.itemID)
            e.Ccool(button, start, duration, nil, true, nil, true)--冷却条
        else
            if button.cooldown then
                button.cooldown:Clear()
            end
        end
    end
end

local function getToy()--生成, 有效表格
    ItemsTab={}
    for itemID ,_ in pairs(Save.items) do
        e.LoadSpellItemData(itemID)--加载法术, 物品数据
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
local function setToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
    local info={
            text='|T133567:0|t'..addName,
            checked=Save.items[itemID],
            tooltipOnButton=true,
            tooltipTitle=addName,
            tooltipText=id,
            func=function()
                if Save.items[itemID] then
                    Save.items[itemID]=nil
                else
                    Save.items[itemID]=true
                end
                getToy()--生成, 有效表格
                setAtt()--设置属性
                ToySpellButton_UpdateButton(anchorTo)
            end,
        }
    UIDropDownMenu_AddButton(info, 1)
end
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    local find = Save.items[self.itemID]
    if find and not self.toy then
        self.toy=self:CreateTexture(nil, 'ARTWORK')
        self.toy:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT',12,0)
        self.toy:SetTexture(133567)
        self.toy:SetSize(12, 12)
    end
    if self.toy then
        self.toy:SetShown(find)
    end
end

--######
--快捷键
--######
local function setKEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(button, true, Save.KEY)
        if #Save.KEY==1 then
            if not button.KEY then
                button.KEYstring=e.Cstr(button,10, nil, nil, true, 'OVERLAY')
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
                if not e.Player.useClassColor then
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

StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
    text=id..' '..addName..'\n'..SETTINGS_KEYBINDINGS_LABEL..'\n\nQ, BUTTON5',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    hasEditBox=1,
    button1=SETTINGS,
    button2=CANCEL,
    button3=REMOVE,
    OnShow = function(self, data)
        self.editBox:SetText(Save.KEY or ';')
        if Save.KEY then
            self.button1:SetText(SLASH_CHAT_MODERATE2:gsub('/', ''))--修该
        end
        self.button3:SetEnabled(Save.KEY)
    end,
    OnAccept = function(self, data)
        local text= self.editBox:GetText()
        text=text:gsub(' ','')
        text=text:gsub('%[','')
        text=text:gsub(']','')
        text=text:upper()
        Save.KEY=text
        setKEY()--设置捷键
    end,
    OnAlt = function()
        Save.KEY=nil
        setKEY()--设置捷键
    end,
    EditBoxOnTextChanged=function(self, data)
        local text= self:GetText()
        text=text:gsub(' ','')
        self:GetParent().button1:SetEnabled(text~='')
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}

StaticPopupDialogs[id..addName..'RESETALL']={--重置所有,清除全部玩具
    text=id..' '..addName..'\n'..	CLEAR_ALL..'\n\n'.. RELOADUI,
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
    if menuList then
        if menuList=='TOY' then
            for _, itemID in pairs(ItemsTab) do
                info={
                    text= C_Item.GetItemNameByID(itemID) or ('itemID '..itemID),
                    notCheckable=true,
                    icon= C_Item.GetItemIconByID(itemID),
                    func=function()
                        Save.items[itemID]=nil
                        getToy()--生成, 有效表格
                        setAtt()--设置属性                        
                        print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '移除' or REMOVE)..'|r', e.onlyChinse and '完成' or COMPLETE, select(2, GetItemInfo(itemID)) or (TOY..'ID: '..itemID))
                    end,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinse and '移除' or REMOVE,
                }
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList=='SETTINGS' then--设置菜单
            info={--快捷键,设置对话框
                text= e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
                checked=Save.KEY and true or nil,
                func=function ()
                    StaticPopup_Show(id..addName..'KEY')
                end,
            }
            info.disabled=UnitAffectingCombat('player')
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)
            info={--清除
                text='|cnRED_FONT_COLOR:'..(e.onlyChinse and '清除' or CLEAR or KEY_NUMLOCK_MAC)..(e.onlyChinse and '玩具' or TOY)..'|r '..#ItemsTab..'/'..getAllSaveNum(),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinse and '清除全部' or CLEAR_ALL,
                func=function ()
                    StaticPopup_Show(id..addName..'RESETALL')
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            info={--重置所有
                text= e.onlyChinse and '重置' or RESET,
                colorCode="|cffff0000",
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinse and '全部重置' or RESET_ALL_BUTTON_TEXT,
                func=function ()
                    StaticPopup_Show(id..addName..'RESETALL')
                end,
            }
            UIDropDownMenu_AddButton(info, level)
        end
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#ItemsTab..'|r'.. addName,
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
       }
       UIDropDownMenu_AddButton(info, level)
       -- UIDropDownMenu_AddSeparator()
        info={
            text=Save.KEY or (e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL),
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
    end
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

                e.tips:AddDoubleLine(name..(e.GetItemCooldown(itemID) or ''), type..'+'..e.Icon.left)
            end
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinse and '菜单' or MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
    else
        e.tips:Hide()
    end
end


local function Init()
    if e.toolsFrame.size and e.toolsFrame.size~=30 then--设置大小
        button:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end
    e.ToolsSetButtonPoint(button)--设置位置

    getToy()--生成, 有效表格
    setAtt()--设置属性
    if Save.KEY then setKEY() end--设置捷键

    button:SetScript('OnShow', setAtt)

    for type, itemID in pairs(ModifiedTab) do
        button:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID..'') or itemID)
    end

    button.Menu=CreateFrame("Frame",nil, button, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    button:SetScript("OnEnter", showTips)
    button:SetScript("OnLeave",function() e.tips:Hide() end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
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
            Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then

                button=e.Cbtn2(id..'RandomToyButton', e.toolsFrame)
                button:SetAttribute("type1", "item")
                button:SetAttribute("alt-type1", "item")
                button:SetAttribute("shift-type1", "item")
                button:SetAttribute("ctrl-type1", "item")

                button.count=e.Cstr(button,10, nil,nil, true)
                button.count:SetPoint('TOPRIGHT',-3, -2)

                panel:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
                panel:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                panel:RegisterEvent('NEW_TOY_ADDED')
                panel:RegisterEvent('TOYS_UPDATED')
                panel:RegisterEvent('SPELL_UPDATE_USABLE')

                C_Timer.After(2.1, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                        panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init()--初始
                    end
                end)
            else
                button:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
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