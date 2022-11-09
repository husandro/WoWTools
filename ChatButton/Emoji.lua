local id, e = ...
local addName= 'Emoji'
local Save={disabled= not e.Player.zh, }
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local File={
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Angel',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Angry',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Biglaugh',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Clap',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Cool',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Cry',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Cutie',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Despise',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Dreamsmile',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Embarrass',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Evil',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Excited',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Faint',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Fight',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Flu',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Freeze',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Frown',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Greet',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Grimace',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Growl',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Happy',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Heart',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Horror',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Ill',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Innocent',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Kongfu',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Love',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Mail',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Makeup',    
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Meditate',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Miserable',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Okay',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Pretty',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Puke',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Shake',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Shout',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Shuuuu',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Shy',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Sleep',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Smile',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Suprise',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Surrender',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Sweat',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Tear',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Tears',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Think',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Titter',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Ugly',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Victory',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Volunteer',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Wronged',
    'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\Mario',      
}

--####
--初始
--####
local function Init()
    panel.texture:SetTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\greet')
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        local sel2=CreateFrame("CheckButton", nil, WoWToolsChatButtonFrame.sel, "InterfaceOptionsCheckButtonTemplate")
        sel2.Text:SetText('emoji')
        sel2:SetPoint('LEFT', WoWToolsChatButtonFrame.sel.Text, 'RIGHT')
        sel2:SetChecked(not Save.disabled)
        sel2:SetScript('OnClick', function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), REQUIRES_RELOAD)
        end)

        if WoWToolsChatButtonFrame.disabled or Save.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)