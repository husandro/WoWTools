local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end




--BOSS技能 Blizzard_EncounterJournal.lua
local function EncounterJournal_SetBullets_setLink(text)--技能加图标
    local find
    text=text:gsub('|Hspell:.-]|h',function(link)
        local texture= link:match('Hspell:(%d+)')
        if texture then
            local icon= C_Spell.GetSpellTexture(texture)
            if icon then
                find=true
                return '|T'..icon..':0|t'..link
            end
        end
    end)
    if find then
        return text
    end
end







local function SetBullets(object, description, hideBullets)
    if Save().hideEncounterJournal then
        return
    end
    if not string.find(description, "%$bullet") then
        local text=EncounterJournal_SetBullets_setLink(description)
        if text then
            object.Text:SetText(text)
            object:SetHeight(object.Text:GetContentHeight())
        end
        return
    end
    local desc = strtrim(string.match(description, "(.-)%$bullet"))
    if (desc) then
        local text=EncounterJournal_SetBullets_setLink(desc)
        if text then
            object.Text:SetText(text)
            object:SetHeight(object.Text:GetContentHeight())
        end
    end

    local bullets = {}
    local k = 1
    local parent = object:GetParent()
    for v in string.gmatch(description,"%$bullet([^$]+)") do
        tinsert(bullets, v)
    end
    for j = 1,#bullets do
        local text = strtrim(bullets[j]).."|n|n"
        if (text and text ~= "") then
            text=EncounterJournal_SetBullets_setLink(text)
            local bullet = parent.Bullets and parent.Bullets[k]
            if text and bullet then
                bullet.Text:SetText(text)
                if (bullet.Text:GetContentHeight() ~= 0) then
                    bullet:SetHeight(bullet.Text:GetContentHeight())
                end
            end
            k = k + 1
        end
    end
end






local function UpdateButtonState(frame)--技能提示
    if frame.hook then
        return
    end

    frame:HookScript("OnEnter", function(self)
        local spellID= self:GetParent().spellID--self3.link
        e.LoadData({id=spellID, type='spell'})
        if not Save().hideEncounterJournal and spellID and spellID>0 then
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:SetSpellByID(spellID)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine((IsInGroup() and '|A:communities-icon-chat:0:0|a' or '')..(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT), e.Icon.right)
            e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_EncounterMixin.addName)
            e.tips:Show()
        end
    end)
    frame:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    frame:HookScript('OnClick', function(self, d)
        local spellID= self:GetParent().spellID--self3.link
        if not Save().hideEncounterJournal and spellID and spellID>0 and d=='RightButton' then
            local link= C_Spell.GetSpellLink(spellID) or spellID
            WoWTools_ChatMixin:Chat(link, nil, not IsInGroup())
        end
    end)
    frame.hook=true
end












function WoWTools_EncounterMixin:Init_Spell_Boss()--技能提示
    hooksecurefunc('EncounterJournal_UpdateButtonState', UpdateButtonState)
    hooksecurefunc('EncounterJournal_SetBullets', SetBullets)
end
