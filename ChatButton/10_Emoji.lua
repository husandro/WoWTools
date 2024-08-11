local id, e = ...
local addName= 'Emoji'
local Save={
    Channels={},
    disabled= not e.Player.cn and not e.Player.husandro,
    --Point={}
    --scale=1
    --show=true
    --On_Click_Show
    clickIndex=18,
    clickButton='RightButton',
}

local EmojiButton
local Frame
local File, FiileTexture
local Texture
local Channels={
    "CHAT_MSG_CHANNEL", -- 公共频道
    "CHAT_MSG_SAY",  -- 说
    "CHAT_MSG_YELL",-- 大喊
    "CHAT_MSG_RAID",-- 团队
    "CHAT_MSG_RAID_LEADER", -- 团队领袖
    "CHAT_MSG_PARTY", -- 队伍
    "CHAT_MSG_PARTY_LEADER", -- 队伍领袖
    "CHAT_MSG_GUILD",-- 公会
    "CHAT_MSG_AFK", -- AFK玩家自动回复
    "CHAT_MSG_DND", -- 切勿打扰自动回复
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_COMMUNITIES_CHANNEL", --社区聊天内容        
}

local function Init_Chat_Filter(_, _, msg, ...)
    local str=msg
    for text, icon in pairs(FiileTexture) do
        str= str:gsub(text, icon)
    end
    if str ~=msg then
        return false, str, ...
    end
end




local function send(text, d)--发送信息
    text='{'..text..'}'
    if d =='LeftButton' then
        local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
        ChatFrameEditBox:Insert(text)
        ChatEdit_ActivateChat(ChatFrameEditBox)
    elseif d=='RightButton' then
        e.Chat(text, nil, nil)
    end
end



local function Init_Buttons()--设置按钮
    local size= 30
    local last, index, line=Frame, 0, nil

    local function setPoint(btn, text)--设置位置, 操作
        if index>0 and select(2, math.modf(index / 10))==0 then
            btn:SetPoint('BOTTOMLEFT', line, 'TOPLEFT')
            line=btn
        else
            btn:SetPoint('BOTTOMLEFT', last, 'BOTTOMRIGHT')
            if index==0 then line=btn end
        end
        btn:SetScript('OnClick', function(self, d)
            send(text, d)
            Save.clickIndex= self:GetID()
            Save.clickButton=d
            EmojiButton:set_texture()
        end)
        btn:SetScript('OnEnter', function()
            e.tips:SetOwner(Frame, "ANCHOR_RIGHT", 0,125)
            e.tips:ClearLines()
            e.tips:AddLine(text)
            e.tips:Show()
        end)
        btn:SetScript('OnLeave', GameTooltip_Hide)
    end
    for i, texture in pairs(File) do
        local btn=e.Cbtn(Frame, {icon='hide',size=size, setID=i})
        setPoint(btn, File[i])
        btn:SetNormalTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\'..texture)
        last=btn
        index=index+1
    end

    local numFile= #File
    for i= 1, 8 do
        local btn=e.Cbtn(Frame, {icon='hide',size=size, setID= i+numFile})
        setPoint(btn, 'rt'..i)
        btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..i)
        last=btn
        index=index+1
    end
end








local function Init_EmojiFrame()
    Frame=e.Cbtn(UIParent, {icon='hide', size={10, 30}})--控制图标,显示,隐藏

    function Frame:set_point()
        self:ClearAllPoints()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('BOTTOMRIGHT',EmojiButton, 'TOPLEFT', -120,2)
        end
    end
    function Frame:set_scale()
        self:SetScale(Save.scale or 1)
    end

    Frame:SetShown(Save.show)
    Frame:RegisterForDrag("RightButton")
    Frame:SetMovable(true)
    Frame:SetClampedToScreen(true)


    Frame:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    Frame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)


    function Frame:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..Save.scale, 'Alt+'..e.Icon.mid)
        e.tips:Show()
    end
    Frame:SetScript("OnMouseUp", ResetCursor)
    Frame:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    Frame:SetScript("OnLeave",function()
        ResetCursor()
        e.tips:Hide()
        EmojiButton:SetButtonState('NORMAL')
    end)
    Frame:SetScript('OnEnter', function(self)
        self:set_tooltip()
        EmojiButton:SetButtonState('PUSHED')
    end)
    Frame:SetScript('OnMouseWheel', function(self, d)--缩放
        Save.scale=e.Set_Frame_Scale(self, d, Save.scale, nil)
    end)


    Frame:SetScript('OnClick',function(self, d)
        if IsAltKeyDown() and d=='RightButton' then
            return
        end
    end)
   

    Frame:set_point()
    Frame:set_scale()

    Init_Buttons()--设置按钮
end








--#####
--主菜单
--[[#####
local function InitMenu(_, level, type)
    local info
    if type then
        for _, channel in pairs(Channels) do
            info={
                text=_G[channel] or channel,
                checked=not Save.Channels[channel],
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
                tooltipText=channel,
                keepShownOnClick=true,
                func=function()
                    Save.Channels[channel]= not Save.Channels[channel] and true or nil
                    print(id, e.cn(addName), e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '全选' or ALL,--全选
            notCheckable=true,
            keepShownOnClick=true,
            func=function()
                Save.Channels={}
                print(id, e.cn(addName), e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,--全清
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            keepShownOnClick=true,
            func=function()
                for _, channel in pairs(Channels) do
                    Save.Channels[channel]=true
                end
                print(id, e.cn(addName), e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    else
    




    
        info={
            text= e.onlyChinese and '进入战斗' or ENTERING_COMBAT,--进入战斗时, 隐藏
            icon= 'Warfronts-BaseMapIcons-Horde-Barracks-Minimap',
            checked=not Save.notHideCombat,
            keepShownOnClick=true,
            func=function()
                Save.notHideCombat = not Save.notHideCombat and true or nil Frame:set_event()
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '隐藏' or HIDE,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '移动' or NPE_MOVE,--移动时, 隐藏
            icon= 'transmog-nav-slot-feet',
            checked=not Save.notHideMoving,
            func=function() Save.notHideMoving = not Save.notHideMoving and true or nil Frame:set_event() end,
            tooltipOnButton=true,
            keepShownOnClick=true,
            tooltipTitle= e.onlyChinese and '隐藏' or HIDE,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '过移图标时' or ENTER_LFG..EMBLEM_SYMBOL,--过移图标时,显示
            icon= 'newplayertutorial-drag-cursor',
            checked=Save.showEnter,
            keepShownOnClick=true,
            func=function()
                Save.showEnter = not Save.showEnter and true or nil
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '显示' or SHOW,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '聊天频道' or CHAT_CHANNELS,
            notCheckable=true,
            menuList='Channels',
            hasArrow=true,
            keepShownOnClick=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '重置' or RESET,
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            keepShownOnClick=true,
            func=function()
                Save=nil
                e.Reload()
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '重新加载UI' or RELOADUI,
            colorCode='|cffff0000'
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end]]















local function Init_Menu(self, root)
    local sub, sub2

    root:CreateCheckbox(e.onlyChinese and '显示' or SHOW, function()
        return Frame:IsShown()
    end, function()
        self:set_frame_shown(not Frame:IsShown())
    end)
    root:CreateDivider()

    sub=root:CreateButton(e.onlyChinese and '选项' or OPTIONS, function()
        return MenuResponse.Open
    end)

--隐藏
    sub:CreateTitle(e.onlyChinese and '隐藏' or HIDE)
    sub:CreateCheckbox('|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(e.onlyChinese and '进入战斗' or ENTERING_COMBAT), function()
        return not Save.notHideCombat
    end, function()
        Save.notHideCombat = not Save.notHideCombat and true or nil
        self:set_event()
    end)

    sub:CreateCheckbox('|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '移动' or NPE_MOVE), function()
        return not Save.notHideMoving
    end, function()
        Save.notHideMoving = not Save.notHideMoving and true or nil
        self:set_event()
    end)

--显示
    sub:CreateTitle(e.onlyChinese and '显示' or SHOW)
    sub:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '过移图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save.showEnter
    end, function()
        Save.showEnter = not Save.showEnter and true or nil
    end)

    sub:CreateCheckbox(e.Icon.left..(e.onlyChinese and '鼠标' or MOUSE_LABEL), function()
        return Save.On_Click_Show
    end, function()
        Save.On_Click_Show= not Save.On_Click_Show and true or false
    end)

    sub:CreateDivider()
    sub2=sub:CreateButton(e.onlyChinese and '聊天频道' or CHAT_CHANNELS, function()
        return MenuResponse.Refresh
    end)

    for _, channel in pairs(Channels) do
        sub2:CreateCheckbox(e.cn(_G[channel]) or channel, function(data)
            return not Save.Channels[data]
        end, function(data)
            Save.Channels[data]= not Save.Channels[data] and true or nil
            self:set_filter_event()
        end, channel)
    end

    sub2:CreateDivider()
    sub2:CreateButton(e.onlyChinese and '全选' or ALL, function()
        Save.Channels={}
        self:set_filter_event()
        return MenuResponse.Refresh
    end)
    sub2:CreateButton(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, function()
        for _, channel in pairs(Channels) do
            Save.Channels[channel]=true
        end
        self:set_filter_event()
        return MenuResponse.Refresh
    end)

    sub:CreateDivider()

    sub:CreateButton((Save.Point and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.Point=nil
        Frame:set_point()
        return MenuResponse.Refresh
    end)
end

















--初始
--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
local function Init()
    Texture={'Angel','Angry','Biglaugh','Clap','Cool','Cry','Cutie','Despise','Dreamsmile','Embarrass','Evil','Excited','Faint','Fight','Flu','Freeze','Frown','Greet','Grimace','Growl','Happy','Heart','Horror','Ill','Innocent','Kongfu','Love','Mail','Makeup','Meditate','Miserable','Okay','Pretty','Puke','Shake','Shout','Shuuuu','Shy','Sleep','Smile','Suprise','Surrender','Sweat','Tear','Tears','Think','Titter','Ugly','Victory','Hero','Wronged','Mario',}
    if e.Player.region==5 then
        File= {'天使','生气','大笑','鼓掌','酷','哭','可爱','鄙视','美梦','尴尬','邪恶','兴奋','晕','打架','流感','呆','皱眉','致敬','鬼脸','龇牙','开心','心','恐惧','生病','无辜','功夫','花痴','邮件','化妆','沉思','可怜','好','漂亮','吐','握手','喊','闭嘴','害羞','睡觉','微笑','吃惊','失败','流汗','流泪','悲剧','想','偷笑','猥琐','胜利','雷锋','委屈','马里奥'}
    elseif e.Player.region==4 then
        File= {'天使','生氣','大笑','鼓掌','酷','哭','可愛','鄙視','美夢','尷尬','邪惡','興奮','暈','打架','流感','呆','皺眉','致敬','鬼臉','齜牙','開心','心','恐懼','生病','無辜','功夫','花痴','郵件','化妝','沉思','可憐','好','漂亮','吐','握手','喊','閉嘴','害羞','睡覺','微笑','吃驚','失敗','流汗','流淚','悲劇','想','偷笑','猥瑣','勝利','英雄','委屈','馬里奧'}
    elseif e.Player.region==2 then
        File= {'천사','화난','웃음','박수','시원함','울음','귀엽다','경멸','꿈','당혹 스러움','악','흥분','헤일로','싸움','독감','머무르기','찡그림','공물','grimface','눈에띄는이빨','행복','심장','두려움','나쁜','순진한','쿵푸','관용구','메일','메이크업','명상','나쁨','좋은','아름다운','침','악수','외침','닥치기','수줍음','수면','웃음','놀라움','실패','땀','눈물','비극','생각하기','shirking','걱정','victory','hero','wronged','Mario'}
    else
        File=Texture
    end
    EmojiButton.numFile= #File
    
    FiileTexture={}
    for index, text in pairs(File) do
        FiileTexture['{'..text..'}']= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\'..Texture[index]..':0|t'
    end

    Init_EmojiFrame()

    function EmojiButton:get_emoji_text(index)
        index= index or Save.clickIndex or 18
        if index<=self.numFile then
            return File[index]
        else
            return 'rt'..(index-self.numFile)
        end
    end
    function EmojiButton:get_texture(index)
        index= index or Save.clickIndex or 18
        if index<=self.numFile then
            return 'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\'..Texture[index]
        else
            return 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..(index-self.numFile)
        end
    end

    function EmojiButton:set_texture()
        self.texture:SetTexture(self:get_texture())
    end


    function EmojiButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(format('|T%s:0|t%s', self:get_texture() or '' or self:get_emoji_text() or ''), e.Icon.left)
        e.tips:Show()
    end

    EmojiButton:SetScript('OnEnter', function(self)
        if Save.showEnter then
            self:set_frame_shown(true)
        end
        self:set_frame_state(true)
        self:set_tooltip()
        self:state_enter()
    end)
    EmojiButton:SetScript('OnLeave', function(self)
        self:set_frame_state(false)
        self:state_leave()
        e.tips:Hide()
    end)

    EmojiButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            send(self:get_emoji_text(), Save.clickButton or d)

            if Save.On_Click_Show then
                self:set_frame_shown(true)
            end


        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


--过滤，事件
    function EmojiButton:set_filter_event()
        for _, channel in pairs(Channels) do
            if not Save.Channels[channel] then
                ChatFrame_AddMessageEventFilter(channel, Init_Chat_Filter)
            else
                ChatFrame_RemoveMessageEventFilter(channel, Init_Chat_Filter)
            end
        end
    end

--Frame, 设置, State
    function EmojiButton:set_frame_state(isEenter)
        if Frame:IsShown() and isEenter then
            Frame:SetButtonState('PUSHED')
        else
            Frame:SetButtonState('NORMAL')
        end
    end

--Frame, 设置, 隐藏/显示
    function EmojiButton:set_frame_shown(show)
        Frame:SetShown(show)
    end

--Frame, 设置, 事件
    function EmojiButton:set_event()
        if Save.notHideCombat then
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
        else
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
        if Save.notHideMoving then
            self:UnregisterEvent('PLAYER_STARTED_MOVING')
        else
            self:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    EmojiButton:SetScript('OnEvent', function(self)
        self:set_frame_shown(false)
    end)

    EmojiButton:set_texture()
    EmojiButton:set_event()
    EmojiButton:set_filter_event()
end










--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            EmojiButton= WoWToolsChatButtonMixin:CreateButton('Emoji')
            if EmojiButton then--禁用Chat Button
                Save.scale= Save.scale or 1
                Save.Channels= Save.Channels or {}
                Save.clickIndex= Save.clickIndex or 18
                
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if Frame then
                Save.show= Frame:IsShown()
            end
            WoWToolsSave[addName]=Save
        end
    end
end)
--[[
elseif LOCALE_frFR then
    File= {'ange','en colère','riant','applaudissements','cool','pleurant','mignon','dédain','rêve','embarras','mal','excité','halo','se battre','grippe','rester','fronçant les sourcils ','salut','grimace','voile','heureux','cœur','peur','malade','innocent','KungFu','nympho','mail','maquillage','contemplation','pauvre','bon','joli','cracher','poignée de main','crier','se taire','timide','dormir','sourire','surpris','échec','sueur','larmes','tragédie','penser','ricaner','obscène','victoire',' héros','grief','Mario'}
elseif LOCALE_deDE then
    File= {'engel','wütend','lachen','applaus','cool','weinen','süß','verachtung','traum','verlegenheit','böse','aufgeregt','heiligenschein','kämpfen','grippe','bleiben','stirnrunzeln','gruß','grimace','segeln','glücklich','herz','angst','krank','unschuldig','KungFu','nymphoman','mail','schminke','nachdenklichkeit','arm','gut','hübsch','spucken','händedruck','schrei','halt die klappe','schüchtern','schlaf','lächeln','überrascht','versagen','schweiß','tränen','tragödie','denken','kichern','obszön','sieg','held','beschwerde','Mario'}
elseif LOCALE_esES or LOCALE_esMX then
    File= {'ángel','enojado','riendo','aplausos','guay','llorando','lindo','desdén','soñar','vergüenza','maldad','emocionado','halo','pelea','gripe','quedarse','frunciendo el ceño ','saludo','mueca','navegar','feliz','corazón','miedo','enfermo','inocente','KungFu','ninfómana','gorreo','maquillaje','contemplación','pobre','bueno','bonita','escupir','apretón de manos','gritar','cállate','tímido','dormir','sonreír','sorprendido','fallar','sudar','lágrimas','tragedia','pensar','risitas','obsceno','victoria','héroe','queja','Mario'}
elseif LOCALE_ruRU then
    File= {'ангел','злость','смех','аплодисменты','клевые','плакать','милый','презирающий','красивая мечта','смущение','зло','возбуждение','головокружение','драка','грипп','тупость','морщины','почтение','грим','гримаса','гримаса','гримаса','гримаса','жалость','красивая','плюнь','рукопожатие','крик','заткнись','застенчивость','спать','улыбка','удивление','неудача','потение','слезы','трагедия','хохот','воровство','мелочь','победа','гром','обида','Марио'}
elseif LOCALE_ptBR then
    --File= {'anjo','irritado','rindo','aplauso','legal','chorando','fofo','desdém','sonho','embaraço','mal','excitado','halo','luta','gripe','fique','franzindo a testa','saudação','careta','navega','feliz','coração','medo','doente','inocente','KungFu','ninfo','correio','maquiagem','contemplação','pobre','bom','bonito','cuspir','aperto de mão','gritar','cala a boca','tímido','dormir','sorriso','surpreso','falhar','suar','lágrimas','tragédia','pensar','risada','obsceno','vitória','herói','queixa','mario'}
elseif LOCALE_itIT then
    File= {'angelo','arrabbiato','risata','applauso','freddo','piange','carino','disprezza','sogno','imbarazzato','cattivo','eccitato','alone','lotta','influenza','resta','accigliato ','omaggio','faccia torva','denti che colpiscono','felice','cuore','paura','ill','innocente','KungFu','idioma','mail','trucco','meditazione','povero','buono','bello','sputa','stretta di mano','grida','zitto','timido','dormiente','sorridente','sorpreso','fallimento','sudore','lacrima','tragedia','pensando','sorprendendosi','preoccupante','vittoria','hero','wronged','Mario'}
]]
