local e= select(2, ...)


--天赋 ClassTalentSpecTabMixin
local function Blizzard_ClassTalentUI(self)
    if not C_SpecializationInfo.IsInitialized() then
        return
    end

    for frame in self.SpecContentFramePool:EnumerateActive() do
        if not frame.specIDLabel then
            frame.specIcon= frame:CreateTexture(nil, 'BORDER')
            frame.specIcon:SetPoint('TOP', frame.RoleIcon, 'BOTTOM', -2, -4)
            frame.specIcon:SetSize(22,22)

            frame.specIconBorder= frame:CreateTexture(nil, 'ARTWORK')
            frame.specIconBorder:SetPoint('CENTER', frame.specIcon,1.2,-1.2)
            frame.specIconBorder:SetAtlas('bag-border')
            frame.specIconBorder:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
            frame.specIconBorder:SetSize(32,32)

            frame.specIDLabel= WoWTools_LabelMixin:Create(frame, {mouse=true, size=18, copyFont=frame.RoleName})
            frame.specIDLabel:SetPoint('LEFT', frame.specIcon, 'RIGHT', 12, 0)
            frame.specIDLabel:SetScript('OnLeave', function(s) s:SetAlpha(1) GameTooltip_Hide() end)
            frame.specIDLabel:SetScript('OnEnter', function(s)
                e.tips:SetOwner(s, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, WoWTools_TooltipMixin.addName)
                local specIndex= s:GetParent().specIndex
                if specIndex then
                    local specID, name, _, icon= GetSpecializationInfo(specIndex)
                    if specID then
                        e.tips:AddLine(' ')
                        e.tips:AddLine(name)
                        e.tips:AddDoubleLine((e.onlyChinese and '专精' or SPECIALIZATION)..' ID', specID)
                        e.tips:AddDoubleLine((e.onlyChinese and '专精' or SPECIALIZATION)..' Index', specIndex)
                        if icon then
                            e.tips:AddDoubleLine(icon and '|T'..icon..':0|t'..icon)
                        end
                    end
                end
                e.tips:Show()
                s:SetAlpha(0.5)
            end)
        end
        local specID, icon, _
        if frame.specIndex then
            specID, _, _, icon= GetSpecializationInfo(frame.specIndex)
        end
        frame.specIDLabel:SetText(specID or '')
        frame.specIcon:SetTexture(icon or 0)
    end

    WoWTools_TooltipMixin.AddOn.Blizzard_ClassTalentUI=nil
end






function WoWTools_TooltipMixin.AddOn.Blizzard_ClassTalentUI()
    hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecFrame', Blizzard_ClassTalentUI)
end
