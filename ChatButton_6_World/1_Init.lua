WoWTools_WorldMixin={}

local P_Save={
    world= WoWTools_DataMixin.Player.Region==5 and '大脚世界频道' or 'World',
    myChatFilter= true,--过滤，多次，内容
    myChatFilterNum=70,

    myChatFilterAutoAdd= WoWTools_DataMixin.Player.husandro,
    myChatFilterPlayers={},--{[guid]=num,}

    userChatFilter=true,
    userChatFilterTab={},--{[name-realm]={num=0, guid=guid},}
}

local function Save()
    return WoWToolsSave['ChatButtonWorldChannel']
end










local function Init_Dialogs()
    StaticPopupDialogs['WoWToolsChatButtonWorldMyChatFilterNum']= {
        text=WoWTools_WorldMixin.addName..'|n|n'..WoWTools_WorldMixin.Button:Get_myChatFilter_Text(),
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '修改' or EDIT,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow = function(self)
            self.editBox:SetNumeric(true)
            self.editBox:SetNumber(Save().myChatFilterNum)
        end,
        OnAccept = function(self)
            local num= self.editBox:GetNumber()
            Save().myChatFilterNum= num
            print(WoWTools_DataMixin.addName, WoWTools_WorldMixin.addName, WoWTools_WorldMixin.Button:Get_myChatFilter_Text())
        end,
        EditBoxOnTextChanged=function(self)
            local num= self:GetNumber() or 0
            self:GetParent().button1:SetEnabled(num>=10 and num<2147483647)
        end,
        EditBoxOnEscapePressed = function(self2)
            self2:SetAutoFocus(false)
            self2:ClearFocus()
            self2:GetParent():Hide()
        end,
    }

    StaticPopupDialogs['WoWToolsChatWolrdAddPlayerNameChatFilter']= {
        text=(WoWTools_DataMixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE))
            ..'|n|n'..WoWTools_DataMixin.Player.name_realm..'|n',
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '添加' or ADD,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow = function(self)
            self.button1:SetEnabled(false)
        end,
        OnHide= function(self)
            self.editBox:ClearFocus()
        end,
        OnAccept = function(self)
            local text= self.editBox:GetText()
            if not text:find('%-') then
                text= text..'-'..WoWTools_DataMixin.Player.realm
            end
            Save().userChatFilterTab[text]={num=0, guid=nil}
            print(WoWTools_DataMixin.Icon.icon2.. WoWTools_WorldMixin.addName, WoWTools_DataMixin.onlyChinese and '添加' or ADD, text, WoWTools_UnitMixin:GetPlayerInfo(nil, nil, text, {reName=true, reRealm=true, reLink=true}))
        end,
        EditBoxOnTextChanged=function(self)
            local text= self:GetText() or ''
            local enabled=true
            if text==''
                or text== WoWTools_DataMixin.Player.name_realm
                or text== WoWTools_DataMixin.Player.Name

                or text:find('^ ')
                or text:find(' $')

                or text:find('%.')
                or text:find('%+')
                or text:find('%*')
                or text:find('%?')
                or text:find('%[')
                or text:find('%^')
                or text:find('%$')
            then
                enabled=false
            end
            self:GetParent().button1:SetEnabled(enabled)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }



    StaticPopupDialogs['WoWToolsChatButtonWorldChangeNamme']={
        text=(WoWTools_DataMixin.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''))..'|n|n'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI ),
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=1,
        button1= WoWTools_DataMixin.onlyChinese and '确定' or OKAY,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow= function(s)
            s.editBox:SetAutoFocus(false)
            s.editBox:SetText(WoWTools_DataMixin.Player.Region==5 and '大脚世界频道' and Save().world or 'World')
            s.button1:SetEnabled(false)
            s.editBox:SetFoucus()
        end,
        OnHide= function(s)
            s.editBox:SetText("")
            s.editBox:ClearFocus()
        end,
        OnAccept= function(s)
            Save().world= s.editBox:GetText()
            WoWTools_Mixin:Reload()
        end,
        EditBoxOnTextChanged=function(s)
            local t= s:GetText()
            s:GetParent().button1:SetEnabled(t~= Save().world and t:gsub(' ', '')~='')
        end,
        EditBoxOnEscapePressed = function(s)
            s:SetAutoFocus(false)
            s:ClearFocus()
            s:GetParent():Hide()
        end,
    }

    Init_Dialogs=function()end
end
















local function Init()
    WoWTools_WorldMixin:Set_Button()
    WoWTools_WorldMixin:Init_Menu()
    WoWTools_WorldMixin:MENU_UNIT_FRIEND()
    WoWTools_WorldMixin:Set_Filters()

    Init_Dialogs()

    Init=function()end
end











local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButtonWorldChannel']= WoWToolsSave['ChatButtonWorldChannel'] or P_Save
            Save().myChatFilterPlayers= Save().myChatFilterPlayers or {}
            Save().userChatFilterTab= Save().userChatFilterTab or {}

            WoWTools_WorldMixin.addName= '|A:tokens-WoW-generic-regular:0:0|a'..(WoWTools_DataMixin.onlyChinese and '频道' or CHANNEL)
            WoWTools_WorldMixin.Button= WoWTools_ChatMixin:CreateButton('World', WoWTools_WorldMixin.addName)

            if WoWTools_WorldMixin.Button then--禁用Chat Button
                self:UnregisterEvent(event)
            else
                self:UnregisterAllEvents()
            end

        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        Init()
        self:UnregisterEvent(event)
    end
end)
