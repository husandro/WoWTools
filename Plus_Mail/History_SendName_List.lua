--收件人，历史记录
local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end


local Button, Frame, Tab








local function created_button(index)
    local btn= WoWTools_ButtonMixin:Cbtn(Frame, {size={22, 14}, icon='hide'})
    btn:SetPoint('TOPRIGHT', Frame, 'BOTTOMRIGHT', 0, -(index-1)*14)
    btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
    btn.Text:SetPoint('RIGHT', -2, 0)

    btn:SetScript('OnLeave', function(frame) e.tips:Hide() frame:set_alpha() end)
    btn:SetScript('OnEnter', function(frame)
        e.tips:SetOwner(frame, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(WoWTools_MailMixin:GetRealmInfo(frame.name) or ' ', frame.name)
        e.tips:Show()
        frame:SetAlpha(1)
    end)
    btn:SetScript('OnClick', function(frame)
          WoWTools_MailMixin:SetSendName(frame.name)--设置，收件人，名字
    end)
    function btn:set_alpha()
        self:SetAlpha(self.alpha or 1)
    end
    function btn:settings()
        self.Text:SetText(WoWTools_MailMixin:GetNameInfo(self.name))
        self:SetWidth(self.Text:GetWidth()+4)
        self.alpha= (self.name==e.Player.name_realm or WoWTools_MailMixin:GetRealmInfo(self.name)) and 0.3 or 1
        self:set_alpha()
        self:SetShown(true)
    end
    function btn:clear()
        self:SetShown(false)
        self.Text:SetText('')
        self.name=nil
    end
    Tab[index]= btn
    return btn
end









local function set_list()
    Button.Text:SetText(#Save().lastSendPlayerList)--列表，数量

    if Save().hideSendPlayerList then
        return
    end
    local index=1
    for _, name in pairs(Save().lastSendPlayerList) do
        if not WoWTools_MailMixin:GetRealmInfo(name) and name~=e.Player.name_realm then
            local btn= Tab[index] or created_button(index)
            btn.name=name
            btn:settings()
            index= index+1
        end
    end
    for i= index, #Tab, 1 do
        local btn= Tab[i]
        if btn then
            btn:clear()
        end
    end
end








local function Set_Button()
    Button:SetAlpha(Save().hideSendPlayerList and 0.3 or 1)
    Frame:SetScale(Save().scaleSendPlayerFrame or 1)
    Frame:SetShown(not Save().hideSendPlayerList)
end









local function remove_table(name)
    for index, name2 in pairs(Save().lastSendPlayerList) do
        if name2==name then
            table.remove(Save().lastSendPlayerList, index)
        end
    end
end

local function find_table(name)
    for index, name2 in pairs(Save().lastSendPlayerList) do
        if name2==name then
            return index
        end
    end
end







local function Init_Menu(_, root)
    local sub, sub2
    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hideSendPlayerList
    end, function()
        Save().hideSendPlayerList= not Save().hideSendPlayerList and true or nil
        Set_Button()
        set_list()
    end)

    local num= #Save().lastSendPlayerList
    sub=root:CreateButton(
        format('%s |cnGREEN_FONT_COLOR:#%d|r', e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER, num),
    function()
        return MenuResponse.Open
    end)

    for index, name in pairs(Save().lastSendPlayerList) do
        sub2=sub:CreateCheckbox(
            (
                WoWTools_MailMixin:GetRealmInfo(name) and '|cff9e9e9e'
                or (name==e.Player.name_realm and '|cff00ff00')
                or ''
            )
            ..WoWTools_MailMixin:GetNameInfo(name),
        function(data)
            return find_table(data.name)
            
        end, function(data)
            if find_table(data.name) then
                remove_table(data.name)
            else
                table.insert(Save().lastSendPlayerList, data.index, data.name)
            end
            set_list()
        end, {index=index, name=name})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.name)
            tooltip:AddLine(' ')
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
            tooltip:AddLine(WoWTools_MailMixin:GetRealmInfo(description.data.name))--该玩家与你不在同一个服务器
        end)
    end

--全部清除
    if num>0 then
        sub:CreateDivider()
    end
    if num>1 then
        sub:CreateButton(
            e.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().lastSendPlayerList={}
            set_list()
            return MenuResponse.Refresh
        end)
    end

    sub2= sub:CreateButton(
        e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
    function()
        return MenuResponse.Open
    end)

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().lastMaxSendPlayerList
        end, setValue=function(value)
            Save().lastMaxSendPlayerList=value
        end,
        name=e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
        minValue=5,
        maxValue=100,
        step=1,
    })
    sub2:CreateSpacer()

--SetGridMode
    WoWTools_MenuMixin:SetGridMode(sub, num)

--打开选项
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})


--缩放
    WoWTools_MenuMixin:Scale(sub, function()
        return Save().scaleSendPlayerFrame or 1
    end, function(value)
        Save().scaleSendPlayerFrame=value
        Set_Button()
    end)
end










--MAIL_FAILED
--MAIL_SEND_SUCCESS
local function Set_Event(self, event)
    if not self.SendName then
        return
    end

    if event=='MAIL_SEND_SUCCESS' then
        local findIndex= find_table(self.SendName)
        if findIndex==1 then
            WoWTools_MailMixin:SetSendName(self.SendName)
            return

        elseif findIndex then--移除，已存在
            table.remove(Save().lastSendPlayerList, findIndex)

        elseif #Save().lastSendPlayerList>= Save().lastMaxSendPlayerList then--移除，最大保存数
            table.remove(Save().lastSendPlayerList)
        end

        table.insert(Save().lastSendPlayerList, 1, self.SendName)

        set_list()--设置，历史记录，内容
        WoWTools_MailMixin:SetSendName(self.SendName)
    end

    self.SendName=nil
end










local function Init()
    Tab={}

    Button= WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size=22, icon='hide'})
    Button:SetPoint('TOPRIGHT', SendMailFrame, 'TOPLEFT', 0, -22)

    Frame= CreateFrame('Frame', nil, Button)
    Frame:SetPoint('BOTTOMRIGHT')
    Frame:SetSize(1,1)

    Button.Text= WoWTools_LabelMixin:Create(Button, {justifyH='CENTER', color={r=1,g=1,b=1}})--列表，数量
    Button.Text:SetPoint('CENTER')

    Button:SetScript('OnEvent', Set_Event)

    SendMailMailButton:HookScript('OnClick', function()
        Button.SendName= WoWTools_UnitMixin:GetFullName(SendMailNameEditBox:GetText())
    end)

    function Button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
    end
    Button:SetScript('OnLeave', GameTooltip_Hide)
    Button:SetScript('OnEnter', Button.set_tooltip)

    Button:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)

    Button:SetScript('OnHide', Button.UnregisterAllEvents)
    Button:SetScript('OnShow', function(self)
        self:RegisterEvent('MAIL_SEND_SUCCESS')--SendName，设置，发送成功，名字
        self:RegisterEvent('MAIL_FAILED')
        set_list()
    end)

    Set_Button()
end















function WoWTools_MailMixin:Init_Send_History_Name()--收件人，历史记录
    Init()
end