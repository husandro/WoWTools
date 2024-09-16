local e= select(2, ...)
WoWTools_ChatMixin={}





--[[
ChatEdit_TryInsertChatLink(link)
ChatEdit_LinkItem(itemID, itemLink)
--]]
function WoWTools_ChatMixin:Chat(text, name, printText)
    if text then
        if name then
            SendChatMessage(text, 'WHISPER', nil, name)
        elseif printText then
            if not e.call(ChatEdit_InsertLink, text) then
                e.call(ChatFrame_OpenChat, text)
            end
            securecallfunction(ChatFrame_OpenChat, 'a')
            --[[if ChatEdit_GetActiveWindow() then
                e.call(ChatEdit_InsertLink, text)
            else
                e.call(ChatFrame_OpenChat, text)
            end]]
        else
            local isNotDead= not UnitIsDeadOrGhost('player')
            local isInInstance= IsInInstance()
            if isInInstance and isNotDead then-- and C_CVar.GetCVarBool("chatBubbles") then
                SendChatMessage(text, 'YELL')

            elseif isInInstance and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                SendChatMessage(text, 'INSTANCE_CHAT')

            elseif IsInRaid() then
                SendChatMessage(text, 'RAID')

            elseif IsInGroup() then--and C_CVar.GetCVarBool("chatBubblesParty") then
                SendChatMessage(text, 'PARTY')
                --elseif isNotDead and IsOutdoors() and not UnitAffectingCombat('player') then
                    --SendChatMessage(text, 'YELL')
                -- elseif setPrint then
            else
                print(text)
            end
        end
    end
end







function WoWTools_ChatMixin:SendText(text)
    local msg= DEFAULT_CHAT_FRAME:IsShown() and DEFAULT_CHAT_FRAME.editBox:GetText() or ''
    DEFAULT_CHAT_FRAME.editBox:SetText(text)
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    if msg~='' then
        ChatFrame_OpenChat(msg, DEFAULT_CHAT_FRAME)
        DEFAULT_CHAT_FRAME.editbox:ClearFocus()
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