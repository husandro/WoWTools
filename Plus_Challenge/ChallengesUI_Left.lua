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


--[[
local ScrollBox = CreateFrame("Frame", nil, UIParent, "WowScrollBoxList")
ScrollBox:SetPoint("CENTER")
ScrollBox:SetSize(300, 300)

local ScrollBar = CreateFrame("EventFrame", nil, UIParent, "MinimalScrollBar")
ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT")
ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT")

local DataProvider = CreateDataProvider()
local ScrollView = CreateScrollBoxListLinearView()
ScrollView:SetDataProvider(DataProvider)

ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)

-- The 'button' argument is the frame that our data will inhabit in our list
-- The 'data' argument will be the data table mentioned above
local function Initializer(button, data)
    local playerName = data.PlayerName
    local playerClass = data.PlayerClass
    button:SetScript("OnClick", function()
        print(playerName .. ": " .. playerClass)
    end)
    button:SetText(playerName)
end

-- The first argument here can either be a frame type or frame template. We're just passing the "UIPanelButtonTemplate" template here
ScrollView:SetElementInitializer("UIPanelButtonTemplate", Initializer)

 -- Optional Resetter function which you can use to reset your frame or data element.
local function Resetter(frame, data)
   
    -- Insert reset code here

end
ScrollView:SetElementResetter(Resetter)

local myData = {
    PlayerName = "Ghost",
    PlayerClass = "Priest"
}

DataProvider:Insert(myData)
]]






local function Create_Label(btn)
    if btn.pve then
        return
    end

    btn.NameFrame:SetPoint('RIGHT')
    btn.pve= WoWTools_LabelMixin:Create(btn, {size=12, mouse=true, color={r=1,g=1,b=1}})
    btn.pve:SetPoint('TOPRIGHT')

    btn.mythic= WoWTools_LabelMixin:Create(btn, {size=12, mouse=true, color={r=1,g=1,b=1}})
    btn.mythic:SetPoint('TOPLEFT', btn.pve, 'BOTTOMLEFT')

    btn.world= WoWTools_LabelMixin:Create(btn, {size=12, mouse=true, color={r=1,g=1,b=1}})
    btn.world:SetPoint('TOPLEFT', btn.pvp, 'BOTTOMLEFT')

    btn.pvp= WoWTools_LabelMixin:Create(btn, {size=12, mouse=true, color={r=1,g=1,b=1}})
    btn.pvp:SetPoint('TOPLEFT', btn.mythic, 'BOTTOMLEFT')
end




local function Initializer(btn, data)
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon({
        guid=data.guid,
        reAtlas=true,
    } or ''))

    local col= WoWTools_UnitMixin:GetColor(nil, data.guid)

    btn.Name:SetText(data.itemLink)

    btn.Name2:SetText(
        (WoWTools_UnitMixin:GetFullName(nil, nil, data.guid) or '')--取得全名
        ..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon[data.faction] or '')
    )
   
    btn.Name2:SetTextColor(col.r, col.g, col.b)

    btn.itemLink= data.itemLink
    
    --[[Create_Label(btn)

    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon({
        guid=data.guid,
        reAtlas=true,
    } or ''))

    btn.pve:SetText(data.pve or '')
    btn.mythic:SetText(data.mythic or '')
    btn.pvp:SetText(data.pvp or '')
    btn.world:SetText(data.world or '')
    

    btn.Name:SetText(data.itemLink or '')

    btn.itemLink= data.itemLink

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self)
    end)
    btn:SetScript('OnHide', function(self)
        self.Icon:SetTexture(0)
        self.Name:SetText('')

        self.settings=nil
        self.itemLink=nil

        self.pve:SetText('')
        self.mythic:SetText('')
        self.pvp:SetText('')
        self.world:SetText( '')
        
        self:SetScript('OnLeave', nil)
        self:SetScript('OnEnter', nil)
        self:SetScript('OnHide', nil)
    end)]]

end






local function Set_List()
    local data = CreateDataProvider()
    for guid, info in pairs(WoWTools_WoWDate) do
     
        if info.Keystone.link then
           
            data:Insert({
                guid=guid,
                faction=info.faction,
                itemLink= info.Keystone.link,
                pve= info.Keystone.weekPvE,
                mythic= info.Keystone.weekMythicPlus,
                pvp= info.Keystone.weekPvP,
                world= info.Keystone.weekWorld,
            })
        end
    end
    Frame.view:SetDataProvider(data,  ScrollBoxConstants.RetainScrollPosition)
   -- Frame:FullUpdate()
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
    Frame.view:SetDataProvider(CreateDataProvider())

    ScrollUtil.InitScrollBoxListWithScrollBar(Frame, Frame.ScrollBar, Frame.view)

    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', Initializer)





    function Frame:Settings()
        --self:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT', Save().leftX or -4, Save().leftY or 0)
        self:SetWidth(250)
        self:SetShown(not Save().hideLeft)
        self:SetScale(Save().leftScale or 1)
     end




    Frame:SetScript('OnShow', function()
        Set_List()
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

