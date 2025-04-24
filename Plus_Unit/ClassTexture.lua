
--职业, 图标， 颜色








local function Init_UnitFrame_Update(frame, isParty)--UnitFrame.lua--职业, 图标， 颜色
    local unit= frame.unit
    if not UnitExists(unit) or unit:find('nameplate') then
        return
    end
    local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))

    local guid
    local unitIsPlayer=  UnitIsPlayer(unit)
    if unitIsPlayer then
        guid= UnitGUID(frame.unit)--职业, 天赋, 图标
        if not frame.classFrame then
            frame.classFrame= CreateFrame('Frame', nil, frame)
            frame.classFrame:SetShown(false)
            frame.classFrame:SetSize(16,16)
            frame.classFrame.Portrait= frame.classFrame:CreateTexture(nil, "BACKGROUND")
            frame.classFrame.Portrait:SetAllPoints(frame.classFrame)


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
            if unit=='target' or unit=='focus' then
                frame.classFrame.itemLevel:SetPoint('RIGHT', frame.classFrame, 'LEFT')
            else
                frame.classFrame.itemLevel:SetPoint('TOPRIGHT', frame.classFrame, 'TOPLEFT')
            end

            function frame.classFrame:set_settings(guid3)
                local unit2= self:GetParent().unit
                local isPlayer= UnitExists(unit2) and UnitIsPlayer(unit2)
                local find2=false
                if isPlayer then
                    if UnitIsUnit(unit2, 'player') then
                        local texture= select(4, GetSpecializationInfo(GetSpecialization() or 0))
                        if texture then
                            SetPortraitToTexture(self.Portrait, texture)
                            find2= true
                        end
                    else
                        local specID= GetInspectSpecialization(unit2)
                        if specID and specID>0 then
                            local texture= select(4, GetSpecializationInfoByID(specID))
                            if texture then
                                SetPortraitToTexture(self.Portrait, texture)
                                find2= true
                            end
                        else
                            local guid2= guid3 or UnitGUID(unit2)
                            if guid2 and WoWTools_DataMixin.UnitItemLevel[guid2] and WoWTools_DataMixin.UnitItemLevel[guid2].specID then
                                local texture= select(4, GetSpecializationInfoByID(WoWTools_DataMixin.UnitItemLevel[guid2].specID))
                                if texture then
                                    SetPortraitToTexture(self.Portrait, texture)
                                    find2= true
                                end
                            else
                                local class= WoWTools_UnitMixin:GetClassIcon(nil, unit2, nil, true)--职业, 图标
                                if class then
                                    self.Portrait:SetAtlas(class)
                                    find2=true
                                end
                            end
                        end
                    end

                    self.itemLevel:SetText(guid3 and WoWTools_DataMixin.UnitItemLevel[guid3] and WoWTools_DataMixin.UnitItemLevel[guid3].itemLevel or '')
                end
                self:SetShown(isPlayer and find2)
            end
            frame.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
            frame.classFrame:SetScript('OnEvent', function(self3)
                local unit2= self3:GetParent().unit
                if UnitIsPlayer(unit2) then
                    WoWTools_UnitMixin:GetNotifyInspect(nil, unit2)--取得玩家信息
                    C_Timer.After(2, function()
                        self3:set_settings()
                    end)
                end
            end)
        end
    end
    if frame.classFrame then
        frame.classFrame:set_settings(guid)
        frame.classFrame.Texture:SetVertexColor(r or 1, g or 1, b or 1)
        frame.classFrame.itemLevel:SetTextColor(r or 1, g or 1, b or 1)
        --frame.classFrame:SetShown(unitIsPlayer)
    end

    if frame.name then
        local name
        if UnitIsUnit(unit, 'pet') then
            frame.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        else
            frame.name:SetTextColor(r,g,b)
            if isParty then
                name= UnitName(unit)
                name= WoWTools_TextMixin:sub(name, 4, 8)
                frame.name:SetText(name)
            elseif unit=='target' and guid then
                local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, guid)
                if wow then
                    name= wow..GetUnitName(unit, false)
                end
            end
        end
        if name then
            frame.name:SetText(name)
        end
    end

    --################
    --生命条，颜色，材质
    --################
    if frame.healthbar then
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        frame.healthbar:SetStatusBarColor(r,g,b)--颜色
    end
end











local function Init()
    hooksecurefunc('UnitFrame_Update', Init_UnitFrame_Update)--职业, 图标， 颜色
    Init=function()end
end





function WoWTools_UnitMixin:Init_ClassTexture()
   Init()
end