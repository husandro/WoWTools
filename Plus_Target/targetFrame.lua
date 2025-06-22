local targetFrame

local function Save()
    return WoWToolsSave['Plus_Target']
end







local function Set_Target()
    local plate= C_NamePlate.GetNamePlateForUnit("target", issecure())
    if not plate or not plate.UnitFrame then
        targetFrame:SetShown(false)
        return
    end

    local UnitFrame = plate.UnitFrame
    local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--C_AddOns.IsAddOnLoaded("Plater")
    targetFrame:ClearAllPoints()
    if Save().TargetFramePoint=='TOP' then
        if UnitFrame.SoftTargetFrame.Icon:IsShown() then
            frame= UnitFrame.SoftTargetFrame
        else
            frame= UnitFrame.name or UnitFrame.healthBar
        end
        targetFrame:SetPoint('BOTTOM', frame or UnitFrame, 'TOP', Save().x, Save().y)

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
        targetFrame:SetSize(w+ n+ p, h)
        targetFrame:SetPoint('CENTER', UnitFrame, Save().x+ (-n+p)/2, Save().y)
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
        targetFrame:SetPoint('RIGHT', frame or UnitFrame, 'LEFT',Save().x, Save().y)
    end
    targetFrame:SetShown(true)
end
















local function Set_Texture()
    targetFrame:SetSize(Save().w, Save().h)--设置大小
    local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save().targetTextureName)--设置，图片
    if isAtlas then
        targetFrame.Texture:SetAtlas(texture)
    else
        targetFrame.Texture:SetTexture(texture or 0)
    end

    local scale= Save().scale
    local elapse= Save().elapsed

    targetFrame.elapsed= nil
    targetFrame:SetScale(1)--缩放
    targetFrame:set_color(Save().targetInCombat and UnitAffectingCombat('player') or false)

    if scale~=1 then
        targetFrame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or elapse) + elapsed
            if self.elapsed> elapse then
                self.elapsed=0
                self:SetScale(self:GetScale()==1 and scale or 1)
            end
        end)

    else
        targetFrame:SetScript('OnUpdate', nil)
    end

    Set_Target()
end













--指示目标 Blizzard_NamePlates.xml
--HealthBarsContainer castBar WidgetContainer
local function Init()
    if not Save().target then
        return
    end

    targetFrame= CreateFrame('Frame', 'WoWToolTarget_TargetFrame')

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
            Set_Target()
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
            Set_Texture()
            self:SetShown(UnitExists('target'))
        end
    end


    targetFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_TARGET_CHANGED'
            or event=='RAID_TARGET_UPDATE'
            or event=='UNIT_FLAGS'
            or event=='PLAYER_ENTERING_WORLD'
            or (event=='CVAR_UPDATE'
                and (arg1=='nameplateShowAll' or arg1=='nameplateShowEnemies' or arg1=='nameplateShowFriends')
            )
        then
            C_Timer.After(0.15, function() Set_Target() end)

        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then--颜色
            self:set_color(event=='PLAYER_REGEN_DISABLED')

        end
    end)


    targetFrame:Settings()

    Init=function()
        targetFrame:Settings()
    end
end











function WoWTools_TargetMixin:Init_targetFrame()
    Init()
end