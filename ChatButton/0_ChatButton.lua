local id, e = ...
local Save={
    --disabled=true,
    emoji= e.Player.cn or e.Player.husandro,
    scale= 1,
}
local addName
local ChatButton

























local function Init_Menu(self, root)
    root:CreateButton((Save.Point and '' or '|cff606060')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.Point=nil
        self:set_point()
    end)
    root:CreateButton((Save.scale~=1 and '' or '|cff606060')..(e.onlyChinese and '重置缩放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, UI_SCALE)), function(...)
        Save.scale= e.Player.husandro and 0.8 or 1
        self:set_scale()
    end)

    root:CreateDivider()
    root:CreateButton(e.onlyChinese and '选项' or OPTIONS, function()
        e.OpenPanelOpting(addName)
    end)
end


















--####
--初始
--####
local function Init()
    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)

    function ChatButton:set_scale()
        if Save.scale then--缩放
            self:SetScale(Save.scale)
        end
    end
    function ChatButton:set_point()
        self:ClearAllPoints()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end
    end
    function ChatButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
        e.tips:Show()
    end

    ChatButton:set_point()
    ChatButton:set_scale()
    
    ChatButton:RegisterForDrag("RightButton")
    ChatButton:SetMovable(true)
    ChatButton:SetClampedToScreen(true)

    ChatButton:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    ChatButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)

    ChatButton:SetScript("OnMouseUp", ResetCursor)
    ChatButton:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    ChatButton:SetScript("OnClick", function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    ChatButton:SetScript('OnMouseWheel', function(self, d)--缩放
        Save.scale=e.Set_Frame_Scale(self, d, Save.scale, nil)
        self:set_tooltip()
        self:set_scale()
    end)


    ChatButton:SetScript("OnLeave",function()
        ResetCursor()
        e.tips:Hide()
    end)
    ChatButton:SetScript('OnEnter',ChatButton.set_tooltip)

end














--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButton'] or Save
            addName='|A:transmog-icon-chat:0:0|a'..(e.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS))

            --添加控制面板
            e.AddPanel_Header(nil, 'ChatButton')

            local initializer2= e.AddPanel_Check_Button({
                checkName= addName,
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.Point=nil
                    if ChatButton then
                        ChatButton:set_point()
                    end
                    print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= addName,
                layout= nil,
                category= nil,
            })

            local initializer= e.AddPanel_Check({
                name= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\greet:0|tEmoji',
                tooltip= addName..', Emoji',
                value= Save.emoji,
                func= function()
                    Save.emoji= not Save.emoji and true or nil
                    print(id, addName, 'Emoji', e.GetEnabeleDisable(Save.emoji), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            initializer:SetParentInitializer(initializer2, function() if Save.disabled then return false else return true end end)


            if not Save.disabled then
                ChatButton= WoWToolsChatButtonMixin:Init({
                    emoji= not Save.emoji and true or nil,
                })                
                Init()

            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton']=Save
        end
    end
end)