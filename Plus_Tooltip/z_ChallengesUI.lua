local e= select(2, ...)


--挑战, AffixID
local function Blizzard_ChallengesUI()
    hooksecurefunc(ChallengesKeystoneFrameAffixMixin, 'OnEnter',function(self)
        if self.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
            if (self.affixID or self.info) then
                if (self.info) then
                    local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[self.info.key]
                    name = tbl.name
                    description = string.format(tbl.desc, self.info.pct)
                else
                    name= e.cn(name)
                    description= e.cn(description)
                end
                GameTooltip:SetText(name, 1, 1, 1, 1, true)
                GameTooltip:AddLine(description, nil, nil, nil, true)
            end
            GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
end





function WoWTools_TooltipMixin.AddOn.Blizzard_ChallengesUI()
    Blizzard_ChallengesUI()
end
