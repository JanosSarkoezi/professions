-- ============================================================
-- 0. LOKALISIERUNG (Localization Setup)
-- ============================================================
local locale = GetLocale()

-- Standard-Übersetzungen für UI-Texte
local L = {
    ["Fortschritt"] = "Fortschritt: ",
    ["NaechsterRang"] = "Nächster Rang ab: ",
    ["MaterialienBesitz"] = "Materialien im Besitz:",
    ["KeineVorraete"] = "<Keine Vorräte>",
    ["MeineBerufe"] = "Meine Berufe",
    ["SpracheFilter"] = "Sprache",
    ["LadeItem"] = "Lade Item-Daten...",
}

if locale ~= "deDE" then
    L["Fortschritt"] = "Progress: "
    L["NaechsterRang"] = "Next rank at: "
    L["MaterialienBesitz"] = "Materials owned:"
    L["KeineVorraete"] = "<No materials>"
    L["MeineBerufe"] = "My Professions"
    L["SpracheFilter"] = "Language"
    L["LadeItem"] = "Loading item data..."
end

-- Interne Zuordnung von Client-Sprache auf deine Tabellen-Keys
-- Interne Zuordnung von Client-Sprache auf deine Tabellen-Keys und Zaubernamen
local professionMap = {}
if locale == "deDE" then
    professionMap = {
        ["Schneiderei"] = "Schneiderei", ["Verzauberung"] = "Verzauberung", 
        ["Juwelenschmiedekunst"] = "Juwelenschmiedekunst", ["Verteidigung"] = "Verteidigung",
        ["Alchemie"] = "Alchemie", ["Schmiedekunst"] = "Schmiedekunst", 
        ["Lederverarbeitung"] = "Lederverarbeitung", ["Ingenieurskunst"] = "Ingenieurskunst",
        ["Kräuterkunde"] = "Kräuterkunde", ["Bergbau"] = "Bergbau", 
        ["Kürschnerei"] = "Kürschnerei", ["Kochkunst"] = "Kochkunst", 
        ["Erste Hilfe"] = "Erste Hilfe", ["Angeln"] = "Angeln", 
        ["Holzfällen"] = "Holzfällen", ["Reiten"] = "Reiten"
    }
else
    professionMap = {
        ["Tailoring"] = "Schneiderei", ["Enchanting"] = "Verzauberung", 
        ["Jewelcrafting"] = "Juwelenschmiedekunst", ["Defense"] = "Verteidigung",
        ["Alchemy"] = "Alchemie", ["Blacksmithing"] = "Schmiedekunst", 
        ["Leatherworking"] = "Lederverarbeitung", ["Engineering"] = "Ingenieurskunst",
        ["Herbalism"] = "Kräuterkunde", ["Mining"] = "Bergbau", 
        ["Skinning"] = "Kürschnerei", ["Cooking"] = "Kochkunst", 
        ["First Aid"] = "Erste Hilfe", ["Fishing"] = "Angeln", 
        ["Woodcutting"] = "Holzfällen", ["Lumberjacking"] = "Holzfällen", 
        ["Riding"] = "Reiten"
    }
end

-- ============================================================
-- 1. DATENKONFIGURATION (ID-basiert & Extrem schlank)
-- ============================================================
local iconTable = {
    ["Schneiderei"] = "Interface\\Icons\\Trade_Tailoring",
    ["Verzauberung"] = "Interface\\Icons\\Trade_Engraving",
    ["Juwelenschmiedekunst"] = "Interface\\Icons\\Inv_jewelcrafting_gem_32",
    ["Verteidigung"] = "Interface\\Icons\\Inv_shield_06",
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

-- Hier speichern wir NUR NOCH IDs. Die Namen holt sich das Addon live aus WoW!
local resourceMap = {
    ["Holzfällen"] = {8210210, 8210211, 21886},
    ["Angeln"] = {
        -- Level 1-20 (Anfänger-Fische für Kochkunst)
        6289,  -- Roher Stoppellachs (Raw Longjaw Mud Snapper)
        6287,  -- Roher Stachelfisch (Raw Brilliant Smallfish)
        6325,  -- Roher Weisenfisch (Raw Sagefish - sehr beliebt für Mana-Reg!)

        -- Level 1-20 (Anfänger-Fische & Hauptstädte)
        6308,  -- Roher Stoppellachs (Raw Longjaw Mud Snapper - Korrigierte ID)
        6291,  -- Roher Stachelfisch (Raw Brilliant Smallfish - Korrigierte ID)
        13880, -- Sickerdorbe (Sickly Looking Fish - SW Angelquest-Item)

        -- Level 20-40 (Mittleres Level / Kochkunst & Alchemie)
        6311,  -- Roher Borstenbartwels (Raw Bristle Whisker Catfish)
        6821,  -- Rohe Mithrilforelle (Raw Mithril Head Trout)
        6358,  -- Öliges Schwarzmaul (Oily Blackmouth - extrem wichtig für Alchemie/Öle!)
        6359,  -- Feuerflossenmaul (Firefin Snapper - wichtig für Alchemie!)

        -- Level 40-60 (High-Level Buff-Food Fische)
        13754, -- Roher Nachtflosser (Raw Nightfin Snapper - Core Mana-Buff-Food)
        13756, -- Roher Sonnenschuppenlachs (Raw Sunscale Salmon)
        13759, -- Roher Glanzfisch (Raw Glossy Mightfish)
        13889, -- Roher Sommerlutjanus (Raw Summer Bass)
        13888, -- Roher Winterkalmar (Raw Winter Squid - Core Offensiv-Buff-Food)

        -- Endgame & Spezial-Fische (Sehr wertvoll)
        13931, -- Roher Steinschuppenkabeljau (Raw Stonescale Eel - extrem wichtig für Titanlegierungs-Tränke)
        13755, -- Roher Prachtbarsch (Raw Greater Sagefish)
        13758, -- Roher Großmaulbarsch (Raw Large Sagefish)

        -- Ascension / Rare Fänge (Falls mal im Inventar)
        8364,  -- Einarmiger Bandit (Rockhide Strongfish - seltener Fisch für Erfolge/Quests)
        13893, -- 22-Pfünder Wels (Seltener kosmetischer Fisch)

        -- WotLK / Ascension Endgame (High-End Buffs & Alchemie)
        43571, -- Pygmäenschiffshalter (Pygmy Suckerfish - Extrem wichtig für Alchemie!)
        34752, -- Roher Drachenflossendorsch (Raw Dragonfin Angelfish - Stärke/Agility Buff)
        43572, -- Roher Heringskönig (Raw Imperial Manta Ray - Zaubermacht Buff)
        41514, -- Tiefenseekarpfen (Glacial Salmon - Agility)

        -- Wichtige TBC Fische (Level 60-70)
        27435, -- Roher Zornbarsch (Raw Furious Crawdad - Bestes Tank-Food)
        27439, -- Roher Großflossenthunfisch (Raw Greater Sagefish - Mana-Reg)

        -- Vergessene Classic-Fische
        21151, -- Roher Stoppellachs (Raw Redgill - Level 40+ Kochen)
        13760, -- Roher Glanzfisch (Raw Mightfish)

        -- Seltene Funde / Mounts / Pets
        43652, -- Meeresschildkröten-Mount (Sea Turtle - Epischer Angel-Drop)
        34447  -- Riesenkanalratte (Giant Sewer Rat - Haustier aus Dalaran)
    },
    ["Kochkunst"] = {
        -- Gewürze & Zubehör (Wichtig, da man sie zum Kochen immer braucht)
        2678,  -- Mildes Gewürz (Mild Spices)
        3713,  -- Heißgewürze (Hot Spices)
        2672,  -- Saitenwurstling (Soothing Spices)
        8924,  -- Festtagsgewürze (Holiday Spices)
        12240, -- Epische Gewürze (Epic Spices)
        159,   -- Erfrischendes Quellwasser (Refreshing Spring Water)
        1708,  -- Süßrahmbutter (Sweet Nectar)

        -- Level 1-20 Fleisch & Fisch
        6889,  -- Kleines Ei (Small Egg)
        2679,  -- Rohes Eberfleisch (Raw Boar Meat)
        2681,  -- Erbeutetes Bärenfleisch (Chunk of Bear Meat)
        688,   -- Rohes Wolfsfleisch (Stringy Wolf Meat)
        2673,  -- Spinnenbein (Crispy Spider Leg)
        2683,  -- Krebsfleisch (Clam Meat)
        6289,  -- Roher Stoppellachs (Raw Longjaw Mud Snapper)
        6287,  -- Roher Stachelfisch (Raw Brilliant Smallfish)

        -- Level 20-40 Fleisch & Fisch
        769,   -- Brocken Eberfleisch (Chunk of Boar Meat)
        3712,  -- Schildkrötenfleisch (Turtle Meat)
        5469,  -- Zartes Wolfsfleisch (Tender Wolf Meat)
        12202, -- Zartes Bärenfleisch (Tender Bear Meat)
        4655,  -- Riesen-Muschelfleisch (Giant Clam Meat)
        6325,  -- Roher Weisenfisch (Raw Sagefish)
        6311,  -- Roher Borstenbartwels (Raw Bristle Whisker Catfish)
        6821,  -- Rohe Mithrilforelle (Raw Mithril Head Trout)

        -- Level 40-60 Fleisch (Zartes / Kodo / Endgame)
        12205, -- Weißes Löwenfleisch (White Kodo Meat)
        12208, -- Prachtvolles Eberfleisch (Large Bear Meat)
        12204, -- Fleisch eines dicken Bären (Thick Bear Meat)
        11930, -- Zartes Großmutantenfleisch (Tender Crocolisk Meat)
        12238, -- Riesiges Ei (Giant Egg)
        22521, -- Sandwurmfleisch (Sandworm Meat)

        -- Level 40-60 Fische (Buff-Foods für Endgame)
        13754, -- Roher Nachtflosser (Raw Nightfin Snapper - extrem wichtig für Mana-Reg!)
        13756, -- Roher Sonnenschuppenlachs (Raw Sunscale Salmon)
        13759, -- Roher Glanzfisch (Raw Glossy Mightfish)
        13889, -- Roher Sommerlutjanus (Raw Summer Bass)
        13888, -- Roher Winterkalmar (Raw Winter Squid - extrem wichtig für Caster/Melees!)
        13931  -- Roher Steinschuppenkabeljau (Raw Stonescale Eel)
    },
    ["Bergbau"] = {
        -- Kupfer / Level 1
        2770,  -- Kupfererz (Copper Ore)
        2840,  -- Kupferbarren (Copper Bar)
        2835,  -- Rauher Stein (Rough Stone)

        -- Zinn & Bronze / Level 50+
        2771,  -- Zinnerz (Tin Ore)
        2841,  -- Zinnbarren (Tin Bar)
        2842,  -- Bronzebarren (Bronze Bar)
        2836,  -- Grober Stein (Coarse Stone)

        -- Silber
        2775,  -- Silbererz (Silver Ore)
        2843,  -- Silberbarren (Silver Bar)

        -- Eisen & Stahl / Level 125+
        2772,  -- Eisenerz (Iron Ore)
        3859,  -- Eisenbarren (Iron Bar)
        3857,  -- Stahlbarren (Steel Bar)
        2838,  -- Schwerer Stein (Heavy Stone)

        -- Gold
        4470,  -- Golderz (Gold Ore)
        3575,  -- Goldbarren (Gold Bar)

        -- Mithril / Echtsilber / Level 175+
        3858,  -- Mithrilerz (Mithril Ore)
        3860,  -- Mithrilbarren (Mithril Bar)
        4478,  -- Echtsilbererz (Truesilver Ore)
        6037,  -- Echtsilberbarren (Truesilver Bar)
        7912,  -- Solider Stein (Solid Stone)

        -- Thorium / Level 250+
        10620, -- Thoriumerz (Thorium Ore)
        12359, -- Thoriumbarren (Thorium Bar)
        12360, -- Arkanitbarren (Arcanite Bar)
        11370, -- Dunkeleisenerz (Dark Iron Ore)
        11371, -- Dunkeleisenbarren (Dark Iron Bar)
        12365  -- Robuster Stein (Dense Stone)
    },
    ["Kräuterkunde"] = {
        765,   -- Silberblatt (Silverleaf)
        2447,  -- Friedensblume (Peacebloom)
        2449,  -- Erdwurzel (Earthroot)
        785,   -- Maguskönigskraut (Mageroyal)
        2450,  -- Wilddornrose (Briarthorn)
        785,   -- Beulengras (Bruiseweed)
        3355,  -- Blassblatt (Fadeleaf)
        3818,  -- Würgetanger (Stranglekelp)
        3821,  -- Golddorn (Goldthorn)
        3820,  -- Blassblatt / Grabmoos (Grave Moss)
        8831,  -- Lila Lotus (Purple Lotus)
        3824,  -- Sonnengras (Sungrass)
        8838,  -- Blindkraut (Blindweed)
        8845,  -- Geisterpilz (Ghost Mushroom)
        13463, -- Traumblatt (Dreamfoil)
        13464, -- Goldenes Sansam (Golden Sansam)
        13465, -- Bergsilberweisling (Mountain Silversage)
        13467, -- Eiskappe (Icecap)
        13468  -- Pestblüte (Plaguebloom)
    },
    ["Kürschnerei"] = {
        -- Leichtes Leder & Bälge (Level 1+)
        2934,  -- Lederfetzen (Ruined Leather Scraps)
        2318,  -- Leichtes Leder (Light Leather)
        2320,  -- Leichter Balg (Light Hide)
        4231,  -- Gegerbter leichter Balg (Cured Light Hide)

        -- Mittleres Leder & Bälge (Level 10+)
        2319,  -- Mittleres Leder (Medium Leather)
        2321,  -- Mittlerer Balg (Medium Hide)
        4233,  -- Gegerbter mittlerer Balg (Cured Medium Hide)

        -- Schweres Leder & Bälge (Level 25+)
        4234,  -- Schweres Leder (Heavy Leather)
        4232,  -- Schwerer Balg (Heavy Hide)
        4235,  -- Gegerbter schwerer Balg (Cured Heavy Hide)

        -- Dickes Leder & Bälge (Level 35+)
        8170,  -- Dickes Leder (Thick Leather)
        8154,  -- Dicker Balg (Thick Hide)
        8150,  -- Gegerbter dicker Balg (Cured Thick Hide)

        -- Unverwüstliches Leder & Bälge (Level 50+)
        8169,  -- Unverwüstliches Leder (Rugged Leather)
        8151,  -- Unverwüstlicher Balg (Rugged Hide)
        8153,  -- Gegerbter unverwüstlicher Balg (Cured Rugged Hide)

        -- Spezial-Leder (Classic-Endgame)
        4304,  -- Dicker Murlocbalg (Thick Murloc Hide)
        15417, -- Schuppen eines roten Drachen (Red Dragonscale)
        15419, -- Schuppen eines blauen Drachen (Blue Dragonscale)
        15407, -- Schuppen eines schwarzen Drachen (Black Dragonscale)
        15415, -- Schuppen eines grünen Drachen (Green Dragonscale)
        8167   -- Schimmerschuppe (Deviate Scale)
    },
    ["Erste Hilfe"] = {
        -- Leinenstoff (Linen)
        2589,  -- Leinenstoff (Linen Cloth)
        1251,  -- Leinenverband (Linen Bandage)
        2581,  -- Schwerer Leinenverband (Heavy Linen Bandage)

        -- Wollstoff (Wool)
        2592,  -- Wollstoff (Wool Cloth)
        3530,  -- Wollverband (Wool Bandage)
        3531,  -- Schwerer Wollverband (Heavy Wool Bandage)

        -- Seidenstoff (Silk)
        4306,  -- Seidenstoff (Silk Cloth)
        6450,  -- Seidenverband (Silk Bandage)
        6451,  -- Schwerer Seidenverband (Heavy Silk Bandage)

        -- Magiestoff (Mageweave)
        4438,  -- Magiestoff (Mageweave Cloth)
        8544,  -- Magiestoffverband (Mageweave Bandage)
        8545,  -- Schwerer Magiestoffverband (Heavy Mageweave Bandage)

        -- Runenstoff (Runecloth)
        14256, -- Runenstoff (Runecloth)
        14529, -- Runenverband (Runecloth Bandage)
        14530, -- Schwerer Runenverband (Heavy Runecloth Bandage)

        -- Gegengifte (Antidotes - optional, aber nützlich für Erste Hilfe)
        1159,  -- Einfaches Gegengift (Anti-Venom)
        1114,  -- Starkes Gegengift (Strong Anti-Venom)
        19440  -- Mächtiges Gegengift (Powerful Anti-Venom)
    },
    ["Schneiderei"] = {
        -- Leinenstoff-Bereich
        2589,  -- Leinenstoff (Linen Cloth)
        2996,  -- Leinenstoffballen (Bolt of Linen Cloth)
        2320,  -- Grober Faden (Coarse Thread)

        -- Wollstoff-Bereich
        2592,  -- Wollstoff (Wool Cloth)
        2997,  -- Wollstoffballen (Bolt of Woolen Cloth)
        2321,  -- Feiner Faden (Fine Thread)
        2324,  -- Bleichmittel (Bleach)
        2604,  -- Roter Farbstoff (Red Dye)

        -- Seidenstoff-Bereich
        4360,  -- Seidenstoff (Silk Cloth)
        4305,  -- Seidenstoffballen (Bolt of Silk Cloth)
        4337,  -- Seidenfaden (Silken Thread)
        4304,  -- Dicker Murlocbalg (wird für manche Schneider-Rezepte gebraucht!)
        2605,  -- Grüner Farbstoff (Green Dye)
        4341,  -- Blauer Farbstoff (Blue Dye)

        -- Magiestoff-Bereich
        4438,  -- Magiestoff (Mageweave Cloth)
        4339,  -- Magiestoffballen (Bolt of Mageweave)
        4338,  -- Magieerfüllter Faden (Magical Thread)
        4342,  -- Schwarzer Farbstoff (Black Dye)

        -- Runenstoff-Bereich
        14256, -- Runenstoff (Runecloth)
        14048, -- Runenstoffballen (Bolt of Runecloth)
        14341, -- Runenfaden (Rune Thread)

        -- Endgame-Stoffe (Classic Level 60)
        14342, -- Mooncloth (Mondstoff)
        11370  -- Teufelsstoff (Felcloth)
    },
    ["Verzauberung"] = {
        -- STAUB (Dust)
        10940, -- Seltsamer Staub (Strange Dust)
        11137, -- Seelenstaub (Soul Dust)
        11176, -- Visionenstaub (Vision Dust)
        16204, -- Illusionenstaub (Illusion Dust)

        -- ESSENZEN (Essences)
        -- Magie (Magic)
        10938, -- Geringe Magieessenz (Lesser Magic Essence)
        10939, -- Große Magieessenz (Greater Magic Essence)
        -- Astral
        10998, -- Geringe Astraloessenz (Lesser Astral Essence)
        11082, -- Große Astraloessenz (Greater Astral Essence)
        -- Mystiker (Mystic)
        11135, -- Geringe Mystikeressenz (Lesser Mystic Essence)
        11139, -- Große Mystikeressenz (Greater Mystic Essence)
        -- Nether
        11175, -- Geringe Netheressenz (Lesser Nether Essence)
        11178, -- Große Netheressenz (Greater Nether Essence)
        -- Ewige (Eternal)
        16203, -- Geringe Ewige Essenz (Lesser Eternal Essence)
        16202, -- Große Ewige Essenz (Greater Eternal Essence)

        -- SPLITTER & KRISTALLE (Shards & Crystals)
        10978, -- Kleine glänzende Splitter (Small Glimmering Shard)
        11084, -- Große glänzende Splitter (Large Glimmering Shard)
        11134, -- Kleine leuchtende Splitter (Small Glowing Shard)
        11140, -- Große leuchtende Splitter (Large Glowing Shard)
        11174, -- Kleine strahlende Splitter (Small Radiant Shard)
        11177, -- Große strahlende Splitter (Large Radiant Shard)
        14343, -- Kleine glänzende Splitter (Small Brilliant Shard)
        14344, -- Große glänzende Splitter (Large Brilliant Shard)
        20725  -- Nexus-Kristall (Nexus Crystal - Classic Endgame)
    },
    ["Schmiedekunst"] = {
        -- Bronze & Kupfer (Anfang)
        2840,  -- Kupferbarren (Copper Bar)
        2841,  -- Zinnbarren (Tin Bar)
        2842,  -- Bronzebarren (Bronze Bar)
        2835,  -- Rauher Stein (Rough Stone)
        2880,  -- Rauher Schleifstein (Rough Grinding Stone)

        -- Silber, Eisen & Stahl
        2843,  -- Silberbarren (Silver Bar)
        3859,  -- Eisenbarren (Iron Bar)
        3857,  -- Stahlbarren (Steel Bar)
        2836,  -- Grober Stein (Coarse Stone)
        2881,  -- Grober Schleifstein (Coarse Grinding Stone)
        2838,  -- Schwerer Stein (Heavy Stone)
        3470,  -- Schwerer Schleifstein (Heavy Grinding Stone)

        -- Gold & Mithril
        3575,  -- Goldbarren (Gold Bar)
        3860,  -- Mithrilbarren (Mithril Bar)
        6037,  -- Echtsilberbarren (Truesilver Bar)
        7912,  -- Solider Stein (Solid Stone)
        7914,  -- Solider Schleifstein (Solid Grinding Stone)

        -- Thorium & Endgame
        12359, -- Thoriumbarren (Thorium Bar)
        12360, -- Arkanitbarren (Arcanite Bar)
        12365, -- Robuster Stein (Dense Stone)
        12644, -- Robuster Schleifstein (Dense Grinding Stone)
        11371, -- Dunkeleisenbarren (Dark Iron Bar)
        18551, -- Elementiumbarren (Elementium Bar)

        -- Spezielle Schmiede-Zusätze
        3864,  -- Citrin (Citrine - wird für manche Platten-Rezepte gebraucht)
        7910,  -- Sternrubin (Star Ruby - wird für Dunkeleisen/Mithril-Rezepte gebraucht)
        14344  -- Großer glänzender Splitter (Large Brilliant Shard - für Endgame-Waffen)
    },
    ["Alchemie"] = {
        -- Phiolen & Zubehör
        3371,  -- Kristallphiole (Crystal Vial)
        3372,  -- Leere Phiole (Empty Vial)
        18256, -- Imprägnierte Phiole (Imbued Vial)
        4625,  -- Immerferne Medizin (Everlasting Medicine)

        -- Level 1-20 Kräuter
        765,   -- Silberblatt (Silverleaf)
        2447,  -- Friedensblume (Peacebloom)
        2449,  -- Erdwurzel (Earthroot)
        785,   -- Maguskönigskraut (Mageroyal)
        2450,  -- Wilddornrose (Briarthorn)
        785,   -- Beulengras (Bruiseweed)

        -- Level 20-40 Kräuter
        3355,  -- Blassblatt (Fadeleaf)
        3818,  -- Würgetanger (Stranglekelp)
        3821,  -- Golddorn (Goldthorn)
        3820,  -- Grabmoos (Grave Moss)
        8831,  -- Lila Lotus (Purple Lotus)
        3824,  -- Sonnengras (Sungrass)

        -- Level 40-60 Kräuter
        8838,  -- Blindkraut (Blindweed)
        8845,  -- Geisterpilz (Ghost Mushroom)
        13463, -- Traumblatt (Dreamfoil)
        13464, -- Goldenes Sansam (Golden Sansam)
        13465, -- Bergsilberweisling (Mountain Silversage)
        13467, -- Eiskappe (Icecap)
        13468, -- Pestblüte (Plaguebloom)

        -- Spezielle Alchemie-Materialien (Transmutationen)
        12958, -- Arkanitkristall (Arcane Crystal - extrem wichtig für Transmutationen!)
        12360, -- Arkanitbarren (Arcanite Bar)
        7067,  -- Elementarfeuer (Elemental Fire)
        7068,  -- Elementarwasser (Elemental Water)
        7070,  -- Elementarerde (Elemental Earth)
        7069   -- Elementarluft (Elemental Air)
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
-- 3. TOOLTIP STRATEGIES (Strategy Pattern mit dynamischer API-Abfrage)
-- ============================================================
local TooltipStrategies = {}

function TooltipStrategies:Default(bar)
    local prozent = math.floor((bar.rank / bar.maxRank) * 100)
    GameTooltip:AddLine(L["Fortschritt"] .. prozent .. "%", 0, 1, 0)
    if bar.maxRank < 450 then
        GameTooltip:AddLine(L["NaechsterRang"] .. bar.maxRank, 0.5, 0.5, 0.5)
    end
end

function TooltipStrategies:Resources(bar)
    self:Default(bar)
    
    local internalKey = professionMap[bar.name]
    local mats = resourceMap[internalKey]
    
    if mats then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["MaterialienBesitz"], 1, 0.8, 0)
        local hatEtwas = false
        
        for _, itemID in ipairs(mats) do
            local anz = GetItemCountByID(itemID)
            if anz > 0 then
                -- DYNAMISCHE ABFRAGE: Holt den Namen direkt aus WoW (vollautomatisch lokalisiert!)
                local itemName = GetItemInfo(itemID) or L["LadeItem"]
                
                GameTooltip:AddDoubleLine(itemName, anz, 1, 1, 1, 1, 1, 1)
                hatEtwas = true
            end
        end
        if not hatEtwas then GameTooltip:AddLine(L["KeineVorraete"], 0.5, 0.5, 0.5) end
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

    -- Wenn man auf den Balken klickt, öffnet sich das Berufsfenster!
    -- f:SetScript("OnMouseDown", function(self, button)
    --     if button == "LeftButton" then
    --         -- CastSpellByName benötigt den exakten Namen des Berufs in der Client-Sprache
    --         CastSpellByName(obj.name)
    --     end
    -- end)

    obj.frame = f
    return obj
end

function SkillBar:Update(name, rank, maxRank)
    self.name, self.rank, self.maxRank = name, rank, maxRank
    self.frame:SetMinMaxValues(0, maxRank)
    self.frame:SetValue(rank)
    self.frame.text:SetText(name .. " " .. rank .. "/" .. maxRank)
    
    local internalKey = professionMap[name] or name
    self.frame.icon:SetTexture(iconTable[internalKey] or "Interface\\Icons\\Inv_Misc_QuestionMark")
    self.frame:Show()
end

function SkillBar:ShowTooltip()
    GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.name, 1, 1, 1)
    
    local internalKey = professionMap[self.name] or self.name
    if resourceMap[internalKey] then
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
    
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText(L["MeineBerufe"])
    
    app.mainFrame = f
    return app
end

function BerufeApp:Refresh()
    for _, b in ipairs(self.bars) do b.frame:Hide() end
    local count = 0
    for i = 1, GetNumSkillLines() do
        local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
        if not isHeader and maxRank > 1 and not name:find(L["SpracheFilter"]) then
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
SLASH_BERUFE2 = "/professions"
SlashCmdList["BERUFE"] = function()
    if MyAddon.mainFrame:IsShown() then MyAddon.mainFrame:Hide()
    else MyAddon:Refresh(); MyAddon.mainFrame:Show() end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:SetScript("OnEvent", function() if MyAddon.mainFrame:IsShown() then MyAddon:Refresh() end end)

-- ============================================================
-- ID-TIP: ZEIGT ITEM-IDS IM STANDARD-TOOLTIP AN
-- ============================================================
local function OnTooltipSetItem(self)
    local _, itemLink = self:GetItem()
    if itemLink then
        local _, _, itemID = string.find(itemLink, "item:(%d+)")
        if itemID then
            self:AddDoubleLine("|cff00ff00Item ID:|r", "|cff00ccff" .. itemID .. "|r")
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
