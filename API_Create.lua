local e = select(2, ...)

--[[
e.Cstr(self, tab)
WoWTools_ButtonMixin:Cbtn(self, tab)--type, icon(atlas, texture), name, size, pushe, button='ItemButton', notWheel, setID, text

e.Ccool(self, start, duration, modRate, HideCountdownNumbers, Reverse, SwipeTexture, hideDrawBling)--冷却条
e.SetItemSpellCool(frame, {item=, spell=, type=, isUnit=true} type=true圆形，false方形
e.GetSpellItemCooldown(spellID, itemID)--法术,物品,冷却

e.Cbtn2(tab)


]]

function e.Cstr(self, tab)
    tab= tab or {}
    self= self or UIParent
    local name= tab.name
    local alpha= tab.alpha
    local font= tab.changeFont
    local layer= tab.layer or 'OVERLAY'--BACKGROUND BORDER ARTWORK OVERLAY HIGHLIGHT
    local fontName= tab.fontName or 'GameFontNormal'
    --local level= tab.level or self:GetFrameLevel()+1
    local copyFont= tab.copyFont
    local size= tab.size or 12
    local justifyH= tab.justifyH
    local notFlag= tab.notFlag
    local notShadow= tab.notShadow
    local color= tab.color
    local mouse= tab.mouse
    local wheel= tab.wheel

    font = font or self:CreateFontString(name, layer, fontName)
    if copyFont then
        local fontName2, size2, fontFlag2 = copyFont:GetFont()
        font:SetFont(fontName2, size or size2, fontFlag2)
        font:SetTextColor(copyFont:GetTextColor())
        font:SetFontObject(copyFont:GetFontObject())
        font:SetShadowColor(copyFont:GetShadowColor())
        font:SetShadowOffset(copyFont:GetShadowOffset())
        if justifyH then font:SetJustifyH(justifyH) end
        --if alpha then font:SetAlpha(alpha) end
    else
        if e.onlyChinese or size then--THICKOUTLINE
            local fontName2, size2, fontFlag2= font:GetFont()
            if e.onlyChinese then
                fontName2= 'Fonts\\ARHei.ttf'--黑体字
                --fontName2='Interface\\AddOns\\WoWTools\\Sesource\\Cloud24-Bold.ttf'
            end
            font:SetFont(fontName2, size or size2, notFlag and fontFlag2 or 'OUTLINE')
        end

        font:SetJustifyH(justifyH or 'LEFT')
    end
    if not notShadow then
        font:SetShadowOffset(1, -1)
    end
    if color~=false then
        if color==true then--颜色
            e.Set_Label_Texture_Color(font, {type='FontString'})
        elseif type(color)=='table' then
            font:SetTextColor(color.r, color.g, color.b, color.a or 1)
        else
            font:SetTextColor(1, 0.82, 0, 1)
        end
    end
    if mouse then
        font:EnableMouse(true)
    end
    if wheel then
        font:EnableMouseWheel(true)
    end
    if alpha then
        font:SetAlpha(alpha)
    end
    return font
end
--[[
function WoWTools_ButtonMixin:Cbtn(self, tab)--type, icon(atlas, texture), name, size, pushe, button='ItemButton', notWheel, setID, text
    tab=tab or {}
    local template= tab.type==false and 'UIPanelButtonTemplate' or (tab.type==true and 'SecureActionButtonTemplate') or tab.type
    SharedUIPanelTemplates.xml
    SecureTemplates
    SecureActionButtonTemplate	Button	Perform protected actions.
    SecureUnitButtonTemplate	Button	Unit frames.
    SecureAuraHeaderTemplate	Frame	Managing buffs and debuffs.
    SecureGroupHeaderTemplate	Frame	Managing group members.
    SecurePartyHeaderTemplate	Frame	Managing party members.
    SecureRaidGroupHeaderTemplate	Frame	Managing raid group members.
    SecureGroupPetHeaderTemplate	Frame	Managing group pets.
    SecurePartyPetHeaderTemplate	Frame	Managing party pets.
    SecureRaidPetHeaderTemplate
    btn:RegisterForClicks("AnyDown", "AnyUp")

    local btn= CreateFrame(tab.button or 'Button', tab.name, self or UIParent, template, tab.setID)
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    if not tab.notWheel then
        btn:EnableMouseWheel(true)
    end
    if tab.size then--大小
        if type(tab.size)=='number' then
            btn:SetSize(tab.size, tab.size)
        else
            btn:SetSize(tab.size[1], tab.size[2])
        end
    elseif tab.button=='ItemButton' then
        btn:SetSize(34, 34)
    end
    if tab.type~=false then
        if tab.pushe then
            btn:SetHighlightAtlas('bag-border')
            btn:SetPushedAtlas('bag-border-highlight')
        else --ChromieTime-Button-Selection
            btn:SetHighlightAtlas('auctionhouse-nav-button-select')--Forge-ColorSwatchSelection')
            btn:SetPushedAtlas('auctionhouse-nav-button-select')--UI-HUD-MicroMenu-Highlightalert')
            --auctionhouse-nav-button-select
            --auctionhouse-nav-button-secondary-select
        end
        if tab.icon~='hide' then
            if tab.texture then
                btn:SetNormalTexture(tab.texture)
            elseif tab.atlas then
                btn:SetNormalAtlas(tab.atlas)
            elseif tab.icon==true then
                btn:SetNormalAtlas(e.Icon.icon)
            else
                btn:SetNormalAtlas(e.Icon.disabled)
            end
        end
    end
    if tab.text then
        btn:SetText(tab.text)
    end
    if tab.alpha then
        btn:SetAlpha(tab.alpha)
    end
    return btn, template
end


]]












function e.Ccool(self, start, duration, modRate, HideCountdownNumbers, Reverse, setSwipeTexture, hideDrawBling)--冷却条
    if not self then
        return
    elseif not duration or duration<=0 then
        if self.cooldown then
            self.cooldown:Clear()
        end
        return
    end
    if not self.cooldown then
        self.cooldown= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
        self.cooldown:SetFrameLevel(self:GetFrameLevel()+5)
        self.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        self.cooldown:SetDrawBling(not hideDrawBling)--闪光
        self.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        self.cooldown:SetHideCountdownNumbers(HideCountdownNumbers)--隐藏数字
        self.cooldown:SetReverse(Reverse)--控制冷却动画的方向
        self.cooldown:SetAlpha(0.7)
        self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
        if setSwipeTexture then
            self.cooldown:SetSwipeTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')--圆框架
        end
        self:HookScript('OnHide', function(self2)
            if self2.cooldown then
                self2.cooldown:Clear()
            end
        end)
    end
    start=start or GetTime()
    self.cooldown:SetCooldown(start, duration, modRate)
end

function e.SetItemSpellCool(frame, tab)--{item=, spell=, type=, isUnit=true} type=true圆形，false方形
    if not frame or not tab then
        return
    end

    local item= tab.item
    local spell= tab.spell
    local type= tab.type
    local unit= tab.unit

    if unit then
        local texture, startTime, endTime, duration, channel

        if UnitExists(unit) then
            texture, startTime, endTime= select(3, UnitChannelInfo(unit))

            if not (texture and startTime and endTime) then
                texture, startTime, endTime= select(3, UnitCastingInfo(unit))
            else
                channel= true
            end
            if texture and startTime and endTime then
                duration= (endTime - startTime) / 1000
                e.Ccool(frame, nil, duration, nil, true, channel, nil,nil)
                return texture
            end
            e.Ccool(frame)
        end

    elseif item then
        local startTime, duration = C_Item.GetItemCooldown(item)

        e.Ccool(frame, startTime, duration, nil, true, nil, not type)
    elseif spell then
        local data= C_Spell.GetSpellCooldown(spell) or {}
        e.Ccool(frame, data.startTime, data.duration, data.modRate, true, nil, not type)--冷却条

    elseif frame.cooldown then
        e.Ccool(frame)
    end
end

--[[
Cooldown.lua
CooldownFrame_Set(self.SpellButton.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled)
CooldownFrame_Clear(self.SpellButton.Cooldown);
CooldownFrame_SetDisplayAsPercentage(self, percentage)
]]
function e.GetSpellItemCooldown(spellID, itemID)--法术,物品,冷却
    if spellID then
        if not C_Spell.GetOverrideSpell(spellID) then
            return
        end
        local data= C_Spell.GetSpellCooldown(spellID)
        if data then
            if data.duration>0 then
                local t= GetTime()
                while t<data.startTime do
                    t= t+86400
                end
                t= t-data.startTime
                t= data.duration-t
                t= t<0 and 0 or t
                return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'

            elseif not data.isEnabled then
                return '|cff9e9e9e'..(e.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
            end
        end
    elseif itemID then
        local startTime, duration, enable = C_Item.GetItemCooldown(itemID)
        if duration>0 then
            local t= GetTime()
            while t<startTime do
                t= t+86400
            end
            t= t-startTime
            t= duration-t
            t= t<0 and 0 or t
            return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'

        elseif C_Item.GetItemCount(itemID, true, false, true, true)>0 and not enable then
            return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
        end
    end
end
















function e.Cbtn2(tab)
    --[[
        e.Cbtn2({
            name=nil, 
            parent=,
            click=true,-- right left
            notSecureActionButton=nil,
            notTexture=nil,
            showTexture=true,
            size=nil,
            alpha=1,
            color={},
        })
    ]]
    local btn= CreateFrame("Button", tab.name, tab.parent or UIParent, not tab.notSecureActionButton and "SecureActionButtonTemplate" or nil)

    btn:SetSize(tab.size or 30, tab.size or 30)
    if tab.click==true then
        btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    elseif tab.click=='right' then
        btn:RegisterForClicks(e.RightButtonDown)
    elseif tab.click=='left' then
        btn:RegisterForClicks(e.LeftButtonDown)
    end
    btn:EnableMouseWheel(true)


    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')


    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)

    btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(tab.alpha or 0.5)
    btn.background:AddMaskTexture(btn.mask)


    if not tab.notTexture then
        btn.texture=btn:CreateTexture(nil, 'BORDER')
        btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
        btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
        btn.texture:AddMaskTexture(btn.mask)
        btn.texture:SetShown(tab.showTexture)
    end
    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)

    btn.border:SetAtlas('bag-reagent-border')

    if btn.color then
        btn.border:SetVertexColor(tab.color.r, tab.color.g, tab.color.b, tab.alpha)
    else
        e.Set_Label_Texture_Color(btn.border, {type='Texture', alpha=tab.alpha or 0.5})
    end
    return btn
end

