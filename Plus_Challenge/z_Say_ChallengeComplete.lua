--挑战结束时，显示按钮
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local SayButton








local function Settings(isSay, sayType)
    local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})

    if SayButton then
        if bagID and slotID then
            SayButton:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
            SayButton:SetItemButtonCount(C_MythicPlus.GetOwnedKeystoneLevel())
        else
            SayButton:Reset()
            local icon = GetItemButtonIconTexture(SayButton)
            if icon then
                icon:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
            end
        end

        SayButton.Text:SetText(info and (WoWTools_HyperLink:CN_Link(info.hyperlink, {itemID=info.itemID}))
            or ('|cff828282'..(WoWTools_DataMixin.onlyChinese and '史诗钥石' or PLAYER_DIFFICULTY_MYTHIC_PLUS))
        )
    end

    if not isSay or not info or not info.hyperlink then
        return
    end

    local text= (Save().EndKeystoneSayText or '')..info.hyperlink
    if not sayType then
        WoWTools_ChatMixin:Chat(text, nil, nil)

    elseif sayType=='WHISPER' then
        if UnitExists('target')
            and UnitIsPlayer('target')
            and UnitIsFriend('target', 'player')
        then
            SendChatMessage(text, "WHISPER", nil, UnitName("target"))
        end

    else
        SendChatMessage(text, sayType)--RAID PARTY
    end
end


--SendChatMessage("My, you're a tall one!", "WHISPER", nil, UnitName("target"))

--[[
"SAY"	/s, /say	

"EMOTE"	/e, /emote
"YELL"	/y, /yell	

"PARTY"	/p, /party
"RAID"	/ra, /raid
"RAID_WARNING"	/rw
"INSTANCE_CHAT"	/i, /instance
"GUILD"	/g, /guild
"OFFICER"	/o, /officer
"WHISPER"	/w, /whisper
/t, /tell
"CHANNEL"	/1, /2, ...	

"AFK"	/afk
"DND"	/dnd
"VOICE_TEXT"
]]




--修改，添加内容
local function Edit_Say_Text()
    StaticPopup_Show('WoWTools_EditText',
    (WoWTools_DataMixin.onlyChinese and '添加' or ADD),
    nil,
    {
        text= Save().EndKeystoneSayText
            or (WoWTools_DataMixin.Player.Region==5 and '{rt1}你们还继续吗? ')
            or (WoWTools_DataMixin.Player.Region==4 and '{rt1}還要繼續嗎? ')
            or (WoWTools_DataMixin.Player.Region==2 and '{rt1}계속하시겠습니까? ')
            or '{rt1}Want to continue? ',
        SetValue= function(s)
            local edit= s.editBox or s:GetEditBox()
            local text= edit:GetText() or ''
            Save().EndKeystoneSayText= text:gsub(' ', '')~='' and text or nil
            Settings(true)
        end,
        OnAlt=function()
            Save().EndKeystoneSayText=nil
        end,
    }
)
end
















local function Say_Menu(_, root)
    local sub, sub2

    local isFind= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})

    local function Set_Say_Menu_Tooltip(f)
        f:SetTooltip(function(tooltip)
            tooltip:AddLine(Save().EndKeystoneSayText or ('|cff828282'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)))
        end)
    end

    sub=root:CreateButton(
        (isFind and '' or '|cff828282')
        ..('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY)),
    function()
        Settings(true, nil)
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub)

--修改
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '修改' or EDIT,
    function()
        Edit_Say_Text()
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub2)


    local isRaid= IsInRaid()
    local isParty= not isRaid and IsInGroup()
    local isGuild= IsInGuild()
--目标
    root:CreateDivider()
    local target
    if UnitExists('target') and UnitIsPlayer('target') and UnitIsFriend('target', 'player') then
        target= WoWTools_UnitMixin:GetPlayerInfo('target', nil, nil, {reName=true, reRealm=false})
        target= target~='' and target or nil
    end
    sub=root:CreateButton(
        (isFind and target and '' or '|cff828282')
        .. (target or (WoWTools_DataMixin.onlyChinese and '目标' or TARGET)),
    function()
        Settings(true, 'WHISPER')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub)

    --小队
    sub=root:CreateButton(
        (isFind and isParty and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '小队' or CHAT_MSG_PARTY),
    function()
        Settings(true, 'PARTY')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub)

    --团队
    sub=root:CreateButton(
        (isFind and isRaid and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '团队' or RAID),
    function()
        Settings(true, 'RAID')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub)

    --公会
    sub=root:CreateButton(
        (isFind and isGuild and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD),
    function()
        Settings(true, 'GUILD')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub)

--发送信息
    root:CreateButton(
        (isFind and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE),
    function()
        local info= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, nil)
        end
        return MenuResponse.Open
    end)

--发送信息
    root:CreateButton(
        (isFind and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT),
    function()
        local info= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, true)
        end
        return MenuResponse.Open
    end)

--史诗钥石评分
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '史诗钥石评分' or DUNGEON_SCORE,
    function()
        local link= WoWTools_ChallengeMixin:GetDungeonScoreLink()
        WoWTools_ChatMixin:Chat(link, nil, nil)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_SetTooltipMixin:Setup(tooltip, {dungeonScore=true})
    end)
    
end








local function Init_Menu(self, root)
    if not self then
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '加载' or LOAD_ADDON:gsub(ADDONS,''),
        function()
            WoWTools_ChallengeMixin:Say_ChallengeComplete()
            Save().hideEndKeystoneSay= nil
            return MenuResponse.CloseAll
        end)
        return
    end

    local sub, sub2

    Say_Menu(self, root)

--打开选项界面
    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_ChallengeMixin.addName,
        name2='|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)}
    )

--总是显示
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
    function()
        return Save().allShowEndKeystoneSay
    end, function()
        Save().allShowEndKeystoneSay= not Save().allShowEndKeystoneSay and true or nil
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().endKeystoneSayScale or 1
    end, function(value)
        Save().endKeystoneSayScale= value
        self:set_scale()
    end)

--FrameStrata
    sub2=WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().endeystoneSayStrata= data
        self:set_scale()
    end)

--插入史诗钥石，打开界面
    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:ChallengeMode-KeystoneSlotFrame:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '插入史诗钥石' or CHALLENGE_MODE_INSERT_KEYSTONE),
    function()
        if not ChallengesKeystoneFrame then
            ChallengeMode_LoadUI()
        end
        ChallengesKeystoneFrame:SetShown(not ChallengesKeystoneFrame:IsShown())
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示UI' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, 'UI'))
    end)

--显示/隐藏
    sub:CreateDivider()
    sub:CreateButton(
        self:IsShown()
        and (WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
        or (WoWTools_DataMixin.onlyChinese and '显示' or SHOW),
    function()
        self:SetShown(not self:IsShown())
    end)
end
















local function Init()
    if Save().hideEndKeystoneSay then
        return
    end


    SayButton= WoWTools_ButtonMixin:Cbtn(nil, {
        isItem=true,
        name='WoWToolsPlusChallengesSayItemLinkButton',
    })

    SayButton.Text= WoWTools_LabelMixin:Create(SayButton)
    SayButton.Text:SetPoint('BOTTOM', SayButton, 'TOP',0, 4)

    SayButton:Hide()

    SayButton:SetMovable(true)
    SayButton:RegisterForDrag("RightButton")
    SayButton:SetClampedToScreen(true)

    SayButton:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    SayButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().sayButtonPoint={self:GetPoint(1)}
            Save().sayButtonPoint[2]= nil
        end
    end)

    SayButton:SetScript("OnMouseUp", ResetCursor)
    SayButton:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Settings(true)
        else
             MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
             end)
        end
    end)
    SayButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        WoWTools_BagMixin:Find(false)
    end)
    SayButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE)..'>', WoWTools_DataMixin.Icon.left..'|A:transmog-icon-chat:0:0|a')
        if Save().EndKeystoneSayText then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('|cffffffff'..Save().EndKeystoneSayText, nil,nil,nil,true)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        WoWTools_BagMixin:Find(true, {itemLocation = self:GetItemLocation()})
    end)

    if Save().sayButtonPoint then
        SayButton:SetPoint(Save().sayButtonPoint[1], UIParent, Save().sayButtonPoint[3], Save().sayButtonPoint[4], Save().sayButtonPoint[5])
    else
        SayButton:SetPoint('CENTER', 100, 100)
    end
    function SayButton:set_scale()
        self:SetScale(Save().endKeystoneSayScale or 1)
        self:SetFrameStrata(Save().endeystoneSayStrata or 'MEDIUM')
    end


    SayButton:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self:Reset()
    end)
    SayButton:SetScript('OnShow', function(self)
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        if not Save().allShowEndKeystoneSay then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
        end
        Settings(false)
    end)

    SayButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            if not IsInInstance() then
                self:Hide()
            end
        elseif event=='BAG_UPDATE_DELAYED' then
            Settings(false)
        end
    end)
    SayButton:Show()

    SayButton:set_scale()

    Init=function()
        SayButton:SetShown(not Save().hideEndKeystoneSay)
    end
end














function WoWTools_ChallengeMixin:Say_ChallengeComplete()
    Init()
end

function WoWTools_ChallengeMixin:Say_ChallengeComplete_Menu(_, root)
    Init_Menu(SayButton, root)
end

function WoWTools_ChallengeMixin:Say_Menu(...)
    Say_Menu(...)
end