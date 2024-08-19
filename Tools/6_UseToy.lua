local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)
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
        [205963]=true,--闻盐
        [208658]=true,--谦逊之镜 使用: 变身为一个悔改的堕落艾瑞达。 (2​小时 冷却)
        [210656]=true,--冬幕节袜子
        --[217726]=true,--砮皂之韧 10.2.7 217724 217723 217725

        [220777]=true,--樱花之路
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
        e.SetItemSpellCool(button, {item=button.itemID})--冷却条
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

local function setAtt(set)--设置属性
    if not button:IsVisible() or UnitAffectingCombat('player') or (GameTooltip:IsOwned(button) and not set) then
        return
    end

    local icon
    local tab={}

    for _, itemID in pairs(ItemsTab) do
        local duration = select(2 ,C_Container.GetItemCooldown(itemID))
        if (duration and duration<2) and C_ToyBox.IsToyUsable(itemID) then
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






























--玩具界面, 菜单, --标记, 是否已选取
function Init_SetButtonOption()
    hooksecurefunc('ToySpellButton_UpdateButton', function(btn)
        if btn.toy then
            btn.toy:set_alpha()
            return
        end
        btn.toy= e.Cbtn(btn,{size={16,16}, texture=133567})
        btn.toy:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 16,0)
        function btn.toy:get_itemID()
            return self:GetParent().itemID
        end
        function btn.toy:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end

        function btn.toy:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, 'Tools |T133567:0|t'..(e.onlyChinese and '随机玩具' or addName))
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            e.tips:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            e.tips:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                e.GetEnabeleDisable(Save.items[itemID])..e.Icon.left
            )
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end

        btn.toy:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                local itemID=self:get_itemID()
                Save.items[itemID]= not Save.items[itemID] and true or nil
                getToy()--生成, 有效表格
                setAtt()--设置属性
                self:set_tooltips()
                self:set_alpha()
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
            end
        end)
        btn.toy:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.toy:SetScript('OnEnter', btn.toy.set_tooltips)

    end)
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

































--#####
--主菜单
--#####
local function InitMenu(_, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for _, itemID in pairs(ItemsTab) do
            local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
            info={
                text= toyName or itemID,
                icon= icon or C_Item.GetItemIconByID(itemID),
                colorCode=not PlayerHasToy(itemID) and '|cff9e9e9e',
                keepShownOnClick=true,
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

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={--清除
            text='|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..(e.onlyChinese and '玩具' or TOY)..'|r '..#ItemsTab..'/'..getAllSaveNum(),
            icon= 'bags-button-autosort-up',
            keepShownOnClick=true,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '清除全部' or CLEAR_ALL,
            func=function ()
                StaticPopup_Show(id..addName..'RESETALL')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif menuList=='notTOY' then
        local num=0
        for itemID, _ in pairs(Save.items) do
            if not PlayerHasToy(itemID) then
                local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
                info={
                    text= toyName or itemID,
                    icon= icon or C_Item.GetItemIconByID(itemID),
                    colorCode='|cff9e9e9e',
                    notCheckable=true,
                    keepShownOnClick=true,
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
                print(id, e.cn(addName), e.onlyChinese and '未收集' or NOT_COLLECTED, '|cnRED_FONT_COLOR:#'..num2..'|r', e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif menuList=='SETTINGS' then--设置菜单
        info={--快捷键,设置对话框
            text= e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
            checked=Save.KEY and true or nil,
            disabled=UnitAffectingCombat('player'),
            keepShownOnClick=true,
            func=function()
                StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
                    text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '设置' or SETTINGS,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    button3= e.onlyChinese and '取消' or REMOVE,
                    OnShow = function(self2, data)
                        self2.editBox:SetText(Save.KEY or ';')
                        if Save.KEY then
                            self2.button1:SetText(e.onlyChinese and '修改' or EDIT)--修该
                        end
                        self2.button3:SetEnabled(Save.KEY and true or false)
                    end,
                    OnHide= function(self2)
                        self2.editBox:SetText("")
                        e.call('ChatEdit_FocusActiveWindow')
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


        info={--重置所有
            text= e.onlyChinese and '重置' or RESET,
            colorCode="|cffff0000",
            notCheckable=true,
            keepShownOnClick=true,
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
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text=e.onlyChinese and '未收集' or NOT_COLLECTED,
        notCheckable=true,
        menuList='notTOY',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    -- e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=Save.KEY or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL),
        notCheckable=true,
        menuList='SETTINGS',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end
























--####
--初始
--####
local function set_Button_Event(isShown)
    if isShown then
        panel:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
        --panel:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        --panel:RegisterEvent('SPELL_UPDATE_USABLE')
    else
        panel:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
--        panel:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
        --panel:UnregisterEvent('SPELL_UPDATE_USABLE')
    end
end























local function Init()

    StaticPopupDialogs[id..addName..'RESETALL']={--重置所有,清除全部玩具
        text=id..' '..addName..'|n'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1='|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET)..'|r',
        button2= e.onlyChinese and '取消' or CANCEL,
        OnAccept = function()
            Save=nil
            e.Reload()
        end,
    }

    button.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    getToy()--生成, 有效表格
    setAtt()--设置属性
    if Save.KEY then set_KEY() end--设置捷键

    button:SetScript('OnShow', setAtt)

    for type, itemID in pairs(ModifiedTab) do
        button:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID..'') or itemID)
    end

    function button:set_tooltips()--显示提示
        if self.itemID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetItemByID(self.itemID)
            --e.tips:SetToyByItemID(self.itemID)
            e.tips:AddLine(' ')
            for type, itemID in pairs(ModifiedTab) do
                if PlayerHasToy(itemID) then
                    local name = C_Item.GetItemNameByID(itemID..'') or ('itemID: '..itemID)
                    local icon = C_Item.GetItemIconByID(itemID..'')
                    name= (icon and '|T'..icon..':0|t' or '')..name
                    local cd= e.GetSpellItemCooldown(nil, itemID)--冷却
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

    button:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)
    button:SetScript("OnEnter", function(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (self, elapsed)
            self.elapsed = (self.elapsed or 0.3) + elapsed
            if self.elapsed > 0.3 and self.itemID then
                self.elapsed = 0
                if GameTooltip:IsOwned(self) and select(3, GameTooltip:GetItem())~=self.itemID then
                    self:set_tooltips()
                end
            end
        end)
    end)

    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        else
            setAtt(true)
        end
    end)

    button:SetScript('OnMouseWheel', function()
        setAtt(true)
    end)

    --button:SetScript('OnMouseWheel', setAtt)--设置属性

    button:SetScript("OnShow", function()
        set_Button_Event(true)
        setAtt(true)--设置属性
        setCooldown()--主图标冷却
    end)
    button:SetScript("OnHide", function()
        set_Button_Event()
    end)
end
























--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save

            button= WoWTools_ToolsButtonMixin:CreateButton({
                name='UseToy',
                tooltip='|A:collections-icon-favorites:0:0|a'..(e.onlyChinese and '使用玩具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)),
                setParent=true,
                point='LEFT'
            })
            if button then
                
                button:SetAttribute("type1", "item")
                button:SetAttribute("alt-type1", "item")
                button:SetAttribute("shift-type1", "item")
                button:SetAttribute("ctrl-type1", "item")

                button.count=e.Cstr(button, {size=10, color=true})--10, nil,nil, true)
                button.count:SetPoint('TOPRIGHT',-3, -2)

                panel:RegisterEvent('NEW_TOY_ADDED')
                panel:RegisterEvent('TOYS_UPDATED')

                --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    C_AddOns.LoadAddOn('Blizzard_Collections')
                end]]

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
            Init_SetButtonOption()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格

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