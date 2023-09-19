local id, e = ...
local Save={
    --disabled=true,
    emoji= e.Player.cn or e.Player.husandro,
    scale=0.8
}
local addName='ChatButton'
local panel= CreateFrame("Frame")

local button

--####
--初始
--####
local function Init()
    
    if Save.scale and Save.scale~=1 then--缩放
        button:SetScale(Save.scale)
    end
    function button:set_Point()
        self:ClearAllPoints()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end
    end
    button:set_Point()

    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)
    button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsControlKeyDown() then--还原
            Save.Point=nil
            self:set_Point()
            print(id ,addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)
    button:SetScript("OnMouseUp", function() ResetCursor() end)

    button:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        local sacle=Save.scale or 1
        if d==1 then
            sacle=sacle+0.05
        elseif d==-1 then
            sacle=sacle-0.05
        end
        sacle= sacle>4 and 4 or sacle
        sacle= sacle<0.4 and 0.4 or sacle
        self:SetScale(sacle)
        Save.scale=sacle
        print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..sacle)
    end)
    button:SetScript("OnLeave",function(self)
        ResetCursor()
        e.tips:Hide()
    end)
    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '重置位置' or RESET_POSITION, 'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end)

    button:SetButtonState('PUSHED')
    C_Timer.After(6, function()
        button:SetButtonState('NORMAL')
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            button= e.Cbtn(nil, {name='WoWToolsChatButtonFrame', icon='hide', size={10,30}})
            WoWToolsChatButtonFrame.last= button

            Save= WoWToolsSave[addName] or Save
            button.disabled= Save.disabled
            button.ShowEmojiButton= Save.emoji

            --添加控制面板
            e.AddPanel_Header(nil, 'Chat')
            local initializer2= e.AddPanel_Check({
                name= '|A:transmog-icon-chat:0:0|a'..(e.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS)),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    button.disabled= Save.disabled
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
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
            initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)

            if not Save.disabled then
                Init()
                SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)
            else
                self:SetShown(false)
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)