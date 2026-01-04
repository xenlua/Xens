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
                local color = obj.Default or Color3.new(1, 1, 1)
                local colorHex

                if typeof(color) == "Color3" then
                    colorHex = "#" .. color:ToHex()
                else
                    colorHex = "#FFFFFF"
                end

                return {
                    __type = obj.__type,
                    value = colorHex,
                    transparency = obj.Transparency or nil,
                }
            end,
            Load = function(element, data)
                if element and element.Update then
                    local color = Color3.fromHex(data.value)
                    element:Update(color, data.transparency or nil)

                    -- Call callback immediately without delay
                    if element.Callback then
                        task.spawn(function()
                            element.Callback(color, data.transparency)
                        end)
                    end
                end
            end
        },
        Dropdown = {
            Save = function(obj)
                return {
                    __type = obj.__type,
                    value = obj.Value,
                    multi = obj.Multi or false,
                }
            end,
            Load = function(element, data)
                if element and element.Select then
                    local value = data.value

                    task.spawn(function()
                        element:Select(value)

                        -- Call callback immediately after select
                        if element.Callback then
                            task.wait(0.01) -- Minimal wait untuk ensure Select selesai
                            element.Callback(value)
                        end
                    end)
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
                if element and element.Set then
                    element:Set(data.value or "")

                    -- Call callback immediately
                    if element.Callback then
                        task.spawn(function()
                            element.Callback(data.value)
                        end)
                    end
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
                if element and element.Set then
                    local value = data.value

                    if type(value) == "string" and Enum.KeyCode[value] then
                        value = Enum.KeyCode[value]
                    end

                    element:Set(value)

                    -- Call callback immediately
                    if element.Callback then
                        task.spawn(function()
                            element.Callback(value)
                        end)
                    end
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
                if element and element.Set then
                    element:Set(data.value or 0)

                    -- Call callback immediately
                    if element.Callback then
                        task.spawn(function()
                            element.Callback(data.value)
                        end)
                    end
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
                if element and element.Set then
                    local targetValue = data.value == true

                    task.spawn(function()
                        -- Force state change: set to opposite first, then to target
                        -- This ensures callback always executes
                        element:Set(not targetValue)
                        task.wait(0.01)
                        element:Set(targetValue)

                        -- Also manually call callback to ensure execution
                        task.wait(0.01)
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
                    task.spawn(function()
                        task.wait(0.02) -- Minimal wait
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
        Version = 1.3,
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
        ConfigModule.Elements[Name] = Element
    end
    
    function ConfigModule:Set(key, value)
        ConfigModule.CustomData[key] = value
    end
    
    function ConfigModule:Get(key)
        return ConfigModule.CustomData[key]
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
                
                if success then
                    saveData.__elements[tostring(name)] = data
                else
                    warn("[ ConfigManager ] Failed to save " .. name)
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
            return HttpService:JSONDecode(readfile(ConfigModule.Path))
        end)
        
        if not success then
            return false, "Failed to parse config"
        end
        
        if ConfigModule.AutoRegisterEnabled then
            ConfigModule:AutoRegisterElements()
        end
        
        for name, data in pairs(loadData.__elements or {}) do
            if ConfigModule.Elements[name] and ConfigManager.Parser[data.__type] then
                pcall(function()
                    ConfigManager.Parser[data.__type].Load(ConfigModule.Elements[name], data)
                end)
            end
        end
        
        ConfigModule.CustomData = loadData.__custom or {}
        return ConfigModule.CustomData
    end
    
    ConfigManager.Configs[configFilename] = ConfigModule
    return ConfigModule
end

function ConfigManager:AllConfigs()
    if not listfiles then return {} end

    local files = {}
    if not isfolder(ConfigManager.Path) then
        return files
    end

    for _, file in pairs(listfiles(ConfigManager.Path)) do
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
    ConfigManager.ExcludedTitles[title] = true
end

function ConfigManager:RemoveExcludedTitle(title)
    ConfigManager.ExcludedTitles[title] = nil
end

function ConfigManager:SaveConfig(configName)
    if not configName or configName == "" then
        return false, "Config name is empty"
    end

    local success, err = pcall(function()
        local configFile = ConfigManager:CreateConfig(configName)
        configFile:Save()
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
        return configFile:Load()
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

    tab:Section({ Title = "Auto Load", Icon = "zap" })

    local autoloadLabel = tab:Paragraph({
        Title = "Auto Load Status",
        Desc = "Current: None",
    })

    local function getAutoloadConfigName()
        local data = AutoloadConfig:Get("autoload_config")
        return data or "None"
    end

    local function updateAutoloadLabel()
        local configName = getAutoloadConfigName()
        autoloadLabel:SetDesc("Current: " .. configName)
    end

    updateAutoloadLabel()

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
            AutoloadConfig:Save()

            updateAutoloadLabel()

            WindUI:Notify({
                Title = "Auto Load Set",
                Content = "Config '" .. selectedConfig .. "' will auto load on startup",
                Duration = 3,
            })
        end,
    })

    task.spawn(function()
        task.wait(2.5)

        AutoloadConfig:Load()
        local autoloadConfigName = getAutoloadConfigName()

        if autoloadConfigName == "None" then return end

        if not ConfigManager:ConfigExists(autoloadConfigName) then
            WindUI:Notify({
                Title = "Auto Load Failed",
                Content = "Config '" .. autoloadConfigName .. "' not found",
                Duration = 3,
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
                Duration = 3,
            })
        end
    end)
end

return ConfigManager
