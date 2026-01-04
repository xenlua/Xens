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
                    
                    -- Set nilai internal dulu
                    element.Default = color
                    element.Value = color
                    element.Transparency = transparency
                    
                    -- Update visual
                    if element.Update then
                        element:Update(color, transparency)
                    end
                    
                    -- Trigger callback setelah semua ter-set
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
                
                -- Pastikan multi-select array tersimpan dengan benar
                if obj.Multi and type(value) == "table" then
                    -- Jika array kosong, tetap simpan sebagai array
                    value = value
                elseif obj.Multi and value == nil then
                    value = {}
                end
                
                return {
                    __type = obj.__type,
                    value = value,
                    multi = obj.Multi or false,
                }
            end,
            Load = function(element, data)
                if element then
                    local value = data.value
                    local isMulti = data.multi or false
                    
                    -- Handle multi-select dropdown
                    if isMulti then
                        -- Pastikan value adalah table/array
                        if type(value) ~= "table" then
                            value = {}
                        end
                        
                        -- Set nilai internal untuk multi-select
                        element.Value = value
                        element.Multi = true
                        
                        -- Method 1: Gunakan SetValue jika ada (beberapa library punya ini)
                        if element.SetValue then
                            task.spawn(function()
                                element:SetValue(value)
                            end)
                        -- Method 2: Clear dulu lalu select satu per satu
                        elseif element.Clear and element.Select then
                            task.spawn(function()
                                element:Clear()
                                task.wait(0.05)
                                
                                for _, item in ipairs(value) do
                                    element:Select(item)
                                    task.wait(0.03)
                                end
                            end)
                        -- Method 3: Langsung select tanpa clear (fallback)
                        elseif element.Select then
                            task.spawn(function()
                                for _, item in ipairs(value) do
                                    element:Select(item)
                                    task.wait(0.03)
                                end
                            end)
                        -- Method 4: Set langsung ke property (last resort)
                        else
                            element.Value = value
                        end
                        
                        -- Trigger callback untuk multi-select
                        task.spawn(function()
                            task.wait(0.35)
                            if element.Callback then
                                element.Callback(value)
                            end
                        end)
                    else
                        -- Handle single-select dropdown
                        element.Value = value
                        
                        -- Update visual selection
                        if element.SetValue then
                            task.spawn(function()
                                element:SetValue(value)
                            end)
                        elseif element.Select and value then
                            task.spawn(function()
                                element:Select(value)
                            end)
                        end
                        
                        -- Trigger callback untuk single-select
                        task.spawn(function()
                            task.wait(0.2)
                            if element.Callback then
                                element.Callback(value)
                            end
                        end)
                    end
                end
            end
        },
        Input = {
            Save = function(obj)
                return {
                    __type = obj.__type,
                    value = tostring(obj.Value or ""),
                }
            end,
            Load = function(element, data)
                if element then
                    local value = data.value or ""
                    
                    -- Set nilai internal
                    element.Value = value
                    
                    -- Update visual input
                    if element.Set then
                        element:Set(value)
                    end
                    
                    -- Trigger callback
                    task.spawn(function()
                        task.wait(0.1)
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
                    
                    -- Convert string to Enum jika perlu
                    if type(value) == "string" and value ~= "None" and Enum.KeyCode[value] then
                        value = Enum.KeyCode[value]
                    end
                    
                    -- Set nilai internal
                    element.Value = value
                    
                    -- Update visual keybind
                    if element.Set then
                        element:Set(value)
                    end
                    
                    -- Trigger callback
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
                    
                    -- Set nilai internal dulu
                    element.Value = value
                    
                    -- Update visual slider
                    if element.Set then
                        element:Set(value)
                    end
                    
                    -- Trigger callback dengan nilai yang benar
                    task.spawn(function()
                        task.wait(0.15)
                        if element.Callback then
                            element.Callback(value)
                        end
                    end)
                end
            end
        },
        Toggle = {
            Save = function(obj)
                return {
                    __type = obj.__type,
                    value = obj.Value == true,
                }
            end,
            Load = function(element, data)
                if element then
                    local targetValue = data.value == true
                    
                    -- Set nilai internal langsung tanpa trigger callback dari Set()
                    element.Value = targetValue
                    
                    -- Update visual state tanpa trigger callback
                    if element.Set then
                        -- Beberapa library Set() method trigger callback, kita bypass dengan set Value dulu
                        element:Set(targetValue)
                    end
                    
                    -- Sekarang trigger callback manual dengan nilai yang sudah pasti
                    task.spawn(function()
                        task.wait(0.15)
                        if element.Callback then
                            element.Callback(targetValue)
                        end
                    end)
                end
            end
        },
        Section = {
            Save = function(obj)
                return {
                    __type = obj.__type,
                    opened = obj.Opened == true,
                }
            end,
            Load = function(element, data)
                if element then
                    -- Set state internal
                    element.Opened = data.opened == true
                    
                    -- Update visual section
                    task.spawn(function()
                        task.wait(0.1)
                        if data.opened and element.Open then
                            element:Open()
                        elseif not data.opened and element.Close then
                            element:Close()
                        end
                    end)
                end
            end
        },
    }
}

function ConfigManager:Init(WindowTable)
    if not WindowTable.Folder then
        warn("[ ConfigManager ] Window.Folder is not specified.")
        return false
    end
    
    ConfigManager.Folder = WindowTable.Folder
    ConfigManager.Path = "Avantrix/" .. tostring(ConfigManager.Folder) .. "/configs/"
    ConfigManager.Window = WindowTable
    
    -- Create folders if not exist
    if not isfolder("Avantrix") then
        makefolder("Avantrix")
    end
    if not isfolder("Avantrix/" .. ConfigManager.Folder) then
        makefolder("Avantrix/" .. ConfigManager.Folder)
    end
    if not isfolder(ConfigManager.Path) then
        makefolder(ConfigManager.Path)
    end
    
    return ConfigManager
end

function ConfigManager:CreateConfig(configFilename)
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
            warn("[ ConfigManager ] Window is not set")
            return 0
        end
        
        ConfigModule.Elements = {}
        local count = 0
        
        -- Scan semua elemen dari Window.AllElements
        if ConfigManager.Window.AllElements then
            for i, element in ipairs(ConfigManager.Window.AllElements) do
                if element and element.__type and ConfigManager.Parser[element.__type] then
                    -- Skip elemen yang ada di ExcludedTitles
                    if element.Title and not ConfigManager.ExcludedTitles[element.Title] then
                        local elementName = element.Title or ("Element_" .. i)
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
            warn("[ ConfigManager ] Invalid Register parameters")
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
            warn("[ ConfigManager ] Invalid key for Set")
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
        -- Auto register jika enabled
        if ConfigModule.AutoRegisterEnabled then
            local count = ConfigModule:AutoRegisterElements()
            print("[ ConfigManager ] Auto-registered " .. count .. " elements")
        end
        
        local saveData = {
            __version = ConfigModule.Version,
            __elements = {},
            __custom = ConfigModule.CustomData
        }
        
        -- Save semua element
        for name, element in pairs(ConfigModule.Elements) do
            if element.__type and ConfigManager.Parser[element.__type] then
                local success, data = pcall(function()
                    return ConfigManager.Parser[element.__type].Save(element)
                end)
                
                if success and data then
                    saveData.__elements[tostring(name)] = data
                else
                    warn("[ ConfigManager ] Failed to save element: " .. tostring(name))
                end
            end
        end
        
        -- Encode to JSON
        local success, jsonData = pcall(function()
            return HttpService:JSONEncode(saveData)
        end)
        
        if success and writefile then
            writefile(ConfigModule.Path, jsonData)
            print("[ ConfigManager ] Config saved: " .. ConfigModule.Path)
            return true
        else
            warn("[ ConfigManager ] Failed to save config file")
            return false
        end
    end
    
    function ConfigModule:Load()
        if not isfile(ConfigModule.Path) then
            return false, "Config file does not exist"
        end
        
        -- Read and decode JSON
        local success, loadData = pcall(function()
            local fileContent = readfile(ConfigModule.Path)
            return HttpService:JSONDecode(fileContent)
        end)
        
        if not success then
            warn("[ ConfigManager ] Failed to parse config file")
            return false, "Failed to parse config"
        end
        
        -- Auto register jika enabled
        if ConfigModule.AutoRegisterEnabled then
            local count = ConfigModule:AutoRegisterElements()
            print("[ ConfigManager ] Auto-registered " .. count .. " elements for loading")
        end
        
        -- Load semua elements dengan delay untuk stabilitas
        local loadedCount = 0
        local failedElements = {}
        
        for name, data in pairs(loadData.__elements or {}) do
            if ConfigModule.Elements[name] and data.__type and ConfigManager.Parser[data.__type] then
                local success, err = pcall(function()
                    -- Debug log untuk dropdown multi-select
                    if data.__type == "Dropdown" and data.multi then
                        print("[ ConfigManager ] Loading Multi-Dropdown: " .. name .. " with " .. (type(data.value) == "table" and #data.value or 0) .. " items")
                    end
                    
                    ConfigManager.Parser[data.__type].Load(ConfigModule.Elements[name], data)
                end)
                
                if success then
                    loadedCount = loadedCount + 1
                else
                    table.insert(failedElements, name)
                    warn("[ ConfigManager ] Failed to load element: " .. tostring(name) .. " - " .. tostring(err))
                end
            else
                if not ConfigModule.Elements[name] then
                    warn("[ ConfigManager ] Element not found: " .. tostring(name))
                elseif not data.__type then
                    warn("[ ConfigManager ] Missing __type for: " .. tostring(name))
                end
            end
        end
        
        -- Load custom data
        ConfigModule.CustomData = loadData.__custom or {}
        
        print("[ ConfigManager ] Config loaded: " .. loadedCount .. " elements" .. (#failedElements > 0 and " (" .. #failedElements .. " failed)" or ""))
        return true, ConfigModule.CustomData
    end
    
    -- Simpan config module ke cache
    ConfigManager.Configs[configFilename] = ConfigModule
    return ConfigModule
end

function ConfigManager:AllConfigs()
    if not listfiles then 
        warn("[ ConfigManager ] listfiles is not available")
        return {} 
    end

    local files = {}
    
    if not isfolder(ConfigManager.Path) then
        warn("[ ConfigManager ] Config path does not exist")
        return files
    end

    local success, fileList = pcall(function()
        return listfiles(ConfigManager.Path)
    end)
    
    if not success then
        warn("[ ConfigManager ] Failed to list files")
        return files
    end

    for _, file in pairs(fileList) do
        local name = file:match("([^\\/]+)%.json$")
        if name then
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

    -- Remove from cache
    if ConfigManager.Configs[configName] then
        ConfigManager.Configs[configName] = nil
    end

    print("[ ConfigManager ] Config deleted: " .. configName)
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

function ConfigManager:DebugElement(elementName)
    if not ConfigManager.Window or not ConfigManager.Window.AllElements then
        warn("[ ConfigManager ] Window or AllElements not available")
        return
    end
    
    print("[ ConfigManager ] Debugging element: " .. elementName)
    
    for i, element in ipairs(ConfigManager.Window.AllElements) do
        if element.Title == elementName then
            print("  Found at index: " .. i)
            print("  Type: " .. tostring(element.__type))
            print("  Value: " .. tostring(element.Value))
            print("  Multi: " .. tostring(element.Multi))
            
            if type(element.Value) == "table" then
                print("  Value is table with " .. #element.Value .. " items:")
                for j, v in ipairs(element.Value) do
                    print("    [" .. j .. "] = " .. tostring(v))
                end
            end
            
            print("  Available methods:")
            for method, _ in pairs(element) do
                if type(element[method]) == "function" then
                    print("    - " .. method .. "()")
                end
            end
            
            return element
        end
    end
    
    warn("  Element not found!")
    return nil
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

function ConfigManager:SetupConfigUI(tab, WindUI)
    local inputPath = nil
    local selectedConfig = nil
    local AutoloadConfigName = "_autoload_settings"
    local AutoloadConfig = ConfigManager:CreateConfig(AutoloadConfigName)

    -- Configuration Section
    tab:Section({ Title = "Configuration", Icon = "settings" })

    local configNameInput = tab:Input({
        Title = "Config Name",
        PlaceholderText = "Enter config name",
        Callback = function(text)
            inputPath = text
        end,
    })

    local configSelection = tab:Dropdown({
        Title = "Select Config",
        Multi = false,
        AllowNone = true,
        Values = ConfigManager:AllConfigs(),
        Callback = function(value)
            selectedConfig = value
        end,
    })

    -- Create Config Button
    tab:Button({
        Title = "Create Config",
        Desc = "Save current settings as new config",
        Icon = "save",
        Callback = function()
            if not inputPath or inputPath:gsub(" ", "") == "" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Config name cannot be empty",
                    Duration = 3,
                })
                return
            end

            local success, err = ConfigManager:SaveConfig(inputPath)

            if not success then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Unable to save: " .. tostring(err),
                    Duration = 3,
                })
                return
            end

            WindUI:Notify({
                Title = "Config Saved",
                Content = "Created config '" .. inputPath .. "'",
                Duration = 3,
            })

            configSelection:Refresh(ConfigManager:AllConfigs())
            configNameInput:Set("")
            inputPath = nil
        end,
    })

    -- Load Config Button
    tab:Button({
        Title = "Load Config",
        Desc = "Load selected configuration",
        Icon = "folder-open",
        Callback = function()
            if not selectedConfig then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config to load",
                    Duration = 3,
                })
                return
            end

            local success, result = ConfigManager:LoadConfig(selectedConfig)

            if not success then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Unable to load: " .. tostring(result),
                    Duration = 3,
                })
                return
            end

            WindUI:Notify({
                Title = "Config Loaded",
                Content = "Loaded config '" .. selectedConfig .. "'",
                Duration = 3,
            })
        end,
    })

    -- Overwrite Config Button
    tab:Button({
        Title = "Overwrite Config",
        Desc = "Save current settings to selected config",
        Icon = "save",
        Callback = function()
            if not selectedConfig then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config to overwrite",
                    Duration = 3,
                })
                return
            end

            local success, err = ConfigManager:SaveConfig(selectedConfig)

            if not success then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Unable to overwrite: " .. tostring(err),
                    Duration = 3,
                })
                return
            end

            WindUI:Notify({
                Title = "Config Saved",
                Content = "Overwrote config '" .. selectedConfig .. "'",
                Duration = 3,
            })
        end,
    })

    -- Delete Config Button
    tab:Button({
        Title = "Delete Config",
        Desc = "Delete selected config file",
        Icon = "trash-2",
        Callback = function()
            if not selectedConfig then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config to delete",
                    Duration = 3,
                })
                return
            end

            local success, err = ConfigManager:DeleteConfig(selectedConfig)

            if not success then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Unable to delete: " .. tostring(err),
                    Duration = 3,
                })
                return
            end

            WindUI:Notify({
                Title = "Config Deleted",
                Content = "Deleted config '" .. selectedConfig .. "'",
                Duration = 3,
            })

            configSelection:Refresh(ConfigManager:AllConfigs())
            selectedConfig = nil
        end,
    })

    -- Refresh Config List Button
    tab:Button({
        Title = "Refresh Config List",
        Desc = "Refresh the dropdown list",
        Icon = "refresh-cw",
        Callback = function()
            local configs = ConfigManager:AllConfigs()
            configSelection:Refresh(configs)

            WindUI:Notify({
                Title = "Refreshed",
                Content = "Config list updated (" .. #configs .. " configs found)",
                Duration = 2,
            })
        end,
    })

    -- Auto Load Section
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

    -- Update label saat pertama kali
    task.spawn(function()
        task.wait(0.5)
        AutoloadConfig:Load()
        updateAutoloadLabel()
    end)

    -- Set as Autoload Button
    tab:Button({
        Title = "Set as Autoload",
        Desc = "Auto load this config on startup",
        Icon = "zap",
        Callback = function()
            if not selectedConfig then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config first",
                    Duration = 3,
                })
                return
            end

            AutoloadConfig:Set("autoload_config", selectedConfig)
            local success = AutoloadConfig:Save()

            if not success then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Failed to save autoload settings",
                    Duration = 3,
                })
                return
            end

            updateAutoloadLabel()

            WindUI:Notify({
                Title = "Auto Load Set",
                Content = "Config '" .. selectedConfig .. "' will auto load on startup",
                Duration = 3,
            })
        end,
    })

    -- Clear Autoload Button
    tab:Button({
        Title = "Clear Autoload",
        Desc = "Disable auto loading",
        Icon = "x-circle",
        Callback = function()
            AutoloadConfig:Set("autoload_config", "None")
            AutoloadConfig:Save()
            updateAutoloadLabel()

            WindUI:Notify({
                Title = "Auto Load Cleared",
                Content = "Auto load has been disabled",
                Duration = 3,
            })
        end,
    })

    -- Auto Load Logic
    task.spawn(function()
        task.wait(3)

        AutoloadConfig:Load()
        local autoloadConfigName = getAutoloadConfigName()

        if autoloadConfigName == "None" or not autoloadConfigName then 
            print("[ ConfigManager ] No autoload config set")
            return 
        end

        if not ConfigManager:ConfigExists(autoloadConfigName) then
            WindUI:Notify({
                Title = "Auto Load Failed",
                Content = "Config '" .. autoloadConfigName .. "' not found",
                Duration = 4,
            })
            return
        end

        local success, result = ConfigManager:LoadConfig(autoloadConfigName)

        if success then
            WindUI:Notify({
                Title = "Auto Loaded",
                Content = "Config '" .. autoloadConfigName .. "' loaded successfully",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Auto Load Failed",
                Content = "Error: " .. tostring(result),
                Duration = 4,
            })
        end
    end)
end

return ConfigManager
