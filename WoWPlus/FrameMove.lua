local id, e = ...
local Save={point={}}
local Frame=CreateFrame("Frame")

local Point=function(frame, name2)
    local p=Save.point
    p=p[name2];
    if p and p[1] and p[3] and p[4] and p[5] then
        local p2 = {frame:GetPoint(1)};
        if p2 and (p[1]~=p2[1] or p[3]~=p2[3] or p[4]~=p2[4] or p[5]~=p2[5]) then
            frame:ClearAllPoints();
            frame:SetPoint(p[1], UIParent, p[3], p[4], p[5]);
        end
    end;
end

local Move=function(F, tab)
    local F2, click, save, enter, show, fun=tab.frame, tab.click, tab.save, tab.enter, tab.show, tab.fun;--, tab.hook;    
    local name;
    if F2 then
        name=F2:GetName();
        if not name then return true end
        F2:SetClampedToScreen(save);
        F2:SetMovable(true);
    else
        F2=F;
        name=F:GetName();
        if not name then return true end
    end
    F:SetClampedToScreen(save and true or false);
    F:SetMovable(true);

    if click=='R' then
        F:RegisterForDrag("RightButton");
    elseif click=='L' then
        F:RegisterForDrag("LeftButton");
    else
        F:RegisterForDrag("LeftButton", "RightButton");
    end
    F:EnableMouse(true);
    F:SetScript("OnDragStart", function() F2:StartMoving() end);
    F:SetScript("OnDragStop", function()
            ResetCursor();
            F2:StopMovingOrSizing();
            if save then
                Save.point[name]={F2:GetPoint(1)}
            end;
    end);

    if save then
        Point(F2,name);
        local Re={F2:GetPoint(1)};
        F:SetScript("OnMouseUp", function(self,D)--还原 Alt+右击
                if D=='RightButton' and IsAltKeyDown() then
                    Save.point[name]=nil
                    F2:ClearAllPoints();
                    F2:SetPoint(Re[1],Re[2],Re[3],Re[4],Re[5]);
                    --print(name..': '..TRANSMOGRIFY_TOOLTIP_REVERT..'('..LOCK_FOCUS_FRAME..')|cffff0000/reload|r');
                end
                ResetCursor();
        end);
        if enter then 
            F:SetScript("OnEnter", function() Point(F2,name) end);
        end
        if show  then
            F:SetScript("OnShow", function() Point(F2,name) end);
        end
        --[[if hook then
            hook=hook:gsub(' ','');
            local  fr, ev=hook:match('(.+):(.+)');
            if fr and ev and _G[fr] then
                if _G[fr]:HasScript(ev) then                    
                    _G[fr]:HookScript(ev, function()
                            Point(F2,name);
                    end) 
                else
                    print(name..'('..NONE..')'..ev);                    
                end
            end            
        else]]if fun then
            fun=fun:gsub(' ','');
            local  fr, ev=fun:match('(.+):(.+)');
            if fr and ev and _G[fr] then
                hooksecurefunc(_G[fr], ev, function()
                        Point(F2,name);
                end)
            elseif _G[fun]  then
                hooksecurefunc(fun, function() Point(F2,name) end);
            end
        end
    end

    F:SetScript("OnMouseDown", function(self,d)
            if IsModifierKeyDown()
            or (click=='R' and d~='RightButton')
            or (click=='L' and d~='LeftButton')
            then return end
            SetCursor('UI_MOVE_CURSOR');
    end);
    F:SetScript("OnLeave", function() ResetCursor() end);
end


local FrameTab={
    ExtraActionButton1={save=true,},
    UIWidgetPowerBarContainerFrame={save=true,},
    ChatConfigFrame={save=true,},
    AddonList={save=true,},
    GameMenuFrame={save=true,},
    --ObjectiveTrackerBlocksFrame={click='R',},
    
    ClassTrainerFrame={},
    CharacterFrame={},
    EncounterJournal={},
    SpellBookFrame={},
    CommunitiesFrame={},
    PVEFrame={},
    DressUpFrame={},
    MacroFrame={},
    GossipFrame={},
    AuctionHouseFrame={},
    --AchievementFrameHeader={frame=AchievementFrame,},--9.0
    AchievementFrame={save=true},
    MerchantFrame={},
    WardrobeFrame={},
    BankFrame={},
    CompanionFrame={},
    ReputationDetailFrame={},
    SkillFrame={},
    --  HonorFrame={},
    PVPFrame={},
    PVPFrameHonor={},
    PVPFrameArena={},
    PVPTeam1={},
    PVPTeam2={},
    PVPTeam3={},
    DestinyFrame={},
    FriendsFrame={},
    RaidInfoFrame={},
    GuildInviteFrame={},
    GuildRegistrarFrame={},
    HelpFrame={},
    InterfaceOptionsFrame={},
    ItemTextFrame={},
    --  LFGParentFrame={},
    LootFrame={},
    PetitionFrame={},
    PetStableFrame={},
    ScenarioQueueFrameSpecific={},
    QuestFrame={},
    QuestLogFrame={},
    QuestLogPopupDetailFrame={},
    ReadyCheckFrame={},
    RecruitAFriendRecruitmentFrame={},
    RecruitAFriendRewardsFrame={},
    SplashFrame={},
    TabardFrame={},
    TaxiFrame={save=true},
    VideoOptionsFrame={},
    WorldMapFrame={save=true},
    WorldStateScoreFrame={},
    AlliedRacesFrame={},
    AnimaDiversionFrame={},
    ArchaeologyFrame={},
    ArcheologyDigsiteProgressBar={},
    ArtifactFrame={},
    AuctionFrame={},
    AzeriteRespecFrame={},
    BarberShopFrame={},
    KeyBindingFrame={},
    BlackMarketFrame={},
    CalendarFrame={},
    CalendarCreateEventFrame={},
    CalendarViewEventFrame={},
    CalendarViewHolidayFrame={},
    ChallengesKeystoneFrame={save=true, },
    ChannelFrame={},
    ClickBindingFrame={},
    ClubFinderGuildFinderFrame={},
    ContributionCollectionFrame={},
    CovenantPreviewFrame={},
    CovenantRenownFrame={},
    CovenantSanctumFrame={},
    CraftFrame={},
    DeathRecapFrame={},
    FlightMapFrame={save=true},
    GarrisonBuildingFrame={},
    OrderHallMissionFrame={},
    BFAMissionFrame={},
    GMSurveyFrame={},
    GuildBankFrame={},
    GuildFrame={},
    InspectFrame={},
    IslandsPartyPoseFrame={},
    IslandsQueueFrame={},
    TransmogrifyFrame={},
    ItemInteractionFrame={},
    ItemSocketingFrame={},
    ItemUpgradeFrame={},
    LookingForGuildFrame={},
    OrderHallTalentFrame={},
    PlayerChoiceFrame={},
    ReforgingFrame={},
    RuneforgeFrame={},
    ScrappingMachineFrame={},
    SoulbindViewer={},
    TalentFrame={},
    --PlayerTalentFrame={},天赋
    TalkingHeadFrame={save=true},
    TorghastLevelPickerFrame={},
    TradeSkillFrame={},
    UIWidgetBelowMinimapContainerFrame={},
    WarboardQuestChoiceFrame={},
    WarfrontsPartyPoseFrame={},
    WeeklyRewardsFrame={},
    ObliterumForgeFrame={},

    VehicleSeatIndicator={save=true, fun='VehicleSeatIndicator_Update',},
    GarrisonLandingPage={},
    DurabilityFrame={save=true,enter=true,show=true},
    ExtraActionButton1={save=true, frame=ExtraActionFrame,click='R'},
    --CollectionsJournal={},
    --MountJournal={frame=_G.CollectionsJournal},
    --ZoneAbilityFrame={save=true,enter=true}
    PlayerPowerBarAltStatusFrame={save=true},
    CovenantMissionFrame={save=true},

    ClassTalentFrame={save=true},--10.0天赋
};

if IsAddOnLoaded('BlizzMove') then
    for k, v in pairs(FrameTab) do
        if not v.save then FrameTab[k]=nil end
    end
end

local function Set()
    for k, v in pairs(FrameTab) do
        local f= _G[k];
        if f then
            Move(f, v);
            FrameTab[k]=nil
        end
    end
end

--加载保存数据
Frame:RegisterEvent("ADDON_LOADED")
Frame:RegisterEvent("PLAYER_LOGOUT")
Frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        Save= FrameMoveSave or Save
        Set()
    elseif event == "PLAYER_LOGOUT" then
        FrameMoveSave=Save
    end
end)

