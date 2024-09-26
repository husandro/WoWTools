local e= select(2, ...)
WoWTools_KeyMixin={}

local Frame=CreateFrame('Frame')
Frame.buttons={}

function Frame:set_event(enable)
    if enable then
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end

Frame:SetScript("OnEvent", function(self)
    do
        for btn, info in pairs(self.buttons) do
            WoWTools_KeyMixin:Setup(btn, info.isDisabled)
        end
    end
    self.buttons={}
    self:set_event(false)
end)






function WoWTools_KeyMixin:Init(btn, GetValue, notSetup)
    btn.GetKEY= GetValue or btn.GetKey
    btn.KEYstring=WoWTools_LabelMixin:CreateLabel(btn,{size=12, color={r=1,g=1,b=1}})
    btn.KEYstring:SetPoint('TOPRIGHT')

    btn.KEYtexture=btn:CreateTexture(nil,'OVERLAY')
    btn.KEYtexture:SetPoint('BOTTOM', btn.border, -1, -3)
    btn.KEYtexture:SetAtlas('NPE_ArrowDown')
    btn.KEYtexture:SetVertexColor(0,1,0)
    btn.KEYtexture:SetDesaturated(true)
    btn.KEYtexture:SetSize(30, 15)
    btn.KEYtexture:Hide()

    if not notSetup then
        self:Setup(btn)
    end
end



function WoWTools_KeyMixin:IsKeyValid(btn)
    local key=btn:GetKEY()
    local action= key and GetBindingAction(key, true)
    if action and action==('CLICK '..btn:GetName()..':LeftButton') then
        return key
    end
end

function WoWTools_KeyMixin:SetTexture(btn, key)
    key=key or btn:GetKEY()
    if self:IsKeyValid(btn) then
        if #key==1 then
            btn.KEYstring:SetText(key)
            btn.KEYtexture:SetShown(false)
        else
            btn.KEYstring:SetText('')
            btn.KEYtexture:SetShown(true)
        end
    else
        btn.KEYstring:SetText('')
        btn.KEYtexture:SetShown(false)
    end
end




function WoWTools_KeyMixin:Setup(btn, isDisabled)
    if UnitAffectingCombat('player') then
        Frame.buttons[btn]={isDisabled=isDisabled}
        Frame:set_event(true)
        return
    end

    local key=btn:GetKEY()
    if key and not isDisabled then
        SetOverrideBindingClick(btn, true, key, btn:GetName(), 'LeftButton')
    else
        ClearOverrideBindings(btn)
    end
    self:SetTexture(btn)
end
    --[[if self:IsKeyValid(btn) then
        if #key==1 then
            btn.KEYstring:SetText(key)
            btn.KEYtexture:SetShown(false)
        else
            btn.KEYstring:SetText('')
            btn.KEYtexture:SetShown(true)
        end
    else
        btn.KEYstring:SetText('')
        btn.KEYtexture:SetShown(false)
    end
end]]





--快捷键
function WoWTools_KeyMixin:SetMenu(root, tab)
    local sub=root:CreateCheckbox(
        '|A:NPE_Icon:0:0|a'
        ..(UnitAffectingCombat('player') and '|cff9e9e9e' or '')
        ..(tab.key or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL))
        ..(tab.icon or ''),
    function(data)
        return data.key~=nil
    end, function(data)
        StaticPopup_Show('WoWTools_EditText',
            (data.name and data.name..' ' or '')
            ..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
            ..'|n|n"|cnGREEN_FONT_COLOR:Q|r", "|cnGREEN_FONT_COLOR:ALT-Q|r","|cnGREEN_FONT_COLOR:BUTTON5|r"|n"|cnGREEN_FONT_COLOR:ALT-CTRL-SHIFT-Q|r"',
            nil,
            {
                text=data.key,
                key=data.key,
                OnShow=function(s, tab2)
                    if not tab2.key then
                        s.editBox:SetText('BUTTON5')
                    end
                end,
                SetValue=function(s, tab2)
                    local text= s.editBox:GetText()
                    text=text:gsub(' ','')
                    text=text:gsub('%[','')
                    text=text:gsub(']','')
                    text=text:upper()
                    tab2.GetKey(text)
                    print(e.addName, data.name, text)
                end,
                OnAlt=data.OnAlt,
                GetKey=tab.GetKey,
            }
        )
    end, tab)
    sub:SetTooltip(function(tooltip, description)
        tooltip:AddLine(e.onlyChinese and '设置' or SETTINGS)
        tooltip:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, description.data.key)
    end)
    sub:SetEnabled(not UnitAffectingCombat('player') and true or false)
    return sub
end

--[[

--设置捷键
    sub:CreateSpacer()
    local text2, num2= WoWTools_MenuMixin:GetDragonriding()--驭空术
    WoWTools_KeyMixin:SetMenu(sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=addName..(num2 and num2>0 and text2 or ''),
        key=Save.KEY,
        GetKey=function(key)
            Save.KEY=key
            WoWTools_KeyMixin:Setup(MountButton)--设置捷键
        end,
        OnAlt=function()
            Save.KEY=nil
            WoWTools_KeyMixin:Setup(MountButton)--设置捷键
        end,
    })
    
    WoWTools_KeyMixin:Init(MountButton, function() return Save.KEY end)




    if self.typeID then
        local key= WoWTools_KeyMixin:IsKeyValid(self)
        e.tips:AddDoubleLine(
            self.typeSpell and WoWTools_SpellMixin:GetName(self.typeID) or WoWTools_ItemMixin:GetName(self.typeID),
            (key and '|cnGREEN_FONT_COLOR:'..key or '')..e.Icon.left
        )
    end

    local key= WoWTools_KeyMixin:IsKeyValid(self)
    if key then
        e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL), '|cnGREEN_FONT_COLOR:'..key)
    end
]]