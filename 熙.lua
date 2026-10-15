local __XixiRoot = (type(getgenv) == "function" and getgenv()) or _G
local function __XixiTrimUrl(url)
    if type(url) ~= "string" then return nil end
    return (url:gsub("^%s+", ""):gsub("%s+$", ""))
end
local __XixiAllowedHosts = {
    ["raw.githubusercontent.com"] = true,
    ["github.com"] = true,
    ["raw.github.com"] = true,
    ["gist.githubusercontent.com"] = true,
    ["pastefy.app"] = true,
    ["pastebin.com"] = true,
    ["gitee.com"] = true,
    ["raw.gitcode.com"] = true,
    ["api.luarmor.net"] = true,
    ["files.catbox.moe"] = true,
    ["rawscripts.net"] = true,
    ["gitlab.com"] = true,
    ["rentry.co"] = true,
    ["glot.io"] = true,
    ["api.jnkie.com"] = true,
    ["api.junkie-development.de"] = true,
    ["latlat.lat"] = true,
    ["pandadevelopment.net"] = true,
    ["scriptblox.com"] = true,
    ["shz.al"] = true,
    ["api.jsonbin.io"] = true,
    ["paste.ubuntu.com"] = true,
    ["wearedevs.net"] = true,
    ["api.mymemory.translated.net"] = true,
    ["translate.googleapis.com"] = true,
    ["openapi.youdao.com"] = true,
    ["api.deepseek.com"] = true,
    ["api.siliconflow.cn"] = true,
    ["music.163.com"] = true,
    ["clients5.google.com"] = true,
    ["games.roblox.com"] = true,
    ["roblox.com"] = true,
    ["www.roblox.com"] = true,
    ["discord.com"] = true,
    ["docs.google.com"] = true,
    ["qun.qq.com"] = true
}
local function __XixiValidateUrl(url)
    url = __XixiTrimUrl(url)
    if not url or url == "" then return nil, "URL为空" end
    if url:find("[%c%s]") then return nil, "URL包含空白或控制字符" end
    if url:find("\\", 1, true) then return nil, "URL包含非法反斜杠" end
    local host = url:match("^https://([^/%?#]+)")
    if not host then return nil, "仅允许HTTPS远程地址" end
    host = host:lower()
    if host:find("@", 1, true) or host:find(":", 1, true) then return nil, "URL主机格式非法" end
    if not __XixiAllowedHosts[host] then return nil, "远程域名不在允许列表中: " .. host end
    return url
end
local function __XixiRemoteFetch(url, cacheFlag)
    local cleanUrl, validationError = __XixiValidateUrl(url)
    if not cleanUrl then error("熙熙远程请求被拦截：" .. tostring(validationError), 2) end
    local errors = {}
    local env = __XixiRoot
    local requestFn = (type(request) == "function" and request)
        or (type(http_request) == "function" and http_request)
        or (type(env.request) == "function" and env.request)
        or (type(env.http_request) == "function" and env.http_request)
        or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
        or (type(http) == "table" and type(http.request) == "function" and http.request)
        or (type(fluxus) == "table" and type(fluxus.request) == "function" and fluxus.request)
    local function waitRetry(delay)
        if type(task) == "table" and type(task.wait) == "function" then pcall(task.wait, delay) end
    end
    for attempt = 1, 3 do
        if type(game) == "userdata" or type(game) == "table" then
            local ok, body = pcall(function()
                if cacheFlag ~= nil then return game:HttpGet(cleanUrl, cacheFlag) end
                return game:HttpGet(cleanUrl)
            end)
            if ok and type(body) == "string" and #body > 0 then
                if body:match("^%s*<!DOCTYPE%s+html") or body:match("^%s*<html[%s>]" ) then
                    table.insert(errors, "HttpGet返回网页而非脚本")
                else
                    return body
                end
            else
                table.insert(errors, "HttpGet第" .. attempt .. "次: " .. tostring(body or "空响应"))
            end
        end
        if requestFn then
            local ok, response = pcall(function()
                return requestFn({Url = cleanUrl, URL = cleanUrl, Method = "GET", method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0", ["Accept"] = "text/plain, */*" }, headers = { ["User-Agent"] = "Mozilla/5.0", ["Accept"] = "text/plain, */*" }})
            end)
            if ok and type(response) == "table" then
                local status = tonumber(response.StatusCode or response.Status or response.status_code or response.status)
                local body = response.Body or response.body or response.ResponseBody
                if type(body) == "string" and #body > 0 and ((not status) or (status >= 200 and status < 300)) then
                    if body:match("^%s*<!DOCTYPE%s+html") or body:match("^%s*<html[%s>]") then
                        table.insert(errors, "request返回网页而非脚本")
                    else
                        return body
                    end
                else
                    table.insert(errors, "request第" .. attempt .. "次HTTP状态=" .. tostring(status) .. "，响应为空或非2xx")
                end
            else
                table.insert(errors, "request第" .. attempt .. "次: " .. tostring(response or "请求失败"))
            end
        else
            table.insert(errors, "当前加载器未提供可用request接口")
        end
        if attempt < 3 then waitRetry(attempt * 0.75) end
    end
    error("熙熙远程请求失败：" .. cleanUrl .. " | " .. table.concat(errors, " | ") .. " | 请检查网络/DNS/加载器HTTP权限；本脚本不强制要求加速器", 2)
end
if __XixiRoot.__XixiMegaBundleRunning then
    warn("熙熙独立融合脚本已在运行")
    return
end
__XixiRoot.__XixiMegaBundleRunning = true
local __XixiBundleTasks = {}
__XixiBundleTasks[1] = task.spawn(function()
    local __ok, __err = pcall(function()
local _genv = (type(getgenv) == "function" and getgenv()) or _G
if _genv.__XixiRuntime and type(_genv.__XixiRuntime.Cleanup) == "function" then
    pcall(_genv.__XixiRuntime.Cleanup)
end
local XixiRuntime = {Alive = true, Connections = {}, Instances = {}}
_genv.__XixiRuntime = XixiRuntime

local function XixiTrackConnection(conn)
    if conn and type(conn.Disconnect) == "function" then
        table.insert(XixiRuntime.Connections, conn)
    end
    return conn
end

local function XixiTrackInstance(obj)
    if obj and typeof(obj) == "Instance" then
        table.insert(XixiRuntime.Instances, obj)
    end
    return obj
end

function XixiRuntime.Cleanup()
    if not XixiRuntime.Alive then return end
    XixiRuntime.Alive = false
    for i = #XixiRuntime.Connections, 1, -1 do
        pcall(function() XixiRuntime.Connections[i]:Disconnect() end)
        XixiRuntime.Connections[i] = nil
    end
    for i = #XixiRuntime.Instances, 1, -1 do
        pcall(function() XixiRuntime.Instances[i]:Destroy() end)
        XixiRuntime.Instances[i] = nil
    end
end

local function XixiHttpGet(url)
    if type(url) ~= "string" or url == "" then return nil, "URL为空" end
    local ok, body = pcall(function() return __XixiRemoteFetch(url) end)
    if ok and type(body) == "string" and #body > 0 then return body end
    return nil, tostring(body or "远程请求失败")
end

local function XixiLoadUI()
    local source, err = XixiHttpGet("https://raw.githubusercontent.com/hgvuyguyg/new/main/ui")
    if not source then return nil, "LUMEN下载失败: " .. tostring(err) end
    local loader = loadstring or load
    if type(loader) ~= "function" then return nil, "当前环境不支持loadstring/load" end
    local okc, chunk = pcall(loader, source)
    if not okc or type(chunk) ~= "function" then return nil, "LUMEN编译失败: " .. tostring(chunk) end
    local oke, result = pcall(chunk)
    if not oke then return nil, "LUMEN执行失败: " .. tostring(result) end
    local ui = (type(result) == "table" and result) or _G.ui
    if type(ui) ~= "table" then return nil, "LUMEN没有返回有效UI对象" end
    return ui
end

local ui, uiErr = XixiLoadUI()
if not ui then
    warn("[熙熙] " .. tostring(uiErr))
    return
end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local function getGlobalExecCount()
    if getgenv and getgenv().GlobalExecCount then return getgenv().GlobalExecCount end
    local success, result = pcall(function()
        if syn and syn.crypt and syn.crypt.custom then
            local data = syn.crypt.custom("read", "xixi_exec_count.txt")
            if data then return tonumber(data) or 0 end
        end
        return 0
    end)
    if success and result and result > 0 then return result end
    success, result = pcall(function()
        if readfile then
            local data = readfile("xixi_exec_count.txt")
            if data then return tonumber(data) or 0 end
        end
        return 0
    end)
    if success and result and result > 0 then return result end
    return 0
end
local function saveGlobalExecCount(count)
    if getgenv then getgenv().GlobalExecCount = count end
    pcall(function()
        if syn and syn.crypt and syn.crypt.custom then
            syn.crypt.custom("write", "xixi_exec_count.txt", tostring(count))
        end
    end)
    pcall(function()
        if writefile then writefile("xixi_exec_count.txt", tostring(count)) end
    end)
end
local globalExecCount = getGlobalExecCount()
if globalExecCount == 0 then globalExecCount = 1 else globalExecCount = globalExecCount + 1 end
saveGlobalExecCount(globalExecCount)

if globalExecCount == 520 then
    spawn(function()
        local heartGui = Instance.new("ScreenGui")
        heartGui.Name = "HeartEffectGui"; heartGui.ResetOnSpawn = false; heartGui.Parent = PlayerGui
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0); overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5; overlay.ZIndex = 999; overlay.Parent = heartGui
        local heartLabel = Instance.new("TextLabel")
        heartLabel.Size = UDim2.new(0, 200, 0, 200); heartLabel.Position = UDim2.new(0.5, -100, 0.5, -100)
        heartLabel.Text = "❤️"; heartLabel.Font = Enum.Font.GothamBold
        heartLabel.TextSize = 150; heartLabel.BackgroundTransparency = 1
        heartLabel.ZIndex = 1000; heartLabel.Parent = heartGui
        local heartHue = 0
        local heartConn = RunService.RenderStepped:Connect(function(delta)
            heartHue = (heartHue + delta * 0.5) % 1
            heartLabel.TextColor3 = Color3.fromHSV(heartHue, 1, 1)
        end)
        heartLabel.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 200)}):Play()
        wait(3)
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(0, 400, 0, 60); msgLabel.Position = UDim2.new(0.5, -200, 0.5, 120)
        msgLabel.Text = "您已执行 520 次，感谢您的支持！❤️"
        msgLabel.Font = Enum.Font.GothamBold; msgLabel.TextSize = 24
        msgLabel.BackgroundTransparency = 1; msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        msgLabel.TextStrokeTransparency = 0; msgLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        msgLabel.ZIndex = 1000; msgLabel.Parent = heartGui
        local msgHue = 0
        local msgConn = RunService.RenderStepped:Connect(function(delta)
            msgHue = (msgHue + delta * 0.3) % 1
            msgLabel.TextColor3 = Color3.fromHSV(msgHue, 1, 1)
        end)
        wait(2)
        heartConn:Disconnect(); msgConn:Disconnect()
        TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(msgLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        wait(0.5); heartGui:Destroy()
    end)
end

spawn(function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://80701295792893"; sound.Volume = 1
    sound.Parent = workspace; sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end)

spawn(function()
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeGui"; welcomeGui.ResetOnSpawn = false; welcomeGui.Parent = PlayerGui
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(0, 500, 0, 80); welcomeLabel.Position = UDim2.new(0.5, -250, 0.5, -40)
    welcomeLabel.Text = "欢迎使用熙熙·融合版"
    welcomeLabel.Font = Enum.Font.GothamBold; welcomeLabel.TextSize = 36
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.TextStrokeTransparency = 0; welcomeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    welcomeLabel.ZIndex = 1000; welcomeLabel.Parent = welcomeGui
    local hue2 = 0
    local colorConnection
    colorConnection = RunService.RenderStepped:Connect(function(delta)
        hue2 = (hue2 + delta * 0.5) % 1
        welcomeLabel.TextColor3 = Color3.fromHSV(hue2, 1, 1)
    end)
    wait(3)
    colorConnection:Disconnect()
    TweenService:Create(welcomeLabel, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    wait(0.8); welcomeGui:Destroy()
    local infoGui = Instance.new("ScreenGui")
    infoGui.Name = "InfoGui"; infoGui.ResetOnSpawn = false; infoGui.Parent = PlayerGui
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 400, 0, 60); infoLabel.Position = UDim2.new(0.5, -200, 0.5, -30)
    infoLabel.Text = "此脚本会一直更新\n此脚本：熙熙\n作者：大肥鱼"
    infoLabel.Font = Enum.Font.GothamBold; infoLabel.TextSize = 22
    infoLabel.BackgroundTransparency = 1; infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextStrokeTransparency = 0; infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.ZIndex = 1000; infoLabel.Parent = infoGui
    wait(2)
    TweenService:Create(infoLabel, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    wait(0.6); infoGui:Destroy()
end)

local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSGui"; fpsGui.ResetOnSpawn = false; fpsGui.Parent = PlayerGui
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 180, 0, 28); FPSLabel.Position = UDim2.new(0, 8, 0, 8)
FPSLabel.BackgroundTransparency = 1; FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 16; FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.ZIndex = 100; FPSLabel.Visible = true; FPSLabel.RichText = true
FPSLabel.Parent = fpsGui
local fpsEnabled = true
local lastFrameTime = tick()
local frameCount = 0
local currentFPS = 0
RunService.RenderStepped:Connect(function()
    if fpsEnabled then
        frameCount = frameCount + 1
        local e = tick() - lastFrameTime
        if e >= 0.5 then
            currentFPS = math.floor(frameCount / e)
            frameCount = 0; lastFrameTime = tick()
            local c = currentFPS >= 30 and "255,0,0" or "255,255,0"
            FPSLabel.Text = '<font color="rgb(255,255,255)">FPS: </font><font color="rgb(' .. c .. ')">' .. currentFPS .. '</font>'
        end
    end
end)

local espHighlights = {}
local espBillboards = {}
local teamGlowHighlights = {}
local enemyGlowHighlights = {}
local infJumpEnabled = false
local spinConnection = nil
local followConnection = nil
local followActive = false
local homePosition = nil
local authorEspEnabled = true
local _toggleConns = {}

local function clearESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(espBillboards) do pcall(function() b:Destroy() end) end
    espHighlights = {}; espBillboards = {}
end
local function clearTeamGlow()
    for _, h in pairs(teamGlowHighlights) do pcall(function() h:Destroy() end) end
    teamGlowHighlights = {}
end
local function clearEnemyGlow()
    for _, h in pairs(enemyGlowHighlights) do pcall(function() h:Destroy() end) end
    enemyGlowHighlights = {}
end
local function addAuthorESP(p)
    if not authorEspEnabled then return end
    if p.Name ~= "熙熙" then return end
    if espHighlights[p] then pcall(function() espHighlights[p]:Destroy() end) end
    if espBillboards[p] then pcall(function() espBillboards[p]:Destroy() end) end
    local function s(c)
        if not c then return end
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 215, 0); hl.FillTransparency = 0.3
        hl.OutlineColor = Color3.fromRGB(255, 215, 0); hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = c; hl.Parent = c
        espHighlights[p] = hl
        local h = c:FindFirstChild("Head")
        if h then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 200, 0, 40); bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true; bb.Parent = h
            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(1, 0, 1, 0); nl.BackgroundTransparency = 1
            nl.Text = "👑 " .. p.Name .. " · 此脚本作者"
            nl.TextColor3 = Color3.fromRGB(255, 215, 0); nl.Font = Enum.Font.GothamBold
            nl.TextSize = 16; nl.TextStrokeTransparency = 0
            nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = bb
            espBillboards[p] = bb
        end
    end
    if p.Character then s(p.Character) end
    p.CharacterAdded:Connect(function(c) if authorEspEnabled then s(c) end end)
end
local function refreshAuthorESP()
    clearESP()
    if authorEspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do addAuthorESP(p) end
    end
end
local function enableAuthorESP() authorEspEnabled = true; refreshAuthorESP() end
local function disableAuthorESP() authorEspEnabled = false; clearESP() end
for _, p in ipairs(Players:GetPlayers()) do addAuthorESP(p) end
Players.PlayerAdded:Connect(function(p) if authorEspEnabled then addAuthorESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then pcall(function() espHighlights[p]:Destroy() end); espHighlights[p] = nil end
    if espBillboards[p] then pcall(function() espBillboards[p]:Destroy() end); espBillboards[p] = nil end
end)

spawn(function()
    wait(3)
    local c = Players.LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        homePosition = c.HumanoidRootPart.CFrame
    end
end)

local function handleFeatureToggle(runCode, enabled)
    if enabled then
        if runCode == "esp" then enableAuthorESP()
        elseif runCode == "night" then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        elseif runCode == "fps" then fpsEnabled = true; FPSLabel.Visible = true
        elseif runCode == "float" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart; local floatY = hrp.Position.Y
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    if hrp and hrp.Parent then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                        hrp.CFrame = CFrame.new(hrp.Position.X, floatY, hrp.Position.Z)
                    end
                end)
            end
        elseif runCode == "antiafk" then
            local vu = game:GetService("VirtualUser")
            Players.LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        elseif runCode == "collect" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    for _, item in ipairs(workspace:GetDescendants()) do
                        if item:IsA("Tool") or item:IsA("MeshPart") or (item:IsA("Part") and (item.Name:lower():find("drop") or item.Name:lower():find("coin") or item.Name:lower():find("gem") or item.Name:lower():find("collect") or item.Name:lower():find("orb"))) then
                            if (item.Position - hrp.Position).Magnitude < 80 then
                                item.CFrame = hrp.CFrame + Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                            end
                        end
                    end
                end)
            end
        elseif runCode == "clicktp" then
            local mouse = Players.LocalPlayer:GetMouse()
            _toggleConns[runCode] = mouse.Button1Down:Connect(function()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") and mouse.Hit then
                    c.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
                end
            end)
        elseif runCode == "autoclick" then
            local vu = game:GetService("VirtualUser"); local camera = workspace.CurrentCamera
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local s = camera.ViewportSize
                vu:Button1Down(Vector2.new(s.X/2, s.Y/2))
                wait(0.05)
                vu:Button1Up(Vector2.new(s.X/2, s.Y/2))
            end)
        elseif runCode == "speedhack" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Animation") then v.Speed = 2 end
                end
            end)
        elseif runCode == "itemesp" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, item in ipairs(workspace:GetDescendants()) do
                    if (item:IsA("Tool") or item.Name:find("Drop")) and not item:FindFirstChild("ItemESP") then
                        local hl = Instance.new("Highlight"); hl.Name = "ItemESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 255, 0); hl.Parent = item
                    end
                end
            end)
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.8 end
            end end
        elseif runCode == "noclip" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end end
        elseif runCode == "god" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = 99999; c.Humanoid.Health = 99999
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 99999 end
                end)
            end
        elseif runCode == "teamglow" then
            local myTeam = Players.LocalPlayer.Team
            clearTeamGlow()
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Team == myTeam then
                        if not teamGlowHighlights[p] then
                            local hl = Instance.new("Highlight"); hl.Name = "TeamGlow"
                            hl.FillColor = Color3.fromRGB(0, 100, 255); hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                            teamGlowHighlights[p] = hl
                        end
                    end
                end
            end)
        elseif runCode == "enemyglow" then
            local myTeam = Players.LocalPlayer.Team
            clearEnemyGlow()
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Team ~= myTeam then
                        if not enemyGlowHighlights[p] then
                            local hl = Instance.new("Highlight"); hl.Name = "EnemyGlow"
                            hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                            enemyGlowHighlights[p] = hl
                        end
                    end
                end
            end)
        elseif runCode == "autoattack" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character; if not c then return end
                local nearest = nil; local minDist = 15; local myTeam = Players.LocalPlayer.Team
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= myTeam and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - c.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then minDist = dist; nearest = p.Character end
                    end
                end
                if nearest and c:FindFirstChild("HumanoidRootPart") then
                    c.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                    local tool = c:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        firetouchinterest(tool.Handle, nearest, 0); firetouchinterest(tool.Handle, nearest, 1)
                    end
                end
            end)
        elseif runCode == "fulllight" then
            Lighting.Brightness = 5; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        elseif runCode == "suicide" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 0 end
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 1000 end
        elseif runCode == "infstamina" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then c.Humanoid.MaxHealth = c.Humanoid.MaxHealth end
            end)
        elseif runCode == "infammo" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character
                if c then
                    for _, tool in ipairs(c:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
                    end
                end
            end)
        elseif runCode == "serverinfo" then
            local infoActive = true
            local infoGui = Instance.new("ScreenGui")
            infoGui.Name = "ServerInfoGui"; infoGui.ResetOnSpawn = false; infoGui.Parent = PlayerGui
            local infoFrame = Instance.new("Frame")
            infoFrame.Size = UDim2.new(0, 280, 0, 180); infoFrame.Position = UDim2.new(1, -290, 0, 10)
            infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); infoFrame.BackgroundTransparency = 0.2
            infoFrame.BorderSizePixel = 0; infoFrame.ZIndex = 500; infoFrame.Parent = infoGui
            local infoCorner = Instance.new("UICorner"); infoCorner.CornerRadius = UDim.new(0, 8); infoCorner.Parent = infoFrame
            local playerCountLabel = Instance.new("TextLabel")
            playerCountLabel.Size = UDim2.new(1, -16, 0, 30); playerCountLabel.Position = UDim2.new(0, 8, 0, 8)
            playerCountLabel.Text = "服务器人数: " .. #Players:GetPlayers()
            playerCountLabel.Font = Enum.Font.GothamBold; playerCountLabel.TextSize = 14
            playerCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerCountLabel.BackgroundTransparency = 1
            playerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
            playerCountLabel.ZIndex = 501; playerCountLabel.Parent = infoFrame
            local coordLabel = Instance.new("TextLabel")
            coordLabel.Size = UDim2.new(1, -16, 0, 30); coordLabel.Position = UDim2.new(0, 8, 0, 40)
            coordLabel.Font = Enum.Font.Gotham; coordLabel.TextSize = 12
            coordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            coordLabel.BackgroundTransparency = 1
            coordLabel.TextXAlignment = Enum.TextXAlignment.Left
            coordLabel.ZIndex = 501; coordLabel.Parent = infoFrame
            local nearestLabel = Instance.new("TextLabel")
            nearestLabel.Size = UDim2.new(1, -16, 0, 90); nearestLabel.Position = UDim2.new(0, 8, 0, 72)
            nearestLabel.Font = Enum.Font.Gotham; nearestLabel.TextSize = 11
            nearestLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            nearestLabel.BackgroundTransparency = 1
            nearestLabel.TextXAlignment = Enum.TextXAlignment.Left
            nearestLabel.TextYAlignment = Enum.TextYAlignment.Top
            nearestLabel.ZIndex = 501; nearestLabel.Parent = infoFrame
            local renderConn = RunService.RenderStepped:Connect(function()
                if not infoActive then return end
                playerCountLabel.Text = "服务器人数: " .. #Players:GetPlayers()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local pos = c.HumanoidRootPart.Position
                    coordLabel.Text = "坐标: X:" .. math.floor(pos.X) .. " Y:" .. math.floor(pos.Y) .. " Z:" .. math.floor(pos.Z)
                end
                local nearestText = "附近玩家:\n"
                local myPos = c and c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.Position
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and myPos then
                        local dist = math.floor((p.Character.HumanoidRootPart.Position - myPos).Magnitude)
                        nearestText = nearestText .. "  " .. p.Name .. " - " .. dist .. "m\n"
                    end
                end
                nearestLabel.Text = nearestText
            end)
            _toggleConns[runCode] = {Disconnect = function()
                infoActive = false
                if infoGui then infoGui:Destroy() end
                if renderConn then renderConn:Disconnect() end
            end}
        elseif runCode == "dance1" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://5918726674"
                local track = c.Humanoid:LoadAnimation(anim); track:Play()
                _toggleConns[runCode] = {Disconnect = function() if track then track:Stop() end end}
            end
        elseif runCode == "fire" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local fire = Instance.new("ParticleEmitter"); fire.Name = "FireFX"
                fire.Texture = "rbxassetid://0"
                fire.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
                fire.Rate = 30; fire.Speed = NumberRange.new(3, 6)
                fire.Lifetime = NumberRange.new(0.5, 1); fire.Parent = c.HumanoidRootPart
            end
        elseif runCode == "glow" then
            local c = Players.LocalPlayer.Character
            if c then
                local hl = Instance.new("Highlight"); hl.Name = "PlayerGlow"
                hl.FillColor = Color3.fromRGB(255, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency = 0.3; hl.Parent = c
            end
        elseif runCode == "upsidedown" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif runCode == "bighead" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(4, 4, 4) end
        elseif runCode == "screenfx" then
            local fx = Instance.new("ColorCorrectionEffect"); fx.Name = "ScreenFX"
            fx.TintColor = Color3.fromRGB(255, 100, 200); fx.Parent = Lighting
        elseif runCode == "trail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "PlayerTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "TrailAttachment0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "TrailAttachment1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255))
                trail.Lifetime = 0.5; trail.MinLength = 0.1; trail.Parent = hrp
            end
        elseif runCode == "firetrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "FireTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "FireTrailA0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "FireTrailA1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 255, 0))
                trail.Lifetime = 0.3; trail.MinLength = 0.05; trail.Parent = hrp
            end
        elseif runCode == "iceTrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "IceTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "IceTrailA0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "IceTrailA1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(150, 220, 255), Color3.fromRGB(200, 240, 255))
                trail.Lifetime = 0.4; trail.MinLength = 0.08; trail.Parent = hrp
            end
        elseif runCode == "clearfog" then
            Lighting.FogEnd = 100000; Lighting.FogStart = 50000
        elseif runCode == "subtitle" then
            local subActive = true
            local subGui = Instance.new("ScreenGui")
            subGui.Name = "SubtitleGui"; subGui.ResetOnSpawn = false; subGui.Parent = PlayerGui
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(0, 500, 0, 80); subLabel.Position = UDim2.new(0.5, -250, 0, 10)
            subLabel.Text = Players.LocalPlayer.Name .. " 已入侵服务器"
            subLabel.Font = Enum.Font.GothamBold; subLabel.TextSize = 24
            subLabel.BackgroundTransparency = 1
            subLabel.TextStrokeTransparency = 0; subLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            subLabel.ZIndex = 500; subLabel.Parent = subGui
            local serverLabel = Instance.new("TextLabel")
            serverLabel.Size = UDim2.new(0, 500, 0, 40); serverLabel.Position = UDim2.new(0.5, -250, 0, 80)
            serverLabel.Text = "服务器ID: " .. game.JobId
            serverLabel.Font = Enum.Font.Gotham; serverLabel.TextSize = 16
            serverLabel.BackgroundTransparency = 1
            serverLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            serverLabel.TextStrokeTransparency = 0; serverLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            serverLabel.ZIndex = 500; serverLabel.Parent = subGui
            local timeLabel = Instance.new("TextLabel")
            timeLabel.Size = UDim2.new(0, 500, 0, 30); timeLabel.Position = UDim2.new(0.5, -250, 0, 115)
            timeLabel.Font = Enum.Font.Gotham; timeLabel.TextSize = 14
            timeLabel.BackgroundTransparency = 1
            timeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            timeLabel.TextStrokeTransparency = 0; timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            timeLabel.ZIndex = 500; timeLabel.Parent = subGui
            local subHue = 0
            local renderConn = RunService.RenderStepped:Connect(function(delta)
                if not subActive then return end
                subHue = (subHue + delta * 0.3) % 1
                subLabel.TextColor3 = Color3.fromHSV(subHue, 1, 1)
                local now = os.date("*t")
                timeLabel.Text = now.year .. "年" .. now.month .. "月" .. now.day .. "日 " .. string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
            end)
            _toggleConns[runCode] = {Disconnect = function()
                subActive = false
                if subGui then subGui:Destroy() end
                if renderConn then renderConn:Disconnect() end
            end}
        elseif runCode == "rainbowname" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then
                local bb = c.Head:FindFirstChild("BillboardGui")
                if not bb then
                    bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 150, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Parent = c.Head
                    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 1, 0); nl.BackgroundTransparency = 1
                    nl.Text = Players.LocalPlayer.DisplayName .. " 👑管理员"
                    nl.Font = Enum.Font.GothamBold; nl.TextSize = 14; nl.Name = "RainbowName"
                    nl.TextStrokeTransparency = 0; nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = bb
                end
            end
            local hue2 = 0
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function(delta)
                hue2 = (hue2 + delta * 0.5) % 1
                local c2 = Players.LocalPlayer.Character
                if c2 and c2:FindFirstChild("Head") then
                    local bb2 = c2.Head:FindFirstChild("BillboardGui")
                    if bb2 then
                        local nl2 = bb2:FindFirstChild("RainbowName")
                        if nl2 then nl2.TextColor3 = Color3.fromHSV(hue2, 1, 1) end
                    end
                end
            end)
        elseif runCode == "giant" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size * 3 end
            end end
        elseif runCode == "deletepart" then
            local mouse = Players.LocalPlayer:GetMouse(); local curGui = nil; local curHl = nil
            _toggleConns[runCode] = mouse.Button1Down:Connect(function()
                local t = mouse.Target
                if t then
                    if curGui then curGui:Destroy() end; if curHl then curHl:Destroy() end
                    curHl = Instance.new("Highlight"); curHl.FillColor = Color3.fromRGB(255, 0, 0)
                    curHl.FillTransparency = 0.5; curHl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    curHl.Adornee = t; curHl.Parent = t
                    local cg = Instance.new("ScreenGui"); cg.Parent = PlayerGui; curGui = cg
                    local frame = Instance.new("Frame"); frame.Size = UDim2.new(0, 280, 0, 130)
                    frame.Position = UDim2.new(0.5, -140, 0.5, -65)
                    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); frame.BorderSizePixel = 0
                    frame.ZIndex = 99; frame.Parent = cg
                    local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 10); frameCorner.Parent = frame
                    local text = Instance.new("TextLabel"); text.Size = UDim2.new(1, 0, 0, 45); text.Text = "确定删除此建模吗？"
                    text.TextColor3 = Color3.fromRGB(255, 255, 255); text.Font = Enum.Font.GothamBold
                    text.TextSize = 15; text.BackgroundTransparency = 1; text.ZIndex = 100; text.Parent = frame
                    local confirmBtn = Instance.new("TextButton"); confirmBtn.Size = UDim2.new(0, 110, 0, 34)
                    confirmBtn.Position = UDim2.new(0, 18, 0, 75); confirmBtn.Text = "确定删除"
                    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255); confirmBtn.Font = Enum.Font.GothamBold
                    confirmBtn.TextSize = 13; confirmBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                    confirmBtn.BorderSizePixel = 0; confirmBtn.ZIndex = 100
                    confirmBtn.AutoButtonColor = false; confirmBtn.Parent = frame
                    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = confirmBtn
                    confirmBtn.MouseButton1Click:Connect(function()
                        if curHl then curHl:Destroy() end; t:Destroy(); cg:Destroy()
                    end)
                    local cancelBtn = Instance.new("TextButton"); cancelBtn.Size = UDim2.new(0, 110, 0, 34)
                    cancelBtn.Position = UDim2.new(0, 152, 0, 75); cancelBtn.Text = "取消"
                    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255); cancelBtn.Font = Enum.Font.GothamBold
                    cancelBtn.TextSize = 13; cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    cancelBtn.BorderSizePixel = 0; cancelBtn.ZIndex = 100
                    cancelBtn.AutoButtonColor = false; cancelBtn.Parent = frame
                    local canc = Instance.new("UICorner"); canc.CornerRadius = UDim.new(0, 6); canc.Parent = cancelBtn
                    cancelBtn.MouseButton1Click:Connect(function()
                        if curHl then curHl:Destroy() end; cg:Destroy()
                    end)
                end
            end)
        elseif runCode == "infjump" then
            infJumpEnabled = true
            _toggleConns[runCode] = UserInputService.JumpRequest:Connect(function()
                if infJumpEnabled then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then
                        c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    else
        if runCode == "esp" then disableAuthorESP()
        elseif runCode == "night" then Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif runCode == "fps" then fpsEnabled = false; FPSLabel.Visible = false
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0 end
            end end
        elseif runCode == "noclip" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end end
        elseif runCode == "fulllight" then
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
        elseif runCode == "serverinfo" then
            local infoGui = PlayerGui:FindFirstChild("ServerInfoGui")
            if infoGui then infoGui:Destroy() end
        elseif runCode == "dance1" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                for _, t in ipairs(c.Humanoid:GetPlayingAnimationTracks()) do t:Stop() end
            end
        elseif runCode == "fire" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                for _, v in ipairs(c.HumanoidRootPart:GetChildren()) do
                    if v:IsA("ParticleEmitter") and v.Name == "FireFX" then v:Destroy() end
                end
            end
        elseif runCode == "glow" then
            local c = Players.LocalPlayer.Character
            if c then
                local hl = c:FindFirstChild("PlayerGlow"); if hl then hl:Destroy() end
            end
        elseif runCode == "upsidedown" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif runCode == "bighead" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(2, 1, 1) end
        elseif runCode == "screenfx" then
            local fx = Lighting:FindFirstChild("ScreenFX"); if fx then fx:Destroy() end
        elseif runCode == "trail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("PlayerTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("TrailAttachment0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("TrailAttachment1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "firetrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("FireTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("FireTrailA0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("FireTrailA1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "iceTrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("IceTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("IceTrailA0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("IceTrailA1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "clearfog" then
            Lighting.FogEnd = 1000; Lighting.FogStart = 0
        elseif runCode == "subtitle" then
            local subGui = PlayerGui:FindFirstChild("SubtitleGui")
            if subGui then subGui:Destroy() end
        elseif runCode == "rainbowname" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then
                local bb = c.Head:FindFirstChild("BillboardGui")
                if bb then bb:Destroy() end
            end
        elseif runCode == "giant" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size / 3 end
            end end
        elseif runCode == "teamglow" then clearTeamGlow()
        elseif runCode == "enemyglow" then clearEnemyGlow()
        elseif runCode == "infjump" then infJumpEnabled = false
        end
        if _toggleConns[runCode] then
            pcall(function() _toggleConns[runCode]:Disconnect() end)
            _toggleConns[runCode] = nil
        end
    end
end

local pageContents = {
    ["公告"] = {type = "text"},
    ["通用"] = {
        type = "toggles",
        items = {
            {type = "button", name = "飞行模式", desc = "远程加载飞行脚本", icon = "🕊️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/refs/heads/main/%E9%A3%9E%E9%A5%BC"},
            {type = "button", name = "Remote", desc = "抓包", icon = "🎁", url = "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua"},
            {type = "button", name = "碰撞甩飞", desc = "帅飞plud", icon = "😎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/帅飞"},
            {type = "button", name = "fps通用", desc = "自动瞄准脚本", icon = "🎯", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E8%87%AA%E7%9E%84"},
            {type = "button", name = "传送玩家", desc = "选择玩家传送到旁边", icon = "📬", url = "teleport"},
            {type = "button", name = "跟随玩家", desc = "按跳跃键取消跟随", icon = "🚶", url = "follow"},
            {type = "button", name = "NTv3.3", desc = "多功能工具", icon = "🥚", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/nt"},
            {type = "button", name = "无限罗宝", desc = "亲测可用", icon = "🌷", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/锁机"},
            {type = "button", name = "Tx翻译", desc = "点击执行", icon = "⛽", url = "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"},
            {type = "button", name = "快速回家", desc = "传送到执行脚本时的位置", icon = "🏠", url = "home"},
            {type = "toggle", name = "无敌模式", desc = "免疫伤害（客户端）", icon = "🛡️", code = "god"},
            {type = "toggle", name = "千倍速度", desc = "移动速度1000", icon = "⚡", code = "superspeed"},
            {type = "toggle", name = "无限体力", desc = "体力不会减少", icon = "💪", code = "infstamina"},
            {type = "toggle", name = "无限弹药", desc = "弹药永远999", icon = "🔫", code = "infammo"},
            {type = "toggle", name = "服务器信息", desc = "人数+坐标+附近玩家", icon = "📊", code = "serverinfo"},
            {type = "toggle", name = "自动收集", desc = "自动吸附近物品", icon = "📦", code = "collect"},
            {type = "toggle", name = "点击传送", desc = "鼠标点哪里传哪里", icon = "📍", code = "clicktp"},
            {type = "toggle", name = "自动连点", desc = "自动点击屏幕准心", icon = "🖱️", code = "autoclick"},
            {type = "toggle", name = "踏空", desc = "走到哪定到哪不往下掉", icon = "🦶", code = "float"},
            {type = "toggle", name = "防挂机", desc = "自动防止被踢出游戏", icon = "⏰", code = "antiafk"},
            {type = "toggle", name = "加速模式", desc = "游戏全局加速", icon = "⏩", code = "speedhack"},
            {type = "toggle", name = "穿墙模式", desc = "可以穿过墙壁", icon = "👻", code = "noclip"},
            {type = "toggle", name = "透视物品", desc = "高亮可拾取物品", icon = "✨", code = "itemesp"},
            {type = "toggle", name = "隐身模式", desc = "别人看不到你", icon = "👻", code = "invisible"},
            {type = "toggle", name = "删除建模", desc = "点击方块确认后删除", icon = "🗑️", code = "deletepart"},
            {type = "toggle", name = "去雾功能", desc = "消除游戏中的雾气", icon = "🌫️", code = "clearfog"},
            {type = "input", name = "旋转速度", desc = "角色自动旋转", icon = "🔄", default = "0", execute = function(v)
                if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local hrp = c.HumanoidRootPart
                        spinConnection = RunService.RenderStepped:Connect(function()
                            if hrp and hrp.Parent then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(v) / 60, 0) end
                        end)
                    end
                end
                return true
            end},
            {type = "input", name = "广角", desc = "摄像机视野", icon = "🔭", default = "70", execute = function(v)
                if v > 0 and v <= 120 then
                    local cam = workspace.CurrentCamera
                    if cam then cam.FieldOfView = v; return true end
                end
                return false
            end},
            {type = "input", name = "调速度", desc = "移动速度", icon = "⚡", default = "16", execute = function(v)
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v; return true end
                end
                return false
            end},
            {type = "input", name = "跳跃高度", desc = "跳跃高度", icon = "🦘", default = "50", execute = function(v)
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpHeight = v; return true end
                end
                return false
            end},
            {type = "input", name = "重力", desc = "世界重力", icon = "🌙", default = "196", execute = function(v)
                if v > 0 then workspace.Gravity = v; return true end
                return false
            end},
            {type = "toggle", name = "无限跳跃", desc = "无限连续跳跃", icon = "⬆️", code = "infjump"},
            {type = "toggle", name = "夜视功能", desc = "提高黑暗视野亮度", icon = "🔦", code = "night"},
            {type = "toggle", name = "显示FPS", desc = "左上角帧率显示", icon = "📊", code = "fps"},
            {type = "toggle", name = "ESP透视", desc = "红色描边+名字可穿墙", icon = "👁️", code = "esp"},
        }
    },
    ["战斗功能"] = {
        type = "toggles",
        items = {
            {type = "toggle", name = "团队高亮", desc = "队友蓝色高亮", icon = "🔵", code = "teamglow"},
            {type = "toggle", name = "敌对高亮", desc = "敌人红色高亮", icon = "🔴", code = "enemyglow"},
            {type = "toggle", name = "自动攻击", desc = "自动追踪攻击敌人", icon = "⚔️", code = "autoattack"},
            {type = "toggle", name = "全图点亮", desc = "消除所有阴影", icon = "💡", code = "fulllight"},
            {type = "toggle", name = "一键自杀", desc = "立即重置角色", icon = "💀", code = "suicide"},
        }
    },
    ["整活功能"] = {
        type = "toggles",
        items = {
            {type = "toggle", name = "跳舞-机械舞", desc = "机器人风格舞蹈", icon = "🤖", code = "dance1"},
            {type = "toggle", name = "喷火模式", desc = "从角色身上喷火", icon = "🔥", code = "fire"},
            {type = "toggle", name = "光环模式", desc = "角色发光环", icon = "✨", code = "glow"},
            {type = "toggle", name = "倒立行走", desc = "角色倒过来", icon = "🙃", code = "upsidedown"},
            {type = "toggle", name = "大头模式", desc = "头变得超大", icon = "🗿", code = "bighead"},
            {type = "toggle", name = "全屏特效", desc = "屏幕加滤镜", icon = "🎨", code = "screenfx"},
            {type = "toggle", name = "彩虹拖尾", desc = "移动时拖彩虹尾迹", icon = "🌈", code = "trail"},
            {type = "toggle", name = "火焰拖尾", desc = "移动时拖火焰尾迹", icon = "🔥", code = "firetrail"},
            {type = "toggle", name = "冰霜拖尾", desc = "移动时拖冰霜尾迹", icon = "❄️", code = "iceTrail"},
            {type = "toggle", name = "管理员-彩虹名字", desc = "头顶名字变彩虹色", icon = "👑", code = "rainbowname"},
            {type = "toggle", name = "巨大化", desc = "把自己变大3倍", icon = "🦖", code = "giant"},
            {type = "toggle", name = "客户端字幕", desc = "屏幕上方显示入侵信息", icon = "📺", code = "subtitle"},
            {type = "button", name = "祖国人", desc = "祖国人脚本", icon = "🦸", url = "https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/refs/heads/main/homelander.lua"},
            {type = "button", name = "动作动画包", desc = "很多动作", icon = "🤖", url = "https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"},
            {type = "button", name = "播放器", desc = "自定义", icon = "🎉", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/播放"},
        }
    },
    ["音乐区"] = {
        type = "music",
        items = {
            {name = "进击的巨人", desc = "点击播放", icon = "🎵", soundId = "89711807693889"},
            {name = "误闯天家", desc = "点击播放", icon = "🎶", soundId = "124384558101360"},
            {name = "DJ喂喂喂", desc = "点击播放", icon = "🎧", soundId = "90054735589094"},
            {name = "unhappy", desc = "点击播放", icon = "🔊", soundId = "88523902860927"},
            {name = "震撼小曲二", desc = "点击播放", icon = "🎼", soundId = "137717310854691"},
            {name = "曾经的王", desc = "点击播放", icon = "🕺", soundId = "121931252233493"},
            {name = "离开我的依赖", desc = "点击播放", icon = "🌻", soundId = "112834898401032"},
            {name = "雨爱", desc = "点击播放", icon = "🌸", soundId = "79277371759525"},
            {name = "iqoo", desc = "点击播放", icon = "🎁", soundId = "75047041148646"},
            {name = "玉米饼", desc = "点击播放", icon = "🌽", soundId = "142376088"},
            {name = "我太想进步了", desc = "点击播放", icon = "🍺", soundId = "126846792948717"},
            {name = "最初的记忆", desc = "点击播放", icon = "💜", soundId = "108869978075942"},
            {name = "海与你", desc = "完整版", icon = "🥶", soundId = "76421239273915"},
            {name = "失眠", desc = "完整版", icon = "😴", soundId = "138048397060431"},
            {name = "传说之下", desc = "完整版", icon = "🍁", soundId = "138048397060431"},
            {name = "祖国人进行曲", desc = "点击播放", icon = "🎃", soundId = "86555185586884"},
        }
    },
    ["甩飞"] = {
        type = "buttons",
        items = {{name = "多人甩飞", desc = "选择玩家然后甩飞", icon = "💨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E7%94%A9%E9%A3%9E"}}
    },
}

pageContents["服务器"] = {
    type = "buttons",
    items = {
        {name = "灾难之岛", desc = "点击执行", icon = "🎍", url = "https://raw.githubusercontent.com/hgvuyguyg/new/main/灾难之岛"},
        {name = "找出谁打了一巴掌", desc = "点击执行", icon = "🤲", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/巴掌"},
        {name = "汉堡包", desc = "点击执行", icon = "🍔", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/汉堡"},
        {name = "机器人滑膛枪", desc = "点击执行", icon = "🤖", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/机器人"},
        {name = "住宅大逃杀", desc = "点击执行", icon = "🚪", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/住宅屠杀"},
        {name = "降落或死亡", desc = "点击执行", icon = "🛩️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/死亡"},
        {name = "砧板鲶鱼", desc = "点击执行", icon = "🐟", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/钓鱼"},
        {name = "死铁轨(黑脚本)", desc = "点击执行", icon = "🚂", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/铁轨"},
        {name = "柠檬大亨", desc = "点击执行", icon = "🍋", url = "https://rawscripts.net/raw/Sell-Lemons-Fluid-Orchard-Update-Read-Description-241132"},
        {name = "键盘逃脱", desc = "点击执行", icon = "⌨️", url = "https://raw.githubusercontent.com/ccdushii/zzzzzzzzz/refs/heads/main/ssssssssss"},
        {name = "驾驶帝国", desc = "皮脚本版", icon = "🚗", url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Roblox-Pi-Drivingempire-Script.lua"},
        {name = "排干湖水", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E6%8E%92%E5%B9%B2%E6%B9%96%E6%B0%B4"},
        {name = "Doors", desc = "点击执行", icon = "🚪", url = "https://raw.githubusercontent.com/XxwanhexxX/doors-zh/refs/heads/main/Abysall.Hub"},
        {name = "后巷", desc = "点击执行", icon = "🏚️", url = "https://github.com/mryitang-sys/Ting-script/releases/download/nsjxjxhs/GE.2.6.lua"},
        {name = "点击一次加一弹药", desc = "点击执行", icon = "🔫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E5%BC%B9%E8%8D%AF"},
        {name = "森林中的九十九夜", desc = "点击执行", icon = "🌲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/99"},
        {name = "踢一个幸运方块", desc = "点击执行", icon = "🎲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E5%B9%B8%E8%BF%90%E6%96%B9%E5%9D%97"},
        {name = "重型钓鱼", desc = "点击执行", icon = "🐬", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/重型钓鱼"},
        {name = "每次点击加1脂肪", desc = "点击执行", icon = "🍔", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/脂肪"},
        {name = "动物医院", desc = "点击执行", icon = "🚑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/福瑞医院"},
        {name = "每次点击加1关注者", desc = "点击执行", icon = "❤️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/关注"},
        {name = "吃吃世界", desc = "点击执行", icon = "🍱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/吃吃世界"},
        {name = "为你的城市供电", desc = "点击执行", icon = "🚦", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/为你的城市供电"},
        {name = "抛一枚硬币", desc = "点击执行", icon = "🎃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抛一枚硬币"},
        {name = "po大po", desc = "点击执行", icon = "🌰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拉大便"},
        {name = "blox Fruit", desc = "点击执行", icon = "🍎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/blox"},
        {name = "悬崖豪宅大亨", desc = "点击执行", icon = "🥂", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/豪宅悬崖"},
        {name = "草地增量模拟器", desc = "点击执行", icon = "🌿", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/草地增亮"},
        {name = "餐厅大亨3", desc = "点击执行", icon = "☕", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/餐厅大亨"},
        {name = "破坏者谜团二", desc = "点击执行", icon = "☠️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/mm2"},
        {name = "画一个滑雪板", desc = "点击执行", icon = "🛴", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/画画"},
        {name = "拥有一家咖啡馆", desc = "点击执行", icon = "🍵", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拥有咖啡馆"},
        {name = "快躲起来吧！", desc = "点击执行", icon = "🐾", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/躲起来"},
        {name = "钓鱼吧", desc = "点击执行", icon = "🦈", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/调"},
        {name = "清洗键盘", desc = "点击执行", icon = "⌨️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/清洗键盘"},
        {name = "装载卡车", desc = "点击执行", icon = "🚛", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/装载卡车"},
        {name = "fisch", desc = "点击执行", icon = "🐠", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/船鱼"},
        {name = "种植花园2", desc = "点击执行", icon = "☘️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/种植菜园二"},
        {name = "活了7天", desc = "点击执行", icon = "🐻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/活了7天"},
        {name = "被遗弃", desc = "点击执行", icon = "👻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/被遗弃"},
        {name = "河北唐县", desc = "点击执行", icon = "🚙", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/河北"},
        {name = "在末日中活下来", desc = "点击执行", icon = "🤢", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/末日"},
        {name = "零售大亨2", desc = "点击执行", icon = "🛷", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/零售大亨"},
        {name = "采矿大亨", desc = "点击执行", icon = "🦇", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/采矿"},
        {name = "启示录", desc = "点击执行", icon = "⚠️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/启示录"},
        {name = "战争大亨", desc = "点击执行", icon = "🦚", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/战争"},
        {name = "海上生存100天", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/海上100天"},
        {name = "俄亥俄州", desc = "点击执行", icon = "🦉", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/ohio"},
        {name = "加1割草冒险", desc = "点击执行", icon = "🌱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/割草冒险"},
        {name = "贪婪的种植者", desc = "点击执行", icon = "🤑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/种植者"},
        {name = "加1剑点击", desc = "点击执行", icon = "🖕🏻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/剑1"},
        {name = "在超级商店生存", desc = "点击执行", icon = "🥓", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/在超级商店生存"},
        {name = "在寒冷中生存", desc = "点击执行", icon = "🥶", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/在寒冷生存"},
        {name = "训练一只鸡", desc = "点击执行", icon = "🐓", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/训练鸡肉"},
        {name = "尘土飞扬的旅行", desc = "点击执行", icon = "🚘", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/长途旅行"},
        {name = "最强战场", desc = "点击执行", icon = "👾", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/最强"},
        {name = "跳跃获得足球球员", desc = "点击执行", icon = "🎈", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/获得球员"},
        {name = "伐木大亨2", desc = "点击执行", icon = "🌳", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/伐木大亨"},
        {name = "偷一个蛋", desc = "点击执行", icon = "🥚", url = "https://pastefy.app/4lHhgnhn/raw"},
        {name = "变身升级", desc = "点击执行", icon = "🐛", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/变身升级"},
        {name = "加1肌肉破坏墙壁", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/肌肉墙壁"},
        {name = "加1翅膀偷走脑残", desc = "点击执行", icon = "🍪", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/翅膀脑残"},
        {name = "踢球进太空", desc = "点击执行", icon = "🐃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/踢球太空"},
        {name = "魔法战利品", desc = "点击执行", icon = "✨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/魔法战利品"},
        {name = "夜幕降临", desc = "点击执行", icon = "🐼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/夜幕降临"},
        {name = "我的恐龙生活", desc = "点击执行", icon = "🦖", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/恐龙生活"},
        {name = "加一双跳自行车", desc = "点击执行", icon = "🚲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/双跳车"},
        {name = "谋杀之岛2", desc = "点击执行", icon = "🌶️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/谋杀之岛"},
        {name = "声名远播", desc = "点击执行", icon = "🍃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抢劫"},
        {name = "加1速度僵尸键盘逃脱", desc = "点击执行", icon = "🐊", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/僵尸键盘"},
        {name = "清理所有树叶", desc = "点击执行", icon = "🍁", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/清理树叶"},
        {name = "开箱asmr", desc = "点击执行", icon = "🍰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/开箱脆皮"},
        {name = "因为脑残退化而倒下", desc = "点击执行", icon = "🐊", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/脑残倒下"},
        {name = "我的木材农场", desc = "点击执行", icon = "🌲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/我的木材农场"},
        {name = "加一个后空翻键盘逃脱", desc = "点击执行", icon = "💀", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/后空翻键盘"},
        {name = "每次点击加一排水速度", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/点击加排水"},
        {name = "加一肌肉进化", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一肌肉精华"},
        {name = "抽取一只军队", desc = "点击执行", icon = "🍼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抽军队"},
        {name = "合拼一个核弹", desc = "点击执行", icon = "😺", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/合并核弹"},
        {name = "加一速度进化", desc = "点击执行", icon = "🐒", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加速度进化"},
        {name = "逃跑者", desc = "点击执行", icon = "👻", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/淘宝"},
        {name = "击杀头目", desc = "点击执行", icon = "🎅🏿", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/击杀头目"},
        {name = "加一速度沙滩逃脱", desc = "点击执行", icon = "🏖️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一沙滩"},
        {name = "dit", desc = "点击执行", icon = "🦰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/dit"},
        {name = "正在探矿", desc = "点击执行", icon = "👀", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/正在挖矿"},
        {name = "蝗虫之屋", desc = "点击执行", icon = "🦗", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/蝗虫之王"},
        {name = "加一超级英雄进化", desc = "点击执行", icon = "🐲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加油英雄"},
        {name = "拯救猫咪", desc = "点击执行", icon = "🐱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拯救猫"},
        {name = "恐怖寿司[第一章]", desc = "点击执行", icon = "😱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/寿司"},
        {name = "加一蛛丝逃脱", desc = "点击执行", icon = "🕸️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一蜘蛛"},
        {name = "加一跳墙奥比逃脱", desc = "点击执行", icon = "🛫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一跳墙"},
        {name = "按一个键帽", desc = "点击执行", icon = "🍅", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/按键帽"},
        {name = "在51区生存真相", desc = "点击执行", icon = "🤫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/51真相"},
        {name = "每步减重", desc = "点击执行", icon = "🦵", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/走路减重"},
        {name = "矿井", desc = "点击执行", icon = "🛶", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/矿井"},
        {name = "神秘的杀手", desc = "点击执行", icon = "👹", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/神秘的杀手"},
        {name = "寻找菜鸟并变身", desc = "点击执行", icon = "🍸", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/寻找菜鸟"},
        {name = "加一技能点传奇", desc = "点击执行", icon = "⚔️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一技能点"},
        {name = "加一忍者键盘逃脱", desc = "点击执行", icon = "🌑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一忍者"},
        {name = "破碎之梦", desc = "点击执行", icon = "❤️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/破碎"},
        {name = "钓鱼换取垃圾", desc = "点击执行", icon = "🐡", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/钓鱼垃圾"},
        {name = "新手间接式", desc = "点击执行", icon = "🤨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/新手间接式"},
        {name = "烤或死", desc = "点击执行", icon = "🍖", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/烤活死"},
        {name = "加一跳跃", desc = "点击执行", icon = "🦘", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一跳跃逃脱"},
        {name = "挖掘以逃脱", desc = "点击执行", icon = "🎃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/挖掘逃出监狱"},
        {name = "飞行世界", desc = "点击执行", icon = "✈️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞行世界"},
        {name = "空乘模拟器", desc = "点击执行", icon = "🛫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/空乘模拟机"},
        {name = "埃尔帕索边境角色扮演", desc = "点击执行", icon = "🤑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/帕索角色扮演"},
        {name = "加一玩具长臂逃脱", desc = "点击执行", icon = "🤳", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/玩具长臂"},
        {name = "墨水(别催了)", desc = "点击执行", icon = "😢", url = "https://raw.githubusercontent.com/hgvuyguyg/inkgames.github.io/refs/heads/main/ringta.lua"},
        {name = "无尽旅馆", desc = "点击执行", icon = "😎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/k"},
        {name = "力量传奇", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/力量"},
        {name = "路线06", desc = "点击执行", icon = "🐍", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/路线"},
        {name = "军事军队大亨", desc = "点击执行", icon = "🤠", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/战斗大亨"},
        {name = "偷走巴掌", desc = "点击执行", icon = "🖐🏻️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/1巴掌"},
    }
}

pageContents["国内脚本"] = {
    type = "buttons",
    items = {
        {name = "小皮脚本", desc = "拉完了", icon = "🇨🇳", url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"},
        {name = "黑洞脚本", desc = "BS脚本", icon = "🕳️", url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"},
        {name = "ROB脚本", desc = "ROB.V3", icon = "🤖", url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4"},
        {name = "黄某脚本", desc = "拉完了缝合", icon = "😞", url = "https://rawscripts.net/raw/Universal-Script-HMscript-50384"},
        {name = "Loarder脚本", desc = "拉完了", icon = "🤔", url = "https://raw.githubusercontent.com/Jilxi/123/refs/heads/main/Loader.lua"},
    }
}

local allSearchItems = {}
for pageName, contentData in pairs(pageContents) do
    if contentData.items then
        for _, itm in ipairs(contentData.items) do
            table.insert(allSearchItems, {page = pageName, item = itm})
        end
    end
end


local XixiHost = _genv.__XixiHost or {}
XixiHost.Version = "Fusion-3.0"
XixiHost.Name = "熙熙"
XixiHost.Modules = {}
XixiHost.Running = {}
XixiHost.Errors = {}
XixiHost.Stats = {}

local function XixiRegister(name, category, runner)
    if type(name) ~= "string" or name == "" or type(runner) ~= "function" then
        return false, "模块参数无效"
    end
    if XixiHost.Modules[name] then
        return false, "模块已注册"
    end
    XixiHost.Modules[name] = {Name=name, Category=category or "其他", Run=runner}
    XixiHost.Stats[name] = {Runs=0, LastError=nil, LastRun=0}
    return true
end

local function XixiRun(name)
    local m = XixiHost.Modules[name]
    if not m then return false, "模块不存在" end
    if XixiHost.Running[name] then return false, "模块正在运行" end
    if not XixiRuntime.Alive then return false, "宿主已经关闭" end
    XixiHost.Running[name] = true
    local st = XixiHost.Stats[name]
    st.Runs = (st.Runs or 0) + 1
    st.LastRun = os.time()
    local ok, err = xpcall(function() return m.Run() end, function(e)
        return debug and debug.traceback and debug.traceback(tostring(e), 2) or tostring(e)
    end)
    XixiHost.Running[name] = nil
    if not ok then
        st.LastError = tostring(err)
        XixiHost.Errors[name] = tostring(err)
        warn("[熙熙] 模块失败: " .. name .. " | " .. tostring(err))
        return false, err
    end
    if err == false then
        st.LastError = "模块返回失败"
        return false, "模块返回失败"
    end
    st.LastError = nil
    XixiHost.Errors[name] = nil
    return true, err
end

function XixiHost:Cleanup()
    for name in pairs(self.Running) do self.Running[name] = nil end
    self.Modules = {}
    self.Errors = {}
    self.Stats = {}
end

_genv.__XixiHost = XixiHost

local XixiPatriotScripts = {
    {Name="落叶 Pro Hub", Category="主脚本", Url="https://raw.githubusercontent.com/SyndromeXph/Luoye-Pro-Hub/refs/heads/main/Script/Loader.lua"},
    {Name="国内最强脚本中心", Category="主脚本", Url="https://raw.githubusercontent.com/ggsq1741-debug/rj/refs/heads/main/pjie.lua"},
    {Name="叶脚本 - 主脚本大全", Category="主脚本", Url="https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"},
    {Name="ROB 脚本 V2", Category="主脚本", Url="https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2"},
    {Name="黑洞中心 (BS)", Category="主脚本", Url="https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"},
    {Name="Delta Force 脚本中心", Category="主脚本", Url="https://api.jnkie.com/api/v1/luascripts/public/28f05f20579742b8db3901d189ca93ddecb4ff36815cee23d34bdff05ad7ae33/download"},
    {Name="ROB 活动", Category="主脚本", Url="https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/ROB.活动"},
    {Name="ROB V4", Category="主脚本", Url="https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4"},
    {Name="夜脚本", Category="主脚本", Url="https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben"},
    {Name="恐脚本", Category="主脚本", Url="https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB"},
    {Name="超高速跑者", Category="主脚本", Url="https://pastefy.app/yEEgIs1r/raw"},
    {Name="圣奥里", Category="主脚本", Url="https://pastefy.app/Wot0aN3V/raw"},
    {Name="翻瓶", Category="主脚本", Url="https://pastefy.app/AaMGGRLH/raw"},
    {Name="最强战场", Category="主脚本", Url="https://pastefy.app/1ZEycK4m/raw"},
    {Name="8个球池经典", Category="主脚本", Url="https://pastefy.app/gR2WUm0k/raw"},
    {Name="终极战场", Category="主脚本", Url="https://pastefy.app/qunhKqEl/raw"},
    {Name="国人电梯", Category="主脚本", Url="https://pastefy.app/eCUUlx4W/raw"},
    {Name="Blox Fruit", Category="主脚本", Url="https://pastefy.app/cE1CuNwC/raw"},
    {Name="BloxV13", Category="主脚本", Url="https://raw.gitcode.com/ROB5201314/dzsc/raw/main/Blox loot.XGJ"},
    {Name="冷脚本 LBT-H", Category="主脚本", Url="https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenlenglenglenglenglenglenglengleng-LBT-H-cold-script/refs/heads/main/LENG%20LBT-H%20cold%20script.txt"},
    {Name="星脚本", Category="主脚本", Url="https://raw.githubusercontent.com/zilinskaslandon/XingJiaoBen-2026-/refs/heads/main/%E6%98%9F%E8%84%9A%E6%9C%AC.lua"},
    {Name="浅脚本", Category="主脚本", Url="https://raw.githubusercontent.com/renlua/shallow/main/Script_Hub.lua"},
    {Name="Rb 脚本中心（Yungengxin）", Category="主脚本", Url="https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub"},
    {Name="Rb 脚本 - 汉化中心", Category="主脚本", Url="https://api.luarmor.net/files/v3/loaders/4fe525637e43a1be8cb0cdf902d107c2.lua"},
    {Name="Rb 脚本 v1.2.4", Category="主脚本", Url="https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4"},
    {Name="Sxingz 脚本", Category="主脚本", Url="https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/ZiO.lua"},
    {Name="VM 脚本", Category="主脚本", Url="https://raw.githubusercontent.com/chano-oss/d/refs/heads/main/obfwni7iq3q.lua"},
    {Name="迪脚本 2.0", Category="主脚本", Url="https://raw.githubusercontent.com/ddjlb7598/-2.0/refs/heads/main/%E8%BF%AA%E8%84%9A%E6%9C%AC2.0.lua"},
    {Name="无脚本 V1", Category="主脚本", Url="https://raw.githubusercontent.com/XiaoXuCynic/Free-Script/main/无脚本V1混淆.lua.txt"},
    {Name="黎明中心脚本", Category="主脚本", Url="https://raw.githubusercontent.com/qwrt5589/eododo/9c2ed7cbca352c21a0b67f4d79558bd56299f252/345678910.txt"},
    {Name="XION 脚本", Category="主脚本", Url="https://raw.githubusercontent.com/smalldesikon/wocaonima/main/qq984820669.txt"},
    {Name="芋风脚本（测试版）", Category="主脚本", Url="https://raw.githubusercontent.com/0lihaorui0/dvdvhd/main/芋风脚本%20测试版(1).lua"},
    {Name="X 脚本", Category="主脚本", Url="https://raw.githubusercontent.com/maowang1/xx/main/Protected_8858329470146381.txt"},
    {Name="矢井凛脚本", Category="主脚本", Url="https://raw.githubusercontent.com/lxmyysd/XiaoXu/refs/heads/main/%E7%9F%A2%E4%BA%95%E5%87%9B%E6%BA%90%E7%A0%81.lua"},
    {Name="禁漫中心脚本", Category="主脚本", Url="https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua"},
    {Name="秋脚本", Category="主脚本", Url="https://raw.githubusercontent.com/WS857960/-/main/秋·自制脚本新源码.txt"},
    {Name="VOTR 脚本", Category="主脚本", Url="https://raw.githubusercontent.com/VOTR-HUB/MAIN/refs/heads/main/VOTR-MAIN"},
    {Name="皮空脚本", Category="主脚本", Url="https://raw.githubusercontent.com/smalldesikon/eyidfki/840d4b80d4f312c70b7b1067e056a2c4f828ef32/%E6%89%A7%E8%A1%8C%E8%84%9A%E6%9C%AC(%E6%B7%B7%E6%B7%86%E5%90%8E).txt"},
    {Name="黑白脚本加载器", Category="主脚本", Url="https://raw.githubusercontent.com/tfcygvunbind/Apple/main/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8"},
    {Name="新圣奥里脚本建议不要使用", Category="服务器专区", Url="https://raw.githubusercontent.com/idkidevthings/improved-octo-chainsaw/refs/heads/main/sanx.lua"},
    {Name="叶脚本 - 俄亥俄州", Category="服务器专区", Url="https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE-%20Scripts-OHIO.lua"},
    {Name="叶脚本 - 河北唐县", Category="服务器专区", Url="https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE%20SCRIPT-Tang%20County%2C%20Hebei.lua"},
    {Name="公益飞行彩虹版", Category="功能脚本", Url="https://pastefy.app/hXt2L9kY/raw"},
    {Name="ROB飞行测试版", Category="功能脚本", Url="https://pastefy.app/FA3q5ROD/raw"},
    {Name="踏空行走", Category="功能脚本", Url="https://pastefy.app/qtazgrP6/raw"},
    {Name="亮光透视", Category="功能脚本", Url="https://pastefy.app/LE2hzECZ/raw"},
    {Name="锁头自瞄", Category="功能脚本", Url="https://pastefy.app/jeYSxlOI/raw"},
    {Name="追踪雷达", Category="功能脚本", Url="https://pastefy.app/bJiEXfNS/raw"},
    {Name="假延迟", Category="功能脚本", Url="https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/Desync(1).lua"},
    {Name="自动翻译", Category="功能脚本", Url="https://pastefy.app/IbrQeCIh/raw"},
    {Name="伪装欺骗", Category="功能脚本", Url="https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/weizhuang.robv4"},
    {Name="防甩飞", Category="功能脚本", Url="https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua"},
    {Name="飞踢甩飞", Category="功能脚本", Url="https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/飞踢脚本汉化"},
    {Name="祖国人飞行", Category="功能脚本", Url="https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/main/homelander.lua"},
    {Name="普通黑洞", Category="黑洞专区", Url="https://pastebin.com/raw/Sx6PY4gV"},
    {Name="普通黑洞2", Category="黑洞专区", Url="https://pastefy.app/BbXuvVkK/raw"},
    {Name="高级黑洞", Category="黑洞专区", Url="https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/blackhole.lua"},
    {Name="黑洞1", Category="黑洞专区", Url="https://pastefy.app/J21lpKbj/raw"},
    {Name="黑洞2", Category="黑洞专区", Url="https://raw.githubusercontent.com/dingding123hhh/lililiugg/main/jm114514.lua"},
    {Name="黑洞3", Category="黑洞专区", Url="https://pastefy.app/EwpVHMPg/raw"},
    {Name="黑洞4", Category="黑洞专区", Url="https://raw.githubusercontent.com/BingusWR/BLACKHOLDSCRIPT/refs/heads/main/BLACK%20HOLD%20SCRIPT"},
    {Name="黑洞5", Category="黑洞专区", Url="https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Blackholescript.lua"},
    {Name="黑洞6", Category="黑洞专区", Url="https://raw.githubusercontent.com/BOOSBS/666/refs/heads/main/656"},
    {Name="黑洞7", Category="黑洞专区", Url="https://pastebin.com/raw/U29jR1Cf"},
    {Name="黑洞8", Category="黑洞专区", Url="https://raw.githubusercontent.com/BOOSBS/199/refs/heads/main/V3"},
    {Name="五子棋", Category="小游戏", Url="https://pastefy.app/YiG9QQae/raw"},
    {Name="俄罗斯方块", Category="小游戏", Url="https://files.catbox.moe/4g6uay.txt"},
    {Name="贪吃蛇", Category="小游戏", Url="https://pastefy.app/6TWyR3SJ/raw"},
    {Name="扫雷", Category="小游戏", Url="https://pastefy.app/TN9CoOPt/raw"},
    {Name="光影", Category="画质光影", Url="https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"},
    {Name="RTX高仿", Category="画质光影", Url="https://pastebin.com/raw/Bkf0BJb3"},
    {Name="超高画质", Category="画质光影", Url="https://pastebin.com/raw/jHBfJYmS"},
    {Name="7yd7 动作脚本", Category="动作 / 表情", Url="https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"},
    {Name="皮脚本", Category="工具", Url="https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"},
    {Name="餐厅大亨3", Category="服务器脚本", Url="https://pastefy.app/Lrs56Q8d/raw"},
    {Name="超真实csgo", Category="服务器脚本", Url="https://pastefy.app/H7QvZbrd/raw"},
    {Name="沉默的刺客", Category="服务器脚本", Url="https://pastefy.app/WvQ2X9Ap/raw"},
    {Name="吃别人来成长", Category="服务器脚本", Url="https://pastefy.app/UNho7C7q/raw"},
    {Name="刀刃球", Category="服务器脚本", Url="https://pastefy.app/SrTbo5RW/raw"},
    {Name="钓鱼模拟器", Category="服务器脚本", Url="https://pastefy.app/dR9CHVPs/raw"},
    {Name="动物医院", Category="服务器脚本", Url="https://pastefy.app/i2DPWno2/raw"},
    {Name="犯罪", Category="服务器脚本", Url="https://pastefy.app/jtpr1Mgc/raw"},
    {Name="防御", Category="服务器脚本", Url="https://pastefy.app/tFXWWXzb/raw"},
    {Name="花园地平线", Category="服务器脚本", Url="https://pastefy.app/gPSk0o4s/raw"},
    {Name="滑开大海", Category="服务器脚本", Url="https://pastefy.app/ScntJmhk/raw"},
    {Name="滑石头RNG", Category="服务器脚本", Url="https://pastefy.app/JAZZfkV4/raw"},
    {Name="火箭发射模拟器", Category="服务器脚本", Url="https://pastefy.app/sHzbfKCD/raw"},
    {Name="火球训练", Category="服务器脚本", Url="https://pastefy.app/7HgyHMnU/raw"},
    {Name="极速传奇", Category="服务器脚本", Url="https://pastefy.app/utTMkgQe/raw"},
    {Name="集装箱RNG", Category="服务器脚本", Url="https://pastefy.app/sO4Ko8mm/raw"},
    {Name="监狱泵", Category="服务器脚本", Url="https://pastefy.app/WShOvrFw/raw"},
    {Name="僵尸生存竞技场", Category="服务器脚本", Url="https://pastefy.app/PYn6KTay/raw"},
    {Name="僵尸之塔", Category="服务器脚本", Url="https://pastefy.app/Wi2f84Ca/raw"},
    {Name="戒网瘾中心", Category="服务器脚本", Url="https://pastefy.app/xGHE7EWS/raw"},
    {Name="举重模拟器", Category="服务器脚本", Url="https://pastefy.app/QTeUq9I0/raw"},
    {Name="决斗场", Category="服务器脚本", Url="https://pastefy.app/MRpyprG1/raw"},
    {Name="砍伐树木", Category="服务器脚本", Url="https://pastefy.app/LS30JEFF/raw"},
    {Name="克隆王国大亨", Category="服务器脚本", Url="https://pastefy.app/fR4qrMdt/raw"},
    {Name="矿井", Category="服务器脚本", Url="https://pastefy.app/Md49dmBE/raw"},
    {Name="力量传奇", Category="服务器脚本", Url="https://pastefy.app/S7GMe806/raw"},
    {Name="每步+1智商", Category="服务器脚本", Url="https://pastefy.app/OfCgKxr3/raw"},
    {Name="迷你帝国", Category="服务器脚本", Url="https://pastefy.app/sKyi6Hdq/raw"},
    {Name="模仿者", Category="服务器脚本", Url="https://pastefy.app/WVCwCr6X/raw"},
    {Name="木筏101天生存", Category="服务器脚本", Url="https://pastefy.app/Hm4zw594/raw"},
    {Name="奴才大亨", Category="服务器脚本", Url="https://pastefy.app/dz4hFQf6/raw"},
    {Name="平滑切片", Category="服务器脚本", Url="https://pastefy.app/ADDvDF0Z/raw"},
    {Name="破坏者谜团2", Category="服务器脚本", Url="https://pastefy.app/Dr5qahWL/raw"},
    {Name="启示录", Category="服务器脚本", Url="https://pastefy.app/M7YGp8zN/raw"},
    {Name="汽车营销商大亨", Category="服务器脚本", Url="https://pastefy.app/DKVut4hJ/raw"},
    {Name="强壮传奇", Category="服务器脚本", Url="https://pastefy.app/6TCozPef/raw"},
    {Name="忍者传奇", Category="服务器脚本", Url="https://pastefy.app/WDHa8llX/raw"},
    {Name="鲨鱼咬", Category="服务器脚本", Url="https://pastefy.app/gZ8J7xAT/raw"},
    {Name="闪光", Category="服务器脚本", Url="https://pastefy.app/UmtpmEi3/raw"},
    {Name="生存于杀手", Category="服务器脚本", Url="https://pastefy.app/baGsRsEU/raw"},
    {Name="手枪竞技场", Category="服务器脚本", Url="https://pastefy.app/XfcDufEY/raw"},
    {Name="水手碎片", Category="服务器脚本", Url="https://pastefy.app/AQjzR2BI/raw"},
    {Name="撕咬之夜", Category="服务器脚本", Url="https://pastefy.app/Mom7Ic9J/raw"},
    {Name="亡命速递", Category="服务器脚本", Url="https://pastefy.app/oyN2H3sW/raw"},
    {Name="像素之刃", Category="服务器脚本", Url="https://pastefy.app/Ztkk1GrI/raw"},
    {Name="血色地带", Category="服务器脚本", Url="https://pastefy.app/JV8YzSza/raw"},
    {Name="血腥游乐场", Category="服务器脚本", Url="https://pastefy.app/FcaDu1vr/raw"},
    {Name="血债", Category="服务器脚本", Url="https://pastefy.app/f0899vFy/raw"},
    {Name="寻找巨型鱼", Category="服务器脚本", Url="https://pastefy.app/9jvzzO0g/raw"},
    {Name="训练怪兽进行破坏", Category="服务器脚本", Url="https://pastefy.app/b0jOaKFH/raw"},
    {Name="月球增量", Category="服务器脚本", Url="https://pastefy.app/CDfIzMDv/raw"},
    {Name="种植花园", Category="服务器脚本", Url="https://pastefy.app/NRTi5pfu/raw"},
    {Name="诅咒之刃", Category="服务器脚本", Url="https://pastefy.app/8GgMUdI3/raw"},
    {Name="菜鸟竞技场", Category="服务器脚本", Url="https://pastefy.app/eqQJ25wZ/raw"},
    {Name="驾驶帝国", Category="服务器脚本", Url="https://pastefy.app/ynf4fWmK/raw"},
}

local XixiBSModules = {
    "被遗弃",
    "偷走脑红",
    "DOORS",
    "森林中生存99夜",
    "死铁轨",
    "伐木大亨2",
    "终极战场",
    "启示录",
    "最强战场",
    "Blox Fruit",
    "刀刃球",
    "内脏与黑火药",
    "Make a Army",
    "成为乞丐(乞丐模拟器)",
    "光剑模拟器",
    "挖出后院(功能1)",
    "挖出后院(功能2)",
    "元素大亨",
    "堡垒之战",
    "恐鬼症",
    "恶魔学",
    "建造基地",
    "极速传奇",
    "紧急汉堡",
    "请捐赠",
    "忍者传奇",
    "植物大战脑红",
    "chain",
    "兵工场",
    "餐厅大亨3",
    "零售大亨2",
    "脑叶公司",
    "武器库",
    "种植花园",
    "射击并吃掉NOOB",
    "在51区",
    "躲避",
    "建造一个堡垒",
    "画我",
    "在超市生存一周",
    "汽车经销大亨",
    "7day live",
    "建造一座岛屿",
    "挖掘它",
    "隐藏或死亡",
    "Rope battles",
    "殖民地",
    "动物捉迷藏",
    "皮肤行者",
    "力量传奇",
    "传奇塔防",
    "死亡之死",
    "凌晨三点后",
    "战争大亨",
    "一路向西",
    "自然灾害",
    "通缉",
    "感染的微笑",
    "监狱人生",
    "鲨口逃生1",
    "南极洲探险队",
    "涂鸦奥比✏️",
    "疯狂电梯!",
    "Ragdoll Stack!",
    "保护房子免受怪物的伤害",
    "盲射",
    "Po大Po",
    "柔术无限",
    "无敌战争",
    "出租车老板",
    "砍伐树木",
    "脑红跳跃",
    "模仿者",
    "画一条Ra和设置帆",
}

local function XixiSafeHttpLoad(url)
    if type(url) ~= "string" or url == "" then return false, "URL 为空" end
    local ok, src = pcall(function() return __XixiRemoteFetch(url) end)
    if not ok or type(src) ~= "string" or src == "" then return false, "远程源码获取失败" end
    local loader = loadstring or load
    if type(loader) ~= "function" then return false, "当前环境不支持 loadstring/load" end
    local okc, fn = pcall(loader, src)
    if not okc or type(fn) ~= "function" then return false, "远程源码编译失败" end
    local oke, err = xpcall(fn, function(e) return debug and debug.traceback and debug.traceback(tostring(e)) or tostring(e) end)
    if not oke then return false, err end
    return true
end

for _, item in ipairs(XixiPatriotScripts) do
    XixiRegister("爱国者/" .. item.Name, item.Category, function()
        return XixiSafeHttpLoad(item.Url)
    end)
end

for _, name in ipairs(XixiBSModules) do
    XixiRegister("BS/" .. name, "BS游戏模块", function()
        local message = "BS模块尚未接入真实功能源码：" .. name
        warn("[熙熙] " .. message)
        return false, message
    end)
end

local TAB_NAMES = {"公告", "通用", "战斗功能", "整活功能", "音乐区", "甩飞", "服务器", "国内脚本", "爱国者", "BS模块", "设置"}
local findTabIndex
do
    local m = {}
    for i, n in ipairs(TAB_NAMES) do m[n] = i end
    findTabIndex = function(n) return m[n] end
end

local mainWin
local function closeAll()
    if XixiRuntime and XixiRuntime.Alive then pcall(XixiRuntime.Cleanup) end
    if XixiHost and type(XixiHost.Cleanup) == "function" then pcall(function() XixiHost:Cleanup() end) end
    if mainWin then pcall(function() mainWin:destroy() end) end
    if fpsGui then pcall(function() fpsGui:Destroy() end) end
    if _genv.__XixiRuntime == XixiRuntime then _genv.__XixiRuntime = nil end
    _genv.__XixiMegaBundleRunning = nil
end

mainWin = ui.createPanel({
    w = 500, h = 340,
    title = "熙熙·融合版",
    tabs = TAB_NAMES,
    sidebarWidth = 100,
    showPlayer = true,
    center = true,
    onClose = function()
        local verify
        verify = ui.createPanel({
            w = 320, h = 180, title = "确认关闭", center = true,
            minimizable = false, showPlayer = false,
        })
        ui.createLabel({
            parent = verify.body, x = 0, y = 10, w = 320, h = 40,
            text = "请输入数字 1 或 2 进行二次验证",
            align = Enum.TextXAlignment.Center, textSize = 12,
        })
        ui.createButton({
            parent = verify.body, x = 60, y = 80, w = 90, h = 40,
            text = "1", textSize = 18,
            onClick = function()
                ui.createLabel({
                    parent = verify.body, x = 0, y = 130, w = 320, h = 24,
                    text = "验证失败", color = Color3.fromRGB(255, 100, 100),
                    align = Enum.TextXAlignment.Center, textSize = 11,
                })
                task.wait(0.8)
                if verify then verify:destroy() end
            end,
        })
        ui.createButton({
            parent = verify.body, x = 170, y = 80, w = 90, h = 40,
            text = "2", textSize = 18,
            onClick = function()
                if verify then verify:destroy() end
                closeAll()
            end,
        })
    end,
})

do
    local camera = workspace.CurrentCamera
    local frame = mainWin and mainWin.frame
    if frame and camera then
        local scaleObj = frame:FindFirstChild("XixiDeviceScale")
        if not scaleObj then
            scaleObj = Instance.new("UIScale")
            scaleObj.Name = "XixiDeviceScale"
            scaleObj.Parent = frame
        end

        local function updateDeviceScale()
            local vp = camera.ViewportSize
            local w, h = vp.X, vp.Y
            local scale

            scale = math.min((w - 20) / 500, (h - 20) / 340)
            scale = math.clamp(scale, 0.58, 1.0)

            if w >= 900 and h >= 600 then
                scale = 1.0
            elseif w >= 700 then
                scale = math.max(scale, 0.88)
            end

            _genv.__XixiBaseScale = scale
            local multiplier = tonumber(_genv.__XixiScaleMultiplier) or 1
            multiplier = math.clamp(multiplier, 0.75, 1.35)
            _genv.__XixiScaleMultiplier = multiplier
            scaleObj.Scale = math.clamp(scale * multiplier, 0.45, 1.35)
            _genv.__XixiApplyScale = function(nextMultiplier)
                local value = tonumber(nextMultiplier)
                if not value then return false end
                value = math.clamp(value, 0.75, 1.35)
                _genv.__XixiScaleMultiplier = value
                local base = tonumber(_genv.__XixiBaseScale) or 1
                if scaleObj and scaleObj.Parent then
                    scaleObj.Scale = math.clamp(base * value, 0.45, 1.35)
                end
                return true
            end
        end

        updateDeviceScale()
        XixiTrackConnection(camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateDeviceScale))

        if UserInputService.TouchEnabled then
            _genv.__XixiMobile = true
            pcall(function() frame.Active = true end)
        else
            _genv.__XixiMobile = false
        end
    end
end

local function addFusionButton(parent, title, desc, callback)
    pcall(function()
        ui.createButton({parent=parent, x=10, y=10, w=180, h=32, text=title, onClick=callback})
    end)
end

pageContents["爱国者"] = pageContents["爱国者"] or {type="buttons", items={}}
for _, item in ipairs(XixiPatriotScripts) do
    table.insert(pageContents["爱国者"].items, {name=item.Name, desc=item.Category, icon="📦", code=function()
        local ok, err = XixiRun("爱国者/" .. item.Name)
        if not ok then warn("[熙熙] " .. item.Name .. ": " .. tostring(err)) end
    end})
end
pageContents["BS模块"] = {type="buttons", items={}}
for _, name in ipairs(XixiBSModules) do
    table.insert(pageContents["BS模块"].items, {name=name, desc="BS游戏模块（受控）", icon="🧩", code=function()
        local ok, err = XixiRun("BS/" .. name)
        if not ok then warn("[熙熙] BS/" .. name .. ": " .. tostring(err)) end
    end})
end

allSearchItems = {}
for pageName, contentData in pairs(pageContents) do
    if contentData.items then
        for _, itm in ipairs(contentData.items) do
            table.insert(allSearchItems, {page = pageName, item = itm})
        end
    end
end

do
    local tb = mainWin.titleBar
    if tb then
        local infoBox = Instance.new("Frame")
        infoBox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        infoBox.BorderSizePixel = 0
        infoBox.Position = UDim2.new(0, 140, 0, 4)
        infoBox.Size = UDim2.new(0, 180, 0, 26)
        infoBox.ZIndex = 30
        infoBox.Parent = tb
        Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)
        local infoLabel = Instance.new("TextLabel")
        infoLabel.BackgroundTransparency = 1
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.Text = "熙熙 V2.0"
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.Font = Enum.Font.GothamBold
        infoLabel.TextSize = 10
        infoLabel.ZIndex = 31
        infoLabel.Parent = infoBox
        task.spawn(function()
            while infoBox.Parent do
                local now = os.date("*t")
                infoLabel.Text = "熙熙 V2.0 | " .. now.month .. "月" .. now.day .. "日 " .. string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
                task.wait(1)
            end
        end)

        local adminBox = Instance.new("Frame")
        adminBox.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        adminBox.BorderSizePixel = 0
        adminBox.Position = UDim2.new(0, 326, 0, 4)
        adminBox.Size = UDim2.new(0, 90, 0, 26)
        adminBox.ZIndex = 30
        adminBox.Parent = tb
        Instance.new("UICorner", adminBox).CornerRadius = UDim.new(0, 6)
        local adminLabel = Instance.new("TextLabel")
        adminLabel.BackgroundTransparency = 1
        adminLabel.Size = UDim2.new(1, 0, 1, 0)
        adminLabel.Text = "👑 管理员"
        adminLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        adminLabel.Font = Enum.Font.GothamBold
        adminLabel.TextSize = 10
        adminLabel.ZIndex = 31
        adminLabel.Parent = adminBox
    end
end

local CW = 380
local PAD = 8
local CARD_H = 42
local CARD_GAP = 6

local function makeScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    return scroll
end

local function attachTooltip(frame, text)
    if not text then return end
    frame.MouseEnter:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        pcall(function() ui.showTooltip(frame, text, mp.X + 12, mp.Y + 12) end)
    end)
    frame.MouseLeave:Connect(function()
        pcall(function() ui.hideTooltip() end)
    end)
end

local function makeButtonCard(scroll, item, yPos)
    local tooltipText = (item.name or "") .. "\n" .. (item.desc or "")
    ui.createButton({
        parent = scroll, x = PAD, y = yPos, w = CW, h = CARD_H,
        layout = "card",
        text = (item.icon or "") .. "  " .. (item.name or ""),
        icon = ">", textSize = 11,
        tooltip = tooltipText,
        onClick = function()
            if item.url == "teleport" or item.url == "follow" then
                local selectWin = ui.createPanel({
                    w = 220, h = 300,
                    title = item.url == "follow" and "选择跟随" or "选择玩家",
                    center = true, minimizable = false, showPlayer = false,
                })
                local pY = 8
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= Players.LocalPlayer then
                        local target = plr
                        ui.createButton({
                            parent = selectWin.body, x = 8, y = pY, w = 204, h = 30,
                            layout = "card", text = target.Name, icon = ">", textSize = 11,
                            tooltip = "点击传送到 " .. target.Name .. " 旁边",
                            onClick = function()
                                if item.url == "follow" then
                                    followActive = true
                                    if followConnection then followConnection:Disconnect() end
                                    followConnection = RunService.RenderStepped:Connect(function()
                                        if not followActive then
                                            if followConnection then followConnection:Disconnect(); followConnection = nil end
                                            return
                                        end
                                        local c = Players.LocalPlayer.Character
                                        local tc = target.Character
                                        if c and c:FindFirstChild("HumanoidRootPart") and tc and tc:FindFirstChild("HumanoidRootPart") then
                                            c.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                                        end
                                    end)
                                    UserInputService.JumpRequest:Connect(function()
                                        if followActive then
                                            followActive = false
                                            if followConnection then followConnection:Disconnect(); followConnection = nil end
                                        end
                                    end)
                                else
                                    local c = Players.LocalPlayer.Character
                                    local tc = target.Character
                                    if c and c:FindFirstChild("HumanoidRootPart") and tc and tc:FindFirstChild("HumanoidRootPart") then
                                        c.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                                    end
                                end
                                selectWin:destroy()
                            end,
                        })
                        pY = pY + 34
                    end
                end
            elseif item.url == "home" then
                if homePosition then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        c.HumanoidRootPart.CFrame = homePosition
                    end
                end
            elseif type(item.code) == "function" then
                local ok, err = xpcall(item.code, function(e)
                    return debug and debug.traceback and debug.traceback(tostring(e), 2) or tostring(e)
                end)
                if not ok then warn("[熙熙] 功能执行失败: " .. tostring(item.name) .. " | " .. tostring(err)) end
            elseif item.url then
                if item.name == "驾驶帝国" then
                    pcall(function() _genv.XiaoPi = "皮脚本-驾驶帝国" end)
                end
                task.spawn(function()
                    local ok, err = XixiSafeHttpLoad(item.url)
                    if not ok then warn("[熙熙] 远程脚本加载失败: " .. tostring(item.name) .. " | " .. tostring(err)) end
                end)
            end
        end,
    })
    return yPos + CARD_H + CARD_GAP
end

local function makeToggleCard(scroll, item, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 60, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 80, h = 14,
        text = item.desc or "", textSize = 9,
        color = Color3.fromRGB(130, 130, 130),
    })
    ui.createToggle({
        parent = card, x = CW - 46, y = 11, w = 36, h = 20,
        value = false,
        onChange = function(v)
            pcall(handleFeatureToggle, item.code, v)
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or ""))
    return yPos + CARD_H + CARD_GAP
end

local function makeInputCard(scroll, item, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 140, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 160, h = 14,
        text = (item.desc or "") .. " (默认" .. tostring(item.default or "") .. ")",
        textSize = 9, color = Color3.fromRGB(130, 130, 130),
    })
    local tb = ui.createTextBox({
        parent = card, x = CW - 130, y = 10, w = 60, h = 22,
        text = item.default or "", textSize = 11,
        align = Enum.TextXAlignment.Center,
    })
    ui.createButton({
        parent = card, x = CW - 62, y = 10, w = 50, h = 22,
        text = "设置", textSize = 10,
        tooltip = "点击应用输入框中的数值",
        onClick = function()
            local v = tonumber(tb.Text)
            if v and item.execute then
                pcall(item.execute, v)
            end
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or "") .. "，当前默认值 " .. tostring(item.default or ""))
    return yPos + CARD_H + CARD_GAP
end

local function makeMusicCard(scroll, item, yPos)
    local sound = nil
    local isPlaying = false
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 80, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 100, h = 14,
        text = item.desc or "", textSize = 9,
        color = Color3.fromRGB(130, 130, 130),
    })
    local btn
    btn = ui.createButton({
        parent = card, x = CW - 62, y = 10, w = 50, h = 22,
        text = "播放", textSize = 10,
        tooltip = "点击播放 / 再点一次停止",
        onClick = function()
            if isPlaying then
                if sound then sound:Stop(); sound:Destroy(); sound = nil end
                isPlaying = false
                if btn then btn.Text = "播放" end
            else
                sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. tostring(item.soundId)
                sound.Volume = 1
                sound.Parent = workspace
                sound:Play()
                sound.Ended:Connect(function()
                    if sound then sound:Destroy() end
                    sound = nil; isPlaying = false
                    if btn then btn.Text = "播放" end
                end)
                isPlaying = true
                if btn then btn.Text = "停止" end
            end
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or ""))
    return yPos + CARD_H + CARD_GAP
end

local function renderItem(scroll, item, pageType, yPos)
    local t = item.type or pageType
    if t == "button" or t == "buttons" then
        return makeButtonCard(scroll, item, yPos)
    elseif t == "toggle" or t == "toggles" then
        return makeToggleCard(scroll, item, yPos)
    elseif t == "input" then
        return makeInputCard(scroll, item, yPos)
    elseif t == "music" then
        return makeMusicCard(scroll, item, yPos)
    end
    return yPos
end

local function buildAnnouncementPage(page)
    local searchTb = ui.createTextBox({
        parent = page, x = PAD, y = 8, w = CW, h = 32,
        placeholder = "🔍 搜索功能 (按回车搜索)",
        textSize = 12,
    })
    local timeLabel = ui.createLabel({
        parent = page, x = PAD, y = 50, w = CW, h = 280,
        text = "", textSize = 11,
        color = Color3.fromRGB(70, 70, 70),
        vAlign = Enum.TextYAlignment.Top, wrapped = true,
    })
    local resultScroll = makeScrollFrame(page)
    resultScroll.Position = UDim2.new(0, 0, 0, 48)
    resultScroll.Visible = false

    local function getTime()
        local n = os.date("*t")
        return n.year .. "年" .. n.month .. "月" .. n.day .. "日 " .. string.format("%02d:%02d:%02d", n.hour, n.min, n.sec)
    end
    task.spawn(function()
        while mainWin and mainWin.frame and mainWin.frame.Parent do
            pcall(function()
                timeLabel.Text =
                    "⏰ " .. getTime() .. "\n\n" ..
                    "👤 脚本：熙熙\n👤 作者：大肥鱼\n" ..
                    "📅 创建日期：2026年7月10日\n" ..
                    "🔄 此脚本一直更新\n\n" ..
                    "📊 您目前已经执行了 " .. globalExecCount .. " 次，感谢您的支持！\n" ..
                    "\n🇨🇳金秋十月，喜迎国庆！山河锦绣，国泰民安。\n\n✨感谢各位一直以来支持熙熙。\n\n🎉愿大家假期愉快，万事顺遂！"
            end)
            task.wait(1)
        end
    end)

    searchTb.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local q = string.lower(searchTb.Text or "")
        for _, c in ipairs(resultScroll:GetChildren()) do c:Destroy() end
        if q == "" then
            resultScroll.Visible = false
            timeLabel.Visible = true
            return
        end
        timeLabel.Visible = false
        resultScroll.Visible = true
        local yPos = 4
        for _, entry in ipairs(allSearchItems) do
            local itm = entry.item
            local nameMatch = itm.name and string.lower(itm.name):find(q, 1, true)
            local descMatch = itm.desc and string.lower(itm.desc):find(q, 1, true)
            if nameMatch or descMatch then
                ui.createButton({
                    parent = resultScroll, x = PAD, y = yPos, w = CW, h = CARD_H,
                    layout = "card",
                    text = (itm.icon or "") .. "  " .. (itm.name or "") .. "   (" .. entry.page .. ")",
                    icon = ">", textSize = 11,
                    tooltip = (itm.name or "") .. "\n" .. (itm.desc or "") .. "\n所在分类：" .. entry.page,
                    onClick = function()
                        local idx = findTabIndex(entry.page)
                        if idx then mainWin:selectTab(idx) end
                    end,
                })
                yPos = yPos + CARD_H + CARD_GAP
            end
        end
    end)
end

for pageName, contentData in pairs(pageContents) do
    local idx = findTabIndex(pageName)
    if idx and mainWin.tabs[idx] then
        local page = mainWin.tabs[idx]
        if pageName == "公告" then
            buildAnnouncementPage(page)
        else
            local scroll = makeScrollFrame(page)
            local yPos = 8
            local items = contentData.items or {}
            for _, item in ipairs(items) do
                yPos = renderItem(scroll, item, contentData.type, yPos)
            end
        end
    end
end

do
    local settingsIdx = findTabIndex("设置")
    if settingsIdx and mainWin.tabs[settingsIdx] then
        local page = mainWin.tabs[settingsIdx]
        local scroll = makeScrollFrame(page)
        local yPos = 8

        do
            local colorNames = {"金色", "红色", "蓝色", "绿色", "紫色", "粉色", "青色", "白色"}
            local colorValues = {
                Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(200, 0, 255), Color3.fromRGB(255, 100, 200),
                Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255),
            }
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, 100)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local cst = Instance.new("UIStroke", card); cst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 6, w = CW - 20, h = 16,
                text = "🎨  边框颜色", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 24, w = CW - 40, h = 14,
                text = "点击色块切换面板边框颜色", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createColorPicker({
                parent = card, x = 15, y = 44,
                size = 22, gap = 6, cols = 8, value = 1,
                palette = colorValues, names = colorNames,
                onChange = function(col, idx, name)
                    if mainWin.panelStroke then
                        mainWin.panelStroke.Color = col
                    end
                end,
            })
            yPos = yPos + 100 + CARD_GAP
        end

        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, 94)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local sst = Instance.new("UIStroke", card); sst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 6, w = CW - 20, h = 16,
                text = "面板尺寸与缩放", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 10, y = 26, w = 130, h = 14,
                text = "调整整体 UI 大小", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createButton({
                parent = card, x = 142, y = 22, w = 42, h = 28,
                text = "−", textSize = 16,
                tooltip = "缩小界面",
                onClick = function()
                    local current = tonumber(_genv.__XixiScaleMultiplier) or 1
                    if _genv.__XixiApplyScale then _genv.__XixiApplyScale(current - 0.05) end
                end,
            })
            ui.createButton({
                parent = card, x = 188, y = 22, w = 42, h = 28,
                text = "+", textSize = 16,
                tooltip = "放大界面",
                onClick = function()
                    local current = tonumber(_genv.__XixiScaleMultiplier) or 1
                    if _genv.__XixiApplyScale then _genv.__XixiApplyScale(current + 0.05) end
                end,
            })
            ui.createButton({
                parent = card, x = 234, y = 22, w = 56, h = 28,
                text = "重置", textSize = 10,
                tooltip = "恢复自动缩放",
                onClick = function() if _genv.__XixiApplyScale then _genv.__XixiApplyScale(1) end end,
            })
            ui.createButton({
                parent = card, x = CW - 150, y = 58, w = 66, h = 28,
                text = "平板", textSize = 10,
                tooltip = "切换到平板尺寸",
                onClick = function() mainWin:setSize(580, 440) end,
            })
            ui.createButton({
                parent = card, x = CW - 78, y = 58, w = 66, h = 28,
                text = "手机", textSize = 10,
                tooltip = "切换到手机尺寸",
                onClick = function() mainWin:setSize(500, 340) end,
            })
            yPos = yPos + 94 + CARD_GAP
        end

        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, CARD_H)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local ast = Instance.new("UIStroke", card); ast.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 5, w = CW - 60, h = 16,
                text = "👑  透视作者（大肥鱼）", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 22, w = CW - 80, h = 14,
                text = "开启或关闭作者 ESP 高亮", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createToggle({
                parent = card, x = CW - 46, y = 11, w = 36, h = 20,
                value = authorEspEnabled,
                onChange = function(v)
                    if v then enableAuthorESP() else disableAuthorESP() end
                end,
            })
            attachTooltip(card, "透视作者（大肥鱼）\n开启后金色高亮作者")
            yPos = yPos + CARD_H + CARD_GAP
        end

        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, CARD_H)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local fst = Instance.new("UIStroke", card); fst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 5, w = CW - 60, h = 16,
                text = "⭐  收藏模式", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 22, w = CW - 80, h = 14,
                text = "开启后卡片右上角显示收藏星标", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createToggle({
                parent = card, x = CW - 46, y = 11, w = 36, h = 20,
                value = false,
                onChange = function(v)
                    ui.setFavoriteMode(v)
                end,
            })
            attachTooltip(card, "收藏模式\n开启后在每个功能卡片右上角显示星标，点击即可收藏")
            yPos = yPos + CARD_H + CARD_GAP
        end
    end
end

task.delay(0.5, function()
    ui.notify({
        type = "success",
        title = "熙熙·融合版",
        message = "脚本执行成功",
        duration = 4,
    })
end)

print("[熙熙·融合版 V2.0] 已加载")


local function XixiSelfCheck()
    local problems = {}
    if type(ui) ~= "table" then table.insert(problems, "LUMEN UI 未初始化") end
    if not mainWin or not mainWin.frame then table.insert(problems, "主窗口未创建") end
    if type(XixiHost.Modules) ~= "table" then table.insert(problems, "模块注册表异常") end
    if type(pageContents["爱国者"]) ~= "table" then table.insert(problems, "爱国者页面缺失") end
    if type(pageContents["BS模块"]) ~= "table" then table.insert(problems, "BS模块页面缺失") end
    if #problems > 0 then
        warn("[熙熙] 自检发现: " .. table.concat(problems, "；"))
        return false, problems
    end
    print("[熙熙] 自检通过 | UI=OK | 模块=" .. tostring(#XixiPatriotScripts + #XixiBSModules) .. " | 远程保护=OK")
    return true, problems
end
XixiSelfCheck()
    end)
    if not __ok then __XixiRoot.__XixiMegaBundleRunning = nil; warn("熙熙主界面模块启动失败: " .. tostring(__err)) end
end)
__XixiBundleTasks[2] = task.spawn(function()
    task.wait(1)
    local __ok, __err = pcall(function()
local XixiRemote = {}
function XixiRemote.get(parent, name, className, timeout)
    if not parent or not name then return nil end
    local obj = parent:FindFirstChild(name)
    if not obj and timeout and timeout > 0 then
        local ok, result = pcall(function() return parent:WaitForChild(name, timeout) end)
        if ok then obj = result end
    end
    if obj and (not className or obj:IsA(className)) then return obj end
    return nil
end
function XixiRemote.fire(remote, ...)
    if not remote or not remote:IsA("RemoteEvent") then return false, "RemoteEvent unavailable" end
    return pcall(function(...) remote:FireServer(...) end, ...)
end
function XixiRemote.invoke(remote, ...)
    if not remote or not remote:IsA("RemoteFunction") then return false, nil, "RemoteFunction unavailable" end
    local ok, result = pcall(function(...) return remote:InvokeServer(...) end, ...)
    return ok, result
end
function XixiRemote.exists(remote, className)
    return remote ~= nil and (not className or remote:IsA(className))
end


local function XixiRemoteSelfCheck()
    local ev = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
    if not ev then warn("[熙熙] Remote检查：ReplicatedStorage.Events 不存在，部分功能会自动跳过。") return end
    local names = {"PIC_PU","PIC_TLO","CZDPZUS","XMHH.2","XMHH2.2","GNX_S","GNX_R"}
    local missing = {}
    for _, n in ipairs(names) do if not ev:FindFirstChild(n) then missing[#missing+1] = n end end
    if #missing > 0 then warn("[熙熙] Remote检查：缺失 " .. table.concat(missing, ", ")) end
end
task.defer(XixiRemoteSelfCheck)


_G.NotifySystem = {
    Queue = {},


    Ready = false,
    Container = nil,
    ActiveNotifications = {},
    MaxNotifications = 5,
    DefaultDuration = 4,
    TweenSpeed = 0.35,
    Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        BackgroundAccent = Color3.fromRGB(28, 28, 35),
        Stroke = Color3.fromRGB(60, 60, 75),
        Title = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(80, 220, 120),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 190, 70),
        Info = Color3.fromRGB(88, 160, 255),
        ProgressBg = Color3.fromRGB(40, 40, 50)
    },
    Icons = {
        Success = "rbxassetid://93202927221730",
        Error = "rbxassetid://76821953846248",
        Warning = "rbxassetid://125920361880643",
        Info = "rbxassetid://124560466474914",
        Close = "rbxassetid://110786993356448",
    }
}

function _G.Notify(title, text, duration, nType)
    duration = duration or _G.NotifySystem.DefaultDuration
    title = title or "通知"
    text = text or ""
    nType = nType or "Info"
    
    if not _G.NotifySystem.Ready then
        table.insert(_G.NotifySystem.Queue, {title, text, duration, nType})
        return
    end
    
    pcall(function()
        _G.NotifySystem.CreateNotification(title, text, duration, nType)
    end)
end

function _G.NotifySuccess(title, text, duration)
    _G.Notify(title, text, duration or 3, "Success")
end

function _G.NotifyError(title, text, duration)
    _G.Notify(title, text, duration or 5, "Error")
end

function _G.NotifyWarning(title, text, duration)
    _G.Notify(title, text, duration or 4, "Warning")
end

function _G.NotifyInfo(title, text, duration)
    _G.Notify(title, text, duration or 4, "Info")
end

function _G.NotifySystem.CreateNotification(title, text, duration, nType)
    local TweenService = game:GetService("TweenService")
    
    if not _G.NotifySystem.Container or not _G.NotifySystem.Container.Parent then
        _G.NotifySystem.SetupContainer()
    end
    
    local container = _G.NotifySystem.Container
    local theme = _G.NotifySystem.Theme
    local typeColor = theme[nType] or theme.Info
    local iconId = _G.NotifySystem.Icons[nType] or _G.NotifySystem.Icons.Info
    
    while #_G.NotifySystem.ActiveNotifications >= _G.NotifySystem.MaxNotifications do
        local oldest = _G.NotifySystem.ActiveNotifications[1]
        if oldest then
            oldest:Close()
        end
        task.wait(0.05)
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.ClipsDescendants = true
    
    local mainBg = Instance.new("Frame")
    mainBg.Name = "MainBg"
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.BackgroundColor3 = theme.Background
    mainBg.BackgroundTransparency = 0.02
    mainBg.BorderSizePixel = 0
    mainBg.Parent = frame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainBg
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Stroke
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = mainBg
    
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.Size = UDim2.new(0, 3, 1, -16)
    accentLine.Position = UDim2.new(0, 8, 0, 8)
    accentLine.BackgroundColor3 = typeColor
    accentLine.BorderSizePixel = 0
    accentLine.Parent = mainBg
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentLine
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 20, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = typeColor
    icon.Parent = mainBg
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -90, 0, 22)
    titleLabel.Position = UDim2.new(0, 46, 0, 11)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = mainBg
    
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = _G.NotifySystem.Icons.Close
    closeBtn.ImageColor3 = Color3.fromRGB(140, 140, 150)
    closeBtn.ImageTransparency = 0.3
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = mainBg
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Content"
    textLabel.Size = UDim2.new(1, -66, 0, 0)
    textLabel.Position = UDim2.new(0, 46, 0, 36)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = theme.Text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 13
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.Parent = mainBg
    
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBg"
    progressBg.Size = UDim2.new(1, -16, 0, 3)
    progressBg.Position = UDim2.new(0, 8, 1, -9)
    progressBg.BackgroundColor3 = theme.ProgressBg
    progressBg.BorderSizePixel = 0
    progressBg.Parent = mainBg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = typeColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = progressBar
    
    frame.Parent = container
    
    task.wait()
    local textHeight = textLabel.TextBounds.Y
    local titleWidth = titleLabel.TextBounds.X
    local textWidth = textLabel.TextBounds.X
    local width = math.clamp(math.max(titleWidth + 100, textWidth + 70), 280, 400)
    local height = math.max(78, 52 + textHeight)
    
    local notification = {
        Frame = frame,
        MainBg = mainBg,
        ProgressBar = progressBar,
        Duration = duration,
        Remaining = duration,
        Paused = false,
        Closed = false,
        Close = function(self)
            if self.Closed then return end
            self.Closed = true
            self:AnimateOut()
        end,
        AnimateOut = function(self)
            for i, n in ipairs(_G.NotifySystem.ActiveNotifications) do
                if n == self then
                    table.remove(_G.NotifySystem.ActiveNotifications, i)
                    break
                end
            end
            TweenService:Create(self.MainBg, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(self.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, height),
                Position = UDim2.new(0, 0, 0, self.Frame.AbsolutePosition.Y - container.AbsolutePosition.Y)
            }):Play()
            task.delay(0.3, function()
                self.Frame:Destroy()
            end)
        end
    }
    
    table.insert(_G.NotifySystem.ActiveNotifications, notification)
    
    frame.Size = UDim2.new(0, width, 0, 0)
    
    TweenService:Create(frame, TweenInfo.new(_G.NotifySystem.TweenSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, width, 0, height)
    }):Play()
    
    local enterTween = TweenService:Create(mainBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.02
    })
    enterTween:Play()
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(255, 90, 90)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageTransparency = 0.3, ImageColor3 = Color3.fromRGB(140, 140, 150)}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        notification:Close()
    end)
    
    mainBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            notification.Paused = true
            TweenService:Create(mainBg, TweenInfo.new(0.2), {BackgroundColor3 = theme.BackgroundAccent}):Play()
        end
    end)
    
    mainBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            notification.Paused = false
            TweenService:Create(mainBg, TweenInfo.new(0.2), {BackgroundColor3 = theme.Background}):Play()
        end
    end)
    
    task.spawn(function()
        local startTime = tick()
        while notification.Remaining > 0 and not notification.Closed do
            if not notification.Paused then
                notification.Remaining = duration - (tick() - startTime)
                local progress = math.clamp(notification.Remaining / duration, 0, 1)
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
            else
                startTime = tick() - (duration - notification.Remaining)
            end
            task.wait(0.03)
        end
        if not notification.Closed then
            notification:Close()
        end
    end)
end

function _G.NotifySystem.SetupContainer()
    local Players = game:GetService("Players")


    local CoreGui = game:GetService("CoreGui")
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotifySystem_" .. math.random(10000, 99999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    
    pcall(function()
        gui.Parent = CoreGui
    end)
    
    if not gui.Parent and Players.LocalPlayer then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 420, 1, -30)
    container.Position = UDim2.new(1, -15, 0, 15)
    container.AnchorPoint = Vector2.new(1, 0)
    container.BackgroundTransparency = 1
    container.Parent = gui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 12)
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = container
    
    _G.NotifySystem.Container = container
    _G.NotifySystem.Ready = true
    _G.NotifySystem.ProcessQueue()
end

function _G.NotifySystem.ProcessQueue()
    if #_G.NotifySystem.Queue == 0 then return end
    
    local queue = table.clone(_G.NotifySystem.Queue)
    _G.NotifySystem.Queue = {}
    
    for i, data in ipairs(queue) do
        task.delay((i-1) * 0.15, function()
            _G.Notify(unpack(data))
        end)
    end
end

_G.Library = _G.Library or {}
_G.Library.Notification = function(...)
    if _G.Notify then
        _G.Notify(...)
    end
end

function _G.SafeNotify(...)
    if not _G.NotifySystem.Ready then
        _G.NotifySystem.SetupContainer()
    end
    _G.Notify(...)
end

task.delay(0.05, function()
    _G.NotifySystem.SetupContainer()
end)
do
if game.PlaceId == 4588604953 then
do

end
local WindUI = loadstring(__XixiRemoteFetch("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local camera = workspace.CurrentCamera
local tween = game:GetService("TweenService")
local light = game:GetService("Lighting")
local rp = game:GetService("ReplicatedStorage")

local functions = {
    Fullbright = false,
    AutoOpenDoors = false,
    NoBarriers = false,
    NoGrinder = false,
    FastPickup = false,
    AutoPickupScraps = false,
    AutoPickupTools = false,
    AutopickupCrates = false,
    AutoPickupMoney = false,
    Infstamina = false,
    Nofalldamage = false,
    Noclip = false,
    FakeDown = true,
    Stopneckmove = false,
    Unbreaklimbs = false,
    SilentAim = false,
    AimBot = false,
    Instantreload = false,
    Meleeaura = false,
    RageBot = false,
    TrigerBot = false,
    RocketControl = false,
    ESP = false,
    ArmsChams = false,
    ToolsChams = false,
}

local SectionSettings = {
    SilentAim = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
    },
    Aimbot = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Velocity = false,
        Smooth = false,
        SmoothSize = 0.5
    },
    MeleeAura = {
        ShowAnim = false,
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Distance = 15,
    },
    RageBot = {
        CheckDowned = false,
        CheckWhiteList = false
    },
    ESP = {
        Name = false,
        Box = false,
        Weapon = false,
        Highlight = false,
    }
}

local Methods = {
    Fly = "Bypass",
    Infstamina = "Getgc"
}

local cockie = {
    SilentAimCircle = nil,
    SilentAim_body = nil,
    ESPHighlight = nil,
    AimBotCircle = nil,
    aimbot_button = nil,
    Aimbot_body = nil,
    MeleeAura_body = nil,
}

local RUNS = {
    cameraFOV = nil,
    JumpHeight = nil,
    AutoOpenDoors = nil,
    AutopickupScraps = nil,
    AutopickupTools = nil,
    AutopickupCrates = nil,
    AutopickupMoney = nil,
    Infstamina = nil,
    Fly = nil,
    Noclip = nil,
    Meleeaura = nil,
    ESP = nil,
}

local funcindex = {
    Fullbright = {
        oldClockTime = nil,
        oldBrightness = nil,
    }
}

local WhiteList = {}

function CharStats(plr)
    local folder = rp.CharStats[plr.Name]
    return folder
end

local Window = WindUI:CreateWindow({
    Title = "犯罪",
    Author = "BS脚本",
    Icon = "atom",
    IconThemed = false,
    Background = "rbxassetid://102621341311637",
    BackgroundImageTransparency = 0.6,
    Acrylic = true,
    Transparent = true,
    ShadowTransparency = 0.65,
    Radius = 22,
    Size = UDim2.new(0, 720, 0, 540),
    MinSize = Vector2.new(600, 450),
    MaxSize = Vector2.new(900, 650),
    ScrollBarEnabled = true,
    Resizable = true,
    AutoScale = true,
    Folder = "服务器",
})

local Tabs = {
    World = Window:Tab({ Title = "世界功能", Icon = "globe", Locked = false }),
    Player = Window:Tab({ Title = "玩家功能", Icon = "user", Locked = false }),
    Combat = Window:Tab({ Title = "战斗功能", Icon = "target", Locked = false }),
    Visual = Window:Tab({ Title = "视觉功能", Icon = "eye", Locked = false }),
    Misc = Window:Tab({ Title = "其他功能", Icon = "settings", Locked = false })
}

Tabs.World:Toggle({
    Title = "夜视",
    Description = "使地图变亮",
    Default = functions.Fullbright,
    Callback = function(Value)
        functions.Fullbright = Value
        local Folder
        if Value then
            if #light:GetChildren() ~= 0 then
                Folder = Instance.new("Folder")
                Folder.Parent = rp
                Folder.Name = "Index"
                for _, a in pairs(light:GetChildren()) do
                    a.Parent = Folder
                end
            end
            funcindex.Fullbright.oldClockTime = light.ClockTime
            light.ClockTime = 14
            funcindex.Fullbright.oldBrightness = light.Brightness
            light.Brightness = 4
            light.ExposureCompensation = .7
        else
            Folder = rp:FindFirstChild("Index")
            if Folder ~= nil then
                for _, a in pairs(Folder:GetChildren()) do
                    a.Parent = light
                end
                Folder:Destroy()
                Folder = nil
            end
            light.ClockTime = funcindex.Fullbright.oldClockTime or 14
            light.Brightness = funcindex.Fullbright.oldBrightness or 1
            light.ExposureCompensation = 0
        end
    end
})

Tabs.World:Toggle({
    Title = "自动开门",
    Description = "自动打开附近的门",
    Default = functions.AutoOpenDoors,
    Callback = function(Value)
        functions.AutoOpenDoors = Value
        if Value then
            RUNS.AutoOpenDoors = run.RenderStepped:Connect(function()
                local function GetDoor()
                    local mapFolder = workspace:FindFirstChild("Map")
                    if not mapFolder then return nil end
                    local folderDoors = mapFolder:FindFirstChild("Doors")
                    if not folderDoors then return nil end

                    local closestDoor, dist = nil, 15
                    for _, door in pairs(folderDoors:GetChildren()) do
                        local doorBase = door:FindFirstChild("DoorBase")
                        if doorBase and me.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (me.Character.HumanoidRootPart.Position - doorBase.Position).Magnitude
                            if distance < dist then
                                dist = distance
                                closestDoor = door
                            end
                        end
                    end
                    return closestDoor
                end

                local door = GetDoor()
                if door then
                    local values = door:FindFirstChild("Values")
                    local events = door:FindFirstChild("Events")
                    if values and events then
                        local locked = values:FindFirstChild("Locked")
                        local openValue = values:FindFirstChild("Open")
                        local toggleEvent = events:FindFirstChild("Toggle")
                        if locked and openValue and toggleEvent then
                            if locked.Value == true then
                                toggleEvent:FireServer("Unlock", door.Lock)
                            elseif locked.Value == false and openValue.Value == false then
                                local knob1 = door:FindFirstChild("Knob1")
                                local knob2 = door:FindFirstChild("Knob2")
                                if knob1 and knob2 then
                                    local knob1pos = (me.Character.HumanoidRootPart.Position - knob1.Position).Magnitude
                                    local knob2pos = (me.Character.HumanoidRootPart.Position - knob2.Position).Magnitude
                                    local chosenKnob = (knob1pos < knob2pos) and knob1 or knob2
                                    toggleEvent:FireServer("Open", chosenKnob)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.AutoOpenDoors then
                RUNS.AutoOpenDoors:Disconnect()
                RUNS.AutoOpenDoors = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "无屏障",
    Description = "移除地图屏障",
    Default = functions.NoBarriers,
    Callback = function(Value)
        functions.NoBarriers = Value
        for _, a in pairs(workspace.Filter.Parts["F_Parts"]:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "防研磨机",
    Description = "防止研磨机伤害",
    Default = functions.NoGrinder,
    Callback = function(Value)
        functions.NoGrinder = Value
        for _, a in pairs(workspace.Map.Parts.Grinders:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
        for _, a in pairs(workspace.Map.Parts.M_Parts:GetDescendants()) do
            if a:IsA("Part") and a.Name == "FirePart" then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "快速拾取",
    Description = "瞬间拾取物品",
    Default = functions.FastPickup,
    Callback = function(Value)
        functions.FastPickup = Value
        if Value then
            game.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                        if functions.FastPickup then
                            obj.HoldDuration = 0
                        end
                    end)
                end
            end)
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取废料",
    Description = "自动拾取附近的废料",
    Default = functions.AutoPickupScraps,
    Callback = function(Value)
        functions.AutoPickupScraps = Value
        local remote = rp.Events.PIC_PU
        local scrapsfolder = workspace.Filter.SpawnedPiles
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupScraps = run.RenderStepped:Connect(function()
                local function GetClosestScrap()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(scrapsfolder:GetChildren()) do
                        if a and (a.Name == "S1" or a.Name == "S2") then
                            if me.Character and me.Character.HumanoidRootPart then
                                local getdist = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
                                if getdist < maxdist then
                                    maxdist = getdist
                                    closest = a
                                end
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local getscrap = GetClosestScrap()
                if getscrap then
                    if canPickup then
                        XixiRemote.fire(remote, string.reverse(getscrap:GetAttribute("jzu")))
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 4.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupScraps then
                RUNS.AutopickupScraps:Disconnect()
                RUNS.AutopickupScraps = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取工具",
    Description = "自动拾取附近的工具",
    Default = functions.AutoPickupTools,
    Callback = function(Value)
        functions.AutoPickupTools = Value
        local remote = rp.Events.PIC_TLO
        local toolsfolder = workspace.Filter.SpawnedTools
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupTools = run.RenderStepped:Connect(function()
                local function GetClosestTool()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(toolsfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local handle = a:FindFirstChild("Handle") or a:FindFirstChild("WeaponHandle")
                            if handle and (handle:IsA("Part") or handle:IsA("MeshPart")) then
                                if me.Character and me.Character:FindFirstChild("HumanoidRootPart") then
                                    local getdist = (me.Character.HumanoidRootPart.Position - handle.Position).Magnitude
                                    if getdist < maxdist then
                                        maxdist = getdist
                                        closest = a
                                    end
                                end
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local tool = GetClosestTool()
                if tool then
                    local Handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("WeaponHandle")
                    if Handle then
                        if canPickup then
                            XixiRemote.fire(remote, Handle)
                            canPickup = false
                        end
                    end
                end
                if canPickup == false and tick() - startTick >= 1.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupTools then
                RUNS.AutopickupTools:Disconnect()
                RUNS.AutopickupTools = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取金钱",
    Description = "自动拾取附近的金钱",
    Default = functions.AutoPickupMoney,
    Callback = function(Value)
        functions.AutoPickupMoney = Value
        local remote = rp.Events:FindFirstChild("CZDPZUS")
        local moneyfolder = workspace.Filter.SpawnedBread
        local canPickup = true
        local startTick = tick()

        if Value then
            RUNS.AutopickupMoney = run.RenderStepped:Connect(function()
                local function GetMoney()
                    local maxdist = 15
                    local closest = nil

                    for _, a in pairs(moneyfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local getdist = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
                            if getdist < maxdist then
                                maxdist = getdist
                                closest = a
                            end
                        end
                    end
                    maxdist = 15
                    return closest
                end

                local foundmoney = GetMoney()
                if foundmoney then
                    if canPickup then
                        XixiRemote.fire(remote, foundmoney)
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 1 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupMoney then
                RUNS.AutopickupMoney:Disconnect()
                RUNS.AutopickupMoney = nil
            end
        end
    end
})

Tabs.Player:Slider({
    Title = "FOV",
    Description = "调整相机视野",
    Default = camera.FieldOfView,
    Min = 70,
    Max = 120,
    Callback = function(Value)
        if RUNS.cameraFOV ~= nil then
            RUNS.cameraFOV:Disconnect()
            RUNS.cameraFOV = nil
        end
        RUNS.cameraFOV = run.RenderStepped:Connect(function()
            camera.FieldOfView = Value
        end)
    end
})

Tabs.Player:Slider({
    Title = "相机距离",
    Description = "调整相机最大距离",
    Default = me.CameraMaxZoomDistance,
    Min = 10,
    Max = 500,
    Callback = function(Value)
        me.CameraMaxZoomDistance = Value
    end
})

Tabs.Player:Slider({
    Title = "跳跃高度",
    Description = "调整跳跃高度",
    Default = 7.1,
    Min = 7.1,
    Max = 25,
    Callback = function(Value)
        if RUNS.JumpHeight then
            RUNS.JumpHeight:Disconnect()
            RUNS.JumpHeight = nil
        end
        RUNS.JumpHeight = run.RenderStepped:Connect(function()
            if me.Character and me.Character:FindFirstChild("Humanoid") then
                me.Character:FindFirstChild("Humanoid").UseJumpPower = false
                me.Character:FindFirstChild("Humanoid").JumpHeight = Value
            end
        end)
    end
})

Tabs.Player:Slider({
    Title = "重力",
    Description = "调整世界重力",
    Default = workspace.Gravity,
    Min = workspace.Gravity,
    Max = 75,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

Tabs.Player:Toggle({
    Title = "无限体力",
    Description = "拥有无限体力",
    Default = functions.Infstamina,
    Callback = function(Value)
        functions.Infstamina = Value
        if Value then
            while functions.Infstamina do
                if Methods.Infstamina == "Getgc" then
                    local stamina = {}
                    function get()
                        for index, value in pairs(getgc(true)) do
                            if type(value) == "table" and rawget(value, "S") then
                                stamina[#stamina + 1] = value
                            end
                        end
                    end
                    local ss, nn = pcall(function()
                        get()
                    end)
                    if ss then
                        for _, a in pairs(stamina) do
                            a.S = 100
                        end
                    end
                elseif Methods.Infstamina == "low exploit" then
                    if me.Character then
                        local hum = me.Character:FindFirstChild("Humanoid")
                        if hum and not hum:GetAttribute("ZSPRN_M") then
                            hum:SetAttribute("ZSPRN_M", true)
                        end
                    end
                    me.CharacterAdded:Connect(function(char)
                        if functions.Infstamina then
                            if char and char:WaitForChild("Humanoid") then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum and not hum:GetAttribute("ZSPRN_M") then
                                    hum:SetAttribute("ZSPRN_M", true)
                                end
                            end
                        end
                    end)
                end
                run.RenderStepped:Wait()
            end
        else
            if me.Character then
                local hum = me.Character:FindFirstChild("Humanoid")
                if hum then
                    local check = hum:GetAttribute("ZSPRN_M")
                    if check then
                        hum:SetAttribute("ZSPRN_M", nil)
                    end
                end
            end
        end
    end
})

Tabs.Player:Dropdown({
    Title = "无限体力方法",
    Description = "选择实现方法",
    Options = {"Getgc", "low exploit"},
    Default = Methods.Infstamina,
    Callback = function(Value)
        Methods.Infstamina = Value
    end
})

Tabs.Player:Toggle({
    Title = "无坠落伤害",
    Description = "防止坠落伤害",
    Default = functions.Nofalldamage,
    Callback = function(Value)
        functions.Nofalldamage = Value
        if Value then
            if me.Character then
                local ff = Instance.new("ForceField")
                ff.Parent = me.Character
                ff.Visible = false
            end
            me.CharacterAdded:Connect(function(char)
                if functions.Nofalldamage and char and char:WaitForChild("HumanoidRootPart") and char:WaitForChild("Humanoid") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                    ff.Visible = false
                end
            end)
        else
            if me.Character then
                for _, a in pairs(me.Character:GetChildren()) do
                    if a:IsA("ForceField") and a.Visible == false then
                        a:Destroy()
                    end
                end
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "穿墙模式",
    Description = "可以穿过墙壁",
    Default = functions.Noclip,
    Callback = function(Value)
        functions.Noclip = Value
        if Value then
            local function LoopNoclip()
                local char = me.Character
                if char then
                    for _, a in pairs(char:GetDescendants()) do
                        if a:IsA("BasePart") and a.CanCollide == true then
                            a.CanCollide = false
                        end
                    end
                end
            end

            RUNS.Noclip = run.RenderStepped:Connect(LoopNoclip)
        else
            if RUNS.Noclip then
                RUNS.Noclip:Disconnect()
                RUNS.Noclip = nil
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "伪装倒地",
    Description = "伪装成倒地状态",
    Default = functions.FakeDown,
    Callback = function(Value)
        functions.FakeDown = Value
        if Value then
            local getvalue = CharStats(me).Downed
            getvalue.Value = true
            getvalue:GetPropertyChangedSignal("Value"):Connect(function()
                if functions.FakeDown then
                    getvalue.Value = true
                end
            end)
        else
            CharStats(me).Downed.Value = false
        end
    end
})

Tabs.Player:Toggle({
    Title = "停止颈部移动",
    Description = "停止角色颈部移动",
    Default = functions.Stopneckmove,
    Callback = function(Value)
        functions.Stopneckmove = Value
        if Value then
            if me.Character then
                me.Character:SetAttribute("NoNeckMovement", true)
            end
            me.CharacterAdded:Connect(function(char)
                if char and char:FindFirstChild("Humanoid") then
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                else
                    repeat wait() until char and char:FindFirstChild("Humanoid")
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                end
            end)
        else
            if me.Character then
                local get = me.Character:GetAttribute("NoNeckMovement")
                if get then
                    me.Character:SetAttribute("NoNeckMovement", nil)
                end
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "肢体不碎",
    Description = "防止肢体断裂",
    Default = functions.Unbreaklimbs,
    Callback = function(Value)
        functions.Unbreaklimbs = Value
        local limbsfolder = CharStats(me).HealthValues
        for _, a in pairs(limbsfolder:GetChildren()) do
            for _, i in pairs(a:GetChildren()) do
                if i and i.Name == "Broken" then
                    if functions.Unbreaklimbs then
                        i.Value = false
                        i:GetPropertyChangedSignal("Value"):Connect(function()
                            if functions.Unbreaklimbs then
                                i.Value = false
                            end
                        end)
                    end
                end
            end
        end
        limbsfolder.ChildAdded:Connect(function()
            for _, a in pairs(limbsfolder:GetChildren()) do
                for _, i in pairs(a:GetChildren()) do
                    if i and i.Name == "Broken" then
                        if functions.Unbreaklimbs then
                            i.Value = false
                            i:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Unbreaklimbs then
                                    i.Value = false
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Combat:Toggle({
    Title = "静默瞄准",
    Description = "自动瞄准敌人",
    Default = functions.SilentAim,
    Callback = function(Value)
        functions.SilentAim = Value
        if Value then
            cockie.SilentAimCircle = Drawing.new("Circle")
            cockie.SilentAimCircle.Color = Color3.new(1, 1, 1)
            cockie.SilentAimCircle.Thickness = 2
            cockie.SilentAimCircle.NumSides = 50
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
            cockie.SilentAimCircle.Filled = false
            cockie.SilentAimCircle.Visible = true

            cockie.SilentAimCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

            local target = nil

            local function GetClosest()
                target = nil
                local shortest = SectionSettings.SilentAim.DrawSize
                for _, a in pairs(plrs:GetPlayers()) do
                    if a ~= me and a.Character then

                        if SectionSettings.SilentAim.CheckDowned and CharStats(a).Downed.Value == true then
                            continue
                        end

                        if SectionSettings.SilentAim.CheckTeam and a.Team == me.Team then
                            continue
                        end

                        if SectionSettings.SilentAim.CheckWhiteList and table.find(WhiteList, a) then
                            continue
                        end

                        local hrp = a.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local screenpos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                local dist = (Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2) - Vector2.new(screenpos.X, screenpos.Y)).Magnitude
                                if dist < shortest then
                                    target = a
                                end
                            end
                        end
                    end
                end
            end

            run.RenderStepped:Connect(GetClosest)

            local VisualizeEvent = rp.Events2.Visualize
            local DamageEvent = rp.Events["ZFKLF__H"]

            VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
                if not functions.SilentAim then return end
                if not Gun or not target or not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character:FindFirstChild("Humanoid").Health == 0 then return end
                if not me.Character or not me.Character:FindFirstChildOfClass("Tool") then return end

                local parts = SectionSettings.SilentAim.TargetParts[math.random(1, #SectionSettings.SilentAim.TargetParts)] or SectionSettings.SilentAim.TargetParts[1] or "Head"
                local targetPart = target.Character:FindFirstChild(parts)
                if not targetPart then return end

                local partPos = targetPart.Position
                local Bullets = {}
                for i = 1, math.clamp(#BulletsPerShot, 1, 100) do
                    table.insert(Bullets, CFrame.new(StartPos, partPos).LookVector)
                end
                task.wait(0.005)
                for i, dir in pairs(Bullets) do
                    DamageEvent:FireServer("🧈", Gun, ShotCode, i, targetPart, partPos, dir)
                end

                if Gun:FindFirstChild("Hitmarker") then
                    Gun.Hitmarker:Fire(targetPart)
                end
            end)
        else
            if cockie.SilentAimCircle then
                cockie.SilentAimCircle:Remove()
                cockie.SilentAimCircle = nil
            end
        end
    end
})

Tabs.Combat:Slider({
    Title = "静默瞄准范围",
    Description = "调整瞄准范围大小",
    Default = SectionSettings.SilentAim.DrawSize,
    Min = 20,
    Max = 500,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawSize = math.floor(Value)
        if cockie.SilentAimCircle then
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
        end
    end
})

Tabs.Combat:Toggle({
    Title = "检查倒地状态",
    Description = "忽略倒地的玩家",
    Default = SectionSettings.SilentAim.CheckDowned,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckDowned = Value
    end
})

Tabs.Combat:Toggle({
    Title = "检查队伍",
    Description = "忽略同队伍玩家",
    Default = SectionSettings.SilentAim.CheckTeam,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckTeam = Value
    end
})

Tabs.Combat:Toggle({
    Title = "自瞄",
    Description = "自动瞄准敌人",
    Default = functions.AimBot,
    Callback = function(Value)
        functions.AimBot = Value
        if Value == true then
            cockie.aimbot_button = Instance.new("TextButton")
            cockie.aimbot_button.Parent = game.CoreGui
            cockie.aimbot_button.Name = "Aim"
            cockie.aimbot_button.BackgroundColor3 = Color3.new(0, 0, 0)
            cockie.aimbot_button.Position = UDim2.new(0.689, 0, 0.521, 0)
            cockie.aimbot_button.Size = UDim2.new(0, 40, 0, 40)
            cockie.aimbot_button.TextSize = 10
            cockie.aimbot_button.TextColor3 = Color3.new(1, 1, 1)
            cockie.aimbot_button.Text = "Aim"
            cockie.aimbot_button.Visible = true

            local target = nil
            local pressed = false
            local aimtarget
            local canusing = false
            local FirstPerson = true
            local predict = 15

            local part
            local randpart = nil
            local LastTick = tick()

            cockie.AimBotCircle = Drawing.new("Circle")
            cockie.AimBotCircle.Color = Color3.new(1, 1, 1)
            cockie.AimBotCircle.Thickness = 2
            cockie.AimBotCircle.NumSides = 50
            cockie.AimBotCircle.Radius = SectionSettings.Aimbot.DrawSize
            cockie.AimBotCircle.Filled = false
            cockie.AimBotCircle.Visible = true

            local centerScreen = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
            cockie.AimBotCircle.Position = centerScreen

            local function getClosestTarget()
                local closest, closestDist = nil, SectionSettings.Aimbot.DrawSize
                for _, player in pairs(plrs:GetPlayers()) do
                    if player ~= me and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

                        local count = #SectionSettings.Aimbot.TargetParts

                        if count == 0 then
                            part = "Head"
                        elseif count == 1 then
                            part = SectionSettings.Aimbot.TargetParts[count]
                        elseif count > 1 then
                            if tick() - LastTick >= .5 then
                                local rand = math.random(1, count)
                                randpart = SectionSettings.Aimbot.TargetParts[rand]
                                LastTick = tick()
                            end
                            part = randpart or SectionSettings.Aimbot.TargetParts[1]
                        end

                        local pos, onScreen = camera:WorldToViewportPoint(player.Character:FindFirstChild(part).Position)
                        if onScreen then
                            if SectionSettings.Aimbot.CheckTeam and player.Team == me.Team then
                                continue
                            end
                            if SectionSettings.Aimbot.CheckWhiteList and table.find(WhiteList, player) then
                                continue
                            end

                            local centerScreen = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                            local distance = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                            if distance < closestDist then
                                closestDist = distance
                                closest = player
                            end
                        end
                    end
                end
                return closest
            end

            cockie.aimbot_button.MouseButton1Click:Connect(function()
                pressed = not pressed
                aimtarget = getClosestTarget() or nil
            end)

            run.RenderStepped:Connect(function()
                if FirstPerson then
                    local magnitude = (camera.Focus.p - camera.CFrame.p).Magnitude
                    canusing = magnitude <= 1.5
                end
                if functions.AimBot and pressed and aimtarget and aimtarget.Character then
                    local head = aimtarget.Character:FindFirstChild(part)
                    local humanoid = aimtarget.Character:FindFirstChild("Humanoid")
                    if head and humanoid and humanoid.Health ~= 0 and canusing then
                        local targetPosition = head.Position

                        if SectionSettings.Aimbot.CheckDowned and CharStats(target).Downed.Value == true then
                            return
                        end

                        if SectionSettings.Aimbot.Velocity then
                            targetPosition = targetPosition + head.Velocity / predict
                        end
                        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.p, targetPosition), 0.9)
                    end
                end
            end)

        else
            if cockie.AimBotCircle then 
                cockie.AimBotCircle:Remove() 
                cockie.AimBotCircle = nil
            end
            if cockie.aimbot_button then 
                cockie.aimbot_button:Destroy()
                cockie.aimbot_button = nil
            end
        end
    end
})

Tabs.Combat:Toggle({
    Title = "近战光环",
    Description = "自动攻击附近敌人",
    Default = functions.Meleeaura,
    Callback = function(Value)
        functions.Meleeaura = Value
        if Value then
            local remote1 = rp.Events["XMHH.2"]
            local remote2 = rp.Events["XMHH2.2"]

            local part
            local randpart = nil

            local LastTick = tick()
            local AttachTick = tick()

            local attach = false
            local attachcd = .1

            local AttachCD = {
                ["Fists"] = .05,
                ["Knuckledusters"] = .05,
                ["Nunchucks"] = 0.05,
                ["Shiv"] = .05,
                ["Bat"] = 1,
                ["Metal-Bat"] = 1,
                ["Chainsaw"] = 2.5,
                ["Balisong"] = .05,
                ["Rambo"] = .3,
                ["Shovel"] = 3,
                ["Sledgehammer"] = 2,
                ["Katana"] = .1,
                ["Wrench"] = .1,
                ["FireAxe"] = 2.6
            }

            local function Attack(target)
                if not (target and target:FindFirstChild("Head")) then return end

                local mychar = me.Character
                if not mychar then return end
                local TOOL = mychar:FindFirstChildOfClass("Tool")
                if not TOOL then return end
                local AnimFolder = TOOL:FindFirstChild("AnimsFolder")
                if not AnimFolder then return end
                local anim = AnimFolder:FindFirstChild("Slash1")
                if not anim then return end

                if tick() - AttachTick >= attachcd then
                    local okInvoke, result = XixiRemote.invoke(remote1, "🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)
                    if not okInvoke then return end

                    attachcd = AttachCD[TOOL.Name] or 1/2

                    if SectionSettings.MeleeAura.ShowAnim then
                        local load = me.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator"):LoadAnimation(anim)
                        load:Play()
                        load:AdjustSpeed(1.3)
                    end

                    task.wait(0.3 + math.random() * 0.2)

                    if TOOL then
                        local Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or me.Character:FindFirstChild("Right Arm")
                        local arg2 = {
                            "🍞",
                            tick(),
                            TOOL,
                            "2389ZFX34",
                            result,
                            true,
                            Handle,
                            target:FindFirstChild(part),
                            target,
                            me.Character.HumanoidRootPart.Position,
                            target:FindFirstChild(part).Position
                        }
                        if TOOL.Name == "Chainsaw" then
                            for i = 1, 15 do
                                XixiRemote.fire(remote2, unpack(arg2)) 
                            end
                        else
                            XixiRemote.fire(remote2, unpack(arg2))
                        end
                        AttachTick = tick()
                    else
                        return
                    end
                end
            end

            while functions.Meleeaura do
                local mychar = me.Character or me.CharacterAdded:Wait()
                if mychar then
                    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
                    if myhrp then
                        for _, a in ipairs(plrs:GetPlayers()) do
                            if a ~= me then
                                local char = a.Character
                                if char then
                                    local hrp = char:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local distance = (myhrp.Position - hrp.Position).Magnitude
                                        if distance < SectionSettings.MeleeAura.Distance and a.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 and not char:FindFirstChildOfClass("ForceField") then

                                            if SectionSettings.MeleeAura.CheckWhiteList and table.find(WhiteList, a) then
                                                continue
                                            end

                                            if SectionSettings.MeleeAura.CheckTeam and a.Team == me.Team then
                                                continue
                                            end

                                            if SectionSettings.MeleeAura.CheckDowned and CharStats(a).Downed.Value == true then
                                                continue
                                            end

                                            local count = #SectionSettings.MeleeAura.TargetParts

                                            if count == 0 then
                                                part = "Head"
                                            elseif count == 1 then
                                                part = SectionSettings.MeleeAura.TargetParts[#SectionSettings.MeleeAura.TargetParts]
                                            elseif count > 1 then
                                                if tick() - LastTick >= .2 then
                                                    local rand = math.random(1, count)
                                                    randpart = SectionSettings.MeleeAura.TargetParts[rand]
                                                    LastTick = tick()
                                                end
                                                part = randpart or SectionSettings.MeleeAura.TargetParts[1]
                                            end

                                            Attack(char)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                run.Heartbeat:Wait()
            end
        end
    end
})

Tabs.Combat:Toggle({
    Title = "显示动画",
    Description = "显示攻击动画",
    Default = SectionSettings.MeleeAura.ShowAnim,
    Callback = function(Value)
        SectionSettings.MeleeAura.ShowAnim = Value
    end
})

Tabs.Combat:Toggle({
    Title = "狂暴模式",
    Description = "自动射击附近敌人",
    Default = functions.RageBot,
    Callback = function(Value)
        functions.RageBot = Value
        if Value then
            local function RandomString(length)
                local res = ""
                for i = 1, length do
                    res = res .. string.char(math.random(97, 122))
                end
                return res
            end

            local function GetClosestEnemy()
                if not me.Character 
                    or not me.Character:FindFirstChild("HumanoidRootPart") 
                then return nil end

                local closestEnemy = nil
                local shortestDistance = 100

                for _, player in pairs(plrs:GetPlayers()) do
                    if player == me then continue end

                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if character 
                        and rootPart 
                        and humanoid 
                        and humanoid.Health > 15 
                        and not character:FindFirstChildOfClass("ForceField") 
                    then
                        if SectionSettings.RageBot.CheckWhiteList and table.find(WhiteList, player) then
                            continue
                        end

                        local distance = (rootPart.Position - me.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestEnemy = player
                        end
                    end
                end
                return closestEnemy
            end

            local function Shoot(target)
                if not target or not target.Character then return end

                local head = target.Character:FindFirstChild("Head")
                if not head then return end

                local tool = me.Character and me.Character:FindFirstChildOfClass("Tool")
                if not tool then return end

                local values = tool:FindFirstChild("Values")
                local hitMarker = tool:FindFirstChild("Hitmarker")
                if not values or not hitMarker then return end

                local ammo = values:FindFirstChild("SERVER_Ammo")
                local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
                if not ammo or not storedAmmo then return end

                local hitPosition = head.Position
                local hitDirection = (hitPosition - camera.CFrame.Position).unit
                local randomKey = RandomString(30) ..0

                if tool.Name == "Beretta" or tool.Name == "TEC-9" then
                    if ammo.Value > 0 then
                        rp.Events.GNX_S:FireServer(
                            tick(),
                            randomKey,
                            tool,
                            "FDS9I83",
                            camera.CFrame.Position,
                            {hitDirection},
                            false
                        )

                        task.delay(0.00001, function()
                            rp.Events["ZFKLF__H"]:FireServer(
                                "🧈",
                                tool,
                                randomKey,
                                1,
                                head,
                                hitPosition,
                                hitDirection
                            )

                            ammo.Value = math.max(ammo.Value - 1, 0)
                            hitMarker:Fire(head)
                            storedAmmo.Value = values:FindFirstChild("SERVER_StoredAmmo").Value
                            rp.Events.GNX_R:FireServer(tick(), "KLWE89U0", tool)
                        end)
                    end
                end
            end

            local function RageBotLoop()
                while functions.RageBot do
                    if me.Character and me.Character:FindFirstChildOfClass("Tool") then
                        local target = GetClosestEnemy()
                        if target then
                            Shoot(target)
                        end
                    end
                    run.RenderStepped:Wait()
                end
            end
            RageBotLoop()
        end
    end
})

Tabs.Combat:Toggle({
    Title = "瞬间换弹",
    Description = "瞬间完成换弹",
    Default = functions.Instantreload,
    Callback = function(Value)
        functions.Instantreload = Value
        local gunR_remote = XixiRemote.get(rp:FindFirstChild("Events"), "GNX_R", "RemoteEvent")
        if Value then
            local charme = me.Character
            if charme then
                local tool = charme:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("IsGun") then
                    local value = tool:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                    local value2 = tool:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                    value2:GetPropertyChangedSignal("Value"):Connect(function()
                        if functions.Instantreload then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end)
                    if value2.Value ~= 0 then
                        if functions.Instantreload then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end
                    value:GetPropertyChangedSignal("Value"):Connect(function()
                        if functions.Instantreload and value2.Value ~= 0 then
                            gunR_remote:FireServer(tick(), "KLWE89U0", tool);
                        end
                    end)
                else
                    charme.ChildAdded:Connect(function(obj)
                        if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
                            local value = obj:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                            local value2 = obj:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                            value2:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                            if value2.Value ~= 0 then
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end
                            value:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload and value2.Value ~= 0 then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                        end
                    end)
                end
                me.CharacterAdded:Connect(function(charr)
                    repeat wait() until charr and charr.Parent
                    charr.ChildAdded:Connect(function(obj)
                        if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
                            local value = obj:FindFirstChild("Values"):FindFirstChild("SERVER_Ammo")
                            local value2 = obj:FindFirstChild("Values"):FindFirstChild("SERVER_StoredAmmo")
                            value2:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                            if value2.Value ~= 0 then
                                if functions.Instantreload then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end
                            value:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Instantreload and value2.Value ~= 0 then
                                    gunR_remote:FireServer(tick(), "KLWE89U0", obj);
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end
})

Tabs.Visual:Toggle({
    Title = "ESP",
    Description = "显示玩家轮廓",
    Default = functions.ESP,
    Callback = function(Value)
        functions.ESP = Value
        if Value then
            RUNS.ESP = run.Heartbeat:Connect(function()
                if SectionSettings.ESP.Highlight then
                    local function Update()
                        for _, a in pairs(plrs:GetPlayers()) do
                            if a ~= me then
                                local char = a.Character
                                if char and not char:FindFirstChild("Highlight") then
                                    local hg = Instance.new("Highlight")
                                    hg.Parent = char
                                    hg.FillTransparency = 1
                                end
                            end
                        end
                    end
                    Update()

                    plrs.PlayerAdded:Connect(function(player)
                        if functions.ESP then
                            local char = player.Character or player.CharacterAdded:Wait()
                            if char and SectionSettings.ESP.Highlight and not char:FindFirstChild("Highlight") then
                                local hg = Instance.new("Highlight")
                                hg.Parent = char
                                hg.FillTransparency = 1
                            end
                        end
                    end)
                else
                    for _, a in pairs(plrs:GetPlayers()) do
                        if a ~= me then
                            local char = a.Character
                            if char then
                                local h = char:FindFirstChild("Highlight")
                                if h then h:Destroy() end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.ESP then
                RUNS.ESP:Disconnect()
                RUNS.ESP = nil
            end
            for _, a in pairs(plrs:GetPlayers()) do
                if a ~= me then
                    local char = a.Character
                    if char then
                        local h = char:FindFirstChild("Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    end
})

Tabs.Visual:Toggle({
    Title = "高亮显示",
    Description = "高亮显示其他玩家",
    Default = SectionSettings.ESP.Highlight,
    Callback = function(Value)
        SectionSettings.ESP.Highlight = Value
    end
})

Tabs.Visual:Toggle({
    Title = "手臂特效",
    Description = "改变手臂材质",
    Default = functions.ArmsChams,
    Callback = function(Value)
        functions.ArmsChams = Value
        local viewfolder = camera:WaitForChild("ViewModel")
        if Value == true then
            viewfolder["Left Arm"].Material = Enum.Material.ForceField
            viewfolder["Right Arm"].Material = Enum.Material.ForceField
        else
            viewfolder["Left Arm"].Material = Enum.Material.Plastic
            viewfolder["Right Arm"].Material = Enum.Material.Plastic
        end
        me.CharacterAdded:Connect(function(char)
            repeat wait() until char and char.Parent
            local viewfolder = camera:WaitForChild("ViewModel")
            if functions.ArmsChams == true then
                viewfolder["Left Arm"].Material = Enum.Material.ForceField
                viewfolder["Right Arm"].Material = Enum.Material.ForceField
            else
                viewfolder["Left Arm"].Material = Enum.Material.Plastic
                viewfolder["Right Arm"].Material = Enum.Material.Plastic
            end
        end)
    end
})

Tabs.Misc:Button({
    Title = "清理效果",
    Description = "清理所有视觉效果",
    Callback = function()
        if cockie.SilentAimCircle then
            cockie.SilentAimCircle:Remove()
            cockie.SilentAimCircle = nil
        end
        
        if cockie.AimBotCircle then
            cockie.AimBotCircle:Remove()
            cockie.AimBotCircle = nil
        end
        
        if cockie.aimbot_button then
            cockie.aimbot_button:Destroy()
            cockie.aimbot_button = nil
        end
        
        for _, player in pairs(plrs:GetPlayers()) do
            if player ~= me then
                local char = player.Character
                if char then
                    local h = char:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
        
        WindUI:Notify({
            Title = "清理完成",
            Content = "所有视觉效果已清理",
            Duration = 3
        })
    end
})

Tabs.Misc:Button({
    Title = "重置设置",
    Description = "重置所有功能设置",
    Callback = function()
        for key, _ in pairs(functions) do
            functions[key] = false
        end
        
        for key, connection in pairs(RUNS) do
            if connection then
                connection:Disconnect()
                RUNS[key] = nil
            end
        end
        
        WindUI:Notify({
            Title = "重置完成",
            Content = "所有设置已重置",
            Duration = 3
        })
    end
})
    return
end
task.wait(0.00000001)
if game.PlaceId == 136801880565837 then
do

end
    loadstring(__XixiRemoteFetch("https://api.junkie-development.de/api/v1/luascripts/public/613d779853d477b40af7c9cc8a517308e0003549f584ccf24bb792031b64cf59/download"))()
    return
end
task.wait(0.00000001)
if game.PlaceId == 5041144419 then
do

end
    loadstring(__XixiRemoteFetch("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/BOOSBS/refs/heads/main/SCP.txt"))()
    return
end
task.wait(0.00000001)
if game.PlaceId == 7239319209 then
do

end
    loadstring(__XixiRemoteFetch("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/BOOSBS/refs/heads/main/Ohio.txt"))()
    return
end
end
wait(0.001)
_G.CreateHeartbeatConnection = _G.CreateHeartbeatConnection or (function()
    local connectionPool = setmetatable({}, {__mode = "k"})
    
    local player = game.Players.LocalPlayer
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            warn("[工厂] 角色死亡，自动清理所有心跳连接...")
            for conn in pairs(connectionPool) do
                if conn.Connected then conn:Disconnect() end
            end
        end)
    end)
    
    if script then
        script.AncestryChanged:Connect(function()
            if not script.Parent then
                warn("[工厂] 脚本卸载，清理所有连接...")
                for conn in pairs(connectionPool) do
                    if conn.Connected then conn:Disconnect() end
                end
            end
        end)
    end
    
    return function(callback)
        local conn = game:GetService("RunService").Heartbeat:Connect(function()
            local success, err = pcall(callback)
            if not success then
                warn(string.format("[连接错误] %s", tostring(err)))
            end
        end)
        connectionPool[conn] = true
        return conn
    end
end)()
wait(0.001)
do

end
wait(0.001)
local RealStatistics = {
    backend = "google_forms",
    config = {
        google_forms = {
            form_id = "1FAIpQLSdPU2dA8An1WSOG8Ia0yfMgNsXJaQyYH58tr2v4ib5fPDVgyw",
            entry_fields = {
                message_choice = "entry.1121183035"
            }
        },
        webhook = {
            url = "https://webhook.site/bc035b23-ae82-4cd0-8ee5-7407040b1434"
        }
    }
}

function RealStatistics:Init(messageChoice)
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    if not game.Players.LocalPlayer then
        game.Players:WaitForChild("LocalPlayer")
    end
    
    local success = false
    
    if self.backend == "webhook" then
        success = self:SendWebhookData(messageChoice)
    elseif self.backend == "google_forms" then
        success = self:SendGoogleFormsData(messageChoice)
    end
    
    if success then
        self:ShowSuccessMessage()
    else
        self:ShowErrorMessage()
    end
end

function RealStatistics:SendWebhookData(messageChoice)
    local success, result = pcall(function()
        local payload = {
            event_type = "script_startup",
            user = {
                username = game.Players.LocalPlayer.Name,
                user_id = game.Players.LocalPlayer.UserId,
                display_name = game.Players.LocalPlayer.DisplayName
            },
            script = {
                name = "黑洞中心",
                version = "2.0"
            },
            game = {
                name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
                id = game.PlaceId
            },
            message_choice = messageChoice and "发送消息" or "不发送消息",
            timestamp = os.time(),
            date = os.date("%Y-%m-%d %H:%M:%S")
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(payload)
        local response = game:HttpPost(
            self.config.webhook.url,
            jsonData,
            Enum.HttpContentType.ApplicationJson,
            false
        )
        
        return true
    end)
    
    if not success then
        warn("Webhook 提交失败:", result)
    end
    
    return success
end

function RealStatistics:SendGoogleFormsData(messageChoice)
    local success, result = pcall(function()
        local formData = {
            [self.config.google_forms.entry_fields.message_choice] = messageChoice and "发送消息" or "不发送消息"
        }
        
        local params = {}
        for key, value in pairs(formData) do
            table.insert(params, key .. "=" .. game:GetService("HttpService"):UrlEncode(value))
        end
        
        local url = "https://docs.google.com/forms/d/e/" .. self.config.google_forms.form_id .. "/formResponse?" .. table.concat(params, "&")
        
        local response = __XixiRemoteFetch(url, true)
        
        return true
    end)
    
    if not success then
        warn("Google Forms 提交失败:", result)
        print("尝试回退到 Webhook...")
        success = self:SendWebhookData(messageChoice)
    end
    
    return success
end

function RealStatistics:ShowSuccessMessage()
    pcall(function()
        _G.NotifySuccess("已登记成功", "感谢您的使用！", 6)
    end)
end

function RealStatistics:ShowErrorMessage()
    print("统计系统: 记录失败（网络问题）")
end

local function createChoiceUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MessageChoiceUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "模式选择"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0.9, 0, 0, 40)
    message.Position = UDim2.new(0.05, 0, 0, 40)
    message.BackgroundTransparency = 1
    message.Text = "是否发送聊天消息?"
    message.TextColor3 = Color3.fromRGB(200, 200, 200)
    message.Font = Enum.Font.SourceSans
    message.TextSize = 16
    message.Parent = frame

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0, 40)
    buttonContainer.Position = UDim2.new(0.05, 0, 0, 90)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = frame

    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.45, 0, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    yesButton.Text = "发送"
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Font = Enum.Font.SourceSansBold
    yesButton.TextSize = 16
    yesButton.Parent = buttonContainer

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.45, 0, 1, 0)
    noButton.Position = UDim2.new(0.55, 0, 0, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    noButton.Text = "不发送"
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.Font = Enum.Font.SourceSansBold
    noButton.TextSize = 16
    noButton.Parent = buttonContainer

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = yesButton
    buttonCorner:Clone().Parent = noButton

    local function makeChoice(sendMessage)
        spawn(function()
            local success, err = pcall(function()
                RealStatistics:Init(sendMessage)
            end)
            
            if not success then
                warn("统计系统启动失败:", err)
            end
        end)
        
        if sendMessage then
            loadstring(__XixiRemoteFetch("https://pastebin.com/raw/DJ82LzhM"))()
        end
        
        screenGui:Destroy()
        
        _G.NotifySuccess("看到这个就代表可以用", "请耐心等待加载", 5)
    end

    yesButton.MouseButton1Click:Connect(function()
        makeChoice(true)
    end)

    noButton.MouseButton1Click:Connect(function()
        makeChoice(false)
    end)
end
wait(0.001)
createChoiceUI()
wait(0.001)
wait(0.001)
_G.HeadSize = 15          
_G.HitboxSize = 15       
_G.HeadLoop = nil         
_G.HitboxLoop = nil       
_G.HeadActive = false     
_G.HitboxActive = false  

local UISelector = {
    "灵动岛UI",
    "仿黑曜石UI",
    "仿AL UI",   
    "仿woofUI (存在显示Bug)",   
    "彩虹UI 2.0",
    "黑白UI",
    "ModernUI",
    "MiniUI",
    "MiniUI 灰",
    "redzUI",
    "NOTHINGUI",
    "流畅UI",
    "彩虹UI",
    "叶脚本UI",
    "皮脚本UI", 
    "皮脚本新UI", 
    "彩虹UI第二种"
}

local UIUrls = {
    ["灵动岛UI"]    = "https://gitee.com/BS_script/script/raw/master/Dynamic_Island",
    ["ModernUI"]   = "https://gitee.com/BS_script/script/raw/master/Modern",
    ["MiniUI"]       = "https://gitee.com/BS_script/script/raw/master/Mini",
    ["MiniUI 灰"]    = "https://gitee.com/BS_script/script/raw/master/Mini2",
    ["仿AL UI"]      = "https://gitee.com/BS_script/script/raw/master/AL",
    ["仿黑曜石UI"]   = "https://gitee.com/BS_script/script/raw/master/Obsidian",
    ["仿woofUI (存在显示Bug)"]   = "https://gitee.com/BS_script/script/raw/master/woof",
    ["NOTHINGUI"]  = "https://gitee.com/BS_script/script/raw/master/NOTHING",
    ["redzUI"]       = "https://gitee.com/BS_script/script/raw/master/redz",
    ["流畅UI"]       = "https://gitee.com/BS_script/script/raw/master/smooth",
    ["彩虹UI 2.0"]   = "https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/骇灵.UI",
    ["彩虹UI"]       = "https://gitee.com/BS_script/script/raw/master/UI",
    ["黑白UI"]       = "https://gitee.com/BS_script/script/raw/master/Blackui.txt",
    ["彩虹UI第二种"] = "https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/UI-2.txt",
    ["叶脚本UI"]     = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/66YEUIUI.txt",
    ["皮脚本新UI"]   = "https://gitee.com/BS_script/script/raw/master/%E7%9A%AEui.txt",
    ["皮脚本UI"]     = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/%E7%9A%AE%E8%84%9A%E6%9C%ACUI%E6%BA%90%E7%A0%81.lua"
}

local currentUIName = nil
local Library = nil
local UI_LOADED = false

pcall(function()
    math.randomseed(tick())
end)

local function saveSelectedUI(uiName)
    if writefile then
        pcall(function()
            writefile("BS脚本/UI选择配置.txt", uiName)
        end)
    end
    currentUIName = uiName
end

local function loadSelectedUI()
    local configPath = "BS脚本/UI选择配置.txt"
    local succ, content = pcall(function()
        return readfile and readfile(configPath) or nil
    end)
    if succ and content and UIUrls[content] then
        return content, UIUrls[content]
    end
    return nil
end

local function getRandomUI(excludeName)
    local availableIndices = {}
    for i, name in ipairs(UISelector) do
        if name ~= excludeName then
            table.insert(availableIndices, i)
        end
    end
    
    if #availableIndices == 0 then
        return nil, nil
    end
    
    local randomIdx = availableIndices[math.random(1, #availableIndices)]
    local uiName = UISelector[randomIdx]
    return uiName, UIUrls[uiName]
end

local function tryLoadUI(uiName, uiUrl)
    if UI_LOADED then
        return nil
    end
    
    local succ, lib = pcall(function()
        local source = __XixiRemoteFetch(uiUrl, true)
        local fn = loadstring(source)
        return fn and fn() or nil
    end)
    
    if succ and lib then
        if lib.new or lib.New then
            currentUIName = uiName
            saveSelectedUI(uiName)
            UI_LOADED = true
            return lib
        end
    end
    
    return nil
end

local function loadUISequentially()
    local savedUIName, savedUIUrl = loadSelectedUI()
    
    if savedUIName and savedUIUrl then
        Library = tryLoadUI(savedUIName, savedUIUrl)
        if Library then
            return Library
        end
    else
        local randomName, randomUrl = getRandomUI()
        if randomName then
            Library = tryLoadUI(randomName, randomUrl)
            if Library then
                return Library
            end
            savedUIName = randomName
        end
    end
    
    for _, uiName in ipairs(UISelector) do
        if uiName ~= savedUIName then
            local uiUrl = UIUrls[uiName]
            if uiUrl then
                Library = tryLoadUI(uiName, uiUrl)
                if Library then
                    return Library
                end
            end
        end
    end
    
    return nil
end

Library = loadUISequentially()

if Library then
    if not Library.new and Library.New then
        Library.new = Library.New
    end
    
    if Library.new then
        local success, window = pcall(function()
            return Library:new(" 黑洞中心(BS)       ")
        end)
        
        if success and window then
            Window = window
            
            if Window and Window.Tab then
                local tab = Window:Tab("UI选择", '92615117311099')
                task.wait(0.1)
                
                if tab and tab.section then
                    local currentUISection = tab:section("当前UI状态", true)
                    if currentUISection and currentUISection.Label then
                        currentUISection:Label("当前UI: " .. (currentUIName or "未知"))
                        currentUISection:Label("UI状态: 加载成功")
                    end
                    
                    local section = tab:section("选择UI库", true)
                    if section and section.Button then
                        section:Button("🎲 随机选择UI", function()
                            local randomName, randomUrl = getRandomUI(currentUIName)
                            if randomName then
                                saveSelectedUI(randomName)
                                if _G.Notify then
                                    _G.Notify("UI已随机切换", "下次启动将使用: " .. randomName, 3)
                                end
                            else
                                if _G.Notify then
                                    _G.Notify("随机选择失败", "没有可用的UI", 3)
                                end
                            end
                        end)
                        
                        section:Label("--- 或手动选择 ---")
                        
                        for _, uiName in ipairs(UISelector) do
                            local buttonText = uiName
                            if uiName == currentUIName then
                                buttonText = "✅ " .. uiName .. " (当前使用)"
                            end
                            
                            section:Button(buttonText, function()
                                saveSelectedUI(uiName)
                                if _G.Notify then
                                    _G.Notify("UI已切换", "请重新执行脚本以应用 " .. uiName, 3)
                                end
                            end)
                        end
                    end
                end
            end
        else
            Library = nil
            UI_LOADED = false
        end
    end
end

if not Library or not UI_LOADED then
    if _G.Notify then
        _G.Notify("UI加载失败", "所有UI库均无法加载，请检查网络连接", 5)
    end
end
if _G.YourVariableName then
    loadstring(__XixiRemoteFetch("https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/Source.lua"))()
end
local Tab1 = Window:Tab("公告", '118759541854879')
task.wait(0.1)
do
local MessageSection = Tab1:section("联系作者", true)
MessageSection:Label("💬 向作者发送消息")
MessageSection:Label("如果想要收到回复请顺便加上你们的QQ号或其他联系方式")

_G.AuthorMessageText = ""
_G.IsSendingMessage = false

MessageSection:Textbox("输入消息", "AuthorMessage", "输入", function(Value)
    _G.AuthorMessageText = Value or ""
end)

MessageSection:Button("发送消息", function()
    if _G.IsSendingMessage then
        _G.NotifyWarning("请等待", "上一条消息正在发送中...", 2)
        return
    end
    
    local messageText = _G.AuthorMessageText or ""
    if messageText == "" or #messageText < 3 then
        _G.NotifyError("错误", "请输入有效的消息内容（至少3个字符）", 3)
        return
    end
    
    _G.IsSendingMessage = true
    _G.NotifyWarning("发送中", "正在发送消息...", 1.5)
    
    coroutine.wrap(function()
        local success = sendMessageToAuthor(messageText)
        if success then
            _G.AuthorMessageText = ""
            _G.NotifySuccess("发送成功", "消息已成功发送给作者！", 3)
        else
            _G.NotifyError("发送失败", "发送失败，请检查网络连接", 3)
        end
        _G.IsSendingMessage = false
    end)()
end)

function sendMessageToAuthor(messageText)
    return false
end

local Section1 = Tab1:section("BS脚本团队 ", true)
Section1:Label("❤️BS脚本❤️ ")
Section1:Label("脚本目标:国内最全能的脚本 ")
Section1:Label("作者用户名:pro_xx863 ")
Section1:Label("作者QQ1545959422 ")
Section1:Button("复制作者QQ", function()
    setclipboard("1545959422")
end)
Section1:Label("副作者QQ1710433791 ")
Section1:Button("复制副作者QQ", function()
    setclipboard("1710433791")
end)
Section1:Label("QQ群聊:1094013257")
Section1:Button("复制QQ群", function()
    setclipboard("1094013257")
end)
Section1:Button("复制Discord频道", function()
    setclipboard("https://discord.com/invite/vRg33fja4H")
end)

local Tab2 = Window:Tab("设置", '116544501716299')
task.wait(0.1)
local Section2 = Tab2:section("信息", true)

Section2:Label("您的用户名: "..game.Players.LocalPlayer.Name)
Section2:Label("您的名称: "..game.Players.LocalPlayer.DisplayName)
Section2:Label("您的用户ID: "..game.Players.LocalPlayer.UserId)
Section2:Label("您的语言: "..game.Players.LocalPlayer.LocaleId)
Section2:Label("您的国家: "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer))
Section2:Label("您的账户年龄(天): "..game.Players.LocalPlayer.AccountAge)
Section2:Label("您的账户年龄(年): "..math.floor(game.Players.LocalPlayer.AccountAge/365*100)/100)
Section2:Label("您使用的注入器："..identifyexecutor())
Section2:Label("游戏名称: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
Section2:Label("游戏ID: "..game.PlaceId)
Section2:Label("游戏版本: "..game.PlaceVersion)
Section2:Label("当前服务器ID: "..game.JobId)
Section2:Label("服务器最大玩家数: "..game.Players.MaxPlayers)
Section2:Label("Roblox版本: "..version())

local membershipType = game.Players.LocalPlayer.MembershipType
local membershipStatus = "无"
if membershipType == Enum.MembershipType.Premium then
    membershipStatus = "Premium"
elseif membershipType == Enum.MembershipType.OutrageousBuildersClub then
    membershipStatus = "OBC"
elseif membershipType == Enum.MembershipType.TurboBuildersClub then
    membershipStatus = "TBC"
elseif membershipType == Enum.MembershipType.BuildersClub then
    membershipStatus = "BC"
end
Section2:Label("会员状态: "..membershipStatus)
Section2:Label("设备类型: "..(game:GetService("UserInputService").TouchEnabled and "移动设备" or "电脑"))
Section2:Label("屏幕分辨率: "..game:GetService("GuiService"):GetScreenResolution().X.."x"..game:GetService("GuiService"):GetScreenResolution().Y)

local character = game.Players.LocalPlayer.Character
if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Section2:Label("最大生命值: "..humanoid.MaxHealth)
        Section2:Label("最大跳跃力: "..humanoid.JumpPower)
        Section2:Label("最大速度: "..humanoid.WalkSpeed)
    else
        Section2:Label("最大生命值: 无法获取")
        Section2:Label("最大跳跃力: 无法获取")
        Section2:Label("最大速度: 无法获取")
    end
else
    Section2:Label("最大生命值: 角色未加载")
    Section2:Label("最大跳跃力: 角色未加载")
    Section2:Label("最大速度: 角色未加载")
end

Section2:Button("复制所有信息", function()
    local info = {}
    table.insert(info, "=== 黑洞中心 - 信息 ===")
    table.insert(info, "用户名: "..game.Players.LocalPlayer.Name)
    table.insert(info, "显示名称: "..game.Players.LocalPlayer.DisplayName)
    table.insert(info, "用户ID: "..game.Players.LocalPlayer.UserId)
    table.insert(info, "语言: "..game.Players.LocalPlayer.LocaleId)
    table.insert(info, "国家: "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer))
    table.insert(info, "账户年龄(天): "..game.Players.LocalPlayer.AccountAge)
    table.insert(info, "账户年龄(年): "..math.floor(game.Players.LocalPlayer.AccountAge/365*100)/100)
    table.insert(info, "注入器: "..identifyexecutor())
    table.insert(info, "游戏名称: "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    table.insert(info, "游戏ID: "..game.PlaceId)
    table.insert(info, "游戏版本: "..game.PlaceVersion)
    table.insert(info, "服务器ID: "..game.JobId)
    table.insert(info, "最大玩家数: "..game.Players.MaxPlayers)
    table.insert(info, "Roblox版本: "..version())
    table.insert(info, "会员状态: "..membershipStatus)
    table.insert(info, "设备类型: "..(game:GetService("UserInputService").TouchEnabled and "移动设备" or "电脑"))
    table.insert(info, "屏幕分辨率: "..game:GetService("GuiService"):GetScreenResolution().X.."x"..game:GetService("GuiService"):GetScreenResolution().Y)
    
    
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            table.insert(info, "最大生命值: "..humanoid.MaxHealth)
            table.insert(info, "最大跳跃力: "..humanoid.JumpPower)
            table.insert(info, "最大速度: "..humanoid.WalkSpeed)
        else
            table.insert(info, "最大生命值: 无法获取")
            table.insert(info, "最大跳跃力: 无法获取")
            table.insert(info, "最大速度: 无法获取")
        end
    else
        table.insert(info, "最大生命值: 角色未加载")
        table.insert(info, "最大跳跃力: 角色未加载")
        table.insert(info, "最大速度: 角色未加载")
    end
    
    table.insert(info, "=== 复制时间: "..os.date("%Y-%m-%d %H:%M:%S").." ===")
    
    local allInfo = table.concat(info, "\n")
    setclipboard(allInfo)
    _G.NotifySuccess("复制成功", "所有信息已复制到剪贴板", 3)
end)

local SetNumber = function(Input, Minimum, Max)
    Minimum = tonumber(Minimum) or -math.huge
    Max = tonumber(Max) or math.huge
    if Input then
        local Numbered = tonumber(Input)
        if Numbered and (Numbered == (Minimum or Max) or (Numbered < Max) or (Numbered > Minimum)) then
            return Numbered
        elseif string.lower(tostring(Input)) == "inf" then
            return Max
        else
            return 0
        end
    else
        return 0
    end
end

local Create = function(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)
    for i, Property in next, Properties or {} do
        Object[i] = Property
    end
    for i, Child in next, Children or {} do
        Child.Parent = Object
    end
    return Object
end

local GetClasses = function(Ancestor, Class, GetChildren)
    local Results = {}
    for _, Descendant in next, (GetChildren and Ancestor:GetChildren() or Ancestor:GetDescendants()) do
        if Descendant:IsA(Class) then
            table.insert(Results, Descendant)
        end
    end
    return Results
end

local SetSRadius = setsimulationradius or function(Radius, MaxRadius)
    task.spawn(function()
        game.Players.LocalPlayer.SimulationRadius = Radius
        game.Players.LocalPlayer.MaxSimulationDistance = MaxRadius
    end)
end

local currentGravity = nil
local gravityConnection = nil

local function SetGravity(Part)
   
    for _, char in ipairs(playerCharacters) do
        if Part:IsDescendantOf(char) then
            return
        end
    end
    
    
    if Part:IsA("BasePart") and not Part.Anchored then
        
        for _, force in ipairs(Part:GetChildren()) do
            if force:IsA("BodyForce") and force.Name == "CustomGravity" then
                force:Destroy()
            end
        end
        
        
        if currentGravity and currentGravity ~= 0 then
            Create("BodyForce", {
                Name = "CustomGravity",
                Force = Part:GetMass() * Vector3.new(currentGravity, workspace.Gravity, currentGravity),
                Parent = Part,
            })
        end
    end
end

local function initializeGravitySystem()
    if gravityConnection then
        gravityConnection:Disconnect()
    end
    
    gravityConnection = game.Workspace.DescendantAdded:Connect(SetGravity)
    
    for _, Part in ipairs(GetClasses(game.Workspace, "BasePart")) do
        SetGravity(Part)
    end
    
    SetSRadius(9e9, 9e9)
end

local Section3 = Tab2:section("终极属性控制台", true)

local settings = {
    jumpPower = nil,
    hipHeight = nil,
    gameTime = nil,
    walkSpeed = nil,
    gravity = nil,
    health = nil,
    headSize = nil,
    hitboxSize = nil,
    fov = nil,
    cameraDistance = 500,
    customGravity = nil,
    transparency = nil,
    spinSpeed = 0,
    animSpeed = 5,
    totalAnimSpeed = 2.0
}

function applyAnimSpeed()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(currentAnimSpeed)
            end
        end
    end
end

local animController = {
    enabled = false,
    speed = 2.0,
    defaultSpeed = 1.0,
    connection = nil,
    animations = {}
}


function animController:ApplyAnimations()
    if not self.enabled then return end
    
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            
            local playingTracks = humanoid:GetPlayingAnimationTracks()
            
            
            for trackId, trackData in pairs(self.animations) do
                if trackData.track then
                    
                    local found = false
                    for _, playingTrack in ipairs(playingTracks) do
                        if playingTrack == trackData.track then
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        self.animations[trackId] = nil 
                    else
                        trackData.track:AdjustSpeed(self.speed) 
                    end
                end
            end
            
            
            for _, track in ipairs(playingTracks) do
                local animationId = tostring(track.Animation.AnimationId)
                if not self.animations[animationId] then
                    self.animations[animationId] = {
                        track = track,
                        defaultSpeed = self.defaultSpeed
                    }
                    track:AdjustSpeed(self.speed) 
                end
            end
        end
    end
end


function animController:ResetAnimations()
    for animationId, trackData in pairs(self.animations) do
        if trackData.track and trackData.track.IsPlaying then
            trackData.track:AdjustSpeed(trackData.defaultSpeed)
        end
    end
    self.animations = {}
    self.speed = self.defaultSpeed
end


game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        
        character:WaitForChild("Humanoid")
        
        
        if settings.walkSpeed then
            character.Humanoid.WalkSpeed = settings.walkSpeed
        end
        if settings.jumpPower then
            character.Humanoid.JumpPower = settings.jumpPower
        end
        if settings.hipHeight then
            character.Humanoid.HipHeight = settings.hipHeight
        end
        if settings.health then
            character.Humanoid.Health = settings.health
        end
        
        
        if animSpeedEnabled then
            applyAnimSpeed()
        end
        if animController.enabled then
            animController:ApplyAnimations()
        end
    end)
end)