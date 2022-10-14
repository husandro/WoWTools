local id, e = ...
local Save={point={},}
local addName=NPE_MOVE..'Frame'

local Point=function(frame, name2)
    local p=Save.point
    p=p[name2] and p[name2][1]
    if p and p[1] and p[3] and p[4] and p[5] then
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end
end

local Move=function(F, tab)
    local F2, click, save, enter, show, fun, re=tab.frame, tab.click, tab.save, tab.enter, tab.show, tab.fun, tab.re;--, tab.hook;    
    local name;
    if F2 then
        name=F2:GetName();
        if not name then return true end
        if save then
            F2:SetClampedToScreen(true);
        end
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
                local point={}
                local n=F2:GetNumPoints()
                for i=1,n do
                    table.insert(point, {F2:GetPoint(i)})
                    break
                end
                Save.point[name]=point
            end;
    end);

    if save then
        Point(F2,name);
        local Re={}
        local n=F2:GetNumPoints()
        for i=1,n do
            table.insert(Re, {F2:GetPoint(i)})
        end
        F:SetScript("OnMouseUp", function(self,D)--还原 Alt+右击
                if D=='RightButton' and IsAltKeyDown() then
                    Save.point[name]=nil
                    F2:ClearAllPoints();
                    local point=Re[1]
                    if point then
                        F2:SetPoint(point[1], point[2], point[3], point[4], point[5]);
                    end
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
if re then
    F2:SetResizable(true)
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
    AddonList={},--插件


    GameMenuFrame={save=true,},--菜单
    ProfessionsFrame={},--专业
    CharacterFrame={},--角色
    ReputationDetailFrame={save=true},--声望描述q
    TokenFramePopup={save=true},--货币设置
    SpellBookFrame={},--法术书

    PVEFrame={},--地下城和团队副本
    HelpFrame={},--客服支持
    MacroFrame={},--宏
    ExtraActionButton1={save=true, click='R' },--额外技能

    ContainerFrameCombinedBags={},--包
    ChatConfigFrame={save=true},--聊天设置
    SettingsPanel={},--选项
    --ZoneAbilityFrame.SpellButtonContainer = {save=true, click='R'},
    --UIWidgetPowerBarContainerFrame={save=true,},
    FriendsFrame={},--好友列表

    GossipFrame={},
    QuestFrame={},
    PlayerChoiceFrame={},--任务选择


    BlackMarketFrame={},--黑市
    BankFrame={save=true},--银行
    --UIWidgetBelowMinimapContainerFrame={save=true,click='RightButton'},
    MerchantFrame={},--货物
    ClassTrainerFrame={},--专业训练师

    ColorPickerFrame={save=true},--颜色选择器

    GarrisonShipyardFrame={},--海军行动
    GarrisonMissionFrame={},--要塞任务
    GarrisonCapacitiveDisplayFrame={},--要塞订单
    BFAMissionFrame={},--侦查地图
    GarrisonLandingPage={},--要塞报告   

    FlightMapFrame={save=true},--飞行地图
    WorldMapFrame={},--世界地图
};

local function setTabInit()
    for k, v in pairs(FrameTab) do
        if v then
            local f= _G[k];
            if f then
                Move(f, v);
                FrameTab[k]=nil
            end
        end
    end
end
local function setClass()--职业,能量条
    if e.Player.class== 'PALADIN' then
        local frame = PaladinPowerBarFrame;--圣骑士能量条, 
        if frame then
            Move(frame, {save=true})
            frame =PaladinPowerBarFrameBG if frame then frame:Hide() end
            frame=PaladinPowerBarFrameBankBG if frame then frame:Hide() end
        end

    elseif e.Player.class=='DEATHKNIGHT' then--DK符文
        Move(RuneFrame, {save=true})

    elseif e.Player.class=='MONK' then--WS
        local frame= MonkHarmonyBarFrame;--DPS
        if frame then
            if not frame.moveFrame then
                frame.moveFrame=CreateFrame('Frame', nil, frame);
                frame.moveFrame:SetSize(21, 21);
                frame.moveFrame:SetPoint('RIGHT', frame, 'LEFT');
                frame.moveFrame.textrue=frame.moveFrame:CreateTexture()
                frame.moveFrame.textrue:SetAllPoints(frame.moveFrame)
                frame.moveFrame.textrue:SetAtlas(e.Icon.icon)
                frame.moveFrame.textrue:SetShown(false)
                frame.moveFrame:SetScript('OnEnter', function(self2)
                    if not UnitAffectingCombat('player') then
                        self2.textrue:SetShown(true)
                        e.tips:ClearLines()
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(NPE_MOVE, e.Icon.left)
                        e.tips:Show()
                    end
                end)
                Move(frame.moveFrame, {save=true, frame=frame})
                frame.moveFrame:SetScript('OnLeave', function(self2)
                    ResetCursor()
                    e.tips:Hide()
                    self2.textrue:SetShown(false)
                end)
            end
        end
        frame=MonkStaggerBar--T
        if frame then
            Move(frame, {save=true})
        end

    elseif e.Player.class=='WARLOCK' then
        Move(WarlockPowerFrame, {save=true})

    elseif e.Player.class=='MAGE' then--Fs
        local frame=MageArcaneChargesFrame
        if frame then
            Move(frame, {save=true})
            if frame.Background then frame.Background:Hide() end
            frame:SetScale(0.7);--缩放
        end
    elseif e.Player.class=='ROGUE' or e.Player.class=='DRUID' then --DZ , XD        
        local frame=ComboPointPlayerFrame
        if frame then
            Move(frame, {save=true})
            UIParent.unit='player';
            if frame.Background then frame.Background:Hide() end

            if frame.ComboPoints then
                for i = 1, #frame.ComboPoints do
                    local self=frame.ComboPoints[i]
                    if self then
                        if self.PointOff then  self.PointOff:Hide() end--:SetAlpha(0) end
                        if self.CircleBurst then self.CircleBurst:Hide() end
                        if not self.tex then 
                            self.tex=self:CreateTexture(nil, 'BACKGROUND');
                            local setFrame=self.Point or self
                            self.tex:SetPoint('BOTTOM', setFrame, 'BOTTOM',0,0);                           
                            self.tex:SetSize(12, 12);
                            self.tex:SetAtlas(e.Icon.number:format(i));
                        end
                    end
                end
            end
        end
    end
end

local function setAddLoad(arg1)
    if arg1=='Blizzard_AchievementUI' then--成就
        Move(AchievementFrame.Header,{frame=AchievementFrame})
    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        Move(EncounterJournal, {})
    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        Move(ClassTalentFrame, {save=true})
    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        Move(AuctionHouseFrame, {})
    elseif arg1=='Blizzard_Communities' then--公会和社区
        local dialog = CommunitiesFrame.NotificationSettingsDialog or nil;
        if dialog then
            dialog:ClearAllPoints();
            dialog:SetAllPoints();
        end
        Move(CommunitiesFrame, {})
    elseif arg1=='Blizzard_Collections' then
        local checkbox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
        checkbox.Label:ClearAllPoints();
        checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1);
        checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1);
        Move(CollectionsJournal, {})--藏品
        Move(WardrobeFrame, {})--幻化
    elseif arg1=='Blizzard_Calendar' then--日历
        Move(CalendarFrame, {})
        --Move(CalendarCreateEventFrame, {save=true})
        --Move(CalendarViewEventFrame, {save=true})
        --Move(CalendarViewHolidayFrame, {save=true})
    end
end

local function setInit()
    Move(ZoneAbilityFrame.SpellButtonContainer, {save=true, click='R'})
    for k, v in pairs(FrameTab) do
        local f= _G[k];
        if f then
            Move(f, v);
            FrameTab[k]=nil
        end
    end
    hooksecurefunc(LootFrame,'Open', function(self2)--物品拾取LootFrame.lua
        if not GetCVarBool("autoLootDefault") and not GetCVarBool("lootUnderMouse") then
            local p=Save.point.LootFrame and Save.point.LootFrame[1]
            if p and p[1] and p[3] and p[4] and p[5] then
                self2:ClearAllPoints();
                self2:SetPoint(p[1], nil, p[3], p[4], p[5]);
            end
        end
    end)

    Move(DressUpFrame.TitleContainer, {frame = DressUpFrame})--试衣间    
    Move(LootFrame.TitleContainer, {frame=LootFrame, save=true})--物品拾取
end

--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
            end)
            if not Save.disabled then
                setInit()
                setTabInit()
                setClass()--职业,能量条
            end
    elseif event=='ADDON_LOADED' then
        if not Save.disabled then
            setAddLoad(arg1)
            setTabInit()
        end
        if arg1 then print(id, addName, arg1) end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)

--[[
     ContainerFrame1={save=true},
    ContainerFrame2={save=true},
    ContainerFrame3={save=true},
    ContainerFrame4={save=true},
    ContainerFrame5={save=true},
    ContainerFrame6={save=true},

    --ZoneAbilityFrame={save=true,enter=true},
    --ObjectiveTrackerBlocksFrame={click='R',},
    
    
 
    
   
  
    
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
    
    RaidInfoFrame={},
    GuildInviteFrame={},
    GuildRegistrarFrame={},
    
    InterfaceOptionsFrame={},
    ItemTextFrame={},
    --  LFGParentFrame={},
    LootFrame={},
    PetitionFrame={},
    PetStableFrame={},
    ScenarioQueueFrameSpecific={},
    
    QuestLogFrame={},
    QuestLogPopupDetailFrame={},
    ReadyCheckFrame={},
    RecruitAFriendRecruitmentFrame={},
    RecruitAFriendRewardsFrame={},
    SplashFrame={},
    TabardFrame={},
    TaxiFrame={save=true},
    VideoOptionsFrame={},
    
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
   
    ReforgingFrame={},
    RuneforgeFrame={},
    ScrappingMachineFrame={},
    SoulbindViewer={},
    TalentFrame={},
   
    TalkingHeadFrame={save=true},
    TorghastLevelPickerFrame={},
    TradeSkillFrame={},
    UIWidgetBelowMinimapContainerFrame={},
    WarboardQuestChoiceFrame={},
    WarfrontsPartyPoseFrame={},
    WeeklyRewardsFrame={},
    ObliterumForgeFrame={},

    VehicleSeatIndicator={save=true, fun='VehicleSeatIndicator_Update',},
   
    DurabilityFrame={save=true,enter=true,show=true},
    ExtraActionButton1={save=true, frame=ExtraActionFrame,click='R'},
    CollectionsJournal={},
    --MountJournal={frame=_G.CollectionsJournal},
    --ZoneAbilityFrame={save=true,enter=true}
    PlayerPowerBarAltStatusFrame={save=true},
    CovenantMissionFrame={save=true},

]]
