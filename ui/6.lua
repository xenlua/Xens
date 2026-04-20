local HttpService = game:GetService("HttpService")

local ConfigManager = {
    Folder = nil,
    Path = nil,
    Configs = {},
    ExcludedTitles = {},
    Window = nil,
    Parser = {
        Colorpicker = {
            Save = function(obj)
                local color = obj.Default or obj.Value or Color3.new(1, 1, 1)
                local colorHex
                
                if typeof(color) == "Color3" then
                    colorHex = "#" .. color:ToHex()
                else
                    colorHex = "#FFFFFF"
                end
                
                return {
                    __type = obj.__type,
                    value = colorHex,
                    transparency = obj.Transparency or 0,
                }
            end,
            Load = function(element, data)
                if element then
                    local color = Color3.fromHex(data.value or "#FFFFFF")
                    local transparency = data.transparency or 0
                    
                    element.Default = color
                    element.Value = color
                    element.Transparency = transparency
                    
                    if element.Update then
                        element:Update(color, transparency)
                    end
                    
                    task.spawn(function()
                        task.wait(0.15)
                        if element.Callback then
                            element.Callback(color, transparency)
                        end
                    end)
                end
            end
        },
        Dropdown = {
            Save = function(obj)
                local value = obj.Value
                local isMulti = obj.Multi or false
                
                if isMulti and type(value) ~= "table" then
                    value = {}
                end
                
                return {
                    __type = obj.__type,
                    value = value,
                    multi = isMulti,
                }
            end,
            Load = function(element, data)
                if not element or not element.Select then return end
                
                local value = data.value
                local isMulti = data.multi or element.Multi or false
                
                task.spawn(function()
                    task.wait(0.15)
                    
                    element.Value = value
                    
                    if isMulti then
                        if type(value) ~= "table" then
                            value = {}
                        end
                        element.Multi = true
                    end
                    
                    pcall(function()
                        element:Select(value)
                    end)
                    
                    task.wait(0.2)
                    if element.Callback then
                        pcall(function()
                            element.Callback(value)
                        end)
                    end
                end)
            end
        },
        Input = {
            Save = function(obj)
                -- Input di Avantrix pake .Text, bukan .Value
                local value = obj.Text or ""
                return {
                    __type = obj.__type,
                    value = tostring(value),
                }
            end,
            Load = function(element, data)
                if element then
                    local value = data.value or ""
                    
                    -- Langsung set ke properti asli library
                    element.Text = value
                    
                    if element.Set then
                        element:Set(value)
                    end
                    
                    task.spawn(function()
                        task.wait(0.2)
                        if element.Callback then
                            element.Callback(value)
                        end
                    end)
                end
            end
        },
        Keybind = {
            Save = function(obj)
                local value = obj.Value
                if typeof(value) == "EnumItem" then
                    value = value.Name
                end
                return {
                    __type = obj.__type,
                    value = tostring(value),
                }
            end,
            Load = function(element, data)
                if element then
                    local value = data.value
                    
                    if type(value) == "string" and value ~= "None" and Enum.KeyCode[value] then
                        value = Enum.KeyCode[value]
                    end
                    
                    element.Value = value
                    
                    if element.Set then
                        element:Set(value)
                    end
                    
                    task.spawn(function()
                        task.wait(0.1)
                        if element.Callback then
                            element.Callback(value)
                        end
                    end)
                end
            end
        },
        Slider = {
            Save = function(obj)
                -- Slider Avantrix pake .Value
                local value = obj.Value
                if type(value) == "table" then
                    value = value.Default or 0
                end
                
                return {
                    __type = obj.__type,
                    value = tonumber(value) or 0,
                }
            end,
            Load = function(element, data)
                if element then
                    local value = tonumber(data.value) or 0
                    element.Value = value
                    
                    if element.Set then
                        element:Set(value)
                    end
                    
                    task.spawn(function()
                        task.wait(0.2)
                        if element.Callback then
                            element.Callback(value)
                        end
                    end)
                end
            end
        },
        Toggle = {
            Save = function(obj)
                -- Toggle di Avantrix pake .State, bukan .Value
                local value = obj.State
                if value == nil then value = false end
                
                return {
                    __type = obj.__type,
                    value = value == true,
                }
            end,
            Load = function(element, data)
                if element then
                    local targetValue = data.value == true
                    
                    -- Langsung set ke State asli library
                    element.State = targetValue
                    
                    -- Update visual
                    if element.Set then
                        pcall(function()
                            element:Set(targetValue)
                        end)
                    end
                    
                    -- Trigger callback
                    task.spawn(function()
                        task.wait(0.2)
                        if element.Callback then
                            pcall(function()
                                element.Callback(targetValue)
                            end)
                        end
                    end)
                end
            end
        },
        Section = {
            Save = function(obj)
                local opened = obj.Opened
                if opened == nil then opened = obj.State end
                if opened == nil then opened = false end
                
                return {
                    __type = obj.__type,
                    opened = opened == true,
                }
            end,
            Load = function(element, data)
                if element then
                    local targetValue = data.opened == true
                    element.Opened = targetValue
                    element.State = targetValue
                    
                    task.spawn(function()
                        task.wait(0.1)
                        if targetValue and element.Open then
                            element:Open()
                        elseif not targetValue and element.Close then
                            element:Close()
                        end
                    end)
                end
            end
        },
    }
}

function ConfigManager:Init(WindowTable, OptionalAvantrix, OptionalTab)
    if not WindowTable or type(WindowTable) ~= "table" then
        return false
    end
    
    -- Native support in library ensures WindowTable.AllElements is automatically populated.
    -- No external hooks needed anymore.

    ConfigManager.Window = WindowTable
    
    -- Mendapatkan folder dasar dari FileSaveName jika ada, atau gunakan Folder
    local basePath = tostring(WindowTable.Folder or "Avantrix")
    if WindowTable.FileSaveName then
        local folderFromPath = WindowTable.FileSaveName:match("(.+)/[^/]+$")
        if folderFromPath then
            basePath = folderFromPath
        end
    end

    ConfigManager.Folder = basePath
    ConfigManager.Path = basePath .. "/configs/"
    
    if not isfolder(basePath) then
        pcall(makefolder, basePath)
    end
    if not isfolder(ConfigManager.Path) then
        pcall(makefolder, ConfigManager.Path)
    end
    
    -- RESTORE LIBRARY SETTINGS (EARLY)
    pcall(function()
        local AutoloadConfig = ConfigManager:CreateConfig("_autoload_settings")
        AutoloadConfig.AutoRegisterEnabled = false -- JANGAN simpan tombol UI ke sini! 
        AutoloadConfig:Load()
        local savedAutoSave = AutoloadConfig:Get("library_autosave")
        if savedAutoSave ~= nil then
            if WindowTable.SetAutoSave then
                WindowTable:SetAutoSave(savedAutoSave)
            else
                WindowTable.AutoSave = savedAutoSave
            end
        end
    end)
    
    -- Auto Setup Detection
    task.spawn(function()
        task.wait(0.1)
        local targetTab = OptionalTab
        
        if not targetTab then
            -- Search for tab in WindowTable or its children
            for _, v in pairs(WindowTable) do
                if type(v) == "table" and v.Title == "ConfigManager" and (v.Input or v.Button) then
                    targetTab = v
                    break
                end
            end
        end
        
        if targetTab then
            ConfigManager:SetupConfigUI(targetTab, OptionalAvantrix)
        end
    end)
    
    return ConfigManager
end

function ConfigManager:CreateConfig(configFilename)
    -- Cek memori (cache) dulu, kalau sudah ada jangan bikin baru biar datanya gak ilang
    if ConfigManager.Configs[configFilename] then
        return ConfigManager.Configs[configFilename]
    end

    local ConfigModule = {
        Path = ConfigManager.Path .. configFilename .. ".json",
        Elements = {},
        CustomData = {},
        Version = 1.4,
        AutoRegisterEnabled = true
    }
    
    if not configFilename then
        return false, "No config file is selected"
    end
    
    function ConfigModule:AutoRegisterElements()
        if not ConfigManager.Window then
            return 0
        end
        
        ConfigModule.Elements = {}
        local count = 0
        
        if ConfigManager.Window.AllElements then
            for i, element in ipairs(ConfigManager.Window.AllElements) do
                if element and element.__type and ConfigManager.Parser[element.__type] then
                    if element.Title and not ConfigManager.ExcludedTitles[element.Title] then
                        -- Mencari Tab name dari properti native library yang baru
                        local tabName = element.__tab or "Unknown"
                        local elementName = tabName .. "/" .. (element.Title or ("Element_" .. i))
                        ConfigModule.Elements[elementName] = element
                        count = count + 1
                    end
                end
            end
        end
        
        return count
    end
    
    function ConfigModule:Register(Name, Element)
        if not Name or not Element then
            return false
        end
        ConfigModule.Elements[Name] = Element
        return true
    end
    
    function ConfigModule:Unregister(Name)
        if ConfigModule.Elements[Name] then
            ConfigModule.Elements[Name] = nil
            return true
        end
        return false
    end
    
    function ConfigModule:Set(key, value)
        if not key then
            return false
        end
        ConfigModule.CustomData[key] = value
        return true
    end
    
    function ConfigModule:Get(key, defaultValue)
        if ConfigModule.CustomData[key] ~= nil then
            return ConfigModule.CustomData[key]
        end
        return defaultValue
    end
    
    function ConfigModule:Save()
        if ConfigModule.AutoRegisterEnabled then
            ConfigModule:AutoRegisterElements()
        end
        
        local saveData = {
            __version = ConfigModule.Version,
            __elements = {},
            __custom = ConfigModule.CustomData
        }
        
        for name, element in pairs(ConfigModule.Elements) do
            if element.__type and ConfigManager.Parser[element.__type] then
                local success, data = pcall(function()
                    return ConfigManager.Parser[element.__type].Save(element)
                end)
                
                if success and data then
                    saveData.__elements[tostring(name)] = data
                end
            end
        end
        
        local success, jsonData = pcall(function()
            return HttpService:JSONEncode(saveData)
        end)
        
        if success and writefile then
            writefile(ConfigModule.Path, jsonData)
            return true
        end
        
        return false
    end
    
    function ConfigModule:Load()
        if not isfile(ConfigModule.Path) then
            return false, "Config file does not exist"
        end
        
        local success, loadData = pcall(function()
            local fileContent = readfile(ConfigModule.Path)
            return HttpService:JSONDecode(fileContent)
        end)
        
        if not success then
            return false, "Failed to parse config"
        end
        
        if ConfigModule.AutoRegisterEnabled then
            ConfigModule:AutoRegisterElements()
        end
        
        for name, data in pairs(loadData.__elements or {}) do
            if ConfigModule.Elements[name] and data.__type and ConfigManager.Parser[data.__type] then
                pcall(function()
                    ConfigManager.Parser[data.__type].Load(ConfigModule.Elements[name], data)
                end)
            end
        end
        
        ConfigModule.CustomData = loadData.__custom or {}
        return true, ConfigModule.CustomData
    end
    
    ConfigManager.Configs[configFilename] = ConfigModule
    return ConfigModule
end

function ConfigManager:AllConfigs()
    if not listfiles then 
        return {} 
    end

    local files = {}
    
    if not isfolder(ConfigManager.Path) then
        return files
    end

    local success, fileList = pcall(function()
        return listfiles(ConfigManager.Path)
    end)
    
    if not success then
        return files
    end

    for _, file in pairs(fileList) do
        local name = file:match("([^\\/]+)%.json$")
        if name and name ~= "_autoload_settings" then
            table.insert(files, name)
        end
    end

    table.sort(files)
    return files
end

function ConfigManager:DeleteConfig(configName)
    if not configName or configName == "" then
        return false, "Config name is empty"
    end

    local filePath = ConfigManager.Path .. configName .. ".json"

    if not isfile(filePath) then
        return false, "Config file not found"
    end

    local success, err = pcall(function()
        delfile(filePath)
    end)

    if not success then
        return false, "Failed to delete: " .. tostring(err)
    end

    if ConfigManager.Configs[configName] then
        ConfigManager.Configs[configName] = nil
    end

    return true
end

function ConfigManager:ConfigExists(configName)
    if not configName or configName == "" then
        return false
    end

    local filePath = ConfigManager.Path .. configName .. ".json"
    return isfile(filePath)
end

function ConfigManager:AddExcludedTitle(title)
    if not title or title == "" then
        return false
    end
    ConfigManager.ExcludedTitles[title] = true
    return true
end

function ConfigManager:RemoveExcludedTitle(title)
    if not title then
        return false
    end
    ConfigManager.ExcludedTitles[title] = nil
    return true
end

function ConfigManager:ClearExcludedTitles()
    ConfigManager.ExcludedTitles = {}
    return true
end

function ConfigManager:SaveConfig(configName)
    if not configName or configName == "" then
        return false, "Config name is empty"
    end

    local success, err = pcall(function()
        local configFile = ConfigManager:CreateConfig(configName)
        if not configFile then
            error("Failed to create config object")
        end
        
        local saveSuccess = configFile:Save()
        if not saveSuccess then
            error("Failed to save config")
        end
    end)

    if not success then
        return false, "Failed to save: " .. tostring(err)
    end

    return true
end

function ConfigManager:LoadConfig(configName)
    if not configName or configName == "" then
        return false, "Config name is empty"
    end

    if not ConfigManager:ConfigExists(configName) then
        return false, "Config does not exist"
    end

    local success, result = pcall(function()
        local configFile = ConfigManager:CreateConfig(configName)
        if not configFile then
            error("Failed to create config object")
        end
        
        local loadSuccess, customData = configFile:Load()
        if not loadSuccess then
            error(customData or "Failed to load config")
        end
        
        return customData
    end)

    if not success then
        return false, "Failed to load: " .. tostring(result)
    end

    return true, result
end

function ConfigManager:SetupConfigUI(tab, Avantrix)
    -- Fallback to find Avantrix if not passed
    if not Avantrix then
        if tab.Library then Avantrix = tab.Library
        elseif tab.Window and tab.Window.Library then Avantrix = tab.Window.Library
        elseif ConfigManager.Window and ConfigManager.Window.Library then Avantrix = ConfigManager.Window.Library
        end
    end
    local libraryAutoSaveToggle
    local inputPath = nil
    local selectedConfig = nil
    local AutoloadConfigName = "_autoload_settings"
    local AutoloadConfig = ConfigManager:CreateConfig(AutoloadConfigName)
    
    AutoloadConfig:Load()
    
    tab:Section({ Title = "Configuration", Icon = "settings" })

    local configNameInput = tab:Input({
        Title = "Config Name",
        Placeholder = "Enter config name",
        Callback = function(text)
            inputPath = text
        end,
    })

    local configSelection = tab:Dropdown({
        Title = "Select Config",
        Multi = false,
        AllowNone = true,
        Value = "",
        Values = ConfigManager:AllConfigs(),
        Callback = function(value)
            selectedConfig = value
        end,
    })

    tab:Button({
        Title = "Create Config",
        Desc = "Save current settings as new config",
        Icon = "save",
        Callback = function()
            if not inputPath or inputPath:gsub(" ", "") == "" then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Config name cannot be empty",
                        Icon = "triangle-alert",
                        Duration = 3,
                    })
                end)
                return
            end

            local success, err = ConfigManager:SaveConfig(inputPath)

            if not success then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Unable to save: " .. tostring(err),
                        Icon = "x-circle",
                        Duration = 3,
                    })
                end)
                return
            end

            pcall(function()
                Avantrix:Notify({
                    Title = "Config Saved",
                    Content = "Created config '" .. inputPath .. "'",
                    Icon = "check-circle",
                    Duration = 3,
                })
            end)

            configSelection:Refresh(ConfigManager:AllConfigs())
            configNameInput:Set("")
            inputPath = nil
        end,
    })

    tab:Button({
        Title = "Load Config",
        Desc = "Load selected configuration",
        Icon = "folder-open",
        Callback = function()
            if not selectedConfig then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Please select a config to load",
                        Icon = "info",
                        Duration = 3,
                    })
                end)
                return
            end

            local success, result = ConfigManager:LoadConfig(selectedConfig)

            if not success then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Unable to load: " .. tostring(result),
                        Icon = "x-circle",
                        Duration = 3,
                    })
                end)
                return
            end

            pcall(function()
                Avantrix:Notify({
                    Title = "Config Loaded",
                    Content = "Loaded config '" .. selectedConfig .. "'\n\n[IMPORTANT] Library AutoSave disabled to prevent conflicts.",
                    Icon = "folder-check",
                    Duration = 5,
                })
            end)

            -- Mematikan AutoSave library secara otomatis
            if ConfigManager.Window then
                if ConfigManager.Window.SetAutoSave then
                    ConfigManager.Window:SetAutoSave(false)
                else
                    ConfigManager.Window.AutoSave = false
                end
                
                -- Update toggle visual jika ada
                if libraryAutoSaveToggle then
                    libraryAutoSaveToggle:Set(false)
                end
            end
        end,
    })

    tab:Button({
        Title = "Overwrite Config",
        Desc = "Save current settings to selected config",
        Icon = "save",
        Callback = function()
            if not selectedConfig then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Please select a config to overwrite",
                        Icon = "info",
                        Duration = 3,
                    })
                end)
                return
            end

            local success, err = ConfigManager:SaveConfig(selectedConfig)

            if not success then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Unable to overwrite: " .. tostring(err),
                        Icon = "x-circle",
                        Duration = 3,
                    })
                end)
                return
            end

            pcall(function()
                Avantrix:Notify({
                    Title = "Config Saved",
                    Content = "Overwrote config '" .. selectedConfig .. "'\n\n[IMPORTANT] Library AutoSave disabled.",
                    Icon = "save",
                    Duration = 5,
                })
            end)

            -- Mematikan AutoSave library secara otomatis
            if ConfigManager.Window then
                if ConfigManager.Window.SetAutoSave then
                    ConfigManager.Window:SetAutoSave(false)
                else
                    ConfigManager.Window.AutoSave = false
                end
                
                -- Update toggle visual jika ada
                if libraryAutoSaveToggle then
                    libraryAutoSaveToggle:Set(false)
                end
            end
        end,
    })

    tab:Button({
        Title = "Delete Config",
        Desc = "Delete selected config file",
        Icon = "trash-2",
        Callback = function()
            if not selectedConfig then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Please select a config to delete",
                        Icon = "info",
                        Duration = 3,
                    })
                end)
                return
            end

            local success, err = ConfigManager:DeleteConfig(selectedConfig)

            if not success then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Unable to delete: " .. tostring(err),
                        Icon = "circle-x",
                        Duration = 3,
                    })
                end)
                return
            end

            pcall(function()
                Avantrix:Notify({
                    Title = "Config Deleted",
                    Content = "Deleted config '" .. selectedConfig .. "'",
                    Icon = "trash",
                    Duration = 3,
                })
            end)

            configSelection:Refresh(ConfigManager:AllConfigs())
            selectedConfig = nil
        end,
    })

    tab:Button({
        Title = "Refresh Config List",
        Desc = "Refresh the dropdown list",
        Icon = "refresh-cw",
        Callback = function()
            local configs = ConfigManager:AllConfigs()
            configSelection:Refresh(configs)

            pcall(function()
                Avantrix:Notify({
                    Title = "Refreshed",
                    Content = "Config list updated (" .. #configs .. " configs found)",
                    Icon = "refresh-cw",
                    Duration = 2,
                })
            end)
        end,
    })

    tab:Section({ Title = "Auto Load", Icon = "zap" })

    local autoloadLabel = tab:Paragraph({
        Title = "Auto Load Status",
        Desc = "Current: None",
    })

    local function getAutoloadConfigName()
        local data = AutoloadConfig:Get("autoload_config", "None")
        return data
    end

    local function updateAutoloadLabel()
        local configName = getAutoloadConfigName()
        autoloadLabel:SetDesc("Current: " .. configName)
    end

    task.spawn(function()
        task.wait(0.5)
        AutoloadConfig:Load()
        updateAutoloadLabel()
    end)

    tab:Button({
        Title = "Set as Autoload",
        Desc = "Auto load this config on startup",
        Icon = "zap",
        Callback = function()
            if not selectedConfig then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Please select a config first",
                        Icon = "info",
                        Duration = 3,
                    })
                end)
                return
            end

            AutoloadConfig:Set("autoload_config", selectedConfig)
            local success = AutoloadConfig:Save()

            if not success then
                pcall(function()
                    Avantrix:Notify({
                        Title = "Error",
                        Content = "Failed to save autoload settings",
                        Icon = "alert-triangle",
                        Duration = 3,
                    })
                end)
                return
            end

            updateAutoloadLabel()

            pcall(function()
                Avantrix:Notify({
                    Title = "Auto Load Set",
                    Content = "Config '" .. selectedConfig .. "' will auto load on startup",
                    Icon = "zap",
                    Duration = 3,
                })
            end)
        end,
    })

    tab:Button({
        Title = "Clear Autoload",
        Desc = "Disable auto load",
        Icon = "x-circle",
        Callback = function()
            AutoloadConfig:Set("autoload_config", "None")
            AutoloadConfig:Save()
            updateAutoloadLabel()

            pcall(function()
                Avantrix:Notify({
                    Title = "Auto Load Cleared",
                    Content = "Auto load has been disabled",
                    Icon = "zap-off",
                    Duration = 3,
                })
            end)
        end,
    })

    -- Integration: Library Settings
    if ConfigManager.Window then
        tab:Section({
            Title = "Library Settings",
        })

        libraryAutoSaveToggle = tab:Toggle({
            Title = "Library AutoSave",
            Desc = "Automatically save to " .. (ConfigManager.Window.FileSaveName or "config.json"),
            Default = ConfigManager.Window.AutoSave,
            Callback = function(state)
                if ConfigManager.Window.SetAutoSave then
                    ConfigManager.Window:SetAutoSave(state)
                else
                    ConfigManager.Window.AutoSave = state
                end
                
                task.wait(0.5)
                local AutoloadConfig = ConfigManager:CreateConfig("_autoload_settings")
                AutoloadConfig.AutoRegisterEnabled = false -- JANGAN simpan tombol UI ke sini!
                AutoloadConfig:Set("library_autosave", state)
                AutoloadConfig:Save()
            end
        })
    end

    task.spawn(function()
        task.wait(3)

        AutoloadConfig:Load()
        local autoloadConfigName = getAutoloadConfigName()

        if autoloadConfigName == "None" or not autoloadConfigName then 
            return 
        end

        if not ConfigManager:ConfigExists(autoloadConfigName) then
            pcall(function()
                Avantrix:Notify({
                    Title = "Auto Load Failed",
                    Content = "Config '" .. autoloadConfigName .. "' not found",
                    Icon = "alert-circle",
                    Duration = 4,
                })
            end)
            return
        end

        local success, result = ConfigManager:LoadConfig(autoloadConfigName)

        if success then
            pcall(function()
                Avantrix:Notify({
                    Title = "Auto Loaded",
                    Content = "Config '" .. autoloadConfigName .. "' loaded successfully",
                    Icon = "zap",
                    Duration = 3,
                })
            end)
        else
            pcall(function()
                Avantrix:Notify({
                    Title = "Auto Load Failed",
                    Content = "Error: " .. tostring(result),
                    Icon = "alert-triangle",
                    Duration = 4,
                })
            end)
        end
    end)
end

return ConfigManager
