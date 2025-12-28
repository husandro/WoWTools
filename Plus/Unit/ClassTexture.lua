
--职业, 图标， 颜色
local function Craete_Frame(frame)
    if frame.classFrame then
        return
    end

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
        if WoWTools_UnitMixin:UnitIsPlayer(unit) then
            local specID= GetInspectSpecialization(unit)
            local texture=0
            if canaccessvalue(specID) and specID and specID>0 then
                texture= select(4, GetSpecializationInfoByID(specID))
                if not canaccessvalue(texture) or not texture then
                    texture=0
                end
            end

            self.Portrait:SetTexture(texture)

            local guid= UnitGUID(unit)
            if not canaccessvalue(guid) or not guid then
                self.itemLevel:SetText('')
            else
                local level= WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel
                if canaccessvalue(level) and level then
                    self.itemLevel:SetText(level)
                else
                    self.itemLevel:SetText('')
                end
            end
            self:SetShown(true)
        else
            self:SetShown(false)
        end
    end
    frame.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', frame.unit)
    frame.classFrame:SetScript('OnEvent', function(self)
        local unit2= self:GetParent().unit
        if WoWTools_UnitMixin:UnitIsPlayer(unit2) then
            WoWTools_UnitMixin:GetNotifyInspect(nil, unit2)--取得玩家信息
            C_Timer.After(2, function()
                self:set_settings()
            end)
        end
    end)
end







local function Init_UnitFrame_Update(frame, isParty)--UnitFrame.lua--职业, 图标， 颜色
    local unit= frame.unit
    if unit:find('nameplate') then
        return
    end

    local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))

    local guid
    local unitIsPlayer= WoWTools_UnitMixin:UnitIsPlayer(unit)
    if unitIsPlayer then
        guid= UnitGUID(frame.unit)--职业, 天赋, 图标
        Craete_Frame(frame)
    end

    if frame.classFrame then
        if unitIsPlayer then
            frame.classFrame:set_settings()
            frame.classFrame.Texture:SetVertexColor(r, g, b)
            frame.classFrame.itemLevel:SetTextColor(r, g, b)
        end
        frame.classFrame:SetShown(unitIsPlayer)
    end

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
            elseif unit=='target' and guid then
                local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, guid, nil)
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