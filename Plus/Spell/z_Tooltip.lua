
--天赋 ClassTalentSpecTabMixin
function WoWTools_TooltipMixin.Events:Blizzard_PlayerSpells()
    WoWTools_DataMixin:Hook(PlayerSpellsFrame.SpecFrame, 'UpdateSpecFrame', function(btn)
        if not C_SpecializationInfo.IsInitialized() then
            return
        end

        for frame in btn.SpecContentFramePool:EnumerateActive() do
            if not frame.specIDLabel then
                frame.specIcon= frame:CreateTexture(nil, 'BORDER')
                frame.specIcon:SetPoint('TOP', frame.RoleIcon, 'BOTTOM', -2, -4)
                frame.specIcon:SetSize(22,22)

                frame.specIconBorder= frame:CreateTexture(nil, 'ARTWORK')
                frame.specIconBorder:SetPoint('CENTER', frame.specIcon,1.2,-1.2)
                frame.specIconBorder:SetAtlas('bag-border')
                frame.specIconBorder:SetVertexColor(PlayerUtil.GetClassColor():GetRGB())
                frame.specIconBorder:SetSize(32,32)

                frame.specIDLabel= frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed2') --WoWTools_LabelMixin:Create(frame, {mouse=true, size=18, copyFont=frame.RoleName})
                frame.specIDLabel:SetPoint('LEFT', frame.specIcon, 'RIGHT', 12, 0)
                frame.specIDLabel:SetScript('OnLeave', function(s) s:SetAlpha(1) GameTooltip_Hide() end)
                frame.specIDLabel:SetScript('OnEnter', function(s)
                    GameTooltip:SetOwner(s, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    local specIndex= s:GetParent().specIndex
                    if specIndex then
                        local specID, name, _, icon= C_SpecializationInfo.GetSpecializationInfo(specIndex)
                        if specID then
                            GameTooltip:AddDoubleLine(
                                WoWTools_TextMixin:CN(name),
                                icon and '|T'..icon..':0|t|cffffffff'..icon
                            )
                            GameTooltip:AddDoubleLine(
                                'specID|cffffffff'..WoWTools_DataMixin.Icon.icon2..specID,
                                'Index |cffffffff'..(specIndex or '')
                            )
                        end
                    end
                    GameTooltip:Show()
                    s:SetAlpha(0.5)
                end)
            end
            local specID, icon, _
            if frame.specIndex then
                specID, _, _, icon= C_SpecializationInfo.GetSpecializationInfo(frame.specIndex)
            end
            frame.specIDLabel:SetText(specID or '')
            frame.specIcon:SetTexture(icon or 0)
        end
    end)
end



