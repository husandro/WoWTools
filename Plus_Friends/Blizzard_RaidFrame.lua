--团队信息，副本信息

local function Init()
    WoWTools_DataMixin:Hook('RaidInfoFrame_InitButton', function(btn, elementData)
        if not btn:IsVisible() then
            return
        end
        local index = elementData.index;
        local text
        if elementData.isInstance then
            local _, _, _, _, locked, extended, _, _, _, _, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
            if numEncounters and encounterProgress then
                local num
                num= numEncounters- encounterProgress
                num= num<0 and 0 or num
                if not (extended or locked) then
                    text= '|cff9e9e9e'..num..'/'..numEncounters..'|r'
                elseif num==0 then
                    text= '|cnWARNING_FONT_COLOR:'..num..'/'..numEncounters..'|r'
                else
                    text= '|cnGREEN_FONT_COLOR:'..num..'|r/'..numEncounters
                end
                if extended or locked then
                    local t=''
                    for j=1,numEncounters do
                        local isKilled = select(3, GetSavedInstanceEncounterInfo(index,j))
                        t= t..(isKilled and '|A:common-icon-redx:0:0|a' or format('|A:%s:0:0|a', 'common-icon-checkmark'))
                    end
                    text= t..' '..text
                end
            end
        end
        if text and not btn.tipsLabel then
            btn.tipsLabel= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
            btn.tipsLabel:SetPoint('BOTTOMRIGHT', -52,1)
        end
        if btn.tipsLabel then
            btn.tipsLabel:SetText(text or '')
        end
    end)



    Init=function()end
end





function WoWTools_FriendsMixin:Blizzard_RaidFrame()
    Init()
end