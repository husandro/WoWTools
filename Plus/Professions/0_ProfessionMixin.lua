WoWTools_ProfessionMixin={}

function WoWTools_ProfessionMixin:IsKnown(skillLineTab)
    local isKnown=nil
    if skillLineTab then
        for skillLineID in pairs(skillLineTab) do
            if C_SpellBook.GetSkillLineIndexByID(skillLineID) then
                isKnown= true
                break
            else
                isKnown= false
            end
        end
    end
    return isKnown
end

function WoWTools_ProfessionMixin:GetName(skillLineID)
    local info= skillLineID and C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    if info and info.professionName and info.professionName~='' then
        local textureID, icon= select(2, WoWTools_TextureMixin:IsAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[skillLineID]))
        return  icon,--1
                WoWTools_TextMixin:CN(info.professionName),--2
                textureID,--3
                info--4
    end
end