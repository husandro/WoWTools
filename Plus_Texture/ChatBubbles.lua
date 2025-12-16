--聊天泡泡
--ChatBubbles https://wago.io/yyX84OlOD
local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end

local BubblesFrame









local function Init()
    if BubblesFrame or Save().disabledChatBubble then
        if BubblesFrame then
            BubblesFrame:set_event()
            if not Save().disabledChatBubble then
                BubblesFrame:set_chat_bubbles(true)
            end
        end
        return
    end

    BubblesFrame= CreateFrame('Frame')

    function BubblesFrame:set_chat_bubbles(set)
        for _, buble in pairs(C_ChatBubbles.GetAllChatBubbles() or {}) do
            if not buble.setAlphaOK or set then
                local frame= buble:GetChildren()
                if frame then
                    local fontString = frame.String
                    local point, relativeTo, relativePoint, ofsx, ofsy = fontString:GetPoint(1)
                    local currentScale= buble:GetScale()
                    frame:SetScale(Save().chatBubbleSacal)
                    if point then
                        local scaleRatio = Save().chatBubbleSacal / currentScale
                        fontString:SetPoint(point, relativeTo, relativePoint, ofsx / scaleRatio, ofsy / scaleRatio)
                    end
                    local tab={frame:GetRegions()}
                    for _, region in pairs(tab) do
                        if region:IsObjectType('Texture') then-- .String
                            WoWTools_TextureMixin:SetAlphaColor(region, nil, nil, Save().chatBubbleAlpha)
                        end
                    end
                    buble.setAlphaOK= true
                end
            end
        end
    end

    function BubblesFrame:set_event()
        self:UnregisterAllEvents()
        if Save().disabledChatBubble then
            return
        end
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        if not IsInInstance() then
            local chatBubblesEvents={
                'CHAT_MSG_SAY',
                'CHAT_MSG_YELL',
                'CHAT_MSG_PARTY',
                'CHAT_MSG_PARTY_LEADER',
                'CHAT_MSG_RAID',
                'CHAT_MSG_RAID_LEADER',
                'CHAT_MSG_MONSTER_PARTY',
                'CHAT_MSG_MONSTER_SAY',
                'CHAT_MSG_MONSTER_YELL',
            }
            FrameUtil.RegisterFrameForEvents(BubblesFrame, chatBubblesEvents)
        end
    end

    BubblesFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_event()
        else
            self:set_chat_bubbles()
        end
    end)

    BubblesFrame:set_event()
end





function WoWTools_TextureMixin:Init_Chat_Bubbles()
    Init(self)
end