local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE)
local panel=e.Cbtn(AddonList, {type=false, size={80,22}})

local Save={
        buttons={
            [BASE_SETTINGS_TAB]={
                ['WeakAuras']=true,
                ['WeakAurasOptions']=true,
                ['BugSack']=true,
                ['!BugGrabber']=true,
                ['TextureAtlasViewer']=true,
                [id]=true,
            },
        },
        fast={},
        enableAllButtn= e.Player.husandro,--全部禁用时，不禁用本插件
    }

local function get_AddList()--检查列表, 选取数量, 总数, 数量/总数
    local num, all=0, C_AddOns.GetNumAddOns()
    for i=1,  all do
        if C_AddOns.GetAddOnEnableState(i)==2 then
            local name=C_AddOns.GetAddOnInfo(i)
            if name then
                num=num+1
            end
        end
    end
    return num, all, '|cff00ff00'.. num..'|r/'..all
end


--####
--按钮
--####
local function get_buttons()
    local addTab={}
    for name, tab in pairs(Save.buttons) do
        local num=0
        local load= 0
        for name2 in pairs(tab) do
            num=num+1
            if C_AddOns.IsAddOnLoaded(name2) then
                load= load+1
            end
        end
        table.insert(addTab, {name= name, tab= tab, num=num, load=load})
    end
    table.sort(addTab, function(a,b) return a.num< b.num end)
    return addTab
end


local function set_Buttons()--设置按钮, 和位置
    local last=panel
    for _, info in pairs(get_buttons()) do
        local button=panel.buttons[info.name]
        if info.num>0 then
            if not button then
                button=e.Cbtn(panel, {type=false, size={88,22}})
                button:SetScript('OnMouseDown',function(self, d)
                    if d=='LeftButton' then--加载
                        for i=1, C_AddOns.GetNumAddOns() do
                            local name2= C_AddOns.GetAddOnInfo(i);
                            if name2 and Save.buttons[self.name][name2] then
                                C_AddOns.EnableAddOn(i)
                            else
                                C_AddOns.DisableAddOn(i)
                            end
                        end
                        e.Reload()

                    elseif d=='RightButton' then--移除
                        StaticPopupDialogs[id..addName..'DELETE']={
                            text =id..' '..addName..'|n|n< |cff00ff00%s|r >|n|n'..(e.onlyChinese and '插件数量' or  ADDONS..AUCTION_HOUSE_QUANTITY_LABEL)..' %s',
                            button1 = e.onlyChinese and '删除' or DELETE,
                            button2 = e.onlyChinese and '取消' or CANCEL,
                            whileDead=true, hideOnEscape=true, exclusive=true,
                            OnAccept=function(_,data)
                                Save.buttons[data.name]=nil
                                data.frame:SetShown(false)
                                local last2=panel
                                local tabs={}
                                for _, btn in pairs(panel.buttons) do
                                    table.insert(tabs, btn)
                                end
                                table.sort(tabs, function(a,b) return a.totaleAddons< b.totaleAddons end)
                                for _, btn in pairs(tabs) do
                                    if btn and btn:IsShown() then
                                        btn:ClearAllPoints()
                                        btn:SetPoint('TOPLEFT', last2, 'BOTTOMLEFT',0,2)
                                        last2=btn
                                    end
                                end
                                AddonList_HasAnyChanged()
                            end,
                        }
                        StaticPopup_Show(id..addName..'DELETE', self.name, self.totaleAddons, {name=self.name, frame=self})
                    end
                end)

                button:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine((e.onlyChinese and '加载插件' or LOAD_ADDON)..e.Icon.left, (e.onlyChinese and '删除' or DELETE)..e.Icon.right,1,0,1, 1,0,1)
                    local addAll={}
                    local addTab={}
                    for i=1, C_AddOns.GetNumAddOns() do
                        addAll[C_AddOns.GetAddOnInfo(i)]=true
                    end
                    for name2, _ in pairs(Save.buttons[self.name]) do
                        table.insert(addTab, name2)
                    end
                    table.sort(addTab)
                    for index, name2 in pairs(addTab) do
                        if C_AddOns.IsAddOnLoaded(name2) then
                            name2= '|cnGREEN_FONT_COLOR:'..name2..'|r'..e.Icon.select2
                        elseif not addAll[name2] then
                            name2= '|cnRED_FONT_COLOR:'..name2..'|r'
                        else
                            name2= '|cffffffff'..name2..'|r'
                        end
                        e.tips:AddDoubleLine(name2, index)
                    end
                    e.tips:Show()
                end)
                button:SetScript('OnLeave', GameTooltip_Hide)

                button.lable= e.Cstr(button)--插件, 数量
                button.lable:SetPoint('LEFT', button, 'RIGHT')
                button.lable:SetTextColor(1,0,1)
            end

            button:ClearAllPoints()
            button:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,2)
            button:SetText(info.name)
            button.totaleAddons=info.num
            button.name= info.name
            button.lable:SetText(info.load..'/'..info.num)

            panel.buttons[info.name]=button
            last=button
        end
        if button then
            button:SetShown(info.num>0)
        end
    end
end









--#####
--初始化
--#####
local function Init()
    panel:SetPoint('TOPLEFT', AddonList ,'TOPRIGHT',0, -20)
    panel:SetText(e.onlyChinese and '新建' or NEW)
    panel:SetScript('OnClick',function()
        StaticPopupDialogs[id..addName..'NEW']={
            text =id..' '..addName..'|n|n'..(e.onlyChinese and '当前已选择' or ICON_SELECTION_TITLE_CURRENT)..' %s|n|n'..(e.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET),
            button1 = e.onlyChinese and '新建' or NEW,
            button2 = e.onlyChinese and '取消' or CANCEL,
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            OnAccept=function(self)
                local text = self.editBox:GetText()
                Save.buttons[text]={}
                for i=1, C_AddOns.GetNumAddOns() do
                    if C_AddOns.GetAddOnEnableState(i)==2 then
                        local name=C_AddOns.GetAddOnInfo(i);
                        if name then
                            Save.buttons[text][name]=true
                        end
                    end
                end
                set_Buttons()--设置按钮, 和位置
                e.call('AddonList_HasAnyChanged')
            end,
            OnShow=function(self)
                self.editBox:SetText(e.onlyChinese and '一般' or RESISTANCE_FAIR)
            end,
            EditBoxOnTextChanged= function(self)
                local text= self:GetText()
                text=text:gsub(' ', '')
                self:GetParent().button1:SetEnabled(text~='' and not Save.buttons[text])
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
        local text= select(3, get_AddList())--检查列表, 选取数量, 总数, 数量/总数
        StaticPopup_Show(id..addName..'NEW', text, nil)--新建按钮
    end)
    panel.buttons={}--存放按钮



























    --###############
    --插件，快捷，选中
    --###############
    panel.fast={}
    local function set_Fast_Button()
        local newTab={}
        for name, index in pairs(Save.fast) do
            table.insert(newTab, {name=name, index= index})
        end
        table.sort(newTab, function(a, b) return a.index< b.index end)
        local last
        local index= 0
        for _, tab in pairs(newTab) do
            local name, _, _, _, reason = C_AddOns.GetAddOnInfo(tab.name)
            if name and reason~='MISSING' then
                index= index+1
                local check= panel.fast[index]
                if not check then
                    check= CreateFrame("CheckButton", nil, AddonList, "InterfaceOptionsCheckButtonTemplate")
                    if not last then
                        check:SetPoint('TOPRIGHT', AddonList, 'TOPLEFT', 8,0)
                    else
                        check:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT',0,9)
                    end
                    check.Text:ClearAllPoints()
                    check.Text:SetPoint('RIGHT', check, 'LEFT')
                    check:SetScript('OnClick', function(self2)
                        if C_AddOns.GetAddOnEnableState(self2.name)~=0 then
                            C_AddOns.DisableAddOn(self2.name)
                        else
                            C_AddOns.EnableAddOn(self2.name)
                        end
                        e.call('AddonList_Update')
                    end)
                    check:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                    check:SetScript('OnEnter', function(self2)
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(self2.icon ..self2.name, self2.index)
                        e.tips:AddLine(' ')
                        e.tips:AddLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                        e.tips:AddDoubleLine(id, e.cn(addName))
                        e.tips:Show()
                        self2:SetAlpha(0.3)
                    end)
                    check.index= tab.index
                    panel.fast[index]= check
                end
                local checked= C_AddOns.GetAddOnEnableState(name)~=0
                check:SetChecked(checked)
                check:SetShown(true)

                local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
	            local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
                local icon= ''
                if iconTexture then
                    icon= '|T'..iconTexture..':22|t'
                elseif iconAtlas then
                    icon='|A:'..iconAtlas..':22:22|a'
                end
                check.Text:SetText(name..icon)
                if checked then
                    check.Text:SetTextColor(0,1,0)
                else
                    check.Text:SetTextColor(1, 0.82, 0)
                end
                check.icon= icon
                last= check
                check.name= name
            end
        end
        for i= index+1, #panel.fast, 1 do
            local check= panel.fast[i]
            if check then
                check:SetShown(false)
            end
        end
    end
    --set_Fast_Button()--插件，快捷，选中



    --hooksecurefunc('AddonList_HasAnyChanged', function(self)
    hooksecurefunc('AddonList_Update', function()
        local num, all, text = get_AddList()--检查列表, 选取数量, 总数, 数量/总数,
        local findButton=nil
        for name, button in pairs(panel.buttons) do
            if button:IsShown() then
                local find--测试按钮内容是否全选定
                if num==button.totaleAddons and Save.buttons[name] then
                    find=true
                    for name2,_ in pairs(Save.buttons[name]) do
                        if C_AddOns.GetAddOnEnableState(name2)==0 then
                            find=false
                            break
                        end
                    end
                    if find and not button.selected then
                        button.selected=button:CreateTexture()
                        button.selected:SetPoint('RIGHT', 8, 0)
                        button.selected:SetSize(22,22)
                        button.selected:SetAtlas(e.Icon.select)
                    end
                end
                if button.selected then
                    button.selected:SetShown(find)
                end
                if not findButton and find then
                    findButton=true
                end
            end
        end
        panel:SetEnabled(num~=0 and num~=all and not findButton)--新建按钮, 没有选定,或全选时, 禁用
        if not panel.text then
            panel.text=e.Cstr(panel,{size=16})--16)
            panel.text:SetPoint('BOTTOM',panel, 'TOP',0,2)
        end
        panel.text:SetText(text)
        set_Fast_Button()--插件，快捷，选中
        set_Buttons()--设置按钮
    end)


    hooksecurefunc('AddonList_InitButton', function(frame, addonIndex)
        local name= C_AddOns.GetAddOnInfo(addonIndex)
        if Save.fast[name] then
            Save.fast[name]= addonIndex
        end
        local checked= Save.fast[name]

        if not frame.check then
            frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
            function frame.check:set_alpha()
                self:SetAlpha(Save.fast[self.name] and 1 or 0)
                self.Text:SetAlpha(C_AddOns.GetAddOnDependencies(self.index) and 0.3 or 1)
            end
            frame.check:SetSize(22,22)
            frame.check:SetCheckedTexture(e.Icon.icon)
            frame.check:SetPoint('RIGHT', frame)
            frame.check:SetScript('OnClick', function(self)
                Save.fast[self.name]= not Save.fast[self.name] and self.index or nil
                set_Fast_Button()
            end)
            frame.check:SetScript('OnLeave', function(self)
                e.tips:Hide()
                self:set_alpha()
                self.select:SetShown(false)
            end)
            frame.check:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine((self.icon or '')..self.name, self.index)
                e.tips:AddLine(' ')
                e.tips:AddLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
                self:SetAlpha(1)
                self.Text:SetAlpha(1)
                self.select:SetShown(true)
            end)

            --[[frame.check.dep= frame:CreateTexture(nil, 'BACKGROUND')
            frame.check.dep:SetAtlas('callingsheader_selectedglow')
            frame.check.dep:SetAllPoints(frame.Title)
            frame.check.dep:Hide()]]

            frame.check.select= frame:CreateTexture(nil, 'OVERLAY')
            frame.check.select:SetAtlas('CreditsScreen-Selected')
            frame.check.select:SetAllPoints(frame)
            frame.check.select:Hide()

            

            frame:HookScript('OnLeave', function(self)
                self.check:set_alpha()
                --self.check.Text:SetAlpha(0.3)
                self.check.select:SetShown(false)
            end)
            frame:HookScript('OnEnter', function(self)
                self.check:SetAlpha(1)
                --self.check.Text:SetAlpha(1)
                self.check.select:SetShown(true)
            end)

            frame.check.Text:SetParent(frame)
            frame.check.Text:ClearAllPoints()
            frame.check.Text:SetPoint('RIGHT', frame.check, 'LEFT')
            --frame.check.Text:SetAlpha(0.3)

            frame.Enabled:HookScript('OnLeave', function(self)
                local f=self:GetParent()
                f.check:set_alpha()
                --f.check.Text:SetAlpha(0.3)
                f.check.select:SetShown(false)
            end)
            frame.Enabled:HookScript('OnEnter', function(self)
                local f=self:GetParent()
                f.check:SetAlpha(1)
                --f.check.Text:SetAlpha(1)
                f.check.select:SetShown(true)
            end)

            --frame.Title
        end

        local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
        local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
        frame.check.icon= iconTexture and '|T'..iconTexture..':32|t' or (iconAtlas and '|A:'..iconAtlas..':32:32|a') or nil
        if not iconTexture and not iconAtlas then
            local title= frame.Title:GetText()
            if title and title:find('|TInterface\\ICONS\\INV_Misc_QuestionMark:%d+:%d+|t') then
                frame.Title:SetText(title:gsub('|TInterface\\ICONS\\INV_Misc_QuestionMark:%d+:%d+|t', '      '))
            end
        end

        frame.check.index= addonIndex
        frame.check.name= name
        frame.check:SetChecked(checked and true or false)--fast
        frame.check:SetAlpha(checked and 1 or 0.1)

        frame.check.Text:SetText(addonIndex or '')--索引
        if C_AddOns.GetAddOnDependencies(addonIndex) then
            frame.check.select:SetVertexColor(0,1,0)
            frame.check.Text:SetTextColor(0,1,0)
            frame.check.Text:SetAlpha(0.3)
            --frame.check.dep:SetShown(false)
        else
            frame.check.select:SetVertexColor(1,1,1)
            frame.check.Text:SetTextColor(1, 0.82, 0)
            frame.check.Text:SetAlpha(1)
            --frame.check.dep:SetShown(true)
        end
    end)

    --#############
    --不禁用，本插件
    --#############
    AddonListDisableAllButton.btn= e.Cbtn(AddonListDisableAllButton, {size={18,18}, icon= Save.enableAllButtn})
    AddonListDisableAllButton.btn:SetPoint('LEFT', AddonListDisableAllButton, 'RIGHT', 2,0)
    AddonListDisableAllButton.btn:SetScript('OnClick', function(self2)
        Save.enableAllButtn= not Save.enableAllButtn and true or nil
        self2:SetNormalAtlas(Save.enableAllButtn and e.Icon.icon or e.Icon.disabled)
    end)
    AddonListDisableAllButton.btn:SetAlpha(0.3)
    AddonListDisableAllButton.btn:SetScript('OnLeave', function(self2) e.tips:Hide() self2:GetParent():SetAlpha(1) end)
    AddonListDisableAllButton.btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '启用' or ENABLE, id)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.GetEnabeleDisable(Save.enableAllButtn))
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        self2:GetParent():SetAlpha(0.3)
    end)
    AddonListDisableAllButton:HookScript('OnClick', function()
        if Save.enableAllButtn then
            C_AddOns.EnableAddOn(id)
            e.call('AddonList_Update')
        end
    end)



end


















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.fast= Save.fast or {}

            if e.Player.husandro then
                Save.buttons[e.onlyChinese and '宠物对战' or PET_BATTLE_COMBAT_LOG ]={
                    ['BugSack']=true,
                    ['!BugGrabber']=true,
                    ['tdBattlePetScript']=true,
                    --['zAutoLoadPetTeam_Rematch']=true,
                    ['Rematch']=true,
                    [id]=true,
                }
                Save.buttons[e.onlyChinese and '副本' or INSTANCE ]={
                    ['BugSack']=true,
                    ['!BugGrabber']=true,
                    ['WeakAuras']=true,
                    ['WeakAurasOptions']=true,
                    ['Details']=true,
                    ['DBM-Core']=true,
                    ['DBM-Challenges']=true,
                    ['DBM-StatusBarTimers']=true,
                    [id]=true,
                }
                Save.fast={
                    ['TextureAtlasViewer']=78,
                    ['WoWeuCN_Tooltips']=96,
                }
            end

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:Garr_Building-AddFollowerPlus:0:0|a'..(e.onlyChinese and '插件管理' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                panel:UnregisterAllEvents()
                panel:SetShown(false)
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)