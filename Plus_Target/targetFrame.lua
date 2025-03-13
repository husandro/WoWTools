local targetFrame

local function Save()
    return WoWTools_TargetMixin.Save
end



















local function Set_Target(self)
    local plate= C_NamePlate.GetNamePlateForUnit("target", issecure())
    if not plate or not plate.UnitFrame then
        self:SetShown(false)
        return
    end

    local UnitFrame = plate.UnitFrame
    local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--C_AddOns.IsAddOnLoaded("Plater")
    self:ClearAllPoints()
    if Save().TargetFramePoint=='TOP' then
        if UnitFrame.SoftTargetFrame.Icon:IsShown() then
            frame= UnitFrame.SoftTargetFrame
        else
            frame= UnitFrame.name or UnitFrame.healthBar
        end
        self:SetPoint('BOTTOM', frame or UnitFrame, 'TOP', Save().x, Save().y)

    elseif Save().TargetFramePoint=='HEALTHBAR' then
        frame= UnitFrame.healthBar or UnitFrame.name or UnitFrame
        local w, h= frame:GetSize()
        w= w+ Save().w
        h= h+ Save().h
        local n, p
        if UnitFrame.RaidTargetFrame.RaidTargetIcon:IsVisible() then
            n= UnitFrame.RaidTargetFrame.RaidTargetIcon:GetWidth()+ UnitFrame.ClassificationFrame.classificationIndicator:GetWidth()

        --[[elseif UnitFrame.WidgetContainer:IsVisible() then
            n= UnitFrame.WidgetContainer:GetWidth()]]

        elseif UnitFrame.ClassificationFrame.classificationIndicator:IsVisible() then
            n= UnitFrame.ClassificationFrame.classificationIndicator:GetWidth()
        end

        if UnitFrame.questProgress then
            p= UnitFrame.questProgress:GetWidth()
        end
        n, p= n or 0, p or 0
        self:SetSize(w+ n+ p, h)
        self:SetPoint('CENTER', UnitFrame, Save().x+ (-n+p)/2, Save().y)
    else

        if UnitFrame.RaidTargetFrame.RaidTargetIcon:IsVisible() then
            frame= UnitFrame.RaidTargetFrame

        elseif UnitFrame.ClassificationFrame.classificationIndicator:IsVisible() then
            frame= UnitFrame.ClassificationFrame.classificationIndicator

        elseif UnitFrame.WidgetContainer:IsVisible() then
            frame= UnitFrame.WidgetContainer
        else
            frame= UnitFrame.healthBar or UnitFrame.name
        end
        self:SetPoint('RIGHT', frame or UnitFrame, 'LEFT',Save().x, Save().y)
    end
    self:SetShown(true)
end
















local function Set_Texture(self)
    self:SetSize(Save().w, Save().h)--设置大小
    local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save().targetTextureName)--设置，图片
    if isAtlas then
        self.Texture:SetAtlas(texture)
    else
        self.Texture:SetTexture(texture or 0)
    end

    if Save().scale~=1 then

        self:SetScript('OnUpdate', function(frame, elapsed)
            frame.elapsed= (frame.elapsed or Save().elapsed) + elapsed
            
            if frame.elapsed> Save().elapsed then

                frame.elapsed=0
                frame:SetScale(frame:GetScale()==1 and Save().scale or 1)
            end
        end)

    else
        self:SetScript('OnUpdate', nil)
    end
    self:SetScale(1)--缩放
    self:set_color(Save().targetInCombat and UnitAffectingCombat('player') or false)
    Set_Target(self)
end













--指示目标 Blizzard_NamePlates.xml
--HealthBarsContainer castBar WidgetContainer
local function Init()
    targetFrame= CreateFrame('Frame')
    WoWTools_TargetMixin.targetFrame= targetFrame

    targetFrame.Texture= targetFrame:CreateTexture(nil, 'BACKGROUND')
    targetFrame.Texture:SetAllPoints(targetFrame)

    function targetFrame:set_color(isInCombat)
        if isInCombat then
            self.Texture:SetVertexColor(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a)
        else
            self.Texture:SetVertexColor(Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a)
        end
    end



    hooksecurefunc(NamePlateDriverFrame, 'OnSoftTargetUpdate', function()
        if Save().TargetFramePoint=='TOP' and Save().target then
            Set_Target(targetFrame)
        end
    end)

    targetFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_TARGET_CHANGED'
            or event=='RAID_TARGET_UPDATE'
            or event=='UNIT_FLAGS'
            or event=='PLAYER_ENTERING_WORLD'
            or (event=='CVAR_UPDATE'
                and (arg1=='nameplateShowAll' or arg1=='nameplateShowEnemies' or arg1=='nameplateShowFriends')
            )
        then
            C_Timer.After(0.15, function() Set_Target(self) end)

        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then--颜色
            self:set_color(event=='PLAYER_REGEN_DISABLED')

        end
    end)

    function targetFrame:Settings()
        self:UnregisterAllEvents()
        if not Save().target then
            self:SetShown(false)
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('CVAR_UPDATE')
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            self:RegisterEvent('RAID_TARGET_UPDATE')
            self:RegisterUnitEvent('UNIT_FLAGS', 'target')
            if Save().targetInCombat then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            end
            Set_Texture(self)
            self:SetShown(UnitExists('target'))
        end
    end

    return true
end











function WoWTools_TargetMixin:Init_targetFrame()
    if Save().target and Init() then
        Init=function()end
    end

    if targetFrame then
        targetFrame:Settings()
    end
end