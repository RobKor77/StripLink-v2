-- @noindex
-- ================================================================================
-- StripLink Connector v2
-- Developer: Wormhole Labs
-- Version: 2.0.2
-- License & Copyright Information (Freeware):
-- StripLink is provided as freeware. You are fully permitted to use and 
-- modify this software for your personal workflow. However, it is strictly 
-- prohibited to sell, commercially repackage, or redistribute for profit 
-- this original version or any of its modified derivatives
-- ================================================================================
--  GMEM MEMORY MAP
-- ================================================================================
--  PROJECT_BASE = 3000000 + (ProjectIndex * 1000000)
--  gmem[100000] = PROJECT_BASE (Omogoča JSFX-u, da najde pravi projekt)
-- 
--  1. GLOBALS & COMMANDS (Offset from PROJECT_BASE)
-- --------------------------------------------------------------------------------
--  + 0    : Trigger števec (sproži Lua akcijo)
--  + 4    : Aktivni Slot ID (Kateri vtičnik pošilja ukaz)
--  + 5    : ID gumba, slota ali merilnika za ukaz
--  + 6    : JSFX p (Identifikator instance za placement)
--  + 7    : Command ID (Ukazi od 1 do 31)
--  + 8    : Active Slot (Trenutno izbrana steza in njen StripLink)
--  + 10   : Selected Track Index (Za proženje selekcije z miško)
--  + 11   : Track Selection Trigger števec
--  + 12   : Modifiers pri selekciji (npr. 5 za CTRL)
--  + 200  : Globalni Zavihek / TAB (0=OVR, 1=EQ, 2=DYN, 3=FX)
--  + 201  : Global TAB Trigger števec
--  + 202  : Global Meter Mode (0=Samo izbrani, 1=Vsi)
--  + 203  : Orodna namiga / Tooltips (1=Off, 2=On)
--  + 204  : Max GR dB (Razpon za merilnike)
--  + 205  : Global Font Size (Velikost pisave)
--  + 206  : ReaImGui Menu Status (0=Zaprto, 1=Odprto - ustavi miško v JSFX)
--  + 207  :*Not in use
--  + 208  : VU Meter Stil (0=Klasika, 1=Slim, 2=Skrito)
--  + 209  : Peak LED Threshold (Opozorilo za clipping)
--  + 210  : Global Mouse Standard Speed (0.5 do 2.0)
--  + 211  : Global Mouse Fine Speed (0.05 do 0.25)
-- 
--  2. LOKALNE SPREMENLJIVKE VTIČNIKA / SLOTA (base = PROJECT_BASE + Slot * 500)
-- --------------------------------------------------------------------------------
--  base + 1          : Active Lock (ID gumba, ki ga trenutno vlečemo z miško)
--  base + 3          : UI Sequence Counter (Sproži osvežitev JSFX GUI-ja)
--  base + 9          : Track Selection Overlay Flag (1=Izbrano, 0=Ni)
--  base + 11 do 75   : Vrednosti gumbov (Normalized 0.0 - 1.0, za gumb 0-64)
--  base + 78         : Auto Gain Power (0=Off, 1=On)
--  base + 79         : Auto Gain Lock/Freeze (0=Learn, 1=Frozen)
--  base + 80 do 144  : Vrednosti za prikaz (Dekodirane Base50 številke)
--  base + 150 do 214 : Statusi gumbov (Enota*1000 + Povezanost*100 + Barva)
--  base + 220 do 284 : Imena gumbov (Zakodiran Base50 Part 1)
--  base + 290        : Local Zavihek / TAB (0=OVR, 1=EQ, 2=DYN, 3=FX)
-- 
--  [Nazaj združljivost za Statične Vtičnike (UC1) - do 17 elementov]
--  base + 300 do 317 : OVR Button Assign (Kateri gumb je dodeljen na slot 1-17)
-- 
--  [Aggregator & Metering]
--  base + 320 / 321  : Meter 1 (DYN 1) Vrednost / Tekst
--  base + 322 / 323  : Meter 2 (DYN 2) Vrednost / Tekst
--  base + 324 / 325  : Meter 3 (Pre Out) Peak / RMS
--  base + 326 / 327  : All-Time Max GR (DYN 1 in DYN 2)
--  base + 328 / 329  : Engine Mode (1=Comp, 2=Gate, 3=Exp) (DYN 1 / DYN 2)
--  base + 330 / 331  : Native GR iz Lue (DYN 1 in DYN 2)
--  base + 332 / 333  : PDC Delay iz Lue (DYN 1 in DYN 2)
--  base + 334 / 335  : Meter 4 (Chain Out) Peak / RMS
--  base + 336        : VU Meter Source (0=PreIn, 1=PreOut, 2=ChainOut)
--  base + 337        : Auto Gain Speed Factor
--  base + 338        : Auto Gain Applied Gain (Aggregator pošilja Lui)
--  base + 339        : Auto Gain Restore Target (Lua piše Aggregatorju)
--  base + 340 / 341  : FX ID vtičnika (Za Gate Linked kompenzacijo, M1 in M2)
-- 
--  342 do 359 : OVR Meter Assign (Dodeljen merilnik za slot 1-17)
--  [Grupe in Nastavitve Modula]
--  base + 360 do 424 : Vrednost grupe za posamezen gumb (0=None, 1=A, 2=B...)
--  base + 426        : Instance Panel Height (Višina instance v slikovnih pikah)
--  base + 427        : Zahteva za osvežitev Layout Builderja (Lua proži JSFX)
--  base + 428        : Layout Builder Mode (0=Izklopljeno, 1=Vklopljeno)
--  base + 429        : Layout Builder Grid Snap Size (Velikost mreže)
-- 
--  [Sistemska stikala]
--  base + 490        : OVR Mailbox Trigger (Lua je posodobil OVR)
--  base + 491        : OVR Mailbox Slot ID
--  base + 492        : OVR Mailbox Button ID
--  base + 493        : OVR Mailbox Meter/Type Packed
--  base + 496        : Force Layout Push (Pove JSFX-u, da obdela nabiralnik)
--  base + 497        : Instance GUID Hash (Preverjanje, če se je premaknil vtičnik)
--  base + 498        : @serialize Status (1=Naloženo, 2=Prazen)
--  base + 499        : Trigger Save Structure (Zapiši RAM nazaj v Lua ExtState)
-- 
--  3. OUT-OF-BAND MEMORY (Ločeno od 500-naslovnega bloka zaradi prostora)
-- --------------------------------------------------------------------------------
--  p_base + 50000 + (Slot * 200) + i      : OVR Button Assign (Dinamični Moduli)
--  p_base + 50000 + (Slot * 200) + 64 + i : OVR Meter Assign (Dinamični Moduli)
--  
--  p_base + 60000 + (Slot * 100) + i      : STEPS CACHE (Koraki za Selectors/Knobe)
-- 
--  4. KOMUNIKACIJA IN LAYOUT BUFFER (Za Layout Builder in shranjevanje)
-- --------------------------------------------------------------------------------
--  p_base + 150000 + (Slot * 2000) : DNA String Array (Za shranjevanje v template)
--  p_base + 200000 + (Slot * 3000) : MAILBOX (Smer: Lua -> JSFX Layout posodobitev)
--  p_base + 500000 + (Slot * 3000) : OUTBOX (Smer: JSFX -> Lua Layout izvoz)
-- ================================================================================


local NS = "striplink_v2.0"

reaper.gmem_attach(NS)




local last_reg_clear = 0

local function GetProjectIndex()
 local cur = reaper.EnumProjects(-1) 
    local i = 0
    while true do
        local p = reaper.EnumProjects(i)
        if not p then return 0 end
        if p == cur then return i end
        i = i + 1
    end
end

-- ============================================================================
-- SAFE SLOT RESOLVER (Ignores saved FX Chain states)
-- ============================================================================
local function GetFXSlot(track)
    if not track or not reaper.ValidatePtr(track, "MediaTrack*") then return 0 end
    return math.floor(reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER"))
end

PROJECT_BASE = 0

last_sent_slot = 0
last_sent_id = 0
local last_context = -1
local last_gmem_values = {}
local expected_vst_values = {}
local mapping_cache = {}
local color_cache = {}
local group_cache = {}
local unit_cache = {}
local pending_os_tasks = {}

local function get_unit_id(name)
    if not name or name == "" then return 0 end
    local n = name:lower()
    -- 1 = Hz, 2 = dB, 3 = ms, 4 = %, 5 = :1
    if n:find("lcf") or n:find("hcf") or n:find("freq") or n:find("low") or n:find("hip") or n:find("hz") then return 1
    elseif n:find("thr") or n:find("gain") or n:find("vol") or n:find("inp") or n:find("in") or n:find("cei") or n:find("out") or n:find("knee") or n:find("db") then return 2
    elseif n:find("att") or n:find("rel") or n:find("pre") or n:find("ms") then return 3
    elseif n:find("wet") or n:find("mix") or n:find("%%") then return 4
    elseif n:find("rat") or n:find(":1") then return 5
    else return 0 end
end

local function GetSectionByParamID(btn_idx)
    if btn_idx >= 0 and btn_idx <= 19 then return "EQ"
    elseif btn_idx >= 20 and btn_idx <= 28 then return "DYN1"
    elseif btn_idx >= 29 and btn_idx <= 37 then return "DYN2"
    elseif btn_idx >= 38 and btn_idx <= 43 then return "PRE"
    elseif btn_idx >= 44 and btn_idx <= 55 then return "POST"
    end
    return nil
end

local function GetElementType(btn_idx, jsfx_name, slot)
    -- 1. Za dinamične Module vedno verjamemo postaviti v RAM-u (user_layouts)
    local is_module = jsfx_name:lower():find("module") ~= nil
    if is_module and user_layouts[slot] then
        for _, el in ipairs(user_layouts[slot]) do
            if el[5] == btn_idx and el[12] ~= 0 then 
                return el[2] -- Vrne natančen tip (1, 2, 3, 7...)
            end
        end
        return 1 -- Fallback na Knob
    end
    
    -- 2. Logika za statične vtičnike
    local is_uc1 = jsfx_name:lower():find("uc1") ~= nil
    
    if is_uc1 then
        -- Pravila za UC1
        if (btn_idx >= 13 and btn_idx <= 20) or (btn_idx >= 26 and btn_idx <= 29) or (btn_idx >= 35 and btn_idx <= 38) or (btn_idx >= 43 and btn_idx <= 44) or (btn_idx >= 54 and btn_idx <= 56) then
            return 2 -- Switch
        elseif btn_idx == 39 then
            return 7 -- Selector
        end
    else
        -- Pravila za Standardni StripLink (vključuje najine nove tube!)
        if (btn_idx >= 13 and btn_idx <= 16) or (btn_idx >= 25 and btn_idx <= 27) or (btn_idx >= 34 and btn_idx <= 36) then
            return 3 -- Tube
        elseif btn_idx == 17 or btn_idx == 18 or btn_idx == 28 or btn_idx == 29 or btn_idx == 37 or btn_idx == 38 or btn_idx == 43 or btn_idx == 44 or btn_idx == 54 or btn_idx == 55 then
            return 2 -- Switch
        elseif btn_idx == 39 then
            return 7 -- Selector
        end
    end
    
    return 1 -- Vse ostalo je Knob
end



local steps_cache = {}
local active_plugins = {}
local warned_clones = {}

if not manual_selection_list then manual_selection_list = {} end

-- Global clipboard buffer for section Copy/Paste
local clipboard_buffer = {
    hash = nil,
    alias = nil,
    jsfx_name = nil, -- Tracks the source JSFX layout type
    page_name = nil, -- Tracks the section type (EQ, DYN, SAT)
    items = {}
}

-------------------------------------------------

local _, script_filepath = reaper.get_action_context()
local script_path = script_filepath:match("^.+[\\/]")


local last_poll_time = 0
local last_fx_structure_hash = nil
local last_project = nil
local POLL_INTERVAL = 0.5
local POLL_INTERVAL_FAST = 0.2 -- fast poll 
local POLL_INTERVAL_SLOW = 2.0 -- slow poll
local last_poll_fast = 0
local last_poll_slow = 0
local STRUCTURE_CHECK_INTERVAL = 2.0 -- structural scanning

local last_sel_trig = -1
local last_sent_slot = 0
local last_sent_id = 0
local last_global_page = -1
local last_change_count = 0

local last_known_striplink_count = -1
local throttle_timer = 0

local global_last_touch_tr   = -2
local global_last_touch_guid = ""
local global_last_touch_p    = -1

-- ============================================================================
-- IDENTIFICATION AND HASHING (NATIVE LUA)
-- ============================================================================

-- Fast CRC32 implementation for Lua 5.3+ (Reaper 6+)
local function CRC32(str)
    local crc = 0xFFFFFFFF
    for i = 1, #str do
        local byte = string.byte(str, i)
        crc = crc ~ byte
        for j = 1, 8 do
            local mask = -(crc & 1)
            crc = (crc >> 1) ~ (0xEDB88320 & mask)
        end
    end
    return ~crc & 0xFFFFFFFF
end

-- Generate Hash and Alias (with Fallback Hash for legacy compatibility)
local function GenerateHashAndAlias(raw_original_name)
    if not raw_original_name or raw_original_name == "" then return "", "", "", "", "" end
    
    -- Extract prefix and create type tag (e.g., {VST3})
    local prefix = raw_original_name:match("^%s*(%u+%d*):")
    local type_tag = prefix and ("{" .. prefix .. "}") or ""
    
    -- Strip prefix from raw name
    local raw_without_prefix = raw_original_name:gsub("^%s*%u+%d*:%s*", "")
    
    -- PRIMARY HASH GENERATOR (Raw Without Prefix + Type Tag)
    local string_for_hash = raw_without_prefix .. type_tag
    local hash_hex = string.format("%08X", CRC32(string_for_hash))
    
    -- FALLBACK HASH (Raw Without Parentheses + Type Tag) for migrated legacy mappings
    local clean_without_parens = raw_without_prefix:gsub("%b()", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
    local fallback_string_for_hash = clean_without_parens .. type_tag
    local fallback_hash_hex = string.format("%08X", CRC32(fallback_string_for_hash))
    
    -- ALIAS GENERATOR (Clean GUI name)
    local alias = clean_without_parens:gsub("|", "-"):gsub("<", "["):gsub(">", "]")
    
    return hash_hex, alias, raw_original_name, type_tag, fallback_hash_hex
end


-- Clean FX name for context menus (uses the new Alias generator)
local function CleanFXName(name)
    if not name or name == "" then return "" end
    local _, alias = GenerateHashAndAlias(name)
    return alias
end



-- Safely get the ORIGINAL FX name (ignores user renames in Reaper 7.44+)
local function GetOriginalFXName(track, fx_idx)
    -- First try the new Reaper API (original_name)
    local ok, orig_name = reaper.TrackFX_GetNamedConfigParm(track, fx_idx, "original_name")
    if not ok or orig_name == "" then
        -- Fallback for slightly older versions
        ok, orig_name = reaper.TrackFX_GetNamedConfigParm(track, fx_idx, "fx_name")
        if not ok or orig_name == "" then
            -- Classic fallback if all else fails
            _, orig_name = reaper.TrackFX_GetFXName(track, fx_idx, "")
        end
    end
    return orig_name
end

-- ============================================================================
-- NATIVE INI I/O OPERATIONS (RAM-BASED)
-- ============================================================================

-- Read INI file into a multi-dimensional Lua table
local function ReadINI_ToRAM(filepath)
    local ini = { _order = {}, _comments = {}, _global_comments = {} }
    local f = io.open(filepath, "r")
    if not f then return ini end -- Return empty structure if file doesn't exist
    
    local current_section = nil
    local pending_comments = {}
    
    for line in f:lines() do
        local trim_line = line:match("^%s*(.-)%s*$")
        
        if trim_line:sub(1, 1) == ";" then
            -- Save comments to a queue
            table.insert(pending_comments, trim_line)
        elseif trim_line:match("^%[.-%]$") then
            -- New section
            current_section = trim_line:match("^%[(.-)%]$")
            if not ini[current_section] then
                ini[current_section] = {}
                table.insert(ini._order, current_section)
            end
            
            -- Assign pending comments to this section
            if #pending_comments > 0 then
                if not ini._comments[current_section] then ini._comments[current_section] = {} end
                for _, c in ipairs(pending_comments) do table.insert(ini._comments[current_section], c) end
                pending_comments = {}
            end
        elseif current_section and trim_line:match("^(.-)=(.*)$") then
            -- Read key and value
            local k, v = trim_line:match("^(.-)=(.*)$")
            ini[current_section][k] = v
            pending_comments = {} -- Discard comments inside sections (unless they precede the section)
        else
            -- Global comments at the top of the file, before the first section
            if not current_section and #pending_comments > 0 then
                for _, c in ipairs(pending_comments) do table.insert(ini._global_comments, c) end
                pending_comments = {}
            end
        end
    end
    
    f:close()
    return ini
end

-- Safe Lua table write to INI file (Atomic Write and Numeric Sort)
local function WriteINI_FromRAM(filepath, ini)
    local tmp_path = filepath .. ".tmp"
    local f = io.open(tmp_path, "w")
    if not f then 
        table.insert(pending_os_tasks, function()
            reaper.MB("Critical saving error!\n\nThe mapping file cannot be overwritten. Please close the file if you have it open in a text editor.\n\nIf the file is not open, another system process (like Antivirus or Cloud Sync) might have temporarily locked it. Please try saving again in a moment.", "StripLink Error", 0)
        end)
        return false 
    end 
    
    -- Write global comments
    if ini._global_comments and #ini._global_comments > 0 then
        for _, c in ipairs(ini._global_comments) do f:write(c .. "\n") end
    end
    
    -- Write sections
    for _, section in ipairs(ini._order) do
        -- Comments preceding the section
        if ini._comments and ini._comments[section] then
            for _, c in ipairs(ini._comments[section]) do f:write(c .. "\n") end
        end
        
        -- Section header
        f:write("[" .. section .. "]\n")
        
        -- Collect and sort keys
        local keys = {}
        for k, _ in pairs(ini[section]) do table.insert(keys, k) end
        
        table.sort(keys, function(a, b)
            local numA = tonumber(a:match("^Btn(%d+)$"))
            local numB = tonumber(b:match("^Btn(%d+)$"))
            if numA and numB then return numA < numB end 
            if numA then return true end
            if numB then return false end
            return a < b 
        end)
        
        -- Write keys and values
        for _, k in ipairs(keys) do
            f:write(k .. "=" .. tostring(ini[section][k]) .. "\n")
        end
    end
    f:close()
    
    -- Atomic File Swap
    if package.config:sub(1,1) == "\\" then
        -- Windows zahteva predhodni remove
        os.remove(filepath)
    end
    os.rename(tmp_path, filepath)
    return true
end


-- ============================================================================
-- MIGRATION LOGIC (BACKWARD COMPATIBILITY)
-- ============================================================================

-- Safely migrate old INI mappings to the new Hash-based relational system
local function MigrateOldMappings(ini)
    local has_changes = false
    if type(ini) ~= "table" then return false end
    
    if not ini["DICTIONARY"] then
        ini["DICTIONARY"] = {}
        if not ini._order then ini._order = {} end
        table.insert(ini._order, 1, "DICTIONARY")
        has_changes = true
    end

    local new_order = {}
    for _, section in ipairs(ini._order or {}) do
        -- Check if it's already properly hashed (8 hex chars followed by _)
        if section == "DICTIONARY" or section:match("^UNMAPPED_") or section:match("^[0-9A-F]+_") or section:match("^[0-9A-F]+>") then
            table.insert(new_order, section)
        else
            local name_part, page_part = section:match("^(.-)_([A-Z0-9]+)$")
            if name_part and page_part then
                local clean_name, type_tag = name_part:match("^(.-)(%{.-%})$")
                if clean_name and type_tag then
                    local plugin_type = type_tag:match("%{(.-)%}") or ""
                    local reconstructed_raw = plugin_type .. ": " .. clean_name
                    local hash_hex, alias, raw_name, tag = GenerateHashAndAlias(reconstructed_raw)
                    
                    if hash_hex and hash_hex ~= "" then
                        if not ini["DICTIONARY"][hash_hex] then
                            ini["DICTIONARY"][hash_hex] = raw_name .. tag .. "|" .. alias
                        end
                        
                        local target_page = page_part
                        if page_part == "SAT" then
                            local has_btn_6_or_higher = false
                            if type(ini[section]) == "table" then
                                for k, _ in pairs(ini[section]) do
                                    local btn_num = tonumber(tostring(k):match("^Btn(%d+)$"))
                                    if btn_num and btn_num >= 6 then
                                        has_btn_6_or_higher = true
                                        break
                                    end
                                end
                            end
                            target_page = has_btn_6_or_higher and "POST" or "PRE"
                        end
                        
                        local new_section = hash_hex .. "_" .. target_page
                        ini[new_section] = ini[section]
                        ini[section] = nil
                        
                        if not ini._comments then ini._comments = {} end
                        if ini._comments[section] then
                            ini._comments[new_section] = ini._comments[section]
                            ini._comments[section] = nil
                        else
                            ini._comments[new_section] = {"; Alias: " .. alias}
                        end
                        
                        table.insert(new_order, new_section)
                        has_changes = true
                    else
                        table.insert(new_order, section)
                    end
                else
                    local new_section = "UNMAPPED_" .. section
                    ini[new_section] = ini[section]
                    ini[section] = nil
                    if not ini._comments then ini._comments = {} end
                    if ini._comments[section] then
                        ini._comments[new_section] = ini._comments[section]
                        ini._comments[section] = nil
                    end
                    table.insert(new_order, new_section)
                    has_changes = true
                end
            else
                table.insert(new_order, section)
            end
        end
    end
    if has_changes then ini._order = new_order end
    return has_changes
end



local function key_from_btn(btn_idx)
    return btn_idx - 1
end

local function btn_from_key(key_idx)
    return key_idx + 1
end

local function HasAnyLinks(guid)
    for i = 0, 64 do
        local _, v = reaper.GetProjExtState(0, NS, guid .. ":" .. i)
        if v ~= "" then return true end
    end
    return false
end

-- Funkcija preveri razpoložljivost metrov glede na zavihek
local function CheckMeterAvailability(tab_id, elements, ignore_el_id)
    local avail = { 
        level = (tab_id ~= 2),  -- Level meter je dovoljen povsod, RAZEN na DYN (2)
        gr_top = (tab_id == 2), -- GR Top je dovoljen SAMO na DYN (2)
        gr_bot = (tab_id == 2)  -- GR Bot je dovoljen SAMO na DYN (2)
    }

    if elements then
        for _, el in ipairs(elements) do
            -- Preverimo samo tipe 5 (Metri), ki niso trenutno urejani element
            if el[12] == tab_id and el[2] == 5 and el[1] ~= ignore_el_id then
                local p_id = el[5]
                
                if p_id == 0 then 
                    avail.level = false -- Level meter na tem zavihku že obstaja
                elseif p_id == 1 or p_id == 3 or p_id == 5 then 
                    avail.gr_top = false -- GR Top na DYN že obstaja
                elseif p_id == 2 or p_id == 4 or p_id == 6 then 
                    avail.gr_bot = false -- GR Bot na DYN že obstaja
                end
            end
        end
    end

    return avail
end

-- ============================================================================
-- DYNAMIC INI DATABASE & SMART FALLBACK LOGIC
-- ============================================================================

-- Cache for loaded INI databases
local INI_DBs = {}

-- Function to extract clean JSFX name for file naming (e.g. "StripLink BUS")
local function GetBaseJSFXName(track, fx_idx)
    local ok, orig_name = reaper.TrackFX_GetNamedConfigParm(track, fx_idx, "original_name")
    if not ok or orig_name == "" then
        _, orig_name = reaper.TrackFX_GetFXName(track, fx_idx, "")
    end
    
    -- 1. Odstrani "JS: " predpono
    local clean_name = orig_name:gsub("^JS:%s*", "")
    
    -- 2. Odstrani kvadratne oklepaje na koncu [StripLink Module v2.jsfx]
    clean_name = clean_name:gsub("%s+%[.-%]$", "")
    
    -- 3. Odstrani končnico .jsfx ali .JSFX
    clean_name = clean_name:gsub("%.jsfx$", ""):gsub("%.JSFX$", "")
    
    -- 4. Odstrani vse mape pred imenom (tako / kot \)
    clean_name = clean_name:match("([^\\/]+)$") or clean_name
    
    return clean_name
end


local function GetJSFXHeightFromFile(jsfx_name)
    if not jsfx_name or jsfx_name == "" then return 635 end
    local filepath = script_path .. jsfx_name
    local f = io.open(filepath, "r")
    if not f then
        filepath = script_path .. jsfx_name .. ".jsfx"
        f = io.open(filepath, "r")
    end
    if f then
        local content = f:read("*all")
        f:close()
        local h = content:match("@gfx%s+%d+%s+(%d+)")
        if h then
            local raw_h = tonumber(h) or 635
            -- Kompenzacija za stil VU metra, da dobimo osnovno višino platna
            local ext_style = tonumber(reaper.GetExtState(NS, "GLOBAL_VU_STYLE")) or 0
            if ext_style == 1 then raw_h = raw_h + 40
            elseif ext_style == 2 then raw_h = raw_h + 70 end
            return raw_h
        end
    end
    return 635 -- Fallback
end


-- ============================================================================
-- THEME SYSTEM: SCANNER & PATH PATCHER
-- ============================================================================

-- Scans available themes for the selected plugin type
local function GetAvailableThemes(jsfx_name)
    local themes = {}
    local target_dir = script_path .. "SL_Themes" .. package.config:sub(1,1) .. jsfx_name
    local i = 0
    repeat
        local sub_dir = reaper.EnumerateSubdirectories(target_dir, i)
        if sub_dir and sub_dir ~= "" then
            table.insert(themes, sub_dir)
        end
        i = i + 1
    until not sub_dir or sub_dir == ""

    -- Fallback if folder is empty or doesn't exist
    if #themes == 0 then table.insert(themes, "Default") end
    return themes
end

-- Replaces the theme path inside the actual JSFX file using Regex and Atomic Write
local function ApplyThemeToJSFX(jsfx_name, new_theme)

    local filepath = script_path .. jsfx_name
    local f = io.open(filepath, "r")
    
    if not f then
        filepath = script_path .. jsfx_name .. ".jsfx"
        f = io.open(filepath, "r")
    end
    
    if not f then return false end 
    
    local content = f:read("*all")
    f:close()

    local safe_jsfx_name = jsfx_name:gsub("([%-%^%$%(%)%%%.%[%]%*%+%?])", "%%%1")
    local search_pattern = "(filename:%d+,%s*SL_Themes/" .. safe_jsfx_name .. "/)[^/\n\r]+/"
    local replacement = "%1" .. new_theme .. "/"
    
    local new_content, count = content:gsub(search_pattern, replacement)
    
    if count > 0 then
        local tmp_path = filepath .. ".tmp"
        local fw = io.open(tmp_path, "w")
        if fw then
            fw:write(new_content)
            fw:close()
            -- Atomic File Swap
            if package.config:sub(1,1) == "\\" then
                os.remove(filepath)
            end
            os.rename(tmp_path, filepath)
            return true
        end
    end
    
    return false
end

-- Function to dynamically load and cache the appropriate INI file
local function GetINIDB(jsfx_name)
    if not INI_DBs[jsfx_name] then
        local filepath = script_path .. jsfx_name .. "_mappings.ini"
        local db = ReadINI_ToRAM(filepath)
        
        -- Run automatic migration of old mappings if needed
        if MigrateOldMappings(db) then
            WriteINI_FromRAM(filepath, db)
        end
        INI_DBs[jsfx_name] = db
    end
    return INI_DBs[jsfx_name]
end

-- Safely check if a mapping section exists in RAM, including legacy Fallback and DYN Fallback
local function get_valid_mapping_section(hash_hex, page, fallback_hash_hex, INI_DB)
    local primary_section = hash_hex .. "_" .. page
    
    if INI_DB[primary_section] then
        return primary_section
    end
    
    -- Check legacy fallback hash (without vendor parentheses)
    if fallback_hash_hex and fallback_hash_hex ~= "" and fallback_hash_hex ~= hash_hex then
        local fallback_sec = fallback_hash_hex .. "_" .. page
        if INI_DB[fallback_sec] then
            return fallback_sec
        end
    end
    
    -- Smart Fallback for DYN section (DYN1 <-> DYN2 <-> DYN)
    if page == "DYN1" or page == "DYN2" then
        local alt_page = (page == "DYN1") and "DYN2" or "DYN1"
        
        -- Try alternate DYN page (DYN2 or DYN1)
        local fb = hash_hex .. "_" .. alt_page
        if INI_DB[fb] then return fb end
        if fallback_hash_hex and fallback_hash_hex ~= "" then
            local fb2 = fallback_hash_hex .. "_" .. alt_page
            if INI_DB[fb2] then return fb2 end
        end
        
        -- Try legacy single _DYN page
        local fb_dyn = hash_hex .. "_DYN"
        if INI_DB[fb_dyn] then return fb_dyn end
        if fallback_hash_hex and fallback_hash_hex ~= "" then
            local fb_dyn2 = fallback_hash_hex .. "_DYN"
            if INI_DB[fb_dyn2] then return fb_dyn2 end
        end
    end

    -- Smart Fallback for SAT section (PRE <-> POST <-> SAT)
    if page == "PRE" or page == "POST" then
        local alt_page = (page == "PRE") and "POST" or "PRE"
        
        local fb = hash_hex .. "_" .. alt_page
        if INI_DB[fb] then return fb end
        if fallback_hash_hex and fallback_hash_hex ~= "" then
            local fb2 = fallback_hash_hex .. "_" .. alt_page
            if INI_DB[fb2] then return fb2 end
        end
        
        local fb_sat = hash_hex .. "_SAT"
        if INI_DB[fb_sat] then return fb_sat end
        if fallback_hash_hex and fallback_hash_hex ~= "" then
            local fb_sat2 = fallback_hash_hex .. "_SAT"
            if INI_DB[fb_sat2] then return fb_sat2 end
        end
    end
    
    return nil
end

-- Check if a chain sequence exists as an in-order subsequence within context_fx_list
local function IsChainSubsequenceInContext(chain_hash_str, ctx_list)
    local chain_hashes = {}
    for h in chain_hash_str:gmatch("([A-Z0-9]+)") do
        table.insert(chain_hashes, h)
    end
    if #chain_hashes < 2 then return false end

    local ctx_idx = 1
    for _, req_hash in ipairs(chain_hashes) do
        local found = false
        while ctx_idx <= #ctx_list do
            local ctx_fx = ctx_list[ctx_idx]
            ctx_idx = ctx_idx + 1
            if ctx_fx.hash == req_hash or ctx_fx.fallback_hash == req_hash then
                found = true
                break
            end
        end
        if not found then return false end
    end
    return true
end

-- Helper function to match INI section page suffixes to the active page
local function is_page_match(sec_page, act_page)
    if sec_page == act_page then return true end
    if (act_page == "DYN1" or act_page == "DYN2") and (sec_page == "DYN1" or sec_page == "DYN2" or sec_page == "DYN") then
        return true
    end
    if (act_page == "PRE" or act_page == "POST") and (sec_page == "PRE" or sec_page == "POST" or sec_page == "SAT") then
        return true
    end
    return false
end

-- HELPER FUNC for NAME (For JSFX)
-- 1. GLAVNI SLOVAR (Edino mesto, kjer definiraš znake)
local function char_to_code(c)
    local byte = string.byte(c)
    if not byte then return 0 end
    if c:match("%l") then return 10 + (byte - string.byte('a') + 1)
    elseif c:match("%u") then return 40 + (byte - string.byte('A') + 1)
    elseif c:match("%d") then return 70 + (byte - string.byte('0'))
    elseif c == "+" then return 81
    elseif c == "-" then return 82
    elseif c == "/" then return 83
    elseif c == "." then return 84
    elseif c == "(" then return 85
    elseif c == ")" then return 86
    else return 0 end
end

-- 2. FUNKCIJA ZA KODIRANJE BESEDIL V BUILDERJU (Base50 - 9 ZNAKOV)
local function char_to_base50(c)
    if not c or c == "" then return 1 end
    if c == " " then return 1 end
    c = c:upper()
    local b = string.byte(c)
    if b >= 65 and b <= 90 then return b - 65 + 2 end   -- A-Z (2..27)
    if b >= 48 and b <= 57 then return b - 48 + 28 end  -- 0-9 (28..37)
    if c == "-" then return 38 end
    if c == "+" then return 39 end
    if c == "/" then return 40 end
    if c == "*" then return 41 end
    if c == "." then return 42 end
    
    -- Vsi nepodprti znaki (šumniki, !, @, #, %, ...) se avtomatsko pretvorijo v '*'
    return 41
end

local function base50_to_char(code)
    if code == 1 then return " " end
    if code >= 2 and code <= 27 then return string.char(code - 2 + 65) end
    if code >= 28 and code <= 37 then return string.char(code - 28 + 48) end
    if code == 38 then return "-" end
    if code == 39 then return "+" end
    if code == 40 then return "/" end
    if code == 41 then return "*" end
    if code == 42 then return "." end
    return ""
end

local function EncodeStringToBase50(str)
    if not str or str == "" then return 0 end
    str = str:upper()
    -- Zapolnimo z presledki do 9 znakov
    if #str < 9 then
        str = str .. string.rep(" ", 9 - #str)
    end
    local val = 0
    for i = 1, 9 do
        local code = char_to_base50(str:sub(i, i))
        val = val * 50 + code
    end
    return val
end

local function DecodeBase50ToString(part1, part2)
    local function decode_num(v)
        if not v or v <= 0 then return "" end
        local tmp = math.floor(v)
        local codes = {}
        for i = 1, 9 do
            if tmp > 0 then
                local code = tmp % 50
                table.insert(codes, 1, code)
                tmp = math.floor(tmp / 50)
            end
        end
        local str = ""
        for _, code in ipairs(codes) do
            str = str .. base50_to_char(code)
        end
        return str
    end
    return decode_num(part1) .. decode_num(part2)
end

local function encode_param_name_to_number(name)
    if not name or name == "" then return 0 end
    
    -- Preveri, ali gre za "CUSTOM" ime (začne se s tildo ~)
    local is_custom = false
    if name:sub(1,1) == "~" then
        is_custom = true
        name = name:sub(2) 
    end

    -- Loči osnovno ime in večmestno številko na koncu (npr. "Frequency 3")
    local base_name, num_str = name:match("^(.-)%s*(%d+)$")
    if not base_name then
        base_name = name
        num_str = ""
    end

    local final_str = ""
    
    if is_custom then
        -- ROČNO PREIMENOVANI: Ohranimo celotno besedilo (do 9 znakov)
        if num_str ~= "" then
            local suffix = " " .. num_str
            local allowed_len = 9 - #suffix
            final_str = base_name:sub(1, allowed_len) .. suffix
        else
            final_str = base_name:sub(1, 9)
        end
    else
        -- AVTOMATSKI: Prvo besedo striktno omejimo na NAJVEČ 6 črk
        local first_word = base_name:match("^%s*(%S+)") or base_name
        first_word = first_word:sub(1, 6)
        
        if num_str ~= "" then
            final_str = first_word .. " " .. num_str
        else
            final_str = first_word
        end
    end

    -- Zakodiramo končni niz v Base 50
    return EncodeStringToBase50(final_str)
end

local function safe_split(str)
    local t = {}
    if not str or str == "" then return t end
    for s in (str .. ":"):gmatch("(.-):") do table.insert(t, s) end
    return t
end


local function ParseParamString(str)
    if not str or str == "" then return nil end
    local lower_str = str:lower()
    if lower_str:find("-inf") then return -100.0 end
    if lower_str:find("+inf") or lower_str:find("inf") then return 100.0 end
    local num_str = str:match("%-?%d+%.?%d*")
    if num_str then return tonumber(num_str) end
    return nil
end

local function format_float(val, decimals)
    return string.format("%."..decimals.."f", tonumber(val) or 0):gsub(",", ".")
end


local function PackDX(dx, align, ref_w)
    if align == 0 then return math.floor(dx) end -- Legacy / Free mode
    local sign = (dx < 0) and -1 or 1
    -- Format: Celi del (DX) + Tisočine (Align) + Desettisočine (Ref_W)
    -- Primer: DX 10, Align 2, RefW 42 -> 10.2042
    local dec = (align * 0.1) + ((ref_w or 0) * 0.0001)
    return (math.abs(dx) + dec) * sign
end

local function UnpackDX(packed_dx)
    if not packed_dx or packed_dx == 0 then return 0, 0, 0 end
    local sign = (packed_dx < 0) and -1 or 1
    local abs_val = math.abs(packed_dx)
    local dx = math.floor(abs_val)
    
    -- Izvlečemo decimalni del in preprečimo float napake z zaokroževanjem
    local dec = math.floor((abs_val - dx) * 10000 + 0.5)
    
    local align = math.floor(dec / 1000)
    local ref_w = dec % 1000
    
    return dx * sign, align, ref_w
end

local UpdatePluginStructure

-- ============================================================================
-- SAVE MAPPING (RAM-BASED & CHAIN READY)
-- ============================================================================

function SaveMapping(track, fx_idx, page_name, section_hash_chain, sub_slot)

    local guid = reaper.TrackFX_GetFXGUID(track, fx_idx)
        
    -- Get dynamic INI database for this specific JSFX
    local jsfx_name = GetBaseJSFXName(track, fx_idx)
    local INI_DB = GetINIDB(jsfx_name)
    local filepath = script_path .. jsfx_name .. "_mappings.ini"
        
    -- Translate standard page names to actual Hash suffixes
    local actual_page = page_name
    if page_name == "DYN" then
        actual_page = (sub_slot == 2) and "DYN2" or "DYN1"
    elseif page_name == "FX" then
        actual_page = (sub_slot == 2) and "POST" or "PRE"
    end
    
    -- Check instance name (Slider 1)
    local custom_hash = math.floor(reaper.TrackFX_GetParam(track, fx_idx, 0) + 0.5)
    local custom_suffix = (custom_hash > 0) and ("_" .. tostring(custom_hash)) or ""
    
    local section = section_hash_chain .. "_" .. actual_page .. custom_suffix
    
    local function proceed_with_save()
        if not INI_DB[section] then
            INI_DB[section] = {}
            table.insert(INI_DB._order, section)
        end

        local btn_list = {}
        if page_name == "EQ" then
            btn_list = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
        elseif page_name == "DYN" then
            local dyn_top    = {21, 22, 23, 24, 25, 26, 27, 28, 29}
            local dyn_bottom = {30, 31, 32, 33, 34, 35, 36, 37, 38}
            btn_list = (sub_slot == 2) and dyn_bottom or dyn_top
        elseif page_name == "FX" then
            local fx_pre_list  = {39, 40, 41, 42, 43, 44}
            local fx_post_list = {45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56}
            btn_list = (sub_slot == 2) and fx_post_list or fx_pre_list
        end

        for j = 0, 70 do 
            INI_DB[section]["Btn"..j] = nil 
        end

        local chain_hashes = {}
        for h in section_hash_chain:gmatch("([A-Z0-9]+)") do
            table.insert(chain_hashes, h)
        end

        local context_fx_list = {}
        local c_idx = -1
        local track_fx_count = reaper.TrackFX_GetCount(track)
         
        for i = 0, track_fx_count - 1 do
            local _, is_c = reaper.TrackFX_GetNamedConfigParm(track, i, "container_count")
            if is_c ~= "" then c_idx = i; break end
        end
         
        local function AddFXToList(target_idx)
            if target_idx == fx_idx or target_idx == c_idx then return end
            local orig_name = GetOriginalFXName(track, target_idx)
            local h, alias, raw_name, tag = GenerateHashAndAlias(orig_name)
            if h and h ~= "" and not orig_name:lower():find("striplink") and not orig_name:lower():find("aggregator") then
                table.insert(context_fx_list, { hash = h, alias = alias, raw = raw_name, tag = tag, guid = reaper.TrackFX_GetFXGUID(track, target_idx) })
            end
        end
         
        if c_idx ~= -1 then
            local ok, c_cnt_str = reaper.TrackFX_GetNamedConfigParm(track, c_idx, "container_count")
            local c_cnt = ok and tonumber(c_cnt_str) or 0
            for i = 0, c_cnt - 1 do
                local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(track, c_idx, "container_item." .. i)
                local child_idx = tonumber(child_id_str)
                if child_idx then AddFXToList(child_idx) end
            end
        end
         
        for i = 0, track_fx_count - 1 do
            if i ~= c_idx then AddFXToList(i) end
        end

        if not INI_DB["DICTIONARY"] then
            INI_DB["DICTIONARY"] = {}
            table.insert(INI_DB._order, 1, "DICTIONARY")
        end

        local alias_names = {}
        for _, h in ipairs(chain_hashes) do
            local matched_alias = nil
            for _, ctx in ipairs(context_fx_list) do
                if ctx.hash == h then
                    if not INI_DB["DICTIONARY"][h] then
                        INI_DB["DICTIONARY"][h] = ctx.raw .. ctx.tag .. "|" .. ctx.alias
                    end
                    matched_alias = ctx.alias
                    break
                end
            end
            
            if not matched_alias and INI_DB["DICTIONARY"][h] then
                matched_alias = INI_DB["DICTIONARY"][h]:match("|(.*)$")
            end
            
            table.insert(alias_names, matched_alias or "Unknown")
        end
        
        if custom_hash > 0 then
            local _, saved_name = reaper.GetProjExtState(0, NS, "INSTANCE_NAME_" .. guid)
            if saved_name and saved_name ~= "" then
                INI_DB["DICTIONARY"][tostring(custom_hash)] = saved_name
            end
        end
        
        local guid_to_rel_idx = {}
        local consumed_guid = {}
        for rel_i, target_hash in ipairs(chain_hashes) do
            for _, ctx_fx in ipairs(context_fx_list) do
                if ctx_fx.hash == target_hash and not consumed_guid[ctx_fx.guid] then
                    guid_to_rel_idx[ctx_fx.guid] = rel_i - 1
                    consumed_guid[ctx_fx.guid] = true
                    break
                end
            end
        end

        for rel_idx = 0, #btn_list - 1 do
            local btn_id = btn_list[rel_idx + 1]
            local k_idx = key_from_btn(btn_id)
            
            local param_key = guid .. ":" .. k_idx
            local _, param_val = reaper.GetProjExtState(0, NS, param_key)

            if param_val ~= "" then
                local parts = safe_split(param_val)
                local target_guid = parts[1]
                local target_fx_idx = tonumber(parts[3])
                local p_num = tonumber(parts[4])
                local curve_p = tonumber((tostring(parts[6]):gsub(",", "."))) or 1.0
                local default_v = tonumber((tostring(parts[8]):gsub(",", "."))) or 0.5
                local current_p_name = parts[5] and parts[5]:gsub(",", "") or ""
                
                local _, color_val = reaper.GetProjExtState(0, NS, "COLOR:" .. guid .. ":" .. k_idx)
                local style_num = tonumber(color_val) or 13
                
                if p_num and target_guid then
                    local rel_hash_idx = guid_to_rel_idx[target_guid]
                    if not rel_hash_idx then rel_hash_idx = 0 end
                    local line = string.format("%d,%d,%d,%s,%s,%s", rel_hash_idx, p_num, math.floor(style_num), format_float(curve_p, 2), format_float(default_v, 4), current_p_name)
                    INI_DB[section]["Btn" .. rel_idx] = line
                end
            end
        end
        
        -- ==========================================================
         -- NEW: LAYOUT SAVING FOR MODULE
         -- ==========================================================
         local slot = GetFXSlot(track)
         if jsfx_name:lower():find("module") ~= nil and user_layouts[slot] then
             local layout_sec = section .. "_LAYOUT"
             
             -- Preverimo, ali sekcija že obstaja, da ne podvajamo vrstnega reda
             if not INI_DB[layout_sec] then
                 local inserted = false
                 for idx, sec in ipairs(INI_DB._order) do
                     if sec == section then
                         table.insert(INI_DB._order, idx + 1, layout_sec)
                         inserted = true
                         break
                     end
                 end
                 if not inserted then table.insert(INI_DB._order, layout_sec) end
             end
             
             INI_DB[layout_sec] = {} -- Očistimo stare elemente pred novim zapisom
             
             local target_tab = 1
             if page_name == "EQ" then target_tab = 1
             elseif page_name == "DYN" then target_tab = 2
             elseif page_name == "FX" then target_tab = 3
             end
             
             -- Poiščemo Y pozicijo dividerja (za ločevanje Top/Bottom elementov)
             local divider_y = 350
             for _, el in ipairs(user_layouts[slot]) do
                 if el[12] == target_tab and el[1] >= 900 and el[2] == 6 then
                     divider_y = el[4]
                     break
                 end
             end
             
             local el_counter = 1
             for _, el in ipairs(user_layouts[slot]) do
                 -- Shranimo samo elemente na trenutnem zavihku in preskočimo sistemske (>= 900)
                 if el[12] == target_tab and el[1] < 900 then
                     local is_bottom = false
                     local param_id = math.floor(el[5] or 0)
                     
                     -- Določitev ali element pripada Top ali Bottom sekciji
                     if target_tab == 2 then
                         if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then is_bottom = true
                         elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then is_bottom = false
                         else is_bottom = ((el[4] or 0) >= divider_y) end
                     elseif target_tab == 3 then
                         if param_id >= 45 and param_id <= 56 then is_bottom = true
                         elseif param_id >= 39 and param_id <= 44 then is_bottom = false
                         else is_bottom = ((el[4] or 0) >= divider_y) end
                     end
                     
                     -- Ali element pripada tisti sekciji, ki jo trenutno shranjujemo?
                     local belongs_to_this_save = (page_name == "EQ") or 
                                                  (sub_slot == 1 and not is_bottom) or 
                                                  (sub_slot == 2 and is_bottom)
                                                  
                     if belongs_to_this_save then
                         local text_str = (el[9] and el[9] ~= "") and el[9] or " "
                         
                         --Uporabimo math.floor za VSE številke, da preprečimo Lua Float Crash
                         local line = string.format("%d,%d,%d,%d,%d,%d,%d,%d,%s,%d,%d,%d,%g,%d",
                             math.floor((el[1] or 0) + 0.5), 
                             math.floor((el[2] or 0) + 0.5), 
                             math.floor((el[3] or 0) + 0.5), 
                             math.floor((el[4] or 0) + 0.5), 
                             math.floor((el[5] or 0) + 0.5), 
                             math.floor((el[6] or 0) + 0.5), 
                             math.floor((el[7] or 0) + 0.5), 
                             math.floor((el[8] or 0) + 0.5),
                             text_str, 
                             math.floor((el[10] or 14) + 0.5), 
                             math.floor((el[11] or 0) + 0.5), 
                             math.floor((el[12] or 0) + 0.5), 
                             (el[13] or 0), -- %g ohrani decimalke za poravnavo
                             math.floor((el[14] or 0) + 0.5))
                         
                         INI_DB[layout_sec]["El_" .. el_counter] = line
                         el_counter = el_counter + 1
                     end
                 end
             end
         end
         -- ==========================================================
        
        local comment_str = "; Alias: " .. table.concat(alias_names, " + ")
        INI_DB._comments[section] = {comment_str}

        WriteINI_FromRAM(filepath, INI_DB)
    end

    -- Check for existing mapping in RAM
    if INI_DB[section] then
        table.insert(pending_os_tasks, function()
            local msg = "Overwrite existing '" .. actual_page .. "' mapping?\n\nTIP: Rename the instance to save a new mapping variant."
            local ans = reaper.MB(msg, "StripLink: Overwrite Mapping", 4)
            if ans == 6 then proceed_with_save() end
        end)
    else
        proceed_with_save()
    end
end

-- ============================================================================
-- LOAD MAPPING (RAM-BASED & CHAIN READY)
-- ============================================================================

function LoadMapping(track, fx_idx, page_name, section_hash_chain, silent, sub_slot, target_fx_idx_override, force_custom_hash)

    local guid = reaper.TrackFX_GetFXGUID(track, fx_idx)
    
    -- Get dynamic INI database for this specific JSFX
    local jsfx_name = GetBaseJSFXName(track, fx_idx)
    local INI_DB = GetINIDB(jsfx_name)
    
    -- Translate standard page names to actual Hash suffixes
    local actual_page = page_name
    if page_name == "DYN" then
        actual_page = (sub_slot == 2) and "DYN2" or "DYN1"
    elseif page_name == "FX" then
        actual_page = (sub_slot == 2) and "POST" or "PRE"
    end
    
    -- Check instance name (Read from parameter os Slider)
    local custom_hash = force_custom_hash
    if custom_hash == nil then
        custom_hash = math.floor(reaper.TrackFX_GetParam(track, fx_idx, 0) + 0.5)
    end
    local custom_suffix = (custom_hash > 0) and ("_" .. tostring(custom_hash)) or ""
    local target_page = actual_page .. custom_suffix

    -- Check if section exists in RAM with Smart Fallback (e.g. DYN1 <-> DYN2)
    local section = get_valid_mapping_section(section_hash_chain, target_page, nil, INI_DB)
    
    if not section then
        if not silent then 
            table.insert(pending_os_tasks, function()
                reaper.MB("No " .. actual_page .. " mapping found for this chain.", "StripLink", 0) 
            end)
        end
        return 
    end

    --local slot = math.floor(reaper.TrackFX_GetParam(track, fx_idx, 1) + 0.5)
    local slot = GetFXSlot(track)
    local base = PROJECT_BASE + slot * 500
    
    local btn_list = {}
    if page_name == "EQ" then
        btn_list = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
    elseif page_name == "DYN" then
        local dyn_top    = {21, 22, 23, 24, 25, 26, 27, 28, 29}
        local dyn_bottom = {30, 31, 32, 33, 34, 35, 36, 37, 38}
        btn_list = (sub_slot == 2) and dyn_bottom or dyn_top
    elseif page_name == "FX" then
        local fx_pre_list  = {39, 40, 41, 42, 43, 44}
        local fx_post_list = {45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56}
        btn_list = (sub_slot == 2) and fx_post_list or fx_pre_list
    end

    -- Extract hashes from the chain string
    local chain_hashes = {}
    for h in section_hash_chain:gmatch("([A-Z0-9]+)") do
        table.insert(chain_hashes, h)
    end

    -- Build a map of context FX based on signal flow order (Container Priority + Main Track Fallback)
    local context_fx_list = {}
    local c_idx = -1
    local track_fx_count = reaper.TrackFX_GetCount(track)
    
    for i = 0, track_fx_count - 1 do
        local _, is_c = reaper.TrackFX_GetNamedConfigParm(track, i, "container_count")
        if is_c ~= "" then c_idx = i; break end
    end
    
    local function AddFXToList(target_idx)
        if target_idx == fx_idx or target_idx == c_idx then return end
        local orig_name = GetOriginalFXName(track, target_idx)
        local h, _, _, _, fb_h = GenerateHashAndAlias(orig_name)
        if h and h ~= "" and not orig_name:lower():find("striplink") and not orig_name:lower():find("aggregator") then
            table.insert(context_fx_list, { hash = h, fallback_hash = fb_h, idx = target_idx })
        end
    end
    
    if c_idx ~= -1 then
        local ok, c_cnt_str = reaper.TrackFX_GetNamedConfigParm(track, c_idx, "container_count")
        local c_cnt = ok and tonumber(c_cnt_str) or 0
        for i = 0, c_cnt - 1 do
            local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(track, c_idx, "container_item." .. i)
            local child_idx = tonumber(child_id_str)
            if child_idx then AddFXToList(child_idx) end
        end
    end
    
    for i = 0, track_fx_count - 1 do
        if i ~= c_idx then AddFXToList(i) end
    end
    
    -- Map 0-based relative hash indices from INI to actual Reaper FX indices
    local rel_to_fx_idx = {}
    local consumed_fx = {}

    -- Ignore FX instances already mapped on OTHER sub-slots of this StripLink instance
    if not target_fx_idx_override then
        for b = 0, 64 do
            local _, mapped_val = reaper.GetProjExtState(0, NS, guid .. ":" .. b)
            if mapped_val and mapped_val ~= "" then
                local p_parts = safe_split(mapped_val)
                local m_fx_idx = tonumber(p_parts[3])
                if m_fx_idx then
                    local is_current_btn = false
                    for _, b_id in ipairs(btn_list) do
                        if key_from_btn(b_id) == b then is_current_btn = true; break end
                    end
                    if not is_current_btn then
                        consumed_fx[m_fx_idx] = true
                    end
                end
            end
        end
    end

    if target_fx_idx_override and #chain_hashes == 1 then
        rel_to_fx_idx[0] = target_fx_idx_override
        consumed_fx[target_fx_idx_override] = true
    else
        for rel_i, target_hash in ipairs(chain_hashes) do
            for _, ctx_fx in ipairs(context_fx_list) do
                if (ctx_fx.hash == target_hash or ctx_fx.fallback_hash == target_hash) and not consumed_fx[ctx_fx.idx] then
                    rel_to_fx_idx[rel_i - 1] = ctx_fx.idx 
                    consumed_fx[ctx_fx.idx] = true
                    break
                end
            end
        end
    end

    -- Process Buttons
    for rel_idx = 0, #btn_list - 1 do
        local btn_id = btn_list[rel_idx + 1]
        local k_idx  = key_from_btn(btn_id)
        local key_name = "Btn" .. rel_idx
        
        -- Grab value directly from RAM table
        local data = INI_DB[section] and INI_DB[section][key_name] or ""

        if data ~= "" then
            local first_val = data:match("^([^,]+)")
            local rel_hash_idx = 0
            local p_idx, c_style, c_p, c_def, c_name
            
            if tonumber(first_val) then
                -- NEW FORMAT (RelativeHashIdx, ParamIdx, Color, Curve, Default, Name)
                rel_hash_idx, p_idx, c_style, c_p, c_def, c_name = data:match("([^,]+),([^,]+),([^,]+),?([^,]*),?([^,]*),?(.*)")
                rel_hash_idx = tonumber(rel_hash_idx)
            else
                -- OLD FORMAT FALLBACK (PluginName, ParamIdx, Color, Curve, Default, Name)
                local _
                _, p_idx, c_style, c_p, c_def, c_name = data:match("([^,]+),([^,]+),([^,]+),?([^,]*),?([^,]*),?(.*)")
                rel_hash_idx = 0 -- Default to 0 for single legacy plugins
            end

            -- Legacy parsing safeguards
            if c_def and c_def ~= "" and not tonumber(c_def) then
                c_name = c_def
                c_def = ""
            end
            if c_p and c_p ~= "" and not tonumber(c_p) then
                c_name = c_p
                c_p = "1.0"
                c_def = ""
            end

            if p_idx then
                local p_num = tonumber(p_idx)
                local color_num = tonumber(c_style) or 13
                local curve_val = tonumber((c_p and tostring(c_p):gsub(",", ".") or "1.0")) or 1.0
                
                -- Resolve to actual plugin index
                local final_fx_idx = rel_to_fx_idx[rel_hash_idx]
                
                if final_fx_idx then
                    local _, native_p_name = reaper.TrackFX_GetParamName(track, final_fx_idx, p_num, "")
                    local final_p_name = (c_name and c_name ~= "") and c_name or native_p_name:gsub(":", "-")
                    local target_guid = reaper.TrackFX_GetFXGUID(track, final_fx_idx)
                    local current_fx_val = reaper.TrackFX_GetParamNormalized(track, final_fx_idx, p_num)
                    local default_val_str = (c_def and c_def ~= "") and tostring(c_def):gsub(",", ".") or format_float(current_fx_val, 4)
                    
                    local val = table.concat({target_guid, 0, final_fx_idx, p_num, final_p_name, tostring(curve_val):gsub(",", "."), reaper.GetTrackGUID(track), default_val_str}, ":")                
                    reaper.SetProjExtState(0, NS, guid .. ":" .. k_idx, val)
                    
                    if not mapping_cache[slot] then mapping_cache[slot] = {} end
                    mapping_cache[slot][k_idx] = val
                    
                    reaper.SetProjExtState(0, NS, "COLOR:" .. guid .. ":" .. k_idx, tostring(color_num))
                    
                    local unit_id = get_unit_id(native_p_name)
                    reaper.SetProjExtState(0, NS, "UNIT:" .. guid .. ":" .. k_idx, tostring(unit_id))
                    
                    local step_size, _, _, n_steps = reaper.TrackFX_GetParameterStepSizes(track, final_fx_idx, p_num)
                    local raw_step = type(step_size) == "number" and step_size or (tonumber(n_steps) or 0)
                    local final_steps = 0
                    if raw_step > 0 then final_steps = math.floor((1 / raw_step) + 0.5) + 1 end
                    
                    reaper.gmem_write(PROJECT_BASE + 60000 + (slot * 100) + k_idx, final_steps)
                    reaper.SetProjExtState(0, NS, "STEPS:" .. guid .. ":" .. k_idx, tostring(final_steps))
                    
                    local cur_v = reaper.TrackFX_GetParamNormalized(track, final_fx_idx, p_num)
                    local is_bypass = native_p_name:lower():find("bypass") ~= nil
                    local final_val = is_bypass and (1 - cur_v) or (cur_v ^ (1 / curve_val))
                    
                    reaper.gmem_write(base + 11 + k_idx, final_val)
                    
                    local addr_val = base + 11 + k_idx
                    local mem_key = guid .. ":" .. k_idx
                    last_gmem_values[mem_key] = { val = final_val, time = reaper.time_precise() }
                    
                    local enc_n = encode_param_name_to_number(final_p_name)
                    if not mapping_cache[slot].encoded_name then mapping_cache[slot].encoded_name = {} end
                    mapping_cache[slot].encoded_name[k_idx] = enc_n
                    reaper.gmem_write(base + 220 + k_idx, enc_n)
                else
                    -- Target FX not found or Button Unmapped: RESET Meters knob data
                    reaper.SetProjExtState(0, NS, guid .. ":" .. k_idx, "")
                    reaper.SetProjExtState(0, NS, "COLOR:" .. guid .. ":" .. k_idx, "")
                    reaper.SetProjExtState(0, NS, "UNIT:" .. guid .. ":" .. k_idx, "")
                    reaper.SetProjExtState(0, NS, "STEPS:" .. guid .. ":" .. k_idx, "")
                    reaper.SetProjExtState(0, NS, "GROUP:" .. guid .. ":" .. k_idx, "")
                    
                    if mapping_cache[slot] and mapping_cache[slot].encoded_name then mapping_cache[slot].encoded_name[k_idx] = 0 end
                    reaper.gmem_write(base + 150 + k_idx, 13)
                    reaper.gmem_write(base + 11 + k_idx, 0)
                    reaper.gmem_write(base + 80 + k_idx, 0)
                    reaper.gmem_write(base + 220 + k_idx, 0)
                    reaper.gmem_write(base + 360 + k_idx, 0)
                    reaper.gmem_write(PROJECT_BASE + 60000 + (slot * 100) + k_idx, 0)
                end
            end
        else
            -- No mapping string found for this button index
            reaper.SetProjExtState(0, NS, guid .. ":" .. k_idx, "")
            reaper.gmem_write(base + 150 + k_idx, 0)
            reaper.gmem_write(base + 11 + k_idx, 0)
            reaper.gmem_write(base + 220 + k_idx, 0)
        end
    end
    
        -- ==========================================================
        -- NEW: LAYOUT LOADING FOR MODULE
        -- ==========================================================
        if jsfx_name:lower():find("module") ~= nil then
            local layout_sec = section .. "_LAYOUT"
            if INI_DB[layout_sec] then
                local target_tab = 1
                if page_name == "EQ" then target_tab = 1
                elseif page_name == "DYN" then target_tab = 2
                elseif page_name == "FX" then target_tab = 3
                end
                
                -- Očistimo stare elemente s tega zavihka (in te sekcije, če gre za split)
                if user_layouts[slot] then
                    local divider_y = 350
                    for _, el in ipairs(user_layouts[slot]) do
                        if el[12] == target_tab and el[1] >= 900 and el[2] == 6 then
                            divider_y = el[4]
                            break
                        end
                    end
                    
                    for j = #user_layouts[slot], 1, -1 do
                        local el = user_layouts[slot][j]
                        if el[12] == target_tab and el[1] < 900 then
                            local is_bottom = false
                            local param_id = math.floor(el[5] or 0)
                            
                            if target_tab == 2 then
                                if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then is_bottom = true
                                elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then is_bottom = false
                                else is_bottom = ((el[4] or 0) >= divider_y) end
                            elseif target_tab == 3 then
                                if param_id >= 45 and param_id <= 56 then is_bottom = true
                                elseif param_id >= 39 and param_id <= 44 then is_bottom = false
                                else is_bottom = ((el[4] or 0) >= divider_y) end
                            end
                            
                            local belongs_to_this_load = (page_name == "EQ") or 
                                                         (sub_slot == 1 and not is_bottom) or 
                                                         (sub_slot == 2 and is_bottom)
                                                         
                            if belongs_to_this_load then
                                table.remove(user_layouts[slot], j)
                            end
                        end
                    end
                else
                    -- Če layout tabela sploh še ne obstaja
                    local inst_h = math.floor(reaper.gmem_read(base + 426))
                    if inst_h <= 0 then inst_h = 635 end
                    user_layouts[slot] = GetDefaultLayout(inst_h)
                end
                
                -- Naložimo nove elemente iz INI
                for k, v in pairs(INI_DB[layout_sec]) do
                    if k:match("^El_%d+$") and v ~= "" then
                        local id_s, type_s, x_s, y_s, param_s, w_s, h_s, txt2_s, text_s, sz_s, bold_s, tab_s, dx_s, dy_s = v:match("^(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),([^,]*),(%-?%d+),(%-?%d+),(%-?%d+),(%-?[%d%.]+),(%-?%d+)$")
                        if id_s then
                            local new_el = {
                                tonumber(id_s), tonumber(type_s), tonumber(x_s), tonumber(y_s),
                                tonumber(param_s), tonumber(w_s), tonumber(h_s), tonumber(txt2_s),
                                text_s, tonumber(sz_s), tonumber(bold_s), tonumber(tab_s),
                                tonumber(dx_s) or 0, tonumber(dy_s) or 0
                            }
                            table.insert(user_layouts[slot], new_el)
                        end
                    end
                end
                
                -- Pošljemo nov layout v JSFX UI
                reaper.gmem_write(base + 496, 1)
            end
        end
        -- ==========================================================
        
    -- Increment the sequence counter to trigger UI redraw
    reaper.gmem_write(base + 3, (reaper.gmem_read(base + 3) + 1) % 1000)
    
    -- refresh DNA for JSFX @serialize
    UpdatePluginStructure(track, slot, guid)
end

local function BuildFXMenu(track, caller_fx_idx)
    local items, map, idx = {"Unlink meter           ", ""}, {}, 1
    map[idx] = { unlink = true }

    local function scan_fx(tr, parent_idx)
        local count = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(tr)
        for i = 0, count - 1 do
            local current_fx_idx = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_item." .. i)})[2]) or i
            if current_fx_idx and current_fx_idx ~= caller_fx_idx then
                local retval, name = reaper.TrackFX_GetFXName(tr, current_fx_idx, "")
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, current_fx_idx, "container_count")
                local clean_name = CleanFXName(name):gsub("|", "-"):gsub("<", "["):gsub(">", "]")
                if is_c ~= "" then
                    table.insert(items, ">[C] " .. clean_name)
                    scan_fx(tr, current_fx_idx)
                    table.insert(items, "<")
                elseif not name:lower():find("striplink") then
                    table.insert(items, clean_name)
                    idx = idx + 1
                    map[idx] = { fx_idx = current_fx_idx }
                end
            end
        end
    end
    scan_fx(track, nil)
    return table.concat(items, "|"), map
end

local function BuildMenu(track, caller_guid, btn_idx)

    local items, map, idx = {"Unlink parameter         ", "Link to last touched parameter", ""}, {}, 1
    map[idx] = { unlink = true }
    idx = idx + 1
    map[idx] = { last_touched = true }

    -- PARAMETER RENAMING OPTION
    local _, current_val = reaper.GetProjExtState(0, NS, caller_guid .. ":" .. btn_idx)
    if current_val ~= "" then
        table.insert(items, "Rename parameter")
        idx = idx + 1
        map[idx] = { rename = true }

        local parts = safe_split(current_val)
        local current_curve = tonumber(parts[6]) or 1.0
        
        local prefix = (current_curve < 0) and "✓ " or ""

        table.insert(items, prefix .. "Invert status")
        idx = idx + 1
        map[idx] = { invert = true }
    end
    
        --  ASSIGN TO GROUP (A - F)
        local group_key = "GROUP:" .. caller_guid .. ":" .. btn_idx
        local _, cur_g = reaper.GetProjExtState(0, NS, group_key)
        local cur_group = tonumber(cur_g) or 0
        local group_names = {"No Group", "Group A", "Group B", "Group C", "Group D", "Group E", "Group F"}
        
        table.insert(items, ">Assign to Group")
        for i, g_name in ipairs(group_names) do
            local g_val = i - 1
            local g_prefix = (cur_group == g_val) and "✓ " or ""
            table.insert(items, g_prefix .. g_name)
            idx = idx + 1
            map[idx] = { group_assign = true, val = g_val }
        end
        table.insert(items, "<")
    
    table.insert(items, "") -- SEPARATOR
    local cur_parts = safe_split(current_val)
    local cur_target_guid = cur_parts[1] or ""
    local cur_param_idx = tonumber(cur_parts[4]) or -1

    if cur_target_guid ~= "" then
        local saved_fx_idx = tonumber(cur_parts[3]) or 0
        if saved_fx_idx <= 0 or saved_fx_idx >= reaper.TrackFX_GetCount(track) or reaper.TrackFX_GetFXGUID(track, saved_fx_idx) ~= cur_target_guid then
            local function find_guid_recursive(tr, p_idx)
                local count = p_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, p_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(tr)
                for j = 0, (count or 0) - 1 do
                    local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, p_idx or -1, "container_item." .. j)
                    local current_idx = p_idx and tonumber(child_id_str) or j
                    if current_idx and reaper.TrackFX_GetFXGUID(tr, current_idx) == cur_target_guid then return current_idx end
                    local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, current_idx or -1, "container_count")
                    if is_c ~= "" then
                        local res = find_guid_recursive(tr, current_idx)
                        if res then return res end
                    end
                end
            end
            local actual_idx = find_guid_recursive(track, nil)
            
            -- HEALING LOGIC FOR CONTAINERS IN MENU
            if not actual_idx and saved_fx_idx > 0 then
                local test_guid = reaper.TrackFX_GetFXGUID(track, saved_fx_idx)
                if test_guid and test_guid ~= "" then
                    local p_num = tonumber(cur_parts[4])
                    if p_num and p_num < reaper.TrackFX_GetNumParams(track, saved_fx_idx) then
                        actual_idx = saved_fx_idx
                        cur_parts[1] = test_guid -- Heal the GUID
                    end
                end
            end
            
            if actual_idx then
                cur_parts[3] = tostring(actual_idx)
                reaper.SetProjExtState(0, NS, caller_guid .. ":" .. btn_idx, table.concat(cur_parts, ":"))
            end
            -- We intentionally DO NOT clear cur_parts[3] if not found, to allow future healing
        end
    end

    local function is_guid_in_container(tr, parent_idx, target_guid)
        local count = tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_count")})[2]) or 0
        for i = 0, count - 1 do
            local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_item." .. i)
            local child_idx = tonumber(child_id_str)
            if child_idx then
                if reaper.TrackFX_GetFXGUID(tr, child_idx) == target_guid then return true end
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, child_idx, "container_count")
                if is_c ~= "" and is_guid_in_container(tr, child_idx, target_guid) then return true end
            end
        end
        return false
    end

    local function scan_fx(tr, parent_idx)
        local count = 0
        if not parent_idx then
            count = reaper.TrackFX_GetCount(tr)
        else
            local ok, c_count = reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_count")
            count = ok and tonumber(c_count) or 0
        end

        for i = 0, count - 1 do
            local current_fx_idx
            if not parent_idx then
                current_fx_idx = i
            else
                local ok_id, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, parent_idx, "container_item." .. i)
                current_fx_idx = ok_id and tonumber(child_id_str)
            end

            if current_fx_idx then
                local retval, name = reaper.TrackFX_GetFXName(tr, current_fx_idx, "")
                local guid = reaper.TrackFX_GetFXGUID(tr, current_fx_idx)
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, current_fx_idx, "container_count")
                
                --remove dangerous signs (| < >) from FX names
                local clean_name = CleanFXName(name):gsub("|", "-"):gsub("<", "["):gsub(">", "]")
            
                if is_c ~= "" then
                    local has_selected = (cur_target_guid == guid) or is_guid_in_container(tr, current_fx_idx, cur_target_guid)
                    local c_prefix = has_selected and "✓ " or ""
                    table.insert(items, ">" .. c_prefix .. (clean_name ~= "" and clean_name or "Container"))
                    scan_fx(tr, current_fx_idx)
                    table.insert(items, "<")
                elseif not name:lower():find("striplink") then
                    local fx_prefix = (cur_target_guid == guid) and "✓ " or ""
                    table.insert(items, ">" .. fx_prefix .. clean_name)
                    
                    for p = 0, reaper.TrackFX_GetNumParams(tr, current_fx_idx) - 1 do
                        local _, pname = reaper.TrackFX_GetParamName(tr, current_fx_idx, p, "")
                        pname = (pname == "") and ("Param " .. p) or pname
                        
                        -- CRITICAL: Skip dummy parameters (saves UAD problem with 8000 parameters)
                        if pname ~= "" and not pname:lower():find("dummy") and not pname:lower():find("reserved") then
                            
                            -- clean names
                            pname = pname:gsub("|", "/"):gsub("<", "("):gsub(">", ")"):gsub("^[!#]", "")
                            
                            local p_prefix = (cur_target_guid == guid and cur_param_idx == p) and "✓ " or ""
                            table.insert(items, p_prefix .. pname)
                            
                            idx = idx + 1
                            map[idx] = { guid = guid, param = p, fx_idx = current_fx_idx }
                        end
                    end
                    
                    table.insert(items, "<")
                end
            end
        end
    end

    scan_fx(track, nil)
    return table.concat(items, "|"), map
end

local function UpdateLink(slot, caller_guid, should_poll, track, fx_idx, just_moved)
    local base = PROJECT_BASE + slot * 500 
    if slot <= 0 then return end

    unit_cache[slot] = unit_cache[slot] or {}

    local active_lock = math.floor(reaper.gmem_read(base + 1))
    
    for i = 0, 64 do
        local btn_num = btn_from_key(i)
        local addr_val    = base + 11 + i
        local addr_disp   = base + 80 + i
        local addr_status = base + 150 + i
        local addr_name   = base + 220 + i
        local addr_group  = base + 360 + i
        
        local param_val = mapping_cache[slot] and mapping_cache[slot][i]
        
        if not param_val then
             local _, direct_val = reaper.GetProjExtState(0, NS, caller_guid .. ":" .. i)
             if direct_val ~= "" then 
                 param_val = direct_val
                 if mapping_cache[slot] then mapping_cache[slot][i] = direct_val end
                 local p_parts = safe_split(direct_val)
                 local p_name = p_parts[5] or ""
                 local enc_n = encode_param_name_to_number(p_name)
                 if mapping_cache[slot] then
                     if not mapping_cache[slot].encoded_name then mapping_cache[slot].encoded_name = {} end
                     mapping_cache[slot].encoded_name[i] = enc_n
                 end
                 reaper.gmem_write(addr_name, enc_n)
                 local _, col_val = reaper.GetProjExtState(0, NS, "COLOR:" .. caller_guid .. ":" .. i)
                 local color_num = tonumber(col_val) or 1
                 reaper.gmem_write(addr_status, 100 + color_num)
             end
        end

        local has_link = (param_val ~= nil and param_val ~= "")
        
        local cached_col = color_cache[slot] and color_cache[slot][i]
        local color_num = (cached_col and cached_col > 0) and cached_col or 1
        local current_status = reaper.gmem_read(addr_status)

        local cached_unit = unit_cache[slot] and unit_cache[slot][i] or 0
        local raw_current_status = reaper.gmem_read(addr_status)
        local current_status = raw_current_status % 1000
        
        local target_base_status = has_link and (100 + color_num) or (should_poll and color_num or current_status)
        local final_status = (cached_unit * 1000) + target_base_status
        
        if (raw_current_status == 0 or should_poll) and raw_current_status ~= final_status then
            reaper.gmem_write(addr_status, final_status)
        end

        if should_poll then
            local cur_group = group_cache[slot] and group_cache[slot][i] or 0
            if reaper.gmem_read(addr_group) ~= cur_group then
                reaper.gmem_write(addr_group, cur_group)
            end
        end

        if has_link then
            -- create CACHE teble, if they don't exist:
            if not mapping_cache[slot].parts then mapping_cache[slot].parts = {} end
            if not mapping_cache[slot].last_raw then mapping_cache[slot].last_raw = {} end
            
            -- Split only if new val in mem:
            if mapping_cache[slot].last_raw[i] ~= param_val then
                mapping_cache[slot].parts[i] = safe_split(param_val)
                mapping_cache[slot].last_raw[i] = param_val
            end
            
            local parts = mapping_cache[slot].parts[i]
            local target_track = track
            local t_guid = parts[7]
            
            if t_guid and t_guid ~= "" then
                -- Create track cache if it doesn't exist yet
                if not mapping_cache[slot].target_tracks then mapping_cache[slot].target_tracks = {} end
                
                local cached_tr = mapping_cache[slot].target_tracks[i]
                
                -- CHECK IF POINTER IS VALID AND STILL POINTS TO THE CORRECT GUID
                local needs_refresh = true
                if cached_tr and reaper.ValidatePtr(cached_tr, "MediaTrack*") then
                    local current_guid = reaper.GetTrackGUID(cached_tr)
                    if current_guid == t_guid then
                        needs_refresh = false
                    end
                end

                if needs_refresh then
                    cached_tr = reaper.BR_GetMediaTrackByGUID(0, t_guid)
                    mapping_cache[slot].target_tracks[i] = cached_tr
                end
                
                target_track = cached_tr or track
            end
            
            if target_track then
                local saved_fx_guid = parts[1]
                local saved_fx_idx = tonumber(parts[3])
                local actual_fx_idx = saved_fx_idx 

                if should_poll and (not actual_fx_idx or reaper.TrackFX_GetFXGUID(target_track, actual_fx_idx) ~= saved_fx_guid) then
                     local function find_guid_recursive(tr, p_idx)
                        local count = p_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, p_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(tr)
                        for j = 0, (count or 0) - 1 do
                            local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, p_idx or -1, "container_item." .. j)
                            local current_idx = p_idx and tonumber(child_id_str) or j
                            if current_idx and reaper.TrackFX_GetFXGUID(tr, current_idx) == saved_fx_guid then return current_idx end
                            local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, current_idx or -1, "container_count")
                            if is_c ~= "" then
                                local res = find_guid_recursive(tr, current_idx)
                                if res then return res end
                            end
                        end
                    end
                    
                    actual_fx_idx = find_guid_recursive(target_track, nil)
                    
                    -- HEALING LOGIC FOR CONTAINERS (Reaper regenerates child GUIDs on SWS offline/online)
                    if not actual_fx_idx and saved_fx_idx then
                        local test_guid = reaper.TrackFX_GetFXGUID(target_track, saved_fx_idx)
                        if test_guid and test_guid ~= "" then
                            local p_num = tonumber(parts[4])
                            if p_num and p_num < reaper.TrackFX_GetNumParams(target_track, saved_fx_idx) then
                                actual_fx_idx = saved_fx_idx
                                parts[1] = test_guid -- Heal the GUID
                            end
                        end
                    end
                                        
                    -- Update cache, but PRESERVE parts[3] if not found, to allow future healing
                    if actual_fx_idx then
                        parts[3] = tostring(actual_fx_idx)
                    end
                    local new_val_str = table.concat(parts, ":")
                    reaper.SetProjExtState(0, NS, caller_guid .. ":" .. i, new_val_str)
                    if mapping_cache[slot] then mapping_cache[slot][i] = new_val_str end
                end
                local is_active = (actual_fx_idx and actual_fx_idx ~= -1)
                    
                    local final_status = is_active and (100 + color_num) or color_num
                    local packed_status = (cached_unit * 1000) + final_status
                    if reaper.gmem_read(addr_status) ~= packed_status then
                        reaper.gmem_write(addr_status, packed_status)
                    end
                    
                if actual_fx_idx and actual_fx_idx ~= -1 then
                    local p_idx = tonumber(parts[4])
                    -- Get the true native name from REAPER so custom renaming doesn't break the bypass inversion logic
                    local _, native_param_name = reaper.TrackFX_GetParamName(target_track, actual_fx_idx, p_idx, "")
                    local is_bypass = native_param_name:lower():find("bypass") ~= nil
                    local p = tonumber((tostring(parts[6]):gsub(",", "."))) or 1.0
                    
                    local current_gmem_val = reaper.gmem_read(addr_val)
                    local mem_key = caller_guid .. ":" .. i
                    if not last_gmem_values[mem_key] then last_gmem_values[mem_key] = { val = current_gmem_val, time = 0 } end
                             
                    if just_moved then
                        -- Plugin changed slots, GMEM is stale. Do NOT trigger a fake tweak!
                        last_gmem_values[mem_key].val = current_gmem_val
                        last_gmem_values[mem_key].time = 0
                    elseif math.abs(last_gmem_values[mem_key].val - current_gmem_val) > 0.0001 then
                        last_gmem_values[mem_key].val = current_gmem_val
                        last_gmem_values[mem_key].time = reaper.time_precise()
                    end
                    local is_immune = (reaper.time_precise() - last_gmem_values[mem_key].time) < 0.5

                    if not just_moved and (active_lock == btn_num or is_immune) then
                        local p_abs = math.abs(p)
                        local is_rev = (p < 0)
                        local base_val = is_bypass and (current_gmem_val < 0.5 and 1 or 0) or (current_gmem_val ^ p_abs)
                        local target_val = is_rev and (1.0 - base_val) or base_val
                        
                        -- Force strict float boundaries (0.0 to 1.0) to prevent VST3 value rejection
                        target_val = math.max(0.0, math.min(1.0, target_val))
                        
                        reaper.TrackFX_SetParamNormalized(target_track, actual_fx_idx, p_idx, target_val)
                        
                        -- Read raw val and send it back to wake unresponsive VST3s
                        local raw_v = reaper.TrackFX_GetParam(target_track, actual_fx_idx, p_idx)
                        reaper.TrackFX_SetParam(target_track, actual_fx_idx, p_idx, raw_v)
                        
                        -- DODANO 1: Zapišemo pričakovano vrednost Masterja
                        expected_vst_values[mem_key] = reaper.TrackFX_GetParamNormalized(target_track, actual_fx_idx, p_idx)
                        
                        local cur_group = group_cache[slot] and group_cache[slot][i] or 0
                        if active_lock == btn_num and cur_group > 0 and active_plugins then
                            -- 1. Preverimo Invert status trenutnega (Master) gumba
                            local master_is_rev = false
                            if mapping_cache[slot] and mapping_cache[slot].parts and mapping_cache[slot].parts[i] then
                                local m_curve = tonumber(mapping_cache[slot].parts[i][6]) or 1.0
                                master_is_rev = (m_curve < 0)
                            end

                            -- 2. Zanka gre čez VSE vtičnike in VSE možne indekse (0 - 64)
                            for _, other_fx in ipairs(active_plugins) do
                                local other_base = PROJECT_BASE + other_fx.slot * 500
                                for j = 0, 64 do
                                    if not (other_fx.guid == caller_guid and j == i) then
                                        local other_g = group_cache[other_fx.slot] and group_cache[other_fx.slot][j] or 0
                                        if other_g == cur_group then
                                            local target_is_rev = false
                                            local o_map = mapping_cache[other_fx.slot] and mapping_cache[other_fx.slot][j]
                                            local o_parts = nil
                                            if o_map then
                                                o_parts = safe_split(o_map)
                                                local t_curve = tonumber(o_parts[6]) or 1.0
                                                target_is_rev = (t_curve < 0)
                                            else
                                                local _, raw_map = reaper.GetProjExtState(0, NS, other_fx.guid .. ":" .. j)
                                                if raw_map ~= "" then
                                                    o_parts = safe_split(raw_map)
                                                    local t_curve = tonumber(o_parts[6]) or 1.0
                                                    target_is_rev = (t_curve < 0)
                                                end
                                            end
                                            
                                            local target_visual_val = current_gmem_val
                                            if master_is_rev ~= target_is_rev then
                                                target_visual_val = 1.0 - current_gmem_val
                                            end
                                            
                                            local other_addr_val = other_base + 11 + j
                                            local other_addr_disp = other_base + 80 + j
                                            
                                            if math.abs(reaper.gmem_read(other_addr_val) - target_visual_val) > 0.0001 then
                                                reaper.gmem_write(other_addr_val, target_visual_val)
                                                
                                                if o_parts then
                                                    local o_tr = o_parts[7] and reaper.BR_GetMediaTrackByGUID(0, o_parts[7]) or other_fx.tr
                                                    local o_idx = tonumber(o_parts[3])
                                                    local o_p = tonumber(o_parts[4])
                                                    if o_tr and o_idx and o_idx ~= -1 and o_p then
                                                        local o_pname = o_parts[5] or ""
                                                        local o_is_byp = o_pname:lower():find("bypass") ~= nil
                                                        
                                                        local t_curve = tonumber(o_parts[6]) or 1.0
                                                        local t_abs = math.abs(t_curve)
                                                        local t_base_v = o_is_byp and (target_visual_val < 0.5 and 1 or 0) or (target_visual_val ^ t_abs)
                                                        local final_vst_v = target_is_rev and (1.0 - t_base_v) or t_base_v
                                                        
                                                        reaper.TrackFX_SetParamNormalized(o_tr, o_idx, o_p, final_vst_v)
                                                        
                                                        -- DODANO 2: Zapišemo pričakovano vrednost Slave-a, da se zanka ne ponovi!
                                                        expected_vst_values[other_fx.guid .. ":" .. j] = reaper.TrackFX_GetParamNormalized(o_tr, o_idx, o_p)
                                                        
                                                        local _, o_buf = reaper.TrackFX_GetFormattedParamValue(o_tr, o_idx, o_p, "")
                                                        local o_disp = 0
                                                        if o_buf:match("^%a") then
                                                            o_disp = encode_param_name_to_number(o_buf)
                                                        else
                                                            local o_num = tonumber(o_buf:match("[%d%.%-]+"))
                                                            o_disp = o_num or encode_param_name_to_number(o_buf)
                                                        end
                                                        reaper.gmem_write(other_addr_disp, o_disp)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        local _, buf = reaper.TrackFX_GetFormattedParamValue(target_track, actual_fx_idx, p_idx, "")
                        local disp_val = 0
                        if buf:match("^%a") then
                            disp_val = encode_param_name_to_number(buf)
                        else
                            local num_val = tonumber(buf:match("[%d%.%-]+"))
                            disp_val = num_val or encode_param_name_to_number(buf)
                        end
                        reaper.gmem_write(addr_disp, disp_val)

                     elseif should_poll then
                         local cur_v = reaper.TrackFX_GetParamNormalized(target_track, actual_fx_idx, p_idx)
                         
                         -- ==========================================================
                         -- 1. DETEKCIJA AVTOMATIZACIJE / MIDI
                         -- ==========================================================
                         if just_moved or expected_vst_values[mem_key] == nil then
                             expected_vst_values[mem_key] = cur_v
                         end
 
                         -- ČE SE VREDNOST RAZLIKUJE, SMO ZAZNALI AVTOMATIZACIJO!
                         if math.abs(cur_v - expected_vst_values[mem_key]) > 0.0001 then
                             expected_vst_values[mem_key] = cur_v
                             
                             local cur_group = group_cache[slot] and group_cache[slot][i] or 0
                             if cur_group > 0 and active_plugins then
                                 local master_is_rev = (p < 0)
                                 local m_abs = math.abs(p)
                                 local base_m = is_bypass and (cur_v > 0.5 and 0 or 1) or cur_v
                                 local eff_m = master_is_rev and (1.0 - base_m) or base_m
                                 local target_visual_gmem = eff_m ^ (1 / m_abs)
 
                                 for _, other_fx in ipairs(active_plugins) do
                                     local other_base = PROJECT_BASE + other_fx.slot * 500
                                     for j = 0, 64 do
                                         if not (other_fx.guid == caller_guid and j == i) then
                                             local other_g = group_cache[other_fx.slot] and group_cache[other_fx.slot][j] or 0
                                             if other_g == cur_group then
                                                 local target_is_rev = false
                                                 local o_map = mapping_cache[other_fx.slot] and mapping_cache[other_fx.slot][j]
                                                 local o_parts = nil
                                                 if o_map then
                                                     o_parts = safe_split(o_map)
                                                     local t_curve = tonumber(o_parts[6]) or 1.0
                                                     target_is_rev = (t_curve < 0)
                                                 else
                                                     local _, raw_map = reaper.GetProjExtState(0, NS, other_fx.guid .. ":" .. j)
                                                     if raw_map ~= "" then
                                                         o_parts = safe_split(raw_map)
                                                         local t_curve = tonumber(o_parts[6]) or 1.0
                                                         target_is_rev = (t_curve < 0)
                                                     end
                                                 end
                                                 
                                                 local final_visual = target_visual_gmem
                                                 if master_is_rev ~= target_is_rev then
                                                     final_visual = 1.0 - target_visual_gmem
                                                 end
                                                 
                                                 local other_addr_val = other_base + 11 + j
                                                 local other_addr_disp = other_base + 80 + j
                                                 
                                                 if math.abs(reaper.gmem_read(other_addr_val) - final_visual) > 0.0001 then
                                                     reaper.gmem_write(other_addr_val, final_visual)
                                                     
                                                     if o_parts then
                                                         local o_tr = o_parts[7] and reaper.BR_GetMediaTrackByGUID(0, o_parts[7]) or other_fx.tr
                                                         local o_idx = tonumber(o_parts[3])
                                                         local o_p = tonumber(o_parts[4])
                                                         if o_tr and o_idx and o_idx ~= -1 and o_p then
                                                             local o_pname = o_parts[5] or ""
                                                             local o_is_byp = o_pname:lower():find("bypass") ~= nil
                                                             
                                                             local t_curve = tonumber(o_parts[6]) or 1.0
                                                             local t_abs = math.abs(t_curve)
                                                             local t_base_v = o_is_byp and (final_visual < 0.5 and 1 or 0) or (final_visual ^ t_abs)
                                                             local final_vst_v = target_is_rev and (1.0 - t_base_v) or t_base_v
                                                             
                                                             reaper.TrackFX_SetParamNormalized(o_tr, o_idx, o_p, final_vst_v)
                                                             
                                                             -- PREPREČITEV ZANKE: Zapišemo pričakovano vrednost avtomatiziranega Slave-a
                                                             expected_vst_values[other_fx.guid .. ":" .. j] = reaper.TrackFX_GetParamNormalized(o_tr, o_idx, o_p)
                                                             
                                                             local _, o_buf = reaper.TrackFX_GetFormattedParamValue(o_tr, o_idx, o_p, "")
                                                             local o_disp = 0
                                                             if o_buf:match("^%a") then
                                                                 o_disp = encode_param_name_to_number(o_buf)
                                                             else
                                                                 local o_num = tonumber(o_buf:match("[%d%.%-]+"))
                                                                 o_disp = o_num or encode_param_name_to_number(o_buf)
                                                             end
                                                             reaper.gmem_write(other_addr_disp, o_disp)
                                                         end
                                                     end
                                                 end
                                             end
                                         end
                                     end
                                 end
                             end
                         end
                         -- ==========================================================
 
                         -- 2. Standardno osveževanje UI-ja (tvoj prejšnji del)
                         local p_abs = math.abs(p)
                         local is_rev = (p < 0)
                         local base_v = is_bypass and (cur_v > 0.5 and 0 or 1) or cur_v
                         local effective_v = is_rev and (1.0 - base_v) or base_v
                         local final_v = effective_v ^ (1 / p_abs)
                         
                         if math.abs(reaper.gmem_read(addr_val) - final_v) > 0.00001 or just_moved then
                              reaper.gmem_write(addr_val, final_v)
                              last_gmem_values[mem_key].val = final_v 
                         end
 
                         local _, buf = reaper.TrackFX_GetFormattedParamValue(target_track, actual_fx_idx, p_idx, "")
                         local disp_val = 0
                         if buf:match("^%a") then
                             disp_val = encode_param_name_to_number(buf)
                         else
                             local num_val = tonumber(buf:match("[%d%.%-]+"))
                             disp_val = num_val or encode_param_name_to_number(buf)
                         end
                         
                         if reaper.gmem_read(addr_disp) ~= disp_val then
                             reaper.gmem_write(addr_disp, disp_val)
                         end
                         
                         local enc_name = mapping_cache[slot] and mapping_cache[slot].encoded_name and mapping_cache[slot].encoded_name[i] or 0
                         if reaper.gmem_read(addr_name) ~= enc_name then
                             reaper.gmem_write(addr_name, enc_name)
                         end
                     end
                 else
                     -- FX IS OFFLINE/MISSING (e.g. inside an offline container)
                     -- Actively push cached data to GMEM so it survives track moves and overwrites ghosts
                     local enc_name = mapping_cache[slot] and mapping_cache[slot].encoded_name and mapping_cache[slot].encoded_name[i] or 0
                     if reaper.gmem_read(addr_name) ~= enc_name then
                         reaper.gmem_write(addr_name, enc_name)
                     end
                     
                     if just_moved then
                         local mem_key = caller_guid .. ":" .. i
                         local frozen_val = (last_gmem_values[mem_key] and last_gmem_values[mem_key].val) or 0
                         reaper.gmem_write(addr_val, frozen_val)
                         reaper.gmem_write(addr_disp, 0)
                     end
                 end
             end
         else
             -- RESET gmem name and display for unlinked buttons (DO NOT touch addr_val!)  
             local addr_name = base + 220 + i
             local addr_disp = base + 80 + i
 
             if reaper.gmem_read(addr_name) ~= 0 then reaper.gmem_write(addr_name, 0) end
             if reaper.gmem_read(addr_disp) ~= 0 then reaper.gmem_write(addr_disp, 0) end
         end
     end
     
     if should_poll then
         local cur_seq = reaper.gmem_read(base + 3)
         reaper.gmem_write(base + 3, (cur_seq + 1) % 1000)
     end
 end
 
 -- ============================================================================
 -- HELPER: LOAD HYBRID MAPPING DIRECTLY (RAM & GMEM)
-- ============================================================================
local function LoadHybridMapping(tr, f_idx, section_name, target_fx_idx, target_slider)
    local c_guid = reaper.TrackFX_GetFXGUID(tr, f_idx)
    local jsfx_name = GetBaseJSFXName(tr, f_idx)
    local INI_DB = GetINIDB(jsfx_name)
    
    --local sl = math.floor(reaper.TrackFX_GetParam(tr, f_idx, 1) + 0.5)
    local sl = GetFXSlot(tr)
    
    local sl_base = PROJECT_BASE + sl * 500
    local t_guid = reaper.TrackFX_GetFXGUID(tr, target_fx_idx)
    
    if INI_DB[section_name] and t_guid then
        for k, v in pairs(INI_DB[section_name]) do
            local btn_num = tonumber(k:match("^Btn(%d+)$"))
            if btn_num and v ~= "" then
                local p_idx, c_style, c_p, c_def, c_name = v:match("0,([^,]+),([^,]+),?([^,]*),?([^,]*),?(.*)")
                if p_idx then
                    local p_num = tonumber(p_idx)
                    local color_num = tonumber(c_style) or 13
                    local curve_val = tonumber((c_p and tostring(c_p):gsub(",", ".") or "1.0")) or 1.0
                    
                    local _, native_p_name = reaper.TrackFX_GetParamName(tr, target_fx_idx, p_num, "")
                    local final_p_name = (c_name and c_name ~= "") and c_name or native_p_name:gsub(":", "-")
                    local current_fx_val = reaper.TrackFX_GetParamNormalized(tr, target_fx_idx, p_num)
                    local default_val_str = (c_def and c_def ~= "") and tostring(c_def):gsub(",", ".") or format_float(current_fx_val, 4)
                    
                    local val = table.concat({t_guid, 0, target_fx_idx, p_num, final_p_name, tostring(curve_val):gsub(",", "."), reaper.GetTrackGUID(tr), default_val_str}, ":")                
                    
                    reaper.SetProjExtState(0, NS, c_guid .. ":" .. btn_num, val)
                    if not mapping_cache[sl] then mapping_cache[sl] = {} end
                    mapping_cache[sl][btn_num] = val
                    
                    reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. btn_num, tostring(color_num))
                    local unit_id = get_unit_id(native_p_name)
                    reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. btn_num, tostring(unit_id))
                    
                    local enc_n = encode_param_name_to_number(final_p_name)
                    if not mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name = {} end
                    mapping_cache[sl].encoded_name[btn_num] = enc_n
                    
                    local is_bypass = native_p_name:lower():find("bypass") ~= nil
                    local final_val = is_bypass and (1 - current_fx_val) or (current_fx_val ^ (1 / curve_val))
                    
                    reaper.gmem_write(sl_base + 11 + btn_num, final_val)
                    reaper.gmem_write(sl_base + 220 + btn_num, enc_n)
                    reaper.gmem_write(sl_base + 150 + btn_num, (unit_id * 1000) + 100 + color_num)
                end
            end
        end
        -- NALAGANJE LAYOUTA ZA HYBRID
        if jsfx_name:lower():find("module") ~= nil then
            local layout_sec = section_name .. "_LAYOUT"
            if INI_DB[layout_sec] then
                if not user_layouts[sl] then
                    local inst_h = math.floor(reaper.gmem_read(sl_base + 426))
                    if inst_h <= 0 then inst_h = 635 end
                    user_layouts[sl] = GetDefaultLayout(inst_h)
                end
                
                local is_eq = section_name:find("_EQ")
                local is_dyn = section_name:find("_DYN")
                local is_fx = section_name:find("_PRE") or section_name:find("_POST")
                
                -- Najprej počistimo obstoječe elemente samo na zavihkih, ki jih ta Hybrid pokriva
                for j = #user_layouts[sl], 1, -1 do
                    local el = user_layouts[sl][j]
                    local t_tab = el[12]
                    local is_sys = (el[1] >= 900)
                    if not is_sys then
                        if (is_eq and t_tab == 1) or (is_dyn and t_tab == 2) or (is_fx and t_tab == 3) then
                            table.remove(user_layouts[sl], j)
                        end
                    end
                end
                
                -- Nato naložimo nove elemente iz INI datoteke
                for k, v in pairs(INI_DB[layout_sec]) do
                    if k:match("^El_%d+$") and v ~= "" then
                        local id_s, type_s, x_s, y_s, param_s, w_s, h_s, txt2_s, text_s, sz_s, bold_s, tab_s, dx_s, dy_s = v:match("^(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),([^,]*),(%-?%d+),(%-?%d+),(%-?%d+),(%-?[%d%.]+),(%-?%d+)$")
                        if id_s then
                            table.insert(user_layouts[sl], {
                                tonumber(id_s), tonumber(type_s), tonumber(x_s), tonumber(y_s),
                                tonumber(param_s), tonumber(w_s), tonumber(h_s), tonumber(txt2_s),
                                text_s, tonumber(sz_s), tonumber(bold_s), tonumber(tab_s),
                                tonumber(dx_s) or 0, tonumber(dy_s) or 0
                            })
                        end
                    end
                end
                reaper.gmem_write(sl_base + 496, 1) -- Potisne layout v JSFX
            end
        end
        -- Trigger JSFX UI refresh
        reaper.gmem_write(sl_base + 3, (reaper.gmem_read(sl_base + 3) + 1) % 1000)
        -- refresh DNA!
        UpdatePluginStructure(tr, f_idx, c_guid)
        return true
    end
    return false
end

-- ============================================================================
-- AUTO LOAD NEW PLUGIN (SCANNER WITH HYBRID & SLIDER 1 SUPPORT)
-- ============================================================================
local function AutoLoadNewPlugin(tr, f_idx)
    local fx_count = reaper.TrackFX_GetCount(tr)
    local c_idx = -1

    -- Search for container
    for i = 0, fx_count - 1 do
        local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, i, "container_count")
        if is_c ~= "" then 
            c_idx = i 
            break 
        end
    end

    -- Set Number of FXs to check in container or on track
    local count = 0
    if c_idx ~= -1 then
        local ok, c_cnt = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_count")
        count = ok and tonumber(c_cnt) or 0
    else
        count = fx_count
    end
    
    local function AutoConnectMeter(target_sub_idx, meter_type)
        if c_idx == -1 then return end 
        if not target_sub_idx then return end 
        
        reaper.SetMediaTrackInfo_Value(tr, "I_NCHAN", 14)
        reaper.TrackFX_SetNamedConfigParm(tr, c_idx, "container_nch", "14")
        
        local _, addr_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_item." .. target_sub_idx)
        local addr = tonumber(addr_str)
        if not addr then return end

        local guid = reaper.TrackFX_GetFXGUID(tr, addr)
        if not guid then return end

        reaper.TrackFX_SetNamedConfigParm(tr, addr, "nchan", "14")

        local function SetSafePin(target_addr, out_pin, clear_mask, add_bit)
            local curr = reaper.TrackFX_GetPinMappings(tr, target_addr, 1, out_pin)
            reaper.TrackFX_SetPinMappings(tr, target_addr, 1, out_pin, (curr & ~clear_mask) | add_bit, 0)
        end

          if meter_type == 1 or meter_type == 2 then 
             if target_sub_idx == 0 then
                 local _, fx_name = reaper.TrackFX_GetFXName(tr, addr, "")
                 local clean_name = fx_name:gsub("%b()", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or fx_name
                 table.insert(pending_os_tasks, function()
                     reaper.MB("Gain reduction metering cannot be fully routed.\n\nThere must be at least one FX before '" .. clean_name .. "' in the container to tap the uncompressed signal.\n\nPlease insert any dummy plugin (e.g., Volume/Pan) before it and reload the mapping.", "StripLink: Metering Warning", 0)
                 end)
                 return 
             end

             local prev_sub_idx = target_sub_idx - 1
             local _, prev_addr_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_item." .. prev_sub_idx)
             local prev_addr = tonumber(prev_addr_str)
             
             if prev_addr then
                 reaper.TrackFX_SetNamedConfigParm(tr, prev_addr, "nchan", "14")
                 
                 if meter_type == 1 then
                     local m_clear = 240
                     SetSafePin(prev_addr, 0, m_clear, 1 << 4)
                     SetSafePin(prev_addr, 1, m_clear, 1 << 5)
                     SetSafePin(addr, 0, m_clear, 1 << 6)
                     SetSafePin(addr, 1, m_clear, 1 << 7)
                 else
                     local m_clear = 3840
                     SetSafePin(prev_addr, 0, m_clear, 1 << 8)
                     SetSafePin(prev_addr, 1, m_clear, 1 << 9)
                     SetSafePin(addr, 0, m_clear, 1 << 10)
                     SetSafePin(addr, 1, m_clear, 1 << 11)
                 end
             end
             
        elseif meter_type == 3 then
            local m_clear = 12288
            SetSafePin(addr, 0, m_clear, 1 << 12)
            SetSafePin(addr, 1, m_clear, 1 << 13)
        end
        
        local c_cnt_val = tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_count")})[2]) or 0
        for j=0, c_cnt_val-1 do
            local _, ag_addr_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_item." .. j)
            local ag_addr = tonumber(ag_addr_str)
            if ag_addr then
                local _, ag_name = reaper.TrackFX_GetFXName(tr, ag_addr, "")
                if ag_name:lower():find("aggregator") then
                    for p=0, 13 do reaper.TrackFX_SetPinMappings(tr, ag_addr, 0, p, 1<<p, 0) end 
                    reaper.TrackFX_SetPinMappings(tr, ag_addr, 1, 0, 1, 0)
                    reaper.TrackFX_SetPinMappings(tr, ag_addr, 1, 1, 2, 0)
                    reaper.TrackFX_SetPinMappings(tr, ag_addr, 1, 2, 4, 0) -- Sidechain L
                    reaper.TrackFX_SetPinMappings(tr, ag_addr, 1, 3, 8, 0) -- Sidechain R
                    for p=4, 13 do reaper.TrackFX_SetPinMappings(tr, ag_addr, 1, p, 0, 0) end
                end
            end
        end
        local strip_guid = reaper.TrackFX_GetFXGUID(tr, f_idx)
        if strip_guid and guid then
            reaper.SetProjExtState(0, NS, "METER_SRC_" .. strip_guid .. "_" .. meter_type, guid)
        end
    end

    -- Gather all valid Hashes to build the Chain structure (Container Priority + Main Track Fallback)
    local active_fx_hashes = {}
    local active_fx_data = {}
    local track_fx_count = reaper.TrackFX_GetCount(tr)

    local function AddFXToList(target_idx, sub_index)
        if target_idx == f_idx or target_idx == c_idx then return end
        local orig_name = GetOriginalFXName(tr, target_idx)
        local hash_hex, _, _, _, fb_hash = GenerateHashAndAlias(orig_name)
        
        if hash_hex and hash_hex ~= "" and not orig_name:lower():find("striplink") and not orig_name:lower():find("aggregator") then
            table.insert(active_fx_hashes, hash_hex)
            table.insert(active_fx_data, { hash = hash_hex, fallback_hash = fb_hash, idx = target_idx, sub_idx = sub_index })
        end
    end

    if c_idx ~= -1 then
        local ok, c_cnt_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_count")
        local c_cnt = ok and tonumber(c_cnt_str) or 0
        for i = 0, c_cnt - 1 do
            local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_item." .. i)
            local child_idx = tonumber(child_id_str)
            if child_idx then AddFXToList(child_idx, i) end
        end
    end

    for i = 0, track_fx_count - 1 do
        if i ~= c_idx then AddFXToList(i, i) end
    end

    local full_chain_hash = table.concat(active_fx_hashes, ">")
    local is_chain = (#active_fx_hashes > 1)
    
    local jsfx_name = GetBaseJSFXName(tr, f_idx)
    local INI_DB = GetINIDB(jsfx_name)
    
    local c_hash = math.floor(reaper.TrackFX_GetParam(tr, f_idx, 0) + 0.5)
    local c_suf = (c_hash > 0) and ("_" .. tostring(c_hash)) or ""

    -- 1. CHECKING STANDARD AND CHAIN MAPPINGS
    local chain_eq = is_chain and (get_valid_mapping_section(full_chain_hash, "EQ"..c_suf, nil, INI_DB) ~= nil)
    local chain_dyn = is_chain and (get_valid_mapping_section(full_chain_hash, "DYN1"..c_suf, nil, INI_DB) ~= nil)
    local chain_fx = is_chain and (get_valid_mapping_section(full_chain_hash, "PRE"..c_suf, nil, INI_DB) ~= nil)

    local eq_targets  = {}
    local dyn1_target = nil
    local dyn2_target = nil
    local fx_pre_target = nil
    local fx_post_target = nil

    for _, fx in ipairs(active_fx_data) do
        local eq_sec = get_valid_mapping_section(fx.hash, "EQ"..c_suf, fx.fallback_hash, INI_DB)
        if not chain_eq and eq_sec then
            local target_h = eq_sec:match("^(.-)_") or fx.hash
            table.insert(eq_targets, { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx })
        end
        
        local dyn_sec = get_valid_mapping_section(fx.hash, "DYN1"..c_suf, fx.fallback_hash, INI_DB)
        if not chain_dyn and dyn_sec then
            local target_h = dyn_sec:match("^(.-)_") or fx.hash
            local actual_suffix = dyn_sec:match("_([A-Z0-9]+)")
            if actual_suffix == "DYN1" then
                if not dyn1_target then dyn1_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not dyn2_target then dyn2_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            elseif actual_suffix == "DYN2" then
                if not dyn2_target then dyn2_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not dyn1_target then dyn1_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            else
                if not dyn1_target then dyn1_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not dyn2_target then dyn2_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            end
        end
        
        local fx_sec = get_valid_mapping_section(fx.hash, "PRE"..c_suf, fx.fallback_hash, INI_DB)
        if not chain_fx and fx_sec then
            local target_h = fx_sec:match("^(.-)_") or fx.hash
            local actual_suffix = fx_sec:match("_([A-Z0-9]+)")
            if actual_suffix == "PRE" then
                if not fx_pre_target then fx_pre_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not fx_post_target then fx_post_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            elseif actual_suffix == "POST" then
                if not fx_post_target then fx_post_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not fx_pre_target then fx_pre_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            else
                if not fx_pre_target then fx_pre_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx }
                elseif not fx_post_target then fx_post_target = { hash = target_h, idx = fx.idx, sub_idx = fx.sub_idx } end
            end
        end
    end

    -- 2. CHECKING HYBRIDS (If standard MAPPINGS ARE MISSING!)
    if not chain_eq and not chain_dyn and not chain_fx and #eq_targets == 0 and not dyn1_target and not dyn2_target and not fx_pre_target and not fx_post_target then
        local loaded_any_hybrid = false
        for _, fx in ipairs(active_fx_data) do
            local matched_hybrid_section = nil
            local matched_slider = 0

            for sec_name, _ in pairs(INI_DB) do
                if sec_name ~= "DICTIONARY" and not sec_name:match("^UNMAPPED_") then
                    if sec_name:find("^" .. fx.hash .. "_HYBRID_") then
                        local rem_suffix = sec_name:match("_HYBRID_[A-Z0-9_]+_(%d+)$")
                        local sec_slider = rem_suffix and tonumber(rem_suffix) or 0
                        
                        if (c_hash > 0 and sec_slider == c_hash) or (c_hash == 0 and sec_slider == 0) then
                            matched_hybrid_section = sec_name
                            matched_slider = sec_slider
                            break
                        end
                    end
                end
            end

            if matched_hybrid_section then
                LoadHybridMapping(tr, f_idx, matched_hybrid_section, fx.idx, matched_slider)
                loaded_any_hybrid = true
            end
        end
        if loaded_any_hybrid then return end
    end

    -- 3. LOADING STANDARD / CHAIN
    if chain_eq then 
        LoadMapping(tr, f_idx, "EQ", full_chain_hash, true, 1)
    elseif eq_targets[1] then 
        LoadMapping(tr, f_idx, "EQ", eq_targets[1].hash, true, 1, eq_targets[1].idx) 
    end

    if chain_dyn then
        LoadMapping(tr, f_idx, "DYN", full_chain_hash, true, 1)
        LoadMapping(tr, f_idx, "DYN", full_chain_hash, true, 2)
    else
        if dyn1_target then
            LoadMapping(tr, f_idx, "DYN", dyn1_target.hash, true, 1, dyn1_target.idx)
            AutoConnectMeter(dyn1_target.sub_idx, 1)
        end
        if dyn2_target then
            LoadMapping(tr, f_idx, "DYN", dyn2_target.hash, true, 2, dyn2_target.idx)
            AutoConnectMeter(dyn2_target.sub_idx, 2)
        end
    end

    if chain_fx then
        LoadMapping(tr, f_idx, "FX", full_chain_hash, true, 1)
        LoadMapping(tr, f_idx, "FX", full_chain_hash, true, 2)
    else
        if fx_pre_target then
            LoadMapping(tr, f_idx, "FX", fx_pre_target.hash, true, 1, fx_pre_target.idx)
            AutoConnectMeter(fx_pre_target.sub_idx, 3)
        end
        if fx_post_target then
            LoadMapping(tr, f_idx, "FX", fx_post_target.hash, true, 2, fx_post_target.idx)
        end
    end
end




-- ============================================================================
-- @SERIALIZE ASCII COMMUNICATION (LUA <-> GMEM)
-- ============================================================================

-- Serializes the mapping structure from Lua to JSFX for Track Template storage
local function WriteStructureToJSFX(slot, struct_string)
    local p_base = PROJECT_BASE
    local addr_str_buf = p_base + 150000 + slot * 2000
    local base = p_base + slot * 500

    reaper.gmem_write(addr_str_buf, #struct_string)

    for i = 1, #struct_string do
        local char_byte = string.byte(struct_string, i)
        reaper.gmem_write(addr_str_buf + i, char_byte)
    end

    reaper.gmem_write(base + 499, 1)
end

-- Restores the mapping structure from JSFX (e.g., when a Track Template is loaded)
local function ReadStructureFromJSFX(slot)
    local p_base = PROJECT_BASE
    local addr_str_buf = p_base + 150000 + slot * 2000
    local base = p_base + slot * 500
    
    local str_len = reaper.gmem_read(addr_str_buf)
    if str_len <= 0 or str_len > 1999 then return "" end
    
    local chars = {}
    for i = 1, str_len do
        table.insert(chars, string.char(reaper.gmem_read(addr_str_buf + i)))
    end
    
    -- Potrdimo prejem na novem varnem naslovu (498)
    reaper.gmem_write(base + 498, 0)
    
    return table.concat(chars)
end

-- ============================================================================
-- UPDATE PLUGIN STRUCTURE (FOR JSFX @SERIALIZE)
-- ============================================================================
UpdatePluginStructure = function(track, slot, c_guid)
    -- 1. Build a flat list of all FX (including Containers in Depth-First order)
    local flat_list = {}
    local function scan_fx_flat(parent_idx)
        local count = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(track, parent_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(track)
        for i = 0, (count or 0) - 1 do
            local current_idx = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(track, parent_idx, "container_item." .. i)})[2]) or i
            if current_idx then
                table.insert(flat_list, { idx = current_idx, guid = reaper.TrackFX_GetFXGUID(track, current_idx) })
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(track, current_idx, "container_count")
                if is_c ~= "" then scan_fx_flat(current_idx) end
            end
        end
    end
    scan_fx_flat(nil)
    
    -- Find StripLink's absolute position on the flat list
    local striplink_flat_pos = -1
    local flat_guid_to_pos = {}
    for pos, fx in ipairs(flat_list) do
        flat_guid_to_pos[fx.guid] = pos
        if fx.guid == c_guid then striplink_flat_pos = pos end
    end
    
    -- 2. Build the new serialized DNA string
    local struct_parts = {}
    local current_track_guid = reaper.GetTrackGUID(track)
    
    for b = 0, 64 do
        local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. b)
        if val and val ~= "" then
            local parts = safe_split(val)
            
            -- STRIKTNE VAROVALKE (Preprečijo sesutje string.format funkcije)
            local t_guid = parts[1]
            local p_idx = parts[4] or "0"
            local p_name = parts[5] or ""
            local curve = parts[6] or "1.0"
            local t_track_guid = parts[7]
            local default_v = parts[8] or "0.5"
            
            -- Serialize only if the target is on the same track (Track Template context)
            if (not t_track_guid or t_track_guid == "" or t_track_guid == current_track_guid) and t_guid then
                local target_flat_pos = flat_guid_to_pos[t_guid]
                if target_flat_pos and striplink_flat_pos ~= -1 then
                    -- Calculate Relative Index
                    local rel_fx_id = target_flat_pos - striplink_flat_pos
                    
                    local _, col_val = reaper.GetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. b)
                    local color_num = tonumber(col_val) or 13
                    
                    local _, unit_val = reaper.GetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. b)
                    local unit_id = tonumber(unit_val) or 0
                    
                    -- Build block safely
                    local block = string.format("%d:%d:%s:%d:%d:%s:%s:%s", b, rel_fx_id, p_idx, unit_id, color_num, curve, default_v, p_name)
                    table.insert(struct_parts, block)
                end
            end
        end
    end
    
    local final_struct = table.concat(struct_parts, "|")
    WriteStructureToJSFX(slot, final_struct)
end

-- ============================================================================
-- RESTORE PLUGIN STRUCTURE (FROM JSFX @SERIALIZE)
-- ============================================================================
local function RestorePluginStructure(track, fx_idx, slot)
    local struct_str = ReadStructureFromJSFX(slot)
    
    if not struct_str or struct_str == "" then return end
    
    local striplink_guid = reaper.TrackFX_GetFXGUID(track, fx_idx)
    
    -- 1. Build a flat list of all FX to resolve the Relative ID
    local flat_list = {}
    local function scan_fx_flat(parent_idx)
        local count = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(track, parent_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(track)
        for i = 0, (count or 0) - 1 do
            local current_idx = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(track, parent_idx, "container_item." .. i)})[2]) or i
            if current_idx then
                table.insert(flat_list, { idx = current_idx, guid = reaper.TrackFX_GetFXGUID(track, current_idx) })
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(track, current_idx, "container_count")
                if is_c ~= "" then scan_fx_flat(current_idx) end
            end
        end
    end
    scan_fx_flat(nil)
    
    -- Find StripLink's absolute position on the flat list
    local striplink_flat_pos = -1
    for pos, fx in ipairs(flat_list) do
        if fx.guid == striplink_guid then 
            striplink_flat_pos = pos 
            break 
        end
    end
    
    if striplink_flat_pos == -1 then return end
    
    local tr_guid = reaper.GetTrackGUID(track)
    local base = PROJECT_BASE + slot * 500
    
    -- 2. Parse string and restore mappings safely (Dvojni Regex!)
    for block in struct_str:gmatch("([^|]+)") do
        
        -- read new format (8 partsincl. default)
        local b_str, rel_id_str, p_idx_str, tip_str, color_str, curve_str, def_val_str, custom_name = block:match("^(%d+):([%-%d]+):(%d+):(%d+):(%d+):([^:]+):([^:]+):(.*)$")
        
        -- if reading fails read old format (7 parts, w/o default)
        if not b_str then
            b_str, rel_id_str, p_idx_str, tip_str, color_str, curve_str, custom_name = block:match("^(%d+):([%-%d]+):(%d+):(%d+):(%d+):([^:]+):(.*)$")
            def_val_str = "" -- safety fallback
        end
        
        -- continwe with key data
        if b_str and rel_id_str and p_idx_str then
            local b = tonumber(b_str)
            local rel_id = tonumber(rel_id_str)
            local p_num = tonumber(p_idx_str)
            
            local unit_id = tonumber(tip_str) or 0
            local color_num = tonumber(color_str) or 13
            local curve_val = tonumber(curve_str) or 1.0
            
            local target_flat_pos = striplink_flat_pos + rel_id
            
            if target_flat_pos >= 1 and target_flat_pos <= #flat_list then
                local target_fx = flat_list[target_flat_pos]
                local t_guid = target_fx.guid
                local t_idx = target_fx.idx
                
                local current_fx_val = reaper.TrackFX_GetParamNormalized(track, t_idx, p_num)
                
                -- SAFETY FOR DEFAULT
                if not def_val_str or def_val_str == "" or not tonumber(def_val_str) then
                    def_val_str = format_float(current_fx_val, 4)
                end
                
                local val = table.concat({t_guid, 0, t_idx, p_num, custom_name, tostring(curve_val):gsub(",", "."), tr_guid, def_val_str}, ":")
                
                reaper.SetProjExtState(0, NS, striplink_guid .. ":" .. b, val)
                if not mapping_cache[slot] then mapping_cache[slot] = {} end
                mapping_cache[slot][b] = val
                
                reaper.SetProjExtState(0, NS, "COLOR:" .. striplink_guid .. ":" .. b, tostring(color_num))
                reaper.SetProjExtState(0, NS, "UNIT:" .. striplink_guid .. ":" .. b, tostring(unit_id))
                
                local step_size, _, _, n_steps = reaper.TrackFX_GetParameterStepSizes(track, t_idx, p_num)
                local raw_step = type(step_size) == "number" and step_size or (tonumber(n_steps) or 0)
                local final_steps = 0
                if raw_step > 0 then final_steps = math.floor((1 / raw_step) + 0.5) + 1 end
                
                reaper.gmem_write(PROJECT_BASE + 60000 + (slot * 100) + b, final_steps)
                reaper.SetProjExtState(0, NS, "STEPS:" .. striplink_guid .. ":" .. b, tostring(final_steps))
                
                local is_bypass = custom_name:lower():find("bypass") ~= nil
                local final_val = is_bypass and (1 - current_fx_val) or (current_fx_val ^ (1 / curve_val))
                
                reaper.gmem_write(base + 11 + b, final_val)
                
                local enc_n = encode_param_name_to_number(custom_name)
                if not mapping_cache[slot].encoded_name then mapping_cache[slot].encoded_name = {} end
                mapping_cache[slot].encoded_name[b] = enc_n
                reaper.gmem_write(base + 220 + b, enc_n)
                
                reaper.gmem_write(base + 150 + b, (unit_id * 1000) + 100 + color_num)
            end
        end
    end
    
    reaper.gmem_write(base + 3, (reaper.gmem_read(base + 3) + 1) % 1000)
end



-- Globalna tabela najinih postavitev (kasneje se bo to shranjevalo v INI datoteko)
user_layouts = {} -- Inicialno prazna, polni se dinamično

local function GetDefaultLayout(panel_h)
    -- Varovalka, če višina še ni nastavljena
    if not panel_h or panel_h < 400 then panel_h = 635 end
    
    -- Natančna matematika za dno vtičnika (3 px paddinga spodaj)
    local ag_pwr_y = panel_h - 35
    local ag_lck_y = ag_pwr_y - 18
    
    -- Format v ploskem seznamu: {id, type, x, y, param, w, h, txt2, text, sz, bold, TAB_ID}
    return {
        -- Format: {id, type, x, y, param, w, h, txt2, text, sz, bold, TAB_ID, dx, dy}
        -- Page 0 (OVR)
        {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 0, 0, 0},
        {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 0, 0, 0},
        -- Page 1 (EQ)
        {1,  1,  6, 133,  1, 54, 54, 0, "", 14, 0, 1, 0, 0},
        {2,  1, 65, 133,  2, 54, 54, 0, "", 14, 0, 1, 0, 0},
        {17, 2,  6, 115, 13, 32, 25, 0, "", 14, 0, 1, 0, 0},
        {13, 3,  6, 202,  3, 45, 15, 0, "", 14, 0, 1, 0, 0},
        -- Auto Gain
        {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 1, 0, 0},
        {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 1, 0, 0},
        -- Page 2 (DYN)
        {902, 6, 6, 350, 5, 113, 10, 0, "", 14, 0, 2, 0, 0},
        {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 2, 0, 0},
        {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 2, 0, 0},
        -- Page 3 (FX)
        {903, 6, 6, 350, 5, 113, 10, 0, "", 14, 0, 3, 0, 0},
        {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 3, 0, 0},
        {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 3, 0, 0}
    }
end

local function LayoutMatchesOutbox(slot_idx, layout)
    if not layout then return false end
    local outbox = PROJECT_BASE + 500000 + (slot_idx * 3000)
    local count = math.floor(reaper.gmem_read(outbox - 1) + 0.5)
    if count ~= #layout then return false end
    for i = 1, count do
        local o  = outbox + (i - 1) * 13
        local el = layout[i]
        if math.floor(reaper.gmem_read(o + 0)  + 0.5) ~= math.floor((el[1]  or -1) + 0.5)
        or math.floor(reaper.gmem_read(o + 1)  + 0.5) ~= math.floor((el[2]  or -1) + 0.5)
        or math.floor(reaper.gmem_read(o + 10) + 0.5) ~= math.floor((el[12] or -1) + 0.5) then
            return false
        end
    end
    return true
end

local function InvalidateSlotOutbox(slot)
    reaper.gmem_write(PROJECT_BASE + 500000 + (slot * 3000) - 1, 0)
    reaper.gmem_write(PROJECT_BASE + slot * 500 + 427, 1)
end

function PullUILayout(slot_idx, page)
    if not user_layouts[slot_idx] then return end
    
    local mailbox = PROJECT_BASE + 200000 + (slot_idx * 3000)
    local outbox = PROJECT_BASE + 500000 + (slot_idx * 3000)
    
    if reaper.gmem_read(mailbox) == 1 then return end
    
    local element_count = math.floor(reaper.gmem_read(outbox - 1))
    if element_count <= 0 then return end 
    if not LayoutMatchesOutbox(slot_idx, user_layouts[slot_idx]) then return end
    
    local current_layout = user_layouts[slot_idx]
    local limit = math.min(#current_layout, element_count)
    
    for i = 0, limit - 1 do
        local offset = i * 13 -- NOVI STRIDE (13)
        local lua_idx = i + 1
        
        if current_layout[lua_idx] and current_layout[lua_idx][12] == page then
            current_layout[lua_idx][3]  = reaper.gmem_read(outbox + offset + 2) 
            current_layout[lua_idx][4]  = reaper.gmem_read(outbox + offset + 3) 
            current_layout[lua_idx][6]  = reaper.gmem_read(outbox + offset + 5) 
            current_layout[lua_idx][7]  = reaper.gmem_read(outbox + offset + 6)
            current_layout[lua_idx][13] = reaper.gmem_read(outbox + offset + 11) -- Očita DX
            current_layout[lua_idx][14] = reaper.gmem_read(outbox + offset + 12) -- Očita DY
        end
    end
end

function PushUILayout(slot_idx)
    if not user_layouts[slot_idx] then 
        local sl_base = PROJECT_BASE + slot_idx * 500
        local inst_h = math.floor(reaper.gmem_read(sl_base + 426))
        
        if inst_h <= 0 then 
            local jsfx_name = "StripLink Module v2"
            if active_plugins then
                for _, fx in ipairs(active_plugins) do
                    if fx.slot == slot_idx then
                        jsfx_name = GetBaseJSFXName(fx.tr, fx.idx)
                        break
                    end
                end
            end
            inst_h = GetJSFXHeightFromFile(jsfx_name)
            reaper.gmem_write(sl_base + 426, inst_h)
        end
        user_layouts[slot_idx] = GetDefaultLayout(inst_h) 
    end
    
    local elements = user_layouts[slot_idx]
    local mailbox = PROJECT_BASE + 200000 + (slot_idx * 3000)
    
    reaper.gmem_write(mailbox + 1, #elements)
    
    for i, el in ipairs(elements) do
        local offset = (i - 1) * 13 -- NOVI STRIDE (13)
        reaper.gmem_write(mailbox + 2 + offset + 0, el[1] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 1, el[2] or 1)
        reaper.gmem_write(mailbox + 2 + offset + 2, el[3] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 3, el[4] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 4, el[5] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 5, el[6] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 6, el[7] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 7, el[8] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 8, el[10] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 9, el[11] or 0)
        reaper.gmem_write(mailbox + 2 + offset + 10, el[12] or 1)
        reaper.gmem_write(mailbox + 2 + offset + 11, el[13] or 0) -- Pošlje DX
        reaper.gmem_write(mailbox + 2 + offset + 12, el[14] or 0) -- Pošlje DY
    end
    
    reaper.gmem_write(mailbox, 1) 
    if builder_selected_idx then builder_state.restore_sel = builder_selected_idx end
end

local function RebuildLayoutFromJSFX(slot_idx)
    local outbox = PROJECT_BASE + 500000 + (slot_idx * 3000)
    
    local loaded_h = math.floor(reaper.gmem_read(outbox - 3))
    if loaded_h > 0 then reaper.gmem_write(PROJECT_BASE + slot_idx * 500 + 426, loaded_h) end
    
    local element_count = math.floor(reaper.gmem_read(outbox - 1))
    if element_count <= 0 then return false end
    
    local new_layout = {}
    for i = 0, element_count - 1 do
        local offset = i * 13 -- NOVI STRIDE (13)
        local el_type = reaper.gmem_read(outbox + offset + 1)
        local part1   = reaper.gmem_read(outbox + offset + 4)
        local part2   = reaper.gmem_read(outbox + offset + 7)
        
        local text_str = ""
        if el_type == 4 then text_str = DecodeBase50ToString(part1, part2) end

        local el = {
            reaper.gmem_read(outbox + offset + 0),  -- 1: ID
            el_type,                                -- 2: Type
            reaper.gmem_read(outbox + offset + 2),  -- 3: X
            reaper.gmem_read(outbox + offset + 3),  -- 4: Y
            part1,                                  -- 5: Param / Part1
            reaper.gmem_read(outbox + offset + 5),  -- 6: W
            reaper.gmem_read(outbox + offset + 6),  -- 7: H
            part2,                                  -- 8: Txt2 / Part2
            text_str,                               -- 9: Text string (dešifrirano!)
            reaper.gmem_read(outbox + offset + 8),  -- 10: Font sz
            reaper.gmem_read(outbox + offset + 9),  -- 11: Bold
            reaper.gmem_read(outbox + offset + 10), -- 12: TAB_ID
            reaper.gmem_read(outbox + offset + 11), -- 13: DX
            reaper.gmem_read(outbox + offset + 12)  -- 14: DY
        }
        table.insert(new_layout, el)
    end
    user_layouts[slot_idx] = new_layout
    return true
end

-- =========================================================================
-- MANAGE ALL 
-- =========================================================================
local last_structure_check = 0

function ManageAll()
    local cur_project = reaper.EnumProjects(-1)

    PROJECT_BASE = 3000000 + (GetProjectIndex() * 1000000)
    local current_time = reaper.time_precise()

    local fx_just_moved_flags = {}

    reaper.gmem_write(100000, PROJECT_BASE)

    local structure_changed = false

    -- === 1. LED SINHRONIZATION FOR SELECTION (Reaper -> JSFX) ===
    local sel_track_count = reaper.CountSelectedTracks(0)
    local current_reaper_selection = {}
    for i = 0, sel_track_count - 1 do
        local sel_tr = reaper.GetSelectedTrack(0, i)
        current_reaper_selection[reaper.GetTrackGUID(sel_tr)] = true
    end

    local selection_diff = false
    for guid, _ in pairs(current_reaper_selection) do
        if not manual_selection_list[guid] then selection_diff = true; break end
    end
    if not selection_diff then
        for guid, _ in pairs(manual_selection_list) do
            if not current_reaper_selection[guid] then selection_diff = true; break end
        end
    end

    if selection_diff then
        manual_selection_list = current_reaper_selection
        for i = 0, reaper.CountTracks(0) - 1 do
            local tr = reaper.GetTrack(0, i)
            local g = reaper.GetTrackGUID(tr)
            local slot_addr = PROJECT_BASE + (i + 1) * 500
            local current_overlay = reaper.gmem_read(slot_addr + 9)
            local new_overlay = (manual_selection_list[g] == true) and 1 or 0
            if current_overlay ~= new_overlay then
                reaper.gmem_write(slot_addr + 9, new_overlay)
            end
        end
    end

    -- === CHECK FOR CHANGES & POLLING ===
    local current_change_count = reaper.GetProjectStateChangeCount(0)

    if current_change_count ~= last_change_count then
        last_change_count = current_change_count
        if (current_time - throttle_timer) > 2.0 then
            structure_changed = true
            throttle_timer = current_time
        end
    end

    if (current_time - last_structure_check) > STRUCTURE_CHECK_INTERVAL then
        last_structure_check = current_time
        
        local current_sl_count = 0
        for i = 0, reaper.CountTracks(0) - 1 do
            local t = reaper.GetTrack(0, i)
            for j = 0, reaper.TrackFX_GetCount(t) - 1 do
                local _, n = reaper.TrackFX_GetFXName(t, j, "")
                if n:lower():find("striplink") and not n:lower():find("aggregator") then
                    current_sl_count = current_sl_count + 1
                end
            end
        end
        
        if current_sl_count ~= last_known_striplink_count then
            last_known_striplink_count = current_sl_count
            structure_changed = true
            throttle_timer = current_time 
        end
    end

    local current_context = reaper.GetCursorContext()
    local user_returned = (current_context ~= last_context)
    last_context = current_context

    if cur_project ~= last_project then
        last_project = cur_project
        structure_changed = true 
    end
    
    local force_refresh = structure_changed or user_returned or (#active_plugins == 0)
    local should_poll_fast = (current_time - last_poll_fast) > POLL_INTERVAL_FAST
    local should_poll_slow = (current_time - last_poll_slow) > POLL_INTERVAL_SLOW

    if should_poll_fast then last_poll_fast = current_time end
    if should_poll_slow then last_poll_slow = current_time end

    -- === SCAN (Force Refresh) ===
    if force_refresh then
        local _, saved_meter_mode = reaper.GetProjExtState(0, NS, "GLOBAL_METER_MODE")
        reaper.gmem_write(PROJECT_BASE + 202, tonumber(saved_meter_mode) or 0)
        
        local ext_tooltips = reaper.GetExtState(NS, "USER_KNOB_TOOLTIPS")
        local tooltips_val = (ext_tooltips == "0") and 2 or 1 
        reaper.gmem_write(PROJECT_BASE + 203, tooltips_val)

        local ext_vu_ref = reaper.GetExtState(NS, "GLOBAL_VU_REF")
        local vu_ref_val = tonumber(ext_vu_ref) or -18 
        --reaper.gmem_write(PROJECT_BASE + 207, vu_ref_val)
        
        local ext_vu_style = reaper.GetExtState(NS, "GLOBAL_VU_STYLE")
        local vu_style_val = tonumber(ext_vu_style) or 0 
        reaper.gmem_write(PROJECT_BASE + 208, vu_style_val)

        local ext_gr = reaper.GetExtState(NS, "GLOBAL_MAX_GR_DB")
        local gr_val = tonumber(ext_gr) or 12 
        reaper.gmem_write(PROJECT_BASE + 204, gr_val)
        
        local ext_font = reaper.GetExtState(NS, "GLOBAL_FONT_SIZE")
        local font_val = tonumber(ext_font) or 14 
        reaper.gmem_write(PROJECT_BASE + 205, font_val)
        
        local ext_peak = reaper.GetExtState(NS, "GLOBAL_PEAK_THRESH")
        local peak_val = tonumber(ext_peak) or 0 
        reaper.gmem_write(PROJECT_BASE + 209, peak_val)
        
        local ext_m_std = reaper.GetExtState(NS, "GLOBAL_MOUSE_STD")
        reaper.gmem_write(PROJECT_BASE + 210, tonumber(ext_m_std) or 1.0)
        
        local ext_m_f = reaper.GetExtState(NS, "GLOBAL_MOUSE_FINE")
        reaper.gmem_write(PROJECT_BASE + 211, tonumber(ext_m_f) or 0.1)
                
        local found_plugins = {}
        
        -- =======================================================
        -- DETEKCIJA PODVOJENIH GUID-OV (Vedno aktivna)
        -- =======================================================
        local seen_guids = {}
        local trigger_clone_warning = false
        -- =======================================================

        local total_tracks = reaper.CountTracks(0)
        for s = 1, total_tracks do 
            reaper.gmem_write(PROJECT_BASE + s * 500 + 1, 0) 
        end

        for i = 0, reaper.CountTracks(0) - 1 do 
            local track = reaper.GetTrack(0, i)
            local cnt = reaper.TrackFX_GetCount(track)
            
            for fx_idx = 0, cnt - 1 do
                local _, name = reaper.TrackFX_GetFXName(track, fx_idx, "")
                
                if name:lower():find("striplink") and not name:lower():find("aggregator") then
                    local guid = reaper.TrackFX_GetFXGUID(track, fx_idx)
                    
                    -- =======================================================
                    -- DETEKCIJA KLONOV
                    -- =======================================================
                    if seen_guids[guid] then
                        if not warned_clones[guid] then
                            warned_clones[guid] = true
                            trigger_clone_warning = true
                        end
                    else
                        seen_guids[guid] = true
                        
                        local slot = GetFXSlot(track)
                        
                        if slot > 0 then
                                                    
                            local is_brand_new = true
                            local just_moved_slot = false
                            local old_layout_pushed = nil
                            local old_last_page = nil
                            
                            for _, old_fx in ipairs(active_plugins) do
                                if old_fx.guid == guid then 
                                    is_brand_new = false
                                    if old_fx.slot ~= slot then just_moved_slot = true end
                                    old_layout_pushed = old_fx.layout_pushed
                                    old_last_page = old_fx.last_page
                                    break 
                                end
                            end

                            local guid_hash = CRC32(guid) % 10000000
                            local slot_base = PROJECT_BASE + slot * 500
                            local prev_hash = reaper.gmem_read(slot_base + 497)
                            
                            local _, fx_name_str = reaper.TrackFX_GetFXName(track, fx_idx, "")
                            local sec_param_idx = 2 -- Vsi vtičniki imajo sedaj Hash na slider3 (indeks 2)
                            
                            local current_hash = 0
                            local has_sec_slider = reaper.TrackFX_GetNumParams(track, fx_idx) > sec_param_idx
                            if has_sec_slider then
                                current_hash = reaper.TrackFX_GetParam(track, fx_idx, sec_param_idx)
                            end

                            if is_brand_new then
                                if has_sec_slider and current_hash ~= guid_hash then 
                                    reaper.TrackFX_SetParam(track, fx_idx, sec_param_idx, guid_hash) 
                                end
                                
                                -- SAFE GMEM DELETION (Z IZOLACIJO ZA MODULE)
                                local is_module_plugin = fx_name_str:lower():find("module") ~= nil
                                local sync_state = reaper.gmem_read(slot_base + 498)
                                
                                if sync_state == 1 then
                                    for b = 0, 289 do reaper.gmem_write(slot_base + b, 0) end
                                else
                                    if is_module_plugin then
                                        local p_h = reaper.gmem_read(slot_base + 426)
                                        for b = 0, 495 do reaper.gmem_write(slot_base + b, 0) end
                                        reaper.gmem_write(slot_base + 426, p_h)
                                    else
                                        for b = 0, 496 do reaper.gmem_write(slot_base + b, 0) end
                                    end
                                end
                                
                                reaper.gmem_write(slot_base + 497, -1)
                                fx_just_moved_flags[guid] = true
                                
                            elseif just_moved_slot then
                                mapping_cache[slot] = nil
                                color_cache[slot] = nil
                                group_cache[slot] = nil
                                unit_cache[slot] = nil
                                steps_cache[slot] = nil
                                
                                reaper.gmem_write(slot_base + 497, -1)
                                fx_just_moved_flags[guid] = true
                                InvalidateSlotOutbox(slot)
                            else
                                if has_sec_slider and current_hash ~= guid_hash then 
                                    reaper.TrackFX_SetParam(track, fx_idx, sec_param_idx, guid_hash) 
                                end
                                if prev_hash ~= guid_hash then 
                                    reaper.gmem_write(slot_base + 497, -1) 
                                end
                            end

                            if is_brand_new then
                                mapping_cache[slot] = nil
                                color_cache[slot] = nil
                                group_cache[slot] = nil
                                unit_cache[slot] = nil
                                steps_cache[slot] = nil

                                local _, saved_ag_pwr = reaper.GetProjExtState(0, NS, "AG_PWR_" .. guid)
                                if saved_ag_pwr ~= "" then reaper.gmem_write(PROJECT_BASE + slot * 500 + 78, tonumber(saved_ag_pwr) or 0) end
                                
                                local _, saved_ag_lock = reaper.GetProjExtState(0, NS, "AG_LOCK_" .. guid)
                                if saved_ag_lock ~= "" then reaper.gmem_write(PROJECT_BASE + slot * 500 + 79, tonumber(saved_ag_lock) or 0) end
                                
                                local _, saved_ag_math = reaper.GetProjExtState(0, NS, "AG_MATH_" .. guid)
                                if saved_ag_math ~= "" then reaper.gmem_write(PROJECT_BASE + slot * 500 + 339, tonumber(saved_ag_math) or 0) end

                                local _, saved_local_page = reaper.GetProjExtState(0, NS, "LOCAL_TAB_" .. guid)
                                if saved_local_page ~= "" then reaper.gmem_write(PROJECT_BASE + slot * 500 + 290, tonumber(saved_local_page) or 0) end
                                
                                -- NEW: AGGRESSIVE ORPHAN CLEANUP
                                if not HasAnyLinks(guid) then
                                    local sb = PROJECT_BASE + slot * 500
                                    for b = 0, 64 do
                                        -- Wipe GMEM
                                        reaper.gmem_write(sb + 11 + b, 0)
                                        reaper.gmem_write(sb + 80 + b, 0)
                                        reaper.gmem_write(sb + 150 + b, 13)
                                        reaper.gmem_write(sb + 220 + b, 0)
                                        reaper.gmem_write(PROJECT_BASE + 60000 + (slot * 100) + b, 0)
                                        
                                        -- Wipe ExtState to prevent ghost values
                                        reaper.SetProjExtState(0, NS, guid .. ":" .. b, "")
                                        reaper.SetProjExtState(0, NS, "COLOR:" .. guid .. ":" .. b, "")
                                        reaper.SetProjExtState(0, NS, "UNIT:" .. guid .. ":" .. b, "")
                                        reaper.SetProjExtState(0, NS, "STEPS:" .. guid .. ":" .. b, "")
                                        reaper.SetProjExtState(0, NS, "GROUP:" .. guid .. ":" .. b, "")
                                    end
                                end
                                
                                -- POPOLN RESET STAREGA LAYOUTA ZA NOV VTIČNIK
                                user_layouts[slot] = nil 
                                reaper.gmem_write(PROJECT_BASE + 500000 + (slot * 3000) - 1, 0)
                            end
                            
                            table.insert(found_plugins, {
                                tr = track, 
                                idx = fx_idx, 
                                guid = guid, 
                                slot = slot,
                                layout_pushed = old_layout_pushed,
                                last_page = old_last_page
                            })
                        end
                    end
                    break
                end
            end
        end
        
        active_plugins = found_plugins

        -- =======================================================
        -- OPOZORILO UPORABNIKU
        -- =======================================================
        if trigger_clone_warning then
            table.insert(pending_os_tasks, function()
                local msg = "StripLink has detected a duplicated FX GUID!\n\n" ..
                            "To ensure database safety and prevent parameter 'mirroring', this clone has been isolated. It is highly recommended that you manually DELETE THIS STRIPLINK INSTANCE.\n\n" ..
                            "Note: If this occurred because you used REAPER's 'Default FX chain for new tracks' feature, you must DELETE THE ENTIRE FX CHAIN. That feature copies identifiers for all plugins, which will break the routing architecture. Please use 'Track Templates' or standard 'FX Chains' instead."
                reaper.MB(msg, "StripLink: Database Safety Protection", 0)
            end)
        end
        -- =======================================================
    end
    
    local selected_track = reaper.GetSelectedTrack(0, 0)
    local active_slot = 0

    if active_plugins then
        for _, fx in ipairs(active_plugins) do
            if reaper.ValidatePtr(fx.tr, "MediaTrack*") then
                local live_slot = GetFXSlot(fx.tr)
                local just_moved = fx_just_moved_flags[fx.guid] or false
                                
                if live_slot > 0 then
                    if live_slot ~= fx.slot then 
                        mapping_cache[live_slot] = nil
                        color_cache[live_slot] = nil
                        group_cache[live_slot] = nil
                        unit_cache[live_slot] = nil
                        steps_cache[live_slot] = nil
                        
                        local slot_base = PROJECT_BASE + live_slot * 500
                        local guid_hash = CRC32(fx.guid) % 10000000
                        
                        if reaper.gmem_read(slot_base + 497) ~= guid_hash then
                            local _, current_fx_name = reaper.TrackFX_GetFXName(fx.tr, fx.idx, "")
                            local is_module_plugin = current_fx_name:lower():find("module") ~= nil
                            
                            if is_module_plugin then
                                local p_h = reaper.gmem_read(slot_base + 426)
                                for b = 0, 495 do reaper.gmem_write(slot_base + b, 0) end
                                reaper.gmem_write(slot_base + 426, p_h)
                            else
                                for b = 0, 496 do reaper.gmem_write(slot_base + b, 0) end
                            end
                            reaper.gmem_write(slot_base + 497, guid_hash)
                        end
                        
                        fx.slot = live_slot 
                        just_moved = true
                        InvalidateSlotOutbox(live_slot)
                        fx.layout_pushed = false
                    end

                    local ext_key_tab = "LOCAL_TAB_" .. fx.guid
                    if just_moved then
                        local _, saved_tab = reaper.GetProjExtState(0, NS, ext_key_tab)
                        if saved_tab ~= "" then
                            reaper.gmem_write(PROJECT_BASE + fx.slot * 500 + 290, tonumber(saved_tab))
                        end
                    end
                    
                    --Vzpostavitev grup in stepsov ob premiku tracka (Reordering)
                    if just_moved then
                        local new_base = PROJECT_BASE + fx.slot * 500
                        for i = 0, 64 do
                            -- 1. Obnova grup
                            local g_key = "GROUP:" .. fx.guid .. ":" .. i
                            local _, g_val = reaper.GetProjExtState(0, NS, g_key)
                            local final_grp = tonumber(g_val) or 0
                            reaper.gmem_write(new_base + 360 + i, final_grp)
                            
                            if not group_cache[fx.slot] then group_cache[fx.slot] = {} end
                            group_cache[fx.slot][i] = final_grp

                            -- 2. Obnova stepsov (za Selectorje)
                            local s_key = "STEPS:" .. fx.guid .. ":" .. i
                            local _, s_val = reaper.GetProjExtState(0, NS, s_key)
                            local final_steps = tonumber(s_val) or 0
                            reaper.gmem_write(PROJECT_BASE + 60000 + (fx.slot * 100) + i, final_steps)
                            
                            if not steps_cache[fx.slot] then steps_cache[fx.slot] = {} end
                            steps_cache[fx.slot][i] = final_steps
                        end
                    end
                    local base = PROJECT_BASE + fx.slot * 500
                    
                    if reaper.gmem_read(base + 496) == 1 then
                        reaper.gmem_write(base + 496, 0)
                        PushUILayout(fx.slot)
                    end
                    local sync_state = reaper.gmem_read(base + 498)
                    
                    if sync_state == 1 then
                        if not HasAnyLinks(fx.guid) then
                            RestorePluginStructure(fx.tr, fx.idx, fx.slot)
                            local cur_page = reaper.gmem_read(base + 290)
                            if cur_page == 0 then cur_page = 1 end
                            PullUILayout(fx.slot, cur_page)
                        end
                        reaper.gmem_write(base + 498, 0)
                        
                    elseif sync_state == 2 then
                        if not HasAnyLinks(fx.guid) then
                            AutoLoadNewPlugin(fx.tr, fx.idx)
                        end
                        
                        -- LUA SE VMEŠA IZKLJUČNO TAKRAT, KO JE SERIALIZE PRAZEN!
                        PushUILayout(fx.slot)
                        fx.layout_pushed = true
                        
                        reaper.gmem_write(base + 498, 0)
                    end

                    local is_selected = (fx.tr == selected_track)
                    if is_selected then active_slot = fx.slot end
                    
                    local poll_this_fx = force_refresh or (is_selected and should_poll_fast) or (not is_selected and should_poll_slow)
                    
                    mapping_cache[fx.slot] = mapping_cache[fx.slot] or {}
                    color_cache[fx.slot]   = color_cache[fx.slot]   or {}
                    group_cache[fx.slot]   = group_cache[fx.slot]   or {}
                    steps_cache[fx.slot]   = steps_cache[fx.slot]   or {}

                    if poll_this_fx then
                        for i = 0, 64 do
                            local key = fx.guid .. ":" .. i
                            local _, param_val = reaper.GetProjExtState(0, NS, key)
                            local param_val_changed = false
                            
                            if param_val ~= "" then
                                if mapping_cache[fx.slot][i] ~= param_val or not (mapping_cache[fx.slot].encoded_name and mapping_cache[fx.slot].encoded_name[i]) then
                                    mapping_cache[fx.slot][i] = param_val
                                    param_val_changed = true
                                    local parts = safe_split(param_val)
                                    local p_name = parts[5] or ""
                                    if not mapping_cache[fx.slot].encoded_name then mapping_cache[fx.slot].encoded_name = {} end
                                    mapping_cache[fx.slot].encoded_name[i] = encode_param_name_to_number(p_name)
                                end
                            else
                                if mapping_cache[fx.slot][i] ~= nil then param_val_changed = true end
                                mapping_cache[fx.slot][i] = nil
                            end
    
                            if force_refresh or param_val_changed or color_cache[fx.slot][i] == nil then
                                local _, col = reaper.GetProjExtState(0, NS, "COLOR:" .. fx.guid .. ":" .. i)
                                color_cache[fx.slot][i] = tonumber(col) or 13
                                
                                local gmem_grp = reaper.gmem_read(PROJECT_BASE + fx.slot * 500 + 360 + i)
                                local _, grp = reaper.GetProjExtState(0, NS, "GROUP:" .. fx.guid .. ":" .. i)
                                
                                if grp == "" and gmem_grp > 0 then
                                    reaper.SetProjExtState(0, NS, "GROUP:" .. fx.guid .. ":" .. i, tostring(gmem_grp))
                                    grp = tostring(gmem_grp)
                                end
                                
                                local final_grp = tonumber(grp) or gmem_grp
                                group_cache[fx.slot][i] = final_grp
                                reaper.gmem_write(PROJECT_BASE + fx.slot * 500 + 360 + i, final_grp)
        
                                local _, stp = reaper.GetProjExtState(0, NS, "STEPS:" .. fx.guid .. ":" .. i)
                                local final_steps = tonumber(stp) or 0
                                steps_cache[fx.slot][i] = final_steps
                                
                                local _, uni = reaper.GetProjExtState(0, NS, "UNIT:" .. fx.guid .. ":" .. i)
                                if uni == "" and param_val ~= "" then
                                    local p_parts = safe_split(param_val)
                                    local p_name = p_parts[5] or ""
                                    if not unit_cache[fx.slot] then unit_cache[fx.slot] = {} end
                                    unit_cache[fx.slot][i] = get_unit_id(p_name)
                                else
                                    if not unit_cache[fx.slot] then unit_cache[fx.slot] = {} end
                                    unit_cache[fx.slot][i] = tonumber(uni) or 0
                                end
                                reaper.gmem_write(PROJECT_BASE + 60000 + (fx.slot * 100) + i, final_steps)
                            end
                        end
                        
                        -- CISTKA OVR ZANKE V LUI - OVR PODATKI SE NE BEREJO IZ EXTSTATE-A
                        local _, vu_mode_str = reaper.GetProjExtState(0, NS, "VU_MODE_" .. fx.guid)
                        local vu_mode = tonumber(vu_mode_str) or 0
                        reaper.gmem_write(PROJECT_BASE + fx.slot * 500 + 336, vu_mode)

                        local _, ag_spd_str = reaper.GetProjExtState(0, NS, "AG_SPEED_" .. fx.guid)
                        local spd_factor = tonumber(ag_spd_str) or 1.00
                        reaper.gmem_write(PROJECT_BASE + fx.slot * 500 + 337, spd_factor)

                        local is_dirty = false

                        local cur_ag_pwr = math.floor(reaper.gmem_read(PROJECT_BASE + fx.slot * 500 + 78) + 0.5)
                        local _, saved_ag_pwr = reaper.GetProjExtState(0, NS, "AG_PWR_" .. fx.guid)
                        if saved_ag_pwr == "" or (tonumber(saved_ag_pwr) or -1) ~= cur_ag_pwr then
                            reaper.SetProjExtState(0, NS, "AG_PWR_" .. fx.guid, tostring(cur_ag_pwr))
                            is_dirty = true
                        end

                        local cur_ag_lock = math.floor(reaper.gmem_read(PROJECT_BASE + fx.slot * 500 + 79) + 0.5)
                        local _, saved_ag_lock = reaper.GetProjExtState(0, NS, "AG_LOCK_" .. fx.guid)
                        if saved_ag_lock == "" or (tonumber(saved_ag_lock) or -1) ~= cur_ag_lock then
                            reaper.SetProjExtState(0, NS, "AG_LOCK_" .. fx.guid, tostring(cur_ag_lock))
                            is_dirty = true
                        end

                        local cur_ag_math = reaper.gmem_read(PROJECT_BASE + fx.slot * 500 + 338)
                        local _, saved_ag_math = reaper.GetProjExtState(0, NS, "AG_MATH_" .. fx.guid)
                        if cur_ag_math > 0 and (saved_ag_math == "" or math.abs(tonumber(saved_ag_math) - cur_ag_math) > 0.001) then
                            reaper.SetProjExtState(0, NS, "AG_MATH_" .. fx.guid, tostring(cur_ag_math))
                            is_dirty = true
                        end

                        local cur_local_page = reaper.gmem_read(PROJECT_BASE + fx.slot * 500 + 290)
                         
                        if not fx.last_page then
                            fx.last_page = cur_local_page
                        end
                        
                        if not fx.layout_pushed or just_moved then
                            local outbox = PROJECT_BASE + 500000 + (fx.slot * 3000)
                            local existing_count = math.floor(reaper.gmem_read(outbox - 1))
                            
                            if existing_count > 0 then
                                RebuildLayoutFromJSFX(fx.slot)
                                fx.layout_pushed = true
                            end
                        end
                        if fx.layout_pushed and not just_moved then
                              local sb      = PROJECT_BASE + fx.slot * 500
                              local mailbox = PROJECT_BASE + 200000 + (fx.slot * 3000)
                              local lay     = user_layouts[fx.slot]
                              local pending = reaper.gmem_read(mailbox) == 1
                                           or reaper.gmem_read(sb + 496) == 1
                                           or reaper.gmem_read(sb + 427) == 1
                              local ob_count = math.floor(reaper.gmem_read(PROJECT_BASE + 500000 + fx.slot * 3000 - 1) + 0.5)
                              
                              if lay and not pending and ob_count > 0 and not LayoutMatchesOutbox(fx.slot, lay) then
                                  fx.desync_n = (fx.desync_n or 0) + 1
                                  if fx.desync_n == 1 then
                                      reaper.gmem_write(sb + 427, 1) 
                                  elseif fx.desync_n >= 3 then
                                      RebuildLayoutFromJSFX(fx.slot) 
                                      fx.desync_n = 0
                                  end
                              else
                                  fx.desync_n = 0
                              end
                          end
                        if fx.last_page ~= cur_local_page then
                            PullUILayout(fx.slot, fx.last_page)
                            fx.last_page = cur_local_page
                        end

                        if is_dirty then reaper.MarkProjectDirty(0) end
                    end           
                    
                    local global_meter_mode = reaper.gmem_read(PROJECT_BASE + 202)
                    
                    if is_selected or global_meter_mode == 1 then
                        local function FindFXByGUID(tr, target_guid, p_idx)
                            local count = p_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(tr, p_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(tr)
                            for j = 0, (count or 0) - 1 do
                                local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, p_idx or -1, "container_item." .. j)
                                local current_idx = p_idx and tonumber(child_id_str) or j
                                if current_idx then
                                    if reaper.TrackFX_GetFXGUID(tr, current_idx) == target_guid then return current_idx end
                                    local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, current_idx, "container_count")
                                    if is_c ~= "" then
                                        local res = FindFXByGUID(tr, target_guid, current_idx)
                                        if res then return res end
                                    end
                                end
                            end
                            return nil
                        end
                        
                            local function ReadGRFromTarget(meter_type, gmem_addr, pdc_addr, id_addr)
                            local ext_key = "METER_SRC_" .. fx.guid .. "_" .. meter_type
                            local _, src_guid = reaper.GetProjExtState(0, NS, ext_key)
                            
                            if src_guid and src_guid ~= "" then
                                local target_fx_idx = FindFXByGUID(fx.tr, src_guid, nil)
                                
                                if target_fx_idx then
                                    -- Zapiši indeks FX vtičnika (premik za 1, da 0 pomeni prazno)
                                    reaper.gmem_write(id_addr, target_fx_idx + 1)

                                    local ok_pdc, pdc_str = reaper.TrackFX_GetNamedConfigParm(fx.tr, target_fx_idx, "pdc")
                                    local pdc_val = ok_pdc and tonumber(pdc_str) or 0
                                    reaper.gmem_write(pdc_addr, pdc_val)
                                    
                                    local ok, gr_str = reaper.TrackFX_GetNamedConfigParm(fx.tr, target_fx_idx, "GainReduction_dB")
                                    
                                    if ok then
                                        local play_state = reaper.GetPlayState()
                                        if play_state > 0 then
                                            local gr_val = math.abs(tonumber(gr_str) or 0)
                                            reaper.gmem_write(gmem_addr, gr_val + 1.0)
                                        else
                                            reaper.gmem_write(gmem_addr, 1.0)
                                        end
                                    else
                                        reaper.gmem_write(gmem_addr, 0.0)
                                    end
                                    return 
                                end
                            end
                            reaper.gmem_write(id_addr, 0)
                            reaper.gmem_write(gmem_addr, 0.0)
                            reaper.gmem_write(pdc_addr, 0)
                        end
                                                                        
                        local base_addr = PROJECT_BASE + fx.slot * 500
                        -- Pošljemo še dodatna naslova za identifikacijo (340 za M1, 341 za M2)
                        ReadGRFromTarget(1, base_addr + 330, base_addr + 332, base_addr + 340)
                        ReadGRFromTarget(2, base_addr + 331, base_addr + 333, base_addr + 341)
                    end

                    local base = PROJECT_BASE + fx.slot * 500
                    local active_lock = reaper.gmem_read(base + 1)
                    
                    if active_lock > 0 or poll_this_fx or just_moved then
                        UpdateLink(fx.slot, fx.guid, poll_this_fx or just_moved, fx.tr, fx.idx, just_moved)
                    end

                    local target_guid_hash = CRC32(fx.guid) % 10000000
                    if reaper.gmem_read(base + 497) ~= target_guid_hash then
                        reaper.gmem_write(base + 497, target_guid_hash)
                    end
                end 
            end 
        end
    end

    reaper.gmem_write(PROJECT_BASE + 8, active_slot)
end

local last_trigger_val = -1
local last_sel_trig = -1 

-- =========================================================================
-- REAIMGUI CONTEXT & STATE (Declared before Main to fix scope)
-- =========================================================================
local ctx = reaper.ImGui_CreateContext('StripLink')

-- Pomožna funkcija za varno nalaganje ikon iz mape Icons (Cross-platform)
local sep = package.config:sub(1, 1)
local function LoadSafeIcon(filename)
    local path = (script_path .. "Icons" .. sep .. filename):gsub("[\\/]+", sep)
    local f = io.open(path, "r")
    if f then 
        f:close()
        local img = reaper.ImGui_CreateImage(path)
        reaper.ImGui_Attach(ctx, img)
        return img
    end
    return nil
end

-- Naložimo vse 4 ikone
local icon_remove = LoadSafeIcon("Remove_1.png")
local icon_knob = LoadSafeIcon("Knob_1.png")
local icon_switch = LoadSafeIcon("Switch_1.png")
local icon_tube= LoadSafeIcon("Tube_1.png")
local icon_text = LoadSafeIcon("Text_1.png")
local icon_meter = LoadSafeIcon("Meter_1.png")
local icon_selector = LoadSafeIcon("Selector_1.png")

-- =========================================================================
-- FONT SETUP (Linked to global ExtState)
-- =========================================================================
local ext_font_val = reaper.GetExtState(NS, "GLOBAL_FONT_SIZE")
local global_font_size = tonumber(ext_font_val) or 14
local current_imgui_font = reaper.ImGui_CreateFont('Calibri', global_font_size)
reaper.ImGui_Attach(ctx, current_imgui_font)

local popup_state = {
    active_cmd = 0,
    request_open = false,
    mouse_x = 0,
    mouse_y = 0,
    data = {}
}


builder_state = { 
    open = false,
    target_sec = 1 -- 1 = Top (DYN1/PRE), 2 = Bottom (DYN2/POST)
}

function Main()
    PROJECT_BASE = 3000000 + (GetProjectIndex() * 1000000)
    
    reaper.gmem_write(100000, PROJECT_BASE)

    -- === 1. CHECK SELECTION TRIGGER (Ctrl-klik) ===
    local sel_trig = tonumber(reaper.gmem_read(PROJECT_BASE + 11))
    
    if sel_trig ~= last_sel_trig then
        last_sel_trig = sel_trig
        
        if sel_trig > 0 then
            -- FORCE INSTANT POLL ON TRACK SELECTION
            last_poll_fast = 0
            last_poll_slow = 0
            local tr_idx = math.floor(reaper.gmem_read(PROJECT_BASE + 10)) - 1 -- slider2 is 1-based, hence -1
            local fx_idx = math.floor(reaper.gmem_read(PROJECT_BASE + 13)) -- f is 0-based
            local mod_val = math.floor(reaper.gmem_read(PROJECT_BASE + 12))
            
            -- JSFX sends '5' explixitly if CTRL is pressed
            local is_ctrl = (mod_val == 5)

            local tr = nil
            if tr_idx == -1 then 
                tr = reaper.GetMasterTrack(0)
            elseif tr_idx >= 0 then
                tr = reaper.GetTrack(0, tr_idx)
            end
            
            local is_valid = false
            
            if tr and fx_idx >= 0 then
                local _, fx_name = reaper.TrackFX_GetFXName(tr, fx_idx, "")
                if fx_name:lower():find("striplink") then
                    is_valid = true
                end
            end
            
            if is_valid then
                local tr_guid = reaper.GetTrackGUID(tr)
                local tr_count = reaper.CountTracks(0)

                reaper.PreventUIRefresh(1)

                if not is_ctrl then
                    manual_selection_list = {}
                    manual_selection_list[tr_guid] = true
                else
                    if not manual_selection_list then manual_selection_list = {} end
                    if next(manual_selection_list) == nil then
                        for i = 0, tr_count - 1 do
                            local t = reaper.GetTrack(0, i)
                            if reaper.IsTrackSelected(t) then
                                manual_selection_list[reaper.GetTrackGUID(t)] = true
                            end
                        end
                    end
                    if manual_selection_list[tr_guid] then
                        manual_selection_list[tr_guid] = nil
                    else
                        manual_selection_list[tr_guid] = true
                    end
                end

                for i = 0, tr_count - 1 do
                    local t = reaper.GetTrack(0, i)
                    local g = reaper.GetTrackGUID(t)
                    local should_be_active = (manual_selection_list[g] == true)
                    
                    if reaper.IsTrackSelected(t) ~= should_be_active then
                       reaper.SetTrackSelected(t, should_be_active)
                    end
                    
                    local val = should_be_active and 1 or 0
                    local slot_addr = PROJECT_BASE + (i + 1) * 500 + 9
                    reaper.gmem_write(slot_addr, val)
                end
                
                if not is_ctrl then
                   --reaper.SetMixerScroll(tr)
                   --reaper.Main_OnCommand(40914, 0) 
                end

                reaper.PreventUIRefresh(-1)
                reaper.UpdateArrange()
            end
        end
    end
    
    -- === MENUS & CONTROLS ===
    local current_trigger_val = reaper.gmem_read(PROJECT_BASE + 0)
    if current_trigger_val ~= last_trigger_val then
        last_trigger_val = current_trigger_val
        
        -- FORCE INSTANT POLL AFTER CLICK
        last_poll_fast = 0
        last_poll_slow = 0
        
        local tr_idx = math.floor(reaper.gmem_read(PROJECT_BASE + 4)) - 1
        local f_idx = math.floor(reaper.gmem_read(PROJECT_BASE + 6))
        local btn_idx = math.floor(reaper.gmem_read(PROJECT_BASE + 5))
        local cmd = math.floor(reaper.gmem_read(PROJECT_BASE + 7))

        local tr = nil
        if tr_idx == -1 then 
            tr = reaper.GetMasterTrack(0)
        elseif tr_idx >= 0 then
            tr = reaper.GetTrack(0, tr_idx)
        end
        
        local is_valid = false
        
        if tr and f_idx >= 0 then
            local _, fx_name = reaper.TrackFX_GetFXName(tr, f_idx, "")
            if fx_name:lower():find("striplink") then
                is_valid = true
            end
        end

        if is_valid then
            local c_guid = reaper.TrackFX_GetFXGUID(tr, f_idx)
            --local sl = math.floor(reaper.TrackFX_GetParam(tr, f_idx, 1) + 0.5)
            local sl = GetFXSlot(tr)

            if sl > 0 then
                if cmd == 1 then
                    local menu, map = BuildMenu(tr, c_guid, btn_idx - 1)
                    local nx, ny = reaper.GetMousePosition()
                    local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                    
                    popup_state.active_cmd = 1
                    popup_state.request_open = true
                    popup_state.mouse_x, popup_state.mouse_y = mx, my
                    popup_state.data = {
                        menu_str = menu,
                        map = map,
                        c_guid = c_guid,
                        btn_idx = btn_idx,
                        sl = sl,
                        tr = tr
                    }
                    -- Clear command slot. Actual execution happens asynchronously in DrawMenus().
                    reaper.gmem_write(PROJECT_BASE + 7, 0)

                elseif cmd == 2 then 
                    local color_key = "COLOR:" .. c_guid .. ":" .. key_from_btn(btn_idx)
                    local _, cur_c = reaper.GetProjExtState(0, NS, color_key)
                    local cur_type = tonumber(cur_c) or 13
                    
                    local jsfx_name = GetBaseJSFXName(tr, f_idx)
                    local is_module = jsfx_name:lower():find("module") ~= nil
                    
                    -- Klic centralne funkcije
                    local el_type = GetElementType(btn_idx, jsfx_name, sl)
                    local is_tube = (el_type == 3)
                    local is_switch = (el_type == 2)
        
                    local menu_table = {}
                    local color_map = {}
                    local map_idx = 1
                    
                    if is_tube then
                        local tube_opts = {"Green", "Blue", "Red", "Yellow", "White", "Grey"}
                        for i, opt in ipairs(tube_opts) do 
                            local target_val = (i - 1) * 3 + 1
                            local is_selected = (cur_type >= target_val and cur_type <= target_val + 2)
                            table.insert(menu_table, (is_selected and "✓ " or "") .. opt) 
                        end
                    elseif is_switch and is_module then
                        local switch_opts = {"Toggle Switch 1", "Toggle Switch 2", "Toggle Switch 3", "Toggle Switch 4", "Toggle Switch 5", "Toggle Switch 6", "Toggle Switch 7", "Toggle Switch 8", "Toggle Switch 9"}
                        for i, opt in ipairs(switch_opts) do
                            local is_selected = (cur_type == i) or (cur_type > 9 and i == 1) 
                            table.insert(menu_table, (is_selected and "✓ " or "") .. opt)
                            color_map[map_idx] = i; map_idx = map_idx + 1
                        end
                    else
                        -- 1. Preberi trenutno naloženo temo
                        local safe_theme_name = jsfx_name:gsub("%s+", "_")
                        local current_theme = reaper.GetExtState(NS, "THEME_" .. safe_theme_name)
                        if current_theme == "" then current_theme = "Default" end
                        
                        -- 2. Privzeta imena (standard)
                        local default_opts = {
                            "Green-Positive","Green-Neutral","Green-Negative",
                            "Blue-Positive","Blue-Neutral","Blue-Negative",
                            "Red-Positive","Red-Neutral","Red-Negative",
                            "Yellow-Positive","Yellow-Neutral","Yellow-Negative",
                            "White-Positive","White-Neutral","White-Negative",
                            "Black-Positive","Black-Neutral","Black-Negative"
                        }
                        
                        -- 3. Ustvari ločena seznama za Type 1 in Type 2
                        local opts_type1 = default_opts
                        local opts_type2 = default_opts -- Type 2 je privzeto standarden
                        
                        -- 4. Če je tema Analog Console, prepiši vsebino za Type 1 in Type 2
                        if current_theme:find("Analog Console", 1, true) ~= nil then
                            opts_type1 = {
                                "Green SSL", "Green API", "Green Neve",
                                "Blue SSL", "Blue API", "Blue Neve",
                                "Red SSL", "Red API", "Red Neve",
                                "Yellow SSL", "Yellow API", "Yellow Neve",
                                "White SSL", "White API", "White Neve",
                                "Black SSL", "Black API", "Black Neve"
                            }
                            opts_type2 = {
                                "SSL Green-Positive", "SSL Green-Neutral", "SSL Green-Negative",
                                "SSL Blue-Positive", "SSL Blue-Neutral", "SSL Blue-Negative",
                                "SSL Red-Positive", "SSL Red-Neutral", "SSL Red-Negative",
                                "SSL Yellow-Positive", "SSL Yellow-Neutral", "SSL Yellow-Negative",
                                "SSL White-Positive", "SSL White-Neutral", "SSL White-Negative",
                                "SSL Black-Positive", "SSL Black-Neutral", "SSL Black-Negative"
                            }
                        end
                        
                        if is_module then
                            -- Knob Type 1 (Uporabi opts_type1)
                            table.insert(menu_table, ">Knob Type 1")
                            for i, opt in ipairs(opts_type1) do 
                                table.insert(menu_table, (cur_type == i and "✓ " or "") .. opt) 
                                color_map[map_idx] = i; map_idx = map_idx + 1
                            end
                            table.insert(menu_table, "<")
                            
                            -- Knob Type 2 (Uporabi opts_type2)
                            table.insert(menu_table, ">Knob Type 2")
                            for i, opt in ipairs(opts_type2) do 
                                local val = i + 18
                                table.insert(menu_table, (cur_type == val and "✓ " or "") .. opt) 
                                color_map[map_idx] = val; map_idx = map_idx + 1
                            end
                            table.insert(menu_table, "<")
                            
                            -- Knob Type 3 in 4 (Ostanejo enaki)
                            table.insert(menu_table, (cur_type == 37 and "✓ " or "") .. "Knob Type 3")
                            color_map[map_idx] = 37; map_idx = map_idx + 1
                            
                            table.insert(menu_table, (cur_type == 55 and "✓ " or "") .. "Knob Type 4")
                            color_map[map_idx] = 55; map_idx = map_idx + 1
                        else
                            -- STATIC FXs (UC1, BUS): use name Type 1
                            for i, opt in ipairs(opts_type1) do 
                                table.insert(menu_table, (cur_type == i and "✓ " or "") .. opt) 
                            end
                        end
                    end
                    
                    local nx, ny = reaper.GetMousePosition()
                    local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                    
                    popup_state.active_cmd = 2
                    popup_state.request_open = true
                    popup_state.mouse_x, popup_state.mouse_y = mx, my
                    popup_state.data = {
                        menu_str = table.concat(menu_table, "|"),
                        color_map = (is_module or is_switch) and color_map or nil,
                        c_guid = c_guid,
                        btn_idx = btn_idx,
                        sl = sl,
                        is_tube = is_tube,
                        is_switch = is_switch,
                        is_module = is_module
                    }
                    
                    reaper.gmem_write(PROJECT_BASE + 7, 0)


                elseif cmd == 3 then
                    if btn_idx == 99 then
                        -- ==========================================
                        -- LOCAL & GLOBAL SETTINGS (Button 99)
                        -- ==========================================
                        
                        -- LOCAL SETTINGS
                        local cur_hash = reaper.TrackFX_GetParam(tr, f_idx, 0)
                        local instance_name = "default"
                        if cur_hash > 0 then
                            local _, saved_name = reaper.GetProjExtState(0, NS, "INSTANCE_NAME_" .. c_guid)
                            if saved_name and saved_name ~= "" then instance_name = saved_name end
                        end
                        
                        -- Preberemo, ali je Layout Builder vklopljen za ta vtičnik (naslov 428)
                        local cur_builder_mode = reaper.gmem_read(PROJECT_BASE + sl * 500 + 428)
                        local is_builder_active = (cur_builder_mode == 1)

                        local _, vu_mode_str = reaper.GetProjExtState(0, NS, "VU_MODE_" .. c_guid)
                        local vu_mode = tonumber(vu_mode_str) or 0

                        -- AUTO GAIN SPEED 
                        local _, ag_speed_str = reaper.GetProjExtState(0, NS, "AG_SPEED_" .. c_guid)
                        local ag_speed_mode = tonumber(ag_speed_str) or 1.0

                        -- GLOBAL SETTINGS
                        local ext_state_val = reaper.GetExtState(NS, "USER_KNOB_TOOLTIPS")
                        local tooltips_on = (ext_state_val ~= "0")
                        
                        -- VU CALIBRATION
                        local current_vu_ref = reaper.TrackFX_GetParam(tr, f_idx, 68)
                        local is_custom_vu = (current_vu_ref ~= 0 and current_vu_ref ~= -6 and current_vu_ref ~= -12 and current_vu_ref ~= -18)
                        local custom_vu_label = is_custom_vu and string.format("Custom... (%d dBFS)", current_vu_ref) or "Custom..."
                        
                        -- GR METER RANGE
                        local ext_gr_val = reaper.GetExtState(NS, "GLOBAL_MAX_GR_DB")
                        local current_gr = tonumber(ext_gr_val) or 12
                        local is_custom_gr = (current_gr ~= 6 and current_gr ~= 12 and current_gr ~= 18 and current_gr ~= 24)
                        local custom_gr_label = is_custom_gr and string.format("Custom... (%d dB)", current_gr) or "Custom..."
                        
                        -- PEAK THRESHOLD
                        local ext_peak_th = reaper.GetExtState(NS, "GLOBAL_PEAK_THRESH")
                        local current_peak_th = tonumber(ext_peak_th) or 0
                        local is_custom_peak = (current_peak_th ~= 0 and current_peak_th ~= -1 and current_peak_th ~= -3 and current_peak_th ~= -6)
                        local custom_peak_label = is_custom_peak and string.format("Custom... (%.1f dBFS)", current_peak_th) or "Custom..."
                        
                        local ext_font_val = reaper.GetExtState(NS, "GLOBAL_FONT_SIZE")
                        local current_font = tonumber(ext_font_val) or 14
                        
                        -- Mouse control
                        local ext_mouse_std = reaper.GetExtState(NS, "GLOBAL_MOUSE_STD")
                        local mouse_std = tonumber(ext_mouse_std) or 1.0
                        local ext_mouse_fine = reaper.GetExtState(NS, "GLOBAL_MOUSE_FINE")
                        local mouse_fine = tonumber(ext_mouse_fine) or 0.1
                        
                        local _, saved_meter_mode = reaper.GetProjExtState(0, NS, "GLOBAL_METER_MODE")
                        local current_meter_mode = tonumber(saved_meter_mode) or 0
                        
                        local ext_vu_style = reaper.GetExtState(NS, "GLOBAL_VU_STYLE")
                        local current_vu_style = tonumber(ext_vu_style) or 0
                        
                        -- SCAN THEMES & MODULE CHECK
                        local jsfx_name = GetBaseJSFXName(tr, f_idx)
                        local is_module = jsfx_name:lower():find("module") ~= nil
                        local available_themes = GetAvailableThemes(jsfx_name)
                        local safe_theme_name = jsfx_name:gsub("%s+", "_")
                        local ext_theme = reaper.GetExtState(NS, "THEME_" .. safe_theme_name)
                        local current_theme = (ext_theme ~= "") and ext_theme or "Default"
                        
                        -- Dinamično oblikovanje gumba za Builder
                        local builder_label = ""
                        if is_module then
                            builder_label = (is_builder_active and "✓ " or "") .. "Layout Builder"
                        else
                            builder_label = "!Layout Builder (Module only)"
                        end

                        local menu_items = {
                            "~INSTANCE SETTINGS",
                            "Rename Instance (current: " .. instance_name .. ")",
                            builder_label,
                            ">VU Meter Tap Point",
                            (vu_mode == 0 and "✓ " or "") .. "PRE In",
                            (vu_mode == 1 and "✓ " or "") .. "PRE Out",
                            (vu_mode == 2 and "✓ " or "") .. "Chain Out",
                            "<",
                            ">VU Meter Calibration",
                            (current_vu_ref == 0 and "✓ " or "") .. "0 dBFS",
                            (current_vu_ref == -6 and "✓ " or "") .. "-6 dBFS",
                            (current_vu_ref == -12 and "✓ " or "") .. "-12 dBFS",
                            (current_vu_ref == -18 and "✓ " or "") .. "-18 dBFS",
                            (is_custom_vu and "✓ " or "") .. custom_vu_label,
                            "<",
                            ">Auto Gain Speed", 
                            (ag_speed_mode == 0.25 and "✓ " or "") .. "Extra Fast (0.25x)",
                            (ag_speed_mode == 0.5  and "✓ " or "") .. "Fast (0.50x)",
                            (ag_speed_mode == 1    and "✓ " or "") .. "Normal (1.00x)",
                            (ag_speed_mode == 2    and "✓ " or "") .. "Slow (2.00x)",
                            (ag_speed_mode == 4    and "✓ " or "") .. "Extra Slow (4.00x)",
                            "<",
                            "",
                            "~GLOBAL SETTINGS",
                            ">Theme (" .. jsfx_name .. ")"
                        }
                        
                        -- Dynamically inject themes
                        for _, theme in ipairs(available_themes) do
                            local prefix = (theme == current_theme) and "✓ " or ""
                            table.insert(menu_items, prefix .. theme)
                        end
                        table.insert(menu_items, "<")

                        -- Append the rest of the global settings
                        table.insert(menu_items, ">VU Meter Style")
                        table.insert(menu_items, (current_vu_style == 0 and "✓ " or "") .. "Classic Analog VU")
                        table.insert(menu_items, (current_vu_style == 1 and "✓ " or "") .. "Slim Horizontal VU")
                        table.insert(menu_items, (current_vu_style == 2 and "✓ " or "") .. "Hide Top Meters")
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">VU Peak LED Threshold")
                        table.insert(menu_items, (current_peak_th == 0 and "✓ " or "") .. "0 dBFS")
                        table.insert(menu_items, (current_peak_th == -1 and "✓ " or "") .. "-1 dBFS")
                        table.insert(menu_items, (current_peak_th == -3 and "✓ " or "") .. "-3 dBFS")
                        table.insert(menu_items, (current_peak_th == -6 and "✓ " or "") .. "-6 dBFS")
                        table.insert(menu_items, (is_custom_peak and "✓ " or "") .. custom_peak_label)
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">GR Meter Range")
                        table.insert(menu_items, (current_gr == 6 and "✓ " or "") .. "6 dB")
                        table.insert(menu_items, (current_gr == 12 and "✓ " or "") .. "12 dB")
                        table.insert(menu_items, (current_gr == 18 and "✓ " or "") .. "18 dB")
                        table.insert(menu_items, (current_gr == 24 and "✓ " or "") .. "24 dB")
                        table.insert(menu_items, (is_custom_gr and "✓ " or "") .. custom_gr_label)
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">Metering Display Mode")
                        table.insert(menu_items, (current_meter_mode == 0 and "✓ " or "") .. "Display meters for selected tracks only")
                        table.insert(menu_items, (current_meter_mode == 1 and "✓ " or "") .. "Display meters on all tracks")
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">Font Size")
                        table.insert(menu_items, (current_font == 8 and "✓ " or "") .. "8 px")
                        table.insert(menu_items, (current_font == 9 and "✓ " or "") .. "9 px")
                        table.insert(menu_items, (current_font == 10 and "✓ " or "") .. "10 px")
                        table.insert(menu_items, (current_font == 11 and "✓ " or "") .. "11 px")
                        table.insert(menu_items, (current_font == 12 and "✓ " or "") .. "12 px")
                        table.insert(menu_items, (current_font == 14 and "✓ " or "") .. "14 px")
                        table.insert(menu_items, (current_font == 16 and "✓ " or "") .. "16 px")
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">Tooltip settings")
                        table.insert(menu_items, (tooltips_on and "✓ " or "") .. "Show tooltips")
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">Mouse Control")
                        table.insert(menu_items, ">Standard Speed")
                        table.insert(menu_items, (mouse_std == 0.5 and "✓ " or "") .. "Sluggish (50%)")
                        table.insert(menu_items, (mouse_std == 0.75 and "✓ " or "") .. "Relaxed (75%)")
                        table.insert(menu_items, (mouse_std == 1.0 and "✓ " or "") .. "Normal (100%)")
                        table.insert(menu_items, (mouse_std == 1.5 and "✓ " or "") .. "Fast (150%)")
                        table.insert(menu_items, (mouse_std == 2.0 and "✓ " or "") .. "Extreme (200%)")
                        table.insert(menu_items, "<")
                        
                        table.insert(menu_items, ">Fine Speed (Ctrl/Cmd)")
                        table.insert(menu_items, (mouse_fine == 0.05 and "✓ " or "") .. "Extra Fine (5%)")
                        table.insert(menu_items, (mouse_fine == 0.1 and "✓ " or "") .. "Default (10%)")
                        table.insert(menu_items, (mouse_fine == 0.25 and "✓ " or "") .. "Moderate (25%)")
                        table.insert(menu_items, "<")
                        table.insert(menu_items, "<")
                        
                        local nx, ny = reaper.GetMousePosition()
                        local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                        
                        popup_state.active_cmd = 3
                        popup_state.request_open = true
                        popup_state.mouse_x, popup_state.mouse_y = mx, my
                        popup_state.data = {
                            is_global = true, 
                            menu_str = table.concat(menu_items, "|"),
                            tooltips_on = tooltips_on,
                            instance_name = instance_name,
                            c_guid = c_guid,
                            tr = tr,
                            f_idx = f_idx,
                            jsfx_name = jsfx_name,
                            themes = available_themes,
                            sl = sl
                        }
                        
                        reaper.gmem_write(PROJECT_BASE + 7, 0)
                    else
                    
                    
                        -- ==========================================================
                        --  MAPPING LOGIC (Background Click - RAM & HASH BASED)
                        -- ==========================================================
                        local addr_page = sl * 500 + 290
                        local page_num = math.floor(reaper.gmem_read(PROJECT_BASE + addr_page))
                        if page_num == 0 then 
                            reaper.gmem_write(PROJECT_BASE + 7, 0)
                            return 
                        end
                
                        local page_data = { [1] = {name="EQ"}, [2] = {name="DYN"}, [3] = {name="FX"} }
                        local p_info = page_data[page_num] or page_data[1]
                        local page_name = p_info.name 

                        local sub_slot = math.floor(reaper.gmem_read(PROJECT_BASE + 5))
                                
                                -- Get dynamic INI database for this specific JSFX
                                local jsfx_name = GetBaseJSFXName(tr, f_idx)
                                local INI_DB = GetINIDB(jsfx_name)
                                
                        local actual_page = page_name
                        local context_label = ""
                        if page_name == "DYN" then 
                            context_label = (sub_slot == 2) and "(DYN 2)" or "(DYN 1)"
                            actual_page = (sub_slot == 2) and "DYN2" or "DYN1"
                        elseif page_name == "FX" then 
                            context_label = (sub_slot == 2) and "(POST)" or "(PRE)" 
                            actual_page = (sub_slot == 2) and "POST" or "PRE"
                        end
                        
                        -- Gather Context FX (Container Priority + Main Track Fallback)
                        local context_fx_list = {}
                        local c_idx = -1
                        local track_fx_count = reaper.TrackFX_GetCount(tr)
                        
                        for i = 0, track_fx_count - 1 do
                            local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, i, "container_count")
                            if is_c ~= "" then c_idx = i; break end
                        end
                        
                        local function AddFXToList(target_idx)
                            if target_idx == f_idx or target_idx == c_idx then return end
                            local orig_name = GetOriginalFXName(tr, target_idx)
                            local hash_hex, alias, _, _, fb_hash = GenerateHashAndAlias(orig_name)
                            if hash_hex and hash_hex ~= "" and not orig_name:lower():find("striplink") and not orig_name:lower():find("aggregator") then
                                table.insert(context_fx_list, { hash = hash_hex, fallback_hash = fb_hash, alias = alias, idx = target_idx })
                            end
                        end
                        
                        if c_idx ~= -1 then
                            local ok, c_cnt_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_count")
                            local c_cnt = ok and tonumber(c_cnt_str) or 0
                            for i = 0, c_cnt - 1 do
                                local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, c_idx, "container_item." .. i)
                                local child_idx = tonumber(child_id_str)
                                if child_idx then AddFXToList(child_idx) end
                            end
                        end
                        
                        for i = 0, track_fx_count - 1 do
                            if i ~= c_idx then AddFXToList(i) end
                        end

                        -- Analyze currently mapped buttons ONLY for the target section/sub-slot
                        local current_btn_list = {}
                        if page_name == "EQ" then
                            for b = 1, 20 do table.insert(current_btn_list, b - 1) end
                        elseif page_name == "DYN" then
                            local dyn_top    = {21, 22, 23, 24, 25, 26, 27, 28, 29}
                            local dyn_bottom = {30, 31, 32, 33, 34, 35, 36, 37, 38}
                            local dyn_btns   = (sub_slot == 2) and dyn_bottom or dyn_top
                            for _, b in ipairs(dyn_btns) do table.insert(current_btn_list, b - 1) end
                        elseif page_name == "FX" then
                            local fx_pre_list  = {39, 40, 41, 42, 43, 44}
                            local fx_post_list = {45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56}
                            local fx_btns      = (sub_slot == 2) and fx_post_list or fx_pre_list
                            for _, b in ipairs(fx_btns) do table.insert(current_btn_list, b - 1) end
                        end

                        local mapped_guids = {}
                        for _, k_idx in ipairs(current_btn_list) do
                            local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. k_idx)
                            if val and val ~= "" then
                                local parts = safe_split(val)
                                local t_guid = parts[1]
                                if t_guid and t_guid ~= "" then
                                    mapped_guids[t_guid] = true
                                end
                            end
                        end

                        -- Collect Hashes and Aliases in signal flow order for plugins mapped on THIS section
                        local section_mapped_hashes = {}
                        local section_mapped_aliases = {}
                        for _, fx in ipairs(context_fx_list) do
                            local fx_guid = reaper.TrackFX_GetFXGUID(tr, fx.idx)
                            if mapped_guids[fx_guid] then
                                table.insert(section_mapped_hashes, fx.hash)
                                table.insert(section_mapped_aliases, fx.alias)
                            end
                        end

                        local full_chain_hash = table.concat(section_mapped_hashes, ">")
                        local chain_display_name = table.concat(section_mapped_aliases, " + ")
                        local is_chain = (#section_mapped_hashes > 1)
                        
                        local chain_mapping_found = is_chain and (get_valid_mapping_section(full_chain_hash, actual_page, nil, INI_DB) ~= nil)
                        
                        -- ==========================================================
                        -- BUILD THE MENU STRUCTURE
                        -- ==========================================================
                        local items, map, idx = {}, {}, 1
                        
                        local section_tag = page_name .. (context_label ~= "" and (" " .. context_label) or "")
                        local current_alias = is_chain and chain_display_name or (section_mapped_aliases[1] or "Unknown")
                       
                        -- CLEAR SECTION OPTION
                        table.insert(items, "Clear " .. section_tag .. " (Unlink all)")
                        map[idx] = { type = "clear_section", btn_list = current_btn_list }
                        idx = idx + 1
                        
                        table.insert(items, "")
                        
                        -- COPY / PASTE OPTIONS
                        if full_chain_hash ~= "" then
                            table.insert(items, "Copy " .. section_tag .. " settings")
                            map[idx] = { 
                                type = "copy", 
                                hash = full_chain_hash, 
                                alias = current_alias, 
                                btn_list = current_btn_list,
                                context_fx_list = context_fx_list,
                                jsfx_name = jsfx_name, -- Save layout type for cross-plugin protection
                                page_name = page_name, -- Save section type
                                sub_slot = sub_slot
                            }
                            idx = idx + 1
                        else
                            table.insert(items, "#Copy " .. section_tag .. " settings (No FX mapped)")
                        end
                        
                        -- ==========================================================
                        -- PREVERI, ALI SO VTIČNIKI IZ ODLOŽIŠČA NA VOLJO NA STEZI
                        -- ==========================================================
                        local can_paste = false
                        if clipboard_buffer.hash then
                            local req_hashes = {}
                            for h in clipboard_buffer.hash:gmatch("([A-Z0-9]+)") do table.insert(req_hashes, h) end
                            
                            local ctx_idx = 1
                            can_paste = true
                            for _, req_hash in ipairs(req_hashes) do
                                local found = false
                                while ctx_idx <= #context_fx_list do
                                    local ctx_fx = context_fx_list[ctx_idx]
                                    ctx_idx = ctx_idx + 1
                                    if ctx_fx.hash == req_hash or ctx_fx.fallback_hash == req_hash then
                                        found = true
                                        break
                                    end
                                end
                                if not found then can_paste = false; break end
                            end
                        end

                        -- Dynamic PASTE menu item state
                        if not clipboard_buffer.hash then
                            table.insert(items, "#Paste " .. section_tag .. " settings (Clipboard empty)")
                        elseif clipboard_buffer.jsfx_name ~= jsfx_name then
                            table.insert(items, "#Paste " .. section_tag .. " settings (Type mismatch)")
                        elseif clipboard_buffer.page_name ~= page_name then
                            -- Section mismatch protection (e.g., trying to paste EQ into DYN)
                            table.insert(items, "#Paste " .. section_tag .. " settings (Section mismatch)")
                        elseif can_paste then
                            table.insert(items, "Paste " .. section_tag .. " settings (" .. clipboard_buffer.alias .. ")")
                            map[idx] = { 
                                type = "paste", 
                                hash = clipboard_buffer.hash, -- <== Nujno uporabiti hash iz odložišča!
                                btn_list = current_btn_list,
                                context_fx_list = context_fx_list,
                                jsfx_name = jsfx_name,
                                page_name = page_name,
                                sub_slot = sub_slot
                            }
                            idx = idx + 1
                        else
                            table.insert(items, "#Paste " .. section_tag .. " settings (Required FX missing on track)")
                        end
                        
                        table.insert(items, "") -- SEPARATOR
                        
                        
                        -- Fetch custom instance name suffix for Save options display
                        local custom_hash = math.floor(reaper.TrackFX_GetParam(tr, f_idx, 0) + 0.5)
                        local instance_suffix = ""
                        if custom_hash > 0 then
                            local _, saved_name = reaper.GetProjExtState(0, NS, "INSTANCE_NAME_" .. c_guid)
                            if saved_name and saved_name ~= "" and saved_name ~= "default" then
                                instance_suffix = " (" .. saved_name .. ")"
                            else
                                -- If there's no name in RAM-u, try reading form INI dictionary
                                local d_name = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][tostring(custom_hash)]
                                if d_name then
                                    instance_suffix = " (" .. d_name .. ")"
                                else
                                    instance_suffix = " (ID: " .. tostring(custom_hash) .. ")"
                                end
                            end
                        end
                        
                        
                        -- ==========================================================
                        -- SAVE OPTIONS (With HYBRID Detection & Instance Name)
                        -- ==========================================================

                        if is_chain then
                            -- Multiple FX mapped -> Active Save option for the whole Chain
                            table.insert(items, "Save " .. section_tag .. " CHAIN: " .. chain_display_name .. instance_suffix)
                            map[idx] = { type = "save", hash = full_chain_hash }
                            idx = idx + 1
                            
                            -- Submenu with greyed-out (disabled) single FX options
                            table.insert(items, ">Save individual FX (Disabled during Chain)")
                            for _, single_alias in ipairs(section_mapped_aliases) do
                                table.insert(items, "#" .. single_alias .. " (linked in chain)")
                            end
                            table.insert(items, "<")
                        
                        elseif #section_mapped_hashes == 1 then
                            -- Single FX mapped -> Detect if it's a HYBRID
                            local single_alias = section_mapped_aliases[1]
                            local single_hash = section_mapped_hashes[1]
                            local single_guid = nil
                            
                            -- Find the actual GUID for this hash
                            for _, fx in ipairs(context_fx_list) do
                                if fx.hash == single_hash then 
                                    single_guid = reaper.TrackFX_GetFXGUID(tr, fx.idx)
                                    break 
                                end
                            end
                            
                            local is_hybrid = false
                            local active_secs = {}
                            
                            if single_guid then
                                local f_eq, f_d1, f_d2, f_pre, f_post = false, false, false, false, false
                                -- Scan all StripLink buttons to see where this GUID is connected
                                for b = 0, 64 do
                                    local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. b)
                                    if val and val ~= "" then
                                        local parts = safe_split(val)
                                        if parts[1] == single_guid then
                                            local sec = GetSectionByParamID(b)
                                            if sec == "EQ" then f_eq = true
                                            elseif sec == "DYN1" then f_d1 = true
                                            elseif sec == "DYN2" then f_d2 = true
                                            elseif sec == "PRE" then f_pre = true
                                            elseif sec == "POST" then f_post = true
                                            end
                                        end
                                    end
                                end
                            
                                if f_eq then table.insert(active_secs, "EQ") end
                                if f_d1 then table.insert(active_secs, "DYN1") end
                                if f_d2 then table.insert(active_secs, "DYN2") end
                                if f_pre then table.insert(active_secs, "PRE") end
                                if f_post then table.insert(active_secs, "POST") end
                            
                                if #active_secs > 1 then is_hybrid = true end
                            end
                            
                            if is_hybrid then
                                -- Replace standalone save with HYBRID save (including instance suffix)
                                local hybrid_str = table.concat(active_secs, " + ")
                                table.insert(items, "Save HYBRID mapping: " .. single_alias .. instance_suffix .. " (" .. hybrid_str .. ")")
                                map[idx] = { type = "save_hybrid", hash = single_hash, sections = active_secs }
                                idx = idx + 1
                            else
                                -- Normal Standalone Save (including instance suffix)
                                table.insert(items, "Save " .. section_tag .. " mapping: " .. single_alias .. instance_suffix)
                                map[idx] = { type = "save", hash = single_hash }
                                idx = idx + 1
                            end
                        else
                            -- Fallback if no buttons are mapped yet
                            table.insert(items, "#Save " .. section_tag .. " mapping (No parameters linked)")
                        end
                                                    
                        table.insert(items, "") -- SEPARATOR
                        
                        -- ==========================================================
                        -- LOAD EXISTING FX (Already on track / In-order Chain Subsequences)
                        -- ==========================================================
                        local added_any_load = false
                        
                        local hash_counts = {}
                        for _, fx in ipairs(context_fx_list) do
                            hash_counts[fx.hash] = (hash_counts[fx.hash] or 0) + 1
                        end
                        local hash_seen = {}
                        
                        -- 1. Search INI for ALL valid CHAIN mappings for the plugins currently on track
                        local found_chains = {}
                        for sec_name, _ in pairs(INI_DB) do
                            if sec_name ~= "DICTIONARY" and not sec_name:match("^UNMAPPED_") then
                                local hash_part, sec_page = sec_name:match("^(.-)_([A-Z0-9_]+)$")
                                if hash_part and sec_page then
                                    local is_chain_hash = hash_part:find(">") ~= nil
                                    if is_chain_hash then
                                        local pure_page, suffix = sec_page:match("^(.-)_(%d+)$")
                                        if not pure_page then pure_page = sec_page end
                                        
                                        if is_page_match(pure_page, actual_page) then
                                            if IsChainSubsequenceInContext(hash_part, context_fx_list) then
                                                local aliases = {}
                                                for h in hash_part:gmatch("([A-Z0-9]+)") do
                                                    local d_entry = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][h]
                                                    if d_entry then
                                                        local _, d_alias = d_entry:match("^(.-)|(.*)$")
                                                        table.insert(aliases, d_alias or "Unknown")
                                                    else
                                                        table.insert(aliases, "Unknown")
                                                    end
                                                end
                                                local chain_name = table.concat(aliases, " + ")
                                                table.insert(found_chains, { hash = hash_part, name = chain_name, suffix = suffix })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        for _, ch in ipairs(found_chains) do
                            local var_label = ch.suffix and (" (ID: " .. ch.suffix .. ")") or " (Default)"
                            if ch.suffix then
                                local d_name = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][ch.suffix]
                                if d_name then var_label = " (" .. d_name .. ")" end
                            end
                            
                            table.insert(items, "Load CHAIN: " .. ch.name .. var_label)
                            map[idx] = { 
                                type = "load", 
                                hash = ch.hash,
                                target_fx_idx = context_fx_list[1] and context_fx_list[1].idx or 0,
                                target_slider = ch.suffix and tonumber(ch.suffix) or 0
                            }
                            idx = idx + 1
                            added_any_load = true
                        end
                        
                        -- 2. Check for individual FX mappings or Hybrids
                        for _, fx in ipairs(context_fx_list) do
                            local found_hybrids = {}
                            local found_variants = {}
                            
                            for sec_name, _ in pairs(INI_DB) do
                                if sec_name ~= "DICTIONARY" and not sec_name:match("^UNMAPPED_") then
                                    if sec_name:match("^" .. fx.hash .. "_HYBRID_") and sec_name:find(actual_page) and not sec_name:match("_LAYOUT$") then
                                        -- It's a Hybrid
                                        local h_label_raw = sec_name:match("_HYBRID_([A-Z0-9_]+)$")
                                        local base_label, suf = h_label_raw:match("^(.-)_(%d+)$")
                                        if not base_label then base_label = h_label_raw; suf = nil end
                                        local clean_label = base_label:gsub("_", " + ")
                                        table.insert(found_hybrids, { full_sec = sec_name, label = clean_label, suffix = suf })
                                    else
                                        -- Standard single mapping
                                        local h_part, sec_page = sec_name:match("^(.-)_([A-Z0-9_]+)$")
                                        if h_part and sec_page and not h_part:find(">") then
                                            local pure_page, suf = sec_page:match("^(.-)_(%d+)$")
                                            if not pure_page then pure_page = sec_page end
                                            
                                            if (h_part == fx.hash or h_part == fx.fallback_hash) and is_page_match(pure_page, actual_page) then
                                                table.insert(found_variants, { hash = h_part, suffix = suf })
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if #found_hybrids > 0 or #found_variants > 0 then
                                hash_seen[fx.hash] = (hash_seen[fx.hash] or 0) + 1
                                local num_str = (hash_counts[fx.hash] > 1) and (" #" .. hash_seen[fx.hash]) or ""
                                
                                for _, h in ipairs(found_hybrids) do
                                    local var_label = h.suffix and (" (ID: " .. h.suffix .. ")") or ""
                                    if h.suffix then
                                        local d_name = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][h.suffix]
                                        if d_name then var_label = " (" .. d_name .. ")" end
                                    end
                                    table.insert(items, "Load HYBRID: " .. fx.alias .. var_label .. num_str .. " [" .. h.label .. "]")
                                    map[idx] = { type = "load_hybrid", full_section_name = h.full_sec, target_fx_idx = fx.idx, target_slider = h.suffix and tonumber(h.suffix) or 0 }
                                    idx = idx + 1
                                    added_any_load = true
                                end
                                
                                for _, v in ipairs(found_variants) do
                                    local var_label = v.suffix and (" (ID: " .. v.suffix .. ")") or " (Default)"
                                    if v.suffix then
                                        local d_name = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][v.suffix]
                                        if d_name then var_label = " (" .. d_name .. ")" end
                                    end
                                    table.insert(items, "Load " .. context_label .. ": " .. fx.alias .. var_label .. num_str)
                                    map[idx] = { type = "load_variant", hash = v.hash, target_fx_idx = fx.idx, target_slider = v.suffix and tonumber(v.suffix) or 0 }
                                    idx = idx + 1
                                    added_any_load = true
                                end
                            end
                        end
                        
                        table.insert(items, "") -- SEPARATOR
                         
                         -- ==========================================================
                         -- INSERT NEW FX
                         -- ==========================================================
                         local all_inserts = {}

                         for section_name, _ in pairs(INI_DB) do
                             if section_name ~= "DICTIONARY" and not section_name:match("^UNMAPPED_") then
                                 local hash_part, sec_page = section_name:match("^(.-)_([A-Z0-9_]+)$")
                                 if hash_part and sec_page then
                                     if sec_page:match("^HYBRID_") and sec_page:find(actual_page) and not sec_page:match("_LAYOUT$") then
                                         local dict_entry = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][hash_part]
                                         if dict_entry then
                                             local raw_with_tag, dict_alias = dict_entry:match("^(.-)|(.*)$")
                                             if raw_with_tag and dict_alias then
                                                 local h_label = sec_page:match("^HYBRID_(.*)$"):gsub("_", " + ")
                                                 table.insert(all_inserts, { type = "hybrid", hash = hash_part, display_name = dict_alias, raw = raw_with_tag, full_section = section_name, label = h_label })
                                             end
                                         end
                                     elseif is_page_match(sec_page, actual_page) then
                                         -- STANDARD OR CHAIN MAPPING
                                         local is_chain_hash = hash_part:find(">") ~= nil
                                         local aliases = {}
                                         local raws = {}
                                         for h in hash_part:gmatch("([A-Z0-9]+)") do
                                             local d_entry = INI_DB["DICTIONARY"] and INI_DB["DICTIONARY"][h]
                                             if d_entry then
                                                 local raw_tag, d_alias = d_entry:match("^(.-)|(.*)$")
                                                 table.insert(aliases, d_alias or "Unknown")
                                                 table.insert(raws, raw_tag)
                                             else
                                                 table.insert(aliases, "Unknown")
                                             end
                                         end
                                         
                                         if #aliases > 0 then
                                             local display_name = table.concat(aliases, " + ")
                                             table.insert(all_inserts, { type = is_chain_hash and "chain" or "single", hash = hash_part, display_name = display_name, raw = raws[1], raws = raws })
                                         end
                                     end
                                 end
                             end
                         end

                         -- Remove duplicates and sort
                         local unique_inserts = {}
                         local sorted_inserts = {}
                         for _, data in ipairs(all_inserts) do
                             local key = data.hash .. "_" .. data.type
                             if not unique_inserts[key] then
                                 unique_inserts[key] = true
                                 table.insert(sorted_inserts, data)
                             end
                         end
                         table.sort(sorted_inserts, function(a, b) return a.display_name < b.display_name end)

                         if #sorted_inserts > 0 then
                             table.insert(items, ">Insert Mapped FX")
                             for _, data in ipairs(sorted_inserts) do
                                 if data.type == "hybrid" then
                                     table.insert(items, "[HYBRID] " .. data.display_name .. " (" .. data.label .. ")")
                                     map[idx] = { type = "insert_hybrid", raw = data.raw, full_section = data.full_section }
                                 elseif data.type == "chain" then
                                     table.insert(items, "[CHAIN] " .. data.display_name)
                                     map[idx] = { type = "insert_chain", hash = data.hash, raws = data.raws }
                                 else
                                     table.insert(items, data.display_name)
                                     map[idx] = { type = "insert", hash = data.hash, raw = data.raw }
                                 end
                                 idx = idx + 1
                             end
                             table.insert(items, "<")
                         else
                             table.insert(items, "#Insert Mapped FX (No mappings yet)")
                         end                      
                        
                        local clean_items = {}
                        local last_was_sep = false
                        for _, v in ipairs(items) do
                            if v == "" then
                                if not last_was_sep then
                                    table.insert(clean_items, v)
                                    last_was_sep = true
                                end
                            else
                                table.insert(clean_items, v)
                                last_was_sep = false
                            end
                        end
                        if #clean_items > 0 and clean_items[#clean_items] == "" then table.remove(clean_items) end
                        
                        local menu = table.concat(clean_items, "|")
                        
                         -- GUI CALL (Routed to ImGui)
                         local nx, ny = reaper.GetMousePosition()
                         local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                         
                         popup_state.active_cmd = 3
                         popup_state.request_open = true
                         popup_state.mouse_x, popup_state.mouse_y = mx, my
                         popup_state.data = {
                             is_global = false,
                             menu_str = menu,
                             map = map,
                             c_guid = c_guid,
                             page_name = page_name,
                             sub_slot = sub_slot,
                             tr = tr,
                             f_idx = f_idx,
                             sl = sl
                         }
                         
                         -- Clear command slot.
                         reaper.gmem_write(PROJECT_BASE + 7, 0)
                     end
                
           elseif cmd == 4 then
                 local container_idx = -1
                 local fx_count = reaper.TrackFX_GetCount(tr)
                 for i = 0, fx_count - 1 do
                     local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, i, "container_count")
                     if is_c ~= "" then container_idx = i; break end
                 end
           
                 if container_idx == -1 then
                     table.insert(pending_os_tasks, function()
                         reaper.MB("Metering only works with FX inside containers.", "StripLink", 0)
                     end)
                     reaper.gmem_write(PROJECT_BASE + 7, 0)
                     return 
                 end
           
                 local ok_c, c_count_str = reaper.TrackFX_GetNamedConfigParm(tr, container_idx, "container_count")
                 local c_count = ok_c and tonumber(c_count_str) or 0
                 local aggregator_idx = -1
                 local last_pos = c_count - 1
                 
                 for i = 0, c_count - 1 do
                     local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, container_idx, "container_item." .. i)
                     local internal_idx = tonumber(child_id_str)
                     if internal_idx then
                         local _, n = reaper.TrackFX_GetFXName(tr, internal_idx, "")
                         if n:lower():find("aggregator") then
                             aggregator_idx = internal_idx
                             if i < last_pos then
                                 local target_pos = 0x2000000 + (last_pos + 1) * (fx_count + 1) + (container_idx + 1)
                                 reaper.TrackFX_CopyToTrack(tr, aggregator_idx, tr, target_pos, true)
                                 aggregator_idx = target_pos 
                             end
                             break
                         end
                     end
                 end
                 if aggregator_idx == -1 then
                     local new_pos = 0x2000000 + (c_count + 1) * (fx_count + 1) + (container_idx + 1)
                     reaper.TrackFX_AddByName(tr, "JS:StripLink_Aggregator_v2.0.jsfx", false, -1000 - new_pos)
                     c_count = c_count + 1 
                 end
           
                 local meter_id = math.floor(reaper.gmem_read(PROJECT_BASE + 5))
                 local target_mask = 0
                 if meter_id == 101 then target_mask = (1 << 12)
                 elseif meter_id == 99 then target_mask = (1 << 6)
                 elseif meter_id == 100 then target_mask = (1 << 10) end
           
                 local menu = "RESET Meter|#Choose FX source:|"
                 local fx_list = {}
                 
                 for i = 0, c_count - 1 do
                     local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(tr, container_idx, "container_item." .. i)
                     local internal_idx = tonumber(child_id_str)
                     if internal_idx then
                         local _, name = reaper.TrackFX_GetFXName(tr, internal_idx, "")
                         if not name:lower():find("striplink") and not name:lower():find("aggregator") then
                             local clean_name = CleanFXName(name):gsub("|", "-"):gsub("<", "["):gsub(">", "]")
                             local curr_pins = reaper.TrackFX_GetPinMappings(tr, internal_idx, 1, 0)
                             local prefix = ((curr_pins & target_mask) ~= 0) and "✓ " or ""
                             menu = menu .. prefix .. clean_name .. "|"
                             table.insert(fx_list, {sub_idx = i, internal_idx = internal_idx, name = clean_name})
                         end
                     end
                 end
                 
                 local nx, ny = reaper.GetMousePosition()
                 local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                 
                 popup_state.active_cmd = 4
                 popup_state.request_open = true
                 popup_state.mouse_x, popup_state.mouse_y = mx, my
                 popup_state.data = {
                     menu_str = menu,
                     fx_list = fx_list,
                     meter_id = meter_id,
                     c_guid = c_guid,
                     sl = sl,
                     tr = tr,
                     container_idx = container_idx,
                     c_count = c_count
                 }
                 
                 reaper.gmem_write(PROJECT_BASE + 7, 0)
 

                elseif cmd == 5 then 
                    local opts = {"No Group", "Group A", "Group B", "Group C", "Group D"}
                    local k_idx = key_from_btn(btn_idx) 
                    local group_key = "GROUP:" .. c_guid .. ":" .. k_idx
                    local _, cur_g = reaper.GetProjExtState(0, NS, group_key)
                    local cur_group = tonumber(cur_g) or 0
                    
                    local menu_table = {}
                    for i, opt in ipairs(opts) do table.insert(menu_table, (cur_group == (i-1) and "✓ " or "") .. opt) end
                    
                    local nx, ny = reaper.GetMousePosition()
                    local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                    
                    popup_state.active_cmd = 5
                    popup_state.request_open = true
                    popup_state.mouse_x, popup_state.mouse_y = mx, my
                    popup_state.data = {
                        menu_str = table.concat(menu_table, "|"),
                        c_guid = c_guid,
                        k_idx = k_idx,
                        sl = sl,
                        tr = tr
                    }
                    
                    reaper.gmem_write(PROJECT_BASE + 7, 0)
 
                elseif cmd == 6 then
                    local k_idx = key_from_btn(btn_idx) 
                    local key = c_guid .. ":" .. k_idx
                    local _, map_data = reaper.GetProjExtState(0, NS, key)
                    
                    if map_data ~= "" then
                        local parts = safe_split(map_data)
                        local current_p = tonumber(parts[6]) or 1.0
                        local abs_p = math.abs(current_p) -- Absolute value for checkmarks
                        
                        local opts = {
                            {name="Linear (1:1)", val=1.0},
                            {name="Fast - Extreme", val=5.0},
                            {name="Fast - Standard", val=3.32},
                            {name="Fast - Moderate", val=2.0},
                            {name="Slow - Standard", val=0.3},
                            {name="Slow - Moderate", val=0.5}
                        }
                        
                        local menu_str = "#Choose parameter curve|"
                        for i, opt in ipairs(opts) do
                            local prefix = (math.abs(abs_p - opt.val) < 0.01) and "✓ " or ""
                            menu_str = menu_str .. prefix .. opt.name .. "|"
                        end
                        
                        local nx, ny = reaper.GetMousePosition()
                        local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                        
                        popup_state.active_cmd = 6
                        popup_state.request_open = true
                        popup_state.mouse_x, popup_state.mouse_y = mx, my
                        popup_state.data = {
                            menu_str = menu_str,
                            parts = parts,
                            key = key,
                            sl = sl,
                            k_idx = k_idx
                        }
                    end
                    reaper.gmem_write(PROJECT_BASE + 7, 0)

                elseif cmd == 9 then
                    -- ==========================================
                    -- DOUBLE CLICK: RESET Meters PARAMETER TO DEFAULT (CMD 9)
                    -- ==========================================
                    local k_idx = key_from_btn(btn_idx)
                    local key = c_guid .. ":" .. k_idx
                    local _, map_data = reaper.GetProjExtState(0, NS, key)
                    
                    if map_data ~= "" then
                        local parts = safe_split(map_data)
                        local target_fx_idx = tonumber(parts[3])
                        local p_idx = tonumber(parts[4])
                        local target_track = (parts[7] and parts[7] ~= "") and reaper.BR_GetMediaTrackByGUID(0, parts[7]) or tr
                        
                        if target_fx_idx and target_fx_idx ~= -1 and p_idx and target_track then
                            -- parts[8] holds the default parameter value recorded upon initial linking
                            local default_v = tonumber((tostring(parts[8] or ""):gsub(",", ".")))
                            if not default_v then default_v = 0.5 end 
                            reaper.TrackFX_SetParamNormalized(target_track, target_fx_idx, p_idx, default_v)
                            
                            -- VST3 KICK HACK for dbl click
                            local raw_def = reaper.TrackFX_GetParam(target_track, target_fx_idx, p_idx)
                            reaper.TrackFX_SetParam(target_track, target_fx_idx, p_idx, raw_def)
                        end
                    end
                    reaper.gmem_write(PROJECT_BASE + 7, 0)
                    
                elseif cmd == 20 then
                    local clicked_tab = reaper.gmem_read(PROJECT_BASE + 5)
                    
                    -- Vsi vtičniki imajo sedaj TAB Colors poenotene na slider6 (indeks 5)
                    local target_param_idx = 5 
                    
                    local current_val = reaper.TrackFX_GetParam(tr, f_idx, target_param_idx)
                    current_val = math.floor(current_val + 0.5)
                    
                    local col_eq  = math.floor(current_val / 100)
                    local col_dyn = math.floor((current_val % 100) / 10)
                    local col_fx  = math.floor(current_val % 10)
                    
                    local current_color = 0
                    if clicked_tab == 1 then current_color = col_eq
                    elseif clicked_tab == 2 then current_color = col_dyn
                    elseif clicked_tab == 3 then current_color = col_fx
                    end
                    
                    local hair = "\xe2\x80\x8a"
                    local opts = {"None " .. hair, "Red   " .. hair .. hair, "Green ", "Blue   ".. hair, "Yellow"}
                    local menu_table = {}
                    for i, opt in ipairs(opts) do
                        local prefix = (current_color == (i - 1)) and "✓ " or ""
                        table.insert(menu_table, prefix .. opt)
                    end
                    
                    local nx, ny = reaper.GetMousePosition()
                    local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                    
                    popup_state.active_cmd = 20
                    popup_state.request_open = true
                    popup_state.mouse_x, popup_state.mouse_y = mx, my
                    popup_state.data = {
                        menu_str = table.concat(menu_table, "|"),
                        clicked_tab = clicked_tab,
                        col_eq = col_eq,
                        col_dyn = col_dyn,
                        col_fx = col_fx,
                        tr = tr,
                        f_idx = f_idx,
                        target_param_idx = target_param_idx
                    }
                    
                    reaper.gmem_write(PROJECT_BASE + 7, 0)
                    
                    elseif cmd == 21 then
                        -- ===========================================
                        -- OVR SLOT MENU (CMD 21)
                        -- ===========================================
                        local slot_id = math.floor(reaper.gmem_read(PROJECT_BASE + 5))
                        
                        local jsfx_name = GetBaseJSFXName(tr, f_idx)
                        local is_module = jsfx_name:lower():find("module") ~= nil
                        
                        local cur_btn = 0
                        local cur_mtr_packed = 0
                        
                        -- PAMETNO BRANJE GLEDE NA TIP VTIČNIKA
                        if is_module then
                            local ext_ovr_base = PROJECT_BASE + 50000 + (sl * 200)
                            cur_btn = reaper.gmem_read(ext_ovr_base + slot_id)
                            cur_mtr_packed = reaper.gmem_read(ext_ovr_base + 64 + slot_id)
                        else
                            cur_btn = reaper.gmem_read(PROJECT_BASE + sl * 500 + 300 + slot_id)
                            cur_mtr_packed = reaper.gmem_read(PROJECT_BASE + sl * 500 + 342 + slot_id)
                        end
                        
                        local cur_mtr = math.floor(cur_mtr_packed / 10)
                        
                        local menu_str = ""
                        local map = {}
                        local idx = 1
                        
                        local function add_item(name, b_id)
                            local b_id_int = math.floor(tonumber(b_id) or 0)
                            local nice_name = "Empty" 
                            local _, m_data = reaper.GetProjExtState(0, NS, c_guid .. ":" .. (b_id_int - 1))
                            
                            if m_data ~= "" then 
                                local parts = safe_split(m_data)
                                if parts[5] and parts[5] ~= "" then 
                                    nice_name = parts[5]:gsub("^~", "") 
                                end
                            end
                            
                            local is_active = (b_id_int == cur_btn)
                            local prefix = is_active and "✓ " or ""
                            
                            menu_str = menu_str .. prefix .. name .. " (" .. nice_name .. ")|"
                            map[idx] = { action = "assign", btn_idx = b_id_int, slot_id = slot_id }
                            idx = idx + 1
                        end

                        if is_module and user_layouts[sl] then
                            -- ZA MODULE: Dinamičen izpis samo elementov, ki fizično obstajajo!
                            local layout_elements = { EQ = {}, DYN = {}, FX = {} }
                            for _, el in ipairs(user_layouts[sl]) do
                                local t = el[2]
                                local tab = el[12]
                                local b_id = el[5]
                                
                                if (t == 1 or t == 2 or t == 3 or t == 7) and tab ~= 0 and b_id > 0 then
                                    local type_str = "Knob"
                                    if t == 2 then type_str = "Switch"
                                    elseif t == 3 then type_str = "Tube"
                                    elseif t == 7 then type_str = "Selector"
                                    end
                                    
                                    local entry = { id = b_id, name = type_str }
                                    if tab == 1 then table.insert(layout_elements.EQ, entry)
                                    elseif tab == 2 then table.insert(layout_elements.DYN, entry)
                                    elseif tab == 3 then table.insert(layout_elements.FX, entry)
                                    end
                                end
                            end
                            
                            -- Pomožna funkcija za sortiranje
                            local function sort_by_id(a, b) return a.id < b.id end
                            table.sort(layout_elements.EQ, sort_by_id)
                            table.sort(layout_elements.DYN, sort_by_id)
                            table.sort(layout_elements.FX, sort_by_id)
                            
                            if #layout_elements.EQ > 0 then
                                menu_str = menu_str .. ">EQ Parameters|"
                                for _, item in ipairs(layout_elements.EQ) do
                                    add_item(item.name .. " " .. item.id, item.id)
                                end
                                menu_str = menu_str .. "<|"
                            end
                            if #layout_elements.DYN > 0 then
                                menu_str = menu_str .. ">DYN Parameters|"
                                for _, item in ipairs(layout_elements.DYN) do
                                    local prefix = (item.id <= 29) and "DYN1 " or "DYN2 "
                                    add_item(prefix .. item.name .. " " .. item.id, item.id)
                                end
                                menu_str = menu_str .. "<|"
                            end
                            if #layout_elements.FX > 0 then
                                menu_str = menu_str .. ">FX Parameters|"
                                for _, item in ipairs(layout_elements.FX) do
                                    local prefix = (item.id <= 44) and "PRE " or "POST "
                                    add_item(prefix .. item.name .. " " .. item.id, item.id)
                                end
                                menu_str = menu_str .. "<|"
                            end
                        else
                            -- ZA STATIČNI UC-1: Trdo kodiran izpis po tvojih merah
                            menu_str = menu_str .. ">EQ Parameters|"
                            for b = 1, 12 do add_item("Knob " .. b, b) end
                            for b = 13, 20 do add_item("Switch " .. (b-12), b) end
                            menu_str = menu_str .. "<|"

                            menu_str = menu_str .. ">DYN Parameters|"
                            for b = 21, 25 do add_item("DYN1 Knob " .. (b-20), b) end
                            for b = 30, 34 do add_item("DYN2 Knob " .. (b-29), b) end
                            for b = 26, 29 do add_item("DYN1 Switch " .. (b-25), b) end
                            for b = 35, 38 do add_item("DYN2 Switch " .. (b-34), b) end
                            menu_str = menu_str .. "<|"
                            
                            menu_str = menu_str .. ">FX Parameters|"
                            for b = 40, 42 do add_item("PRE Knob " .. (b-38), b) end
                            for b = 45, 52 do add_item("POST Knob " .. (b-44), b) end
                            for b = 43, 44 do add_item("PRE Switch " .. (b-42), b) end
                            for b = 54, 55 do add_item("POST Switch " .. (b-53), b) end
                            menu_str = menu_str .. "<|"
                        end

                        -- METER SUBMENU (Dovoli prekrivanje samo na gumbih)
                        local assigned_is_knob = false
                        if cur_btn > 0 then
                            if (cur_btn >= 1 and cur_btn <= 12) or 
                               (cur_btn >= 21 and cur_btn <= 25) or 
                               (cur_btn >= 30 and cur_btn <= 34) or
                               (cur_btn >= 39 and cur_btn <= 42) or
                               (cur_btn >= 45 and cur_btn <= 53) then
                                assigned_is_knob = true
                            end
                        end

                        -- METER SUBMENU
                        if assigned_is_knob then
                            menu_str = menu_str .. "||>Overlay GR Meter|"
                            local mtr_opts = {"None", "DYN 1", "DYN 2"}
                            for i, opt in ipairs(mtr_opts) do
                                local m_val = i - 1
                                local prefix = (cur_mtr == m_val) and "✓ " or ""
                                menu_str = menu_str .. prefix .. opt .. "|"
                                map[idx] = { action = "meter", val = m_val, slot_id = slot_id }
                                idx = idx + 1
                            end
                            menu_str = menu_str .. "<|"
                        else
                            -- Onemogočen prikaz za stikala in tube
                            menu_str = menu_str .. "||#Overlay GR Meter (Knobs only)"
                        end
                        
                        -- Clear slot
                        local clear_prefix = (cur_btn == 0) and "✓ " or ""
                        menu_str = menu_str .. "||" .. clear_prefix .. "Clear Parameter (Empty)"
                        map[idx] = { action = "assign", btn_idx = 0, slot_id = slot_id }
                        
                        local nx, ny = reaper.GetMousePosition()
                        local mx, my = reaper.ImGui_PointConvertNative(ctx, nx, ny)
                        
                        popup_state.active_cmd = 21
                        popup_state.request_open = true
                        popup_state.mouse_x, popup_state.mouse_y = mx, my
                        popup_state.data = {
                            menu_str = menu_str,
                            map = map,
                            c_guid = c_guid,
                            sl = sl,
                            tr = tr,
                            f_idx = f_idx
                        }
                        
                        reaper.gmem_write(PROJECT_BASE + 7, 0)
                            
                    elseif cmd == 22 then
                        -- ===========================================
                        -- AUTO GAIN VALIDATION (CMD 22)
                        -- ===========================================
                        local ag_addr = PROJECT_BASE + sl * 500 + 78
                        local ag_lock_addr = PROJECT_BASE + sl * 500 + 79
                        local cur_ag = reaper.gmem_read(ag_addr)
                        
                        -- Ker JSFX takoj preklopi vrednost zaradi MIDI Learn-a,
                        -- 'cur_ag' zdaj predstavlja NOVO (želeno) stanje!
                        if cur_ag < 0.5 then
                            -- Uporabnik je izklopil Auto Gain (JSFX ga je nastavil na 0).
                            -- To je vedno dovoljeno, samo ponastavimo statuse.
                            reaper.gmem_write(ag_addr, 0)
                            reaper.gmem_write(ag_lock_addr, 0) -- Reset freeze state
                            reaper.SetProjExtState(0, NS, "AG_PWR_" .. c_guid, "0")
                            reaper.SetProjExtState(0, NS, "AG_LOCK_" .. c_guid, "0")
                        else
                            -- User turned AG on (JSFX set it to 1).
                            -- Needs validation
                            local has_aggregator = false
                            local has_routing = false
                            
                            local function CheckFX(t, parent_idx)
                                local count = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(t, parent_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(t)
                                for i = 0, count - 1 do
                                    local current_idx = parent_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(t, parent_idx, "container_item." .. i)})[2]) or i
                                    if current_idx then
                                        local _, name = reaper.TrackFX_GetFXName(t, current_idx, "")
                                        if name:lower():find("aggregator") then has_aggregator = true end
                                        
                                        -- Read output pins (0 = L, 1 = R)
                                        local out_0 = reaper.TrackFX_GetPinMappings(t, current_idx, 1, 0)
                                        local out_1 = reaper.TrackFX_GetPinMappings(t, current_idx, 1, 1)
                                        
                                        -- Check if bits 12 or 13 are set (Channels 13 and 14)
                                        if ((out_0 | out_1) & (3 << 12)) ~= 0 then has_routing = true end
                                        
                                        local _, is_c = reaper.TrackFX_GetNamedConfigParm(t, current_idx, "container_count")
                                        if is_c ~= "" then CheckFX(t, current_idx) end
                                    end
                                end
                            end
                            
                            CheckFX(tr, nil)
                            
                            if has_aggregator and has_routing then
                                -- Validation successful! Write saved state
                                reaper.SetProjExtState(0, NS, "AG_PWR_" .. c_guid, "1")
                            else
                                reaper.gmem_write(ag_addr, 0)
                                table.insert(pending_os_tasks, function()
                                    reaper.MB(
                                        "Auto Gain cannot be enabled!\n\n" ..
                                        "Please make sure that:\n" ..
                                        "1. 'StripLink Aggregator' is present in the FX chain.\n" ..
                                        "2. At least one plugin (preferably the first) is routed to channels 13/14.\n\n" ..
                                        "Tip: Simply link the PRE meter to the plugin — the Aggregator will be added " ..
                                        "and the required pins will be set automatically.",
                                        "StripLink: Auto Gain Error",
                                        0
                                    )
                                end)
                            end
                        end
                        reaper.gmem_write(PROJECT_BASE + 7, 0)
                            
                    elseif cmd == 23 then
                        -- ===========================================
                        -- INPUT GAIN TEXT INPUT (CMD 23)
                        -- ===========================================
                        -- Input Gain je na Sliderju 10, kar pomeni parameter indeks 9
                        local current_gain = reaper.TrackFX_GetParam(tr, f_idx, 9)
                        
                        table.insert(pending_os_tasks, function()
                            local retval, user_input = reaper.GetUserInputs("Input Gain", 1, "Enter Gain (dB) [-12 to 12]:,extrawidth=20", string.format("%.1f", current_gain))
                            
                            if retval then
                                -- Zamenjamo morebitne vejice v pike za pravilen float parse
                                local num = tonumber((user_input:gsub(",", ".")))
                                if num then
                                    -- Omejimo vnos med -12 in 12, kot to zahteva JSFX slider
                                    local final_gain = math.max(-12, math.min(12, num))
                                    reaper.TrackFX_SetParam(tr, f_idx, 9, final_gain)
                                end
                            end
                        end)
                        reaper.gmem_write(PROJECT_BASE + 7, 0)
                            
                    elseif cmd == 30 then
                            -- ===========================================
                            -- GLOBAL TAB SYNC (triggered from JSFX-a)
                            -- ===========================================
                            local target_page = reaper.gmem_read(PROJECT_BASE + 200)
                            for _, fx_data in ipairs(active_plugins) do
                                local slot_addr = PROJECT_BASE + fx_data.slot * 500
                                reaper.gmem_write(slot_addr + 290, target_page)
                                reaper.gmem_write(slot_addr + 3, (reaper.gmem_read(slot_addr + 3) + 1) % 1000)
                                -- Permanently save the local tab for each instance
                                reaper.SetProjExtState(0, NS, "LOCAL_TAB_" .. fx_data.guid, tostring(target_page))
                            end
                            reaper.gmem_write(PROJECT_BASE + 7, 0)
                            
                        elseif cmd == 31 then
                            -- ===========================================
                            -- LOCAL TAB SYNC (triggered from JSFX-a)
                            -- ===========================================
                            local cur_tab = reaper.gmem_read(PROJECT_BASE + sl * 500 + 290)
                            reaper.SetProjExtState(0, NS, "LOCAL_TAB_" .. c_guid, tostring(cur_tab))
                            reaper.gmem_write(PROJECT_BASE + 7, 0)
                            
                    end
                        
                     -- Overall RESET Meters & drain queued triggers after modal menu
                    reaper.gmem_write(PROJECT_BASE + 7, 0)
                    last_trigger_val = reaper.gmem_read(PROJECT_BASE + 0)
                end 
            end 
        end 
    end



-- =========================================================================
-- COMMAND EXECUTION HELPERS
-- =========================================================================
local function ExecuteCmd1(choice, data)
    local sel = data.map[choice]
    local c_guid = data.c_guid
    local btn_idx = data.btn_idx
    local sl = data.sl
    local tr = data.tr
    local key = c_guid .. ":" .. key_from_btn(btn_idx)
    local base_addr = PROJECT_BASE + sl * 500
    local addr_status = base_addr + 150 + (btn_idx - 1)
    local addr_val = base_addr + 11 + (btn_idx - 1)
    local addr_name = base_addr + 220 + (btn_idx - 1)

    if sel and sel.unlink then 
        reaper.SetProjExtState(0, NS, key, "")
        if mapping_cache[sl] then 
            mapping_cache[sl][btn_idx-1] = nil 
            if mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name[btn_idx-1] = 0 end
        end
        reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. (btn_idx - 1), "")
        reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. (btn_idx - 1), "")
        reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. (btn_idx - 1), "")
        reaper.SetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. (btn_idx - 1), "")
        
        reaper.gmem_write(addr_status, 13)
        reaper.gmem_write(addr_name, 0) 
        reaper.gmem_write(addr_val, 0)
        reaper.gmem_write(base_addr + 80 + (btn_idx - 1), 0)
        reaper.gmem_write(base_addr + 360 + (btn_idx - 1), 0)
        reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + (btn_idx - 1), 0)
        
        local cur_seq = reaper.gmem_read(base_addr + 3)
        reaper.gmem_write(base_addr + 3, (cur_seq + 1) % 1000) 
                            
    elseif sel and sel.last_touched then
        local retval, tr_num, item_num, take_num, fx_num, p_num = reaper.GetTouchedOrFocusedFX(0)
        
        -- Ignore item FX (item_num == -1 means the FX is on a track)
        if retval and item_num == -1 then
            local target_track
            if tr_num == -1 then
                target_track = reaper.GetMasterTrack(0)
            elseif tr_num >= 0 then
                target_track = reaper.GetTrack(0, tr_num)
            end
            
            if target_track then
                local target_guid = reaper.TrackFX_GetFXGUID(target_track, fx_num)
                local _, pn = reaper.TrackFX_GetParamName(target_track, fx_num, p_num, "")
                pn = pn:gsub(":", "-") 
                
                local current_fx_val = reaper.TrackFX_GetParamNormalized(target_track, fx_num, p_num)
                local val = table.concat({target_guid, 0, fx_num, p_num, pn, "1.0", reaper.GetTrackGUID(target_track), format_float(current_fx_val, 4)}, ":")
                reaper.SetProjExtState(0, NS, key, val)
                if not mapping_cache[sl] then mapping_cache[sl] = {} end
                mapping_cache[sl][btn_idx-1] = val

                local current_slot_base = PROJECT_BASE + sl * 500
                local _, color_str = reaper.GetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. (btn_idx - 1))
                local color_val = tonumber(color_str) or 1
                local unit_id = get_unit_id(pn)
                
                reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. (btn_idx - 1), tostring(unit_id))
                reaper.gmem_write(addr_status, (unit_id * 1000) + 100 + color_val)
                
                local step_size, _, _, n_steps = reaper.TrackFX_GetParameterStepSizes(target_track, fx_num, p_num)
                local raw_step = type(step_size) == "number" and step_size or (tonumber(n_steps) or 0)
                local final_steps = 0
                if raw_step > 0 then final_steps = math.floor((1 / raw_step) + 0.5) + 1 end
                
                reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + (btn_idx - 1), final_steps)
                reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. (btn_idx - 1), tostring(final_steps))
                
                local is_bypass = pn:lower():find("bypass") ~= nil
                local enc_n = encode_param_name_to_number(pn)
                if not mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name = {} end
                mapping_cache[sl].encoded_name[btn_idx-1] = enc_n
                reaper.gmem_write(addr_val, is_bypass and (1 - current_fx_val) or current_fx_val)
                reaper.gmem_write(addr_name, enc_n)
                
                local cur_seq = reaper.gmem_read(current_slot_base + 3)
                reaper.gmem_write(current_slot_base + 3, (cur_seq + 1) % 1000)
            else
                table.insert(pending_os_tasks, function()
                    reaper.MB("Could not determine the track of the last touched parameter.", "StripLink", 0)
                end)
            end
        else
            table.insert(pending_os_tasks, function()
                reaper.MB("The system did not detect any parameter movement.\n\nPlease tweak the desired parameter in any plugin first and try again.", "StripLink: Wiggle-to-link", 0)
            end)
        end

    elseif sel and sel.rename then
        local _, map_data = reaper.GetProjExtState(0, NS, key)
        if map_data ~= "" then
            local parts = safe_split(map_data)
            local old_name = parts[5] or ""
            local target_fx_idx = tonumber(parts[3])
            local target_param_num = tonumber(parts[4])
            
            -- Dynamically get native name
            local native_name = "Unknown"
            if tr and target_fx_idx and target_param_num then
                local retval, p_name = reaper.TrackFX_GetParamName(tr, target_fx_idx, target_param_num, "")
                if retval then native_name = p_name:gsub(":", "-") end
            end
            
            -- Remove dot (if exists)
            local display_name = old_name:match("^~?(.*)") or old_name
            
            -- Write original name into window title!
            local dialog_title = "Rename | Original: " .. native_name
            table.insert(pending_os_tasks, function()
                local retval, new_name = reaper.GetUserInputs(dialog_title, 1, "New name (Empty = RESET Meters):,extrawidth=20", display_name)
                
                if retval then
                    -- Restore name if empty
                    if new_name == "" then
                        parts[5] = native_name
                    else
                        parts[5] = "~" .. new_name
                    end
                    
                    local new_val_str = table.concat(parts, ":")
                    reaper.SetProjExtState(0, NS, key, new_val_str)
                    
                    if mapping_cache[sl] then mapping_cache[sl][btn_idx-1] = new_val_str end
                    
                    local enc_n = encode_param_name_to_number(parts[5])
                    if mapping_cache[sl] and mapping_cache[sl].encoded_name then 
                        mapping_cache[sl].encoded_name[btn_idx-1] = enc_n 
                    end
                    
                    reaper.gmem_write(addr_name, enc_n)
                    
                    local cur_seq = reaper.gmem_read(base_addr + 3)
                    reaper.gmem_write(base_addr + 3, (cur_seq + 1) % 1000)
                    UpdatePluginStructure(tr, sl, c_guid)
                end
            end)
        end

        elseif sel and sel.invert then
        local _, map_data = reaper.GetProjExtState(0, NS, key)
        if map_data ~= "" then
            local parts = safe_split(map_data)
            local current_curve = tonumber(parts[6]) or 1.0
            
            -- Invert (1.0 --> -1.0 and other the way around)
            local new_curve = current_curve * -1.0
            parts[6] = tostring(new_curve):gsub(",", ".")
            
            local new_val_str = table.concat(parts, ":")
            reaper.SetProjExtState(0, NS, key, new_val_str)
            
            if mapping_cache[sl] then mapping_cache[sl][btn_idx-1] = new_val_str end
            
            reaper.gmem_write(base_addr + 3, (reaper.gmem_read(base_addr + 3) + 1) % 1000)
        end

      -- IZVEDBA GRUPIRANJA PREKO DESNEGA KLIKA
      elseif sel and sel.group_assign then
         local new_group_idx = sel.val
         local group_key = "GROUP:" .. c_guid .. ":" .. (btn_idx - 1)
         
         reaper.SetProjExtState(0, NS, group_key, tostring(new_group_idx))
         reaper.gmem_write(PROJECT_BASE + sl * 500 + 360 + (btn_idx - 1), new_group_idx)
         
         if not group_cache[sl] then group_cache[sl] = {} end
         group_cache[sl][btn_idx - 1] = new_group_idx
         
         if new_group_idx > 0 then
             local master_val = nil
             local master_is_rev = false
             
             -- Poiščemo KATERIKOLI drug element v projektu, ki je v tej grupi
             for _, other_fx in ipairs(active_plugins) do
                 for j = 0, 64 do
                     if not (other_fx.guid == c_guid and j == (btn_idx - 1)) then
                         local g_key = "GROUP:" .. other_fx.guid .. ":" .. j
                         local _, g_val = reaper.GetProjExtState(0, NS, g_key)
                         
                         if (tonumber(g_val) or -1) == new_group_idx then
                             local other_base = PROJECT_BASE + other_fx.slot * 500
                             master_val = reaper.gmem_read(other_base + 11 + j)
                             
                             local _, m_map = reaper.GetProjExtState(0, NS, other_fx.guid .. ":" .. j)
                             if m_map ~= "" then
                                 local m_parts = safe_split(m_map)
                                 local m_curve = tonumber(m_parts[6]) or 1.0
                                 master_is_rev = (m_curve < 0)
                             end
                             break 
                         end
                     end
                 end
                 if master_val then break end
             end
             
             if master_val then
                 local _, map_data = reaper.GetProjExtState(0, NS, key)
                 local target_is_rev = false
                 local t_curve = 1.0
                 if map_data ~= "" then
                      local parts = safe_split(map_data)
                      t_curve = tonumber(parts[6]) or 1.0
                      target_is_rev = (t_curve < 0)
                 end
                 
                 -- Izračun vizualne (obratne) vrednosti
                 local target_visual_val = master_val
                 if master_is_rev ~= target_is_rev then
                     target_visual_val = 1.0 - master_val
                 end
                 
                 reaper.gmem_write(base_addr + 11 + (btn_idx - 1), target_visual_val)
                 
                 if map_data ~= "" then
                      local parts = safe_split(map_data)
                      local target_fx_idx = tonumber(parts[3])
                      local p_idx = tonumber(parts[4])
                      
                      if target_fx_idx and target_fx_idx ~= -1 and p_idx then
                          local p_name = parts[5] or ""
                          local is_byp = p_name:lower():find("bypass") ~= nil
                          local t_abs = math.abs(t_curve)
                          local t_base_v = is_byp and (target_visual_val < 0.5 and 1 or 0) or (target_visual_val ^ t_abs)
                          local final_v = target_is_rev and (1.0 - t_base_v) or t_base_v
                          
                          local target_track = parts[7] and reaper.BR_GetMediaTrackByGUID(0, parts[7]) or tr
                          reaper.TrackFX_SetParamNormalized(target_track, target_fx_idx, p_idx, final_v)
                      end
                 end
             end
         end

    elseif sel then
        local _, pn = reaper.TrackFX_GetParamName(tr, sel.fx_idx, sel.param, "")
        pn = pn:gsub(":", "-")
        local current_fx_val = reaper.TrackFX_GetParamNormalized(tr, sel.fx_idx, sel.param)
        local val = table.concat({sel.guid, 0, sel.fx_idx, sel.param, pn, "1.0", reaper.GetTrackGUID(tr), format_float(current_fx_val, 4)}, ":")
        
        reaper.SetProjExtState(0, NS, key, val)
        if not mapping_cache[sl] then mapping_cache[sl] = {} end
        mapping_cache[sl][btn_idx-1] = val

        local current_slot_base = PROJECT_BASE + sl * 500
        local _, color_str = reaper.GetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. (btn_idx - 1))
        local color_val = tonumber(color_str) or 1
        local unit_id = get_unit_id(pn)
        reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. (btn_idx - 1), tostring(unit_id))
        reaper.gmem_write(addr_status, (unit_id * 1000) + 100 + color_val)
        
        local step_size, _, _, n_steps = reaper.TrackFX_GetParameterStepSizes(tr, sel.fx_idx, sel.param)
        local raw_step = type(step_size) == "number" and step_size or (tonumber(n_steps) or 0)
        local final_steps = 0
        if raw_step > 0 then final_steps = math.floor((1 / raw_step) + 0.5) + 1 end
        reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + (btn_idx - 1), final_steps)
        reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. (btn_idx - 1), tostring(final_steps))
        
        local cur_v = reaper.TrackFX_GetParamNormalized(tr, sel.fx_idx, sel.param)
        local is_bypass = pn:lower():find("bypass") ~= nil
        local enc_n = encode_param_name_to_number(pn)
        if not mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name = {} end
        mapping_cache[sl].encoded_name[btn_idx-1] = enc_n
        reaper.gmem_write(addr_val, is_bypass and (1 - cur_v) or cur_v)
        reaper.gmem_write(addr_name, enc_n)
        
        local cur_seq = reaper.gmem_read(current_slot_base + 3)
        reaper.gmem_write(current_slot_base + 3, (cur_seq + 1) % 1000)
    end
    
    UpdatePluginStructure(data.tr, data.sl, data.c_guid)
end

local function ExecuteCmd2(choice, data)
    local actual_choice = choice
    
    -- Samo Module uporablja preslikavo barv in tipov gumbov (color_map)
    if data.is_module and data.color_map then
        actual_choice = data.color_map[choice] or choice
    end

    -- ČE JE TUBE (na katerem koli vtičniku)
    if data.is_tube then
        actual_choice = (actual_choice - 1) * 3 + 1
    end

    local c_guid = data.c_guid
    local btn_idx = data.btn_idx
    local sl = data.sl
    
    local color_key = "COLOR:" .. c_guid .. ":" .. key_from_btn(btn_idx)
    reaper.SetProjExtState(0, NS, color_key, tostring(actual_choice))
    
    if not color_cache[sl] then color_cache[sl] = {} end
    color_cache[sl][key_from_btn(btn_idx)] = actual_choice
    
    local _, param_val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. key_from_btn(btn_idx))
    local is_active_status = (param_val ~= "") and 100 or 0
    local _, uni = reaper.GetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. key_from_btn(btn_idx))
    local unit_id = tonumber(uni) or 0
    
    reaper.gmem_write(PROJECT_BASE + sl * 500 + 150 + (btn_idx - 1), (unit_id * 1000) + is_active_status + actual_choice)
   
    -- === DINAMIČNA SPREMEMBA DIMENZIJ V LAYOUTU ZA STIKALA ===
        if data.is_switch and data.is_module and user_layouts[sl] then
            for _, el in ipairs(user_layouts[sl]) do
                if el[5] == btn_idx and el[2] == 2 then
                    if actual_choice == 5 then
                        -- Ožja širina za stikalo 5
                        el[6] = 32
                        el[7] = 50
                    elseif actual_choice == 6 then
                        -- Dimenzije za stikalo 6
                        el[6] = 50
                        el[7] = 50
                    elseif actual_choice == 7 or actual_choice == 8 then
                        -- Dimenzije za stikalo 7+8
                        el[6] = 51
                        el[7] = 40
                    else
                        -- Standardna širina za vsa ostala stikala
                        el[6] = 32 
                        el[7] = 25
                    end
                    PushUILayout(sl)
                    break
                end
            end
        end
        -- ===
    local tr = nil
    for _, fx in ipairs(active_plugins) do
        if fx.guid == c_guid then tr = fx.tr; break end
    end
    if tr then UpdatePluginStructure(tr, sl, c_guid) end
end


-- ============================================================================
-- DYNAMIC JSFX RESIZER (FOLDER SCANNER HACK WITH ATOMIC WRITE)
-- ============================================================================
local function UpdateAllJSFXWindowSizes(style_val)
    local modified_any = false
    local i = 0
    
    -- Scan all files in the directory where this Lua script is located
    while true do
        local filename = reaper.EnumerateFiles(script_path, i)
        if not filename then break end -- End of file list
        
        local lower_name = filename:lower()
        
        -- Check if file starts with "striplink" AND IS NOT aggregator, lua, ini or png
        if lower_name:match("^striplink") and not lower_name:find("aggregator") 
           and not lower_name:match("%.lua$") and not lower_name:match("%.ini$") 
           and not lower_name:match("%.png$") then
            
            -- Preverimo točen tip vtičnika!
            local is_bus = lower_name:find("bus") ~= nil
            local is_module = lower_name:find("module") ~= nil
            
            -- Set target dimensions based on plugin type and selected style
            local target_w = is_bus and 170 or 125
            local target_h = 0
            
            if is_module then
                -- Preberemo dinamično višino iz Builderja (fallback = 635) in odštejemo višino metra
                local base_name = filename:gsub("%.[jJ][sS][fF][xX]$", ""):gsub("%s+", "_")
                local base_h = tonumber(reaper.GetExtState(NS, "PANNEL_HEIGHT_" .. base_name)) or 635
                
                if style_val == 1 then 
                    target_h = base_h - 40  -- Slim VU
                elseif style_val == 2 then 
                    target_h = base_h - 70  -- Hidden VU
                else 
                    target_h = base_h       -- Classic VU
                end
            elseif is_bus then
                if style_val == 1 then target_h = 646 
                elseif style_val == 2 then target_h = 615
                else target_h = 689 end
            else
                if style_val == 1 then target_h = 595 
                elseif style_val == 2 then target_h = 565
                else target_h = 635 end
            end
            
            local filepath = script_path .. filename
            local f = io.open(filepath, "r")
            
            if f then
                local content = f:read("*all")
                f:close()
                
                -- Regex pattern to find @gfx followed by numbers
                local search_pattern = "@gfx%s+%d+%s+%d+"
                local replacement = string.format("@gfx %d %d", target_w, target_h)
                
                local new_content, num_replacements = content:gsub(search_pattern, replacement)
                
                -- Save only if replacement was successful (using ATOMIC WRITE)
                if num_replacements > 0 then
                    local tmp_path = filepath .. ".tmp"
                    local fw = io.open(tmp_path, "w")
                    if fw then
                        fw:write(new_content)
                        fw:close()
                        
                        -- Atomic File Swap (safe for Linux/macOS to prevent 0-byte file crashes)
                        if package.config:sub(1,1) == "\\" then
                            os.remove(filepath)
                        end
                        os.rename(tmp_path, filepath)
                        
                        modified_any = true
                    else
                        table.insert(pending_os_tasks, function()
                            reaper.MB("Critical error during UI resize!\n\nCould not write to temporary file. Please check folder permissions.", "StripLink Error", 0)
                        end)
                    end
                end
            end
        end
        
        i = i + 1
    end
    
    return modified_any
end

-- ============================================================================
-- DYNAMIC PANNEL RESIZER (JSFX)
-- ============================================================================
local function ApplyPANNELHeightToJSFX(jsfx_name, target_h)
    local filepath = script_path .. jsfx_name
    local f = io.open(filepath, "r")
    if not f then
        filepath = script_path .. jsfx_name .. ".jsfx"
        f = io.open(filepath, "r")
    end
    if not f then return false end
    
    local content = f:read("*all")
    f:close()
    
    -- Vzorec, ki prepozna npr: "@gfx 125 635" in zamenja le zadnjo številko
    local search_pattern = "(@gfx%s+%d+%s+)%d+"
    local replacement = "%1" .. tostring(target_h)
    
    local new_content, num_replacements = content:gsub(search_pattern, replacement)
    
    if num_replacements > 0 then
        local tmp_path = filepath .. ".tmp"
        local fw = io.open(tmp_path, "w")
        if fw then
            fw:write(new_content)
            fw:close()
            -- Atomski prepis datoteke
            os.remove(filepath)
            os.rename(tmp_path, filepath)
            return true
        end
    end
    return false
end

local function ExecuteCmd3_Settings(choice, data)
    if choice == 1 then
        -- 1. LOCAL: Rename instance
        local current_name = (data.instance_name == "default") and "" or data.instance_name
        table.insert(pending_os_tasks, function()
            local retval, new_name = reaper.GetUserInputs("Rename Instance", 1, "Name (Empty = default):,extrawidth=20", current_name)
            
            if retval then
                local hash_val = 0
                if new_name ~= "" then
                    hash_val = CRC32(new_name) % 1000000 
                end
                reaper.SetProjExtState(0, NS, "INSTANCE_NAME_" .. data.c_guid, new_name)
                reaper.TrackFX_SetParam(data.tr, data.f_idx, 0, hash_val)
                UpdatePluginStructure(data.tr, data.sl, data.c_guid)
            end
        end)
        
    elseif choice == 2 then
        -- 2. LOCAL: Layout Builder Mode
        local sl_base = PROJECT_BASE + data.sl * 500
        local cur_mode = reaper.gmem_read(sl_base + 428)
        local new_mode = (cur_mode == 1) and 0 or 1
        reaper.gmem_write(sl_base + 428, new_mode)
        builder_state.open = (new_mode == 1)

    elseif choice >= 3 and choice <= 5 then
        -- 3. LOCAL: VU Meter Mode
        local mode = choice - 3
        reaper.SetProjExtState(0, NS, "VU_MODE_" .. data.c_guid, tostring(mode))
        
        local sl = GetFXSlot(data.tr)
        if sl > 0 then
            local local_base = PROJECT_BASE + sl * 500
            reaper.gmem_write(local_base + 336, mode)
            reaper.gmem_write(local_base + 3, (reaper.gmem_read(local_base + 3) + 1) % 1000)
        end

        elseif choice >= 6 and choice <= 10 then
        -- 4. LOCAL: VU Meter Calibration
        if choice == 10 then
            local cur_val = reaper.TrackFX_GetParam(data.tr, data.f_idx, 68)
            table.insert(pending_os_tasks, function()
                local retval, user_input = reaper.GetUserInputs("VU Meter Calibration", 1, "Enter dBFS (0 to -24):,extrawidth=20", tostring(cur_val))
                if retval then
                    local num = tonumber((user_input:gsub(",", ".")))
                    if num then
                        if num > 0 then num = -num end 
                        local final_vu = math.max(-24, math.min(0, num))
                        reaper.TrackFX_SetParam(data.tr, data.f_idx, 68, final_vu)
                    end
                end
            end)
            return
        else
            local ref_options = { [6] = 0, [7] = -6, [8] = -12, [9] = -18 }
            local selected_ref = ref_options[choice]
            reaper.TrackFX_SetParam(data.tr, data.f_idx, 68, selected_ref)
        end

    elseif choice >= 11 and choice <= 15 then
        -- 5. LOCAL: Auto Gain Speed
        local speed_factors = { [11] = 0.25, [12] = 0.50, [13] = 1.00, [14] = 2.00, [15] = 4.00 }
        local spd_factor = speed_factors[choice] or 1.00
        
        reaper.SetProjExtState(0, NS, "AG_SPEED_" .. data.c_guid, tostring(spd_factor))
        
        local sl = math.floor(reaper.TrackFX_GetParam(data.tr, data.f_idx, 1) + 0.5)
        if sl > 0 then
            local local_base = PROJECT_BASE + sl * 500
            reaper.gmem_write(local_base + 337, spd_factor)
            reaper.gmem_write(local_base + 3, (reaper.gmem_read(local_base + 3) + 1) % 1000)
        end
    end
    
    -- ==========================================
    -- GLOBAL SETTINGS
    -- ==========================================
    local num_themes = data.themes and #data.themes or 0
    local theme_start = 16  -- Spremenjeno iz 11 na 16
    local theme_end = 15 + num_themes -- Spremenjeno iz 10 na 15
    
    -- GLOBAL: Theme Selection
    if choice >= theme_start and choice <= theme_end then
        local selected_theme = data.themes[choice - theme_start + 1]
        local safe_theme_name = data.jsfx_name:gsub("%s+", "_")
        local ext_theme = reaper.GetExtState(NS, "THEME_" .. safe_theme_name)
        local current_theme = (ext_theme ~= "") and ext_theme or "Default"
        
        if selected_theme ~= current_theme then
            local success = ApplyThemeToJSFX(data.jsfx_name, selected_theme)
            if success then
                reaper.SetExtState(NS, "THEME_" .. safe_theme_name, selected_theme, true)
                reaper.PreventUIRefresh(1)
                for _, fx in ipairs(active_plugins) do
                    local name = GetBaseJSFXName(fx.tr, fx.idx)
                    if name == data.jsfx_name then
                        reaper.TrackFX_SetOffline(fx.tr, fx.idx, true)  
                        reaper.TrackFX_SetOffline(fx.tr, fx.idx, false) 
                    end
                end
                reaper.PreventUIRefresh(-1)
            else
                table.insert(pending_os_tasks, function()
                    reaper.MB("Could not apply theme. Ensure the .jsfx file is not set to Read-Only.", "StripLink Error", 0)
                end)
            end
        end
        return
    end
    
local T = num_themes
  
  if choice >= 16 + T and choice <= 18 + T then
      -- 5. GLOBAL: VU Meter Style
      local style_options = { [16 + T] = 0, [17 + T] = 1, [18 + T] = 2 }
      local selected_style = style_options[choice]
      
      local ext_vu_style = reaper.GetExtState(NS, "GLOBAL_VU_STYLE")
      local current_vu_style = tonumber(ext_vu_style) or 0
      
      if selected_style ~= current_vu_style then
          reaper.SetExtState(NS, "GLOBAL_VU_STYLE", tostring(selected_style), true)
          reaper.gmem_write(PROJECT_BASE + 208, selected_style)
          
          if selected_style == 2 then
              table.insert(pending_os_tasks, function()
                  reaper.MB("Because the top VU meters are now hidden, the Settings Menu icon has been moved to the bottom right corner of the StripLink interface.", "StripLink: Layout Changed", 0)
              end)
          end
          
          local success = UpdateAllJSFXWindowSizes(selected_style)
          if success then
              reaper.PreventUIRefresh(1)
              for _, fx in ipairs(active_plugins) do
                  reaper.TrackFX_SetOffline(fx.tr, fx.idx, true)  
                  reaper.TrackFX_SetOffline(fx.tr, fx.idx, false) 
              end
              reaper.TrackList_AdjustWindows(true)
              reaper.PreventUIRefresh(-1)
          end
      end

  elseif choice >= 19 + T and choice <= 23 + T then
      -- 6. GLOBAL: VU Peak LED Threshold (Prej 24+T do 28+T)
      local selected_peak = 0
      if choice == 19 + T then selected_peak = 0
      elseif choice == 20 + T then selected_peak = -1
      elseif choice == 21 + T then selected_peak = -3
      elseif choice == 22 + T then selected_peak = -6
      elseif choice == 23 + T then
          local ext_cur = reaper.GetExtState(NS, "GLOBAL_PEAK_THRESH")
          local cur_val = tonumber(ext_cur) or 0
          
          table.insert(pending_os_tasks, function()
              local retval, user_input = reaper.GetUserInputs("Peak LED Threshold", 1, "Enter dBFS (0 to -48):,extrawidth=20", tostring(cur_val))
              
              if retval then
                  local num = tonumber((user_input:gsub(",", ".")))
                  if num then
                      if num > 0 then num = -num end
                      local final_peak = math.max(-48, math.min(0, num))
                      reaper.SetExtState(NS, "GLOBAL_PEAK_THRESH", tostring(final_peak), true)
                      reaper.gmem_write(PROJECT_BASE + 209, final_peak)
                  end
              end
          end)
          return
      end
      reaper.SetExtState(NS, "GLOBAL_PEAK_THRESH", tostring(selected_peak), true)
      reaper.gmem_write(PROJECT_BASE + 209, selected_peak)
      
  elseif choice >= 24 + T and choice <= 28 + T then
      -- 7. GLOBAL: GR Meter Range (Prej 29+T do 33+T)
      if choice == 28 + T then
          local ext_cur = reaper.GetExtState(NS, "GLOBAL_MAX_GR_DB")
          local cur_val = tonumber(ext_cur) or 12
          
          table.insert(pending_os_tasks, function()
              local retval, user_input = reaper.GetUserInputs("GR Meter Range", 1, "Enter dB (1 to 24):,extrawidth=20", tostring(cur_val))
              if retval then
                  local num = tonumber((user_input:gsub(",", ".")))
                  if num then
                      local final_gr = math.max(1, math.min(24, math.abs(num)))
                      reaper.SetExtState(NS, "GLOBAL_MAX_GR_DB", tostring(final_gr), true)
                      reaper.gmem_write(PROJECT_BASE + 204, final_gr)
                  end
              end
          end)
          return
      else
          local gr_options = { [24 + T] = 6, [25 + T] = 12, [26 + T] = 18, [27 + T] = 24 }
          local selected_gr = gr_options[choice]
          reaper.SetExtState(NS, "GLOBAL_MAX_GR_DB", tostring(selected_gr), true)
          reaper.gmem_write(PROJECT_BASE + 204, selected_gr)
      end
      
  elseif choice >= 29 + T and choice <= 30 + T then
      -- 8. GLOBAL: Metering Display Mode (Prej 34+T do 35+T)
      local mode = (choice == 29 + T) and "0" or "1"
      reaper.SetProjExtState(0, NS, "GLOBAL_METER_MODE", mode)
      reaper.gmem_write(PROJECT_BASE + 202, tonumber(mode))

  elseif choice >= 31 + T and choice <= 37 + T then
      -- 9. GLOBAL: Font Size (Prej 36+T do 42+T)
      local font_options = { 
          [31 + T] = 8, 
          [32 + T] = 9, 
          [33 + T] = 10, 
          [34 + T] = 11, 
          [35 + T] = 12, 
          [36 + T] = 14, 
          [37 + T] = 16 
      }
      local selected_font = font_options[choice]
      reaper.SetExtState(NS, "GLOBAL_FONT_SIZE", tostring(selected_font), true)
      reaper.gmem_write(PROJECT_BASE + 205, selected_font)
      
  elseif choice == 38 + T then
      -- 10. GLOBAL: Tooltips (Prej 43+T)
      local new_val = data.tooltips_on and "0" or "1"
      reaper.SetExtState(NS, "USER_KNOB_TOOLTIPS", new_val, true)
      reaper.gmem_write(PROJECT_BASE + 203, data.tooltips_on and 2 or 1)
      
  -- Mouse control settings
  elseif choice >= 39 + T and choice <= 43 + T then
      -- Standard Speed (Prej 44+T do 48+T)
      local std_opts = { [39 + T] = 0.5, [40 + T] = 0.75, [41 + T] = 1.0, [42 + T] = 1.5, [43 + T] = 2.0 }
      local selected_std = std_opts[choice]
      reaper.SetExtState(NS, "GLOBAL_MOUSE_STD", tostring(selected_std), true)
      reaper.gmem_write(PROJECT_BASE + 210, selected_std)
      
  elseif choice >= 44 + T and choice <= 46 + T then
      -- Fine Speed (Prej 49+T do 51+T)
      local fine_opts = { [44 + T] = 0.05, [45 + T] = 0.1, [46 + T] = 0.25 }
      local selected_fine = fine_opts[choice]
      reaper.SetExtState(NS, "GLOBAL_MOUSE_FINE", tostring(selected_fine), true)
      reaper.gmem_write(PROJECT_BASE + 211, selected_fine)
  end
end

local function ExecuteCmd4(choice, data)
    local tr = data.tr
    local sl = data.sl
    local c_guid = data.c_guid
    local meter_id = data.meter_id
    local container_idx = data.container_idx
    local c_count = data.c_count
    local fx_list = data.fx_list

    local function GetContainerAddr(sub_i)
        local _, addr_str = reaper.TrackFX_GetNamedConfigParm(tr, container_idx, "container_item." .. sub_i)
        return tonumber(addr_str)
    end

    if choice == 1 then
        -- --- RESET Meters METER ---
        reaper.PreventUIRefresh(1)
        
        local m_type = (meter_id == 99) and 1 or (meter_id == 100 and 2 or 3)
        reaper.SetProjExtState(0, NS, "METER_SRC_" .. c_guid .. "_" .. m_type, "")

        -- Eksaktne maske
        local mask_to_clear = (m_type == 1) and 240 or ((m_type == 2) and 3840 or 12288)

        for j = 0, c_count - 1 do
            local addr = GetContainerAddr(j)
            if addr then
                local map_0 = reaper.TrackFX_GetPinMappings(tr, addr, 1, 0)
                local map_1 = reaper.TrackFX_GetPinMappings(tr, addr, 1, 1)
                reaper.TrackFX_SetPinMappings(tr, addr, 1, 0, map_0 & ~mask_to_clear, 0)
                reaper.TrackFX_SetPinMappings(tr, addr, 1, 1, map_1 & ~mask_to_clear, 0)
            end
        end
        reaper.PreventUIRefresh(-1)
        
        mapping_cache[sl] = nil
        
    elseif choice > 1 then
        -- --- CONNECT METER ---
        local target = fx_list[choice - 1]
        local m_type = (meter_id == 99) and 1 or (meter_id == 100 and 2 or 3)
        local target_guid = reaper.TrackFX_GetFXGUID(tr, target.internal_idx)
        reaper.SetProjExtState(0, NS, "METER_SRC_" .. c_guid .. "_" .. m_type, target_guid or "")
        
        reaper.PreventUIRefresh(1)
        reaper.SetMediaTrackInfo_Value(tr, "I_NCHAN", 14)
        reaper.TrackFX_SetNamedConfigParm(tr, container_idx, "container_nch", "14")

        local function SetSafePin(target_addr, out_pin, clear_mask, add_bit)
            if not target_addr then return end
            reaper.TrackFX_SetNamedConfigParm(tr, target_addr, "nchan", "14")
            local curr = reaper.TrackFX_GetPinMappings(tr, target_addr, 1, out_pin)
            reaper.TrackFX_SetPinMappings(tr, target_addr, 1, out_pin, (curr & ~clear_mask) | add_bit, 0)
        end

        if m_type == 3 then
            SetSafePin(target.internal_idx, 0, 12288, 1 << 12)
            SetSafePin(target.internal_idx, 1, 12288, 1 << 13)
        else
            if target.sub_idx == 0 then 
                table.insert(pending_os_tasks, function()
                    reaper.MB("Gain reduction metering cannot be fully routed.\n\nThere must be at least one FX before '" .. target.name .. "' in the container to tap the uncompressed signal.\n\nPlease insert any dummy plugin (e.g., Volume/Pan) before it and try again.", "StripLink: Metering Warning", 0)
                end)
                reaper.PreventUIRefresh(-1)
                return 
            end
            
            local prev_addr = GetContainerAddr(target.sub_idx - 1)
            local curr_addr = target.internal_idx
            
            if m_type == 1 then
                local m_clear = 240
                SetSafePin(prev_addr, 0, m_clear, 1 << 4)
                SetSafePin(prev_addr, 1, m_clear, 1 << 5)
                SetSafePin(curr_addr, 0, m_clear, 1 << 6)
                SetSafePin(curr_addr, 1, m_clear, 1 << 7)
            else
                local m_clear = 3840
                SetSafePin(prev_addr, 0, m_clear, 1 << 8)
                SetSafePin(prev_addr, 1, m_clear, 1 << 9)
                SetSafePin(curr_addr, 0, m_clear, 1 << 10)
                SetSafePin(curr_addr, 1, m_clear, 1 << 11)
            end
        end

        -- AGGREGATOR
        for i = 0, c_count - 1 do
            local addr = GetContainerAddr(i)
            if addr then
                local _, s_name = reaper.TrackFX_GetFXName(tr, addr, "")
                if s_name:lower():find("aggregator") then
                    for p = 0, 13 do reaper.TrackFX_SetPinMappings(tr, addr, 0, p, 1 << p, 0) end
                    reaper.TrackFX_SetPinMappings(tr, addr, 1, 0, 1, 0)
                    reaper.TrackFX_SetPinMappings(tr, addr, 1, 1, 2, 0)
                    reaper.TrackFX_SetPinMappings(tr, addr, 1, 2, 4, 0)
                    reaper.TrackFX_SetPinMappings(tr, addr, 1, 3, 8, 0)
                    for p = 4, 13 do reaper.TrackFX_SetPinMappings(tr, addr, 1, p, 0, 0) end
                end
            end
        end
        reaper.PreventUIRefresh(-1)
        
        mapping_cache[sl] = nil

    end
end

local function ExecuteCmd5(choice, data)
    local c_guid = data.c_guid
    local k_idx = data.k_idx
    local sl = data.sl
    local tr = data.tr

    local new_group_idx = choice - 1
    local group_key = "GROUP:" .. c_guid .. ":" .. k_idx
    
    reaper.SetProjExtState(0, NS, group_key, tostring(new_group_idx))
    reaper.gmem_write(PROJECT_BASE + sl * 500 + 360 + k_idx, new_group_idx)
    
    if not group_cache[sl] then group_cache[sl] = {} end
    group_cache[sl][k_idx] = new_group_idx
    
    if new_group_idx > 0 then
        local master_val = nil
        for _, other_fx in ipairs(active_plugins) do
            if other_fx.guid ~= c_guid then
                local g_key = "GROUP:" .. other_fx.guid .. ":" .. k_idx
                local _, g_val = reaper.GetProjExtState(0, NS, g_key)
                if (tonumber(g_val) or -1) == new_group_idx then
                    local other_base = PROJECT_BASE + other_fx.slot * 500
                    master_val = reaper.gmem_read(other_base + 11 + k_idx)
                    break 
                end
            end
        end
        
        if master_val then
            reaper.gmem_write(PROJECT_BASE + sl * 500 + 11 + k_idx, master_val)
            local _, map_data = reaper.GetProjExtState(0, NS, c_guid .. ":" .. k_idx)
            if map_data ~= "" then
                 local parts = safe_split(map_data)
                 local target_fx_idx = tonumber(parts[3])
                 local p_idx = tonumber(parts[4])
                 
                 if target_fx_idx and target_fx_idx ~= -1 and p_idx then
                     local p_name = parts[5] or ""
                     local is_byp = p_name:lower():find("bypass") ~= nil
                     local o_curve = tonumber(parts[6]) or 1.0
                     local o_abs = math.abs(o_curve)
                     local o_rev = (o_curve < 0)
                     local o_curved = master_val ^ o_abs
                     local o_target = o_rev and (1.0 - o_curved) or o_curved
                     
                     local final_v = is_byp and (1 - master_val) or o_target
                     local target_track = parts[7] and reaper.BR_GetMediaTrackByGUID(0, parts[7]) or tr
                     reaper.TrackFX_SetParamNormalized(target_track, target_fx_idx, p_idx, final_v)
                 end
            end
        end
    end
end

local function ExecuteCmd6(choice, data)
    local opts = {
        {name="Linear (1:1)", val=1.0},
        {name="Fast - Extreme", val=5.0},
        {name="Fast - Standard", val=3.32},
        {name="Fast - Moderate", val=2.0},
        {name="Slow - Standard", val=0.3},
        {name="Slow - Moderate", val=0.5}
    }
    
    if choice > 0 and opts[choice] then 
        local selected_opt = opts[choice]
        
        local current_p = tonumber(data.parts[6]) or 1.0
        local sign = (current_p < 0) and -1 or 1
        
        local new_curve_val = selected_opt.val * sign
        
        data.parts[6] = tostring(new_curve_val):gsub(",", ".")
        local new_val_str = table.concat(data.parts, ":")                                      
        reaper.SetProjExtState(0, NS, data.key, new_val_str)
        if mapping_cache[data.sl] then mapping_cache[data.sl][data.k_idx] = new_val_str end
        

        local c_guid = data.key:match("^(.-):")
        local tr = nil
        for _, fx in ipairs(active_plugins) do
            if fx.guid == c_guid then tr = fx.tr; break end
        end
        if tr then UpdatePluginStructure(tr, data.sl, c_guid) end
    end
end


local function ExecuteCmd20(choice, data)
    local selected_color = choice - 1
    local col_eq, col_dyn, col_fx = data.col_eq, data.col_dyn, data.col_fx
    if data.clicked_tab == 1 then col_eq = selected_color
    elseif data.clicked_tab == 2 then col_dyn = selected_color
    elseif data.clicked_tab == 3 then col_fx = selected_color end
    local new_packed_val = (col_eq * 100) + (col_dyn * 10) + col_fx
    reaper.TrackFX_SetParam(data.tr, data.f_idx, data.target_param_idx, new_packed_val)
end

local function ExecuteCmd21(choice, data)
    local sel = data.map[choice]
    if sel then
        local jsfx_name = GetBaseJSFXName(data.tr, data.f_idx)
        local is_module = jsfx_name:lower():find("module") ~= nil
        
        local cur_packed = 0
        local cur_btn = 0
        
        -- PAMETNO BRANJE PRED ZAPISOM V NABIRALNIK
        if is_module then
            local ext_ovr_base = PROJECT_BASE + 50000 + (data.sl * 200)
            cur_packed = reaper.gmem_read(ext_ovr_base + 64 + sel.slot_id)
            cur_btn = reaper.gmem_read(ext_ovr_base + sel.slot_id)
        else
            cur_packed = reaper.gmem_read(PROJECT_BASE + data.sl * 500 + 342 + sel.slot_id)
            cur_btn = reaper.gmem_read(PROJECT_BASE + data.sl * 500 + 300 + sel.slot_id)
        end
        
        local cur_mtr = math.floor(cur_packed / 10)
        local base_addr = PROJECT_BASE + data.sl * 500

        -- Priprava podatkov za nabiralnik
        reaper.gmem_write(base_addr + 491, sel.slot_id)

        if sel.action == "assign" then
            -- Klic GetElementType premaknjen sem, kjer je sel.btn_idx zagotovo številka
            local el_typ = GetElementType(sel.btn_idx, jsfx_name, data.sl)
            
            reaper.gmem_write(base_addr + 492, sel.btn_idx)
            reaper.gmem_write(base_addr + 493, el_typ + (cur_mtr * 10))
        elseif sel.action == "meter" then
            local cur_typ = cur_packed % 10
            reaper.gmem_write(base_addr + 492, cur_btn)
            reaper.gmem_write(base_addr + 493, cur_typ + (sel.val * 10))
        end
        
        -- POŠLJI V NABIRALNIK IN SPROŽI JSFX
        reaper.gmem_write(base_addr + 490, 1)
        reaper.gmem_write(base_addr + 3, (reaper.gmem_read(base_addr + 3) + 1) % 1000)
    end
end


-- =========================================================================
-- REAIMGUI MENU ROUTING
-- =========================================================================
-- Universal parser: Converts REAPER SWELL menu string into ReaImGui structure
local function DrawImGuiSwellMenu(ctx, menu_str)
    local choice = 0
    local map_idx = 1
    local parts = {}
    for part in (menu_str.."|"):gmatch("(.-)|") do table.insert(parts, part) end
    
    local p = 1
    local function parse_level()
        while p <= #parts do
            local part = parts[p]
            local unique_id_suffix = "##" .. tostring(p)
            p = p + 1
            
            if part == "" then
                reaper.ImGui_Separator(ctx)
            elseif part == "<" then
                return
            elseif part:sub(1,1) == "~" then
                reaper.ImGui_SeparatorText(ctx, part:sub(2))
            elseif part:sub(1,1) == ">" then
                local label = part:sub(2)
                if reaper.ImGui_BeginMenu(ctx, label .. unique_id_suffix) then
                    parse_level()
                    reaper.ImGui_EndMenu(ctx)
                else
                    local depth = 1
                    while p <= #parts and depth > 0 do
                        local next_part = parts[p]
                        if next_part:sub(1,1) == ">" then depth = depth + 1
                        elseif next_part == "<" then depth = depth - 1 end
                        if next_part ~= "" and next_part ~= "<" and next_part:sub(1,1) ~= ">" and next_part:sub(1,1) ~= "#" and next_part:sub(1,1) ~= "~" then
                            map_idx = map_idx + 1
                        end
                        p = p + 1
                    end
                end
            elseif part:sub(1,1) == "#" then
                reaper.ImGui_TextDisabled(ctx, part:sub(2))
            elseif part:sub(1,1) == "!" then
                -- ONEMOGOČEN MENI ITEM (Ohrani indeks, a se ga ne da klikniti!)
                reaper.ImGui_MenuItem(ctx, part:sub(2) .. unique_id_suffix, nil, false, false)
                map_idx = map_idx + 1
            else
                local label = part

                if reaper.ImGui_MenuItem(ctx, label .. unique_id_suffix) then 
                    choice = map_idx 
                end
                map_idx = map_idx + 1
            end
        end
    end
    
    parse_level()
    return choice
end

-- ============================================================================
-- CLEAR SECTION & HYBRID SAVE SUPPORT
-- ============================================================================
local function ClearSectionMapping(c_guid, sl, btn_list)
    local base_addr = PROJECT_BASE + sl * 500
    for _, k_idx in ipairs(btn_list) do
        reaper.SetProjExtState(0, NS, c_guid .. ":" .. k_idx, "")
        if mapping_cache[sl] then 
            mapping_cache[sl][k_idx] = nil 
            if mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name[k_idx] = 0 end
        end
        reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. k_idx, "")
        reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. k_idx, "")
        reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. k_idx, "")
        reaper.SetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. k_idx, "")
        
        reaper.gmem_write(base_addr + 150 + k_idx, 13) 
        reaper.gmem_write(base_addr + 11 + k_idx, 0)
        reaper.gmem_write(base_addr + 80 + k_idx, 0)
        reaper.gmem_write(base_addr + 220 + k_idx, 0)
        reaper.gmem_write(base_addr + 360 + k_idx, 0)
        reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + k_idx, 0)
    end
    -- Force UI refresh!
    reaper.gmem_write(base_addr + 3, (reaper.gmem_read(base_addr + 3) + 1) % 1000)
end

local function SaveHybridMapping(track, fx_idx, fx_hash, sections_list)
    local guid = reaper.TrackFX_GetFXGUID(track, fx_idx)
    local jsfx_name = GetBaseJSFXName(track, fx_idx)
    local INI_DB = GetINIDB(jsfx_name)
    
    local custom_hash = math.floor(reaper.TrackFX_GetParam(track, fx_idx, 0) + 0.5)
    local custom_suffix = (custom_hash > 0) and ("_" .. tostring(custom_hash)) or ""
    
    local section_suffix = "HYBRID_" .. table.concat(sections_list, "_")
    local section = fx_hash .. "_" .. section_suffix .. custom_suffix
    
    local function proceed_with_save()
        if not INI_DB[section] then
            INI_DB[section] = {}
            table.insert(INI_DB._order, section)
        end
        
        local orig_name = GetOriginalFXName(track, fx_idx)
        local _, alias, raw, tag = GenerateHashAndAlias(orig_name)
        
        -- Dictionary ensure
        if not INI_DB["DICTIONARY"] then INI_DB["DICTIONARY"] = {}; table.insert(INI_DB._order, 1, "DICTIONARY") end
        if not INI_DB["DICTIONARY"][fx_hash] then
            INI_DB["DICTIONARY"][fx_hash] = raw .. tag .. "|" .. alias
        end
        
        if custom_hash > 0 then
            local _, saved_name = reaper.GetProjExtState(0, NS, "INSTANCE_NAME_" .. guid)
            if saved_name and saved_name ~= "" then
                INI_DB["DICTIONARY"][tostring(custom_hash)] = saved_name
            end
        end
        
        -- Clear old btn entries to prevent ghosting
        for j = 0, 70 do INI_DB[section]["Btn"..j] = nil end
        
        -- Gather ALL buttons mapped to this plugin across ALL sections
        for b = 0, 64 do
            local _, param_val = reaper.GetProjExtState(0, NS, guid .. ":" .. b)
            if param_val ~= "" then
                local parts = safe_split(param_val)
                local p_num = tonumber(parts[4])
                local curve_p = tonumber((tostring(parts[6]):gsub(",", "."))) or 1.0
                local default_v = tonumber((tostring(parts[8]):gsub(",", "."))) or 0.5
                local current_p_name = parts[5] and parts[5]:gsub(",", "") or ""
                
                local _, color_val = reaper.GetProjExtState(0, NS, "COLOR:" .. guid .. ":" .. b)
                local style_num = tonumber(color_val) or 13
                
                if p_num then
                    -- For HYBRIDS, we use the ABSOLUTE button index (BtnX) so it loads back exactly where it was
                    local line = string.format("0,%d,%d,%s,%s,%s", p_num, math.floor(style_num), format_float(curve_p, 2), format_float(default_v, 4), current_p_name)
                    INI_DB[section]["Btn" .. b] = line
                end
            end
        end
        -- SHRANJEVANJE LAYOUTA ZA HYBRID
        local slot = GetFXSlot(track)
        if jsfx_name:lower():find("module") ~= nil and user_layouts[slot] then
             local layout_sec = section .. "_LAYOUT"
             if not INI_DB[layout_sec] then
                 table.insert(INI_DB._order, layout_sec)
             end
             INI_DB[layout_sec] = {} 
             
             local el_counter = 1
             for _, el in ipairs(user_layouts[slot]) do
                 local t_tab = el[12]
                 local is_sys = (el[1] >= 900)
                 
                 -- Preverimo, ali element pripada kateremu izmed aktivnih Hybrid zavihkov
                 local tab_valid = false
                 for _, sec in ipairs(sections_list) do
                     if (sec == "EQ" and t_tab == 1) or 
                        (sec:find("DYN") and t_tab == 2) or 
                        (sec == "PRE" and t_tab == 3) or 
                        (sec == "POST" and t_tab == 3) then
                         tab_valid = true
                         break
                     end
                 end
                 
                 if tab_valid and not is_sys then
                     local text_str = (el[9] and el[9] ~= "") and el[9] or " "
                     local line = string.format("%d,%d,%d,%d,%d,%d,%d,%d,%s,%d,%d,%d,%g,%d",
                         math.floor((el[1] or 0) + 0.5), math.floor((el[2] or 0) + 0.5), math.floor((el[3] or 0) + 0.5), 
                         math.floor((el[4] or 0) + 0.5), math.floor((el[5] or 0) + 0.5), math.floor((el[6] or 0) + 0.5), 
                         math.floor((el[7] or 0) + 0.5), math.floor((el[8] or 0) + 0.5), text_str, 
                         math.floor((el[10] or 14) + 0.5), math.floor((el[11] or 0) + 0.5), math.floor((el[12] or 0) + 0.5), 
                         (el[13] or 0), math.floor((el[14] or 0) + 0.5))
                     
                     INI_DB[layout_sec]["El_" .. el_counter] = line
                     el_counter = el_counter + 1
                 end
             end
        end
        INI_DB._comments[section] = {"; HYBRID Alias: " .. alias .. " (" .. table.concat(sections_list, " + ") .. ")"}
        local filepath = script_path .. jsfx_name .. "_mappings.ini"
        WriteINI_FromRAM(filepath, INI_DB)
    end

    -- Check for existing mapping in RAM and trigger async save
    if INI_DB[section] then
        table.insert(pending_os_tasks, function()
            local ans = reaper.MB("Overwrite existing HYBRID mapping (" .. table.concat(sections_list, " + ") .. ")?", "StripLink: Overwrite", 4)
            if ans == 6 then proceed_with_save() end
        end)
    else
        proceed_with_save()
    end
end

local function ExecuteCmd3_Mapping(choice, data)
    local entry = data.map[choice]
    if not entry then return end
    
    local c_guid = data.c_guid
    local page_name = data.page_name
    local sub_slot = data.sub_slot
    local tr = data.tr
    local f_idx = data.f_idx
    local sl = data.sl
    
    -- 1. Definiramo akcijo ZUNAJ pogojev, da bo na voljo za vse ukaze (Save, Copy, Paste, Load...)
    local function execute_action()
        if entry.type == "copy" then
            -- Full Section Clone: Copy Mappings, Values, Names, Colors, Units & Curves
            clipboard_buffer = {
                hash = entry.hash,
                alias = entry.alias,
                jsfx_name = entry.jsfx_name, 
                page_name = entry.page_name, -- Store the section type
                items = {},
                layout = {}
            }
            
            -- Build guid_to_rel_idx correctly based on mapped chain
            local chain_hashes = {}
            for h in entry.hash:gmatch("([A-Z0-9]+)") do table.insert(chain_hashes, h) end
            
            local guid_to_rel_idx = {}
            local consumed_guid = {}
            if entry.context_fx_list then
                for rel_i, target_hash in ipairs(chain_hashes) do
                    for _, ctx_fx in ipairs(entry.context_fx_list) do
                        local ctx_guid = reaper.TrackFX_GetFXGUID(tr, ctx_fx.idx)
                        if (ctx_fx.hash == target_hash or ctx_fx.fallback_hash == target_hash) and not consumed_guid[ctx_guid] then
                            guid_to_rel_idx[ctx_guid] = rel_i - 1
                            consumed_guid[ctx_guid] = true
                            break
                        end
                    end
                end
            end
            
            for i, k_idx in ipairs(entry.btn_list) do
                local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. k_idx)
                if val and val ~= "" then
                    local parts = safe_split(val)
                    local t_guid = parts[1]
                    local t_fx_idx = tonumber(parts[3])
                    local p_idx = tonumber(parts[4])
                    local p_name = parts[5] or ""
                    local curve = parts[6] or "1.0"
                    local default_v = parts[8] or "0.5"
                    
                    local live_val = 0.5
                    if t_fx_idx and t_fx_idx ~= -1 and p_idx then
                        local target_track = (parts[7] and parts[7] ~= "") and reaper.BR_GetMediaTrackByGUID(0, parts[7]) or tr
                        live_val = reaper.TrackFX_GetParamNormalized(target_track, t_fx_idx, p_idx)
                    end
                    
                    local _, col_val = reaper.GetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. k_idx)
                    local _, unit_val = reaper.GetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. k_idx)
                    local _, steps_val = reaper.GetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. k_idx)
                    local _, group_val = reaper.GetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. k_idx)
                    
                    local rel_fx_idx = guid_to_rel_idx[t_guid] or 0
                    
                    -- Store relatively (1 to N) to support pasting across generic slots
                    clipboard_buffer.items[i] = {
                        p_num = p_idx,
                        p_name = p_name,
                        curve = curve,
                        default_val = default_v,
                        val_norm = live_val,
                        color = col_val ~= "" and col_val or "13",
                        unit = unit_val ~= "" and unit_val or "0",
                        steps = steps_val ~= "" and steps_val or "0",
                        group = group_val ~= "" and group_val or "0",
                        rel_fx_idx = rel_fx_idx
                    }
                end
            end
            if user_layouts[sl] then
                local target_tab = 1
                if entry.page_name == "EQ" then target_tab = 1
                elseif entry.page_name == "DYN" then target_tab = 2
                elseif entry.page_name == "FX" then target_tab = 3
                end
                
                local divider_y = 350
                for _, el in ipairs(user_layouts[sl]) do
                    if el[12] == target_tab and el[1] >= 900 and el[2] == 6 then
                        divider_y = el[4]
                        break
                    end
                end
                
                for _, el in ipairs(user_layouts[sl]) do
                    if el[12] == target_tab and el[1] < 900 then
                        local is_bottom = false
                        local param_id = math.floor(el[5] or 0)
                        
                        if target_tab == 2 then
                            if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then is_bottom = true
                            elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then is_bottom = false
                            else is_bottom = ((el[4] or 0) >= divider_y) end
                        elseif target_tab == 3 then
                            if param_id >= 45 and param_id <= 56 then is_bottom = true
                            elseif param_id >= 39 and param_id <= 44 then is_bottom = false
                            else is_bottom = ((el[4] or 0) >= divider_y) end
                        end
                        
                        local belongs_to_this_save = (entry.page_name == "EQ") or 
                                                     (entry.sub_slot == 1 and not is_bottom) or 
                                                     (entry.sub_slot == 2 and is_bottom)
                                                     
                        if belongs_to_this_save then
                            local new_el = {}
                            for i_el, v_el in ipairs(el) do new_el[i_el] = v_el end
                            table.insert(clipboard_buffer.layout, new_el)
                        end
                    end
                end
            end
            
        elseif entry.type == "paste" then
            -- Apply Full Section Clone to target instance
            -- Strict safety check: Ensure Target Hash, Plugin Layout, AND Section match exactly
            if clipboard_buffer.hash == entry.hash and clipboard_buffer.jsfx_name == entry.jsfx_name and clipboard_buffer.page_name == entry.page_name then
                local base_addr = PROJECT_BASE + sl * 500
                local tr_guid = reaper.GetTrackGUID(tr)
                
                local chain_hashes = {}
                for h in entry.hash:gmatch("([A-Z0-9]+)") do table.insert(chain_hashes, h) end
                
                -- Check if target section (e.g., DYN 2) ALREADY has an existing linked plugin
                local existing_target_fx_idx = nil
                for _, k_idx in ipairs(entry.btn_list) do
                    local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. k_idx)
                    if val and val ~= "" then
                        local parts = safe_split(val)
                        local t_fx_idx = tonumber(parts[3])
                        if t_fx_idx and t_fx_idx ~= -1 then
                            existing_target_fx_idx = t_fx_idx
                            break
                        end
                    end
                end

                -- Mark plugins that are ALREADY occupied on other sections of this StripLink (e.g., on DYN 1)
                local consumed_fx = {}
                for b = 0, 64 do
                    local is_current_btn = false
                    for _, b_id in ipairs(entry.btn_list) do
                        if b_id == b then is_current_btn = true; break end -- <== ODSTRANJEN key_from_btn()
                    end
                    
                    if not is_current_btn then
                        local _, mapped_val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. b)
                        if mapped_val and mapped_val ~= "" then
                            local p_parts = safe_split(mapped_val)
                            local m_fx_idx = tonumber(p_parts[3])
                            if m_fx_idx then
                                consumed_fx[m_fx_idx] = true
                            end
                        end
                    end
                end

                -- Determine target plugin for each link in the chain
                local rel_to_target_fx = {}
                if existing_target_fx_idx and #chain_hashes == 1 then
                    -- If target section already points to a specific plugin, keep it!
                    rel_to_target_fx[0] = {
                        idx = existing_target_fx_idx,
                        guid = reaper.TrackFX_GetFXGUID(tr, existing_target_fx_idx)
                    }
                elseif entry.context_fx_list then
                     -- If section is empty, find the first UNOCCUPIED plugin of that type
                     for rel_i, target_hash in ipairs(chain_hashes) do
                         for _, ctx_fx in ipairs(entry.context_fx_list) do
                             if (ctx_fx.hash == target_hash or ctx_fx.fallback_hash == target_hash) and not consumed_fx[ctx_fx.idx] then
                                 rel_to_target_fx[rel_i - 1] = {
                                     idx = ctx_fx.idx,
                                     guid = reaper.TrackFX_GetFXGUID(tr, ctx_fx.idx)
                                 }
                                 consumed_fx[ctx_fx.idx] = true
                                 break
                             end
                         end
                         
                         -- FAILSAFE: Če ga nismo našli zaradi 'consumed_fx' (npr. zaradi starih izbrisanih povezav), prisilno vzamemo prvega ujemajočega!
                         if not rel_to_target_fx[rel_i - 1] then
                             for _, ctx_fx in ipairs(entry.context_fx_list) do
                                 if (ctx_fx.hash == target_hash or ctx_fx.fallback_hash == target_hash) then
                                     rel_to_target_fx[rel_i - 1] = {
                                         idx = ctx_fx.idx,
                                         guid = reaper.TrackFX_GetFXGUID(tr, ctx_fx.idx)
                                     }
                                     break
                                 end
                             end
                         end
                     end
                 end
                
                -- Copy all knob settings and parameters
                for i, k_idx in ipairs(entry.btn_list) do
                    local saved = clipboard_buffer.items[i]
                    if saved then
                        local target_fx_info = rel_to_target_fx[saved.rel_fx_idx] or rel_to_target_fx[0]
                        if target_fx_info then
                            local t_fx_idx = target_fx_info.idx
                            local t_guid = target_fx_info.guid
                            local p_num = saved.p_num
                            
                            -- Set actual VST parameter normalized value
                            reaper.TrackFX_SetParamNormalized(tr, t_fx_idx, p_num, saved.val_norm)
                            
                            local new_val_str = table.concat({
                                t_guid, 0, t_fx_idx, p_num, saved.p_name, 
                                tostring(saved.curve):gsub(",", "."), tr_guid, 
                                tostring(saved.default_val):gsub(",", ".")
                            }, ":")
                            
                            reaper.SetProjExtState(0, NS, c_guid .. ":" .. k_idx, new_val_str)
                            
                            -- Save Visual / Behavior ExtStates
                            reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. k_idx, saved.color)
                            reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. k_idx, saved.unit)
                            reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. k_idx, saved.steps)
                            reaper.SetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. k_idx, saved.group)
                            
                            -- Calculate exact un-curved GMEM position for JSFX UI
                            local _, native_p_name = reaper.TrackFX_GetParamName(tr, t_fx_idx, p_num, "")
                            local is_bypass = native_p_name:lower():find("bypass") ~= nil
                            local curve_p = tonumber((tostring(saved.curve):gsub(",", "."))) or 1.0
                            local p_abs = math.abs(curve_p)
                            local is_rev = (curve_p < 0)
                            local effective_v = is_rev and (1.0 - saved.val_norm) or saved.val_norm
                            local final_gmem_v = is_bypass and (saved.val_norm > 0.5 and 0 or 1) or (effective_v ^ (1 / p_abs))
                            
                            local addr_val = base_addr + 11 + k_idx
                            reaper.gmem_write(addr_val, final_gmem_v)
                            if not last_gmem_values[addr_val] then last_gmem_values[addr_val] = {} end
                            last_gmem_values[addr_val].val = final_gmem_v
                            last_gmem_values[addr_val].time = reaper.time_precise()

                            local enc_n = encode_param_name_to_number(saved.p_name)
                            reaper.gmem_write(base_addr + 80 + k_idx, 0)
                            local color_num = tonumber(saved.color) or 13
                            local unit_id = tonumber(saved.unit) or 0
                            reaper.gmem_write(base_addr + 150 + k_idx, (unit_id * 1000) + 100 + color_num)
                            reaper.gmem_write(base_addr + 220 + k_idx, enc_n)
                            reaper.gmem_write(base_addr + 360 + k_idx, tonumber(saved.group) or 0)
                            reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + k_idx, tonumber(saved.steps) or 0)
                        end
                    else
                        reaper.SetProjExtState(0, NS, c_guid .. ":" .. k_idx, "")
                        reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. k_idx, "")
                        reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. k_idx, "")
                        reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. k_idx, "")
                        reaper.SetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. k_idx, "")
                        
                        reaper.gmem_write(base_addr + 150 + k_idx, 13)
                        reaper.gmem_write(base_addr + 11 + k_idx, 0)
                        reaper.gmem_write(base_addr + 80 + k_idx, 0)
                        reaper.gmem_write(base_addr + 220 + k_idx, 0)
                        reaper.gmem_write(base_addr + 360 + k_idx, 0)
                        reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + k_idx, 0)
                    end
                end
                
                
                
                -- PRILEPLJENJE LAYOUT ELEMENTOV
                if user_layouts[sl] and clipboard_buffer.layout then
                    local target_tab = 1
                    if entry.page_name == "EQ" then target_tab = 1
                    elseif entry.page_name == "DYN" then target_tab = 2
                    elseif entry.page_name == "FX" then target_tab = 3
                    end
                    
                    local divider_y = 350
                    for _, el in ipairs(user_layouts[sl]) do
                        if el[12] == target_tab and el[1] >= 900 and el[2] == 6 then
                            divider_y = el[4]
                            break
                        end
                    end
                    
                    -- Brisanje starih grafičnih elementov ciljne sekcije
                    for j = #user_layouts[sl], 1, -1 do
                        local el = user_layouts[sl][j]
                        if el[12] == target_tab and el[1] < 900 then
                            local is_bottom = false
                            local param_id = math.floor(el[5] or 0)
                            
                            if target_tab == 2 then
                                if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then is_bottom = true
                                elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then is_bottom = false
                                else is_bottom = ((el[4] or 0) >= divider_y) end
                            elseif target_tab == 3 then
                                if param_id >= 45 and param_id <= 56 then is_bottom = true
                                elseif param_id >= 39 and param_id <= 44 then is_bottom = false
                                else is_bottom = ((el[4] or 0) >= divider_y) end
                            end
                            
                            local belongs_to_this_load = (entry.page_name == "EQ") or 
                                                         (entry.sub_slot == 1 and not is_bottom) or 
                                                         (entry.sub_slot == 2 and is_bottom)
                            
                            if belongs_to_this_load then
                                table.remove(user_layouts[sl], j)
                            end
                        end
                    end
                    
                    -- Vstavljanje prekopiranih elementov
                    for _, clip_el in ipairs(clipboard_buffer.layout) do
                        local new_el = {}
                        for i_el, v_el in ipairs(clip_el) do new_el[i_el] = v_el end
                        table.insert(user_layouts[sl], new_el)
                    end
                    
                    reaper.gmem_write(base_addr + 496, 1) -- Potisk layouta v vtičnik (UI refresh)
                end
                
                -- Force cache flush & refresh JSFX UI
                mapping_cache[sl] = nil
                reaper.gmem_write(base_addr + 3, (reaper.gmem_read(base_addr + 3) + 1) % 1000)
            end

        elseif entry.type == "save" then
            SaveMapping(tr, f_idx, page_name, entry.hash, sub_slot)
            
        elseif entry.type == "save_hybrid" then
            SaveHybridMapping(tr, f_idx, entry.hash, entry.sections)
            
        elseif entry.type == "clear_section" then
            ClearSectionMapping(c_guid, sl, entry.btn_list)
            
        elseif entry.type == "load" or entry.type == "load_variant" then
            LoadMapping(tr, f_idx, page_name, entry.hash, false, sub_slot, entry.target_fx_idx, entry.target_slider)
            
        elseif entry.type == "load_hybrid" then
            local section_to_load = entry.full_section_name or entry.full_section
            LoadHybridMapping(tr, f_idx, section_to_load, entry.target_fx_idx, entry.target_slider)

        elseif entry.type == "insert_hybrid" then
            local actual_plugin_name = entry.raw:gsub("%{.-%}$", "")
            reaper.PreventUIRefresh(1)
            local final_insert_idx = reaper.TrackFX_AddByName(tr, actual_plugin_name, false, -1)
            if final_insert_idx and final_insert_idx >= 0 then
                entry.target_fx_idx = final_insert_idx
                entry.type = "load_hybrid"
                execute_action() -- Ponovno pokličemo samo sebe za naložitev
                reaper.TrackFX_Show(tr, final_insert_idx, 3)
            end
            reaper.PreventUIRefresh(-1)
        elseif entry.type == "insert" then
            local fx_count = reaper.TrackFX_GetCount(tr)
            local target_container_idx = -1
            
            for i = f_idx + 1, fx_count - 1 do
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, i, "container_count")
                if is_c ~= "" then
                    target_container_idx = i
                    break
                end
            end
            
            reaper.PreventUIRefresh(1)
            local final_insert_idx = -1
            local actual_plugin_name = entry.raw:gsub("%{.-%}$", "")
            
            if target_container_idx ~= -1 then
                local ok_c, c_count_str = reaper.TrackFX_GetNamedConfigParm(tr, target_container_idx, "container_count")
                local c_count = ok_c and tonumber(c_count_str) or 0
                local dest_magic = 0x2000000 + (c_count + 1) * (fx_count + 1) + (target_container_idx + 1)
                local insert_pos = -1000 - dest_magic
                
                reaper.TrackFX_AddByName(tr, actual_plugin_name, false, insert_pos)
                local _, real_magic_str = reaper.TrackFX_GetNamedConfigParm(tr, target_container_idx, "container_item." .. c_count)
                if real_magic_str then final_insert_idx = tonumber(real_magic_str) end
            else
                final_insert_idx = reaper.TrackFX_AddByName(tr, actual_plugin_name, false, -1)
            end
            
            if final_insert_idx and final_insert_idx >= 0 then
                LoadMapping(tr, f_idx, page_name, entry.hash, false, sub_slot)
                reaper.TrackFX_Show(tr, final_insert_idx, 3)
            end
            
            reaper.PreventUIRefresh(-1)
        elseif entry.type == "insert_chain" then
            local fx_count = reaper.TrackFX_GetCount(tr)
            local target_container_idx = -1
            
            for i = f_idx + 1, fx_count - 1 do
                local _, is_c = reaper.TrackFX_GetNamedConfigParm(tr, i, "container_count")
                if is_c ~= "" then
                    target_container_idx = i
                    break
                end
            end
            
            reaper.PreventUIRefresh(1)
            
            for _, raw_item in ipairs(entry.raws) do
                local actual_plugin_name = raw_item:gsub("%{.-%}$", "")
                if target_container_idx ~= -1 then
                    local ok_c, c_count_str = reaper.TrackFX_GetNamedConfigParm(tr, target_container_idx, "container_count")
                    local c_count = ok_c and tonumber(c_count_str) or 0
                    local dest_magic = 0x2000000 + (c_count + 1) * (fx_count + 1) + (target_container_idx + 1)
                    local insert_pos = -1000 - dest_magic
                    reaper.TrackFX_AddByName(tr, actual_plugin_name, false, insert_pos)
                else
                    reaper.TrackFX_AddByName(tr, actual_plugin_name, false, -1)
                end
            end
            
            LoadMapping(tr, f_idx, page_name, entry.hash, false, sub_slot)
            reaper.PreventUIRefresh(-1)
        end
    end

    -- 2. Določimo ali potrebujemo varnostno brisanje (če nalagamo nove vtičnike na ta mesta)
    local requires_relink = (entry.type == "load" or entry.type == "load_variant" or entry.type == "insert" or entry.type == "insert_chain" or entry.type == "load_hybrid" or entry.type == "insert_hybrid")
    
    if requires_relink then
        local exact_incoming_btns = {}
        
        -- Identify exact buttons the incoming mapping uses
        if entry.type == "load_hybrid" or entry.type == "insert_hybrid" then
            local jsfx_name = GetBaseJSFXName(tr, f_idx)
            local INI_DB = GetINIDB(jsfx_name)
            local section = entry.full_section_name or entry.full_section
            if section and INI_DB[section] then
                for k, v in pairs(INI_DB[section]) do
                    local btn_num = tonumber(k:match("^Btn(%d+)$"))
                    if btn_num and v ~= "" then table.insert(exact_incoming_btns, btn_num) end
                end
            end
        else
            if page_name == "EQ" then 
                for b = 1, 20 do table.insert(exact_incoming_btns, b - 1) end
            elseif page_name == "DYN" then 
                local dyn_top    = {21, 22, 23, 24, 25, 26, 27, 28, 29}
                local dyn_bottom = {30, 31, 32, 33, 34, 35, 36, 37, 38}
                local list       = (sub_slot == 2) and dyn_bottom or dyn_top
                for _, b in ipairs(list) do table.insert(exact_incoming_btns, b - 1) end
            elseif page_name == "FX" then 
                local fx_pre_list  = {39, 40, 41, 42, 43, 44}
                local fx_post_list = {45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56}
                local list         = (sub_slot == 2) and fx_post_list or fx_pre_list
                for _, b in ipairs(list) do table.insert(exact_incoming_btns, b - 1) end
            end
        end

        -- Map incoming buttons to their entire sections (btn = btn_id - 1)
        local sections_to_check = {}
        for _, btn in ipairs(exact_incoming_btns) do
            local sec = GetSectionByParamID(btn)
            if sec == "EQ" then
                for b = 0, 19 do sections_to_check[b] = true end
            elseif sec == "DYN1" then
                for b = 20, 28 do sections_to_check[b] = true end
            elseif sec == "DYN2" then
                for b = 29, 37 do sections_to_check[b] = true end
            elseif sec == "PRE" then
                for b = 38, 43 do sections_to_check[b] = true end
            elseif sec == "POST" then
                for b = 44, 55 do sections_to_check[b] = true end
            end
        end

        local function IsPluginAlive(t_track, t_guid)
            if not t_track or not t_guid or t_guid == "" then return false end
            local function find_guid(t, p_idx)
                local count = p_idx and tonumber(({reaper.TrackFX_GetNamedConfigParm(t, p_idx, "container_count")})[2]) or reaper.TrackFX_GetCount(t)
                for j = 0, (count or 0) - 1 do
                    local _, child_id_str = reaper.TrackFX_GetNamedConfigParm(t, p_idx or -1, "container_item." .. j)
                    local current_idx = p_idx and tonumber(child_id_str) or j
                    if current_idx and reaper.TrackFX_GetFXGUID(t, current_idx) == t_guid then return true end
                    local _, is_c = reaper.TrackFX_GetNamedConfigParm(t, current_idx or -1, "container_count")
                    if is_c ~= "" and find_guid(t, current_idx) then return true end
                end
                return false
            end
            return find_guid(t_track, nil)
        end

        local buttons_to_clear = {}
        local occupied_guids = {}
        local found_active_mapping = false

        -- Scan full touched sections for existing mappings
        for btn, _ in pairs(sections_to_check) do
            buttons_to_clear[btn] = true -- Always guarantee clean target section
            local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. btn)
            if val and val ~= "" then
                local parts = safe_split(val)
                local target_guid = parts[1]
                local target_track = (parts[7] and parts[7] ~= "") and reaper.BR_GetMediaTrackByGUID(0, parts[7]) or tr
                if IsPluginAlive(target_track, target_guid) then
                    occupied_guids[target_guid] = true
                    found_active_mapping = true
                end
            end
        end

        -- Expand footprint to hunt cross-section orphans
        if found_active_mapping then
            for b = 0, 64 do
                local _, val = reaper.GetProjExtState(0, NS, c_guid .. ":" .. b)
                if val and val ~= "" then
                    local parts = safe_split(val)
                    if occupied_guids[parts[1]] then
                        buttons_to_clear[b] = true
                    end
                end
            end
        end

        -- Execute Wipe
        local function execute_wipe()
            local base_addr = PROJECT_BASE + sl * 500
            for k_idx, _ in pairs(buttons_to_clear) do
                reaper.SetProjExtState(0, NS, c_guid .. ":" .. k_idx, "")
                
                -- Cache cleanup
                if mapping_cache[sl] then 
                    mapping_cache[sl][k_idx] = nil 
                    if mapping_cache[sl].encoded_name then mapping_cache[sl].encoded_name[k_idx] = 0 end
                end
                if color_cache[sl] then color_cache[sl][k_idx] = nil end
                if group_cache[sl] then group_cache[sl][k_idx] = nil end
                if unit_cache[sl] then unit_cache[sl][k_idx] = nil end
                if steps_cache[sl] then steps_cache[sl][k_idx] = nil end
                
                -- ExtState cleanup
                reaper.SetProjExtState(0, NS, "STEPS:" .. c_guid .. ":" .. k_idx, "")
                reaper.SetProjExtState(0, NS, "COLOR:" .. c_guid .. ":" .. k_idx, "")
                reaper.SetProjExtState(0, NS, "UNIT:" .. c_guid .. ":" .. k_idx, "")
                reaper.SetProjExtState(0, NS, "GROUP:" .. c_guid .. ":" .. k_idx, "")
                
                -- GMEM reset
                reaper.gmem_write(base_addr + 150 + k_idx, 13) 
                reaper.gmem_write(base_addr + 11 + k_idx, 0)
                reaper.gmem_write(base_addr + 80 + k_idx, 0)
                reaper.gmem_write(base_addr + 220 + k_idx, 0)
                reaper.gmem_write(base_addr + 360 + k_idx, 0)
                reaper.gmem_write(PROJECT_BASE + 60000 + (sl * 100) + k_idx, 0)
            end
        end

        -- ASINHRONA USMERJEVALNA LOGIKA ZA IZVEDBO (če je relink)
        if next(buttons_to_clear) then
            if found_active_mapping then
                table.insert(pending_os_tasks, function()
                    local ans = reaper.MB("This action will overwrite currently mapped active FX.\n\nTo prevent orphan parameters, ALL sections belonging to the affected FX will be cleared before loading.\n\nDo you want to proceed?", "StripLink: Smart Relink Warning", 4)
                    if ans == 6 then -- 6 pomeni 'Yes'
                        execute_wipe()
                        execute_action()
                        UpdatePluginStructure(data.tr, data.sl, data.c_guid)
                    else
                        reaper.gmem_write(PROJECT_BASE + 7, 0)
                    end
                end)
                return -- Prekinemo neposredno izvajanje, vrstica bo prevzela vajeti
            else
                execute_wipe()
                execute_action()
            end
        else
            execute_action()
        end
        
        UpdatePluginStructure(data.tr, data.sl, data.c_guid)

    else
        -- 3. TO SO VSE OSTALE AKCIJE (Save, Copy, Paste, Clear) - izvedejo se takoj!
        execute_action()
        UpdatePluginStructure(data.tr, data.sl, data.c_guid)
    end
end

function DrawMenus()
    -- Open request: set positions and activate state
    if popup_state.request_open then
        reaper.ImGui_SetNextWindowPos(ctx, popup_state.mouse_x, popup_state.mouse_y)
        popup_state.is_visible = true
        popup_state.request_open = false
        popup_state.open_time = reaper.time_precise()
    end

    -- Update gmem 206 continuously based on actual menu visibility state
    local is_open_val = (popup_state.is_visible and popup_state.active_cmd > 0) and 1 or 0
    reaper.gmem_write(PROJECT_BASE + 206, is_open_val)

    -- Exit immediately if menu is closed -> 0 CPU/GPU overhead!
    if not popup_state.is_visible or popup_state.active_cmd == 0 then return end

    local current_time = reaper.time_precise()
    local just_opened = (popup_state.open_time and (current_time - popup_state.open_time) < 0.15)
    local close_requested = false

    -- =========================================================================
    -- TRANSPARENT OVERLAY WINDOW (CAPTURE CLICKS & ESC)
    -- =========================================================================
    local viewport = reaper.ImGui_GetMainViewport(ctx)
    local vx, vy = reaper.ImGui_Viewport_GetPos(viewport)
    local vw, vh = reaper.ImGui_Viewport_GetSize(viewport)

    reaper.ImGui_SetNextWindowPos(ctx, vx, vy)
    reaper.ImGui_SetNextWindowSize(ctx, vw, vh)

    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x00000001)

    local overlay_flags = reaper.ImGui_WindowFlags_NoDecoration() | 
                          reaper.ImGui_WindowFlags_NoMove() | 
                          reaper.ImGui_WindowFlags_NoSavedSettings() | 
                          reaper.ImGui_WindowFlags_NoNav() | 
                          reaper.ImGui_WindowFlags_TopMost()

    local overlay_visible, overlay_open = reaper.ImGui_Begin(ctx, 'StripLinkOverlay', true, overlay_flags)

    if overlay_visible then
        if reaper.ImGui_IsWindowAppearing(ctx) then
            reaper.ImGui_SetWindowFocus(ctx)
        end

        if reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) then
            close_requested = true
        end

        if reaper.ImGui_IsWindowHovered(ctx) and (reaper.ImGui_IsMouseClicked(ctx, 0) or reaper.ImGui_IsMouseClicked(ctx, 1)) and not just_opened then
            close_requested = true
        end

    end
    reaper.ImGui_End(ctx)
    reaper.ImGui_PopStyleColor(ctx, 1)

    -- Handle immediate closure if overlay was clicked or ESC was pressed
    if close_requested then
        popup_state.is_visible = false
        popup_state.active_cmd = 0
        popup_state.data = {}
        reaper.gmem_write(PROJECT_BASE + 7, 0)
        
        -- Signal JSFX: Menu is CLOSED (written ONCE on close)
        reaper.gmem_write(PROJECT_BASE + 206, 0)
        return
    end

    -- =========================================================================
    -- CUSTOM MENU WINDOW (DRAWN ABOVE TRANSPARENT OVERLAY)
    -- =========================================================================
    reaper.ImGui_SetNextWindowPos(ctx, popup_state.mouse_x, popup_state.mouse_y)

    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 6.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_PopupRounding(), 6.0)
    
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), 0x323232FF) 
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),  0x3C3C3CFF) 
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),         0x323232FF) 

    local menu_window_flags = reaper.ImGui_WindowFlags_NoDecoration() | 
                              reaper.ImGui_WindowFlags_AlwaysAutoResize() | 
                              reaper.ImGui_WindowFlags_TopMost()

    local visible, open = reaper.ImGui_Begin(ctx, 'StripLinkCustomMenu', true, menu_window_flags)

    if visible then
        local choice = 0
        local success, err = true, nil
        
        if popup_state.active_cmd == 1 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd1, choice, popup_state.data) end
        elseif popup_state.active_cmd == 2 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd2, choice, popup_state.data) end
        elseif popup_state.active_cmd == 3 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then
                if popup_state.data.is_global then
                    success, err = pcall(ExecuteCmd3_Settings, choice, popup_state.data)
                else
                    success, err = pcall(ExecuteCmd3_Mapping, choice, popup_state.data)
                end
            end
        elseif popup_state.active_cmd == 4 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd4, choice, popup_state.data) end
        elseif popup_state.active_cmd == 5 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd5, choice, popup_state.data) end
        elseif popup_state.active_cmd == 6 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd6, choice, popup_state.data) end
        elseif popup_state.active_cmd == 20 then
            local current_color = 0
            if popup_state.data.clicked_tab == 1 then current_color = popup_state.data.col_eq
            elseif popup_state.data.clicked_tab == 2 then current_color = popup_state.data.col_dyn
            elseif popup_state.data.clicked_tab == 3 then current_color = popup_state.data.col_fx
            end
            
            local opts = {
                {name = "None",   col = 0x888888FF}, 
                {name = "Red",    col = 0xFF5555FF},
                {name = "Green",  col = 0x55FF55FF},
                {name = "Blue",   col = 0x5555FFFF},
                {name = "Yellow", col = 0xFFFF55FF}
            }
            
            for i, opt in ipairs(opts) do
                local is_selected = (current_color == (i - 1))
                local prefix = is_selected and "✓ " or "   "
                
                local p_min_x, p_min_y = reaper.ImGui_GetCursorScreenPos(ctx)
                local line_h = reaper.ImGui_GetTextLineHeight(ctx)
                
                if reaper.ImGui_MenuItem(ctx, prefix .. "     " .. opt.name) then
                    choice = i
                end
                
                if i > 1 then 
                    local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
                    local rect_size = line_h * 0.7
                    local offset_y = (line_h - rect_size) * 0.5
                    local offset_x = p_min_x + reaper.ImGui_CalcTextSize(ctx, prefix) 
                    
                    reaper.ImGui_DrawList_AddRectFilled(draw_list, 
                        offset_x, p_min_y + offset_y, 
                        offset_x + rect_size, p_min_y + offset_y + rect_size, 
                        opt.col, 2.0)
                end
            end
            
            if choice > 0 then success, err = pcall(ExecuteCmd20, choice, popup_state.data) end
        elseif popup_state.active_cmd == 21 then
            choice = DrawImGuiSwellMenu(ctx, popup_state.data.menu_str)
            if choice > 0 then success, err = pcall(ExecuteCmd21, choice, popup_state.data) end
        end

        -- Close menu if item selected (ALWAYS EXECUTED, EVEN ON CRASH!)
        if choice > 0 then
            if not success then
                reaper.ShowConsoleMsg("Lua Error in Command " .. tostring(popup_state.active_cmd) .. ":\n" .. tostring(err) .. "\n")
            end
        
            popup_state.is_visible = false
            popup_state.active_cmd = 0
            popup_state.data = {}
            reaper.gmem_write(PROJECT_BASE + 7, 0)
            
            -- Signal JSFX: Menu is CLOSED (written ONCE on selection)
            reaper.gmem_write(PROJECT_BASE + 206, 0)
        end
    end
    
    reaper.ImGui_End(ctx)
    -- Pop styles
    reaper.ImGui_PopStyleColor(ctx, 3)
    reaper.ImGui_PopStyleVar(ctx, 2)
end


-- =========================================================================
-- LAYOUT BUILDER TOOLBOX
-- =========================================================================

local function GetNextElementPos(slot_idx, page, new_w, new_h, PANNEL_h)
    local elements = user_layouts[slot_idx] or {}
    
    local min_x = 5
    local max_x = 120
    local padding = 4
    local step = 5
    
    local divider_y = 350
    local divider_h = 31
    
    if page == 2 or page == 3 then
        for _, el in ipairs(elements) do
            -- POPRAVEK: Tudi tukaj dodamo 'and el[2] == 6'
            if el[12] == page and el[1] >= 900 and el[2] == 6 then
                divider_y = el[4]
                divider_h = el[7] or (el[5] == 6 and 10 or 31)
                break
            end
        end
    end

    local search_start_y = 105
    local search_max_y = PANNEL_h or 800

    if page == 0 or page == 1 then
        search_start_y = 105
    elseif builder_state.target_sec == 1 then
        search_max_y = divider_y - padding 
    else
        search_start_y = divider_y + divider_h + padding
    end
    
    local function check_overlap(tx, ty)
        for _, el in ipairs(elements) do
            if el[12] == page then
                local ex, ey = el[3], el[4]
                local ew, eh = el[6] or 54, el[7] or 30
                if tx < (ex + ew + padding) and (tx + new_w + padding) > ex and
                   ty < (ey + eh + padding) and (ty + new_h + padding) > ey then
                    return true
                end
            end
        end
        return false
    end

    for ty = search_start_y, search_max_y - new_h, step do
        for tx = min_x, max_x - new_w, step do
            if not check_overlap(tx, ty) then
                return tx, ty
            end
        end
    end

    return min_x, search_start_y
end

local function GetAvailableParamID(elements, tab_id, el_type, y_pos)
    local used_ids = {}
    
    for _, el in ipairs(elements) do
        if el[12] == tab_id and el[1] < 900 then
            if el[2] == 1 or el[2] == 2 or el[2] == 3 or el[2] == 7 then
                used_ids[el[5]] = true
            end
        end
    end
    
    -- Uporabimo eksplicitno izbrano sekcijo iz Builderja (1 = Top, 2 = Bottom)
    local is_top_section = (builder_state.target_sec == 1)
    local allowed_ids = {}
    
    if tab_id == 0 then -- OVR
        for i = 1, 64 do table.insert(allowed_ids, i) end
        
    elseif tab_id == 1 then -- EQ (14 Knobs, 6 Switches)
        if el_type == 1 or el_type == 3 or el_type == 7 then 
            -- Gumbi imajo prekinjeno zaporedje za ohranitev starih stikal
            allowed_ids = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
        else 
            -- Stikala ostanejo tam, kjer so bila (prvih 6 od starih 8)
            allowed_ids = {15, 16, 17, 18, 19, 20}
        end
        
    elseif tab_id == 2 then -- DYN
        if is_top_section then -- DYN 1 (5 Knobs/Selectors, 4 Switches)
            if el_type == 1 or el_type == 3 or el_type == 7 then 
                allowed_ids = {21, 22, 23, 24, 25} 
            else 
                allowed_ids = {26, 27, 28, 29} 
            end
        else -- DYN 2 (5 Knobs/Selectors, 4 Switches)
            if el_type == 1 or el_type == 3 or el_type == 7 then 
                allowed_ids = {30, 31, 32, 33, 34} 
            else 
                allowed_ids = {35, 36, 37, 38} 
            end
        end
        
    elseif tab_id == 3 then -- FX
        if is_top_section then -- FX PRE (4 Knobs/Selectors, 2 Switches)
            if el_type == 1 or el_type == 3 or el_type == 7 then 
                allowed_ids = {39, 40, 41, 42}
            else 
                allowed_ids = {43, 44}
            end
        else -- FX POST (9 Knobs/Selectors, 3 Switches)
            if el_type == 1 or el_type == 3 or el_type == 7 then 
                allowed_ids = {45, 46, 47, 48, 49, 50, 51, 52, 53}
            else 
                allowed_ids = {54, 55, 56}
            end
        end
    end
    
    for _, id in ipairs(allowed_ids) do
        if not used_ids[id] then
            return id
        end
    end
    
    return 0 
end


local function DrawLayoutBuilderToolbox()
    -- 1. PREBERI STANif current_slot <= 0 thenJE IZ GMEM (Sinhronizira Meni 99 in Shift+Alt+Klik)
    local current_slot = math.floor(reaper.gmem_read(PROJECT_BASE + 8))
    local sl_base = 0
    if current_slot > 0 then
        sl_base = PROJECT_BASE + current_slot * 500
        local jsfx_builder_mode = reaper.gmem_read(sl_base + 428)
        
        if jsfx_builder_mode == 1 then
            if not builder_state.open then
                builder_state.open = true
                builder_state.just_opened = true -- Pravilno sproži pozicioniranje!
                
                -- LUA ZAHTEVA: Prebudi JSFX in zahtevaj svež izvoz!
                reaper.gmem_write(sl_base + 427, 1)
            end
        else
            builder_state.open = false
        end
    end

    if not builder_state.open then return end

    -- VSI STYLE VARS
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 8.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),   6.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_GrabRounding(),    6.0)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameBorderSize(), 1.0)

    -- VSE STYLE COLORS
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),   0x222222FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBg(),         0x101010FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(),        0x111111FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),          0x333333FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Border(),          0x383838FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),   0x666666FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),    0x333333FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),         0x111111FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),  0x242424FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),   0x222222FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),            0xE0E0E0FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrab(),      0x666666FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_SliderGrabActive(),0x888888FF)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),       0x222222FF)

    reaper.ImGui_SetNextWindowSizeConstraints(ctx, 272, 0, 272, 2000)
    
    
    local window_flags = reaper.ImGui_WindowFlags_AlwaysAutoResize() | reaper.ImGui_WindowFlags_NoSavedSettings()
    local visible, open = reaper.ImGui_Begin(ctx, 'StripLink Layout Builder', true, window_flags)
    
    if not open then
        builder_state.open = false
        if sl_base > 0 then reaper.gmem_write(sl_base + 428, 0) end
    end
    
    if visible then
        local current_slot = math.floor(reaper.gmem_read(PROJECT_BASE + 8))
    
        if current_slot > 0 then
            
            -- 1. Poišči ime trenutnega vtičnika (potrebno za branje in pisanje prave višine)
            local current_tr, current_idx, current_jsfx_name
            if active_plugins then
                for _, fx in ipairs(active_plugins) do
                    if fx.slot == current_slot then
                        current_tr = fx.tr
                        current_idx = fx.idx
                        current_jsfx_name = GetBaseJSFXName(fx.tr, fx.idx)
                        break
                    end
                end
            end
            -- Fallback, če iz nekega razloga seznam ni osvežen
            if not current_jsfx_name then 
                local _, n = reaper.TrackFX_GetFXName(reaper.GetSelectedTrack(0,0) or reaper.GetMasterTrack(0), 0, "")
                current_jsfx_name = n:match("StripLink.-%s") and n:gsub("^JS:%s*", ""):gsub("%s+%[.-%]$", "") or "StripLink Module v2"
            end
            
            -- 2. Preberi GLOBALNO višino (Unscrollable Slot Height) direktno iz JSFX datoteke!
            local global_slot_height = GetJSFXHeightFromFile(current_jsfx_name)
            
            -- 3. Preberi LOKALNO višino instance (Panel Size) iz gmem 431
            local sl_base = PROJECT_BASE + current_slot * 500
            local instance_panel_h = math.floor(reaper.gmem_read(sl_base + 426))
            
            -- Varovalka 1
            if instance_panel_h < global_slot_height then 
                instance_panel_h = global_slot_height 
                reaper.gmem_write(sl_base + 426, instance_panel_h)
            end
                    
            local current_page = math.floor(reaper.gmem_read(sl_base + 290))
            --if current_page == 0 then current_page = 1 end
            
            -- ZAGOTOVIMO OBSTOJ TABELE ZA TRENUTNI SLOT
            if not user_layouts[current_slot] then 
                user_layouts[current_slot] = GetDefaultLayout(instance_panel_h) 
            end
            local my_elements = user_layouts[current_slot]
            
            local outbox = PROJECT_BASE + 500000 + (current_slot * 3000)
            local mailbox = PROJECT_BASE + 200000 + (current_slot * 3000)
            
            -- DODANO: Zakasnjena obnova selekcije
            if builder_state.restore_sel and reaper.gmem_read(mailbox) == 0 then
                reaper.gmem_write(outbox - 4, builder_state.restore_sel)
                builder_state.restore_sel = nil
            end
            
            local function SyncCurrentPositions()
                -- VAROVALKA: Če smo pravkar odprli Builder, počakaj en cikel, da JSFX zaključi izvoz!
                if builder_state.just_opened then
                    builder_state.just_opened = false
                    return 
                end
                
                -- VAROVALKA 2: Prepreči branje, če JSFX še ni ugasnil zahteve po izvozu
                if reaper.gmem_read(sl_base + 427) == 1 then return end
            
                if reaper.gmem_read(mailbox) == 1 then return end 
                local outbox_page = math.floor(reaper.gmem_read(outbox - 2))
                if outbox_page ~= current_page then return end
                if not LayoutMatchesOutbox(current_slot, my_elements) then return end
                
                local outbox_count = math.floor(reaper.gmem_read(outbox - 1))
                local limit = math.min(#my_elements, outbox_count)
                
                local gap = 4 
                local max_top_y = 100   -- LOKALNA LOGIČNA MEJA POD HEADERJEM (JSFX kompenzira meter!)
                local min_bot_y = instance_panel_h - 5
                
                local divider_y = 350
                local divider_h = 31
                
                -- ========================================================
                -- POMOŽNI FUNKCIJI S TOLERANČNIM PRINCIPOM ("Buffer")
                -- ========================================================
                local function BoundingBoxX(nx, nw)
                    local hw = math.floor(nw / 2)
                    if nw >= 125 then
                        local cx = math.floor((125 - nw) / 2)
                        if nx ~= cx then return cx, true end
                    else
                        local l_left = 0
                        local l_right = 125 - nw
                        if nx < l_left - hw then
                            return l_left, true
                        elseif nx > l_right + hw then
                            return l_right, true
                        end
                    end
                    return nx, false
                end
    
                local function BoundingBoxY(ny, nh, l_top, l_bot)
                    local hh = math.floor(nh / 2)
                    if l_bot < l_top then l_bot = l_top end 
                    
                    if nh >= (l_bot - l_top + nh) then 
                        if ny ~= l_top then return l_top, true end
                    else
                        if ny < l_top - hh then
                            return l_top, true
                        elseif ny > l_bot + hh then
                            return l_bot, true
                        end
                    end
                    return ny, false
                end
                -- ========================================================
                
                -- Izračun specifičnih mej in prepoznavanje dividerja SAMO za DYN/FX
                if current_page == 2 or current_page == 3 then
                    for i = 1, limit do
                        local el = my_elements[i]
                        if el[12] == current_page and el[1] >= 900 and el[2] == 6 then
                            divider_y = el[4]
                            divider_h = el[7] or (el[5] == 6 and 10 or 31)
                            break
                        end
                    end
                    
                    -- 2. Drugi prehod: Izračun mej (SAMO za funkcijske kontrole sekcij!)
                    for i = 1, limit do
                        local el = my_elements[i]
                        local el_type = el[2]
                        
                        -- Filtramo LE funkcijske kontrole (Knob, Switch, Tube, Meter, Selector, InputGain)
                        -- Teksti (4), dekorativni separatorji (6 z ID < 900), Grupe (8) in AutoGain (9, 10) so IZKLJUČENI!
                        
                        --local is_functional_control = (el_type == 1 or el_type == 2 or el_type == 3 or el_type == 5 or el_type == 7 or el_type == 12)
                        -- Leave meters without constraints, so users can place 2 vertical meters one beside antother
                        local is_functional_control = (el_type == 1 or el_type == 2 or el_type == 3 or el_type == 7 or el_type == 12)
                        
                        if el[12] == current_page and el[1] < 900 and is_functional_control then
                            local param_id = el[5]
                            local is_bottom = false
                            
                            if current_page == 2 then
                                -- DYN 1 (Top): 21..29, metri 1,3,5 | DYN 2 (Bottom): 30..38, metri 2,4,6
                                if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then 
                                    is_bottom = true 
                                elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then
                                    is_bottom = false
                                else
                                    is_bottom = (el[4] >= divider_y)
                                end
                            elseif current_page == 3 then
                                -- FX PRE (Top): 39..44 | FX POST (Bottom): 45..56
                                if param_id >= 45 and param_id <= 56 then 
                                    is_bottom = true 
                                elseif param_id >= 39 and param_id <= 44 then
                                    is_bottom = false
                                else
                                    is_bottom = (el[4] >= divider_y)
                                end
                            end
                            
                            local el_h = el[7] or 30
                            if is_bottom then
                                if el[4] < min_bot_y then min_bot_y = el[4] end
                            else
                                local bottom_edge = el[4] + el_h
                                if bottom_edge > max_top_y then max_top_y = bottom_edge end
                            end
                        end
                    end
                    
                    -- Varovalka za razmik med sekcijama
                    if min_bot_y < max_top_y + divider_h + gap * 2 then
                        min_bot_y = max_top_y + divider_h + gap * 2
                    end
                end
                
                local needs_push = false
                local live_divider_y = divider_y
                
                for i = 1, limit do
                    -- VAROVALKA: Omejimo logiko izključno na elemente trenutnega zavihka
                    if my_elements[i][12] == current_page then
                        local new_x = reaper.gmem_read(outbox + ((i - 1) * 13) + 2)
                        local new_y = reaper.gmem_read(outbox + ((i - 1) * 13) + 3)
                        local new_w = reaper.gmem_read(outbox + ((i - 1) * 13) + 5)
                        local new_h = reaper.gmem_read(outbox + ((i - 1) * 13) + 6)
                        local new_dx = reaper.gmem_read(outbox + ((i - 1) * 13) + 11) -- Očita DX
                        local new_dy = reaper.gmem_read(outbox + ((i - 1) * 13) + 12) -- Očita DY
                        
                        local push_x, push_y = false, false
                        
                        -- ZAGOTOVIMO VARNO X OS ZA VSE ELEMENTE (razen sistemskega dividerja, ki se centrira ročno)
                        if not (my_elements[i][1] >= 900 and my_elements[i][2] == 6) then
                            new_x, push_x = BoundingBoxX(new_x, new_w)
                        end
                        
                        if current_page == 0 or current_page == 1 then
                            -- Samo globalne meje (100 do dno)
                            new_y, push_y = BoundingBoxY(new_y, new_h, 100, instance_panel_h - new_h)
                        else
                            if my_elements[i][1] >= 900 and my_elements[i][2] == 6 then
                                live_divider_y = new_y
                                
                                new_y, push_y = BoundingBoxY(new_y, new_h, max_top_y + gap, min_bot_y - new_h - gap)
                                
                                local target_x = math.floor((125 - new_w) / 2)
                                if new_x ~= target_x then
                                    new_x = target_x
                                    push_x = true 
                                end
                            else
                                local el_type = my_elements[i][2]
                                
                                -- Tekst (4), dekorativne črte (6), Grupa (8) in AutoGain (9, 10) so povsem prosto premični od 100px do dna:
                                -- also no constraints for meters!
                                --if el_type == 4 or (el_type == 6 and my_elements[i][1] < 900) or el_type == 8 or el_type == 9 or el_type == 10 then
                                if el_type == 4 or el_type == 5 or (el_type == 6 and my_elements[i][1] < 900) or el_type == 8 or el_type == 9 or el_type == 10 then
                                    new_y, push_y = BoundingBoxY(new_y, new_h, 100, instance_panel_h - new_h)
                                else
                                    -- Samo pravi funkcijski parametri (Gumbi, Stikala, Tube, Metri) ostajajo omejeni z ločilnikom:
                                    local param_id = my_elements[i][5]
                                    local is_bottom = false
                                    
                                    if current_page == 2 then
                                        if (param_id >= 30 and param_id <= 38) or param_id == 2 or param_id == 4 or param_id == 6 then 
                                            is_bottom = true 
                                        elseif (param_id >= 21 and param_id <= 29) or param_id == 1 or param_id == 3 or param_id == 5 then
                                            is_bottom = false
                                        else
                                            is_bottom = (my_elements[i][4] >= divider_y)
                                        end
                                    elseif current_page == 3 then
                                        if param_id >= 45 and param_id <= 56 then 
                                            is_bottom = true 
                                        elseif param_id >= 39 and param_id <= 44 then
                                            is_bottom = false
                                        else
                                            is_bottom = (my_elements[i][4] >= divider_y)
                                        end
                                    end

                                    if is_bottom then
                                        new_y, push_y = BoundingBoxY(new_y, new_h, divider_y + divider_h + gap, instance_panel_h - new_h)
                                    else
                                        new_y, push_y = BoundingBoxY(new_y, new_h, 100, divider_y - new_h - gap)
                                    end
                                end
                            end
                        end
                        
                        if push_x or push_y then
                            my_elements[i][3] = new_x
                            my_elements[i][4] = new_y
                            my_elements[i][6] = new_w
                            my_elements[i][7] = new_h
                            my_elements[i][13] = new_dx
                            my_elements[i][14] = new_dy
                            needs_push = true
                        else
                            -- Tudi če ni push-a, obvezno osvežimo cache z offseti
                            my_elements[i][3] = new_x
                            my_elements[i][4] = new_y
                            my_elements[i][6] = new_w
                            my_elements[i][7] = new_h
                            my_elements[i][13] = new_dx
                            my_elements[i][14] = new_dy
                        end
                    end
                end
                
                if needs_push then 
                    PushUILayout(current_slot) 
                end
            end
            
            SyncCurrentPositions()
            
            -- POMOŽNA FUNKCIJA ZA RISANJE GUMBOV Z IKONO (izris in avtomatski centriran odmik)
            local function DrawIconButton(label, icon_img, w, h)
                local clicked = reaper.ImGui_Button(ctx, label, w, h)
                if icon_img and reaper.ImGui_ValidatePtr(icon_img, 'ImGui_Image*') then
                    local min_x, min_y = reaper.ImGui_GetItemRectMin(ctx)
                    local max_x, max_y = reaper.ImGui_GetItemRectMax(ctx)
                    local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
                    local img_size = 16
                    
                    local full_text_w = reaper.ImGui_CalcTextSize(ctx, label)
                    local text_start_x = min_x + (max_x - min_x - full_text_w) * 0.5
                    
                    local img_x = text_start_x - 8 
                    local img_y = min_y + (max_y - min_y - img_size) * 0.5
                    
                    reaper.ImGui_DrawList_AddImage(draw_list, icon_img, img_x, img_y, img_x + img_size, img_y + img_size)
                end
                return clicked
            end
    
            -- 1. SEKCIJA: SHRANJEVANJE IN ZAPIRANJE
            reaper.ImGui_SeparatorText(ctx, "ACTIONS")
            if reaper.ImGui_Button(ctx, "SAVE LAYOUT & CLOSE", 150, 35) then
                SyncCurrentPositions()
                reaper.gmem_write(sl_base + 428, 0)
                builder_state.open = false
                reaper.MarkProjectDirty(0)
            end
            reaper.ImGui_SameLine(ctx)
            
            -- ==========================================
            -- GUMB ZA ČIŠČENJE PLATNA Z POTRDITVIJO
            -- ==========================================
            if reaper.ImGui_Button(ctx, "CLEAR LAYOUT", -1, 35) then
                table.insert(pending_os_tasks, function()
                    local confirm = reaper.MB(
                        "Are you sure you want to clear ALL UI elements and tab colors from this layout?\n\n" ..
                        "Note: This will reset all tabs (EQ, DYN, FX) at once.", 
                        "Confirm Clear Layout", 
                        4
                    )
                    
                    if confirm == 6 then
                        -- Uporabimo pravilno ime spremenljivke za višino 'instance_panel_h'
                        local ag_pwr_y = instance_panel_h - 35
                        local ag_lck_y = ag_pwr_y - 18
                        
                        user_layouts[current_slot] = {
                            -- OVR Zavihek (0)
                            {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 0, 0, 0},
                            {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 0, 0, 0},
                            -- EQ Zavihek (1)
                            {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 1, 0, 0},
                            {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 1, 0, 0},
                            -- DYN Zavihek (2) - Divider + AG + Lock
                            {902, 6, 6, 350, 5, 113, 10, 0, "", 14, 0, 2, 0, 0},
                            {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 2, 0, 0},
                            {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 2, 0, 0},
                            -- FX Zavihek (3) - Divider + AG + Lock
                            {903, 6, 6, 350, 5, 113, 10, 0, "", 14, 0, 3, 0, 0},
                            {904, 9, 42, ag_pwr_y, 68, 40, 35, 0, "", 14, 0, 3, 0, 0},
                            {905, 10, 53, ag_lck_y, 64, 17, 17, 0, "", 14, 0, 3, 0, 0}
                        }
                        
                        -- PONASTAVITEV BARV ZAVIHKOV (Parametri 6, 7 in 8 v Lui)
                        if current_tr and current_idx then
                            reaper.TrackFX_SetParam(current_tr, current_idx, 6, 0x161616) -- Reset EQ Color
                            reaper.TrackFX_SetParam(current_tr, current_idx, 7, 0x161616) -- Reset DYN Color
                            reaper.TrackFX_SetParam(current_tr, current_idx, 8, 0x161616) -- Reset FX Color
                        end
        
                        -- Pošljemo posodobitev v JSFX
                        PushUILayout(current_slot)
                        
                        -- Ponastavimo selekcijo
                        builder_selected_idx = 1
                        local outbox = PROJECT_BASE + 500000 + (current_slot * 3000)
                        reaper.gmem_write(outbox - 4, 0)
                    end
                end)
            end
            
            -- 1.2 SEKCIJA: HEIGHT SETTINGS
            reaper.ImGui_SeparatorText(ctx, "HEIGHT SETTINGS")
            
            -- GLOBALNI DRSNIK
            if not builder_state.global_slot_h then builder_state.global_slot_h = global_slot_height end
            reaper.ImGui_TextDisabled(ctx, "Unscrollable Slot Height (Global)")
            reaper.ImGui_SetNextItemWidth(ctx, 190)
            local changed_g, new_g = reaper.ImGui_SliderInt(ctx, "##g_h", builder_state.global_slot_h, 400, 1000, "%d px")
            if changed_g then builder_state.global_slot_h = new_g end
            
            reaper.ImGui_SameLine(ctx)
            if reaper.ImGui_Button(ctx, "Apply", 60, 0) then
                if ApplyPANNELHeightToJSFX(current_jsfx_name, builder_state.global_slot_h) then
                    local safe_jsfx_name = current_jsfx_name:gsub("%s+", "_")
                    reaper.SetExtState(NS, "PANNEL_HEIGHT_" .. safe_jsfx_name, tostring(builder_state.global_slot_h), true)
                    global_slot_height = builder_state.global_slot_h
                    
                    -- Varovalka 2
                    if reaper.gmem_read(sl_base + 426) < global_slot_height then
                        reaper.gmem_write(sl_base + 426, global_slot_height)
                    end
                    
                    if current_tr and current_idx then
                        reaper.PreventUIRefresh(1)
                        for _, fx in ipairs(active_plugins) do
                            local n = GetBaseJSFXName(fx.tr, fx.idx)
                            if n == current_jsfx_name then
                                reaper.TrackFX_SetOffline(fx.tr, fx.idx, true)  
                                reaper.TrackFX_SetOffline(fx.tr, fx.idx, false) 
                            end
                        end
                        reaper.TrackList_AdjustWindows(true)
                        reaper.PreventUIRefresh(-1)
                    end
                else
                    table.insert(pending_os_tasks, function()
                        reaper.MB("Could not modify JSFX file. Ensure it is not read-only.", "StripLink Builder", 0)
                    end)
                end
            end
            
            -- LOKALNI DRSNIK (z vgrajeno varovalko proti rezanju)
            reaper.ImGui_TextDisabled(ctx, "Panel Size (Instance)")
            reaper.ImGui_SetNextItemWidth(ctx, 190)
            local changed_i, new_i = reaper.ImGui_SliderInt(ctx, "##i_h", instance_panel_h, global_slot_height, 1000, "%d px")
            if changed_i then
                -- Najnižja dovoljena točka je vedno osnovna višina vtičnika (npr. 635 px)
                local max_y = global_slot_height
                if user_layouts[current_slot] then
                    for _, el in ipairs(user_layouts[current_slot]) do
                        -- Ignoriramo sistemska Auto Gain gumba na dnu
                        if el[1] < 900 and el[2] ~= 9 and el[2] ~= 10 then
                            local bottom_edge = (el[4] or 0) + (el[7] or 30)
                            if bottom_edge > max_y then max_y = bottom_edge end
                        end
                    end
                    
                    -- Dinamično premaknemo Auto Gain gumba na novo dno
                    local ag_pwr_y = new_i - 35
                    local ag_lck_y = ag_pwr_y - 18
                    for _, el in ipairs(user_layouts[current_slot]) do
                        if el[1] == 904 then el[4] = ag_pwr_y end
                        if el[1] == 905 then el[4] = ag_lck_y end
                    end
                end
                
                -- Varovalka: Ne dovoli manj kot global_slot_height (635 px) in ne pod najnižji gumb
                if new_i < max_y then new_i = max_y end
                
                reaper.gmem_write(sl_base + 426, new_i)
                instance_panel_h = new_i
                PushUILayout(current_slot)
            end
            
            -- 1.3 SEKCIJA: TAB COLOR
             if current_page >= 1 and current_page <= 3 then
                 reaper.ImGui_SeparatorText(ctx, "TAB COLOR (Per Instance)")
                 
                 -- Pravilni indeks (sliderji 7, 8 in 9 so parametri 6, 7 in 8)
                 local slider_idx = 5 + current_page
                 
                 local current_color_raw = 0x161616
                 if current_tr and current_idx then
                     current_color_raw = math.floor(reaper.TrackFX_GetParam(current_tr, current_idx, slider_idx))
                     if current_color_raw == 0 then current_color_raw = 0x161616 end
                 end
                 
                 -- Pretvorba iz JSFX (0xRRGGBB) v ImGui (0xAARRGGBB) s polno Alpha vrednostjo (0xFF)
                 local imgui_color = (0xFF << 24) | current_color_raw
                 
                 reaper.ImGui_SetNextItemWidth(ctx, 190)
                 local changed_c, new_c = reaper.ImGui_ColorEdit3(ctx, "Color##TabColor", imgui_color, reaper.ImGui_ColorEditFlags_NoInputs())
                 
                 if changed_c and current_tr and current_idx then
                     -- Pretvorba iz ImGui (0xAARRGGBB) nazaj v JSFX (0xRRGGBB)
                     -- Odstranimo Alpha bajt (prvih 8 bitov) z uporabo preproste bitne maske
                     local jsfx_color = new_c & 0x00FFFFFF
                     
                     reaper.TrackFX_SetParam(current_tr, current_idx, slider_idx, jsfx_color)
                 end
             end

            -- =========================================================================
            
            
            -- 1.5 SEKCIJA: TARGET SECTION (Vidno SAMO na DYN [2] in FX [3] zavihku)
            if current_page == 2 or current_page == 3 then
                reaper.ImGui_SeparatorText(ctx, "TARGET SECTION")
                
                local top_label = (current_page == 2) and "Top (DYN 1)" or "Top (FX PRE)"
                local bot_label = (current_page == 2) and "Bottom (DYN 2)" or "Bottom (FX POST)"
                
                if reaper.ImGui_RadioButton(ctx, top_label, builder_state.target_sec == 1) then
                    builder_state.target_sec = 1
                end
                
                reaper.ImGui_SameLine(ctx)
                
                if reaper.ImGui_RadioButton(ctx, bot_label, builder_state.target_sec == 2) then
                    builder_state.target_sec = 2
                end
            else
                -- Na EQ zavihku (Page 1) avtomatsko vsilimo zgornjo sekcijo
                builder_state.target_sec = 1
            end
            
            -- 2. SEKCIJA: DODAJANJE ELEMENTOV
            reaper.ImGui_SeparatorText(ctx, "ADD ELEMENT")
            
            -- Gumb KNOB
            if DrawIconButton("     KNOB", icon_knob, 80, 30) then
                SyncCurrentPositions()
                local element_count = #my_elements
                local nov_id = element_count + 100
                local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 54, 54, instance_panel_h)
                local param_target = GetAvailableParamID(my_elements, current_page, 1, spawn_y)
                
                if param_target > 0 then
                    local nov_element = {nov_id, 1, spawn_x, spawn_y, param_target, 54, 54, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                else
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the maximum number of knobs\n" .. "(including tubes and selectors) for this section!", "StripLink Builder", 0) end)
                end
            end
            
            reaper.ImGui_SameLine(ctx)
            
            -- Gumb SWITCH
            if DrawIconButton("    SWITCH", icon_switch, 80, 30) then
                SyncCurrentPositions()
                local element_count = #my_elements
                local nov_id = element_count + 100
                local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 32, 25, instance_panel_h)
                
                -- POIŠČI PROST ID ZA SWITCH NA TEM ZAVIHKU
                local param_target = GetAvailableParamID(my_elements, current_page, 2, spawn_y)
                
                if param_target > 0 then
                    local nov_element = {nov_id, 2, spawn_x, spawn_y, param_target, 32, 25, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                else
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the maximum number of switches for this section!", "StripLink Builder", 0)
                    end)
                end
            end
            
            reaper.ImGui_SameLine(ctx)
            
            -- Gumb TUBE
            if DrawIconButton("    TUBE", icon_tube, 80, 30) then
                SyncCurrentPositions()
                local element_count = #my_elements
                local nov_id = element_count + 100
                local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 45, 15, instance_panel_h)
                
                -- POIŠČI PROST ID ZA TUBE NA TEM ZAVIHKU
                local param_target = GetAvailableParamID(my_elements, current_page, 1, spawn_y)
                
                if param_target > 0 then
                    local nov_element = {nov_id, 3, spawn_x, spawn_y, param_target, 45, 15, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                else
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the maximum number of tubes\n" .. "(including knobs and selectors) for this section!", "StripLink Builder", 0) end)
                end
            end
            
            -- Gumb METER (Type 5)
            local meters_avail = CheckMeterAvailability(current_page, my_elements, -1)
            local can_add_gr = (builder_state.target_sec == 1) and meters_avail.gr_top or ((builder_state.target_sec == 2) and meters_avail.gr_bot)
            local can_add_meter = meters_avail.level or can_add_gr
            
            if not can_add_meter then reaper.ImGui_BeginDisabled(ctx) end
            if DrawIconButton("    METER", icon_meter, 80, 30) then
                SyncCurrentPositions()
                
                -- Določitev privzetega tipa metra ob spawnu glede na razpoložljivost
                local default_m_type = 0 -- Default je Level
                if not meters_avail.level and can_add_gr then
                    default_m_type = (builder_state.target_sec == 1) and 1 or 2 -- Horiz DYN1 ali DYN2
                end
                
                local m_w, m_h = 114, 14
                local element_count = #my_elements
                local nov_id = element_count + 100
                
                -- Spawn_y bo avtomatsko v pravi sekciji zaradi builder_state.target_sec!
                local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, m_w, m_h, instance_panel_h)
                
                local nov_element = {nov_id, 5, spawn_x, spawn_y, default_m_type, m_w, m_h, 0, "", 14, 0, current_page, 0, 0}
                table.insert(my_elements, nov_element)
                PushUILayout(current_slot)
            end
            if not can_add_meter then reaper.ImGui_EndDisabled(ctx) end
            
            reaper.ImGui_SameLine(ctx)
                    
            -- Gumb INPUT GAIN (Type 12)
            if DrawIconButton(" INPUT GAIN", nil, 80, 30) then
                if #my_elements >= 230 then
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the absolute graphical limit (230 elements) for this plugin!", "StripLink Builder", 0)
                    end)
                else
                    SyncCurrentPositions()
                    local element_count = #my_elements
                    local nov_id = element_count + 100
                    local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 66, 30, instance_panel_h)
                    
                    local nov_element = {nov_id, 12, spawn_x, spawn_y, 0, 66, 30, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                end
            end
            
            reaper.ImGui_SameLine(ctx)
            
            -- Gumb TEXT
            if DrawIconButton("     TEXT", icon_text, 80, 30) then
                if #my_elements >= 230 then
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the absolute graphical limit (230 elements) for this plugin!", "StripLink Builder", 0)
                    end)
                else
                    SyncCurrentPositions()
                    local element_count = #my_elements
                    local nov_id = element_count + 100
                    local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 40, 15, instance_panel_h)
                    
                    local default_text = "LABEL"
                    local part1 = EncodeStringToBase50(default_text:sub(1, 9))
                    local part2 = EncodeStringToBase50(default_text:sub(10, 18))
                    
                    local nov_element = {nov_id, 4, spawn_x, spawn_y, part1, 40, 15, part2, default_text, 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                end
            end
            
            -- SELECTOR (Type 7)
            if DrawIconButton("      SELECTOR", icon_selector, 125, 30) then
                SyncCurrentPositions()
                local element_count = #my_elements
                local nov_id = element_count + 100
                
                local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 90, 18, instance_panel_h)
                
                -- POPRAVEK: Tukaj namesto 1 pošlješ 7 (čeprav zaradi deljene logike delujeta oba)
                local param_target = GetAvailableParamID(my_elements, current_page, 7, spawn_y)
                
                if param_target > 0 then
                    local nov_element = {nov_id, 7, spawn_x, spawn_y, param_target, 90, 18, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                else
                    table.insert(pending_os_tasks, function()
                        -- POPRAVEK: Poenoteno besedilo z Gumbi in Tubami
                        reaper.MB("You have reached the maximum number of selectors\n(including knobs and tubes) for this section!", "StripLink Builder", 0)
                    end)
                end
            end
            
    
            reaper.ImGui_SameLine(ctx)
            
            -- Gumb SEPARATOR (Type 6)
            if DrawIconButton(" SEPARATOR", nil, -1, 30) then
                if #my_elements >= 230 then
                    table.insert(pending_os_tasks, function()
                        reaper.MB("You have reached the absolute graphical limit (230 elements) for this plugin!", "StripLink Builder", 0)
                    end)
                else
                    SyncCurrentPositions()
                    local element_count = #my_elements
                    local nov_id = element_count + 100
                    local spawn_x, spawn_y = GetNextElementPos(current_slot, current_page, 113, 31, instance_panel_h)
                    
                    local nov_element = {nov_id, 6, spawn_x, spawn_y, 3, 113, 31, 0, "", 14, 0, current_page, 0, 0}
                    table.insert(my_elements, nov_element)
                    PushUILayout(current_slot)
                end
            end
            
            -- 3. SEKCIJA: ODSTRANJEVANJE ELEMENTA
            reaper.ImGui_SeparatorText(ctx, "REMOVE ELEMENT")
            
            local elements = my_elements
            
            if #elements > 0 then
                local sel_from_jsfx = math.floor(reaper.gmem_read(outbox - 4))
                if sel_from_jsfx > 0 and sel_from_jsfx <= #elements then
                    -- Selekcijo sprejmemo le, če element pripada trenutno aktivnemu zavihku
                    if elements[sel_from_jsfx] and elements[sel_from_jsfx][12] == current_page then
                        builder_selected_idx = sel_from_jsfx
                    end
                end
                
                -- Varovalka: Če izbrani element pripada drugemu zavihku, fokusiramo prvega veljavnega na tem zavihku
                if not builder_selected_idx or not elements[builder_selected_idx] or elements[builder_selected_idx][12] ~= current_page then
                    builder_selected_idx = nil
                    for i, el in ipairs(elements) do
                        if el[12] == current_page then
                            builder_selected_idx = i
                            break
                        end
                    end
                end
                
                local current_el = builder_selected_idx and elements[builder_selected_idx] or nil

                -- KLJUČNA VAROVALKA: Kodo izvedemo SAMO, če je na TRENUTNEM zavihku izbran veljaven element
                if current_el then
                    local type_str = (current_el[2] == 1 and "Knob" or (current_el[2] == 2 and "Switch" or "Tube"))
                    if current_el[2] == 4 then type_str = "Text" end
                    if current_el[2] == 5 then type_str = "Meter" end
                    if current_el[2] == 6 then type_str = "Separator" end
                    if current_el[2] == 9 then type_str = "Auto Gain Power" end
                    if current_el[2] == 10 then type_str = "Auto Gain Lock" end
                    if current_el[2] == 12 then type_str = "Input Gain" end
                                
                    reaper.ImGui_AlignTextToFramePadding(ctx)
                    reaper.ImGui_TextColored(ctx, 0x99999999, string.format("Current sel.: #%d %s", builder_selected_idx, type_str))
                    
                    reaper.ImGui_SameLine(ctx)
                    
                    -- Gumb REMOVE (Skrit za sistemske elemente)
                    local is_system_element = (current_el[1] >= 900)
                    
                    if not is_system_element then
                        if DrawIconButton("     REMOVE", icon_remove, -1, 30) then
                            SyncCurrentPositions()
                            local removed_type = current_el[2] -- Shranimo tip, preden ga zbrišemo
                            
                            table.remove(elements, builder_selected_idx)
                            
                            -- ČE SMO BRISALI SELECTOR (7) ALI GROUP (8), ZBRIŠEMO ŠE DRUGEGA
                            if removed_type == 7 or removed_type == 8 then
                                local target_to_remove = (removed_type == 7) and 8 or 7
                                for j = #elements, 1, -1 do
                                    if elements[j][12] == current_page and elements[j][2] == target_to_remove then
                                        table.remove(elements, j)
                                        break
                                    end
                                end
                            end
                            
                            builder_selected_idx = math.max(1, #elements)
                            
                            if #elements == 0 then
                                reaper.gmem_write(outbox - 4, 0)
                            else
                                reaper.gmem_write(outbox - 4, builder_selected_idx)
                            end
                            
                            PushUILayout(current_slot)
                        end
                    else
                        reaper.ImGui_TextDisabled(ctx, "[System element]")
                    end
                    
                    -- Pazi, da Lua sama zapiše nazaj JSFX-u svojo selekcijo v primeru Property preklopa
                    if builder_selected_idx and builder_selected_idx > 0 then
                       reaper.gmem_write(outbox - 4, builder_selected_idx)
                    end
                    
                    -- 3.5 SEKCIJA: PROPERTIES
                    reaper.ImGui_SeparatorText(ctx, "PROPERTIES")
                    
                    local live_x = math.floor(reaper.gmem_read(outbox + ((builder_selected_idx - 1) * 13) + 2))
                    local live_y = math.floor(reaper.gmem_read(outbox + ((builder_selected_idx - 1) * 13) + 3))
                    
                    local flags = reaper.ImGui_InputTextFlags_EnterReturnsTrue() | reaper.ImGui_InputTextFlags_CharsDecimal()
                    local id_x = "X##" .. builder_selected_idx
                    local id_y = "Y##" .. builder_selected_idx
                    local id_s = "Size %##" .. builder_selected_idx
        
                    local changed_x, str_x = false, tostring(live_x)
                    
                    reaper.ImGui_SetNextItemWidth(ctx, 30)
                    -- Sistemskemu dividerju onemogočimo vpisovanje X koordinate
                    if current_el[1] >= 900 and current_el[2] == 6 then
                        reaper.ImGui_BeginDisabled(ctx)
                        reaper.ImGui_InputText(ctx, id_x, tostring(live_x), flags)
                        reaper.ImGui_EndDisabled(ctx)
                    else
                        changed_x, str_x = reaper.ImGui_InputText(ctx, id_x, tostring(live_x), flags)
                    end
                    
                    reaper.ImGui_SameLine(ctx)
                    reaper.ImGui_SetNextItemWidth(ctx, 30)
                    local changed_y, str_y = reaper.ImGui_InputText(ctx, id_y, tostring(live_y), flags)
                    
                    local el_type = current_el[2]
                                
                   local base_w, base_h = 54, 54
                   if el_type == 2 then 
                       base_w, base_h = 32, 25 -- Standardna osnova (default)
                       
                       -- PREVERIMO BARVO/TIP STIKALA DIREKTNO IZ GMEM-a
                       local btn_idx = current_el[5] or 0
                       if current_slot > 0 and btn_idx > 0 then
                           local k_idx = btn_idx - 1
                           local raw_status = reaper.gmem_read(PROJECT_BASE + current_slot * 500 + 150 + k_idx)
                           local cur_color = raw_status % 100
                           
                           -- Dinamično prilagajanje drsnika glede na izbrano stikalo
                           if cur_color == 5 then
                               base_w = 32
                               base_h = 50
                           elseif cur_color == 6 then
                               base_w = 50
                               base_h = 50
                           elseif cur_color == 7 or cur_color == 8 then
                               base_w = 51
                               base_h = 40
                           end
                       end
                       
                   elseif el_type == 3 then 
                        base_w, base_h = 45, 15 
                    elseif el_type == 5 then 
                        local sub_type = current_el[5] or 0
                        if sub_type == 3 or sub_type == 4 then
                            base_w, base_h = 14, 114 -- Vertikalni metri
                        elseif sub_type == 5 or sub_type == 6 then
                            base_w, base_h = 114, 64 -- Analogni GR metri
                            
                        else
                            base_w, base_h = 114, 14 -- Horizontalni in Level metri
                        end
                    elseif el_type == 6 then
                        base_w = 113
                        base_h = (current_el[5] == 5) and 10 or 31 
                    elseif el_type == 7 then
                        base_w, base_h = 90, 18
                    elseif el_type == 8 then
                        base_w, base_h = 66, 20
                    elseif el_type == 9 then
                        base_w, base_h = 40, 35
                    elseif el_type == 10 then
                        base_w, base_h = 17, 17
                    elseif el_type == 12 then
                        base_w, base_h = 66, 37
                    end
                    
                    if not current_el[6] or not current_el[7] then
                        current_el[6], current_el[7] = base_w, base_h
                    end
                    
                    local changed_size = false
                    local new_pct = 100
                    
                    if el_type ~= 4 and el_type ~= 7 then
                        local current_pct = math.floor((current_el[6] / base_w) * 100 + 0.5)
                        reaper.ImGui_SameLine(ctx)
                        reaper.ImGui_SetNextItemWidth(ctx, 117)
                        changed_size, new_pct = reaper.ImGui_SliderInt(ctx, id_s, current_pct, 50, 200)
                        
                        if changed_size then
                            new_pct = math.floor((new_pct + 2.5) / 5) * 5
                        end
                    end 
                    
                    if changed_x or changed_y or changed_size then
                        SyncCurrentPositions()
                        if changed_x then current_el[3] = math.floor(tonumber(str_x) or live_x) end
                        if changed_y then current_el[4] = math.floor(tonumber(str_y) or live_y) end
                        
                        if changed_size then
                            current_el[6] = math.floor((base_w * new_pct) / 100 + 0.5)
                            current_el[7] = math.floor((base_h * new_pct) / 100 + 0.5)
                            
                            if current_el[1] >= 900 and current_el[2] == 6 then
                                current_el[3] = math.floor((125 - current_el[6]) / 2)
                            end
                        end
                        PushUILayout(current_slot)
                    end
                    ---------------------------------------------------------
                    -- PORAVNAVA (LABEL POSITION & ANCHOR)
                    ---------------------------------------------------------
                   if el_type == 1 or el_type == 2 or el_type == 3 or el_type == 7 then
                        reaper.ImGui_SeparatorText(ctx, "LABEL POSITION & ANCHOR")
                        
                        local raw_dx = current_el[13] or 0
                        local raw_dy = current_el[14] or 0
                        
                        -- Razpakiramo naš decimalni format
                        local c_dx, c_align, c_ref = UnpackDX(raw_dx)
                        
                        -- 1. Dropdown za poravnavo
                        reaper.ImGui_SetNextItemWidth(ctx, 100)
                        local align_opts = "0 - Free\0 1 - Left\0 2 - Right\0 3 - Top\0 4 - Bottom\0"
                        local changed_align, new_align = reaper.ImGui_Combo(ctx, "Attachment Constraint##" .. builder_selected_idx, c_align, align_opts)
                        if changed_align then
                            local ref_w = 0
                            if new_align > 0 then
                                local p_text = current_el[9]
                                if not p_text or p_text == "" then p_text = "ID:" .. tostring(current_el[5]) end
                                -- Izmerimo širino trenutnega teksta za referenco
                                ref_w = math.floor(reaper.ImGui_CalcTextSize(ctx, p_text))
                            end
                            c_dx = 0
                            current_el[14] = 0
                            
                            -- Zapakiramo nazaj
                            current_el[13] = PackDX(c_dx, new_align, ref_w)
                            PushUILayout(current_slot)
                        end
                        
                        -- 2. Input polja za DX in DY
                        reaper.ImGui_SetNextItemWidth(ctx, 100)
                        local changed_dx, new_dx = reaper.ImGui_InputInt(ctx, "DX##" .. builder_selected_idx, c_dx, 1, 5)
                        if changed_dx then
                            current_el[13] = PackDX(new_dx, c_align, c_ref)
                            PushUILayout(current_slot)
                        end
                        
                        reaper.ImGui_SameLine(ctx, 140)
                        
                        reaper.ImGui_SetNextItemWidth(ctx, 100)
                        local changed_dy, new_dy = reaper.ImGui_InputInt(ctx, "DY##" .. builder_selected_idx, raw_dy, 1, 5)
                        if changed_dy then
                            current_el[14] = new_dy
                            PushUILayout(current_slot)
                        end
                    end
                    ---------------------------------------------------------
                    
                    if el_type == 2 then
                        reaper.ImGui_SeparatorText(ctx, "SWITCH BEHAVIOR")
                        local cur_dimmer = (current_el[11] == 1)
                        local changed_dimmer, new_dimmer = reaper.ImGui_Checkbox(ctx, "Master Section Dimmer", cur_dimmer)
                        
                        if changed_dimmer then
                            current_el[11] = new_dimmer and 1 or 0
                            PushUILayout(current_slot)
                        end
                    end

                    if el_type == 4 then
                        reaper.ImGui_SeparatorText(ctx, "TEXT CONTENT & STYLE")
                        reaper.ImGui_SetNextItemWidth(ctx, 130)
                        
                        local current_text = current_el[9] or ""
                        local changed_text, new_text = reaper.ImGui_InputText(ctx, "##TextInput" .. builder_selected_idx, current_text)
                        
                        reaper.ImGui_SameLine(ctx)
                        reaper.ImGui_SetNextItemWidth(ctx, 35)
                        local cur_size = current_el[10] or 14
                        local changed_sz, new_sz = reaper.ImGui_InputText(ctx, "px##sz" .. builder_selected_idx, tostring(cur_size), flags)
                        
                        reaper.ImGui_SameLine(ctx)
                        local cur_bold = (current_el[11] == 1)
                        local changed_bold, new_bold = reaper.ImGui_Checkbox(ctx, "Bold##b" .. builder_selected_idx, cur_bold)
                        
                        if changed_text or changed_sz or changed_bold then
                            SyncCurrentPositions()
                            if changed_text then
                                current_el[9] = new_text
                                current_el[5] = EncodeStringToBase50(new_text:sub(1, 9))
                                current_el[8] = EncodeStringToBase50(new_text:sub(10, 18))
                            end
                            if changed_sz then current_el[10] = tonumber(new_sz) or 14 end
                            if changed_bold then current_el[11] = new_bold and 1 or 0 end
                            
                            PushUILayout(current_slot)
                        end
                    end
                    
                    if el_type == 5 then
                        reaper.ImGui_SeparatorText(ctx, "METER SOURCE & SHAPE")
                        local cur_param = current_el[5] or 0
                        
                        local is_top_sec = true
                        -- Preverimo dejansko identiteto metra, ne glede na to, kje na zaslonu se nahaja
                        if cur_param == 1 or cur_param == 3 or cur_param == 5 then
                            is_top_sec = true
                        elseif cur_param == 2 or cur_param == 4 or cur_param == 6 then
                            is_top_sec = false
                        else
                            -- Če gre za osnovni Level Meter (0), uporabimo Y-pozicijo samo za določitev, v kateri GR meter se lahko pretvori
                            if current_page == 2 or current_page == 3 then
                                local div_y = 350
                                for _, e in ipairs(my_elements) do
                                    if e[12] == current_page and e[1] >= 900 and e[2] == 6 then
                                        div_y = e[4]
                                        break
                                    end
                                end
                                if current_el[4] >= div_y then is_top_sec = false end
                            end
                        end
                        
                        local cur_opt_idx = 1
                        if cur_param == 1 or cur_param == 2 then cur_opt_idx = 2
                        elseif cur_param == 3 or cur_param == 4 then cur_opt_idx = 3
                        elseif cur_param == 5 or cur_param == 6 then cur_opt_idx = 4
                        end
                        
                        local meter_opts = { 
                            "Level Meter", 
                            "Gain Reduction (Horizontal)", 
                            "Gain Reduction (Vertical)", 
                            "Gain Reduction (Analog)" 
                        }
                        
                        local avail = CheckMeterAvailability(current_page, my_elements, current_el[1])
                        
                        reaper.ImGui_SetNextItemWidth(ctx, 180)
                        if reaper.ImGui_BeginCombo(ctx, "##MeterType", meter_opts[cur_opt_idx]) then
                            for i, opt in ipairs(meter_opts) do
                                local is_allowed = false
                                if i == 1 then 
                                    is_allowed = avail.level 
                                else
                                    is_allowed = is_top_sec and avail.gr_top or ((not is_top_sec) and avail.gr_bot)
                                end
                                
                                if not is_allowed then reaper.ImGui_BeginDisabled(ctx) end
                                
                                if reaper.ImGui_Selectable(ctx, opt, (cur_opt_idx == i)) then
                                    SyncCurrentPositions()
                                    local new_param = 0
                                    local is_meter_two = (cur_param == 2 or cur_param == 4 or cur_param == 6)
                                    
                                    if i == 1 then new_param = 0
                                    elseif i == 2 then new_param = is_meter_two and 2 or 1
                                    elseif i == 3 then new_param = is_meter_two and 4 or 3
                                    elseif i == 4 then new_param = is_meter_two and 6 or 5
                                    end
                                    
                                    current_el[5] = new_param
                                    
                                    if new_param == 3 or new_param == 4 then
                                        current_el[6] = 14; current_el[7] = 114
                                    elseif new_param == 5 or new_param == 6 then
                                        current_el[6] = 114; current_el[7] = 64
                                    else
                                        current_el[6] = 114; current_el[7] = 14
                                    end
                                    
                                    PushUILayout(current_slot)
                                end
                                
                                if not is_allowed then reaper.ImGui_EndDisabled(ctx) end
                            end
                            reaper.ImGui_EndCombo(ctx)
                        end
                    end
                    
                    if el_type == 6 then
                        reaper.ImGui_SeparatorText(ctx, "SEPARATOR SHAPE")
                        local cur_shape = current_el[5] or 0
                        reaper.ImGui_SetNextItemWidth(ctx, 160)
                        
                        if current_el[1] >= 900 then
                            reaper.ImGui_BeginDisabled(ctx)
                            reaper.ImGui_SliderInt(ctx, "##SepShape", 5, 0, 10, "Fixed System Line")
                            reaper.ImGui_EndDisabled(ctx)
                            
                            if current_el[5] ~= 5 then
                                current_el[5] = 5
                                PushUILayout(current_slot)
                            end
                        else
                            local changed_shape, new_shape = reaper.ImGui_SliderInt(ctx, "##SepShape", cur_shape, 0, 10, "Style %d")
                            
                            if changed_shape then
                                SyncCurrentPositions()
                                current_el[5] = new_shape
                                local new_base_h = (new_shape == 5) and 10 or 31
                                local current_pct = math.floor((current_el[6] / 113) * 100 + 0.5)
                                current_el[7] = math.floor((new_base_h * current_pct) / 100 + 0.5)
                                PushUILayout(current_slot)
                            end
                        end
                    end
                    
                    if el_type == 7 then
                        reaper.ImGui_SeparatorText(ctx, "SELECTOR STEPS")
                        local current_steps = current_el[8] or 0
                        local is_auto = (current_steps == 0 or current_steps == 1)
                        
                        local changed_auto, new_auto = reaper.ImGui_Checkbox(ctx, "Auto detect##sel_auto", is_auto)
                        if changed_auto then
                            SyncCurrentPositions()
                            if new_auto then
                                current_el[8] = 0
                            else
                                current_el[8] = 2
                            end
                            PushUILayout(current_slot)
                        end
                        
                        reaper.ImGui_SameLine(ctx)
                        reaper.ImGui_SetNextItemWidth(ctx, 70)
                        local display_val = is_auto and 0 or current_steps
                        
                        if is_auto then reaper.ImGui_BeginDisabled(ctx) end
                        
                        local changed_s, new_s = reaper.ImGui_InputInt(ctx, "Steps (2-20)##sel_steps", display_val, 0)
                        
                        if changed_s then
                            SyncCurrentPositions()
                            if new_s <= 1 then
                                current_el[8] = 0
                            elseif new_s > 20 then
                                current_el[8] = 20
                            else
                                current_el[8] = new_s
                            end
                            PushUILayout(current_slot)
                        end
                        
                        if is_auto then reaper.ImGui_EndDisabled(ctx) end
                    end
                else
                    -- Če na trenutnem zavihku ni nobenega izbranega elementa
                    reaper.ImGui_TextDisabled(ctx, "No elements selected on this Tab!")
                end
            else
                reaper.ImGui_TextDisabled(ctx, "No elements on this Tab!")
            end
    
            -- 4. SEKCIJA: NASTAVITVE MREŽE
            reaper.ImGui_SeparatorText(ctx, "GRID SETTINGS")
            
            local grid_val = math.floor(reaper.gmem_read(sl_base + 429))
            if grid_val <= 0 then 
                grid_val = 2 
                reaper.gmem_write(sl_base + 429, grid_val)
            end
            
            reaper.ImGui_SetNextItemWidth(ctx, 255)
            local changed, new_grid = reaper.ImGui_SliderInt(ctx, "##GridSnap", grid_val, 1, 20)
            if changed then
                reaper.gmem_write(sl_base + 429, new_grid)
            end
            reaper.ImGui_TextDisabled(ctx, "Current Grid: " .. new_grid .. " px")
        end
    end    
    -- ENKRATNI ZAKLJUČEK OKNA
    reaper.ImGui_End(ctx)
    
    -- ENKRATNO ČIŠČENJE STILOV (14 barv in 4 variabl-e)
    reaper.ImGui_PopStyleColor(ctx, 14)
    reaper.ImGui_PopStyleVar(ctx, 4)
end

-- === MAIN LOOP (DEFER) ===
local delay_frames = 0
function Run()
    if not __startup_sync_done then
        __startup_sync_done = true
        reaper.defer(Run)
        return
    end

    local tb_ok, tb_err = xpcall(DrawLayoutBuilderToolbox, debug.traceback)
    
    if not tb_ok then
        -- 1. Varovalka: Kodo izvedemo SAMO ENKRAT
        if not __builder_error_logged then
            __builder_error_logged = true
            
            local err_msg = tostring(tb_err)
            local log_path = reaper.GetResourcePath() .. "/StripLink_BugLog.txt"
            
            -- Poskusimo zapisati na disk
            local f = io.open(log_path, "a")
            if f then 
                f:write(os.date() .. " - CRASH: " .. err_msg .. "\n")
                f:close() 
            else
                -- Če Linux blokira pisanje na disk, vržemo klasično pojavno okno SAMO ENKRAT!
                reaper.MB("StripLink Builder Error:\n\n" .. err_msg .. "\n\nProsim, naredite posnetek zaslona tega okna in ga pošljite razvijalcu.", "StripLink: Debug Info", 0)
            end
        end
        
        -- 2. Varno ugasnemo Builder v GMEM-u
        builder_state.open = false
        if PROJECT_BASE then
            local current_slot = math.floor(reaper.gmem_read(PROJECT_BASE + 8))
            if current_slot > 0 then
                reaper.gmem_write(PROJECT_BASE + current_slot * 500 + 428, 0)
            end
        end
    end

    local window_flags = reaper.ImGui_WindowFlags_NoDecoration() | 
                         reaper.ImGui_WindowFlags_NoBackground() | 
                         reaper.ImGui_WindowFlags_NoSavedSettings() |
                         reaper.ImGui_WindowFlags_NoNav()
                         
    if not popup_state.is_visible and not popup_state.request_open then
        window_flags = window_flags | reaper.ImGui_WindowFlags_NoInputs()
        window_flags = window_flags | reaper.ImGui_WindowFlags_NoFocusOnAppearing()
    end
                         
    reaper.ImGui_SetNextWindowSize(ctx, 0, 0)
    reaper.ImGui_SetNextWindowPos(ctx, 0, 0)
    
    local visible, open = reaper.ImGui_Begin(ctx, 'StripLinkContext', true, window_flags)
    
    if visible then
        local menu_ok, menu_err = xpcall(DrawMenus, debug.traceback)
        if not menu_ok then
            reaper.ShowConsoleMsg("\n=== STRIPLINK MENU ERROR ===\n" .. tostring(menu_err) .. "\n============================\n")
            popup_state.is_visible = false
            popup_state.active_cmd = 0
            reaper.gmem_write(PROJECT_BASE + 7, 0)
            reaper.gmem_write(PROJECT_BASE + 206, 0)
        end
    end
    reaper.ImGui_End(ctx)
    
    local main_ok, main_err = xpcall(Main, debug.traceback)
    if not main_ok then
        reaper.ShowConsoleMsg("\n=== STRIPLINK MAIN ERROR ===\n" .. tostring(main_err) .. "\n============================\n")
        reaper.gmem_write(PROJECT_BASE + 7, 0)
        reaper.gmem_write(PROJECT_BASE + 206, 0)
    end
    
    local man_ok, man_err = xpcall(ManageAll, debug.traceback)
    if not man_ok then
        reaper.ShowConsoleMsg("\n=== STRIPLINK MANAGE ERROR ===\n" .. tostring(man_err) .. "\n==============================\n")
    end
    
    -- ===== ZAMAKNJENO IZVAJANJE NALOG (ReaImGui Fix) =====
    if #pending_os_tasks > 0 and not popup_state.is_visible then
        if delay_frames > 0 then
            delay_frames = delay_frames - 1
        else
            local task = table.remove(pending_os_tasks, 1)
            local t_ok, t_err = pcall(task)
            if not t_ok then reaper.ShowConsoleMsg("\nTask Error:\n" .. tostring(t_err) .. "\n") end
            delay_frames = 2 
        end
    else
        delay_frames = 2 
    end
    -- =====================================================
    
    if open then
        reaper.defer(Run)
    end
end

Run()


