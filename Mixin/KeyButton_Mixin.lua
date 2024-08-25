local e= select(2, ...)
WoWTools_Key_Button={
    Buttons={}
}




function WoWTools_Key_Button:Init(btn, GetValue)
    btn.GetKEY= GetValue
    btn.KEYstring=e.Cstr(btn,{size=12, color={r=1,g=1,b=1}})
    btn.KEYstring:SetPoint('TOPRIGHT')

    btn.KEYtexture=btn:CreateTexture(nil,'OVERLAY')
    btn.KEYtexture:SetPoint('BOTTOM', btn.border, -1, -3)
    btn.KEYtexture:SetAtlas('NPE_ArrowDown')
    btn.KEYtexture:SetVertexColor(0,1,0)
    btn.KEYtexture:SetDesaturated(true)
    btn.KEYtexture:SetSize(30, 15)

    self:Setup(btn)
end



function WoWTools_Key_Button:IsKeyValid(btn)
    local key=btn:GetKEY()
    local action= key and GetBindingAction(key, true)
    if action and action==('CLICK '..btn:GetName()..':LeftButton') then
        return key
    end
end

function WoWTools_Key_Button:Setup(btn, isHide)
    
    local key=btn:GetKEY()
    if not UnitAffectingCombat('player') then
        if key and not isHide then
            SetOverrideBindingClick(btn, true, key, btn:GetName(), 'LeftButton')
        else
            ClearOverrideBindings(btn)
        end
    end
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
        btn.KEYtexture:SetShown(true)
    end
end





--快捷键
function WoWTools_Key_Button:SetMenu(root, tab)
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
    return sub
end

--[[
WoWTools_Key_Button:SetMenu(sub, {
    icon='',
    name=addName,
    text=,
    key=,
    GetKey=function(key)
    end,
    OnAlt=function(s, data)
    end,
})
]]