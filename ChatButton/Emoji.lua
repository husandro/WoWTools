local id, e = ...
local addName= 'Emoji'
local Save={
    Channels={},
    disabled= not e.Player.cn and not e.Player.husandro,
 }
local button

local frame--控制图标,显示,隐藏
local File={'Angel','Angry','Biglaugh','Clap','Cool','Cry','Cutie','Despise','Dreamsmile','Embarrass','Evil','Excited','Faint','Fight','Flu','Freeze','Frown','Greet','Grimace','Growl','Happy','Heart','Horror','Ill','Innocent','Kongfu','Love','Mail','Makeup','Meditate','Miserable','Okay','Pretty','Puke','Shake','Shout','Shuuuu','Shy','Sleep','Smile','Suprise','Surrender','Sweat','Tear','Tears','Think','Titter','Ugly','Victory','Volunteer','Wronged','Mario',}
local textFile

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

local function setframeEvent()--设置隐藏事件
    if Save.notHideCombat then
        frame:UnregisterEvent('PLAYER_REGEN_DISABLED')
    else
        frame:RegisterEvent('PLAYER_REGEN_DISABLED')
    end
    if Save.notHideMoving then
        frame:UnregisterEvent('PLAYER_STARTED_MOVING')
    else
        frame:RegisterEvent('PLAYER_STARTED_MOVING')
    end
end

local function setButtons()--设置按钮
    local size= 30
    local last, index, line=frame, 0, nil
    local function send(text, d)--发送信息
        text='{'..text..'}'
        if d =='LeftButton' then
            local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
            ChatFrameEditBox:Insert(text)
            ChatEdit_ActivateChat(ChatFrameEditBox)
        elseif d=='RightButton' then
            e.Chat(text)
        end
    end
    local function setPoint(btn, text)--设置位置, 操作
        if index>0 and select(2, math.modf(index / 10))==0 then
            btn:SetPoint('BOTTOMLEFT', line, 'TOPLEFT')
            line=btn
        else
            btn:SetPoint('BOTTOMLEFT', last, 'BOTTOMRIGHT')
            if index==0 then line=btn end
        end
        btn:SetScript('OnMouseDown', function(self, d) send(text, d) end)
        btn:SetScript('OnEnter', function(self)
            e.tips:SetOwner(frame, "ANCHOR_RIGHT", 0,125)
            e.tips:ClearLines()
            e.tips:AddLine(text)
            e.tips:Show()
        end)
        btn:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    for i, texture in pairs(File) do
        local btn=e.Cbtn(frame, {icon='hide',size={size,size}})
        setPoint(btn, textFile[i])
        btn:SetNormalTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\'..texture)
        last=btn
        index=index+1
    end
    for i= 1, 8 do
        local btn=e.Cbtn(frame, {icon='hide',size={size,size}})
        setPoint(btn, 'rt'..i)
        btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..i)
        last=btn
        index=index+1
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)
    local info
    if type then
        info={
            text= e.onlyChinese and '全选' or  MENU_EDIT_SELECT_ALL or ALL,--全选
            notCheckable=true,
            func=function()
                Save.Channels={}
                print(id, addName, e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '清除' or  SLASH_STOPWATCH_PARAM_STOP2,--全清
            notCheckable=true,
            func=function()
                for _, channel in pairs(Channels) do
                    Save.Channels[channel]=true
                end
                print(id, addName, e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        for _, channel in pairs(Channels) do
            info={
                text=_G[channel] or channel,
                checked=not Save.Channels[channel],
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
                tooltipText=channel,
                func=function()
                    Save.Channels[channel]= not Save.Channels[channel] and true or nil
                    print(id, addName, e.onlyChinese and '聊天频道' or CHAT_CHANNELS,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    else
        info={
            text= e.onlyChinese and '进入战斗' or ENTERING_COMBAT,--进入战斗时, 隐藏
            checked=not Save.notHideCombat,
            func=function() Save.notHideCombat = not Save.notHideCombat and true or nil setframeEvent() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '隐藏' or HIDE,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '移动' or NPE_MOVE,--移动时, 隐藏
            checked=not Save.notHideMoving,
            func=function() Save.notHideMoving = not Save.notHideMoving and true or nil setframeEvent() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '隐藏' or HIDE,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '过移图标时' or ENTER_LFG..EMBLEM_SYMBOL,--过移图标时,显示
            checked=Save.showEnter,
            func=function() Save.showEnter = not Save.showEnter and true or nil end,
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
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '重置' or RESET,
            notCheckable=true,
            func=function() Save=nil e.Reload() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '重新加载UI' or RELOADUI,
            colorCode='|cffff0000'
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
    button:SetPoint('LEFT', WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    frame=e.Cbtn(button,{icon='hide', size={10, 30}})--控制图标,显示,隐藏
    if Save.Point then
        frame:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
    else
        frame:SetPoint('BOTTOMRIGHT',button, 'TOPLEFT', -120,2)
    end
    frame:SetShown(false)
    frame:RegisterForDrag("RightButton")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    setframeEvent()--设置隐藏事件
    frame:SetScript('OnEvent', function(self) self:SetShown(false) end)
    frame:SetScript("OnDragStart", function(self,d )
        if not IsModifierKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
        print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
    end)
    frame:SetScript('OnMouseDown',function(self, d)
        local key=IsModifierKeyDown()
        if d=='RightButton' and IsAltKeyDown() then--还原
            Save.Point=nil
            self:ClearAllPoints()
            self:SetPoint('BOTTOMRIGHT',button, 'TOPLEFT', -120,2)
        elseif d=='RightButton' and not key then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then--提示信息
            print(id, addName, NPE_MOVE..e.Icon.right)
        end
    end)
    frame:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    frame:SetScript("OnLeave",function()
        ResetCursor()
    end)

    

    setButtons()--设置按钮

    button.texture:SetTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\greet')
    button:SetScript('OnEnter', function()
        if Save.showEnter then
            frame:SetShown(true)
        end
    end)
    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            frame:SetShown(not frame:IsShown())
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)--主菜单
        end
    end)

    local Tab={}
    for index, text in pairs(textFile) do
        Tab['{'..text..'}']= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\'..File[index]..':0|t'
    end
    local function ChatEmoteFilter(self, event, msg, ...)
        local str=msg
        for text, icon in pairs(Tab) do
            str= str:gsub(text, icon)
        end
        if str ~=msg then
            return false, str, ...
        end
    end

    for _, channel in pairs(Channels) do
        if not Save.Channels[channel] then
            ChatFrame_AddMessageEventFilter(channel, ChatEmoteFilter)
        end
    end
end

--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.Channels= Save.Channels or {}

            local sel=CreateFrame("CheckButton", nil, WoWToolsChatButtonFrame.sel, "InterfaceOptionsCheckButtonTemplate")
            sel.text:SetText('|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\greet:0|tEmoji')
            sel:SetPoint('LEFT', WoWToolsChatButtonFrame.sel.text, 'RIGHT')
            sel:SetChecked(not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if not (WoWToolsChatButtonFrame.disabled or Save.disabled) then--禁用Chat Button
                button=e.Cbtn2('WoWToolsChatButtonEmoji', WoWToolsChatButtonFrame, true, false)

                if LOCALE_zhCN then
                    textFile= {'天使','生气','大笑','鼓掌','酷','哭','可爱','鄙视','美梦','尴尬','邪恶','兴奋','晕','打架','流感','呆','皱眉','致敬','鬼脸','龇牙','开心','心','恐惧','生病','无辜','功夫','花痴','邮件','化妆','沉思','可怜','好','漂亮','吐','握手','喊','闭嘴','害羞','睡觉','微笑','吃惊','失败','流汗','流泪','悲剧','想','偷笑','猥琐','胜利','雷锋','委屈','马里奥'}
                elseif LOCALE_koKR then
                    textFile= {'천사','화난','웃음','박수','시원함','울음','귀엽다','경멸','꿈','당혹 스러움','악','흥분','헤일로','싸움','독감','머무르기','찡그림','공물','grimface','눈에띄는이빨','행복','심장','두려움','나쁜','순진한','쿵푸','관용구','메일','메이크업','명상','나쁨','좋은','아름다운','침','악수','외침','닥치기','수줍음','수면','웃음','놀라움','실패','땀','눈물','비극','생각하기','shirking','걱정','victory','hero','wronged','Mario'}
                elseif LOCALE_frFR then
                    textFile= {'ange','en colère','riant','applaudissements','cool','pleurant','mignon','dédain','rêve','embarras','mal','excité','halo','se battre','grippe','rester','fronçant les sourcils ','salut','grimace','voile','heureux','cœur','peur','malade','innocent','KungFu','nympho','mail','maquillage','contemplation','pauvre','bon','joli','cracher','poignée de main','crier','se taire','timide','dormir','sourire','surpris','échec','sueur','larmes','tragédie','penser','ricaner','obscène','victoire',' héros','grief','Mario'}
                elseif LOCALE_deDE then
                    textFile= {'engel','wütend','lachen','applaus','cool','weinen','süß','verachtung','traum','verlegenheit','böse','aufgeregt','heiligenschein','kämpfen','grippe','bleiben','stirnrunzeln','gruß','grimace','segeln','glücklich','herz','angst','krank','unschuldig','KungFu','nymphoman','mail','schminke','nachdenklichkeit','arm','gut','hübsch','spucken','händedruck','schrei','halt die klappe','schüchtern','schlaf','lächeln','überrascht','versagen','schweiß','tränen','tragödie','denken','kichern','obszön','sieg','held','beschwerde','Mario'}
                elseif LOCALE_esES or LOCALE_esMX then
                    textFile= {'ángel','enojado','riendo','aplausos','guay','llorando','lindo','desdén','soñar','vergüenza','maldad','emocionado','halo','pelea','gripe','quedarse','frunciendo el ceño ','saludo','mueca','navegar','feliz','corazón','miedo','enfermo','inocente','KungFu','ninfómana','gorreo','maquillaje','contemplación','pobre','bueno','bonita','escupir','apretón de manos','gritar','cállate','tímido','dormir','sonreír','sorprendido','fallar','sudar','lágrimas','tragedia','pensar','risitas','obsceno','victoria','héroe','queja','Mario'}
                elseif LOCALE_zhTW then
                    textFile= {'天使','生氣','大笑','鼓掌','酷','哭','可愛','鄙視','美夢','尷尬','邪惡','興奮','暈','打架','流感','呆','皺眉','致敬','鬼臉','齜牙','開心','心','恐懼','生病','無辜','功夫','花痴','郵件','化妝','沉思','可憐','好','漂亮','吐','握手','喊','閉嘴','害羞','睡覺','微笑','吃驚','失敗','流汗','流淚','悲劇','想','偷笑','猥瑣','勝利','雷鋒','委屈','馬里奧'}
                elseif LOCALE_ruRU then
                    textFile= {'ангел','злость','смех','аплодисменты','клевые','плакать','милый','презирающий','красивая мечта','смущение','зло','возбуждение','головокружение','драка','грипп','тупость','морщины','почтение','грим','гримаса','гримаса','гримаса','гримаса','жалость','красивая','плюнь','рукопожатие','крик','заткнись','застенчивость','спать','улыбка','удивление','неудача','потение','слезы','трагедия','хохот','воровство','мелочь','победа','гром','обида','Марио'}
                elseif LOCALE_ptBR then
                    textFile= {'anjo','irritado','rindo','aplauso','legal','chorando','fofo','desdém','sonho','embaraço','mal','excitado','halo','luta','gripe','fique','franzindo a testa','saudação','careta','navega','feliz','coração','medo','doente','inocente','KungFu','ninfo','correio','maquiagem','contemplação','pobre','bom','bonito','cuspir','aperto de mão','gritar','cala a boca','tímido','dormir','sorriso','surpreso','falhar','suar','lágrimas','tragédia','pensar','risada','obsceno','vitória','herói','queixa','mario'}
                elseif LOCALE_itIT then
                    textFile= {'angelo','arrabbiato','risata','applauso','freddo','piange','carino','disprezza','sogno','imbarazzato','cattivo','eccitato','alone','lotta','influenza','resta','accigliato ','omaggio','faccia torva','denti che colpiscono','felice','cuore','paura','ill','innocente','KungFu','idioma','mail','trucco','meditazione','povero','buono','bello','sputa','stretta di mano','grida','zitto','timido','dormiente','sorridente','sorpreso','fallimento','sudore','lacrima','tragedia','pensando','sorprendendosi','preoccupante','vittoria','hero','wronged','Mario'}
                else
                    textFile=File
                end

                Init()
            else
                File=nil
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
