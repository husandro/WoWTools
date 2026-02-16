





--职业, 图标， 颜色
local function Craete_Frame(frame, portrait)
    frame.classFrame= CreateFrame('Frame', nil, frame)
    frame.classFrame:SetFrameStrata('HIGH')
    frame.classFrame:SetSize(14,14)
    frame.classFrame:SetPoint('BOTTOM', portrait, -7, -2)

    frame.classFrame.Portrait= frame.classFrame:CreateTexture(nil, "BORDER")
    frame.classFrame.Portrait:SetAllPoints()
    WoWTools_ButtonMixin:AddMask(frame.classFrame, true, frame.classFrame.Portrait)

    frame.classFrame.Texture= frame.classFrame:CreateTexture(nil, 'BACKGROUND')--加个外框
    frame.classFrame.Texture:SetAtlas('talents-node-choiceflyout-circle-greenglow')
    frame.classFrame.Texture:SetPoint('TOPLEFT', frame.classFrame, -2, 2)
    frame.classFrame.Texture:SetPoint('BOTTOMRIGHT', frame.classFrame, 2, -2)
    frame.classFrame.itemLevel= frame.classFrame:CreateFontString(nil, 'BORDER', 'WoWToolsFont')-- WoWTools_LabelMixin:Create(frame.classFrame, {size=12})--装等
    frame.classFrame.itemLevel:SetPoint('LEFT', frame.classFrame.Portrait, 'RIGHT', -1, 0)

    function frame.classFrame:get_guid()
        local unit= self:GetParent().unit
        local guid= UnitGUID(unit)
        if canaccessvalue(guid) then
            return guid, unit
        else
            return nil, unit
        end
    end

    function frame.classFrame:get_playerinfo()
        local guid= self:get_guid()
        if guid and not WoWTools_DataMixin.PlayerInfo[guid] then
            WoWTools_UnitMixin:GetNotifyInspect(nil, self.unit)--取得玩家信息
        end
    end

    function frame.classFrame:set_settings()
        self:get_playerinfo()

        local guid, unit= self:get_guid()

        local texture, itemLevel
        if guid then
            local data= WoWTools_DataMixin.PlayerInfo[guid] or {}
            local specID= data.specID or GetInspectSpecialization(unit) or 0
            local item= data.itemLevel or C_PaperDollInfo.GetInspectItemLevel(unit) or 0
            if specID>0 then
                texture= select(4, GetSpecializationInfoByID(specID, UnitSex(unit)))
            end
            if item>0 then
                itemLevel= item
            end
        end

        --local isShow= (texture or itemLevel) and true or false

        self.itemLevel:SetText(itemLevel or '')
        self.Portrait:SetTexture(texture or 0)
        local color= WoWTools_UnitMixin:GetColor(unit)
        local r,g,b= color:GetRGB()
        self.Texture:SetVertexColor(r,g,b)
        self.itemLevel:SetTextColor(r,g,b)
        self.Texture:SetShown(texture)

        --self:SetShown(isShow)
    end

    function frame.classFrame:set_event()
        local unit= self:GetParent().unit
        self:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
        EventRegistry:RegisterCallback("WoWTools_Cached_ItemLevel", function(_, guid)
            --print('WoWTools_Cached_ItemLevel|cnGREEN_FONT_COLOR:',guid, guid==self:get_guid())
            if guid==self:get_guid() then
                self:set_settings()
            end
        end, self)
        self:set_settings()
    end

    frame.classFrame:SetScript('OnEvent', function(self)
        WoWTools_UnitMixin:GetNotifyInspect(nil, self:GetParent().unit)--取得玩家信息
    end)

    frame:HookScript('OnShow', function(self)
        self.classFrame:set_event()
    end)

    frame:HookScript('OnHide', function(self)
        self.classFrame:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        EventRegistry:UnregisterCallback("WoWTools_Cached_ItemLevel", self)
    end)


    frame:HookScript('OnEnter', function(self)
        self.classFrame:get_playerinfo()
    end)

    if frame:IsVisible() then
        frame.classFrame:set_event()
    end
end









--UnitFrame.lua
--职业, 图标， 颜色
local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideClassColor then
        return
    end

    for frame, portrait in pairs({
        [PlayerFrame]= PlayerFrame.PlayerFrameContainer.PlayerPortrait,
        [TargetFrame]= TargetFrame.TargetFrameContainer.Portrait,
        [PartyFrame.MemberFrame1]=PartyFrame.MemberFrame1.Portrait,
        [PartyFrame.MemberFrame2]=PartyFrame.MemberFrame2.Portrait,
        [PartyFrame.MemberFrame3]=PartyFrame.MemberFrame3.Portrait,
        [PartyFrame.MemberFrame4]=PartyFrame.MemberFrame4.Portrait,
        [TargetFrameToT]= TargetFrameToT.Portrait,
        --[FocusFrame]= FocusFrame.TargetFrameContainer.Portrait,
    }) do
        if frame and portrait then
            Craete_Frame(frame, portrait)
        end
    end


    WoWTools_DataMixin:Hook('UnitFrame_Update', function(frame, isParty)
        if not frame.classFrame or not canaccessvalue(frame.unit) then
            return
        end

        local unit= frame.unit

        frame.classFrame:set_settings()

        local color= WoWTools_UnitMixin:GetColor(unit)
        local r,g,b= color:GetRGB()

    --名称
        if frame.name then
            local name
            if WoWTools_UnitMixin:UnitIsUnit(unit, 'pet') then
                frame.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
            else

                frame.name:SetTextColor(r,g,b)
                if isParty then
                    name= UnitName(unit)
                    name= WoWTools_TextMixin:sub(name, 4, 8)
                    frame.name:SetText(name)
                elseif unit=='target' then
                    local wow= WoWTools_UnitMixin:GetIsFriendIcon(unit)
                    if wow then
                        name= wow..GetUnitName(unit, false)
                    end
                end
            end
            if name then
                frame.name:SetText(name)
            end
        end


    --生命条，颜色，材质
        if frame.healthbar then
            frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
            frame.healthbar:SetStatusBarColor(r,g,b)--颜色
        end
    end)


    Init=function()end
end





function WoWTools_UnitMixin:Init_ClassTexture()
   Init()
end