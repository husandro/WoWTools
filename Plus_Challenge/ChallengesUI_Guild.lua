

local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame














--[[

    if WoWTools_DataMixin.Player.husandro and #data==0 then
        data={
            name= WoWTools_DataMixin.Player.name_realm,
            classFilename= UnitClassBase('player'),
            keystoneLevel=11,
            mapChallengeModeID=247,
            isYou= true,
            members= {
                {
                    name= WoWTools_DataMixin.Player.name_realm,
                    classFileName= UnitClassBase('player'),
                },
            },
        }
    end

]]

local function Set_Text()
    local data= C_ChallengeMode.GetGuildLeaders()
    local text= WoWTools_DataMixin.onlyChinese and '公会挑战' or GUILD_CHALLENGE_LABEL


    if not data or not data.mapChallengeModeID then
        Frame.Text:SetText(text)
        Frame.Background:SetAtlas('ChallengeMode-guild-background')
        return
    end

   
    local name, _, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(data.mapChallengeModeID)
    if backgroundTexture and backgroundTexture>0 then
        Frame.Background:SetTexture(texture, false)
    else
        Frame.Background:SetAtlas('ChallengeMode-guild-background')
    end

    if name then
        text= text..'|n|n'
            ..(data.keystoneLevel and '< |cffffffff'..data.keystoneLevel..'|r >' or '')
            ..' '
            ..WoWTools_TextMixin:CN(name)
            ..format('|T%d:0|t', texture or 0)
    end

    if data.isYou then
        text= text..'|n|n'
            ..WoWTools_DataMixin.Player.col
            ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            ..WoWTools_DataMixin.Icon.Player
            ..'|r'
    elseif data.name then
        local col= select(5,WoWTools_UnitMixin:GetColor(nil, nil, data.classFilename))
        local icon= WoWTools_UnitMixin:GetClassIcon(data.classFilename)
        text= text..'|n|n'
            ..(col or '')
            ..data.name
            ..(icon or '')
            ..(col and '|r' or '')
    end

    for i=1, #data.members do
        local member= data.members[i]
        if member.name and member.name~=data.name then
            local col= select(5,WoWTools_UnitMixin:GetColor(nil, nil, member.classFileName))
            local icon= WoWTools_UnitMixin:GetClassIcon(member.classFileName)
            text= text..'|n'
                ..(col or '') 
                ..member.name 
                ..(icon or '')
                ..(col and '|r' or '')
        end
    end
    Frame.Text:SetText(text)    
end
    --[[
Field	Type	Description
name	string	
classFileName	string	
keystoneLevel	number	
mapChallengeModeID	number	
isYou	boolean	

members	structure ChallengeModeGuildAttemptMember[]	
ChallengeModeGuildAttemptMember
Field	Type	Description
name	string	
classFileName	string	]]





local function Init()
    if not IsInGuild() or Save().hideGuild then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:SetSize(1,1)
    Frame:Hide()

    Frame.Text= WoWTools_LabelMixin:Create(Frame, {
        color=true,
        justifyH= 'RIGHT',
    })
    Frame.Text:SetPoint('TOPRIGHT')

    WoWTools_TextureMixin:CreateBackground(Frame, {
        alpha=0.7,
        point=function(texture)
            texture:SetPoint('TOPLEFT', Frame.Text, 0, 4)
            texture:SetPoint('BOTTOMRIGHT', Frame.Text, 4, -6)
        end
    })

    function Frame:Settings()
        self:SetPoint('TOPRIGHT', ChallengesFrame, Save().guildX or -15, Save().guildY or -32)        
        self:SetScale(Save().guildScale or 1)
        self:SetShown(not Save().hideGuild and IsInGuild())
     end

     Frame:SetScript('OnShow', function(self)
        Set_Text()
        self:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
        self:RegisterEvent('GUILD_CHALLENGE_UPDATED')
        self:RegisterEvent('GUILD_CHALLENGE_COMPLETED')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.Text:SetText('')
    end)
    Frame:SetScript('OnEvent', function()
        Set_Text()
    end)

    Frame:Settings()

    Init=function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Guild()
    Init()
end