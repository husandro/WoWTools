
--职业, 图标， 颜色
local function Craete_Frame(frame)
    frame.classFrame= CreateFrame('Frame', nil, frame)
    frame.classFrame:SetShown(false)
    frame.classFrame:SetSize(16,16)
    frame.classFrame.Portrait= frame.classFrame:CreateTexture(nil, "BACKGROUND")
    frame.classFrame.Portrait:SetAllPoints(frame.classFrame)
    WoWTools_ButtonMixin:AddMask(frame.classFrame, true, frame.classFrame.Portrait)


    if frame==TargetFrame then
        frame.classFrame:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentContextual.LeaderIcon, 'LEFT')
    elseif frame==PetFrame then
        frame.classFrame:SetPoint('LEFT', frame.name,-10,0)
    elseif frame==PlayerFrame then
        frame.classFrame:SetPoint('TOPLEFT', frame.portrait, 'TOPRIGHT',-14,8)
    elseif frame==FocusFrame then
        frame.classFrame:SetPoint('BOTTOMRIGHT', frame.TargetFrameContent.TargetFrameContentMain.ReputationColor, 'TOPRIGHT')
    else
        frame.classFrame:SetPoint('TOPLEFT', frame.portrait, 'TOPRIGHT',-14,10)
    end

    frame.classFrame.Texture= frame.classFrame:CreateTexture(nil, 'OVERLAY')--加个外框
    frame.classFrame.Texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    frame.classFrame.Texture:SetPoint('CENTER', frame.classFrame, 1,-1)
    frame.classFrame.Texture:SetSize(20,20)

    frame.classFrame.itemLevel= WoWTools_LabelMixin:Create(frame.classFrame, {size=12})--装等
    if frame.unit=='target' or frame.unit=='focus' then
        frame.classFrame.itemLevel:SetPoint('RIGHT', frame.classFrame, 'LEFT')
    else
        frame.classFrame.itemLevel:SetPoint('TOPRIGHT', frame.classFrame, 'TOPLEFT')
    end

    function frame.classFrame:set_settings()
        local unit= self:GetParent().unit

        local guid= WoWTools_UnitMixin:UnitGUID(unit)

        if not guid or not UnitIsPlayer(unit) then
            self:SetShown(false)
            return
        end

        local texture, level

        local specID= GetInspectSpecialization(unit)
        if canaccessvalue(specID) and specID and specID>0 then
            texture= select(4, GetSpecializationInfoByID(specID, UnitSex(unit)))
        end

        if WoWTools_DataMixin.UnitItemLevel[guid] then
            level= WoWTools_DataMixin.UnitItemLevel[guid].itemLevel
        end

        local isShow= (texture or level) and true or false
        if isShow then
            self.itemLevel:SetText(level or '')
            self.Portrait:SetTexture(texture or 0)
            local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))
            self.Texture:SetVertexColor(r or 1, g or 1, b or 1)
            self.itemLevel:SetTextColor(r, g, b)
        end
        self:SetShown(isShow)
    end

    frame.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', frame.unit)
    frame.classFrame:SetScript('OnShow', function(self)
        self:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', self:GetParent().unit)
    end)

    frame.classFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)

    frame.classFrame:SetScript('OnEvent', function(self)
        WoWTools_UnitMixin:GetNotifyInspect(nil, self:GetParent().unit)--取得玩家信息
        C_Timer.After(2, function()
            self:set_settings()
        end)
    end)
end







local function Init_UnitFrame_Update(frame, isParty)--UnitFrame.lua--职业, 图标， 颜色
    local unit= frame.unit

    if not WoWTools_UnitMixin:UnitExists(unit)
        or not UnitIsPlayer(unit)
        or unit:find('nameplate')
    then
        if frame.classFrame then
            frame.classFrame:SetShown(false)
        end
        return
    end


    if not frame.classFrame then
        Craete_Frame(frame)
    end
    frame.classFrame:set_settings()

    local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))

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
end











local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideClassColor then
        return
    end





    WoWTools_DataMixin:Hook('UnitFrame_Update', Init_UnitFrame_Update)--职业, 图标， 颜色
    Init=function()end
end





function WoWTools_UnitMixin:Init_ClassTexture()
   Init()
end