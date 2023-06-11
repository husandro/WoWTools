local id, e = ...
local addName= ADDONS..CHAT_MODERATE
local panel=e.Cbtn(AddonList, {type=false, size={80,22}})

local Save={
        buttons={
            [RESISTANCE_FAIR]={
                ['WeakAuras']=true,
                ['WeakAurasOptions']=true,
                ['BugSack']=true,
                ['!BugGrabber']=true,
                ['TextureAtlasViewer']=true,
                [id]=true,
            },
        }
    }

local function getAddList()--检查列表, 选取数量, 总数, 数量/总数
    local num, all=0, GetNumAddOns();
    for i=1,  all do
        local t= GetAddOnEnableState(nil,i);
        if t==2 then
            local name=GetAddOnInfo(i);
            if name then
                num=num+1;
            end
        end
    end
    return num, all, '|cff00ff00'.. num..'|r/'..all
end


--####
--按钮
--####
local function setButtons()--设置按钮, 和位置

    local function get_buttons()
        local addTab={}
        for name, tab in pairs(Save.buttons) do
            local num=0
            for _ in pairs(tab) do
                num=num+1
            end
            table.insert(addTab, {name= name, tab= tab, num=num})
        end
        table.sort(addTab, function(a,b) return a.num< b.num end)
        return addTab
    end

    local last=panel
    for _, info in pairs(get_buttons()) do
        local button=panel.buttons[info.name]
        if info.num>0 then
            if not button then
                button=e.Cbtn(panel, {type=false, size={88,22}})
                button:SetScript('OnMouseDown',function(self, d)
                    if d=='LeftButton' then--加载
                        for i=1, GetNumAddOns() do
                            local name2= GetAddOnInfo(i);
                            if name2 and Save.buttons[self.name][name2] then
                                EnableAddOn(i)
                            else
                                DisableAddOn(i)
                            end
                        end
                        e.Reload()

                    elseif d=='RightButton' then--移除
                        StaticPopupDialogs[id..addName..'DELETE']={
                            text =id..' '..addName..'|n|n< |cff00ff00%s|r >|n|n'..(e.onlyChinese and '插件数量' or  ADDONS..AUCTION_HOUSE_QUANTITY_LABEL)..' %s',
                            button1 = e.onlyChinese and '删除' or DELETE,
                            button2 = e.onlyChinese and '取消' or CANCEL,
                            whileDead=true,
                            timeout=60,
                            hideOnEscape = true,
                            OnAccept=function(self2,data)
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
                    for i=1, GetNumAddOns() do
                        addAll[GetAddOnInfo(i)]=true
                    end
                    for name2, _ in pairs(Save.buttons[self.name]) do
                        table.insert(addTab, name2)
                    end
                    table.sort(addTab)
                    for index, name2 in pairs(addTab) do
                        if IsAddOnLoaded(name2) then
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
                button:SetScript('OnLeave', function() e.tips:Hide() end)

                button.lable= e.Cstr(button)--插件, 数量
                button.lable:SetPoint('LEFT')
                button.lable:SetTextColor(1,0,1)
            end

            button:ClearAllPoints()
            button:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,2)
            button:SetText(info.name)
            button.totaleAddons=info.num
            button.name= info.name
            button.lable:SetText(info.num)

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
            hasEditBox=true,
            whileDead=true,
            timeout=60,
            hideOnEscape = true,
            OnAccept=function(self)
                local text = self.editBox:GetText()
                Save.buttons[text]={}
                for i=1, GetNumAddOns() do
                    if GetAddOnEnableState(nil,i)==2 then
                        local name=GetAddOnInfo(i);
                        if name then
                            Save.buttons[text][name]=true
                        end
                    end
                end
                setButtons()--设置按钮, 和位置
                AddonList_HasAnyChanged()
            end,
            OnShow=function(self)
                self.editBox:SetText(RESISTANCE_FAIR)
            end,
            EditBoxOnTextChanged=function(self, data)
                local text= self:GetText()
                text=text:gsub(' ', '')
                local parent=self:GetParent()
                parent.button1:SetEnabled(text~='' and not Save.buttons[text])
            end,
            EditBoxOnEscapePressed = function(self)
                self:SetAutoFocus(false)
                self:ClearFocus()
                self:GetParent():Hide()
            end,
        }
        local text= select(3, getAddList())--检查列表, 选取数量, 总数, 数量/总数
        StaticPopup_Show(id..addName..'NEW', text, nil)--新建按钮
    end)
    panel.buttons={}--存放按钮

    setButtons()--设置按钮
    hooksecurefunc('AddonList_HasAnyChanged', function(self)
        local num, all, text = getAddList()--检查列表, 选取数量, 总数, 数量/总数,
        local findButton=nil
        for name, button in pairs(panel.buttons) do
            if button:IsShown() then
                local find--测试按钮内容是否全选定
                if num==button.totaleAddons and Save.buttons[name] then
                    find=true
                    for name2,_ in pairs(Save.buttons[name]) do
                        if GetAddOnEnableState(nil, name2)==0 then
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
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
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
            end
            --添加控制面板        
            local sel=e.CPanel('|A:Garr_Building-AddFollowerPlus:0:0|a'..(e.onlyChinese and '插件管理' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)

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