WoWTools_WorldMixin={}

local P_Save={
    world= LOCALE_zhCN and '大脚世界频道' or 'World',
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
        text=WoWTools_WorldMixin.addName
            ..'|n|n'
            ..WoWTools_ChatMixin:GetButtonForName('World'):Get_myChatFilter_Text(),
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '修改' or EDIT,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow = function(self)
            local edit= self:GetEditBox()
            edit:SetNumeric(true)
            edit:SetNumber(Save().myChatFilterNum)
        end,
        OnAccept = function(self)
            local edit= self:GetEditBox()
            local num= edit:GetNumber()
            Save().myChatFilterNum= num
            print(
                WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_ChatMixin:GetButtonForName('World'):Get_myChatFilter_Text()
            )
        end,
        EditBoxOnTextChanged=function(self)
            local num= self:GetNumber() or 0
            local p= self:GetParent()
            local b1= p:GetButton1()
            b1:SetEnabled(num>=10 and num<2147483647)
        end,
        OnHide=function(self)
            local edit= self:GetEditBox()
            edit:SetNumeric(false)
            edit:ClearFocus()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }

    StaticPopupDialogs['WoWToolsChatWolrdAddPlayerNameChatFilter']= {
        text=(WoWTools_DataMixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE))
            ..'|n|n'..WoWTools_DataMixin.Player.Name_Realm..'|n'
            ..(WoWTools_DataMixin.onlyChinese and '名字-服务器' or 'Name-Realm'),-- format(FULL_PLAYER_NAME, NAME, VAS_REALM_LABEL)),
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '添加' or ADD,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow = function(self)
            local b1= self.button1 or self:GetButton1()
            b1:SetEnabled(false)
        end,
        OnHide= function(self)
            local edit= self:GetEditBox()
            edit:ClearFocus()
        end,
        OnAccept = function(self)
            local edit= self:GetEditBox()
            local text= edit:GetText() or ''
            if not text:find('%-') then
                text= text..'-'..WoWTools_DataMixin.Player.Realm
            end
            Save().userChatFilterTab[text]={num=0, guid=nil}
            print(
                WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '添加' or ADD,
                text,
                WoWTools_UnitMixin:GetPlayerInfo(nil, nil, text, {reName=true, reRealm=true, reLink=true})
            )
        end,
        EditBoxOnTextChanged=function(self)
            local text= self:GetText() or ''
            local enabled=true
            if text==''
                or text== WoWTools_DataMixin.Player.Name_Realm
                or text== UnitName('player')

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
            local p= self:GetParent()
            local b1= p:GetButton1()
            b1:SetEnabled(enabled)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }



    StaticPopupDialogs['WoWToolsChatButtonWorldChangeNamme']={
        text=(WoWTools_DataMixin.onlyChinese and '修改名称' or HUD_EDIT_MODE_RENAME_LAYOUT)..'|n|n'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI ),
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '确定' or OKAY,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow= function(self)
            local edit= self:GetEditBox()
            edit:SetAutoFocus(false)
            edit:SetText(WoWTools_DataMixin.Player.Region==5 and '大脚世界频道' and Save().world or 'World')
            local b1= self.button1 or self:GetButton1()
            b1:SetEnabled(false)
        end,
        OnHide= function(self)
            local edit= self:GetEditBox()
            edit:SetText("")
            edit:ClearFocus()
        end,
        OnAccept= function(self)
            local edit= self:GetEditBox()
            Save().world= edit:GetText()
            WoWTools_DataMixin:Reload()
        end,
        EditBoxOnTextChanged=function(self)
            local t= self:GetText() or ''
            local p= self:GetParent()
            local b1= p:GetButton1()
            b1:SetEnabled(t~= Save().world and t:gsub(' ', '')~='')
        end,
        EditBoxOnEscapePressed = function(s)
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

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButtonWorldChannel']= WoWToolsSave['ChatButtonWorldChannel'] or P_Save

            Save().myChatFilterPlayers= Save().myChatFilterPlayers or {}
            Save().userChatFilterTab= Save().userChatFilterTab or {}
            Save().lastName= Save().lastName or P_Save.world

            P_Save=nil

            WoWTools_WorldMixin.addName= '|A:tokens-WoW-generic-regular:0:0|a'..(WoWTools_DataMixin.onlyChinese and '频道' or CHANNEL)

            if WoWTools_ChatMixin:CreateButton('World', WoWTools_WorldMixin.addName) then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)
    end
end)
