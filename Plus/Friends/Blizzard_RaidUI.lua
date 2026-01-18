--[[
团队, 模块 
Blizzard_RaidUI.lua

subframes = {};
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


local function Init_RaidGroupFrame_Update()
    if not IsInRaid() then
        if RaidFrame.groupInfoLable then
            RaidFrame.groupInfoLable:SetText('')
        end
        return
    end

    local itemLevel, itemNum, afkNum, deadNum, notOnlineNum= 0,0,0,0,0
    local getItemLevelTab={}--取得装等
    local setSize= WhoFrame:GetWidth()> 350
    local maxLevel= GetMaxLevelForLatestExpansion()
    local player= UnitName('player')
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
                    if name==player then--自己
                        text= WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME
                    end
                    if not text then--距离
                        local distance, checkedDistance = UnitDistanceSquared(unit)
                        if checkedDistance then
                            if distance and distance > DISTANCE_THRESHOLD_SQUARED then
                                text= WoWTools_MapMixin:GetUnit(unit)--单位, 地图名称
                                if text then
                                    text= '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
                                end
                            end
                        end
                    end

                    text= text or WoWTools_UnitMixin:GetOnlineInfo(unit)--状态

                    if not text and not setSize then--处理名字
                        text= name:gsub('(%-.+)','')--名称
                        text= WoWTools_TextMixin:sub(text, 3, 7)
                    end
                    if text then
                        subframes.name:SetText(text)
                    end
                end

                if subframes.class and fileName then
                    local text
                    if WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].specID then
                        local texture= select(4, GetSpecializationInfoForSpecID(WoWTools_DataMixin.UnitItemLevel[guid].specID))
                        if texture then
                            text= "|T"..texture..':0|t'
                        end
                    end
                    text= text or WoWTools_UnitMixin:GetClassIcon(nil, nil, fileName)--职业图标

                    if text then
                        if guid and WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel then
                            text= WoWTools_DataMixin.UnitItemLevel[guid].itemLevel..text
                            itemLevel= itemLevel+ WoWTools_DataMixin.UnitItemLevel[guid].itemLevel
                            itemNum= itemNum+1
                        else
                            table.insert(getItemLevelTab, unit)--取得装等
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

                if subframes.level and level==maxLevel then
                    subframes.level:SetText(WoWTools_UnitMixin:GetRaceIcon(unit, guid, nil) or '')
                end
            end
        end
    end
    if not RaidFrame.groupInfoLable then
        RaidFrame.groupInfoLable= WoWTools_LabelMixin:Create(RaidFrame, {copyFont=FriendsFrameTitleText, justifyH='CENTER'})
        RaidFrame.groupInfoLable:SetPoint('BOTTOM',FriendsFrame.TitleContainer, 'TOP')
    end
    local text= '|A:charactercreate-gendericon-male-selected:0:0|a'..(itemNum==0 and 0 or format('%i',itemLevel/itemNum))
    text= text..'  |cnGREEN_FONT_COLOR:'..itemNum..'|r/'..GetNumGroupMembers()..'|cnWARNING_FONT_COLOR:'--人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)..notOnlineNum--不在线, 人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK)..afkNum--AFK
    text= text..'  |A:deathrecap-icon-tombstone:0:0|a'..deadNum--死亡
    RaidFrame.groupInfoLable:SetText(text)
    WoWTools_UnitMixin:GetNotifyInspect(getItemLevelTab)--取得装等
end













local function Init()
    WoWTools_DataMixin:Hook('RaidGroupFrame_Update', function()
        Init_RaidGroupFrame_Update()
    end)

    RaidFrame:HookScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 1) + elapsed
        if self.elapsed>1 then
            self.elapsed=0
            if not PlayerIsInCombat() then
                WoWTools_DataMixin:Call('RaidGroupFrame_Update')
            end
        end
    end)

    RaidFrame:HookScript('OnHide', function(self)
        self.elapsed= nil
    end)


    Init=function()end
end





















function WoWTools_FriendsMixin:Blizzard_RaidUI()
    Init()
end