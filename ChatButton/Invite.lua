local id, e = ...
local addName= INVITE
local Save={InvNoFriend={}}
local InvPlateGuid={}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function getLeader()--取得权限
    return UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player') or not IsInGroup()
end

local InvPlateTimer
local InvUnitFunc=function()--邀请，周围玩家
    local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player') or not IsInGroup();
    if not getLeader() then--取得权限
        print(id,addName, ERR_GUILD_PERMISSIONS)
        return
    end 
    
    local p=C_CVar.GetCVarBool('nameplateShowFriends');
    local all=C_CVar.GetCVarBool('nameplateShowAll');
    if not all then C_CVar.SetCVar('nameplateShowAll', 1) end
    if not p then C_CVar.SetCVar('nameplateShowFriends', 1) end
    
    if InvPlateTimer and not InvPlateTimer:IsCancelled() then
        return
    end
    
    InvPlateTimer=C_Timer.NewTicker(0.3, function()
            local n=0;
            local co=GetNumGroupMembers();
            local raid=IsInRaid();
            if (not raid and co==5) then 
                print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
                return
            elseif co==40 then
                print(id, addName, RED_FONT_COLOR_CODE..'|r',co,PLAYERS_IN_GROUP)        
            else 
                for _, v in pairs(C_NamePlate.GetNamePlates()) do
                    local u = v.namePlateUnitToken or (v.UnitFrame and v.UnitFrame.unit);                
                    local name=GetUnitName(u,true);
                    local guid=UnitGUID(u);
                    if name and guid and not UnitInAnyGroup(u) and not UnitIsAFK(u) and UnitIsConnected(u) and UnitIsPlayer(u) and UnitIsFriend(u, 'player') and not UnitIsUnit('player',u) then
                        if not InvPlateGuid[guid] then 
                            n=n+1 
                        end
                        
                        C_PartyInfo.InviteUnit(name); 
                        InvPlateGuid[guid]=name;                    
                        print(n..')',e.PlayerLink(nil, guid));
                        
                        if not raid and n +co>=5  then 
                            print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
                            break
                        end
                    end
                end
            end
            if not all then C_CVar.SetCVar('nameplateShowAll', 0) end
            if not p then C_CVar.SetCVar('nameplateShowFriends', 0) end
            if n==0 then print(GUILDCONTROL_OPTION7..': '..RED_FONT_COLOR_CODE..NONE..'|r') end
            
            if InvPlateTimer and InvPlateTimer:IsCancelled() then 
                InvPlateTimer:Cancel() 
            end
    end,1)
end

local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player') or not IsInGroup();
    if not getLeader() then--取得权限
        print(id, addName, ERR_GUILD_PERMISSIONS) 
        return
    end 
    local n=0;
    local co=GetNumGroupMembers();
    for guid, name in pairs(InvPlateGuid) do 
        C_PartyInfo.InviteUnit(name);         
        n=n+1;
        print(n..')'..e.PlayerLink(name, guid));
        if not raid and n +co>=5  then 
            print(PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
            break
        end        
    end
end

--#######
--初始菜单
--#######
local function InitList(self, level, type)
    local info
    if type then

        if type=='InvUnit' then--邀请单位    
            info={
                text=GUILDCONTROL_OPTION7,
                notCheckable=true,
                isTitle=true,
            }
            UIDropDownMenu_AddButton(info, level)
            
            info={--邀请LFD
                text=DUNGEONS_BUTTON,
                func=function() 
                    Save.LFGAutoInv= not Save.LFGAutoInv and true or nil
                    local f=(LFGListFrame and LFGListFrame.ApplicationViewer) and LFGListFrame.ApplicationViewer.DataDisplay.inv
                    if f then 
                        f:SetChecked(Save.LFGAutoInv)
                    end
                end,
                checked=Save.LFGAutoInv,
                tooltipOnButton=true,
                tooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..LEADER..'|r'),
            }
            UIDropDownMenu_AddButton(info, level);
            
            
            info={--邀请目标
                text=INVITE..TARGET,
                func=function()
                    Save.InvTar= not Save.InvTar and true or nil
                    checked=Save.InvTar
                end,
                disabled=IsInInstance() and true or nil,
                tooltipOnButton=true,
                tooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..LEADER..'|r')..AGGRO_WARNING_IN_PARTY,
            }
            UIDropDownMenu_AddButton(info, level)
            
            info={--已邀请列表
                text= LFG_LIST_APP_INVITED,--三级列表，已邀请列表
                notCheckable=true,
                menuList='InvUnitAll',
                hasArrow=true,
                func=InvPlateGuidFunc,
                tooltipOnButton=true;
                tooltipTitle=CALENDAR_INVITE_ALL,
            }
            UIDropDownMenu_AddButton(info, level);
            UIDropDownMenu_AddSeparator(level)
            
            info={--转团
                text=CONVERT_TO_RAID,
                func=function()
                    Save.PartyToRaid= not Save.PartyToRaid and true or nil
                    local f=(LFGListFrame and LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer.DataDisplay) and LFGListFrame.ApplicationViewer.DataDisplay.raid
                    if f then 
                        f:SetChecked(Save.PartyToRaid) 
                    end
                end,
                tooltipOnButton=true,
                ooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..DUNGEONS_BUTTON..'|r'),
                checked= Save.PartyToRaid,
            }
            UIDropDownMenu_AddButton(info, level);
            
            info={--预创建队伍增强
                text=LFGLIST_NAME..' Plus+',
                func=function()
                    Save.LFGPlus = not Save.LFGPlus and true or nil
                    print(id, addName, REQUIRES_RELOAD)
                end,
                checked=Save.LFGPlus,
                tooltipOnButton=true,
                tooltipTitle=PLAYER_DIFFICULTY5..', 2'..e.Icon.left,
                tooltipText=REQUIRES_RELOAD..' /reload'
            }
            UIDropDownMenu_AddButton(info, level)

        elseif type=='InvUnitAll' then--三级列表，已邀请列表
            local n, all=0, 0;
            for guid, name in pairs(InvPlateGuid) do
                if not IsGUIDInGroup(guid) then
                    info={
                        text=e.GetPlayerInfo(nil, guid, true),
                        notCheckable=true,
                        func=function() 
                            C_PartyInfo.InviteUnit(name)
                        end,
                        tooltipOnButton=true,
                        tooltipTitle=INVITE,
                    }
                    UIDropDownMenu_AddButton(info, level);
                    n=n+1;
                end
                all=all+1
            end
            if n==0 then
                info={
                    text=NONE;
                    notCheckable=true,
                    isTitle=true,
                }
                UIDropDownMenu_AddButton(info, level)
            else
                info={
                    text='|cff00ff00'..CALENDAR_INVITE_ALL..'|r',
                    notCheckable=true,
                    func= InvPlateGuidFunc,
                }
                UIDropDownMenu_AddButton(info, level)
                
                info={
                    text='|cff00ff00'..CLEAR_ALL..'|r '..n..'/'..all,
                    notCheckable=true,
                    func=function()
                        InvPlateGuid={}
                    end,
                }
                UIDropDownMenu_AddButton(info, lv);     
            end
        
        elseif type=='ACEINVITE' then--自动接爱邀请
            info={--队伍查找器
                text=CALENDAR_ACCEPT_INVITATION,
                isTitle=true;
                notCheckable=true;
            }
            UIDropDownMenu_AddButton(info, level)   
            
            info={
                text=DUNGEONS_BUTTON,
                checked=Save.LFGListAceInvite,
                func=function()
                    Save.LFGListAceInvite= not Save.LFGListAceInvite and true or nil
                    CloseDropDownMenus()
                    --if LFGListFrame.SearchPanel.ace then LFGListFrame.SearchPanel.ace:SetChecked(Save.LFGListAceInvite) end
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            info={--好友
                text=FRIENDS,
                checked=Save.FriendAceInvite,
                tooltipOnButton=true,
                tooltipTitle=COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD,
                func=function()
                    Save.FriendAceInvite= not Save.FriendAceInvite and true or nil
                    CloseDropDownMenus()
                end,
            }
            UIDropDownMenu_AddButton(info, level)  
        
        elseif type=='NoInv' then--拒绝邀请
            info={
                text=LFG_LIST_APP_INVITE_DECLINED,--三级列表，拒绝邀请列表
                notCheckable=true,
                menuList='NoInvList',
                hasArrow=true,
            }
            UIDropDownMenu_AddButton(info, level)
            
            info={
                text=RED_FONT_COLOR_CODE..CALENDAR_STATUS_OUT..'|r'..ZONE,--休息区拒绝组队  
                checked=Save.NoInvInResting,
                tooltipOnButton=true,
                tooltipTitle=RED_FONT_COLOR_CODE..SPELL_FAILED_CUSTOM_ERROR_464..'|r',
                tooltipText=CALENDAR_DECLINE_INVITATION..'|n'.. RED_FONT_COLOR_CODE.. VOICEMACRO_15_Ni_2..'|r'..TUTORIAL_TITLE22,
                func=function()
                    Save.NoInvInResting= not Save.NoInvInResting and true or nil
                end,
            }
            UIDropDownMenu_AddButton(info, lv)

        elseif type=='NoInvList' then--三级列表，拒绝邀请列表
            local all=0;
            for guid, nu in pairs(Save.InvNoFriend) do        
                local text=e.GetPlayerInfo(nil, guid, true)
                if text then
                    all=all+1
                    info={
                        text='|cff00ff00'..all..'|r)'..text..' |cff00ff00'..nu..'|r';
                        notCheckable=true,
                        func=function() 
                            Save.InvNoFriend[guid]=nil
                            print(id, addName, '|cff00ff00'..REMOVE..'|r: '..text);
                        end,
                        tooltipOnButton=true,
                        tooltipTitle=REMOVE,
                    }
                    UIDropDownMenu_AddButton(info, level)            
                end
            end    
            if all==0 then
                local info={
                    text=NONE,
                    notCheckable=true,
                    isTitle=true,
                }
                UIDropDownMenu_AddButton(info, level)
            else
                info={
                    text='|cff00ff00'..CLEAR_ALL..'|r '.. all,
                    notCheckable=true,
                    func=function()
                        Save.InvNoFriend={}
                        print(id, addName, '|cff00ff00'..CLEAR_ALL..'|r: ', DONE)
                    end,
                }
                UIDropDownMenu_AddButton(info, level)
            end
        end
    else
        info={--邀请成员
            text=GUILDCONTROL_OPTION7,
            notCheckable=true,
            menuList='InvUnit',
            func=InvUnitFunc,--邀请，周围玩家
            tooltipOnButton=true,
            tooltipTitle=INVITE..e.Icon.left..SPELL_RANGE_AREA:gsub(SPELL_TARGET_CENTER_CASTER,''),
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        
        info = {--接受邀请
            text= CALENDAR_ACCEPT_INVITATION,
            notCheckable=true,
            menuList='ACEINVITE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        
        info = {--拒绝邀请
            text=GUILD_INVITE_DECLINE,
            notCheckable=true,
            menuList='NoInv',
            hasArrow=true,
            tooltipOnButton=true,
            tooltipTitle=GUILD_INVITE_DECLINE..' |cff00ff00'..(Save.InvNoFriendNum or 0)..'|r '..VOICEMACRO_LABEL_CHARGE1,
        }
        UIDropDownMenu_AddButton(info, level)
    end
end
--####
--初始
--####
local function Init()
    panel.texture:SetAtlas('communities-icon-addgroupplus')

    panel.Menu= CreateFrame("Frame",nil, LFDMicroButton, "UIDropDownMenuTemplate")--菜单列表
    UIDropDownMenu_Initialize(panel.Menu, InitList, "MENU")
    
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            InvUnitFunc()--邀请，周围玩家
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
