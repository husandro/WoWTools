local function Save()
    return WoWToolsSave['Plus_GuildBank']
end


local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14






local function Init_Button()
--按钮，边框
    local showIndex= Save().showIndex

    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if btnIndex == 0 then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn= GuildBankFrame.Columns[column].Buttons[btnIndex]
        if btn then
            if not btn.indexText then
--索引
                WoWTools_TextureMixin:SetAlphaColor(btn.NormalTexture, nil, true, 0.2)
                btn.indexText= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1, a=0.3}})
                btn.indexText:SetPoint('CENTER')
--物品信息
                hooksecurefunc(btn, 'SetMatchesSearch', function(self)
                    WoWTools_ItemMixin:SetupInfo(self, {
                        guidBank= Save().showItemInfo and {tab=GetCurrentGuildBankTab(), slot=self:GetID()} or nil
                    })
                end)
            end
            btn.indexText:SetText(showIndex and slotID or '')
        end
    end
end



local function Init()
    Init_Button()

    Init=function()
        Init_Button()
    end
end


function WoWTools_GuildBankMixin:Init_Plus()
    Init()
end