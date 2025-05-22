local function Save()
    return WoWToolsSave['Plus_Spell']
end

local function Call_Bg()
    WoWTools_Mixin:Call(PlayerSpellsFrame.TalentsFrame.UpdateSpecBackground, PlayerSpellsFrame.TalentsFrame)
    --PlayerSpellsFrame.TalentsFrame:UpdateSpecBackground()
end


local TextureTab={--TalentArt
['talents-background-warrior-arms']=true,
['talents-background-warrior-fury']=true,
['talents-background-warrior-protection']=true,

['talents-background-paladin-holy']=true,
['talents-background-paladin-protection']=true,
['talents-background-paladin-retribution']=true,

['talents-background-deathknight-blood']=true,
['talents-background-deathknight-frost']=true,
['talents-background-deathknight-unholy']=true,

['talents-background-hunter-beastmastery']=true,
['talents-background-hunter-marksmanship']=true,
['talents-background-hunter-survival']=true,

['talents-background-shaman-elemental']=true,
['talents-background-shaman-enhancement']=true,
['talents-background-shaman-restoration']=true,

['talents-background-evoker-devastation']=true,
['talents-background-evoker-preservation']=true,
['talents-background-evoker-augmentation']=true,

['talents-background-druid-balance']=true,
['talents-background-druid-feral']=true,
['talents-background-druid-guardian']=true,
['talents-background-druid-restoration']=true,

['talents-background-rogue-assassination']=true,
['talents-background-rogue-outlaw']=true,
['talents-background-rogue-subtlety']=true,

['talents-background-monk-brewmaster']=true,
['talents-background-monk-mistweaver']=true,
['talents-background-monk-windwalker']=true,

['talents-background-demonhunter-havoc']=true,
['talents-background-demonhunter-vengeance']=true,

['talents-background-priest-discipline']=true,
['talents-background-priest-holy']=true,
['talents-background-priest-shadow']=true,

['talents-background-mage-arcane']=true,
['talents-background-mage-fire']=true,
['talents-background-mage-frost']=true,

['talents-background-warlock-affliction']=true,
['talents-background-warlock-demonology']=true,
['talents-background-warlock-destruction']=true,

['UI-Frame-KyrianChoice-ScrollingBG']=true,
['UI-Frame-NecrolordsChoice-ScrollingBG']=true,
['UI-Frame-NightFaeChoice-ScrollingBG']=true,
['UI-Frame-VenthyrChoice-ScrollingBG']=true,
['scoreboard-background-warfronts-darkshore-horde']=true,
['scoreboard-background-islands-alliance']=true,

['legionmission-complete-background-warrior']=true,
['legionmission-complete-background-druid']=true,

['legionmission-complete-background-Paladin']=true,
['legionmission-complete-background-hunter']=true,
['legionmission-complete-background-Rogue']=true,
['legionmission-complete-background-Priest']=true,
['legionmission-complete-background-deathknight']=true,
['legionmission-complete-background-Shaman']=true,
['legionmission-complete-background-Mage']=true,
['legionmission-complete-background-Warlock']=true,
['legionmission-complete-background-Monk']=true,
['legionmission-complete-background-demonhunter']=true,

}
















local function Set_TalentsFrameBg()
    local show= Save().bg.show
    local alpha= Save().bg.alpha or 1
    local tab={
        PlayerSpellsFrame.TalentsFrame.Background,
        --PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background,
        PlayerSpellsFrame.TalentsFrame.BottomBar
    }
    for _, texture in pairs(tab) do
        if show then
            texture:SetAlpha(alpha)
        else
            texture:SetAlpha(0)
        end
    end
    PlayerSpellsFrame.TalentsFrame.BottomBar:SetAlpha(0)

    PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    --[[PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT')
    if show then
        PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame.TalentsFrame, 'BOTTOMRIGHT')
    else
        PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame.TalentsFrame.BottomBar, 'TOPRIGHT')
    end]]


    local isAtlas, textureID= WoWTools_TextureMixin:IsAtlas(Save().bg.icon)
    if textureID then
        if isAtlas then
            PlayerSpellsFrame.SpecFrame.Background:SetAtlas(textureID)
        else
            PlayerSpellsFrame.SpecFrame.Background:SetTexture(textureID)
        end
    else
        PlayerSpellsFrame.SpecFrame.Background:SetAtlas('spec-background')
        alpha= 0.3
    end
    PlayerSpellsFrame.SpecFrame.Background:SetShown(show)
    PlayerSpellsFrame.SpecFrame.Background:SetAlpha(alpha)
end





















local function Init_Texture_Sub_Menu(_, root, name)
    local sub
    local isAtlas, textureID, icon= WoWTools_TextureMixin:IsAtlas(name, {480, 240})
    if not textureID then
        return
    end
    sub=root:CreateCheckbox(
        '',
    function(data)
        return data.name== Save().bg.icon
    end, function(data)
        if data.name== Save().bg.icon then
            Save().bg.icon=nil
        else
            Save().bg.icon= data.name
        end
        Call_Bg()
    end, {isAtlas=isAtlas, name=textureID, icon=icon})

    sub:AddInitializer(function(button, desc)
        local texture = button:AttachTexture();
        texture:SetSize(64, 32)
        texture:SetPoint("RIGHT")
        if desc.data.isAtlas then
            texture:SetAtlas(desc.data.name)
        else
            texture:SetTexture(desc.data.name)
        end
    end)

    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.icon)
        tooltip:AddLine(desc.data.name)
    end)
    return sub
end


local function Init_Texture_Menu(self, root)
    local num=0
    for name in pairs(Save().bg.texture) do
        local sub=Init_Texture_Sub_Menu(self, root, name)
        if sub then
            sub:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            function(data)
                return Save().bg.texture[data.name]
            end, function(data)
                Save().bg.texture[data.name]= not Save().bg.texture[data.name] and true or nil
                return MenuResponse.Refresh
            end, {name=name})
            num=num+1
        end
    end

    if num>3 then
        root:CreateDivider()
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            nil,
            {SetValue=function()
                Save().bg.texture={}
            end}
        )
        end)
    end
    root:CreateDivider()

    for name in pairs(TextureTab) do
        Init_Texture_Sub_Menu(self, root, name)
    end

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end


















local function Init_Menu(self, root)--隐藏，天赋，背景
    local sub, sub2, sub3
    root:CreateDivider()
--显示背景
    sub=WoWTools_MenuMixin:ShowBackground(root, function()
        return Save().bg.show
    end, function()
        Save().bg.show= not Save().bg.show and true or nil
        WoWTools_SpellMixin:Init_TalentsFrame()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_SpellMixin.addName)
    end)


    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM,
    function()
        return Save().bg.icon
    end, function()
        Save().bg.icon= nil
        Call_Bg()
    end)
    sub2:SetTooltip(function (tooltip)
        local _, textureID, icon= WoWTools_TextureMixin:IsAtlas(Save().bg.icon, {480, 240})
        if textureID then
            tooltip:AddLine(icon)
            tooltip:AddLine(textureID)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )
        end
    end)

    sub2:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND)..'\n\nTexture or Atlas\n',
        nil,
        {
            OnShow=function(s)
                s.button1:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                s.editBox:SetText('Interface\\AddOns\\WoWTools\\Source\\Background\\')
            end,
            SetValue= function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s.editBox:GetText(), 0))
                if textureID then
                    Save().bg.icon= textureID
                    Call_Bg()
                    if not TextureTab[textureID] then
                        Save().bg.texture[textureID]=true
                    end
                end
            end,
            EditBoxOnTextChanged=function(s)
                s:GetParent().button1:SetEnabled(select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0)))
            end,
        }
    )
    end)

--材质，列表
    Init_Texture_Menu(self, sub2)



    sub:CreateSpacer()
--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().bg.alpha or 1
        end, setValue=function(value)
            Save().bg.alpha=value
            WoWTools_SpellMixin:Init_TalentsFrame()
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.01,
        bit='%.2f',
    })
    sub:CreateSpacer()

   -- sub:CreateDivider()




--打开选项界面
    sub2=WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_SpellMixin.addName, category=WoWTools_SpellMixin.Category})
--Web
    sub3=sub2:CreateButton(
        'Web',
    function(data)
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, data.name)
        return MenuResponse.Open
    end, {name=[[https://www.aconvert.com/]]})
    sub3:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
    end)
end








local function Init()
--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
    hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', function(btn)
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
    end)


--背景
    PlayerSpellsFrame.TalentsFrame.BottomBar:SetAlpha(0)

    PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT')
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame.TalentsFrame, 'BOTTOMRIGHT')
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.ExpandedContainer.Background:SetAlpha(0.2)

    local SetValueTab={
        isHook=true,
        icons={PlayerSpellsFrame.SpecFrame.Background},
        setFunc= Call_Bg,
    }

    WoWTools_TextureMixin:SetBG_Settings('TalentsFrameBackground', PlayerSpellsFrame.TalentsFrame.Background, SetValueTab)

    Menu.ModifyMenu("MENU_CLASS_TALENT_PROFILE", function(_, root)
        root:CreateDivider()
        WoWTools_TextureMixin:BGMenu(root, 'TalentsFrameBackground', PlayerSpellsFrame.TalentsFrame.Background, SetValueTab)
    end)

    hooksecurefunc(PlayerSpellsFrame.TalentsFrame, "UpdateSpecBackground", function(self)
        if self.Background.Set_BGTexture then

            local currentSpecID = self:GetSpecID()
            local specVisuals = ClassTalentUtil.GetVisualsForSpecID(currentSpecID);
            if specVisuals and specVisuals.background and C_Texture.GetAtlasInfo(specVisuals.background) then
                self.Background.set_BGData.p_texture= specVisuals.background
            end

            self.Background:Set_BGTexture()
        end
    end)
    --Menu.ModifyMenu("MENU_CLASS_TALENT_PROFILE", Init_Menu)


--ClassTalentsFrameMixin
    --[[hooksecurefunc(PlayerSpellsFrame.TalentsFrame, "UpdateSpecBackground", function(self)
        local icon= Save().bg.show and Save().bg.icon
        if not icon then
            return
        end
    
        if WoWTools_TextureMixin:IsAtlas(icon) then
            self.Background:SetAtlas(icon)
        else
            self.Background:SetTexture(icon)
        end
    end)]]


    WoWTools_SpellMixin:Set_UI()




    Init=function()
        --Set_TalentsFrameBg()
    end
end







function WoWTools_SpellMixin:Init_TalentsFrame()
    if Save().talentsFramePlus and C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        Init()
    end
end
