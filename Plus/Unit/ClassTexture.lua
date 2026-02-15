




local FindTab= {
    ['player']=1,
    ['target']=1,
    ['party1']=1,
    ['party2']=1,
    ['party3']=1,
    ['party4']=1,
}


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
        local guid
        if canaccessvalue(unit) and unit and UnitIsPlayer(unit) then
            guid= UnitGUID(unit)
        end

        local texture, itemLevel
        if guid then
            local data= WoWTools_DataMixin.PlayerInfo[guid] or {}
            local specID= data.specID or GetInspectSpecialization(unit)
            local item= data.itemLevel or C_PaperDollInfo.GetInspectItemLevel(unit)
            if specID and specID>0 then
                texture= select(4, GetSpecializationInfoByID(specID, UnitSex(unit)))
            end
            if item>0 then
                itemLevel= item
            end
        end

        local isShow= (texture or itemLevel) and true or false
        if isShow then
            self.itemLevel:SetText(itemLevel or '')
            self.Portrait:SetTexture(texture or 0)
            local color= WoWTools_UnitMixin:GetColor(unit)
            local r,g,b= color:GetRGB()
            self.Texture:SetVertexColor(r,g,b)
            self.itemLevel:SetTextColor(r,g,b)
            self.Texture:SetShown(texture)
        end
        print(unit, texture,itemLevel)
        self:SetShown(isShow)
       
    end

    function frame.classFrame:set_event()
        local unit= self:GetParent().unit
        self:RegisterEvent('INSPECT_READY')
        self:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
        --self:RegisterEvent('PLAYER_ENTERING_WORLD')
    end

    frame.classFrame:SetScript('OnShow', function(self)
        self:set_event()
    end)
    

    frame.classFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)

    frame.classFrame:SetScript('OnEvent', function(self, event, guid)
        local unit= self:GetParent().unit
        if event=='PLAYER_SPECIALIZATION_CHANGED' then
            WoWTools_UnitMixin:GetNotifyInspect(nil, unit)--取得玩家信息
        elseif canaccessvalue(guid) and guid and WoWTools_UnitMixin:UnitIsUnit(unit, UnitTokenFromGUID(guid)) then
            C_Timer.After(0.3, function()
                self:set_settings()
            end)
        end
        --if event=='PLAYER_SPECIALIZATION_CHANGED' then
        --elseif canaccessvalue(guid) and guid and WoWTools_UnitMixin:UnitIsUnit(unit, UnitTokenFromGUID(guid)) then    
        --end
    end)

    frame:HookScript('OnEnter', function(self)
        WoWTools_UnitMixin:GetNotifyInspect(nil, self.unit)--取得玩家信息
    end)
    if frame.classFrame:IsVisible() then
        frame.classFrame:set_event()
    end
end














--UnitFrame.lua
--职业, 图标， 颜色
local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideClassColor then
        return
    end





    WoWTools_DataMixin:Hook('UnitFrame_Update', function(frame, isParty)
            local unit= frame.unit
            if not canaccessvalue(unit) or not FindTab[unit] then
                if frame.classFrame then
                    frame.classFrame:SetShown(false)
                end
                return
            end

            if not frame.classFrame then
                Craete_Frame(frame)
            end

            frame.classFrame:set_settings()
            WoWTools_UnitMixin:GetNotifyInspect(nil, unit)--取得玩家信息

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