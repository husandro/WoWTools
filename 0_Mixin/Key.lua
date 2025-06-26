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
    if not btn then
        return
    end
    btn.GetKEY= GetValue or btn.GetKey or btn.GetKEY
    btn.KEYstring=WoWTools_LabelMixin:Create(btn,{size=12, color={r=1,g=1,b=1}})
    btn.KEYstring:SetPoint('TOPRIGHT')

    btn.KEYtexture=btn:CreateTexture(nil,'OVERLAY')
    btn.KEYtexture:SetPoint('BOTTOM', btn.border, -1, -3)
    btn.KEYtexture:SetAtlas('NPE_ArrowDown')
    btn.KEYtexture:SetVertexColor(0,1,0)
    btn.KEYtexture:SetDesaturated(true)
    btn.KEYtexture:SetSize(30, 15)
    btn.KEYtexture:Hide()

    function btn:get_key_text()
        local key=self:GetKEY()
        if key then
            return (WoWTools_KeyMixin:IsKeyValid(self) and '|cnGREEN_FONT_COLOR:' or '|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
            ..'|A:NPE_Icon:0:0|a'..(key or '')
            ..'|r'
        end
    end

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
    --if UnitAffectingCombat('player') then
    if not btn:CanChangeAttribute() then
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
function WoWTools_KeyMixin:SetMenu(frame, root, tab)
    local sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '设置捷键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, SETTINGS_KEYBINDINGS_LABEL))
        ..(tab.key and ' ['..tab.key..']' or ''),
    function(data)
        StaticPopup_Show('WoWTools_EditText',
            (data.name and data.name..' ' or '')
            ..(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
            ..'|n|n"|cnGREEN_FONT_COLOR:Q|r", "|cnGREEN_FONT_COLOR:ALT-Q|r","|cnGREEN_FONT_COLOR:BUTTON5|r"|n"|cnGREEN_FONT_COLOR:ALT-CTRL-SHIFT-Q|r"',
            nil,
            {
                text=data.key,
                key=data.key,
                OnShow=function(s, tab2)
                    local edit= s.editBox or s:GetEditBox()
                    if not tab2.key then
                        edit:SetText('BUTTON5')
                    end
                end,
                SetValue=function(s, tab2)
                    local edit= s.editBox or s:GetEditBox()
                    local text= edit:GetText()
                    text=text:gsub(' ','')
                    text=text:gsub('%[','')
                    text=text:gsub(']','')
                    text=text:upper()
                    tab2.GetKey(text)
                    print(WoWTools_DataMixin.addName, data.name, text)
                end,
                OnAlt=data.OnAlt,
                GetKey=data.GetKey,
            }
        )
    end, tab)
    sub:SetEnabled(frame:CanChangeAttribute() and not InCombatLockdown())

    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS, desc.data.name)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,
            desc.data.key
        )
        tooltip:AddLine(frame:get_key_text())
    end)

    --sub:SetEnabled(not UnitAffectingCombat('player'))
    return sub
end

--[[

--设置捷键
    sub:CreateSpacer()
    local text2, num2= WoWTools_MenuMixin:GetDragonriding()--驭空术
    WoWTools_KeyMixin:SetMenu(self, sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=addName..(num2 and num2>0 and text2 or ''),
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
        GameTooltip:AddDoubleLine(
            self.typeSpell and WoWTools_SpellMixin:GetName(self.typeID) or WoWTools_ItemMixin:GetName(self.typeID),
            (key and '|cnGREEN_FONT_COLOR:'..key or '')..WoWTools_DataMixin.Icon.left
        )
    end

    local key= WoWTools_KeyMixin:IsKeyValid(self)
    if key then
        GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL), '|cnGREEN_FONT_COLOR:'..key)
    end
]]









function WoWTools_KeyMixin:SetButtonKey(frame, set, key, click)--设置清除快捷键
    if set then
        SetOverrideBindingClick(frame, true, key, frame:GetName(), click or 'LeftButton')
    else
        ClearOverrideBindings(frame)
    end
end


--NPE_ArrowDown
--NPE_ArrowUp

local KeyTabs={
    KEY_BUTTON1='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    KEY_BUTTON2='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    KEY_BUTTON3='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    KEY_MOUSEWHEELUP='|A:NPE_ArrowUp:0:0|a',
    KEY_MOUSEWHEELDOWN= '|A:NPE_ArrowDown:0:0|a',
}
local KEY_BUTTON = KEY_BUTTON10:gsub(10, '')--"鼠标按键10"

local function set_keytext(keyText)
    local text= keyText
    if not text or text=='' then
        return
    end

    if KeyTabs[text] then
        return KeyTabs[text]
    end

    text= text:gsub(KEY_BUTTON, 'm')
    text= text:gsub('鼠标按键', 'm')

    if text~=keyText then
        return text
    end
end

function WoWTools_KeyMixin:GetHotKeyText(text, action)
    if text then
        return set_keytext(text)

    elseif action then
        return set_keytext(GetBindingKeyForAction(action, false, false))
    end
end