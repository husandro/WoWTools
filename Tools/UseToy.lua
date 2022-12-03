local id, e = ...
local addName= SLASH_RANDOM3:gsub('/','').. TOY
local panel=e.Cbtn2(id..'RandomToyButton', e.toolsFrame)
panel.items={}--存放有效

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
    },
}


panel:SetAttribute("type1", "item")
panel:SetAttribute("alt-type1", "item")
panel:SetAttribute("shift-type1", "item")
panel:SetAttribute("ctrl-type1", "item")

local ModifiedTab={
    alt=69775,--[维库饮水角]
    shift=134032,--[精英旗帜]
    ctrl=109183,--[世界缩小器]
}
for _, itemID in pairs(ModifiedTab) do
    if not C_Item.IsItemDataCachedByID(itemID) then
        C_Item.RequestLoadItemDataByID(itemID)
    end
end

--#########
--主图标冷却
--#########
local function setCooldown()--主图标冷却
    if panel:IsShown() then
        if panel.itemID then
            local start, duration = GetItemCooldown(panel.itemID)
            e.Ccool(panel, start, duration, nil, true, nil, true)--冷却条
        else
            if panel.cooldown then
                panel.cooldown:Clear()
            end
        end
    end
end

local function getToy()--生成, 有效表格
    panel.items={}
    for itemID ,_ in pairs(Save.items) do
        if not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end
        if PlayerHasToy(itemID) then
            table.insert(panel.items, itemID)
        end
    end
end

local function setAtt(init)--设置属性
    if UnitAffectingCombat('player') and not init then
        return
    end
    local icon
    local tab={}

    for _, itemID in pairs(panel.items) do
        local duration, enable = select(2 ,GetItemCooldown(itemID))
        if duration<2 and enable==1 and C_ToyBox.IsToyUsable(itemID) then
            table.insert(tab, itemID)
        end
    end

    local num=#tab
    panel.count:SetText(num)
    if num>0 then
        local itemID=tab[math.random(1, num)]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                panel.texture:SetTexture(icon)
            end
            local  name= select(2, C_ToyBox.GetToyInfo(itemID)) or C_Item.GetItemNameByID(itemID) or itemID
            panel:SetAttribute('item1', name)
            panel.itemID=itemID
        end
    else
        panel:SetAttribute('item1', nil)
        panel.itemID=nil
    end
    setCooldown()--主图标冷却
    panel.texture:SetShown(icon)
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
    if e.toolsFrame.disabled or not itemID then
        return
    end
    local info={
            text='|T133567:0|t'..addName,
            checked=Save.items[itemID],
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
            tooltipOnButton=true,
            tooltipTitle=addName,
            tooltipText=id,
        }
    UIDropDownMenu_AddButton(info, 1)
end
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if e.toolsFrame.disabled or not self.itemID then
        return
    end
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
        e.SetButtonKey(panel, true, Save.KEY)
        if #Save.KEY==1 then
            if not panel.KEY then
                panel.KEYstring=e.Cstr(panel,10, nil, nil, true, 'OVERLAY')
                panel.KEYstring:SetPoint('BOTTOMRIGHT', panel.border, 'BOTTOMRIGHT',-4,4)
            end
            panel.KEYstring:SetText(Save.KEY)
            if panel.KEYtexture then
                panel.KEYtexture:SetShown(false)
            end
        else
            if not panel.KEYtexture then
                panel.KEYtexture=panel:CreateTexture(nil,'OVERLAY')
                panel.KEYtexture:SetPoint('BOTTOM', panel.border,'BOTTOM',-1,-5)
                panel.KEYtexture:SetAtlas('NPE_ArrowDown')
                panel.KEYtexture:SetDesaturated(true)
                panel.KEYtexture:SetSize(20,15)
            end
            panel.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(panel)
        if panel.KEYstring then
            panel.KEYstring:SetText('')
        end
        if panel.KEYtexture then
            panel.KEYtexture:SetShown(false)
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
        C_UI.Reload()
    end,
}


--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList then
        if menuList=='TOY' then
            for _, itemID in pairs(panel.items) do
                info={
                    text= C_Item.GetItemNameByID(itemID) or ('itemID '..itemID),
                    notCheckable=true,
                    icon= C_Item.GetItemIconByID(itemID),
                    func=function()
                        Save.items[itemID]=nil
                        getToy()--生成, 有效表格
                        setAtt()--设置属性                        
                        print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r', COMPLETE, select(2, GetItemInfo(itemID)) or (TOY..'ID: '..itemID))
                    end,
                    tooltipOnButton=true,
                    tooltipTitle=REMOVE,
                }
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList=='SETTINGS' then--设置菜单
            info={--快捷键,设置对话框
                text=SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
                checked=Save.KEY and true or niil,
                func=function ()
                    StaticPopup_Show(id..addName..'KEY')
                end,
            }
            info.disabled=UnitAffectingCombat('player')
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)
            info={--清除
                text='|cnRED_FONT_COLOR:'..(CLEAR or KEY_NUMLOCK_MAC).. TOY..'|r '..#panel.items..'/'..getAllSaveNum(),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=CLEAR_ALL,
                func=function ()
                    StaticPopup_Show(id..addName..'RESETALL')
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            info={--重置所有
                text='|cnRED_FONT_COLOR:'..RESET..'|r',
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=RESET_ALL_BUTTON_TEXT,
                func=function ()
                    StaticPopup_Show(id..addName..'RESETALL')
                end,
            }
            UIDropDownMenu_AddButton(info, level)
        end
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#panel.items..'|r'.. addName,
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
       }
       UIDropDownMenu_AddButton(info, level)
       -- UIDropDownMenu_AddSeparator()
        info={
            text=Save.KEY or SETTINGS,
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
        e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
    else
        e.tips:Hide()
    end
end


local function Init()
    if e.toolsFrame.size and e.toolsFrame.size~=30 then--设置大小
        panel:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end
    e.ToolsSetButtonPoint(panel)--设置位置

    panel.count=e.Cstr(panel,10, nil,nil, true)
    panel.count:SetPoint('TOPRIGHT',-3, -2)

    getToy()--生成, 有效表格
    setAtt(true)--设置属性
    setCooldown()--主图标冷却
    if Save.KEY then
        setKEY()--设置捷键
    end

    panel:SetScript('OnShow', setCooldown)

    for type, itemID in pairs(ModifiedTab) do
        panel:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID..'') or itemID)
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript("OnEnter",function(self)
        showTips(self)--显示提示
    end)
    panel:SetScript("OnLeave",function()
        e.tips:Hide()
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
        self.border:SetAtlas('bag-border')
    end)

    panel:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            setAtt()--设置属性
            if not UnitAffectingCombat('player') and self:IsShown() then
                showTips(self)--显示提示
            end
        end
        self.border:SetAtlas('bag-reagent-border')
       --ResetCursor()
    end)

    panel:SetScript('OnMouseWheel',function(self,d)
        setAtt()--设置属性
        showTips(self)--显示提示
    end)

end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('BAG_UPDATE_COOLDOWN')

panel:RegisterEvent('NEW_TOY_ADDED')
panel:RegisterEvent('TOYS_UPDATED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
        hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--主图标冷却
    end
end)