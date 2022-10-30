local id, e = ...
local addName=ADDONS..CHAT_MODERATE
local panel=e.Cbtn(AddonList, true, nil, nil, nil, true,{80,22})

local Save={
            buttons={
                [RESISTANCE_FAIR]={
                    ['WeakAuras']=true,
                    ['WeakAurasArchive']=true,
                    ['WeakAurasModelPaths']=true,
                    ['WeakAurasOptions']=true,
                    ['WeakAurasTemplates']=true,
                    ['BugSack']=true,
                    ['!BugGrabber']=true,
                    ['TextureAtlasViewer']=true,
                    [id]=true,
                }
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
local function getTabNumeri(tab)--取得表格里的数量
    local num=0
    for _ in pairs(tab) do
        num=num+1
    end
    return num
end

--###########
--对话框, 删除
--###########
StaticPopupDialogs[id..addName..'DELETE']={
    text =id..' '..addName..'\n\n< |cff00ff00%s|r >\n\n'..ADDONS..AUCTION_HOUSE_QUANTITY_LABEL..' %s',
    button1 = DELETE,
    button2 = CANCEL,
    whileDead=true,
    timeout=60,
    hideOnEscape = true,
    OnAccept=function(self,data)
        Save.buttons[data.name]=nil
        data.frame:SetShown(false)
        local last=panel
        for _, button in pairs(panel.buttons) do
            if button and button:IsShown() then
                button:ClearAllPoints()
                button:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,2)
                last=button
            end
        end
        AddonList_HasAnyChanged()
    end,
}

--####
--按钮
--####
local function setButtons()--设置按钮, 和位置
    local last=panel
    for name, tab in pairs(Save.buttons) do
        local num=getTabNumeri(tab)
        if num>0 then
            if not panel.buttons[name] then
                panel.buttons[name]=e.Cbtn(panel, true, nil, nil, nil, true,{80,22})
                panel.buttons[name]:SetScript('OnClick',function(self, d)
                    if d=='LeftButton' then--加载
                        for i=1, GetNumAddOns() do
                            local name2= GetAddOnInfo(i);
                            if name2 and Save.buttons[name][name2] then
                                EnableAddOn(i)
                            else
                                DisableAddOn(i)
                            end
                        end
                        ReloadUI()
                    elseif d=='RightButton' then--移除
                        StaticPopup_Show(id..addName..'DELETE', name, num, {name=name, frame=self})
                    end
                end)
                panel.buttons[name]:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine(LOAD_ADDON..e.Icon.left, 	DELETE..e.Icon.right,0,1,0, 0,1,0)
                    local index=1
                    for name2,_ in pairs(Save.buttons[name]) do
                        e.tips:AddDoubleLine(name2, index)
                        index=index+1
                    end
                    e.tips:Show()
                end)
                panel.buttons[name]:SetScript('OnLeave', function() e.tips:Hide() end)
            end
            panel.buttons[name]:ClearAllPoints()
            panel.buttons[name]:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,2)
            panel.buttons[name]:SetText('|cnGREEN_FONT_COLOR:'..num..'|r'..name)
            panel.buttons[name].totaleAddons=num
        end
        if panel.buttons[name] then
            panel.buttons[name]:SetShown(num>0)
            last=panel.buttons[name]
        end
    end
end

--######
--对话框, 新建
--######
StaticPopupDialogs[id..addName..'NEW']={
    text =id..' '..addName..'\n\n'..ICON_SELECTION_TITLE_CURRENT..' %s\n\n'..PAPERDOLL_NEWEQUIPMENTSET,
    button1 = NEW,
    button2 = CANCEL,
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
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

--#####
--初始化
--#####
local function Init()
    panel:SetPoint('TOPLEFT', AddonList ,'TOPRIGHT',-2, -20)
    panel:SetText(NEW)
    panel:SetScript('OnClick',function()
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
                        button.selected:SetPoint('LEFT', button, 'RIGHT', -2, 0)
                        button.selected:SetSize(16,16)
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
            panel.text=e.Cstr(panel,16)
            panel.text:SetPoint('BOTTOM',panel, 'TOP',0,2)
        end
        panel.text:SetText(text)
    end)
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1==id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(addName, not Save.disabled, true)
        sel:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
        end)
        if not Save.disabled then
            Init()
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)