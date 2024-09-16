

--要塞，技能树
local function Init_Blizzard_OrderHallUI()
    hooksecurefunc(GarrisonTalentButtonMixin, 'OnEnter', function(self2)--Blizzard_OrderHallTalents.lua
        local info=self2.talent--C_Garrison.GetTalentInfo(self.talent.id)
        if not info or not info.id then
            return
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('talentID '..info.id, info.icon and '|T'..info.icon..':0|t'..info.icon)
        if info.ability and info.ability.id and info.ability.id>0 then
            GameTooltip:AddDoubleLine('ability '..info.ability.id, info.ability.icon and '|T'..info.ability.icon..':0|t'..info.ability.icon)
        end
        GameTooltip:Show()
    end)
    hooksecurefunc(GarrisonTalentButtonMixin, 'SetTalent', function(self2)--是否已激活, 和等级
        local info= self2.talent
        if not info or not info.id then
            return
        end

        if info.researched and not self2.researchedTexture then
            self2.researchedTexture= self2:CreateTexture(nil, 'OVERLAY')
            local w,h= self2:GetSize()
            self2.researchedTexture:SetSize(w/3, h/3)
            self2.researchedTexture:SetPoint('BOTTOMRIGHT')
            self2.researchedTexture:SetAtlas(e.Icon.select)
        end
        if self2.researchedTexture then
            self2.researchedTexture:SetShown(info.researched)
        end

        local rank
        if info.talentMaxRank and info.talentMaxRank>1 and info.talentRank~= info.talentMaxRank then
            if not info.rankText then
                info.rankText= WoWTools_LabelMixin:CreateLabel(self2)
                info.rankText:SetPoint('BOTTOMLEFT')
            end
            rank= '|cnGREEN_FONT_COLOR:'..(info.talentRank or 0)..'|r/'..info.talentMaxRank
        end
        if info.rankText then
            info.rankText:SetText(rank or '')
        end
    end)
end
