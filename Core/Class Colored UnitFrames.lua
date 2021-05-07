local frame = CreateFrame("FRAME")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("UNIT_FACTION")
frame:RegisterEvent("ADDON_LOADED")

local function Unit_CheckColor(unit)
    if( not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) ) then
        return {r = 0.5, g = 0.5, b = 0.5}
    else
        red, green ,blue, alpha  = UnitSelectionColor(unit)
        return {r = red, g = green, b = blue}
    end
end

local function Player_CheckColor(unit)
    return RAID_CLASS_COLORS[select(2, UnitClass(unit))]
end

local function tfFrameLoad(sel, event, ...)
    if UnitIsPlayer("target") then
        target_c = Player_CheckColor("target")
    elseif UnitExists("target") then
        target_c = Unit_CheckColor("target")
    end
    if UnitIsPlayer("focus") then
        focus_c = Player_CheckColor("focus")
    elseif UnitExists("focus") then
        focus_c = Unit_CheckColor("focus")
    end

    if UnitFrameType == 1 then
        if UnitExists("target") then
            TargetFrameNameBackground:SetVertexColor(target_c.r, target_c.g, target_c.b, 1)
            TargetFrameHealthBar:SetStatusBarColor(0, 1, 0)
        end
        if UnitExists("focus") then
            FocusFrameNameBackground:SetVertexColor(focus_c.r, focus_c.g, focus_c.b, 1)
            FocusFrameHealthBar:SetStatusBarColor(0, 1, 0)
        end
    elseif UnitFrameType == 2 then
        if UnitExists("target") then
            TargetFrameNameBackground:SetVertexColor(target_c.r, target_c.g, target_c.b, 0)
            TargetFrameHealthBar:SetStatusBarColor(target_c.r, target_c.g, target_c.b)
            TargetFrameHealthBar.lockColor = true
        end
        if UnitExists("focus") then
            FocusFrameNameBackground:SetVertexColor(focus_c.r, focus_c.g, focus_c.b, 0)
            FocusFrameHealthBar:SetStatusBarColor(focus_c.r, focus_c.g, focus_c.b)
            FocusFrameHealthBar.lockColor = true
        end
    elseif UnitFrameType == 3 then     
        if UnitExists("target") then
            target_c_bg = Unit_CheckColor("target")
            TargetFrameNameBackground:SetVertexColor(target_c_bg.r, target_c_bg.g, target_c_bg.b, 1)
            if UnitIsPlayer("target") then
                TargetFrameHealthBar:SetStatusBarColor(target_c.r, target_c.g, target_c.b)
                TargetFrameHealthBar.lockColor = true
            else
                TargetFrameHealthBar:SetStatusBarColor(0, 1, 0)
            end
        end
        if UnitExists("focus") then
            focus_c_bg = Unit_CheckColor("focus")
            FocusFrameNameBackground:SetVertexColor(focus_c_bg.r, focus_c_bg.g, focus_c_bg.b, 1)
            if UnitIsPlayer("focus") then
                FocusFrameHealthBar:SetStatusBarColor(focus_c.r, focus_c.g, focus_c.b)
                FocusFrameHealthBar.lockColor = true
            else
                FocusFrameHealthBar:SetStatusBarColor(0, 1, 0)
            end
        end
    end
end

local function playerFrameLoad()
    c=RAID_CLASS_COLORS[select(2,UnitClass("player"))]
    if not PlayerFrame.bg then
        c=RAID_CLASS_COLORS[select(2,UnitClass("player"))]
        bg=PlayerFrame:CreateTexture()
        bg:SetPoint("TOPLEFT",PlayerFrameBackground)
        bg:SetPoint("BOTTOMRIGHT",PlayerFrameBackground,0,22)
        bg:SetTexture(TargetFrameNameBackground:GetTexture())
        PlayerFrame.bg=true
    end
    if UnitFrameType == 1 then
        bg:SetVertexColor(c.r,c.g,c.b,1)
        PlayerFrameHealthBar:SetStatusBarColor(0, 1, 0)
    elseif UnitFrameType == 2 or UnitFrameType == 3 then
        bg:SetVertexColor(0,0,0,0)
        PlayerFrameHealthBar:SetStatusBarColor(c.r, c.g, c.b)
    end
    PlayerFrameHealthBar.lockColor = true
end

if PlayerFrame:IsShown() then
    playerFrameLoad()
end

local function eventHandler(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "Class Colored UnitFrames" then
        if UnitFrameType == nil then
            UnitFrameType = 1
        end
        playerFrameLoad()
    elseif event ~= "ADDON_LOADED" then
        tfFrameLoad()
    end
end

frame:SetScript("OnEvent", eventHandler)

for _, BarTextures in pairs({TargetFrameNameBackground, FocusFrameNameBackground}) do
    BarTextures:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
end

-- Removes Healing/Damage spam over player/pet frames --

PlayerHitIndicator:SetText(nil)
PlayerHitIndicator.SetText = function() end

PetHitIndicator:SetText(nil)
PetHitIndicator.SetText = function() end

--------------------------------------------------------

-- Capture comands --
local function CCUFCommands(msg, editbox)
    if msg == '1' then
        UnitFrameType = 1
        tfFrameLoad()
        playerFrameLoad()
    elseif msg == '2' then
        UnitFrameType = 2
        tfFrameLoad()
        playerFrameLoad()
    elseif msg == '3' then
        UnitFrameType = 3
        tfFrameLoad()
        playerFrameLoad()
    end
end

SLASH_CCUF1 = '/ccuf'
SlashCmdList["CCUF"] = CCUFCommands

--------------------