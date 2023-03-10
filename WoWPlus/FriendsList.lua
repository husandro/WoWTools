local id, e = ...
local addName= FRIENDS_LIST
local Save={Friends={}, }

--#############
--快速加入, 模块
--#############
local function set_SOCIAL_QUEUE_UPDATE()--更新, 快速加入
    if QuickJoinToastButton then
        if not QuickJoinToastButton.quickJoinText then
            QuickJoinToastButton.quickJoinText= QuickJoinToastButton:CreateFontString()
            QuickJoinToastButton.quickJoinText:SetFontObject('NumberFontNormal')
            QuickJoinToastButton.quickJoinText:SetPoint('TOPRIGHT', -6, -3)
        end

        local n=#C_SocialQueue.GetAllGroups()
        QuickJoinToastButton.quickJoinText:SetText(n~=0 and n or '')
    end
end
local function set_QuinkJoin_Init()--快速加入, 初始化
    set_SOCIAL_QUEUE_UPDATE()

    hooksecurefunc(QuickJoinEntryMixin, 'ApplyToFrame', function(self, frame)
            if not frame then return end

            local icon, icon2 = nil, ''--角色图标
            if self.guid then
                local guid= select(8, C_SocialQueue.GetGroupInfo(self.guid))
                if guid then
                    local _, class, _, race, sex = GetPlayerInfoByGUID(guid)
                    if race and sex then
                        icon=e.Race(nil, race, sex, true)
                    end
                    if class then
                        icon2='groupfinder-icon-class-'..class
                    end
                end

                if not frame.chat then--悄悄话
                    frame.chat=e.Cbtn(frame, {icon='hide', size={20,20}})
                    frame.chat:SetPoint('RIGHT', (frame.Icon or frame), 'LEFT')
                    frame.chat:SetScript('OnMouseDown',function()
                        local player=frame.Members[1].playerLink
                        if player then
                            local link, text = LinkUtil.SplitLink(player)
                            SetItemRef(link, text, "LeftButton")
                        end
                    end)
                    frame:HookScript("OnDoubleClick", function()
                        QuickJoinFrame:JoinQueue()
                    end)
                end
                icon=icon or 'communities-icon-chat'
                frame.chat:SetNormalAtlas(icon)

                if not frame.class and icon2 then--角色职业图标
                    frame.class=frame:CreateTexture()
                    frame.class:SetSize(20,20)
                    frame.class:SetPoint('RIGHT', frame, 'RIGHT', 0,0)
                end

                if frame.class then--种族图标
                    if icon2 then
                        frame.class:SetAtlas(icon2)
                    end
                    frame.class:SetShown(icon2 and true or false)
                end
            end
    end)

    hooksecurefunc(QuickJoinRoleSelectionFrame, 'ShowForGroup', function(self, guid)--职责选择框
        local t, h ,dps=self.RoleButtonTank.CheckButton, self.RoleButtonHealer.CheckButton, self.RoleButtonDPS.CheckButton--选择职责
        local t3, h3, dps3 =t:GetChecked(), h:GetChecked(), dps:GetChecked()
        if not t3 and  not h3 and not dps3 then
            local sid=GetSpecialization()
            if sid and sid>0 then
                local role = select(5, GetSpecializationInfo(sid))
                if role=='TANK' then
                    t:Click()
                elseif role=='HEALER' then
                    h:Click()
                elseif role=='DAMAGER' then
                    dps:Click()
                end
            end
        end

        local player= select(8, C_SocialQueue.GetGroupInfo(guid))--玩家名称
        if player then
            local name, realm = select(6, GetPlayerInfoByGUID(player))
            if name then
                if not self.name then
                    self.name=self:CreateFontString()
                    self.name:SetFontObject('GameFontNormal')
                    self.name:SetPoint('BOTTOM', self.CancelButton, 'TOPLEFT', 2, 0)
                end
                if realm and realm=='' then realm=nil end
                name=name..(realm and ' - '..realm or '')
                self.name:SetText(name)
            else
                if self.name then self.name:SetText('') end
            end
        end
    end)

    if QuickJoinToastButton.Toast then
        QuickJoinToastButton.Toast:ClearAllPoints()
        QuickJoinToastButton.Toast:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT')
    end
end


--#############
--好友列表, 模块
--#############
local function set_FriendsList_Init()--好友列表, 初始化
    local optionText = '|A:honorsystem-bar-lock:0:0|a'..(e.onlyChinese and '锁定' or LOCK).."\124T%s.tga:16:16:0:0\124t %s"--好友列表
    Save.Friends[e.Player.name_server]=Save.Friends[e.Player.name_server] or {}

    hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
        if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(button.id)
            if ( info.connected ) and info.guid then
                local m=''
                if info.level and info.level~=MAX_PLAYER_LEVEL then m=m..'|cff00ff00'..info.level ..'|r' end
                if info.guid then
                    m=m..e.GetPlayerInfo(nil, info.guid)
                    if info.area then m=m..info.area end
                    --if realm and realm~='' then m=m..(info.area and '-' or '')..realm end
                    button.info:SetText(m)

                end
            end
        elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then--2战网                
            local info2 = C_BattleNet.GetFriendAccountInfo(button.id)
            if not info2 then return end
            local info=info2.gameAccountInfo
            if not info then return end
            local m=''
            if info.characterLevel and info.characterLevel~=MAX_PLAYER_LEVEL  then m=m..'|cff00ff00'..info.characterLevel..'|r' end--等级
            if info.factionName then--派系
                if info.factionName=='Alliance' then
                    m=m..'|A:charcreatetest-logo-alliance:0:0|a'
                elseif info.factionName=='Horde' then
                    m=m..'|A:charcreatetest-logo-horde:0:0|a'
                end
            end

            if info.playerGuid then
                m=e.GetPlayerInfo(nil, info.playerGuid)
            else
                if info.raceName then m=m..info.raceName end
            end
            if info.areaName then
                if not info.richPresence or not info.richPresence:find(info.areaName) then
                    m=m..info.areaName
                    if info.richPresence then m=m..'-' end
                end
            end--区域                
            if info.richPresence then m=m..info.richPresence:gsub(' %- ','%-') end
            if m~='' then
                button.info:SetText(m)
            end
        end
    end)


    local Set=function()
        if Save.Friends[e.Player.name_server].Availabel then
            BNSetAFK(false)
            BNSetDND(false)
            print(id, addName,string.format(optionText, FRIENDS_TEXTURE_ONLINE, e.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE))
        elseif Save.Friends[e.Player.name_server].Away then
            BNSetAFK(true)
            print(id, addName, string.format(optionText, FRIENDS_TEXTURE_AFK, e.onlyChinese and '离开' or FRIENDS_LIST_AWAY))
        elseif Save.Friends[e.Player.name_server].DND then
            BNSetDND(true)
            print(id, addName,string.format(optionText, FRIENDS_TEXTURE_DND, e.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY))
        end
    end

    hooksecurefunc('FriendsFrameStatusDropDown_Initialize', function(self)
        UIDropDownMenu_AddSeparator()
        local info= {
            text = optionText:format(FRIENDS_TEXTURE_ONLINE, e.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE),
            checked= Save.Friends[e.Player.name_server].Availabel,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function()
                Save.Friends[e.Player.name_server].Availabel = not Save.Friends[e.Player.name_server].Availabel and true or nil
                Save.Friends[e.Player.name_server].Away= nil
                Save.Friends[e.Player.name_server].DND= nil
                Set()
            end
        }
        UIDropDownMenu_AddButton(info)

        info= {
            text = optionText:format(FRIENDS_TEXTURE_AFK, e.onlyChinese and '离开' or FRIENDS_LIST_AWAY),
            checked= Save.Friends[e.Player.name_server].Away,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function()
                Save.Friends[e.Player.name_server].Availabel = nil
                Save.Friends[e.Player.name_server].Away= not Save.Friends[e.Player.name_server].Away and true or nil
                Save.Friends[e.Player.name_server].DND=nil
                Set()
            end
        }
        UIDropDownMenu_AddButton(info)

        info= {
            text = optionText:format(FRIENDS_TEXTURE_DND, e.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY),
            checked= Save.Friends[e.Player.name_server].DND,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function()
                Save.Friends[e.Player.name_server].Availabel = nil
                Save.Friends[e.Player.name_server].Away=nil
                Save.Friends[e.Player.name_server].DND= not Save.Friends[e.Player.name_server].DND and true or nil
                Set()
            end
        }
        UIDropDownMenu_AddButton(info)
    end)
end


--#########
--团队, 模块
--Blizzard_RaidUI.lua
--[[subframes = {};
subframes.name = _G["RaidGroupButton"..i.."Name"];
subframes.class = _G["RaidGroupButton"..i.."Class"];
subframes.level = _G["RaidGroupButton"..i.."Level"];
subframes.rank = _G["RaidGroupButton"..i.."Rank"];
subframes.role = _G["RaidGroupButton"..i.."Role"];
subframes.rankTexture = _G["RaidGroupButton"..i.."RankTexture"];
subframes.roleTexture = _G["RaidGroupButton"..i.."RoleTexture"];
subframes.readyCheck = _G["RaidGroupButton"..i.."ReadyCheck"];
button.subframes = subframes;
]]
local setRaidGroupFrameLabel
local function set_RaidGroupFrame_Update()--团队, 模块
    if not IsInRaid() then
        return
    end
    local itemLevel, itemNum, afkNum, deadNum, notOnlineNum= 0,0,0,0,0
    for i=1, MAX_RAID_MEMBERS do
        local button = _G["RaidGroupButton"..i]
        if button and button.subframes then
            local subframes = button.subframes
            local unit = "raid"..i
            if subframes and UnitExists(unit) then
                local name, _, _, level, _, fileName, _, online, isDead, role, _, combatRole = GetRaidRosterInfo(i)
                local guid= UnitGUID(unit)

                afkNum= UnitIsAFK(unit) and (afkNum+1) or afkNum
                deadNum= isDead and (deadNum+1) or deadNum
                notOnlineNum= not online and (notOnlineNum+1) or notOnlineNum

                if subframes.name and name then
                    local text
                    if name==e.Player.name then--自己
                        text= COMBATLOG_FILTER_STRING_ME
                    end
                    if not text then--距离
                        local distance, checkedDistance = UnitDistanceSquared(unit)
                        if checkedDistance then
                            if distance and distance > DISTANCE_THRESHOLD_SQUARED then
                                text= e.GetUnitMapName(unit)--单位, 地图名称
                                if text then
                                    text= e.Icon.map2..'|cnGREEN_FONT_COLOR:'..text..'|r'
                                end
                            end
                        end
                    end

                    text= text or e.PlayerOnlineInfo(unit)--状态

                    if not text then--处理名字
                        text= name:gsub('(%-.+)','')--名称
                        text= e.WA_Utf8Sub(text, 3, 7)
                    end
                    if text then
                        subframes.name:SetText(text)
                    end
                end

                if subframes.class and fileName then
                    local text
                    if e.UnitItemLevel[guid] and e.UnitItemLevel[guid].specID then
                        local texture= select(4, GetSpecializationInfoForSpecID(e.UnitItemLevel[guid].specID))
                        if texture then
                            text= "|T"..texture..':0|t'
                        end
                    end
                    text= text or e.Class(nil, fileName)--职业图标

                    if text then
                        if guid and e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel then
                            text= e.UnitItemLevel[guid].itemLevel..text
                            itemLevel= itemLevel+ e.UnitItemLevel[guid].itemLevel
                            itemNum= itemNum+1
                        else
                            e.GetGroupGuidDate()--队伍数据收集
                        end
                        local role2= role or combatRole
                        if role2=='TANK'then
                            text= INLINE_TANK_ICON..text
                        elseif role2=='HEALER' then
                            text= INLINE_HEALER_ICON..text
                        end
                        subframes.class:SetText(text)
                        subframes.class:SetJustifyH('RIGHT')
                    end
                end

                if subframes.level and level==MAX_PLAYER_LEVEL then
                    local text= e.Race(unit) or ''
                    subframes.level:SetText(text)
                end
            end
        end
    end
    if FriendsFrameTitleText then
        local text= '|A:charactercreate-gendericon-male-selected:0:0|a'..(itemNum==0 and 0 or format('%i',itemLevel/itemNum))
        text= text..'  |cnGREEN_FONT_COLOR:'..itemNum..'|r/'..GetNumGroupMembers()..'|cnRED_FONT_COLOR:'--人数
        text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)..notOnlineNum--不在线, 人数
        text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK)..afkNum--AFK
        text= text..'  |A:deathrecap-icon-tombstone:0:0|a'..deadNum--死亡
        FriendsFrameTitleText:SetText(text)
        FriendsFrameTitleText:SetJustifyH('RIGHT')
    end
end


--######
--初始化
--######
local function Init()--FriendsFrame.lua
    set_QuinkJoin_Init()--快速加入, 模块
    set_FriendsList_Init()--好友列表, 模块
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('SOCIAL_QUEUE_UPDATE')--快速加入

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel('|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '好友列表' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_RaidUI' then
            hooksecurefunc('RaidGroupFrame_Update', set_RaidGroupFrame_Update)--团队, 模块
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='SOCIAL_QUEUE_UPDATE' then--更新, 快速加入
        set_SOCIAL_QUEUE_UPDATE()


    end

end)
