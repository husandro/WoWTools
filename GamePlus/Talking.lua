local id, e = ...
local Save={
    --notPrint= e.Player.husandro
}
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING)
local panel=CreateFrame('Frame')

local function setRegister()--设置事件
    if not Save.disabled then
        panel:RegisterEvent('TALKINGHEAD_REQUESTED')
    else
        panel:UnregisterEvent('TALKINGHEAD_REQUESTED')
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            local initializer2= e.AddPanel_Check({
                name= '|A:TalkingHeads-Glow-TopSpike:0:0|a'..(e.onlyChinese and '隐藏NPC发言' or addName),
                tooltip=format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '隐藏' or HIDE , e.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
                        ..'|n|n'..(e.onlyChinese and '声音' or SOUND)
                        ..'|nChat Button, '..(e.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
                        ..'|n'..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    setRegister()--设置事件
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled))
                end
            })

            local initializer= e.AddPanel_Check({
                name= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
                tooltip= addName,
                value= not Save.notPrint,
                func= function()
                    Save.notPrint= not Save.notPrint and true or nil
                end
            })
            initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)


 --[[
            --添加控制面板        
            local sel=e.AddPanel_Check('|A:TalkingHeads-Glow-TopSpike:0:0|a'..(e.onlyChinese and '隐藏NPC发言' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                setRegister()--设置事件
                print(id, addName, e.GetEnabeleDisable(not Save.disabled))
            end)
           sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '声音' or SOUND, e.GetEnabeleDisable(e.setPlayerSound))
                e.tips:AddDoubleLine('ChatButton, '..(e.onlyChinese and '超链接图标' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..EMBLEM_SYMBOL), e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', GameTooltip_Hide)

            local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
            sel2.text:SetText(e.onlyChinese and '文本' or LOCALE_TEXT_LABEL)
            sel2:SetPoint('LEFT', sel.text, 'RIGHT')
            sel2:SetChecked(not Save.notPrint)
            sel2:SetScript('OnMouseDown', function()
                Save.notPrint= not Save.notPrint and true or nil
            end)
]]
            setRegister()--设置事件
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='TALKINGHEAD_REQUESTED' then--TalkingHeadUI.lua
        local _, _, vo, _, _, _, name, text, isNewTalkingHead = C_TalkingHead.GetCurrentLineInfo()
        TalkingHeadFrame:CloseImmediately()
        if vo and vo>0 then
            if ( self.voHandle ) then
                StopSound(self.voHandle);
                self.voHandle = nil;
            end
            local success, voHandle = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true);
            if ( success ) then
                self.voHandle = voHandle;
            end
        end
        if not Save.notPrint and (text or self.voHandle) then
            print('|cff00ff00'..name..'|r','|cffff00ff'..text..'|r',id, e.cn(addName), 'soundKitID', vo)
        end
    end
end)
