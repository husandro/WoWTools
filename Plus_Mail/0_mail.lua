--受限模式
if GameLimitedMode_IsActive() then
    WoWTools_MailMixin={Save={disabled=true}}
    return
end

local id, e= ...

WoWTools_MailMixin={
Save={
    --hide=true,--隐藏
    --hideUIPlus=true,
    --hideSendNameList=true,
    --hideHistoryList=true,
    --hideItemButtonList=true

    --notAutoToSendFrame=true,--自动转到，收件箱
    --autoToSendFrameSecond=1,

    lastSendPlayerList= {},--历史记录, {'名字-服务器',},
    --hideSendPlayerList=true,--隐藏，历史记录
    lastMaxSendPlayerList=20,--记录, 最大数
    show={--显示离线成员
        ['FRIEND']=true,--好友
        --['GUILD']=true,--公会
    },
    fast={},--快速，加载，物品，指定玩家
    fastShow=true,--显示/隐藏，快速，加载，按钮
    --CtrlFast= WoWTools_DataMixin.Player.husandro,--Ctrl+RightButton,快速，加载，物品
    --scaleSendPlayerFrame=1.2,--清除历史数据，缩放
    scaleFastButton=1.3,
    --INBOXITEMS_TO_DISPLAY=7,
    logSendInfo= WoWTools_DataMixin.Player.husandro,--隐藏时不,清除，内容
    --lastSendPlayer='Fuocco-server',--收件人
    --lastSendSub=主题
    --lastSendBody=内容
},
}


local function Save()
    return WoWTools_MailMixin.Save
end



local function Is_Sandro()
    if not WoWTools_DataMixin.Player.husandro or #Save().lastSendPlayerList~=0 then
        return
    end
        --1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    if WoWTools_DataMixin.Player.Region==3 then
        Save().lastSendPlayerList= {
            'Zans-Nemesis',
            'Qisi-Nemesis',
            'Sandroxx-Nemesis',
            'Fuocco-Nemesis',
            'Sm-Nemesis',
            'Xiaod-Nemesis',
            'Dz-Nemesis',
            'Ws-Nemesis',
            'Sosi-Nemesis',
            'Maggoo-Nemesis',
            'Dhb-Nemesis',
            'Ms-Nemesis',--最大存20个
        }
        Save().fast={
            [WoWTools_Mixin.onlyChinese and '布甲' or C_Item.GetItemSubClassInfo(4, 1)]= 'Ms-Nemesis',--布甲
            [WoWTools_Mixin.onlyChinese and '皮甲' or C_Item.GetItemSubClassInfo(4, 2)]= 'Xiaod-Nemesis',--皮甲
            [WoWTools_Mixin.onlyChinese and '锁甲' or C_Item.GetItemSubClassInfo(4, 3)]= 'Fuocco-Nemesis',--锁甲
            [WoWTools_Mixin.onlyChinese and '板甲' or C_Item.GetItemSubClassInfo(4, 4)]= 'Zans-Nemesis',--板甲
            [WoWTools_Mixin.onlyChinese and '盾牌' or C_Item.GetItemSubClassInfo(4, 6)]= 'Zans-Nemesis',--盾牌
            [WoWTools_Mixin.onlyChinese and '武器' or C_Item.GetItemClassInfo(2)]= 'Zans-Nemesis',--武器

        }
    elseif WoWTools_DataMixin.Player.Region==4 then
        Save().lastSendPlayerList= {
            'Wowtools-巫妖之王',
        }
        Save().fast={}
    end
end















--设置，发送名称
function WoWTools_MailMixin:SetSendName(name, guid)
    name= name or WoWTools_UnitMixin:GetFullName(nil, nil, guid)
    if not name then
        return
    end
    name= name:gsub('%-'..WoWTools_DataMixin.Player.realm, '')
    SendMailNameEditBox:SetText(name)
    SendMailNameEditBox:SetCursorPosition(0)
    SendMailNameEditBox:ClearFocus()
    C_Timer.After(0.5, function()
        if SendMailSubjectEditBox:GetText()=='' then
            SendMailSubjectEditBox:SetText(EMOTE56_CMD1:gsub('/',''))
            SendMailSubjectEditBox:SetCursorPosition(0)
            SendMailSubjectEditBox:ClearFocus()
        end
    end)
end

--名称，信息
function WoWTools_MailMixin:GetNameInfo(name)
    if not name then
        return
    end
    local reName
    name = WoWTools_UnitMixin:GetFullName(name)--取得全名
    for guid, tab in pairs(WoWTools_WoWDate) do
        if name== WoWTools_UnitMixin:GetFullName(nil, nil, guid) then
            reName= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=tab.faction, reName=true, realm=true})
            break
        end
    end
    reName= reName or WoWTools_UnitMixin:GetPlayerInfo({name=name, reName=true, reRealm=true})
    return reName and reName:gsub('%-'..WoWTools_DataMixin.Player.realm, '') or name
end


--服务器，信息
function WoWTools_MailMixin:GetRealmInfo(name)
    if not name then
        return
    end
    local realm= name:match('%-(.+)')
    if realm and not (WoWTools_DataMixin.Player.Realms[realm] or realm==WoWTools_DataMixin.Player.realm) then
        return format('|cnRED_FONT_COLOR:%s|r', WoWTools_Mixin.onlyChinese and '该玩家与你不在同一个服务器' or ERR_PETITION_NOT_SAME_SERVER)
    end
end







function WoWTools_MailMixin:RefreshAll()
    if InboxFrame:IsShown() then
        WoWTools_Mixin:Call(InboxFrame_Update)
    elseif SendMailFrame:IsShown() then
        WoWTools_Mixin:Call(SendMailFrame_Update)
    end
    if OpenMailFrame:IsShown() then
        WoWTools_Mixin:Call(OpenMail_Update)
    end
end












local function set_to_send()
    if Save().lastSendPlayer then--收件人
        WoWTools_MailMixin:SetSendName(Save().lastSendPlayer)--设置，发送名称，文
    end
    if Save().lastSendSub then--主题
        SendMailSubjectEditBox:SetText(Save().lastSendSub)
    end
    if Save().lastSendBody then--内容
        SendMailBodyEditBox:SetText(Save().lastSendBody)
    end
    SendMailNameEditBox:ClearFocus()

    if not Save().notAutoToSendFrame then
        C_Timer.After(Save().autoToSendFrameSecond or 1, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(nil, 2)
            end
        end)
    end
end











--初始
local function Init()--SendMailNameEditBox
    WoWTools_MailMixin:Init_Menu_Button()

--收件箱 Plus
    WoWTools_MailMixin:Init_InBox()--收信箱，物品，提示

--UI Plus
    WoWTools_MailMixin:Init_UI()
    WoWTools_MailMixin:Init_Edit_Letter_Num()--字数
    WoWTools_MailMixin:Init_Clear_All_Send_Items()--清除所有，要发送物品

--名单列表
    WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表


--历史收件人
    WoWTools_MailMixin:Init_Send_History_Name()--收件人，历史记录

--物品快捷键
    WoWTools_MailMixin:Init_Fast_Button()
end











local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_MailMixin.Save= WoWToolsSave['Plus_Mail'] or Save()

            local addName= '|A:UI-HUD-Minimap-Mail-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '邮件' or BUTTON_LAG_MAIL)
            WoWTools_MailMixin.addName= addName

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            if not Save().disabled then
                Is_Sandro()
                self:RegisterEvent('MAIL_SHOW')
            end

            self:UnregisterEvent(event)
        end

    elseif event=='MAIL_SHOW' then
        set_to_send()
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Plus_Mail']=Save()
        end
    end
end)
