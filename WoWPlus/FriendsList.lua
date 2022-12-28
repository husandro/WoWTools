local id, e = ...
local addName= FRIENDS_LIST
local Save={ Friends={}, }


--######
--初始化
--######
local function Init()--FriendsFrame.lua
    local name=UnitName('player')..GetRealmName();--好友列表,在线状态
    local optionText = '|A:honorsystem-bar-lock:0:0|a'..LOCK.."\124T%s.tga:16:16:0:0\124t %s";--好友列表
    Save.Friends[e.Player.name_server]=Save.Friends[e.Player.name_server] or {};
          
    hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
        if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(button.id);
            if ( info.connected ) and info.guid then
                local m='';
                if info.level and info.level~=MAX_PLAYER_LEVEL then m=m..'|cff00ff00'..info.level ..'|r' end                    
                if info.guid then
                    m=m..e.GetPlayerInfo(nil, info.guid)
                    if info.area then m=m..info.area end
                    if realm and realm~='' then m=m..(info.area and '-' or '')..realm end
                    button.info:SetText(m);

                end
            end
        elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then--2战网                
            local info2 = C_BattleNet.GetFriendAccountInfo(button.id);
            if not info2 then return end            
            local info=info2.gameAccountInfo;
            if not info then return end
            local m='';
            if info.characterLevel and info.characterLevel~=MAX_PLAYER_LEVEL  then m=m..'|cff00ff00'..info.characterLevel..'|r' end--等级
            if info.factionName then--派系
                if info.factionName=='Alliance' then 
                    m=m..'|A:charcreatetest-logo-alliance:0:0|a';
                elseif info.factionName=='Horde' then 
                    m=m..'|A:charcreatetest-logo-horde:0:0|a';
                end
            end
            
            if info.playerGuid then            
                m=e.GetPlayerInfo(nil, info.playerGuid)
            else
                if info.raceName then m=m..info.raceName end
            end                
            if info.areaName then                         
                if not info.richPresence or not info.richPresence:find(info.areaName) then                       
                    m=m..info.areaName;                        
                    if info.richPresence then m=m..'-' end
                end                    
            end--区域                
            if info.richPresence then m=m..info.richPresence:gsub(' %- ','%-') end                
            if m~='' then                 
                button.info:SetText(m);
            end
        end            
    end) 
    
    
    local Set=function()
        if Save.Friends[e.Player.name_server].Availabel then
            BNSetAFK(false);
            BNSetDND(false);
            print(id, addName,string.format(optionText, FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE));
        elseif Save.Friends[e.Player.name_server].Away then
            BNSetAFK(true);
            print(id, addName, string.format(optionText, FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY));
        elseif Save.Friends[e.Player.name_server].DND then
            BNSetDND(true);
            print(id, addName,string.format(optionText, FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY));
        end
    end
        
    hooksecurefunc('FriendsFrameStatusDropDown_Initialize', function(self)
        UIDropDownMenu_AddSeparator()
        local info= {
            text = optionText:format(FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE),
            checked= Save.Friends[e.Player.name_server].Availabel,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function() 
                Save.Friends[e.Player.name_server].Availabel = not Save.Friends[e.Player.name_server].Availabel and true or nil
                Save.Friends[e.Player.name_server].Away= nil
                Save.Friends[e.Player.name_server].DND= nil
                Set();
            end
        }
        UIDropDownMenu_AddButton(info)
        
        info= {
            text = optionText:format(FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY),
            checked= Save.Friends[e.Player.name_server].Away,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function() 
                Save.Friends[e.Player.name_server].Availabel = nil
                Save.Friends[e.Player.name_server].Away= not Save.Friends[e.Player.name_server].Away and true or nil
                Save.Friends[e.Player.name_server].DND=nil
                Set();
            end
        }
        UIDropDownMenu_AddButton(info)

        info= {
            text = optionText:format(FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY),
            checked= Save.Friends[e.Player.name_server].DND,
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func=function() 
                Save.Friends[e.Player.name_server].Availabel = nil
                Save.Friends[e.Player.name_server].Away=nil
                Save.Friends[e.Player.name_server].DND= not Save.Friends[e.Player.name_server].DND and true or nil
                Set();
            end
        }
        UIDropDownMenu_AddButton(info)
    end)
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
--                C_Timer.After(1, function()
                Init()
            end
            

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
