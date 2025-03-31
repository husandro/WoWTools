--所以角色信息
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame
local Buttons={}



--所以角色信息
--###########
local function create_lable(btn, point, text, col, size)
    if not text or text=='' then
        return
    end

    local label= WoWTools_LabelMixin:Create(btn, {size=size or 12, mouse=true, color=col})

    if type(point)=='number' then
        if not btn.lastLabel then
            label:SetPoint('TOPRIGHT', btn, 'TOPLEFT')
        else
            label:SetPoint('TOPRIGHT', btn.lastLabel, 'BOTTOMRIGHT')
        end
        btn.lastLabel=label

    elseif point=='b' then
        label:SetPoint('BOTTOM')
    elseif point=='l' then
        label:SetPoint('TOPLEFT')
        label.num= text
    elseif point=='r' then
        label:SetPoint('TOPRIGHT')
    end

    label:SetText(text or point)

    label.point= point

    label:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)

    label:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(
            self.point==3 and (WoWTools_DataMixin.onlyChinese and '团队副本' or RAIDS)
            or self.point==1 and (WoWTools_DataMixin.onlyChinese and '地下城' or DUNGEONS)
            or self.point==2 and (WoWTools_DataMixin.onlyChinese and 'PvP' or PVP)
            or self.point==6 and (WoWTools_DataMixin.onlyChinese and '世界' or WORLD)
            or self.point=='b' and (WoWTools_DataMixin.onlyChinese and '史诗钥石评分' or DUNGEON_SCORE)
            or self.point=='l' and (WoWTools_DataMixin.onlyChinese and '本周次数' or format(CURRENCY_THIS_WEEK, format(ARCHAEOLOGY_COMPLETION,self.num)))
            or self.point=='r' and (WoWTools_DataMixin.onlyChinese and '本周最高等级' or format(CURRENCY_THIS_WEEK, BEST))
        )
        GameTooltip:AddLine('|cffffffff'..(self:GetText() or ''))
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
end














local function Create_Button(index)
    local btn= WoWTools_ButtonMixin:Cbtn(Frame, {size=36, icon='hide'})

    if index==1 then
        btn:SetPoint('TOPRIGHT')
    else
        btn:SetPoint('TOPRIGHT', Buttons[index-1], 'BOTTOMRIGHT')
    end

    btn:SetScript('OnLeave', GameTooltip_Hide)

    btn:SetScript('OnEnter', function(self)
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)

    Buttons[index]= btn

    return btn
end




local function Int_All_Player()--所以角色信息   
    local last
    local index=0
    for guid, info in pairs(WoWTools_WoWDate) do
        local link= info.Keystone.link
        local weekPvE= info.Keystone.weekPvE
        local weekMythicPlus= info.Keystone.weekMythicPlus
        local weekPvP= info.Keystone.weekPvP
        local weekWorld= info.Keystone.weekWorld

        if
            info.region==WoWTools_DataMixin.Player.Region
            and (guid~=WoWTools_DataMixin.Player.GUID or WoWTools_DataMixin.Player.husandro)
            and (link or weekPvE or weekMythicPlus or weekPvP or weekWorld) 
        
        then

            local _, englishClass, _, _, _, namePlayer, realm = GetPlayerInfoByGUID(guid)
            if namePlayer and namePlayer~='' then
                index= index+1

                local classColor = englishClass and C_ClassColor.GetClassColor(englishClass)
                local btn= Buttons[index] or Create_Button(index)

                btn:SetNormalAtlas(WoWTools_UnitMixin:GetRaceIcon({guid=guid, reAtlas=true}))

                btn.link=link

                

                local score= WoWTools_ChallengeMixin:KeystoneScorsoColor(info.Keystone.score, false, nil)
                local weekNum= info.Keystone.weekNum and info.Keystone.weekNum>0 and info.Keystone.weekNum
                local weekLevel= info.Keystone.weekLevel and info.Keystone.weekLevel>0 and info.Keystone.weekLevel
--[[
0	None	
1	Activities	
2	RankedPvP	
3	Raid	
4	AlsoReceive	
5	Concession	
6	World
]]

                create_lable(btn, 3, weekPvE, classColor)--团队副本
                create_lable(btn, 1, weekMythicPlus, classColor)--挑战
                create_lable(btn, 2, weekPvP, classColor)--pvp
                create_lable(btn, 6, weekWorld, classColor)--world
                create_lable(btn, 'b', score, {r=1,g=1,b=1}, 12)--分数
                create_lable(btn, 'l', weekNum, {r=1,g=1,b=1})--次数
                create_lable(btn, 'r', weekLevel, {r=1,g=1,b=1})--次数


                local nameLable= WoWTools_LabelMixin:Create(btn, {color= classColor})--名字
                nameLable:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')
                nameLable:SetText(
                    (namePlayer or '')
                    ..((realm and realm~='') and '-'..realm or '')
                    ..(WoWTools_UnitMixin:GetClassIcon(nil, englishClass) or '')
                    ..(WoWTools_UnitMixin:GetFaction(nil, info.faction, false) or '')
                )

                if link then
                    if WoWTools_DataMixin.onlyChinese and link then--取得中文，副本名称
                        local mapID, name= link:match('|Hkeystone:%d+:(%d+):.+%[(.+) %(%d+%)]')
                        mapID= mapID and tonumber(mapID)
                        if mapID and name and WoWTools_DataMixin.ChallengesSpellTabs[mapID] and WoWTools_DataMixin.ChallengesSpellTabs[mapID].name then
                            link= link:gsub(name, WoWTools_DataMixin.ChallengesSpellTabs[mapID].name)
                        end
                    end
                    local keyLable= WoWTools_LabelMixin:Create(btn, {mouse=true})--KEY
                    keyLable.link=link
                    keyLable:SetPoint('RIGHT', nameLable, 'LEFT')
                    keyLable:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
                    keyLable:SetScript('OnEnter', function(self)
                        if self.link then
                            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                            GameTooltip:ClearLines()
                            GameTooltip:SetHyperlink(self.link)
                            GameTooltip:Show()
                        end
                    end)
                    keyLable:SetText(link)
                end

                last= nameLable
            end
        end
    end
end









local function Init_List()
    Frame.view:SetElementInitializer('Frame')
end



local function Init()
    if Save().hideLeft then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame, 'WowScrollBoxList')
    Frame:Hide()

    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT', -4)
    Frame:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMLEFT', -4)

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(Frame, {isAllPoint=true})

    Frame.ScrollBar  = CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame, "TOPRIGHT", 8,0)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT",8,12)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame, Frame.ScrollBar, Frame.view)

    


    function Frame:Settings()
        --self:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT', Save().leftX or -4, Save().leftY or 0)
        self:SetWidth(200)
        self:SetShown(not Save().hideLeft)
        self:SetScale(Save().leftScale or 1)
     end

    Frame:SetScript('OnShow', function(self)
        Init_List()
    end)
    Frame:SetScript('OnHide', function(self)

    end)

    Frame:Settings()

    Init= function()
        Frame:Settings()
    end
end












function WoWTools_ChallengeMixin:ChallengesUI_Left()
    if not WoWTools_DataMixin.Player.husandro then
        return
    end
    Init()
end

