WoWTools_ChatMixin={

}





--[[
ChatEdit_TryInsertChatLink(link)
ChatEdit_LinkItem(itemID, itemLink)
ChatFrameUtil.OpenChat 11.2.7才有
--]]
function WoWTools_ChatMixin:Chat(text, name, printText)
    if not text then
        return
    end
    if name then
        C_ChatInfo.SendChatMessage(text, 'WHISPER', nil, name)
    elseif printText then
        if not ChatEdit_InsertLink(text) then
            WoWTools_DataMixin:Call(ChatFrame_OpenChat, text)
        end
        
        --[[if ChatEdit_GetActiveWindow() then
            WoWTools_DataMixin:Call(ChatEdit_InsertLink, text)
        else
            WoWTools_DataMixin:Call(ChatFrame_OpenChat, text)
        end]]
    else
        local isNotDead= not UnitIsDeadOrGhost('player')
        local isInInstance= IsInInstance()
        if isInInstance and isNotDead then-- and C_CVar.GetCVarBool("chatBubbles") then
            C_ChatInfo.SendChatMessage(text, 'YELL')

        elseif isInInstance and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            C_ChatInfo.SendChatMessage(text, 'INSTANCE_CHAT')

        elseif IsInRaid() then
            C_ChatInfo.SendChatMessage(text, 'RAID')

        elseif IsInGroup() then--and C_CVar.GetCVarBool("chatBubblesParty") then
            C_ChatInfo.SendChatMessage(text, 'PARTY')
            --elseif isNotDead and IsOutdoors() and not UnitAffectingCombat('player') then
                --C_ChatInfo.SendChatMessage(text, 'YELL')
            -- elseif setPrint then
        else
            if text:find('{rt%d}') then
                text= text:gsub('{rt%d}', function(s)
                    local icon= s:match('%d')
                    if icon then
                        return format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t', icon)
                    end
                end)
            end
            print(text)
        end
    end
end






--ChatFrameEditBoxMixin.SendText 11.2.7才有
function WoWTools_ChatMixin:SendText(text)
    if not text then
        return
    end
    local msg= DEFAULT_CHAT_FRAME:IsShown() and DEFAULT_CHAT_FRAME.editBox:GetText() or ''
    DEFAULT_CHAT_FRAME.editBox:SetText(text)
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    if msg~='' then
        ChatFrame_OpenChat(msg, DEFAULT_CHAT_FRAME)
        if DEFAULT_CHAT_FRAME.editbox then
            DEFAULT_CHAT_FRAME.editbox:ClearFocus()
        end
    end
end






function WoWTools_ChatMixin:Say(type, name, wow, text)
    local chat= SELECTED_DOCK_FRAME
    local msg = chat.editBox:GetText() or ''
    if text and text==msg then
        text=''
    else
        text= text or ''
    end
    if msg:find('/') then msg='' end
    msg=' '..msg
    if name then
        if wow then
            ChatFrame_SendBNetTell(name..msg..(text or ''))
        else
            ChatFrame_OpenChat("/w " ..name..msg..(text or ''), chat)
        end
    elseif type then
        ChatFrame_OpenChat(type..msg..(text or ''), chat)
    end
end