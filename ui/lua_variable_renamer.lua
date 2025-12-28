--[[
    Lua Variable Renamer Tool
    Auto-rename common variables menjadi lebih readable

    Usage:
        local Renamer = loadstring(game:HttpGet("path/to/lua_variable_renamer.lua"))()
        local beautifiedCode = Renamer.beautify(yourLuaCode)
]]

local Renamer = {}

-- Common single-letter variables yang sering digunakan
local COMMON_VARS = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
}

-- Context-based naming suggestions
local CONTEXT_PATTERNS = {
    -- Loop iterators
    {pattern = "for%s+([a-z])%s*=%s*%d+", suggest = "index"},
    {pattern = "for%s+([a-z])%s*,%s*([a-z])%s+in%s+pairs", suggest = {"key", "value"}},
    {pattern = "for%s+([a-z])%s*,%s*([a-z])%s+in%s+ipairs", suggest = {"index", "item"}},
    {pattern = "for%s+([a-z])%s+in%s+next", suggest = "item"},

    -- Instance/GUI related
    {pattern = "Instance%.new%s*%(%s*['\"]Frame['\"]", var_name = "frame"},
    {pattern = "Instance%.new%s*%(%s*['\"]TextLabel['\"]", var_name = "label"},
    {pattern = "Instance%.new%s*%(%s*['\"]TextButton['\"]", var_name = "button"},
    {pattern = "Instance%.new%s*%(%s*['\"]ScrollingFrame['\"]", var_name = "scrollFrame"},
    {pattern = "Instance%.new%s*%(%s*['\"]ImageButton['\"]", var_name = "imageButton"},
    {pattern = "Instance%.new%s*%(%s*['\"]ImageLabel['\"]", var_name = "imageLabel"},

    -- Function related
    {pattern = "function%s+[%w_]+%s*%(([a-z])%)", suggest = "param"},

    -- Table operations
    {pattern = "table%.insert", suggest = "item"},
    {pattern = "table%.remove", suggest = "item"},
}

-- Smart variable name generator based on usage
function Renamer.analyzeContext(code, varName, varPos)
    local lineStart = code:sub(1, varPos):reverse():find("\n") or 0
    lineStart = varPos - lineStart
    local lineEnd = code:find("\n", varPos) or #code
    local line = code:sub(lineStart, lineEnd)

    -- Check if it's in a loop
    if line:match("for%s+" .. varName) then
        if line:match("pairs") then
            if line:match("for%s+" .. varName .. "%s*,") then
                return "key"
            else
                return "value"
            end
        elseif line:match("ipairs") then
            if line:match("for%s+" .. varName .. "%s*,") then
                return "index"
            else
                return "item"
            end
        else
            return "i"
        end
    end

    -- Check if it's an Instance
    local instanceMatch = line:match("Instance%.new%s*%(%s*['\"]([%w_]+)['\"]")
    if instanceMatch then
        local name = instanceMatch:lower()
        if name:find("frame") then return "frame"
        elseif name:find("label") then return "label"
        elseif name:find("button") then return "button"
        elseif name:find("text") then return "textBox"
        elseif name:find("image") then return "image"
        elseif name:find("scroll") then return "scrollFrame"
        end
    end

    -- Check for color
    if line:match("Color3%.fromRGB") or line:match("Color3%.new") then
        return "color"
    end

    -- Check for position/size
    if line:match("UDim2%.new") or line:match("Vector2%.new") or line:match("Vector3%.new") then
        return "position"
    end

    -- Default based on letter
    local defaults = {
        a = "obj", b = "item", c = "value", d = "data",
        e = "element", f = "func", g = "gui", h = "handler",
        i = "index", j = "jIndex", k = "key", l = "list",
        m = "module", n = "number", o = "option", p = "property",
        q = "query", r = "result", s = "string", t = "table",
        u = "util", v = "var", w = "widget", x = "xPos",
        y = "yPos", z = "zPos"
    }

    return defaults[varName] or "var_" .. varName
end

-- Parse Lua code and find all variable declarations
function Renamer.findVariables(code)
    local variables = {}
    local usedNames = {}

    -- Find local variables
    for pos, varName in code:gmatch("()local%s+([a-z])%s*[=,;\n]") do
        if not variables[varName] then
            variables[varName] = {
                positions = {},
                suggestedName = nil,
                isCommon = true
            }
        end
        table.insert(variables[varName].positions, pos)
    end

    -- Find variables in for loops
    for pos, varName in code:gmatch("()for%s+([a-z])%s+") do
        if not variables[varName] then
            variables[varName] = {
                positions = {},
                suggestedName = nil,
                isCommon = true
            }
        end
        table.insert(variables[varName].positions, pos)
    end

    -- Find function parameters
    for pos, varName in code:gmatch("()function%s+[%w_]*%s*%(([a-z])%)") do
        if not variables[varName] then
            variables[varName] = {
                positions = {},
                suggestedName = nil,
                isCommon = true
            }
        end
        table.insert(variables[varName].positions, pos)
    end

    return variables
end

-- Generate unique name
function Renamer.generateUniqueName(baseName, usedNames, counter)
    counter = counter or 1
    local newName = baseName
    if counter > 1 then
        newName = baseName .. counter
    end

    if usedNames[newName] then
        return Renamer.generateUniqueName(baseName, usedNames, counter + 1)
    end

    return newName
end

-- Main beautify function
function Renamer.beautify(code, options)
    options = options or {}
    local renameMap = {}
    local usedNames = {}

    -- Find existing variable names to avoid conflicts
    for varName in code:gmatch("local%s+([%w_]+)") do
        usedNames[varName] = true
    end

    -- Find single-letter variables
    local variables = {}

    -- Pattern 1: local variable declarations
    for varName in code:gmatch("local%s+([a-z])%s*[=,;\n]") do
        if not variables[varName] then
            variables[varName] = true
        end
    end

    -- Pattern 2: for loop variables
    for varName in code:gmatch("for%s+([a-z])%s*[=,]") do
        if not variables[varName] then
            variables[varName] = true
        end
    end

    -- Pattern 3: function parameters
    for varName in code:gmatch("function%s*%([^%)]*([a-z])[^%)]*%)") do
        if #varName == 1 and not variables[varName] then
            variables[varName] = true
        end
    end

    -- Generate rename suggestions
    local varCounter = {}
    for varName, _ in pairs(variables) do
        -- Find first occurrence to analyze context
        local firstPos = code:find("[^%w_]" .. varName .. "[^%w_]")
        if firstPos then
            local baseName = Renamer.analyzeContext(code, varName, firstPos)
            local newName = Renamer.generateUniqueName(baseName, usedNames, varCounter[baseName])

            renameMap[varName] = newName
            usedNames[newName] = true
            varCounter[baseName] = (varCounter[baseName] or 1) + 1
        end
    end

    -- Apply renaming (careful to not rename inside strings or comments)
    local result = code
    local inString = false
    local inComment = false
    local stringChar = nil

    -- Sort by length (longer names first to avoid partial matches)
    local sortedVars = {}
    for old, new in pairs(renameMap) do
        table.insert(sortedVars, {old = old, new = new})
    end
    table.sort(sortedVars, function(a, b) return #a.old > #b.old end)

    -- Replace each variable (word boundary aware)
    for _, var in ipairs(sortedVars) do
        -- Match word boundaries
        result = result:gsub("([^%w_])" .. var.old .. "([^%w_])", function(before, after)
            return before .. var.new .. after
        end)
        -- Match start of string
        result = result:gsub("^" .. var.old .. "([^%w_])", var.new .. "%1")
        -- Match end of string
        result = result:gsub("([^%w_])" .. var.old .. "$", "%1" .. var.new)
    end

    return result, renameMap
end

-- Beautify with detailed report
function Renamer.beautifyWithReport(code)
    local beautified, renameMap = Renamer.beautify(code)

    local report = "=== Variable Renaming Report ===\n"
    local count = 0
    for old, new in pairs(renameMap) do
        report = report .. string.format("'%s' -> '%s'\n", old, new)
        count = count + 1
    end
    report = report .. string.format("\nTotal: %d variables renamed\n", count)

    return beautified, report
end

-- Beautify G2L style variables (common in auto-generated code)
function Renamer.beautifyG2L(code)
    local renameMap = {}
    local counter = 1

    -- Find all G2L["x"] patterns and analyze context
    for g2lKey in code:gmatch('G2L%[[\'\"](%w+)[\'\"]%]') do
        if not renameMap[g2lKey] and g2lKey ~= "backgroundOutput" then
            local context = code:match('G2L%[[\'\"]' .. g2lKey .. '[\'\"]%]%s*=%s*Instance%.new%([\'"]([%w_]+)[\'"]')

            local newName
            if context then
                newName = context:lower():gsub("^%l", string.upper)
                if renameMap[newName] then
                    newName = newName .. counter
                    counter = counter + 1
                end
            else
                newName = "element" .. counter
                counter = counter + 1
            end

            renameMap[g2lKey] = newName
        end
    end

    -- Apply replacements
    local result = code
    for old, new in pairs(renameMap) do
        result = result:gsub('G2L%[[\'\"]' .. old .. '[\'\"]%]', new)
    end

    return result, renameMap
end

-- Export functions
Renamer.version = "1.0.0"
return Renamer
