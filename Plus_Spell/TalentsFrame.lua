local function Save()
    return WoWToolsSave['Plus_Spell']
end






--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= WoWTools_LabelMixin:Create(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
            btn.maxText:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            btn.maxText:SetTextColor(1, 0, 1)
            btn.maxText:EnableMouse(true)
            btn.maxText:SetScript('OnLeave', GameTooltip_Hide)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_SpellMixin.addName)
                    GameTooltip:Show()
                end
            end)
        end
    end
    if btn.maxText then
        btn.maxText.maxRanks= info and info.maxRanks
        btn.maxText:SetText(text or '')
    end
end
















local function Set_TalentsFrameBg()
    if not Save().setUITexture then
        return
    end

    local show= Save().setUITexture or Save().bg.show
    local alpha= Save().setUITexture and 1 or 
    Save().bg.alpha or 1
    local tab={
        PlayerSpellsFrame.TalentsFrame.Background,
        PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background,
        PlayerSpellsFrame.TalentsFrame.BottomBar
    }
    for _, frame in pairs(tab) do
        frame:SetShown(show)
        frame:SetAlpha(alpha)
    end
end






        
local function Set_UI()
    if not Save().setUITexture then
        return
    end
    WoWTools_TextureMixin:SetAlphaColor(PlayerSpellsFrameBg)
    WoWTools_TextureMixin:SetNineSlice(PlayerSpellsFrame, 0.3)
    WoWTools_TextureMixin:SetTabSystem(PlayerSpellsFrame)

    WoWTools_TextureMixin:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background)--专精
    WoWTools_TextureMixin:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    WoWTools_TextureMixin:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    WoWTools_TextureMixin:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)
    WoWTools_TextureMixin:SetSearchBox(PlayerSpellsFrame.TalentsFrame.SearchBox)


    WoWTools_TextureMixin:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书
    WoWTools_TextureMixin:SetSearchBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    WoWTools_TextureMixin:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)



    --英雄专精
    WoWTools_TextureMixin:SetNineSlice(HeroTalentsSelectionDialog, nil, nil, true, false)

    Set_UI= function()end
end








local function Init_Menu(self, root)--隐藏，天赋，背景
    local sub, sub2
    root:CreateDivider()

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER,
    function()
        return Save().setUITexture
    end, function()
        Save().setUITexture= not Save().setUITexture and true or nil
    end)

    sub=WoWTools_MenuMixin:ShowBackground(root, function()
        return Save().bg.show
    end, function()
        Save().bg.show= not Save().bg.show and true or nil
        Set_TalentsFrameBg()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_SpellMixin.addName)
    end)
    

    sub2=sub:CreateButton(
        'Web',
    function(data)
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, data.name)
        return MenuResponse.Open
    end, {name=[[https://www.aconvert.com/]]})
    sub2:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
    end)


--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().bg.alpha or 1
        end, setValue=function(value)
            Save().bg.alpha=value
            Set_TalentsFrameBg()
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.01,
        bit='%.2f',
    })
    sub:CreateSpacer()
end










local function Init()
    if not Save().talentsFramePlus or not C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        return
    end

    hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 
    Menu.ModifyMenu("MENU_CLASS_TALENT_PROFILE", Init_Menu)
    Set_TalentsFrameBg()


    hooksecurefunc(PlayerSpellsFrame.TalentsFrame, "UpdateSpecBackground", function(self)
        print('UpdateSpecBackground')
        --resetTextScript(self)
    end)

    Init=function()end
end







function WoWTools_SpellMixin:Init_TalentsFrame()
    Init()
    Set_UI()
end
