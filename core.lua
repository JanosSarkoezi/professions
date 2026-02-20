-- ============================================================
-- 1. DATENKONFIGURATION (Data Driven)
-- ============================================================
local iconTable = {
    ["Schneiderei"] = "Interface\\Icons\\Trade_Tailoring",
    ["Verzauberung"] = "Interface\\Icons\\Trade_Engraving",
    ["Alchemie"] = "Interface\\Icons\\Trade_Alchemy",
    ["Schmiedekunst"] = "Interface\\Icons\\Trade_Blacksmithing",
    ["Lederverarbeitung"] = "Interface\\Icons\\Trade_Leatherworking",
    ["Ingenieurskunst"] = "Interface\\Icons\\Trade_Engineering",
    ["Kräuterkunde"] = "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
    ["Bergbau"] = "Interface\\Icons\\Trade_Mining",
    ["Kürschnerei"] = "Interface\\Icons\\Inv_Misc_Pelt_Wolf_01",
    ["Kochkunst"] = "Interface\\Icons\\Inv_Misc_Food_15",
    ["Erste Hilfe"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
    ["Angeln"] = "Interface\\Icons\\Spell_Arcane_StudentOfMagic",
    ["Holzfällen"] = "Interface\\Icons\\Inv_Axe_02",
    ["Reiten"] = "Interface\\Icons\\Spell_Nature_Swiftness",
}

-- Map für Ressourcen (ID-basiert für maximale Präzision)
-- Format: [BerufName] = { {id = ItemID, label = "AnzeigeName"}, ... }
local resourceMap = {
    ["Holzfällen"] = {
        {id = 8210210, label = "Green Wood"}, 
        {id = 8210211, label = "Soft Wood"},
        {id = 21886,   label = "Tannenholz"},
    },
    ["Bergbau"] = {
        {id = 2770, label = "Kupfererz"},
        {id = 2771, label = "Zinnerz"},
        {id = 2772, label = "Eisenerz"},
        {id = 2775, label = "Silbererz"},
    },
    ["Erste Hilfe"] = {
        {id = 2589, label = "Leinenstoff"},
        {id = 2592, label = "Wollstoff"},
        {id = 4360, label = "Seidenstoff"},
        {id = 4438, label = "Magiestoff"},
    },
    ["Kürschnerei"] = {
        {id = 2934, label = "Lederfetzen"},
        {id = 2318, label = "Leichtes Leder"},
        {id = 2319, label = "Mittleres Leder"},
    },
    ["Kräuterkunde"] = {
        {id = 765,  label = "Silberblatt"},
        {id = 2447, label = "Friedensblume"},
        {id = 2449, label = "Erdwurzel"},
    },
}

-- ============================================================
-- 2. UTILS & HELFER
-- ============================================================
local function GetItemCountByID(targetID)
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local _, _, itemID = string.find(itemLink, "item:(%d+)")
                if tonumber(itemID) == targetID then
                    local _, stackCount = GetContainerItemInfo(bag, slot)
                    count = count + (stackCount or 0)
                end
            end
        end
    end
    return count
end

-- ============================================================
-- 3. TOOLTIP STRATEGIES (Strategy Pattern)
-- ============================================================
local TooltipStrategies = {}

function TooltipStrategies:Default(bar)
    local prozent = math.floor((bar.rank / bar.maxRank) * 100)
    GameTooltip:AddLine("Fortschritt: " .. prozent .. "%", 0, 1, 0)
    if bar.maxRank < 450 then
        GameTooltip:AddLine("Nächster Rang ab: " .. bar.maxRank, 0.5, 0.5, 0.5)
    end
end

function TooltipStrategies:Resources(bar)
    self:Default(bar) -- Erst Standard-Infos anzeigen
    
    local mats = resourceMap[bar.name]
    if mats then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Materialien im Besitz:", 1, 0.8, 0)
        local hatEtwas = false
        for _, itemData in ipairs(mats) do
            local anz = GetItemCountByID(itemData.id)
            if anz > 0 then
                GameTooltip:AddDoubleLine(itemData.label, anz, 1, 1, 1, 1, 1, 1)
                hatEtwas = true
            end
        end
        if not hatEtwas then GameTooltip:AddLine("<Keine Vorräte>", 0.5, 0.5, 0.5) end
    end
end

-- ============================================================
-- 4. KLASSE: SkillBar
-- ============================================================
SkillBar = {}
SkillBar.__index = SkillBar

function SkillBar:Create(parent)
    local obj = setmetatable({}, SkillBar)
    local f = CreateFrame("StatusBar", nil, parent)
    f:SetSize(170, 16)
    f:EnableMouse(true)
    f:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    f:SetStatusBarColor(0.2, 0.7, 0.2)
    
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetTexture(0, 0, 0, 0.5)

    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetSize(22, 22)
    f.icon:SetPoint("RIGHT", f, "LEFT", -10, 0)

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.text:SetPoint("CENTER", 0, 0)

    f:SetScript("OnEnter", function() obj:ShowTooltip() end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    obj.frame = f
    return obj
end

function SkillBar:Update(name, rank, maxRank)
    self.name, self.rank, self.maxRank = name, rank, maxRank
    self.frame:SetMinMaxValues(0, maxRank)
    self.frame:SetValue(rank)
    self.frame.text:SetText(name .. " " .. rank .. "/" .. maxRank)
    self.frame.icon:SetTexture(iconTable[name] or "Interface\\Icons\\Inv_Misc_QuestionMark")
    self.frame:Show()
end

function SkillBar:ShowTooltip()
    GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.name, 1, 1, 1)
    
    -- Strategie wählen: Falls Ressourcen-Map existiert, nutze Resource-Strategy
    if resourceMap[self.name] then
        TooltipStrategies:Resources(self)
    else
        TooltipStrategies:Default(self)
    end
    
    GameTooltip:Show()
end

-- ============================================================
-- 5. KLASSE: BerufeApp
-- ============================================================
BerufeApp = {}
BerufeApp.__index = BerufeApp

function BerufeApp:New()
    local app = setmetatable({}, BerufeApp)
    app.bars = {}
    
    local f = CreateFrame("Frame", "BerufeAnzeigeFrame", UIParent)
    f:SetSize(250, 60)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16, insets = {left=5, right=5, top=5, bottom=5}
    })
    f:Hide()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- tinsert(UISpecialFrames, "BerufeAnzeigeFrame")
    
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Meine Berufe")
    
    app.mainFrame = f
    return app
end

function BerufeApp:Refresh()
    for _, b in ipairs(self.bars) do b.frame:Hide() end
    local count = 0
    for i = 1, GetNumSkillLines() do
        local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
        if not isHeader and maxRank > 1 and not name:find("Sprache") then
            count = count + 1
            if not self.bars[count] then self.bars[count] = SkillBar:Create(self.mainFrame) end
            self.bars[count]:Update(name, rank, maxRank)
            self.bars[count].frame:SetPoint("TOPLEFT", 45, -15 - (count * 26))
        end
    end
    self.mainFrame:SetHeight(40 + (count * 26) + 10)
end

-- ============================================================
-- 6. INITIALISIERUNG & ADMIN
-- ============================================================
local MyAddon = BerufeApp:New()

SLASH_BERUFE1 = "/berufe"
SlashCmdList["BERUFE"] = function()
    if MyAddon.mainFrame:IsShown() then MyAddon.mainFrame:Hide() 
    else MyAddon:Refresh(); MyAddon.mainFrame:Show() end
end

-- Echtzeit-Update bei Skill-Up
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:SetScript("OnEvent", function() if MyAddon.mainFrame:IsShown() then MyAddon:Refresh() end end)

-- ============================================================
-- ID-TIP: ZEIGT ITEM-IDS IM STANDARD-TOOLTIP AN
-- ============================================================

-- Wir nutzen einen Hook, um den Standard-Tooltip zu erweitern
local function OnTooltipSetItem(self)
    -- Hole den Link des Items, das gerade im Tooltip ist
    local _, itemLink = self:GetItem()
    if itemLink then
        -- Extrahiere die ID aus dem Link (item:ID:...)
        local _, _, itemID = string.find(itemLink, "item:(%d+)")
        if itemID then
            -- Füge eine neue Zeile mit der ID in Cyan hinzu
            self:AddDoubleLine("|cff00ff00Item ID:|r", "|cff00ccff" .. itemID .. "|r")
        end
    end
end

-- Registriere die Funktion für alle Item-Tooltips im Spiel
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem) -- Für Links im Chat
