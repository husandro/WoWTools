--收件人，历史记录
local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end













local function Init()
    local historyButton= WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size=22, icon='hide'})
    SendMailMailButton.historyButton= historyButton

    historyButton:SetPoint('TOPRIGHT', SendMailFrame, 'TOPLEFT', 0, -22)
    historyButton.frame= CreateFrame('Frame', nil, historyButton)
    historyButton.frame:SetPoint('BOTTOMRIGHT')
    historyButton.frame:SetSize(1,1)
    historyButton.Text= WoWTools_LabelMixin:Create(historyButton, {justifyH='RIGHT', color={r=1,g=1,b=1}})--列表，数量
    historyButton.Text:SetPoint('BOTTOMRIGHT', 2, -2)

    historyButton.buttons={}
    function historyButton:created_button(index)
        local btn= WoWTools_ButtonMixin:Cbtn(self.frame, {size={22, 14}, icon='hide'})
        btn:SetPoint('TOPRIGHT', self.frame, 'BOTTOMRIGHT', 0, -(index-1)*14)
        btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
        btn.Text:SetPoint('RIGHT', -2, 0)

        btn:SetScript('OnLeave', function(frame) e.tips:Hide() frame:set_alpha() end)
        btn:SetScript('OnEnter', function(frame)
            e.tips:SetOwner(frame, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
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
        self.buttons[index]= btn
        return btn
    end

    function historyButton:set_list()
        self.Text:SetText(#Save().lastSendPlayerList)--列表，数量
        if Save().hideSendPlayerList then
            return
        end
        local index=1
        for _, name in pairs(Save().lastSendPlayerList) do
            if not WoWTools_MailMixin:GetRealmInfo(name) and name~=e.Player.name_realm then
                local btn= self.buttons[index] or self:created_button(index)
                btn.name=name
                btn:settings()
                index= index+1
            end
        end
        for i= index, #self.buttons, 1 do
            local btn= self.buttons[i]
            if btn then
                btn:clear()
            end
        end
    end

    historyButton:SetScript('OnEvent', function(self, event)
        if event=='MAIL_SEND_SUCCESS' then
            if self.SendName then--SendName，设置，发送成功，名字
                local find
                for index, name in pairs(Save().lastSendPlayerList) do
                    if name==self.SendName then
                        find= index
                        break
                    end
                end
                if find~=1 then
                    if find then
                        table.remove(Save().lastSendPlayerList, find)

                    elseif #Save().lastSendPlayerList>= Save().lastMaxSendPlayerList then
                        table.remove(Save().lastSendPlayerList )
                    end
                    table.insert(Save().lastSendPlayerList, 1, self.SendName)
                end
                self:set_list()--设置，历史记录，内容
                  WoWTools_MailMixin:SetSendName(self.SendName)
                self.SendName=nil
            end

        elseif event=='MAIL_FAILED' then
            self.SendName=nil
        end
    end)
    SendMailMailButton:HookScript('OnClick', function(self)
        self.historyButton.SendName= WoWTools_UnitMixin:GetFullName(SendMailNameEditBox:GetText())
    end)



    function historyButton:settings()
        self:SetNormalAtlas(Save().hideSendPlayerList and e.Icon.disabled or 'NPE_ArrowDown')
        self:SetAlpha(Save().hideSendPlayerList and 0.5 or 1)
        self.frame:SetScale(Save().scaleSendPlayerFrame or 1)
        self.frame:SetShown(not Save().hideSendPlayerList)
    end



    function historyButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scaleSendPlayerFrame or 1), e.Icon.mid)
        e.tips:Show()
    end
    historyButton:SetScript('OnLeave', GameTooltip_Hide)
    historyButton:SetScript('OnEnter', historyButton.set_tooltip)

    historyButton:SetScript('OnClick', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
                if menuList then
                    for index, name in pairs(Save().lastSendPlayerList) do
                        local realm= WoWTools_MailMixin:GetRealmInfo(name)
                        e.LibDD:UIDropDownMenu_AddButton({
                            text=WoWTools_MailMixin:GetNameInfo(name),
                            icon= realm and 'quest-legendary-available',
                            notCheckable=true,
                            tooltipOnButton=true,
                            tooltipTitle=name,
                            tooltipText=(e.onlyChinese and '移除' or REMOVE)..(realm and '|n'.. realm or ''),
                            arg1=index,
                            func=function(_, arg1)
                                local name2= Save().lastSendPlayerList[arg1]
                                table.remove(Save().lastSendPlayerList, arg1)
                                self:set_list()
                                print(e.addName, WoWTools_MailMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '移除' or REMOVE), name2)
                            end
                        }, level)
                    end

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                        notCheckable=true,
                        func= function()
                            Save().lastSendPlayerList={}
                            self:set_list()
                            print(e.addName, WoWTools_MailMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r',e.onlyChinese and '全部清除' or CLEAR_ALL))
                        end
                    }, level)
                    return
                end
                e.LibDD:UIDropDownMenu_AddButton({
                    text= e.GetShowHide(nil, true),
                    checked= not Save().hideSendPlayerList,
                    func= function()
                        Save().hideSendPlayerList= not Save().hideSendPlayerList and true or nil
                        self:settings()
                        self:set_list()
                    end
                }, level)

                local num= #Save().lastSendPlayerList
                e.LibDD:UIDropDownMenu_AddButton({
                    text= format('%s |cnGREEN_FONT_COLOR:#%d|r', e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER, num),
                    notCheckable=true,
                    disabled= num==0,
                    menuList='LIST',
                    hasArrow=true,
                }, level)
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    historyButton:SetScript('OnMouseWheel', function(self, d)
        local num= Save().scaleSendPlayerFrame or 1
        num= d==1 and num-0.05 or num
        num= d==-1 and num+0.05 or num
        num= num<0.4 and 0.4 or num
        num= num>4 and 4 or num
        Save().scaleSendPlayerFrame= num
        self:settings()
        self:set_tooltip()
    end)

    historyButton:SetScript('OnHide', historyButton.UnregisterAllEvents)
    historyButton:SetScript('OnShow', function(self)
        self:RegisterEvent('MAIL_SEND_SUCCESS')--SendName，设置，发送成功，名字
        self:RegisterEvent('MAIL_FAILED')
        self:set_list()
    end)

    historyButton:settings()
end







function WoWTools_MailMixin:Init_Send_History_Name()--收件人，历史记录
    Init()
end