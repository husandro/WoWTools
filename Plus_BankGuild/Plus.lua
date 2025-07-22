




local function Init()
    --按钮，边框
    local MAX_GUILDBANK_SLOTS_PER_TAB = 98
    local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if btnIndex == 0 then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn= GuildBankFrame.Columns[column].Buttons[btnIndex]
        if btn then
            WoWTools_TextureMixin:SetAlphaColor(btn.NormalTexture, nil, nil, 0.2)
            btn.indexText= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1, a=0.3}})
            btn.indexText:SetPoint('CENTER')
            btn.indexText:SetText(slotID)
        end
    end

    Init=function() end
end


function WoWTools_GuildBankMixin:Guild_Plus()
    Init()
end