if IY_LOADED and not _G.IY_DEBUG then
	-- error("Infinite Yield is already running!", 0)
	return
end

pcall(function() getgenv().IY_LOADED = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f) return f end)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
ExperienceService = Services.ExperienceService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
SocialService = Services.SocialService

PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
COREGUI = Services.CoreGui or PlayerGui
IYMouse = cloneref(Players.LocalPlayer:GetMouse())
PlaceId, JobId = game.PlaceId, game.JobId
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
--[[rcdEnabled = select(2, pcall(function()
    return gethidden(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
end)) or false]]

-- xylex & europa
local iyassets = {
	["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
	["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
	["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
	["infiniteyield/assets/editkeybinds.png"] = "rbxassetid://129697930",
	["infiniteyield/assets/edittheme.png"] = "rbxassetid://4911962991",
	["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
	["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
	["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
	["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
	["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
	["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
	["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029",
	["infiniteyield/assets/scrollbar.png"] = "rbxassetid://75024581433929"
}

local function getcustomasset(asset)
	if waxgetcustomasset then
		local success, result = pcall(function()
			return waxgetcustomasset(asset)
		end)
		if success and result ~= nil and result ~= "" then
			return result
		end
	end
	return iyassets[asset]
end

if makefolder and isfolder and writefile and isfile then
	pcall(function() -- good executor trust
		local assets = "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/"
		for _, folder in {"infiniteyield", "infiniteyield/assets"} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		for path in iyassets do
			if not isfile(path) and path ~= 'infiniteyield/assets/scrollbar.png' then
				writefile(path, game:HttpGet((path:gsub("infiniteyield/", assets))))
			end
		end
		-- honestly just blame your phone if the assets appear in your gallery
		if IsOnMobile then writefile("infiniteyield/assets/.nomedia", "") end
	end)
end

currentVersion = "6.4.2"

ScaledHolder = Instance.new("Frame")
Scale = Instance.new("UIScale")
Holder = Instance.new("Frame")
Title = Instance.new("TextLabel")
Dark = Instance.new("Frame")
Cmdbar = Instance.new("TextBox")
CMDsF = Instance.new("ScrollingFrame")
cmdListLayout = Instance.new("UIListLayout")
SettingsButton = Instance.new("ImageButton")
ColorsButton = Instance.new("ImageButton")
Settings = Instance.new("Frame")
Prefix = Instance.new("TextLabel")
PrefixBox = Instance.new("TextBox")
Keybinds = Instance.new("TextLabel")
StayOpen = Instance.new("TextLabel")
Button = Instance.new("Frame")
On = Instance.new("TextButton")
Positions = Instance.new("TextLabel")
EventBind = Instance.new("TextLabel")
Plugins = Instance.new("TextLabel")
Example = Instance.new("TextButton")
Notification = Instance.new("Frame")
Title_2 = Instance.new("TextLabel")
Text_2 = Instance.new("TextLabel")
CloseButton = Instance.new("TextButton")
CloseImage = Instance.new("ImageLabel")
PinButton = Instance.new("TextButton")
PinImage = Instance.new("ImageLabel")
Tooltip = Instance.new("Frame")
Title_3 = Instance.new("TextLabel")
Description = Instance.new("TextLabel")
IntroBackground = Instance.new("Frame")
Logo = Instance.new("ImageLabel")
Credits = Instance.new("TextBox")
KeybindsFrame = Instance.new("Frame")
Close = Instance.new("TextButton")
Add = Instance.new("TextButton")
Delete = Instance.new("TextButton")
Holder_2 = Instance.new("ScrollingFrame")
Example_2 = Instance.new("Frame")
Text_3 = Instance.new("TextLabel")
Delete_2 = Instance.new("TextButton")
KeybindEditor = Instance.new("Frame")
background_2 = Instance.new("Frame")
Dark_3 = Instance.new("Frame")
Directions = Instance.new("TextLabel")
BindTo = Instance.new("TextButton")
TriggerLabel = Instance.new("TextLabel")
BindTriggerSelect = Instance.new("TextButton")
Add_2 = Instance.new("TextButton")
Toggles = Instance.new("ScrollingFrame")
ClickTP  = Instance.new("TextLabel")
Select = Instance.new("TextButton")
ClickDelete = Instance.new("TextLabel")
Select_2 = Instance.new("TextButton")
Cmdbar_2 = Instance.new("TextBox")
Cmdbar_3 = Instance.new("TextBox")
CreateToggle = Instance.new("TextLabel")
Button_2 = Instance.new("Frame")
On_2 = Instance.new("TextButton")
shadow_2 = Instance.new("Frame")
PopupText_2 = Instance.new("TextLabel")
Exit_2 = Instance.new("TextButton")
ExitImage_2 = Instance.new("ImageLabel")
PositionsFrame = Instance.new("Frame")
Close_3 = Instance.new("TextButton")
Delete_5 = Instance.new("TextButton")
Part = Instance.new("TextButton")
Holder_4 = Instance.new("ScrollingFrame")
Example_4 = Instance.new("Frame")
Text_5 = Instance.new("TextLabel")
Delete_6 = Instance.new("TextButton")
TP = Instance.new("TextButton")
AliasesFrame = Instance.new("Frame")
Close_2 = Instance.new("TextButton")
Delete_3 = Instance.new("TextButton")
Holder_3 = Instance.new("ScrollingFrame")
Example_3 = Instance.new("Frame")
Text_4 = Instance.new("TextLabel")
Delete_4 = Instance.new("TextButton")
Aliases = Instance.new("TextLabel")
PluginsFrame = Instance.new("Frame")
Close_4 = Instance.new("TextButton")
Add_3 = Instance.new("TextButton")
Holder_5 = Instance.new("ScrollingFrame")
Example_5 = Instance.new("Frame")
Text_6 = Instance.new("TextLabel")
Delete_7 = Instance.new("TextButton")
PluginEditor = Instance.new("Frame")
background_3 = Instance.new("Frame")
Dark_2 = Instance.new("Frame")
Img = Instance.new("ImageButton")
AddPlugin = Instance.new("TextButton")
FileName = Instance.new("TextBox")
About = Instance.new("TextLabel")
Directions_2 = Instance.new("TextLabel")
shadow_3 = Instance.new("Frame")
PopupText_3 = Instance.new("TextLabel")
Exit_3 = Instance.new("TextButton")
ExitImage_3 = Instance.new("ImageLabel")
AliasHint = Instance.new("TextLabel")
PluginsHint = Instance.new("TextLabel")
PositionsHint = Instance.new("TextLabel")
ToPartFrame = Instance.new("Frame")
background_4 = Instance.new("Frame")
ChoosePart = Instance.new("TextButton")
CopyPath = Instance.new("TextButton")
Directions_3 = Instance.new("TextLabel")
Path = Instance.new("TextLabel")
shadow_4 = Instance.new("Frame")
PopupText_5 = Instance.new("TextLabel")
Exit_4 = Instance.new("TextButton")
ExitImage_5 = Instance.new("ImageLabel")
logs = Instance.new("Frame")
shadow = Instance.new("Frame")
Hide = Instance.new("TextButton")
ImageLabel = Instance.new("ImageLabel")
PopupText = Instance.new("TextLabel")
Exit = Instance.new("TextButton")
ImageLabel_2 = Instance.new("ImageLabel")
background = Instance.new("Frame")
chat = Instance.new("Frame")
Clear = Instance.new("TextButton")
SaveChatlogs = Instance.new("TextButton")
Toggle = Instance.new("TextButton")
scroll_2 = Instance.new("ScrollingFrame")
join = Instance.new("Frame")
Toggle_2 = Instance.new("TextButton")
Clear_2 = Instance.new("TextButton")
scroll_3 = Instance.new("ScrollingFrame")
listlayout = Instance.new("UIListLayout",scroll_3)
selectChat = Instance.new("TextButton")
selectJoin = Instance.new("TextButton")

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

PARENT = nil
MAX_DISPLAY_ORDER = 1.7976931348623157e308
if gethui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = gethui()
    PARENT = Main
elseif (not is_sirhurt_closure) and syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
elseif COREGUI:FindFirstChild("RobloxGui") then
    PARENT = COREGUI.RobloxGui
else
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = COREGUI
    PARENT = Main
end

shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}

ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT
Scale.Name = randomString()

Holder.Name = randomString()
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -250, 1, -220)
Holder.Size = UDim2.new(0, 250, 0, 220)
Holder.ZIndex = 10
table.insert(shade2,Holder)

Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = Color3.fromRGB(36,36,37)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0, 250, 0, 20)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18
Title.Text = "Infinite Yield FE v" .. currentVersion

do
	local emoji = ({
		["01 01"] = "🎆",
		["02 14"] = "💝",
		["03 17"] = "☘️",
		[(function(Year)
			local A = math.floor(Year/100)
			local B = math.floor((13+8*A)/25)
			local C = (15-B+A-math.floor(A/4))%30
			local D = (4+A-math.floor(A/4))%7
			local E = (19*(Year%19)+C)%30
			local F = (2*(Year%4)+4*(Year%7)+6*E+D)%7
			local G = (22+E+F)
			if E == 29 and F == 6 then
				return "04 19"
			elseif E == 28 and F == 6 then
				return "04 18"
			elseif 31 < G then
				return ("04 %02d"):format(G-31)
			end
			return ("03 %02d"):format(G)
		end)(tonumber(os.date"%Y"))] = "🥚",
		["10 31"] = "🎃",
		["12 25"] = "🎄"
	})[os.date("%m %d")]
	if emoji then
		Title.Text = ("%s %s %s"):format(emoji, Title.Text, emoji)
	end
end

Title.TextColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 10
table.insert(shade1,Title)
table.insert(text1,Title)

Dark.Name = "Dark"
Dark.Parent = Holder
Dark.Active = true
Dark.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Dark.BorderSizePixel = 0
Dark.Position = UDim2.new(0, 0, 0, 45)
Dark.Size = UDim2.new(0, 250, 0, 175)
Dark.ZIndex = 10
table.insert(shade1,Dark)

Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundTransparency = 1
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 5, 0, 20)
Cmdbar.Size = UDim2.new(0, 240, 0, 25)
Cmdbar.Font = Enum.Font.SourceSans
Cmdbar.TextSize = 18
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.TextColor3 = Color3.new(1, 1, 1)
Cmdbar.Text = ""
Cmdbar.ZIndex = 10
Cmdbar.PlaceholderText = "Command Bar"

CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundTransparency = 1
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 5, 0, 45)
CMDsF.Size = UDim2.new(0, 245, 0, 175)
CMDsF.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 8
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = 'Always'
CMDsF.ZIndex = 10
table.insert(scroll,CMDsF)

cmdListLayout.Parent = CMDsF

SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(0, 230, 0, 0)
SettingsButton.Size = UDim2.new(0, 20, 0, 20)
SettingsButton.Image = getcustomasset("infiniteyield/assets/settings.png")
SettingsButton.ZIndex = 10

ReferenceButton = Instance.new("ImageButton")
ReferenceButton.Name = "ReferenceButton"
ReferenceButton.Parent = Holder
ReferenceButton.BackgroundTransparency = 1
ReferenceButton.Position = UDim2.new(0, 212, 0, 2)
ReferenceButton.Size = UDim2.new(0, 16, 0, 16)
ReferenceButton.Image = getcustomasset("infiniteyield/assets/reference.png")
ReferenceButton.ZIndex = 10

Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 220)
Settings.Size = UDim2.new(0, 250, 0, 175)
Settings.ZIndex = 10
table.insert(shade1,Settings)

SettingsHolder = Instance.new("ScrollingFrame")
SettingsHolder.Name = "Holder"
SettingsHolder.Parent = Settings
SettingsHolder.BackgroundTransparency = 1
SettingsHolder.BorderSizePixel = 0
SettingsHolder.Size = UDim2.new(1,0,1,0)
SettingsHolder.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
SettingsHolder.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.CanvasSize = UDim2.new(0, 0, 0, 235)
SettingsHolder.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.ScrollBarThickness = 8
SettingsHolder.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.VerticalScrollBarInset = 'Always'
SettingsHolder.ZIndex = 10
table.insert(scroll,SettingsHolder)

Prefix.Name = "Prefix"
Prefix.Parent = SettingsHolder
Prefix.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Prefix.BorderSizePixel = 0
Prefix.BackgroundTransparency = 1
Prefix.Position = UDim2.new(0, 5, 0, 5)
Prefix.Size = UDim2.new(1, -10, 0, 20)
Prefix.Font = Enum.Font.SourceSans
Prefix.TextSize = 14
Prefix.Text = "Prefix"
Prefix.TextColor3 = Color3.new(1, 1, 1)
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 10
table.insert(shade2,Prefix)
table.insert(text1,Prefix)

PrefixBox.Name = "PrefixBox"
PrefixBox.Parent = Prefix
PrefixBox.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
PrefixBox.BorderSizePixel = 0
PrefixBox.Position = UDim2.new(1, -20, 0, 0)
PrefixBox.Size = UDim2.new(0, 20, 0, 20)
PrefixBox.Font = Enum.Font.SourceSansBold
PrefixBox.TextSize = 14
PrefixBox.Text = ''
PrefixBox.TextColor3 = Color3.new(0, 0, 0)
PrefixBox.ZIndex = 10
table.insert(shade3,PrefixBox)
table.insert(text2,PrefixBox)

function makeSettingsButton(name,iconID,off)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0,0,0,0)
	button.Size = UDim2.new(1,0,0,25)
	button.Text = ""
	button.ZIndex = 10
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = button
	icon.Position = UDim2.new(0,5,0,5)
	icon.Size = UDim2.new(0,16,0,16)
	icon.BackgroundTransparency = 1
	icon.Image = iconID
	icon.ZIndex = 10
	if off then
		icon.ScaleType = Enum.ScaleType.Crop
		icon.ImageRectSize = Vector2.new(16,16)
		icon.ImageRectOffset = Vector2.new(off,0)
	end
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Text = name
	label.Position = UDim2.new(0,28,0,0)
	label.Size = UDim2.new(1,-28,1,0)
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.ZIndex = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(shade2,button)
	table.insert(text1,label)
	return button
end

ColorsButton = makeSettingsButton("Edit Theme",getcustomasset("infiniteyield/assets/edittheme.png"))
ColorsButton.Position = UDim2.new(0, 5, 0, 55)
ColorsButton.Size = UDim2.new(1, -10, 0, 25)
ColorsButton.Name = "Colors"
ColorsButton.Parent = SettingsHolder

Keybinds = makeSettingsButton("Edit Keybinds",getcustomasset("infiniteyield/assets/editkeybinds.png"))
Keybinds.Position = UDim2.new(0, 5, 0, 85)
Keybinds.Size = UDim2.new(1, -10, 0, 25)
Keybinds.Name = "Keybinds"
Keybinds.Parent = SettingsHolder

Aliases = makeSettingsButton("Edit Aliases",getcustomasset("infiniteyield/assets/editaliases.png"))
Aliases.Position = UDim2.new(0, 5, 0, 115)
Aliases.Size = UDim2.new(1, -10, 0, 25)
Aliases.Name = "Aliases"
Aliases.Parent = SettingsHolder

StayOpen.Name = "StayOpen"
StayOpen.Parent = SettingsHolder
StayOpen.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
StayOpen.BorderSizePixel = 0
StayOpen.BackgroundTransparency = 1
StayOpen.Position = UDim2.new(0, 5, 0, 30)
StayOpen.Size = UDim2.new(1, -10, 0, 20)
StayOpen.Font = Enum.Font.SourceSans
StayOpen.TextSize = 14
StayOpen.Text = "Keep Menu Open"
StayOpen.TextColor3 = Color3.new(1, 1, 1)
StayOpen.TextXAlignment = Enum.TextXAlignment.Left
StayOpen.ZIndex = 10
table.insert(shade2,StayOpen)
table.insert(text1,StayOpen)

Button.Name = "Button"
Button.Parent = StayOpen
Button.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.Font = Enum.Font.SourceSans
On.FontSize = Enum.FontSize.Size14
On.Text = ""
On.TextColor3 = Color3.new(0, 0, 0)
On.ZIndex = 10

Positions = makeSettingsButton("Edit/Goto Waypoints",getcustomasset("infiniteyield/assets/editwaypoints.png"))
Positions.Position = UDim2.new(0, 5, 0, 145)
Positions.Size = UDim2.new(1, -10, 0, 25)
Positions.Name = "Waypoints"
Positions.Parent = SettingsHolder

EventBind = makeSettingsButton("Edit Event Binds",getcustomasset("infiniteyield/assets/bindsandplugins.png"),759)
EventBind.Position = UDim2.new(0, 5, 0, 205)
EventBind.Size = UDim2.new(1, -10, 0, 25)
EventBind.Name = "EventBinds"
EventBind.Parent = SettingsHolder

Plugins = makeSettingsButton("Manage Plugins",getcustomasset("infiniteyield/assets/bindsandplugins.png"),743)
Plugins.Position = UDim2.new(0, 5, 0, 175)
Plugins.Size = UDim2.new(1, -10, 0, 25)
Plugins.Name = "Plugins"
Plugins.Parent = SettingsHolder

Example.Name = "Example"
Example.Parent = Holder
Example.BackgroundTransparency = 1
Example.BorderSizePixel = 0
Example.Size = UDim2.new(0, 190, 0, 20)
Example.Visible = false
Example.Font = Enum.Font.SourceSans
Example.TextSize = 18
Example.Text = "Example"
Example.TextColor3 = Color3.new(1, 1, 1)
Example.TextXAlignment = Enum.TextXAlignment.Left
Example.ZIndex = 10
table.insert(text1,Example)

Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -500, 1, 20)
Notification.Size = UDim2.new(0, 250, 0, 100)
Notification.ZIndex = 10
table.insert(shade1,Notification)

Title_2.Name = "Title"
Title_2.Parent = Notification
Title_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0, 250, 0, 20)
Title_2.Font = Enum.Font.SourceSans
Title_2.TextSize = 14
Title_2.Text = "Notification Title"
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.ZIndex = 10
table.insert(shade2,Title_2)
table.insert(text1,Title_2)

Text_2.Name = "Text"
Text_2.Parent = Notification
Text_2.BackgroundTransparency = 1
Text_2.BorderSizePixel = 0
Text_2.Position = UDim2.new(0, 5, 0, 25)
Text_2.Size = UDim2.new(0, 240, 0, 75)
Text_2.Font = Enum.Font.SourceSans
Text_2.TextSize = 16
Text_2.Text = "Notification Text"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextWrapped = true
Text_2.ZIndex = 10
table.insert(text1,Text_2)

CloseButton.Name = "CloseButton"
CloseButton.Parent = Notification
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = ""
CloseButton.ZIndex = 10

CloseImage.Parent = CloseButton
CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
CloseImage.BackgroundTransparency = 1
CloseImage.Position = UDim2.new(0, 5, 0, 5)
CloseImage.Size = UDim2.new(0, 10, 0, 10)
CloseImage.Image = getcustomasset("infiniteyield/assets/close.png")
CloseImage.ZIndex = 10

PinButton.Name = "PinButton"
PinButton.Parent = Notification
PinButton.BackgroundTransparency = 1
PinButton.Size = UDim2.new(0, 20, 0, 20)
PinButton.ZIndex = 10
PinButton.Text = ""

PinImage.Parent = PinButton
PinImage.BackgroundColor3 = Color3.new(1, 1, 1)
PinImage.BackgroundTransparency = 1
PinImage.Position = UDim2.new(0, 3, 0, 3)
PinImage.Size = UDim2.new(0, 14, 0, 14)
PinImage.ZIndex = 10
PinImage.Image = getcustomasset("infiniteyield/assets/pin.png")

Tooltip.Name = randomString()
Tooltip.Parent = ScaledHolder
Tooltip.Active = true
Tooltip.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 200, 0, 96)
Tooltip.Visible = false
Tooltip.ZIndex = 10
table.insert(shade1,Tooltip)

Title_3.Name = "Title"
Title_3.Parent = Tooltip
Title_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_3.BackgroundTransparency = 0.1
Title_3.BorderSizePixel = 0
Title_3.Size = UDim2.new(0, 200, 0, 20)
Title_3.Font = Enum.Font.SourceSans
Title_3.TextSize = 14
Title_3.Text = ""
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextTransparency = 0.1
Title_3.ZIndex = 10
table.insert(shade2,Title_3)
table.insert(text1,Title_3)

Description.Name = "Description"
Description.Parent = Tooltip
Description.BackgroundTransparency = 1
Description.BorderSizePixel = 0
Description.Size = UDim2.new(0,180,0,72)
Description.Position = UDim2.new(0,10,0,18)
Description.Font = Enum.Font.SourceSans
Description.TextSize = 16
Description.Text = ""
Description.TextColor3 = Color3.new(1, 1, 1)
Description.TextTransparency = 0.1
Description.TextWrapped = true
Description.ZIndex = 10
table.insert(text1,Description)

IntroBackground.Name = "IntroBackground"
IntroBackground.Parent = Holder
IntroBackground.Active = true
IntroBackground.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
IntroBackground.BorderSizePixel = 0
IntroBackground.Position = UDim2.new(0, 0, 0, 45)
IntroBackground.Size = UDim2.new(0, 250, 0, 175)
IntroBackground.ZIndex = 10

Logo.Name = "Logo"
Logo.Parent = Holder
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0, 125, 0, 127)
Logo.Size = UDim2.new(0, 10, 0, 10)
Logo.Image = getcustomasset("infiniteyield/assets/logo.png")
Logo.ImageTransparency = 0
Logo.ZIndex = 10

Credits.Name = "Credits"
Credits.Parent = Holder
Credits.BackgroundTransparency = 1
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0, 0, 0.9, 30)
Credits.Size = UDim2.new(0, 250, 0, 20)
Credits.Font = Enum.Font.SourceSansLight
Credits.FontSize = Enum.FontSize.Size14
Credits.Text = "Edge // Zwolf // Moon // Toon // Peyton // ATP"
Credits.TextColor3 = Color3.new(1, 1, 1)
Credits.ZIndex = 10

KeybindsFrame.Name = "KeybindsFrame"
KeybindsFrame.Parent = Settings
KeybindsFrame.Active = true
KeybindsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
KeybindsFrame.BorderSizePixel = 0
KeybindsFrame.Position = UDim2.new(0, 0, 0, 175)
KeybindsFrame.Size = UDim2.new(0, 250, 0, 175)
KeybindsFrame.ZIndex = 10
table.insert(shade1,KeybindsFrame)

Close.Name = "Close"
Close.Parent = KeybindsFrame
Close.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 150)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

Add.Name = "Add"
Add.Parent = KeybindsFrame
Add.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 150)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = Color3.new(1, 1, 1)
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

Delete.Name = "Delete"
Delete.Parent = KeybindsFrame
Delete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 150)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = Color3.new(1, 1, 1)
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

Holder_2.Name = "Holder"
Holder_2.Parent = KeybindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 145)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

Example_2.Name = "Example"
Example_2.Parent = KeybindsFrame
Example_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = Color3.new(1, 1, 1)
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = Color3.new(0, 0, 0)
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

KeybindEditor.Name = randomString()
KeybindEditor.Parent = ScaledHolder
KeybindEditor.Active = true
KeybindEditor.BackgroundTransparency = 1
KeybindEditor.Position = UDim2.new(0.5, -180, 0, -500)
KeybindEditor.Size = UDim2.new(0, 360, 0, 20)
KeybindEditor.ZIndex = 10

background_2.Name = "background"
background_2.Parent = KeybindEditor
background_2.Active = true
background_2.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_2.BorderSizePixel = 0
background_2.Position = UDim2.new(0, 0, 0, 20)
background_2.Size = UDim2.new(0, 360, 0, 185)
background_2.ZIndex = 10
table.insert(shade1,background_2)

Dark_3.Name = "Dark"
Dark_3.Parent = background_2
Dark_3.Active = true
Dark_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_3.BorderSizePixel = 0
Dark_3.Position = UDim2.new(0, 135, 0, 0)
Dark_3.Size = UDim2.new(0, 2, 0, 185)
Dark_3.ZIndex = 10
table.insert(shade2,Dark_3)

Directions.Name = "Directions"
Directions.Parent = background_2
Directions.BackgroundTransparency = 1
Directions.BorderSizePixel = 0
Directions.Position = UDim2.new(0, 10, 0, 15)
Directions.Size = UDim2.new(0, 115, 0, 90)
Directions.ZIndex = 10
Directions.Font = Enum.Font.SourceSans
Directions.Text = "Click the button below and press a key/mouse button. Then select what you want to bind it to."
Directions.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions.TextSize = 14.000
Directions.TextWrapped = true
Directions.TextYAlignment = Enum.TextYAlignment.Top
table.insert(text1,Directions)

BindTo.Name = "BindTo"
BindTo.Parent = background_2
BindTo.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTo.BorderSizePixel = 0
BindTo.Position = UDim2.new(0, 10, 0, 95)
BindTo.Size = UDim2.new(0, 115, 0, 50)
BindTo.ZIndex = 10
BindTo.Font = Enum.Font.SourceSans
BindTo.Text = "Click to bind"
BindTo.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTo.TextSize = 16.000
table.insert(shade2,BindTo)
table.insert(text1,BindTo)

TriggerLabel.Name = "TriggerLabel"
TriggerLabel.Parent = background_2
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Position = UDim2.new(0, 10, 0, 155)
TriggerLabel.Size = UDim2.new(0, 45, 0, 20)
TriggerLabel.ZIndex = 10
TriggerLabel.Font = Enum.Font.SourceSans
TriggerLabel.Text = "Trigger:"
TriggerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerLabel.TextSize = 14.000
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,TriggerLabel)

BindTriggerSelect.Name = "BindTo"
BindTriggerSelect.Parent = background_2
BindTriggerSelect.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTriggerSelect.BorderSizePixel = 0
BindTriggerSelect.Position = UDim2.new(0, 60, 0, 155)
BindTriggerSelect.Size = UDim2.new(0, 65, 0, 20)
BindTriggerSelect.ZIndex = 10
BindTriggerSelect.Font = Enum.Font.SourceSans
BindTriggerSelect.Text = "KeyDown"
BindTriggerSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTriggerSelect.TextSize = 16.000
table.insert(shade2,BindTriggerSelect)
table.insert(text1,BindTriggerSelect)

Add_2.Name = "Add"
Add_2.Parent = background_2
Add_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_2.BorderSizePixel = 0
Add_2.Position = UDim2.new(0, 310, 0, 35)
Add_2.Size = UDim2.new(0, 40, 0, 20)
Add_2.ZIndex = 10
Add_2.Font = Enum.Font.SourceSans
Add_2.Text = "Add"
Add_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Add_2.TextSize = 14.000
table.insert(shade2,Add_2)
table.insert(text1,Add_2)

Toggles.Name = "Toggles"
Toggles.Parent = background_2
Toggles.BackgroundTransparency = 1
Toggles.BorderSizePixel = 0
Toggles.Position = UDim2.new(0, 150, 0, 125)
Toggles.Size = UDim2.new(0, 200, 0, 50)
Toggles.ZIndex = 10
Toggles.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.CanvasSize = UDim2.new(0, 0, 0, 50)
Toggles.ScrollBarThickness = 8
Toggles.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.VerticalScrollBarInset = Enum.ScrollBarInset.Always
table.insert(scroll,Toggles)

ClickTP.Name = "Click TP (Hold Key & Click)"
ClickTP.Parent = Toggles
ClickTP.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickTP.BorderSizePixel = 0
ClickTP.Size = UDim2.new(0, 200, 0, 20)
ClickTP.ZIndex = 10
ClickTP.Font = Enum.Font.SourceSans
ClickTP.Text = "    Click TP (Hold Key & Click)"
ClickTP.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickTP.TextSize = 14.000
ClickTP.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickTP)
table.insert(text1,ClickTP)

Select.Name = "Select"
Select.Parent = ClickTP
Select.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select.BorderSizePixel = 0
Select.Position = UDim2.new(0, 160, 0, 0)
Select.Size = UDim2.new(0, 40, 0, 20)
Select.ZIndex = 10
Select.Font = Enum.Font.SourceSans
Select.Text = "Add"
Select.TextColor3 = Color3.fromRGB(0, 0, 0)
Select.TextSize = 14.000
table.insert(shade3,Select)
table.insert(text2,Select)

ClickDelete.Name = "Click Delete (Hold Key & Click)"
ClickDelete.Parent = Toggles
ClickDelete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickDelete.BorderSizePixel = 0
ClickDelete.Position = UDim2.new(0, 0, 0, 25)
ClickDelete.Size = UDim2.new(0, 200, 0, 20)
ClickDelete.ZIndex = 10
ClickDelete.Font = Enum.Font.SourceSans
ClickDelete.Text = "    Click Delete (Hold Key & Click)"
ClickDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelete.TextSize = 14.000
ClickDelete.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickDelete)
table.insert(text1,ClickDelete)

Select_2.Name = "Select"
Select_2.Parent = ClickDelete
Select_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select_2.BorderSizePixel = 0
Select_2.Position = UDim2.new(0, 160, 0, 0)
Select_2.Size = UDim2.new(0, 40, 0, 20)
Select_2.ZIndex = 10
Select_2.Font = Enum.Font.SourceSans
Select_2.Text = "Add"
Select_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Select_2.TextSize = 14.000
table.insert(shade3,Select_2)
table.insert(text2,Select_2)

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background_2
Cmdbar_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.Position = UDim2.new(0, 150, 0, 35)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
Cmdbar_2.Font = Enum.Font.SourceSans
Cmdbar_2.PlaceholderText = "Command"
Cmdbar_2.Text = ""
Cmdbar_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_2.TextSize = 14.000
Cmdbar_2.TextXAlignment = Enum.TextXAlignment.Left

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background_2
Cmdbar_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.Position = UDim2.new(0, 150, 0, 60)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.ZIndex = 10
Cmdbar_3.Font = Enum.Font.SourceSans
Cmdbar_3.PlaceholderText = "Command 2"
Cmdbar_3.Text = ""
Cmdbar_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_3.TextSize = 14.000
Cmdbar_3.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background_2
CreateToggle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CreateToggle.BackgroundTransparency = 1
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 152, 0, 10)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button_2.Name = "Button"
Button_2.Parent = CreateToggle
Button_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(1, -20, 0, 0)
Button_2.Size = UDim2.new(0, 20, 0, 20)
Button_2.ZIndex = 10
table.insert(shade3,Button_2)

On_2.Name = "On"
On_2.Parent = Button_2
On_2.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On_2.BackgroundTransparency = 1
On_2.BorderSizePixel = 0
On_2.Position = UDim2.new(0, 2, 0, 2)
On_2.Size = UDim2.new(0, 16, 0, 16)
On_2.ZIndex = 10
On_2.Font = Enum.Font.SourceSans
On_2.Text = ""
On_2.TextColor3 = Color3.fromRGB(0, 0, 0)
On_2.TextSize = 14.000

shadow_2.Name = "shadow"
shadow_2.Parent = KeybindEditor
shadow_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_2.BorderSizePixel = 0
shadow_2.Size = UDim2.new(0, 360, 0, 20)
shadow_2.ZIndex = 10
table.insert(shade2,shadow_2)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow_2
PopupText_2.BackgroundTransparency = 1
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set Keybinds"
PopupText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow_2
Exit_2.BackgroundTransparency = 1
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ExitImage_2.Parent = Exit_2
ExitImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ExitImage_2.BackgroundTransparency = 1
ExitImage_2.Position = UDim2.new(0, 5, 0, 5)
ExitImage_2.Size = UDim2.new(0, 10, 0, 10)
ExitImage_2.ZIndex = 10
ExitImage_2.Image = getcustomasset("infiniteyield/assets/close.png")

PositionsFrame.Name = "PositionsFrame"
PositionsFrame.Parent = Settings
PositionsFrame.Active = true
PositionsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PositionsFrame.BorderSizePixel = 0
PositionsFrame.Size = UDim2.new(0, 250, 0, 175)
PositionsFrame.Position = UDim2.new(0, 0, 0, 175)
PositionsFrame.ZIndex = 10
table.insert(shade1,PositionsFrame)

Close_3.Name = "Close"
Close_3.Parent = PositionsFrame
Close_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0, 205, 0, 150)
Close_3.Size = UDim2.new(0, 40, 0, 20)
Close_3.Font = Enum.Font.SourceSans
Close_3.TextSize = 14
Close_3.Text = "Close"
Close_3.TextColor3 = Color3.new(1, 1, 1)
Close_3.ZIndex = 10
table.insert(shade2,Close_3)
table.insert(text1,Close_3)

Delete_5.Name = "Delete"
Delete_5.Parent = PositionsFrame
Delete_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_5.BorderSizePixel = 0
Delete_5.Position = UDim2.new(0, 50, 0, 150)
Delete_5.Size = UDim2.new(0, 40, 0, 20)
Delete_5.Font = Enum.Font.SourceSans
Delete_5.TextSize = 14
Delete_5.Text = "Clear"
Delete_5.TextColor3 = Color3.new(1, 1, 1)
Delete_5.ZIndex = 10
table.insert(shade2,Delete_5)
table.insert(text1,Delete_5)

Part.Name = "PartGoto"
Part.Parent = PositionsFrame
Part.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Part.BorderSizePixel = 0
Part.Position = UDim2.new(0, 5, 0, 150)
Part.Size = UDim2.new(0, 40, 0, 20)
Part.Font = Enum.Font.SourceSans
Part.TextSize = 14
Part.Text = "Part"
Part.TextColor3 = Color3.new(1, 1, 1)
Part.ZIndex = 10
table.insert(shade2,Part)
table.insert(text1,Part)

Holder_4.Name = "Holder"
Holder_4.Parent = PositionsFrame
Holder_4.BackgroundTransparency = 1
Holder_4.BorderSizePixel = 0
Holder_4.Position = UDim2.new(0, 0, 0, 0)
Holder_4.Selectable = false
Holder_4.Size = UDim2.new(0, 250, 0, 145)
Holder_4.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_4.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_4.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.ScrollBarThickness = 0
Holder_4.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.VerticalScrollBarInset = 'Always'
Holder_4.ZIndex = 10

Example_4.Name = "Example"
Example_4.Parent = PositionsFrame
Example_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_4.BorderSizePixel = 0
Example_4.Size = UDim2.new(0, 10, 0, 20)
Example_4.Visible = false
Example_4.Position = UDim2.new(0, 0, 0, -5)
Example_4.ZIndex = 10
table.insert(shade2,Example_4)

Text_5.Name = "Text"
Text_5.Parent = Example_4
Text_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_5.BorderSizePixel = 0
Text_5.Position = UDim2.new(0, 10, 0, 0)
Text_5.Size = UDim2.new(0, 240, 0, 20)
Text_5.Font = Enum.Font.SourceSans
Text_5.TextSize = 14
Text_5.Text = "Position"
Text_5.TextColor3 = Color3.new(1, 1, 1)
Text_5.TextXAlignment = Enum.TextXAlignment.Left
Text_5.ZIndex = 10
table.insert(shade2,Text_5)
table.insert(text1,Text_5)

Delete_6.Name = "Delete"
Delete_6.Parent = Text_5
Delete_6.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_6.BorderSizePixel = 0
Delete_6.Position = UDim2.new(0, 200, 0, 0)
Delete_6.Size = UDim2.new(0, 40, 0, 20)
Delete_6.Font = Enum.Font.SourceSans
Delete_6.TextSize = 14
Delete_6.Text = "Delete"
Delete_6.TextColor3 = Color3.new(0, 0, 0)
Delete_6.ZIndex = 10
table.insert(shade3,Delete_6)
table.insert(text2,Delete_6)

TP.Name = "TP"
TP.Parent = Text_5
TP.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
TP.BorderSizePixel = 0
TP.Position = UDim2.new(0, 155, 0, 0)
TP.Size = UDim2.new(0, 40, 0, 20)
TP.Font = Enum.Font.SourceSans
TP.TextSize = 14
TP.Text = "Goto"
TP.TextColor3 = Color3.new(0, 0, 0)
TP.ZIndex = 10
table.insert(shade3,TP)
table.insert(text2,TP)

AliasesFrame.Name = "AliasesFrame"
AliasesFrame.Parent = Settings
AliasesFrame.Active = true
AliasesFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasesFrame.BorderSizePixel = 0
AliasesFrame.Position = UDim2.new(0, 0, 0, 175)
AliasesFrame.Size = UDim2.new(0, 250, 0, 175)
AliasesFrame.ZIndex = 10
table.insert(shade1,AliasesFrame)

Close_2.Name = "Close"
Close_2.Parent = AliasesFrame
Close_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0, 205, 0, 150)
Close_2.Size = UDim2.new(0, 40, 0, 20)
Close_2.Font = Enum.Font.SourceSans
Close_2.TextSize = 14
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.new(1, 1, 1)
Close_2.ZIndex = 10
table.insert(shade2,Close_2)
table.insert(text1,Close_2)

Delete_3.Name = "Delete"
Delete_3.Parent = AliasesFrame
Delete_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_3.BorderSizePixel = 0
Delete_3.Position = UDim2.new(0, 5, 0, 150)
Delete_3.Size = UDim2.new(0, 40, 0, 20)
Delete_3.Font = Enum.Font.SourceSans
Delete_3.TextSize = 14
Delete_3.Text = "Clear"
Delete_3.TextColor3 = Color3.new(1, 1, 1)
Delete_3.ZIndex = 10
table.insert(shade2,Delete_3)
table.insert(text1,Delete_3)

Holder_3.Name = "Holder"
Holder_3.Parent = AliasesFrame
Holder_3.BackgroundTransparency = 1
Holder_3.BorderSizePixel = 0
Holder_3.Position = UDim2.new(0, 0, 0, 0)
Holder_3.Size = UDim2.new(0, 250, 0, 145)
Holder_3.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_3.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.ScrollBarThickness = 0
Holder_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.VerticalScrollBarInset = 'Always'
Holder_3.ZIndex = 10

Example_3.Name = "Example"
Example_3.Parent = AliasesFrame
Example_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_3.BorderSizePixel = 0
Example_3.Size = UDim2.new(0, 10, 0, 20)
Example_3.Visible = false
Example_3.ZIndex = 10
table.insert(shade2,Example_3)

Text_4.Name = "Text"
Text_4.Parent = Example_3
Text_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_4.BorderSizePixel = 0
Text_4.Position = UDim2.new(0, 10, 0, 0)
Text_4.Size = UDim2.new(0, 240, 0, 20)
Text_4.Font = Enum.Font.SourceSans
Text_4.TextSize = 14
Text_4.Text = "honk"
Text_4.TextColor3 = Color3.new(1, 1, 1)
Text_4.TextXAlignment = Enum.TextXAlignment.Left
Text_4.ZIndex = 10
table.insert(shade2,Text_4)
table.insert(text1,Text_4)

Delete_4.Name = "Delete"
Delete_4.Parent = Text_4
Delete_4.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_4.BorderSizePixel = 0
Delete_4.Position = UDim2.new(0, 200, 0, 0)
Delete_4.Size = UDim2.new(0, 40, 0, 20)
Delete_4.Font = Enum.Font.SourceSans
Delete_4.TextSize = 14
Delete_4.Text = "Delete"
Delete_4.TextColor3 = Color3.new(0, 0, 0)
Delete_4.ZIndex = 10
table.insert(shade3,Delete_4)
table.insert(text2,Delete_4)

PluginsFrame.Name = "PluginsFrame"
PluginsFrame.Parent = Settings
PluginsFrame.Active = true
PluginsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PluginsFrame.BorderSizePixel = 0
PluginsFrame.Position = UDim2.new(0, 0, 0, 175)
PluginsFrame.Size = UDim2.new(0, 250, 0, 175)
PluginsFrame.ZIndex = 10
table.insert(shade1,PluginsFrame)

Close_4.Name = "Close"
Close_4.Parent = PluginsFrame
Close_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_4.BorderSizePixel = 0
Close_4.Position = UDim2.new(0, 205, 0, 150)
Close_4.Size = UDim2.new(0, 40, 0, 20)
Close_4.Font = Enum.Font.SourceSans
Close_4.TextSize = 14
Close_4.Text = "Close"
Close_4.TextColor3 = Color3.new(1, 1, 1)
Close_4.ZIndex = 10
table.insert(shade2,Close_4)
table.insert(text1,Close_4)

Add_3.Name = "Add"
Add_3.Parent = PluginsFrame
Add_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_3.BorderSizePixel = 0
Add_3.Position = UDim2.new(0, 5, 0, 150)
Add_3.Size = UDim2.new(0, 40, 0, 20)
Add_3.Font = Enum.Font.SourceSans
Add_3.TextSize = 14
Add_3.Text = "Add"
Add_3.TextColor3 = Color3.new(1, 1, 1)
Add_3.ZIndex = 10
table.insert(shade2,Add_3)
table.insert(text1,Add_3)

Holder_5.Name = "Holder"
Holder_5.Parent = PluginsFrame
Holder_5.BackgroundTransparency = 1
Holder_5.BorderSizePixel = 0
Holder_5.Position = UDim2.new(0, 0, 0, 0)
Holder_5.Selectable = false
Holder_5.Size = UDim2.new(0, 250, 0, 145)
Holder_5.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_5.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_5.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.ScrollBarThickness = 0
Holder_5.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.VerticalScrollBarInset = 'Always'
Holder_5.ZIndex = 10

Example_5.Name = "Example"
Example_5.Parent = PluginsFrame
Example_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_5.BorderSizePixel = 0
Example_5.Size = UDim2.new(0, 10, 0, 20)
Example_5.Visible = false
Example_5.ZIndex = 10
table.insert(shade2,Example_5)

Text_6.Name = "Text"
Text_6.Parent = Example_5
Text_6.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_6.BorderSizePixel = 0
Text_6.Position = UDim2.new(0, 10, 0, 0)
Text_6.Size = UDim2.new(0, 240, 0, 20)
Text_6.Font = Enum.Font.SourceSans
Text_6.TextSize = 14
Text_6.Text = "F4 > Toggle Fly"
Text_6.TextColor3 = Color3.new(1, 1, 1)
Text_6.TextXAlignment = Enum.TextXAlignment.Left
Text_6.ZIndex = 10
table.insert(shade2,Text_6)
table.insert(text1,Text_6)

Delete_7.Name = "Delete"
Delete_7.Parent = Text_6
Delete_7.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_7.BorderSizePixel = 0
Delete_7.Position = UDim2.new(0, 200, 0, 0)
Delete_7.Size = UDim2.new(0, 40, 0, 20)
Delete_7.Font = Enum.Font.SourceSans
Delete_7.TextSize = 14
Delete_7.Text = "Delete"
Delete_7.TextColor3 = Color3.new(0, 0, 0)
Delete_7.ZIndex = 10
table.insert(shade3,Delete_7)
table.insert(text2,Delete_7)

PluginEditor.Name = randomString()
PluginEditor.Parent = ScaledHolder
PluginEditor.BorderSizePixel = 0
PluginEditor.Active = true
PluginEditor.BackgroundTransparency = 1
PluginEditor.Position = UDim2.new(0.5, -180, 0, -500)
PluginEditor.Size = UDim2.new(0, 360, 0, 20)
PluginEditor.ZIndex = 10

background_3.Name = "background"
background_3.Parent = PluginEditor
background_3.Active = true
background_3.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_3.BorderSizePixel = 0
background_3.Position = UDim2.new(0, 0, 0, 20)
background_3.Size = UDim2.new(0, 360, 0, 160)
background_3.ZIndex = 10
table.insert(shade1,background_3)

Dark_2.Name = "Dark"
Dark_2.Parent = background_3
Dark_2.Active = true
Dark_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_2.BorderSizePixel = 0
Dark_2.Position = UDim2.new(0, 222, 0, 0)
Dark_2.Size = UDim2.new(0, 2, 0, 160)
Dark_2.ZIndex = 10
table.insert(shade2,Dark_2)

Img.Name = "Img"
Img.Parent = background_3
Img.BackgroundTransparency = 1
Img.Position = UDim2.new(0, 242, 0, 3)
Img.Size = UDim2.new(0, 100, 0, 95)
Img.Image = getcustomasset("infiniteyield/assets/imgstudiopluginlogo.png")
Img.ZIndex = 10

AddPlugin.Name = "AddPlugin"
AddPlugin.Parent = background_3
AddPlugin.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddPlugin.BorderSizePixel = 0
AddPlugin.Position = UDim2.new(0, 235, 0, 100)
AddPlugin.Size = UDim2.new(0, 115, 0, 50)
AddPlugin.Font = Enum.Font.SourceSans
AddPlugin.TextSize = 14
AddPlugin.Text = "Add Plugin"
AddPlugin.TextColor3 = Color3.new(1, 1, 1)
AddPlugin.ZIndex = 10
table.insert(shade2,AddPlugin)
table.insert(text1,AddPlugin)

FileName.Name = "FileName"
FileName.Parent = background_3
FileName.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FileName.BorderSizePixel = 0
FileName.Position = UDim2.new(0.028, 0, 0.625, 0)
FileName.Size = UDim2.new(0, 200, 0, 50)
FileName.Font = Enum.Font.SourceSans
FileName.TextSize = 14
FileName.Text = "Plugin File Name"
FileName.TextColor3 = Color3.new(1, 1, 1)
FileName.ZIndex = 10
table.insert(shade2,FileName)
table.insert(text1,FileName)

About.Name = "About"
About.Parent = background_3
About.BackgroundTransparency = 1
About.BorderSizePixel = 0
About.Position = UDim2.new(0, 17, 0, 10)
About.Size = UDim2.new(0, 187, 0, 49)
About.Font = Enum.Font.SourceSans
About.TextSize = 14
About.Text = "Plugins are .iy files and should be located in the 'workspace' folder of your exploit."
About.TextColor3 = Color3.fromRGB(255, 255, 255)
About.TextWrapped = true
About.TextYAlignment = Enum.TextYAlignment.Top
About.ZIndex = 10
table.insert(text1,About)

Directions_2.Name = "Directions"
Directions_2.Parent = background_3
Directions_2.BackgroundTransparency = 1
Directions_2.BorderSizePixel = 0
Directions_2.Position = UDim2.new(0, 17, 0, 60)
Directions_2.Size = UDim2.new(0, 187, 0, 49)
Directions_2.Font = Enum.Font.SourceSans
Directions_2.TextSize = 14
Directions_2.Text = "Type the name of the plugin file you want to add below."
Directions_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions_2.TextWrapped = true
Directions_2.TextYAlignment = Enum.TextYAlignment.Top
Directions_2.ZIndex = 10
table.insert(text1,Directions_2)

shadow_3.Name = "shadow"
shadow_3.Parent = PluginEditor
shadow_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_3.BorderSizePixel = 0
shadow_3.Size = UDim2.new(0, 360, 0, 20)
shadow_3.ZIndex = 10
table.insert(shade2,shadow_3)

PopupText_3.Name = "PopupText"
PopupText_3.Parent = shadow_3
PopupText_3.BackgroundTransparency = 1
PopupText_3.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_3.ZIndex = 10
PopupText_3.Font = Enum.Font.SourceSans
PopupText_3.TextSize = 14
PopupText_3.Text = "Add Plugins"
PopupText_3.TextColor3 = Color3.new(1, 1, 1)
PopupText_3.TextWrapped = true
table.insert(text1,PopupText_3)

Exit_3.Name = "Exit"
Exit_3.Parent = shadow_3
Exit_3.BackgroundTransparency = 1
Exit_3.Position = UDim2.new(1, -20, 0, 0)
Exit_3.Size = UDim2.new(0, 20, 0, 20)
Exit_3.Text = ""
Exit_3.ZIndex = 10

ExitImage_3.Parent = Exit_3
ExitImage_3.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_3.BackgroundTransparency = 1
ExitImage_3.Position = UDim2.new(0, 5, 0, 5)
ExitImage_3.Size = UDim2.new(0, 10, 0, 10)
ExitImage_3.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_3.ZIndex = 10

AliasHint.Name = "AliasHint"
AliasHint.Parent = AliasesFrame
AliasHint.BackgroundTransparency = 1
AliasHint.BorderSizePixel = 0
AliasHint.Position = UDim2.new(0, 25, 0, 40)
AliasHint.Size = UDim2.new(0, 200, 0, 50)
AliasHint.Font = Enum.Font.SourceSansItalic
AliasHint.TextSize = 16
AliasHint.Text = "Add aliases by using the 'addalias' command"
AliasHint.TextColor3 = Color3.new(1, 1, 1)
AliasHint.TextStrokeColor3 = Color3.new(1, 1, 1)
AliasHint.TextWrapped = true
AliasHint.ZIndex = 10
table.insert(text1,AliasHint)

PluginsHint.Name = "PluginsHint"
PluginsHint.Parent = PluginsFrame
PluginsHint.BackgroundTransparency = 1
PluginsHint.BorderSizePixel = 0
PluginsHint.Position = UDim2.new(0, 25, 0, 40)
PluginsHint.Size = UDim2.new(0, 200, 0, 50)
PluginsHint.Font = Enum.Font.SourceSansItalic
PluginsHint.TextSize = 16
PluginsHint.Text = "Download plugins from the IY Discord (discord.gg/78ZuWSq)"
PluginsHint.TextColor3 = Color3.new(1, 1, 1)
PluginsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PluginsHint.TextWrapped = true
PluginsHint.ZIndex = 10
table.insert(text1,PluginsHint)

PositionsHint.Name = "PositionsHint"
PositionsHint.Parent = PositionsFrame
PositionsHint.BackgroundTransparency = 1
PositionsHint.BorderSizePixel = 0
PositionsHint.Position = UDim2.new(0, 25, 0, 40)
PositionsHint.Size = UDim2.new(0, 200, 0, 70)
PositionsHint.Font = Enum.Font.SourceSansItalic
PositionsHint.TextSize = 16
PositionsHint.Text = "Use the 'swp' or 'setwaypoint' command to add a position using your character (NOTE: Part teleports will not save)"
PositionsHint.TextColor3 = Color3.new(1, 1, 1)
PositionsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PositionsHint.TextWrapped = true
PositionsHint.ZIndex = 10
table.insert(text1,PositionsHint)

ToPartFrame.Name = randomString()
ToPartFrame.Parent = ScaledHolder
ToPartFrame.Active = true
ToPartFrame.BackgroundTransparency = 1
ToPartFrame.Position = UDim2.new(0.5, -180, 0, -500)
ToPartFrame.Size = UDim2.new(0, 360, 0, 20)
ToPartFrame.ZIndex = 10

background_4.Name = "background"
background_4.Parent = ToPartFrame
background_4.Active = true
background_4.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_4.BorderSizePixel = 0
background_4.Position = UDim2.new(0, 0, 0, 20)
background_4.Size = UDim2.new(0, 360, 0, 117)
background_4.ZIndex = 10
table.insert(shade1,background_4)

ChoosePart.Name = "ChoosePart"
ChoosePart.Parent = background_4
ChoosePart.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ChoosePart.BorderSizePixel = 0
ChoosePart.Position = UDim2.new(0, 100, 0, 55)
ChoosePart.Size = UDim2.new(0, 75, 0, 30)
ChoosePart.Font = Enum.Font.SourceSans
ChoosePart.TextSize = 14
ChoosePart.Text = "Select Part"
ChoosePart.TextColor3 = Color3.new(1, 1, 1)
ChoosePart.ZIndex = 10
table.insert(shade2,ChoosePart)
table.insert(text1,ChoosePart)

CopyPath.Name = "CopyPath"
CopyPath.Parent = background_4
CopyPath.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CopyPath.BorderSizePixel = 0
CopyPath.Position = UDim2.new(0, 185, 0, 55)
CopyPath.Size = UDim2.new(0, 75, 0, 30)
CopyPath.Font = Enum.Font.SourceSans
CopyPath.TextSize = 14
CopyPath.Text = "Copy Path"
CopyPath.TextColor3 = Color3.new(1, 1, 1)
CopyPath.ZIndex = 10
table.insert(shade2,CopyPath)
table.insert(text1,CopyPath)

Directions_3.Name = "Directions"
Directions_3.Parent = background_4
Directions_3.BackgroundTransparency = 1
Directions_3.BorderSizePixel = 0
Directions_3.Position = UDim2.new(0, 51, 0, 17)
Directions_3.Size = UDim2.new(0, 257, 0, 32)
Directions_3.Font = Enum.Font.SourceSans
Directions_3.TextSize = 14
Directions_3.Text = 'Click on a part and then click the "Select Part" button below to set it as a teleport location'
Directions_3.TextColor3 = Color3.new(1, 1, 1)
Directions_3.TextWrapped = true
Directions_3.TextYAlignment = Enum.TextYAlignment.Top
Directions_3.ZIndex = 10
table.insert(text1,Directions_3)

Path.Name = "Path"
Path.Parent = background_4
Path.BackgroundTransparency = 1
Path.BorderSizePixel = 0
Path.Position = UDim2.new(0, 0, 0, 94)
Path.Size = UDim2.new(0, 360, 0, 16)
Path.Font = Enum.Font.SourceSansItalic
Path.TextSize = 14
Path.Text = ""
Path.TextColor3 = Color3.new(1, 1, 1)
Path.TextScaled = true
Path.TextWrapped = true
Path.TextYAlignment = Enum.TextYAlignment.Top
Path.ZIndex = 10
table.insert(text1,Path)

shadow_4.Name = "shadow"
shadow_4.Parent = ToPartFrame
shadow_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_4.BorderSizePixel = 0
shadow_4.Size = UDim2.new(0, 360, 0, 20)
shadow_4.ZIndex = 10
table.insert(shade2,shadow_4)

PopupText_5.Name = "PopupText"
PopupText_5.Parent = shadow_4
PopupText_5.BackgroundTransparency = 1
PopupText_5.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_5.ZIndex = 10
PopupText_5.Font = Enum.Font.SourceSans
PopupText_5.TextSize = 14
PopupText_5.Text = "Teleport to Part"
PopupText_5.TextColor3 = Color3.new(1, 1, 1)
PopupText_5.TextWrapped = true
table.insert(text1,PopupText_5)

Exit_4.Name = "Exit"
Exit_4.Parent = shadow_4
Exit_4.BackgroundTransparency = 1
Exit_4.Position = UDim2.new(1, -20, 0, 0)
Exit_4.Size = UDim2.new(0, 20, 0, 20)
Exit_4.Text = ""
Exit_4.ZIndex = 10

ExitImage_5.Parent = Exit_4
ExitImage_5.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_5.BackgroundTransparency = 1
ExitImage_5.Position = UDim2.new(0, 5, 0, 5)
ExitImage_5.Size = UDim2.new(0, 10, 0, 10)
ExitImage_5.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_5.ZIndex = 10

logs.Name = randomString()
logs.Parent = ScaledHolder
logs.Active = true
logs.BackgroundTransparency = 1
logs.Position = UDim2.new(0, 0, 1, 10)
logs.Size = UDim2.new(0, 338, 0, 20)
logs.ZIndex = 10

shadow.Name = "shadow"
shadow.Parent = logs
shadow.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 0, 0.00999999978, 0)
shadow.Size = UDim2.new(0, 338, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

Hide.Name = "Hide"
Hide.Parent = shadow
Hide.BackgroundTransparency = 1
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.ZIndex = 10
Hide.Text = ""

ImageLabel.Parent = Hide
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 3, 0, 3)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.Image = getcustomasset("infiniteyield/assets/minimize.png")
ImageLabel.ZIndex = 10

PopupText.Name = "PopupText"
PopupText.Parent = shadow
PopupText.BackgroundTransparency = 1
PopupText.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText.ZIndex = 10
PopupText.Font = Enum.Font.SourceSans
PopupText.FontSize = Enum.FontSize.Size14
PopupText.Text = "Logs"
PopupText.TextColor3 = Color3.new(1, 1, 1)
PopupText.TextWrapped = true
table.insert(text1,PopupText)

Exit.Name = "Exit"
Exit.Parent = shadow
Exit.BackgroundTransparency = 1
Exit.Position = UDim2.new(1, -20, 0, 0)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.ZIndex = 10
Exit.Text = ""

ImageLabel_2.Parent = Exit
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.Image = getcustomasset("infiniteyield/assets/close.png")
ImageLabel_2.ZIndex = 10

background.Name = "background"
background.Parent = logs
background.Active = true
background.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
background.BorderSizePixel = 0
background.ClipsDescendants = true
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(0, 338, 0, 245)
background.ZIndex = 10

chat.Name = "chat"
chat.Parent = background
chat.Active = true
chat.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
chat.BorderSizePixel = 0
chat.ClipsDescendants = true
chat.Size = UDim2.new(0, 338, 0, 245)
chat.ZIndex = 10
table.insert(shade1,chat)

Clear.Name = "Clear"
Clear.Parent = chat
Clear.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 5, 0, 220)
Clear.Size = UDim2.new(0, 50, 0, 20)
Clear.ZIndex = 10
Clear.Font = Enum.Font.SourceSans
Clear.FontSize = Enum.FontSize.Size14
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear)
table.insert(text1,Clear)

SaveChatlogs.Name = "SaveChatlogs"
SaveChatlogs.Parent = chat
SaveChatlogs.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
SaveChatlogs.BorderSizePixel = 0
SaveChatlogs.Position = UDim2.new(0, 258, 0, 220)
SaveChatlogs.Size = UDim2.new(0, 75, 0, 20)
SaveChatlogs.ZIndex = 10
SaveChatlogs.Font = Enum.Font.SourceSans
SaveChatlogs.FontSize = Enum.FontSize.Size14
SaveChatlogs.Text = "Save To .txt"
SaveChatlogs.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,SaveChatlogs)
table.insert(text1,SaveChatlogs)

Toggle.Name = "Toggle"
Toggle.Parent = chat
Toggle.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 60, 0, 220)
Toggle.Size = UDim2.new(0, 66, 0, 20)
Toggle.ZIndex = 10
Toggle.Font = Enum.Font.SourceSans
Toggle.FontSize = Enum.FontSize.Size14
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle)
table.insert(text1,Toggle)

scroll_2.Name = "scroll"
scroll_2.Parent = chat
scroll_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_2.BorderSizePixel = 0
scroll_2.Position = UDim2.new(0, 5, 0, 25)
scroll_2.Size = UDim2.new(0, 328, 0, 190)
scroll_2.ZIndex = 10
scroll_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_2.ScrollBarThickness = 8
scroll_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_2)
table.insert(shade2,scroll_2)

join.Name = "join"
join.Parent = background
join.Active = true
join.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
join.BorderSizePixel = 0
join.ClipsDescendants = true
join.Size = UDim2.new(0, 338, 0, 245)
join.Visible = false
join.ZIndex = 10
table.insert(shade1,join)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = join
Toggle_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle_2.BorderSizePixel = 0
Toggle_2.Position = UDim2.new(0, 60, 0, 220)
Toggle_2.Size = UDim2.new(0, 66, 0, 20)
Toggle_2.ZIndex = 10
Toggle_2.Font = Enum.Font.SourceSans
Toggle_2.FontSize = Enum.FontSize.Size14
Toggle_2.Text = "Disabled"
Toggle_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle_2)
table.insert(text1,Toggle_2)

Clear_2.Name = "Clear"
Clear_2.Parent = join
Clear_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 5, 0, 220)
Clear_2.Size = UDim2.new(0, 50, 0, 20)
Clear_2.ZIndex = 10
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontSize = Enum.FontSize.Size14
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear_2)
table.insert(text1,Clear_2)

scroll_3.Name = "scroll"
scroll_3.Parent = join
scroll_3.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_3.BorderSizePixel = 0
scroll_3.Position = UDim2.new(0, 5, 0, 25)
scroll_3.Size = UDim2.new(0, 328, 0, 190)
scroll_3.ZIndex = 10
scroll_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_3.ScrollBarThickness = 8
scroll_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_3)
table.insert(shade2,scroll_3)

selectChat.Name = "selectChat"
selectChat.Parent = background
selectChat.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
selectChat.BorderSizePixel = 0
selectChat.Position = UDim2.new(0, 5, 0, 5)
selectChat.Size = UDim2.new(0, 164, 0, 20)
selectChat.ZIndex = 10
selectChat.Font = Enum.Font.SourceSans
selectChat.FontSize = Enum.FontSize.Size14
selectChat.Text = "Chat Logs"
selectChat.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,selectChat)
table.insert(text1,selectChat)

selectJoin.Name = "selectJoin"
selectJoin.Parent = background
selectJoin.BackgroundColor3 = Color3.new(0.305882, 0.305882, 0.309804)
selectJoin.BorderSizePixel = 0
selectJoin.Position = UDim2.new(0, 169, 0, 5)
selectJoin.Size = UDim2.new(0, 164, 0, 20)
selectJoin.ZIndex = 10
selectJoin.Font = Enum.Font.SourceSans
selectJoin.FontSize = Enum.FontSize.Size14
selectJoin.Text = "Join Logs"
selectJoin.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade3,selectJoin)
table.insert(text1,selectJoin)

function create(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

ViewportTextBox = (function()

	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

ViewportTextBox.convert(Cmdbar).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_2).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_3).View.ZIndex = 10

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

function vtype(o, t)
	if o == nil then return false end
	if type(o) == "userdata" then return typeof(o) == t end
	return type(o) == t
end

function getRoot(char)
    if not char then return nil end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid and humanoid.RootPart then return humanoid.RootPart end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

function tools(plr)
    if not plr then return false end
    local pack = plr:FindFirstChildOfClass("Backpack")
    local char = plr.Character
    return (pack and pack:FindFirstChildWhichIsA("Tool") ~= nil)
        or (char and char:FindFirstChildWhichIsA("Tool") ~= nil) or false
end

function r15(plr)
    local char = plr and plr.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    return hum ~= nil and hum.RigType == Enum.HumanoidRigType.R15
end

function breakVelocity()
    local V3 = Vector3.new(0, 0, 0)
    for _, v in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = V3, V3
        end
    end
end

function toClipboard(txt)
    if type(everyClipboard) ~= "function" then
        notify("Clipboard", "Clipboard API is unavailable in this environment")
        return false
    end
    local ok, problem = pcall(everyClipboard, tostring(txt or ""))
    if ok then notify("Clipboard", "Copied to clipboard")
    else notify("Clipboard", "Copy failed: " .. tostring(problem):sub(1, 130)) end
    return ok
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

AllWaypoints = {}

-- NOVA: coalesce rapid saves by filename, never recursively spawn retry jobs.
local pendingWrites = {}
local flushingWrites = false
function writefileCooldown(name, data)
    if type(writefile) ~= "function" or type(name) ~= "string" then return end
    pendingWrites[name] = data
    if flushingWrites then return end
    flushingWrites = true
    task.spawn(function()
        while next(pendingWrites) do
            task.wait(0.4)
            local batch = pendingWrites
            pendingWrites = {}
            for path, payload in pairs(batch) do
                local ok, wrote = pcall(writefile, path, payload, true)
                if (not ok or wrote == false) and _G.IY_DEBUG then
                    warn("IY settings write failed:", path)
                end
            end
        end
        flushingWrites = false
    end)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			-- Dragging shouldn't allocate a fresh Tween object per mouse event.
			gui.Position = position
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						if cmdStr:lower():match("plugin") then return end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end

	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderSizePixel=0,Name="EventEditor",Position=UDim2.new(0.5,-175,0,-500),Size=UDim2.new(0,350,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=currentShade2,BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0.95,0),Text="Event Editor",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,202),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={6},Position=UDim2.new(0,5,0,5),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,-10,1,-10),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{8,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={7},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{9,"UIListLayout",{Parent={8},SortOrder=2,}},
		{10,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,ClipsDescendants=true,Name="Settings",Parent={6},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,150,1,0),ZIndex=10,}},
		{11,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),Name="Slider",Parent={10},Position=UDim2.new(0,-150,0,0),Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.23529413342476,0.23529413342476,0.23529413342476),BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="Line",Parent={11},Size=UDim2.new(0,1,1,0),ZIndex=10,}},
		{13,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={11},Position=UDim2.new(0,0,0,25),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,-25),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={13},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{15,"UIListLayout",{Parent={14},SortOrder=2,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={11},Size=UDim2.new(1,0,0,20),Text="Event Settings",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{17,"TextButton",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Font=3,Name="Close",BorderSizePixel=0,Parent={11},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="<",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{18,"Folder",{Name="Templates",Parent={10},}},
		{19,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Players",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,86),Visible=false,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={19},Size=UDim2.new(1,0,0,20),Text="Choose Players",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{21,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={19},Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-10,0,20),Text="Any Player",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{22,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={21},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{23,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={22},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{24,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Me",Parent={19},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Me Only",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{25,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={24},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{26,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={25},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{27,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={19},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Custom Player Set",Position=UDim2.new(0,5,0,64),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{28,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={19},Position=UDim2.new(1,-25,0,64),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{29,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={28},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Strings",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={30},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={30},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any String",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={32},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{34,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={33},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Numbers",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={54},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any Number",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={56},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{58,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={57},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{59,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={54},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Number",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={54},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{61,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={60},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{35,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={30},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Match String",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={30},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{37,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={36},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{38,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="DelayEditor",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,24),Visible=false,ZIndex=10,}},
		{39,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Font=3,Name="Secs",Parent={38},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),Position=UDim2.new(0,60,0,2),Size=UDim2.new(1,-65,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Label",Parent={39},Position=UDim2.new(0,-55,0,0),Size=UDim2.new(1,0,1,0),Text="Delay (s):",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{41,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="EventTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{42,"TextButton",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="Expand",Parent={41},Size=UDim2.new(0,20,0,20),Text=">",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="EventName",Parent={41},Position=UDim2.new(0,25,0,0),Size=UDim2.new(1,-25,0,20),Text="OnSpawn",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{44,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BorderSizePixel=0,BackgroundTransparency=1,ClipsDescendants=true,Name="Cmds",Parent={41},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Name="Add",Parent={44},Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{46,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={45},PlaceholderColor3=Color3.new(0.7843137383461,0.7843137383461,0.7843137383461),PlaceholderText="Add new command",Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{47,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={44},Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{48,"UIListLayout",{Parent={47},SortOrder=2,}},
		{49,"Frame",{currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="CmdTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{50,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={49},PlaceholderColor3=Color3.new(1,1,1),Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-45,0,20),Text="a\\b\\c\\d",TextColor3=currentText1,TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{51,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Delete",Parent={49},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="X",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{52,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Settings",Parent={49},Position=UDim2.new(1,-40,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{53,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/settings.png"),Parent={52},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),ZIndex=10,}},
	})
	main.Name = randomString()
	local mainFrame = main:WaitForChild("Content")
	local eventList = mainFrame:WaitForChild("List")
	local eventListHolder = eventList:WaitForChild("Holder")
	local cmdTemplate = mainFrame:WaitForChild("CmdTemplate")
	local eventTemplate = mainFrame:WaitForChild("EventTemplate")
	local settingsFrame = mainFrame:WaitForChild("Settings"):WaitForChild("Slider")
	local settingsTemplates = mainFrame.Settings:WaitForChild("Templates")
	local settingsList = settingsFrame:WaitForChild("List"):WaitForChild("Holder")
	table.insert(shade2,main.TopBar) table.insert(shade1,mainFrame) table.insert(shade2,eventTemplate)
	table.insert(text1,eventTemplate.EventName) table.insert(shade1,eventTemplate.Cmds.Add) table.insert(shade1,cmdTemplate)
	table.insert(text1,cmdTemplate.TextBox) table.insert(shade2,cmdTemplate.Delete) table.insert(shade2,cmdTemplate.Settings)
	table.insert(scroll,mainFrame.List) table.insert(shade1,settingsFrame) table.insert(shade2,settingsFrame.Line)
	table.insert(shade2,settingsFrame.Close) table.insert(scroll,settingsFrame.List) table.insert(shade2,settingsTemplates.DelayEditor.Secs)
	table.insert(text1,settingsTemplates.DelayEditor.Secs) table.insert(text1,settingsTemplates.DelayEditor.Secs.Label) table.insert(text1,settingsTemplates.Players.Title)
	table.insert(shade3,settingsTemplates.Players.CustomButton) table.insert(shade2,settingsTemplates.Players.Custom) table.insert(text1,settingsTemplates.Players.Custom)
	table.insert(shade3,settingsTemplates.Players.Any.Button) table.insert(shade3,settingsTemplates.Players.Me.Button) table.insert(text1,settingsTemplates.Players.Any)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Strings.Title) table.insert(text1,settingsTemplates.Strings.Any)
	table.insert(shade3,settingsTemplates.Strings.Any.Button) table.insert(shade3,settingsTemplates.Strings.CustomButton) table.insert(text1,settingsTemplates.Strings.Custom)
	table.insert(shade2,settingsTemplates.Strings.Custom)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Numbers.Title) table.insert(text1,settingsTemplates.Numbers.Any)
	table.insert(shade3,settingsTemplates.Numbers.Any.Button) table.insert(shade3,settingsTemplates.Numbers.CustomButton) table.insert(text1,settingsTemplates.Numbers.Custom)
	table.insert(shade2,settingsTemplates.Numbers.Custom)

	local tweenInf = TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	local currentlyEditingCmd = nil

	settingsFrame:WaitForChild("Close").MouseButton1Click:Connect(function()
		settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end)

	local function resizeList()
		local size = 0

		for i,v in pairs(eventListHolder:GetChildren()) do
			if v.Name == "EventTemplate" then
				size = size + 20
				if v.Expand.Rotation == 90 then
					size = size + 20*(1+(#events[v.EventName:GetAttribute("RawName")].commands or 0))
				end
			end
		end

		TweenService:Create(eventList,tweenInf,{CanvasSize = UDim2.new(0,0,0,size)}):Play()

		if size > eventList.AbsoluteSize.Y then
			eventListHolder.Size = UDim2.new(1,-8,1,0)
		else
			eventListHolder.Size = UDim2.new(1,0,1,0)
		end
	end

	local function resizeSettingsList()
		local size = 0

		for i,v in pairs(settingsList:GetChildren()) do
			if v:IsA("Frame") then
				size = size + v.AbsoluteSize.Y
			end
		end

		settingsList.Parent.CanvasSize = UDim2.new(0,0,0,size)

		if size > settingsList.Parent.AbsoluteSize.Y then
			settingsList.Size = UDim2.new(1,-8,1,0)
		else
			settingsList.Size = UDim2.new(1,0,1,0)
		end
	end

	local function setupCheckbox(button,callback)
		local enabled = button.On.BackgroundTransparency == 0

		local function update()
			button.On.BackgroundTransparency = (enabled and 0 or 1)
		end

		button.On.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			if callback then callback(enabled) end
		end)

		return {
			Toggle = function(nocall) enabled = not enabled update() if not nocall and callback then callback(enabled) end end,
			Enable = function(nocall) if enabled then return end enabled = true update()if not nocall and callback then callback(enabled) end end,
			Disable = function(nocall) if not enabled then return end enabled = false update()if not nocall and callback then callback(enabled) end end,
			IsEnabled = function() return enabled end
		}
	end

	local function openSettingsEditor(event,cmd)
		currentlyEditingCmd = cmd

		for i,v in pairs(settingsList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		local delayEditor = settingsTemplates.DelayEditor:Clone()
		delayEditor.Secs.FocusLost:Connect(function()
			cmd[3] = tonumber(delayEditor.Secs.Text) or 0
			delayEditor.Secs.Text = cmd[3]
			if onEdited then onEdited() end
		end)
		delayEditor.Secs.Text = cmd[3]
		delayEditor.Visible = true
		table.insert(shade2,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs.Label)
		delayEditor.Parent = settingsList

		for i,v in pairs(event.sets) do
			if v.Type == "Player" then
				local template = settingsTemplates.Players:Clone()
				template.Title.Text = v.Name or "Player"

				local me,any,custom

				me = setupCheckbox(template.Me.Button,function(on)
					if not on then return end
					any.Disable()
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					me.Disable()
					custom.Disable()
					cmd[2][i] = 1
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					me.Disable()
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					me:Enable()
				elseif cVal == 1 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(shade3,template.CustomButton)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.Me.Button)
				table.insert(text1,template.Any)
				table.insert(text1,template.Me)
				template.Parent = settingsList
			elseif v.Type == "String" then
				local template = settingsTemplates.Strings:Clone()
				template.Title.Text = v.Name or "String"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			elseif v.Type == "Number" then
				local template = settingsTemplates.Numbers:Clone()
				template.Title.Text = v.Name or "Number"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					cmd[2][i] = tonumber(customTextBox.Text) or 0
					customTextBox.Text = cmd[2][i]
					if custom:IsEnabled() then
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			end
		end
		resizeSettingsList()
		settingsFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end

	local function defaultSettings(ev)
		local res = {}

		for i,v in pairs(ev.sets) do
			if v.Type == "Player" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res+1] = v.Default or 0
			end
		end

		return res
	end

	local function refreshList()
		for i,v in pairs(eventListHolder:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		for name,event in pairs(events) do
			local eventF = eventTemplate:Clone()
			eventF.EventName.Text = name
			eventF.Visible = true
			eventF.EventName:SetAttribute("RawName", name)
			table.insert(shade2,eventF)
			table.insert(text1,eventF.EventName)
			table.insert(shade1,eventF.Cmds.Add)

			local expanded = false
			eventF.Expand.MouseButton1Down:Connect(function()
				expanded = not expanded
				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				eventF.Expand.Rotation = expanded and 90 or 0
				resizeList()
			end)

			local function refreshCommands()
				for i,v in pairs(eventF.Cmds.Holder:GetChildren()) do
					if v.Name == "CmdTemplate" then
						v:Destroy()
					end
				end

				eventF.EventName.Text = name..(#event.commands > 0 and " ("..#event.commands..")" or "")

				for i,cmd in pairs(event.commands) do
					local cmdF = cmdTemplate:Clone()
					local cmdTextBox = cmdF.TextBox
					ViewportTextBox.convert(cmdTextBox)
					cmdTextBox.Text = cmd[1]
					cmdF.Visible = true
					table.insert(shade1,cmdF)
					table.insert(shade2,cmdF.Delete)
					table.insert(shade2,cmdF.Settings)

					cmdTextBox.FocusLost:Connect(function()
						event.commands[i] = {cmdTextBox.Text,cmd[2],cmd[3]}
						if onEdited then onEdited() end
					end)

					cmdF.Settings.MouseButton1Click:Connect(function()
						openSettingsEditor(event,cmd)
					end)

					cmdF.Delete.MouseButton1Click:Connect(function()
						table.remove(event.commands,i)
						refreshCommands()
						resizeList()

						if currentlyEditingCmd == cmd then
							settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						if onEdited then onEdited() end
					end)

					cmdF.Parent = eventF.Cmds.Holder
				end

				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			end

			local newBox = eventF.Cmds.Add.TextBox
			ViewportTextBox.convert(newBox)
			newBox.FocusLost:Connect(function(enter)
				if enter then
					event.commands[#event.commands+1] = {newBox.Text,defaultSettings(event),0}
					newBox.Text = ""

					refreshCommands()
					resizeList()
					if onEdited then onEdited() end
				end
			end)

			--eventF:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeList)

			eventF.Parent = eventListHolder

			refreshCommands()
		end

		resizeList()
	end

	local function saveData()
		local result = {}
		for i,v in pairs(events) do
			result[i] = v.commands
		end
		return HttpService:JSONEncode(result)
	end

	local function loadData(str)
		local data = HttpService:JSONDecode(str)
		for i,v in pairs(data) do
			if events[i] then
				events[i].commands = v
			end
		end
	end

	local function addCmd(event,data)
		table.insert(events[event].commands,data)
	end

	local function setOnEdited(f)
		if type(f) == "function" then
			onEdited = f
		end
	end

	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-175,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		Refresh = refreshList,
		SaveData = saveData,
		LoadData = loadData,
		AddCmd = addCmd,
		Frame = main,
		SetOnEdited = setOnEdited
	}
end)()

reference = (function()
	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="Main",Position=UDim2.new(0.5,-250,0,-500),Size=UDim2.new(0,500,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Size=UDim2.new(1,0,0.94999998807907,0),Text="Reference",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,300),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,1313),Name="List",Parent={6},ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,0),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",VerticalScrollBarInset=2,ZIndex=10,}},
		{8,"UIListLayout",{Parent={7},SortOrder=2,}},
		{9,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,429),ZIndex=10,}},
		{10,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={9},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Special Player Cases",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={9},Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-8,0,20),Text="These keywords can be used to quickly select groups of players in commands:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={9},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{13,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Cases",Parent={9},Position=UDim2.new(0,8,0,55),Size=UDim2.new(1,-16,0,342),ZIndex=10,}},
		{14,"UIListLayout",{Parent={13},SortOrder=2,}},
		{15,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={15},Size=UDim2.new(1,0,1,0),Text="all",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={15},Position=UDim2.new(0,15,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{18,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-3,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{19,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={18},Size=UDim2.new(1,0,1,0),Text="others",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={18},Position=UDim2.new(0,37,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone except you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{21,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-2,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{22,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={21},Size=UDim2.new(1,0,1,0),Text="me",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{23,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={21},Position=UDim2.new(0,19,0,0),Size=UDim2.new(1,0,1,0),Text="- includes your player only",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{24,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{25,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={24},Size=UDim2.new(1,0,1,0),Text="#[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{26,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={24},Position=UDim2.new(0,59,0,0),Size=UDim2.new(1,0,1,0),Text="- gets a specified amount of random players",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{27,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{28,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={27},Size=UDim2.new(1,0,1,0),Text="random",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{29,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={27},Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,0,1,0),Text="- affects a random player",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={30},Size=UDim2.new(1,0,1,0),Text="%[team name]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={30},Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone on a given team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{34,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={33},Size=UDim2.new(1,0,1,0),Text="allies / team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{35,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={33},Position=UDim2.new(0,63,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{37,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={36},Size=UDim2.new(1,0,1,0),Text="enemies / nonteam",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={36},Position=UDim2.new(0,101,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are not on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{39,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={39},Size=UDim2.new(1,0,1,0),Text="friends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{41,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={39},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{42,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={42},Size=UDim2.new(1,0,1,0),Text="nonfriends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{44,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={42},Position=UDim2.new(0,61,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is not friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{46,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={45},Size=UDim2.new(1,0,1,0),Text="guests",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{47,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={45},Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,0,1,0),Text="- guest players (obsolete)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{48,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{49,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={48},Size=UDim2.new(1,0,1,0),Text="bacons",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{50,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={48},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone with the \"bacon\" or pal hair",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{51,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={51},Size=UDim2.new(1,0,1,0),Text="age[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{53,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={51},Position=UDim2.new(0,71,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone below or at the given age",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={54},Size=UDim2.new(1,0,1,0),Text="rad[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={54},Position=UDim2.new(0,70,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone within the given radius",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{58,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={57},Size=UDim2.new(1,0,1,0),Text="nearest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{59,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={57},Position=UDim2.new(0,43,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the closest player to you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{61,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={60},Size=UDim2.new(1,0,1,0),Text="farthest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{62,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={60},Position=UDim2.new(0,46,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the farthest player from you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{63,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{64,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={63},Size=UDim2.new(1,0,1,0),Text="group[ID]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{65,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={63},Position=UDim2.new(0,55,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are in a certain group",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{66,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={66},Size=UDim2.new(1,0,1,0),Text="alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{68,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={66},Position=UDim2.new(0,27,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{69,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{70,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={69},Size=UDim2.new(1,0,1,0),Text="dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{71,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={69},Position=UDim2.new(0,29,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{72,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{73,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={72},Size=UDim2.new(1,0,1,0),Text="@username",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{74,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={72},Position=UDim2.new(0,66,0,0),Size=UDim2.new(1,0,1,0),Text="- searches for players by username only (ignores displaynames)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{75,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,180),ZIndex=10,}},
		{76,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={75},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Various Operators",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{77,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={75},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{78,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,16),Text="Use commas to separate multiple expressions:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{79,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,75),Size=UDim2.new(1,-8,0,16),Text="Use - to exclude, and + to include players in your expression:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{80,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,91),Size=UDim2.new(1,-8,0,16),Text=";locate %blue-friends (gets players in blue team who aren't your friends)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,46),Size=UDim2.new(1,-8,0,16),Text=";locate noob,noob2,bob",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{82,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,120),Size=UDim2.new(1,-8,0,16),Text="Put ! before a command to run it with the last arguments it was ran with:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{83,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,136),Size=UDim2.new(1,-8,0,32),Text="After running ;offset 0 100 0,  you can run !offset anytime to repeat that command with the same arguments that were used to run it last time",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,154),ZIndex=10,}},
		{85,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={84},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Command Looping",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{86,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="Form: [How many times it loops]^[delay (optional)]^[command]",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{87,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={84},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{88,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,50),Size=UDim2.new(1,-8,0,20),Text="Use the 'breakloops' command to stop all running loops.",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{89,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,80),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{90,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,98),Size=UDim2.new(1,-8,0,42),Text=";5^btools - gives you 5 sets of btools\n;10^3^drophats - drops your hats every 3 seconds 10 times\n;inf^0.1^animspeed 100 - infinitely loops your animation speed to 100",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{91,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,120),ZIndex=10,}},
		{92,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Execute Multiple Commands at Once",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{93,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="You can execute multiple commands at once using \"\\\"",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{94,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={91},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{96,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={91},Position=UDim2.new(0,8,0,78),Size=UDim2.new(1,-8,0,32),Text=";drophats\\respawn - drops your hats and respawns you\n;enable inventory\\enable playerlist\\refresh - enables those coregui items and refreshes you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{97,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{98,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={97},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Browse Command History",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{99,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={97},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the up and down arrow keys to browse recently used commands",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{100,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={97},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{101,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{102,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={101},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Autocomplete in the Command Bar",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{103,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={101},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the tab key to insert the top suggested command into the command bar.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{104,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={101},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{105,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,175),ZIndex=10,}},
		{106,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={105},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Using Event Binds",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{107,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="Use event binds to set up commands that get executed when certain events happen. You can edit the conditions for an event command to run (such as which player triggers it).",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{108,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={105},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{109,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,70),Size=UDim2.new(1,-8,0,48),Text="Some events may send arguments; you can use them in your event command by using $ followed by the argument number ($1, $2, etc). You can find out the order and types of these arguments by looking at the settings of the event command.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{110,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={105},Position=UDim2.new(0,8,0,130),Size=UDim2.new(1,-8,0,16),Text="Example:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{111,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,148),Size=UDim2.new(1,-8,0,16),Text="Setting up 'goto $1' on the OnChatted event will teleport you to any player that chats.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{112,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,105),ZIndex=10,}},
		{113,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={112},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Get Further Help",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{114,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={112},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="You can join the Discord server to get support with IY,  and read up on more documentation such as the Plugin API.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{115,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={112},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),Visible=false,ZIndex=10,}},
		{116,"TextButton",{BackgroundColor3=Color3.new(0.48627451062202,0.61960786581039,0.85098040103912),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Font=4,Name="InviteButton",Parent={112},Position=UDim2.new(0,5,0,75),Size=UDim2.new(1,-10,0,25),Text="Copy Discord Invite Link (https://discord.gg/78ZuWSq)",TextColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),TextSize=16,ZIndex=10,}},
	})
	for i,v in pairs(main.Content.List:GetDescendants()) do
		if v:IsA("TextLabel") then
			table.insert(text1,v)
		end
	end
	table.insert(scroll,main.Content.List)
	table.insert(shade1,main.Content)
	table.insert(shade2,main.TopBar)
	main.Name = randomString()
	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	local inviteButton = main:FindFirstChild("InviteButton",true)
	local lastPress = nil
	inviteButton.MouseButton1Click:Connect(function()
		if everyClipboard then
			toClipboard("https://discord.gg/78ZuWSq")
			inviteButton.Text = "Copied"
		else
			inviteButton.Text = "No Clipboard Function, type out the link"
		end
		local pressTime = tick()
		lastPress = pressTime
		wait(2)
		if lastPress ~= pressTime then return end
		inviteButton.Text = "Copy Discord Invite Link (https://discord.gg/78ZuWSq)"
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	ReferenceButton.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0.5,-150), "InOut", "Quart", 0.5, true, nil)
	end)
end)()

currentShade1 = Color3.fromRGB(36, 36, 37)
currentShade2 = Color3.fromRGB(46, 46, 47)
currentShade3 = Color3.fromRGB(78, 78, 79)
currentText1 = Color3.new(1, 1, 1)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(78,78,79)

defaultGuiScale = IsOnMobile and 0.9 or 1
defaultsettings = {
	prefix = ';';
	StayOpen = false;
	guiScale = defaultGuiScale;
	espTransparency = 0.3;
	keepIY = true;
	logsEnabled = false;
	jLogsEnabled = false;
	aliases = {};
	binds = {};
	WayPoints = {};
	PluginsTable = {};
	currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
	currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
	currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
	currentText1 = {currentText1.R,currentText1.G,currentText1.B};
	currentText2 = {currentText2.R,currentText2.G,currentText2.B};
	currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
	eventBinds = eventEditor.SaveData()
}

defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
useFactorySettings = function()
	prefix = ';'
	StayOpen = false
	guiScale = defaultGuiScale
	KeepInfYield = true
	espTransparency = 0.3
	logsEnabled = false
	jLogsEnabled = false
	logsWebhook = nil
	aliases = {}
	binds = {}
	WayPoints = {}
	PluginsTable = {}
end

function createPopup(title, text)
	local Popup = Instance.new("Frame")
	local background = Instance.new("Frame")
	local Directions = Instance.new("TextLabel")
	local shadow = Instance.new("Frame")
	local PopupText = Instance.new("TextLabel")
	local Exit = Instance.new("TextButton")
	local ExitImage = Instance.new("ImageLabel")

	Popup.Name = randomString()
	Popup.Parent = ScaledHolder
	Popup.Active = true
	Popup.BackgroundTransparency = 1
	Popup.Position = UDim2.new(0.5, -180, 0, -500)
	Popup.Size = UDim2.new(0, 360, 0, 20)
	Popup.ZIndex = 10

	background.Name = "background"
	background.Parent = Popup
	background.Active = true
	background.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
	background.BorderSizePixel = 0
	background.Position = UDim2.new(0, 0, 0, 20)
	background.Size = UDim2.new(0, 360, 0, 205)
	background.ZIndex = 10

	Directions.Name = "Directions"
	Directions.Parent = background
	Directions.BackgroundTransparency = 1
	Directions.BorderSizePixel = 0
	Directions.Position = UDim2.new(0, 10, 0, 10)
	Directions.Size = UDim2.new(0, 340, 0, 185)
	Directions.Font = Enum.Font.SourceSans
	Directions.TextSize = 14
	Directions.Text = text
	Directions.TextColor3 = Color3.new(1, 1, 1)
	Directions.TextWrapped = true
	Directions.TextXAlignment = Enum.TextXAlignment.Left
	Directions.TextYAlignment = Enum.TextYAlignment.Top
	Directions.ZIndex = 10

	shadow.Name = "shadow"
	shadow.Parent = Popup
	shadow.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	shadow.BorderSizePixel = 0
	shadow.Size = UDim2.new(0, 360, 0, 20)
	shadow.ZIndex = 10

	PopupText.Name = "PopupText"
	PopupText.Parent = shadow
	PopupText.BackgroundTransparency = 1
	PopupText.Size = UDim2.new(1, 0, 0.95, 0)
	PopupText.ZIndex = 10
	PopupText.Font = Enum.Font.SourceSans
	PopupText.TextSize = 14
	PopupText.Text = title
	PopupText.TextColor3 = Color3.new(1, 1, 1)
	PopupText.TextWrapped = true

	Exit.Name = "Exit"
	Exit.Parent = shadow
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -20, 0, 0)
	Exit.Size = UDim2.new(0, 20, 0, 20)
	Exit.Text = ""
	Exit.ZIndex = 10

	ExitImage.Parent = Exit
	ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
	ExitImage.BackgroundTransparency = 1
	ExitImage.Position = UDim2.new(0, 5, 0, 5)
	ExitImage.Size = UDim2.new(0, 10, 0, 10)
	ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
	ExitImage.ZIndex = 10

	Popup:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

	Exit.MouseButton1Click:Connect(function()
		Popup:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
		task.wait(0.6)
		Popup:Destroy()
	end)
end

local loadedEventData = nil
local jsonAttempts = 0
function saves()
	if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
		local readSuccess, out = readfile("IY_FE.iy", true)
		if readSuccess then
			if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
				local success, response = pcall(function()
					local json = HttpService:JSONDecode(out)
					if vtype(json.prefix, "string") then prefix = json.prefix else prefix = ';' end
					if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
					if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
					if vtype(json.keepIY, "boolean") then KeepInfYield = json.keepIY else KeepInfYield = true end
					if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
					if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
					if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
					if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
					if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
					if vtype(json.binds, "table") then binds = json.binds else binds = {} end
					if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
					if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
					if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
					if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
					if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
					if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
					if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
					if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
					if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
					if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
				end)
				if not success then
					-- Preserve the original file for manual recovery; do not wipe it.
					jsonAttempts = jsonAttempts + 1
					warn("Save Json Error (original file preserved):", response)
					nosaves = true
					useFactorySettings()
					createPopup("Settings Recovery", "Your IY_FE.iy file could not be read. The original was NOT overwritten. Infinite Yield is using temporary default settings for this session. Repair or back up the file before saving again.")
				end
			else
				writefile("IY_FE.iy", defaults, true)
				wait()
				local dReadSuccess, dOut = readfile("IY_FE.iy", true)
				if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
					saves()
				else
					nosaves = true
					useFactorySettings()
					createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
				end
			end
		else
			writefile("IY_FE.iy", defaults, true)
			wait()
			local dReadSuccess, dOut = readfile("IY_FE.iy", true)
			if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
				saves()
			else
				nosaves = true
				useFactorySettings()
				createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
			end
		end
	else
		if jsonAttempts >= 10 then
			nosaves = true
			useFactorySettings()
			createPopup("File Error", "Sorry, we have attempted to parse your save file, but it is unreadable!\n\nInfinite Yield is now using factory settings until your exploit's file system works.\n\nYour save file has not been deleted.")
		else
			nosaves = true
			useFactorySettings()
		end
	end
end

saves()

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("IY_FE.iy", HttpService:JSONEncode(update))
	end
end

eventEditor.SetOnEdited(updatesaves)

pWayPoints = {}
WayPoints = {}

if #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
	for i = #PluginsTable, 1, -1 do
		if string.sub(PluginsTable[i], -3) ~= ".iy" then
			table.remove(PluginsTable, i)
		end
	end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

PrefixBox.Text = prefix
local SettingsOpen = false
local isHidden = false

if StayOpen == false then
	On.BackgroundTransparency = 1
else
	On.BackgroundTransparency = 0
end

if logsEnabled then
	Toggle.Text = 'Enabled'
else
	Toggle.Text = 'Disabled'
end

if jLogsEnabled then
	Toggle_2.Text = 'Enabled'
else
	Toggle_2.Text = 'Disabled'
end

function maximizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
	end
end

minimizeNum = -20
function minimizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
	end
end

function cmdbarHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -45), "InOut", "Quart", 0.5, true, nil)
	end
end

-- NOVA: one active close listener and one active pin listener per notification.
pinNotification = nil
local notificationCounter = 0
local notificationCloseConnection = nil
function notify(text, text2, length)
    notificationCounter = notificationCounter + 1
    local notificationId = notificationCounter
    if pinNotification then pinNotification:Disconnect() pinNotification = nil end
    if notificationCloseConnection then
        notificationCloseConnection:Disconnect()
        notificationCloseConnection = nil
    end
    local pinned = false
    local closed = false
    Title_2.Text = tostring(text2 and text or "Notification")
    Text_2.Text = tostring(text2 or text or "")
    PinImage.ImageTransparency = 0
    pinNotification = PinButton.MouseButton1Click:Connect(function()
        if notificationId ~= notificationCounter then return end
        pinned = not pinned
        PinImage.ImageTransparency = pinned and 0.5 or 0
    end)
    notificationCloseConnection = CloseButton.MouseButton1Click:Connect(function()
        if notificationId ~= notificationCounter then return end
        closed = true
        Notification:TweenPosition(
            UDim2.new(1, Notification.Position.X.Offset, 1, 0),
            "InOut", "Quart", 0.25, true
        )
    end)
    Notification:TweenPosition(
        UDim2.new(1, Notification.Position.X.Offset, 1, -100),
        "InOut", "Quart", 0.25, true
    )
    task.spawn(function()
        local duration = tonumber(length) or 10
        if duration ~= duration then duration = 10 end
        task.wait(math.clamp(duration, 0.5, 120))
        if notificationId == notificationCounter and not pinned and not closed then
            Notification:TweenPosition(
                UDim2.new(1, Notification.Position.X.Offset, 1, 0),
                "InOut", "Quart", 0.25, true
            )
        end
    end)
end

local lastMessage = nil
local lastLabel = nil
local dupeCount = 1
function CreateLabel(Name, Text)
	if lastMessage == Name..Text then
		dupeCount = dupeCount+1
		lastLabel.Text = Time()..' - ['..Name..']: '..Text..' (x'..dupeCount..')'
	else
		if dupeCount > 1 then dupeCount = 1 end
		if #scroll_2:GetChildren() >= 2546 then
			scroll_2:ClearAllChildren()
		end
		local alls = 0
		for i,v in pairs(scroll_2:GetChildren()) do
			if v then
				alls = v.Size.Y.Offset + alls
			end
			if not v then
				alls = 0
			end
		end
		local tl = Instance.new('TextLabel')
		lastMessage = Name..Text
		lastLabel = tl
		tl.Name = Name
		tl.Parent = scroll_2
		tl.ZIndex = 10
		tl.RichText = true
		tl.Text = Time().." - ["..Name.."]: "..Text
		tl.Text = tl.ContentText
		tl.Size = UDim2.new(0,322,0,84)
		tl.BackgroundTransparency = 1
		tl.BorderSizePixel = 0
		tl.Font = "SourceSans"
		tl.Position = UDim2.new(-1,0,0,alls)
		tl.TextTransparency = 1
		tl.TextScaled = false
		tl.TextSize = 14
		tl.TextWrapped = true
		tl.TextXAlignment = "Left"
		tl.TextYAlignment = "Top"
		tl.TextColor3 = currentText1
		tl.Size = UDim2.new(0,322,0,tl.TextBounds.Y)
		table.insert(text1,tl)
		scroll_2.CanvasSize = UDim2.new(0,0,0,alls+tl.TextBounds.Y)
		scroll_2.CanvasPosition = Vector2.new(0,scroll_2.CanvasPosition.Y+tl.TextBounds.Y)
		tl:TweenPosition(UDim2.new(0,3,0,alls), 'In', 'Quint', 0.5)
		TweenService:Create(tl, TweenInfo.new(1.25, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
	end
end

function CreateJoinLabel(player, userId)
    if #scroll_3:GetChildren() >= 2546 then
        scroll_3:ClearAllChildren()
    end
    local infoFrame = Instance.new("Frame")
    local info1 = Instance.new("TextLabel")
    local info2 = Instance.new("TextLabel")
    local ImageLabel_3 = Instance.new("ImageLabel")
    infoFrame.Name = randomString()
    infoFrame.Parent = scroll_3
    infoFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    infoFrame.BackgroundTransparency = 1
    infoFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    info1.Name = randomString()
    info1.Parent = infoFrame
    info1.BackgroundTransparency = 1
    info1.BorderSizePixel = 0
    info1.Position = UDim2.new(0, 45, 0, 0)
    info1.Size = UDim2.new(0, 135, 1, 0)
    info1.ZIndex = 10
    info1.Font = Enum.Font.SourceSans
    info1.FontSize = Enum.FontSize.Size14
    info1.Text = "Username: " .. player.Name .. "\nJoined Server: " .. Time()
    info1.TextColor3 = Color3.new(1, 1, 1)
    info1.TextWrapped = true
    info1.TextXAlignment = Enum.TextXAlignment.Left
    info2.Name = randomString()
    info2.Parent = infoFrame
    info2.BackgroundTransparency = 1
    info2.BorderSizePixel = 0
    info2.Position = UDim2.new(0, 185, 0, 0)
    info2.Size = UDim2.new(0, 140, 1, -5)
    info2.ZIndex = 10
    info2.Font = Enum.Font.SourceSans
    info2.FontSize = Enum.FontSize.Size14
    info2.Text = "User ID: " .. userId .. "\nAccount Age: " .. player.AccountAge .. "\nJoined Roblox: Loading..."
    info2.TextColor3 = Color3.new(1, 1, 1)
    info2.TextWrapped = true
    info2.TextXAlignment = Enum.TextXAlignment.Left
    info2.TextYAlignment = Enum.TextYAlignment.Center
    ImageLabel_3.Parent = infoFrame
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.new(0, 45, 1, 0)
    ImageLabel_3.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    scroll_3.CanvasSize = UDim2.new(0, 0, 0, listlayout.AbsoluteContentSize.Y)
    scroll_3.CanvasPosition = Vector2.new(0, scroll_2.CanvasPosition.Y + infoFrame.AbsoluteSize.Y)
    local date = os.date("!%Y-%m-%d", os.time() - (player.AccountAge * 86400))
    local splitDates = string.split(date, "-")
    info2.Text = string.gsub(info2.Text, "Loading...", splitDates[2] .. "/" .. splitDates[3] .. "/" .. splitDates[1])
end

IYMouse.KeyDown:Connect(function(Key)
	if (Key==prefix) then
		RunService.RenderStepped:Wait()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end
end)

local lastMinimizeReq = 0
Holder.MouseEnter:Connect(function()
	lastMinimizeReq = 0
	maximizeHolder()
end)

Holder.MouseLeave:Connect(function()
	if not Cmdbar:IsFocused() then
		local reqTime = tick()
		lastMinimizeReq = reqTime
		wait(1)
		if lastMinimizeReq ~= reqTime then return end
		if not Cmdbar:IsFocused() then
			minimizeHolder()
		end
	end
end)

function updateColors(color,ctype)
	if ctype == shade1 then
		for i,v in pairs(shade1) do
			v.BackgroundColor3 = color
		end
		currentShade1 = color
	elseif ctype == shade2 then
		for i,v in pairs(shade2) do
			v.BackgroundColor3 = color
		end
		currentShade2 = color
	elseif ctype == shade3 then
		for i,v in pairs(shade3) do
			v.BackgroundColor3 = color
		end
		currentShade3 = color
	elseif ctype == text1 then
		for i,v in pairs(text1) do
			v.TextColor3 = color
			if v:IsA("TextBox") then
				v.PlaceholderColor3 = color	
			end
		end
		currentText1 = color
	elseif ctype == text2 then
		for i,v in pairs(text2) do
			v.TextColor3 = color
		end
		currentText2 = color
	elseif ctype == scroll then
		for i,v in pairs(scroll) do
			v.ScrollBarImageColor3 = color
		end
		currentScroll = color
	end
end

local colorpickerOpen = false
ColorsButton.MouseButton1Click:Connect(function()
	cache_currentShade1 = currentShade1
	cache_currentShade2 = currentShade2
	cache_currentShade3 = currentShade3
	cache_currentText1 = currentText1
	cache_currentText2 = currentText2
	cache_currentScroll = currentScroll
	if not colorpickerOpen then
		colorpickerOpen = true
		picker = game:GetObjects("rbxassetid://4908465318")[1]
		picker.Name = randomString()
		picker.Parent = ScaledHolder

		local ColorPicker do
			ColorPicker = {}

			ColorPicker.new = function()
				local newMt = setmetatable({},{})

				local pickerGui = picker.ColorPicker
				local pickerTopBar = pickerGui.TopBar
				local pickerExit = pickerTopBar.Exit
				local pickerFrame = pickerGui.Content
				local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
				local colorStrip = pickerFrame.ColorStrip
				local previewFrame = pickerFrame.Preview
				local basicColorsFrame = pickerFrame.BasicColors
				local customColorsFrame = pickerFrame.CustomColors
				local defaultButton = pickerFrame.Default
				local cancelButton = pickerFrame.Cancel
				local shade1Button = pickerFrame.Shade1
				local shade2Button = pickerFrame.Shade2
				local shade3Button = pickerFrame.Shade3
				local text1Button = pickerFrame.Text1
				local text2Button = pickerFrame.Text2
				local scrollButton = pickerFrame.Scroll

				local colorScope = colorSpace.Scope
				local colorArrow = pickerFrame.ArrowFrame.Arrow

				local hueInput = pickerFrame.Hue.Input
				local satInput = pickerFrame.Sat.Input
				local valInput = pickerFrame.Val.Input

				local redInput = pickerFrame.Red.Input
				local greenInput = pickerFrame.Green.Input
				local blueInput = pickerFrame.Blue.Input

				local mouse = IYMouse

				local hue,sat,val = 0,0,1
				local red,green,blue = 1,1,1
				local chosenColor = Color3.new(0,0,0)

				local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
				local customColors = {}

				dragGUI(picker)

				local function updateColor(noupdate)
					local relativeX,relativeY,relativeStripY = 219 - hue*219, 199 - sat*199, 199 - val*199
					local hsvColor = Color3.fromHSV(hue,sat,val)

					if noupdate == 2 or not noupdate then
						hueInput.Text = tostring(math.ceil(359*hue))
						satInput.Text = tostring(math.ceil(255*sat))
						valInput.Text = tostring(math.floor(255*val))
					end
					if noupdate == 1 or not noupdate then
						redInput.Text = tostring(math.floor(255*red))
						greenInput.Text = tostring(math.floor(255*green))
						blueInput.Text = tostring(math.floor(255*blue))
					end

					chosenColor = Color3.new(red,green,blue)

					colorScope.Position = UDim2.new(0,relativeX-9,0,relativeY-9)
					colorStrip.ImageColor3 = Color3.fromHSV(hue,sat,1)
					colorArrow.Position = UDim2.new(0,-2,0,relativeStripY-4)
					previewFrame.BackgroundColor3 = chosenColor

					newMt.Color = chosenColor
					if newMt.Changed then newMt:Changed(chosenColor) end
				end

				local function colorSpaceInput()
					local relativeX = mouse.X - colorSpace.AbsolutePosition.X
					local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

					if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

					hue = (219 - relativeX)/219
					sat = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function colorStripInput()
					local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

					val = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function hookButtons(frame,func)
					frame.ArrowFrame.Up.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum + 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum + 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Up.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 1
						end
					end)

					frame.ArrowFrame.Down.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum - 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum - 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Down.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 1
						end
					end)
				end

				colorSpace.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorSpaceInput()
							end
						end)

						colorSpaceInput()
					end
				end)

				colorStrip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorStripInput()
							end
						end)

						colorStripInput()
					end
				end)

				local function updateHue(str)
					local num = tonumber(str)
					if num then
						hue = math.clamp(math.floor(num),0,359)/359
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						hueInput.Text = tostring(hue*359)
						updateColor(1)
					end
				end
				hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput,updateHue)

				local function updateSat(str)
					local num = tonumber(str)
					if num then
						sat = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						satInput.Text = tostring(sat*255)
						updateColor(1)
					end
				end
				satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

				local function updateVal(str)
					local num = tonumber(str)
					if num then
						val = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						valInput.Text = tostring(val*255)
						updateColor(1)
					end
				end
				valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

				local function updateRed(str)
					local num = tonumber(str)
					if num then
						red = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						redInput.Text = tostring(red*255)
						updateColor(2)
					end
				end
				redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

				local function updateGreen(str)
					local num = tonumber(str)
					if num then
						green = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						greenInput.Text = tostring(green*255)
						updateColor(2)
					end
				end
				greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

				local function updateBlue(str)
					local num = tonumber(str)
					if num then
						blue = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						blueInput.Text = tostring(blue*255)
						updateColor(2)
					end
				end
				blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

				local colorChoice = Instance.new("TextButton")
				colorChoice.Name = "Choice"
				colorChoice.Size = UDim2.new(0,25,0,18)
				colorChoice.BorderColor3 = Color3.new(96/255,96/255,96/255)
				colorChoice.Text = ""
				colorChoice.AutoButtonColor = false
				colorChoice.ZIndex = 10

				local row = 0
				local column = 0
				for i,v in pairs(basicColors) do
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = v
					newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						red,green,blue = v.r,v.g,v.b
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						updateColor()
					end)	

					newColor.Parent = basicColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				row = 0
				column = 0
				for i = 1,12 do
					local color = customColors[i] or Color3.new(0,0,0)
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = color
					newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						local curColor = customColors[i] or Color3.new(0,0,0)
						red,green,blue = curColor.r,curColor.g,curColor.b
						hue,sat,val = Color3.toHSV(curColor)
						updateColor()
					end)

					newColor.MouseButton2Click:Connect(function()
						customColors[i] = chosenColor
						newColor.BackgroundColor3 = chosenColor
					end)

					newColor.Parent = customColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				shade1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade1) end end)
				shade1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0.4 end end)
				shade1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0 end end)

				shade2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade2) end end)
				shade2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0.4 end end)
				shade2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0 end end)

				shade3Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade3) end end)
				shade3Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0.4 end end)
				shade3Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0 end end)

				text1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text1) end end)
				text1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0.4 end end)
				text1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0 end end)

				text2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text2) end end)
				text2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0.4 end end)
				text2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0 end end)

				scrollButton.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,scroll) end end)
				scrollButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0.4 end end)
				scrollButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0 end end)

				cancelButton.MouseButton1Click:Connect(function() if newMt.Cancel then newMt:Cancel() end end)
				cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0.4 end end)
				cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0 end end)

				defaultButton.MouseButton1Click:Connect(function() if newMt.Default then newMt:Default() end end)
				defaultButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0.4 end end)
				defaultButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0 end end)

				pickerExit.MouseButton1Click:Connect(function()
					picker:TweenPosition(UDim2.new(0.5, -219, 0, -500), "InOut", "Quart", 0.5, true, nil)
				end)

				updateColor()

				newMt.SetColor = function(self,color)
					red,green,blue = color.r,color.g,color.b
					hue,sat,val = Color3.toHSV(color)
					updateColor()
				end

				return newMt
			end
		end

		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)

		local Npicker = ColorPicker.new()
		Npicker.Confirm = function(self,color,ctype) updateColors(color,ctype) wait() updatesaves() end
		Npicker.Cancel = function(self)
			updateColors(cache_currentShade1,shade1)
			updateColors(cache_currentShade2,shade2)
			updateColors(cache_currentShade3,shade3)
			updateColors(cache_currentText1,text1)
			updateColors(cache_currentText2,text2)
			updateColors(cache_currentScroll,scroll)
			wait()
			updatesaves()
		end
		Npicker.Default = function(self)
			updateColors(Color3.fromRGB(36, 36, 37),shade1)
			updateColors(Color3.fromRGB(46, 46, 47),shade2)
			updateColors(Color3.fromRGB(78, 78, 79),shade3)
			updateColors(Color3.new(1, 1, 1),text1)
			updateColors(Color3.new(0, 0, 0),text2)
			updateColors(Color3.fromRGB(78,78,79),scroll)
			wait()
			updatesaves()
		end
	else
		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)
	end
end)


SettingsButton.MouseButton1Click:Connect(function()
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	else SettingsOpen = false
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.5, true, nil)
	end
end)

On.MouseButton1Click:Connect(function()
	if isHidden == false then
		if StayOpen == false then
			StayOpen = true
			On.BackgroundTransparency = 0
		else
			StayOpen = false
			On.BackgroundTransparency = 1
		end
		updatesaves()
	end
end)

Clear.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_2:GetChildren()) do
		child:Destroy()
	end
	scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Clear_2.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_3:GetChildren()) do
		child:Destroy()
	end
	scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Toggle.MouseButton1Down:Connect(function()
	if logsEnabled then
		logsEnabled = false
		Toggle.Text = 'Disabled'
		updatesaves()
	else
		logsEnabled = true
		Toggle.Text = 'Enabled'
		updatesaves()
	end
end)

Toggle_2.MouseButton1Down:Connect(function()
	if jLogsEnabled then
		jLogsEnabled = false
		Toggle_2.Text = 'Disabled'
		updatesaves()
	else
		jLogsEnabled = true
		Toggle_2.Text = 'Enabled'
		updatesaves()
	end
end)

selectChat.MouseButton1Down:Connect(function()
	join.Visible = false
	chat.Visible = true
	table.remove(shade3,table.find(shade3,selectChat))
	table.remove(shade2,table.find(shade2,selectJoin))
	table.insert(shade2,selectChat)
	table.insert(shade3,selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
end)

selectJoin.MouseButton1Down:Connect(function()
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3,table.find(shade3,selectJoin))
	table.remove(shade2,table.find(shade2,selectChat))
	table.insert(shade2,selectJoin)
	table.insert(shade3,selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
end)

if not writefileExploit() then
	notify("Saves", "Your exploit does not support read/write file. Your settings will not save.")
end

avatarcache = {}
function sendChatWebhook(player, message)
	if httprequest and vtype(logsWebhook, "string") then
		local id = player.UserId
		local avatar = avatarcache[id]
		if not avatar then
			local d = HttpService:JSONDecode(httprequest({
				Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
				Method = "GET"
			}).Body)["data"]
			avatar = d and d[1].state == "Completed" and d[1].imageUrl or "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/assets/plain.png"
			avatarcache[id] = avatar
		end
		local log = HttpService:JSONEncode({
			content = message,
			avatar_url = avatar,
			username = formatUsername(player),
			allowed_mentions = {parse = {}}
		})
		httprequest({
			Url = logsWebhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = log
		})
	end
end

ChatLog = function(player)
	player.Chatted:Connect(function(message)
		if logsEnabled == true then
			CreateLabel(player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

JoinLog = function(plr)
	if jLogsEnabled == true then
		CreateJoinLabel(plr,plr.UserId)
	end
end

CleanFileName = function(name)
	return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
end

SaveChatlogs.MouseButton1Down:Connect(function()
	if writefileExploit() then
		if #scroll_2:GetChildren() > 0 then
			notify("Loading",'Hold on a sec')
			local placeName = CleanFileName(MarketplaceService:GetProductInfo(PlaceId).Name)
			local writelogs = '-- Infinite Yield Chat logs for "'..placeName..'"\n'
			for _, child in pairs(scroll_2:GetChildren()) do
				writelogs = writelogs..'\n'..child.Text
			end
			local writelogsFile = tostring(writelogs)
			local fileext = 0
			local function nameFile()
				local file
				pcall(function() file = readfile(placeName..' Chat Logs ('..fileext..').txt') end)
				if file then
					fileext = fileext+1
					nameFile()
				else
					writefileCooldown(placeName..' Chat Logs ('..fileext..').txt', writelogsFile)
				end
			end
			nameFile()
			notify('Chat Logs','Saved chat logs to the workspace folder within your exploit folder.')
		end
	else
		notify('Chat Logs','Your exploit does not support write file. You cannot save chat logs.')
	end
end)

if isLegacyChat then
	for _, plr in pairs(Players:GetPlayers()) do
		ChatLog(plr)
	end
end

Players.PlayerRemoving:Connect(function(player)
	if ESPenabled or CHMSenabled or COREGUI:FindFirstChild(player.Name..'_LC') then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == player.Name..'_ESP' or v.Name == player.Name..'_LC' or v.Name == player.Name..'_CHMS' then
				v:Destroy()
			end
		end
	end
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
		viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		notify('Spectate','View turned off (player left)')
	end
	eventEditor.FireEvent("OnLeave", player.Name)
end)

Exit.MouseButton1Down:Connect(function()
	logs:TweenPosition(UDim2.new(0, 0, 1, 10), "InOut", "Quart", 0.3, true, nil)
end)

Hide.MouseButton1Down:Connect(function()
	if logs.Position ~= UDim2.new(0, 0, 1, -20) then
		logs:TweenPosition(UDim2.new(0, 0, 1, -20), "InOut", "Quart", 0.3, true, nil)
	else
		logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
	end
end)

EventBind.MouseButton1Click:Connect(function()
	eventEditor.Frame:TweenPosition(UDim2.new(0.5,-175,0.5,-101), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Add.MouseButton1Click:Connect(function()
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, 260), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Click:Connect(function()
	binds = {}
	refreshbinds()
	updatesaves()
	notify('Keybinds Updated','Removed all keybinds')
end)

Close_2.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Aliases.MouseButton1Click:Connect(function()
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close_3.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Positions.MouseButton1Click:Connect(function()
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = randomString()
selectionBox.Color3 = Color3.new(255,255,255)
selectionBox.Adornee = nil
selectionBox.Parent = PARENT

local selected = Instance.new("SelectionBox")
selected.Name = randomString()
selected.Color3 = Color3.new(0,166,0)
selected.Adornee = nil
selected.Parent = PARENT

local ActivateHighlight = nil
local ClickSelect = nil
function selectPart()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, 335), "InOut", "Quart", 0.5, true, nil)
	local function HighlightPart()
		if selected.Adornee ~= IYMouse.Target then
			selectionBox.Adornee = IYMouse.Target
		else
			selectionBox.Adornee = nil
		end
	end
	ActivateHighlight = IYMouse.Move:Connect(HighlightPart)
	local function SelectPart()
		if IYMouse.Target ~= nil then
			selected.Adornee = IYMouse.Target
			Path.Text = getHierarchy(IYMouse.Target)
		end
	end
	ClickSelect = IYMouse.Button1Down:Connect(SelectPart)
end

Part.MouseButton1Click:Connect(function()
	selectPart()
end)

Exit_4.MouseButton1Click:Connect(function()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	if ActivateHighlight then
		ActivateHighlight:Disconnect()
	end
	if ClickSelect then
		ClickSelect:Disconnect()
	end
	selectionBox.Adornee = nil
	selected.Adornee = nil
	Path.Text = ""
end)

CopyPath.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		toClipboard(Path.Text)
	else
		notify('Copy Path','Select a part to copy its path')
	end
end)

ChoosePart.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		local tpNameExt = ''
		local function handleWpNames()
			local FoundDupe = false
			for i,v in pairs(pWayPoints) do
				if v.NAME:lower() == selected.Adornee.Name:lower()..tpNameExt then
					FoundDupe = true
				end
			end
			if not FoundDupe then
				notify('Modified Waypoints',"Created waypoint: "..selected.Adornee.Name..tpNameExt)
				pWayPoints[#pWayPoints + 1] = {NAME = selected.Adornee.Name..tpNameExt, COORD = {selected.Adornee}}
			else
				if isNumber(tpNameExt) then
					tpNameExt = tpNameExt+1
				else
					tpNameExt = 1
				end
				handleWpNames()
			end
		end
		handleWpNames()
		refreshwaypoints()
	else
		notify('Part Selection','Select a part first')
	end
end)

cmds={}
customAlias = {}
Delete_3.MouseButton1Click:Connect(function()
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

PrefixBox:GetPropertyChangedSignal("Text"):Connect(function()
	prefix = PrefixBox.Text
	Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
	updatesaves()
end)

function CamViewport()
	if workspace.CurrentCamera then
		return workspace.CurrentCamera.ViewportSize.X
	end
end

function UpdateToViewport()
	if Holder.Position.X.Offset < -CamViewport() then
		Holder:TweenPosition(UDim2.new(1, -CamViewport(), Holder.Position.Y.Scale, Holder.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
		Notification:TweenPosition(UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
	end
end
CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)

function updateCamera(child, parent)
	if parent ~= workspace then
		CamMoved:Disconnect()
		CameraChanged:Disconnect()
		repeat wait() until workspace.CurrentCamera
		CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)
		CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)
	end
end
CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)

function dragMain(dragpoint,gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local pos = -250
			local delta = input.Position - dragStart
			if startPos.X.Offset + delta.X <= -500 then
				local Position = UDim2.new(1, -250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = 250
			else
				local Position = UDim2.new(1, -500, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = -250
			end
			if startPos.X.Offset + delta.X <= -250 and -CamViewport() <= startPos.X.Offset + delta.X then
				local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + pos, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			elseif startPos.X.Offset + delta.X > -500 then
				local Position = UDim2.new(1, -250, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
			elseif -CamViewport() > startPos.X.Offset + delta.X then
				gui:TweenPosition(UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
				local Position = UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			end
		end
		dragpoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		dragpoint.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragMain(Title,Holder)

Match = function(name,str)
	str = str:gsub("%W", "%%%1")
	return name:lower():find(str:lower()) and true
end

local canvasPos = Vector2.new(0,0)
local topCommand = nil
local function updateCommandCanvasSize(frame)
	local scale = (Scale and Scale.Scale) or 1
	if scale <= 0 then scale = 1 end
	local contentY = cmdListLayout.AbsoluteContentSize.Y
	local unscaledY = math.ceil(contentY / scale)
	frame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, unscaledY))
end
cmdListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateCommandCanvasSize(CMDsF)
end)
IndexContents = function(str,bool,cmdbar,Ianim)
	CMDsF.CanvasPosition = Vector2.new(0,0)
	local SizeY = 0
	local indexnum = 0
	local frame = CMDsF
	topCommand = nil
	local chunks = {}
	if str:sub(#str,#str) == "\\" then str = "" end
	for w in string.gmatch(str,"[^\\]+") do
		table.insert(chunks,w)
	end
	if #chunks > 0 then str = chunks[#chunks] end
	if str:sub(1,1) == "!" then str = str:sub(2) end
	for i,v in next, frame:GetChildren() do
		if v:IsA("TextButton") then
			if bool then
				if Match(v.Text,str) then
					indexnum = indexnum + 1
					v.Visible = true
					if topCommand == nil then
						topCommand = v.Text
					end
				else
					v.Visible = false
				end
			else
				v.Visible = true
				if topCommand == nil then
					topCommand = v.Text
				end
			end
		end
	end
	updateCommandCanvasSize(frame)
	if not Ianim then
		if indexnum == 0 or string.find(str, " ") then
			if not cmdbar then
				minimizeHolder()
			elseif cmdbar then
				cmdbarHolder()
			end
		else
			maximizeHolder()
		end
	else
		minimizeHolder()
	end
end

task.spawn(function()
	if not isLegacyChat then return end
	local chatbox
	local success, result = pcall(function() chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local function chatboxFocused()
			canvasPos = CMDsF.CanvasPosition
		end
		local chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)

		local function Index()
			if chatbox.Text:lower():sub(1,1) == prefix then
				if SettingsOpen == true then
					wait(0.2)
					CMDsF.Visible = true
					Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
				end
				IndexContents(PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Text:lower():sub(2),true)
			else
				minimizeHolder()
				if SettingsOpen == true then
					wait(0.2)
					Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
					CMDsF.Visible = false
				end
			end
		end
		local chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)

		local function chatboxFocusLost(enterpressed)
			if not enterpressed or chatbox.Text:lower():sub(1,1) ~= prefix then
				IndexContents('',true)
			end
			CMDsF.CanvasPosition = canvasPos
			minimizeHolder()
		end
		local chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)

		PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.ChildAdded:Connect(function(newbar)
			wait()
			if newbar:FindFirstChild('BoxFrame') then
				chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if chatboxFocusedC then chatboxFocusedC:Disconnect() end
				chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)
				if chatboxFunc then chatboxFunc:Disconnect() end
				chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)
				if chatboxFocusLostC then chatboxFocusLostC:Disconnect() end
				chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)
			end
		end)
		--else
		--print('Custom chat detected. Will not provide suggestions for commands typed in the chat.')
	end
end)

function autoComplete(str,curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i=1,#str do
		local c = str:sub(i,i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText,"\\",pos)
	while findRes do
		subPos = findRes
		pos = findRes+1
		findRes = string.find(curText,"\\",pos)
	end
	if curText:sub(subPos+1,subPos+1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = curText:sub(1,subPos) .. str:sub(1, stop - 1)..' '
	RunService.RenderStepped:Wait()
	Cmdbar.Text = Cmdbar.Text:gsub( '\t', '' )
	Cmdbar.CursorPosition = #Cmdbar.Text+1--1020
end

CMDs = {}
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the Infinite Yield Discord server.'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the GUI. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens Dex by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt [player]', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/AFK'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Sets outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Sets IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your UserId to the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute IY when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disables keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Saves the game you are in to a file'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents LocalScripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents LocalScripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality in an attempt to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'setfpscap / fpscap / maxfps', DESC = 'Sets FPS cap'}
CMDs[#CMDs + 1] = {NAME = 'record / rec', DESC = 'Starts Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disables 3D Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enables 3D Rendering'}
CMDs[#CMDs + 1] = {NAME = '2022materials / use2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'un2022materials / unuse2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'togglenoclip', DESC = 'Toggles noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'togglefly', DESC = 'Toggles fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float / platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'togglefloat', DESC = 'Toggles float'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a Discord webhook for chatlogs to go to (provide no URL to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'vsay [text]', DESC = 'Say anything uncensored (CLIENT)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam / nospam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam / nopmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with voice chat'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'view / spectate [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unview / unspectate', DESC = 'Stops viewing player/part'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fcam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Sets maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Sets minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Unfreezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'unglobalshadows / ungshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players UserId'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current PlaceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current GameId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players AppearanceId'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players AppearanceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to climb into the air by repeatedly pressing jump'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infinitejump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Infinite jump that continuously flies upward just by holding the jump button'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools LocalScripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'defemote [emote]', DESC = 'Plays default emote'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your AnimationId or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesnt let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'clickfor', DESC = 'Click a player to run (click type) (player)'}
CMDs[#CMDs + 1] = {NAME = 'unclickfor', DESC = 'Disables clickfor'}
CMDs[#CMDs + 1] = {NAME = 'clicktype [type]', DESC = 'Sets click type'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
-- wait()

for i = 1, #CMDs do
	local newcmd = Example:Clone()
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = CMDs[i].NAME
	newcmd.Name = "CMD"
	table.insert(text1, newcmd)
	if CMDs[i].DESC ~= "" then
		newcmd:SetAttribute("Title", CMDs[i].NAME)
		newcmd:SetAttribute("Desc", CMDs[i].DESC)
		newcmd.MouseButton1Down:Connect(function()
			if not IsOnMobile and newcmd.Visible and newcmd.TextTransparency == 0 then
				local currentText = Cmdbar.Text
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text, currentText)
				maximizeHolder()
			end
		end)
	end
end

IndexContents("", true)

function checkTT()
	local t
	local guisAtPosition = COREGUI:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)

	for _, gui in pairs(guisAtPosition) do
		if gui.Parent == CMDsF then
			t = gui
		end
	end

	if t ~= nil and t:GetAttribute("Title") ~= nil then
		local x = IYMouse.X
		local y = IYMouse.Y
		local xP
		local yP
		if IYMouse.X > 200 then
			xP = x - 201
		else
			xP = x + 21
		end
		if IYMouse.Y > (IYMouse.ViewSizeY-96) then
			yP = y - 97
		else
			yP = y
		end
		Tooltip.Position = UDim2.new(0, xP, 0, yP)
		Description.Text = t:GetAttribute("Desc")
		if t:GetAttribute("Title") ~= nil then
			Title_3.Text = t:GetAttribute("Title")
		else
			Title_3.Text = ''
		end
		Tooltip.Visible = true
	else
		Tooltip.Visible = false
	end
end

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

function GetInTable(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

function respawn(plr)
	if invisRunning then TurnVisible() end
    local char = plr.Character
    local hum = char:FindFirstChildWhichIsA("Humanoid")
	local archive = workspace.FallenPartsDestroyHeight
	local camType = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.FallenPartsDestroyHeight = 0/0
    getRoot(char).Position = Vector3.yAxis * archive
	task.wait(plr:GetNetworkPing())
	workspace.FallenPartsDestroyHeight = archive
	repeat task.wait() until not char.Parent or not hum.Parent or (hum and hum.Health <= 0)
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end

local refreshCmd = false
function refresh(plr)
	refreshCmd = true
	local root = getRoot(plr.Character)
	local pos = root.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	respawn(plr)
	task.spawn(function()
		local char = plr.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		while not humanoid do
			wait()
			humanoid = char:FindFirstChildOfClass("Humanoid")
		end
		humanoid.RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, task.wait() and pos1
		refreshCmd = false
	end)
end

local lastDeath
local diedConnection
local diedCharacter
function onDied()
    local character = Players.LocalPlayer.Character
    if character == diedCharacter and diedConnection then return end
    if diedConnection then diedConnection:Disconnect(); diedConnection = nil end
    diedCharacter = character
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        task.spawn(function()
            humanoid = character:WaitForChild("Humanoid", 12)
            if character == Players.LocalPlayer.Character and humanoid then onDied() end
        end)
        return
    end
    diedConnection = humanoid.Died:Connect(function()
        local part = getRoot(character)
        if part then lastDeath = part.CFrame end
    end)
end

Clip = true
spDelay = 0.1
Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	floating = false

	if not Clip then
		execCmd('clip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if spawnpoint and not refreshCmd and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)

	onDied()
end)

onDied()

local booly = {
    truthy = { ["true"] = true, ["t"] = true, ["1"] = true, ["yes"] = true, ["y"] = true, ["on"] = true, ["enable"] = true, ["enabled"] = true },
    falsy = { ["false"] = true, ["f"] = true, ["0"] = true, ["no"] = true, ["n"] = true, ["off"] = true, ["disable"] = true, ["disabled"] = true },
}

function parseBoolean(raw, default)
    raw = tostring(raw):lower()
    if booly.truthy[raw] then return true end
    if booly.falsy[raw] then return false end
    return default or false
end

function getstring(begin, args)
    return table.concat(args or cargs, " ", begin)
end

-- NOVA v2: indexed canonical names and aliases. Rebuild lazily on mutation,
-- and keep custom aliases as a final fallback for backward compatibility.
local novaIndex, novaIndexedSize = {}, -1
local function invalidateCommandIndex()
    novaIndexedSize = -1
end
findCmd = function(cmd_name)
    if type(cmd_name) ~= "string" or cmd_name == "" then return nil end
    local key = cmd_name:lower()
    if novaIndexedSize ~= #cmds then
        local rebuilt = {}
        for _, command in ipairs(cmds) do
            if type(command.NAME) == "string" then
                local canonical = command.NAME:lower()
                if rebuilt[canonical] == nil then rebuilt[canonical] = command end
                for _, alias in ipairs(type(command.ALIAS) == "table" and command.ALIAS or {}) do
                    local candidate = tostring(alias):lower()
                    if rebuilt[candidate] == nil then rebuilt[candidate] = command end
                end
            end
        end
        novaIndex, novaIndexedSize = rebuilt, #cmds
    end
    return novaIndex[key] or (type(customAlias) == "table" and customAlias[key] or nil)
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split=" "
local lastBreakTime = 0
local function recordCommandError(commandName, failure)
    local history = _G.IY_NOVA_ERRORS
    if type(history) ~= "table" then
        history = {}
        _G.IY_NOVA_ERRORS = history
    end
    table.insert(history, 1, {
        command = tostring(commandName),
        message = tostring(failure),
        timestamp = os.time()
    })
    if #history > 40 then table.remove(history) end
end

-- NOVA v2 dispatcher: bounded chains, tracked infinite loops, isolated errors,
-- no busy spins, and deterministic history entries. Existing signatures kept.
local novaInfiniteLoops = {}
local novaDispatch = {
    infinite = novaInfiniteLoops, executed = 0, blocked = 0,
    active = 0, maxActive = 10, maxLoops = 10,
    launched = 0, completed = 0, failures = 0, cancelled = 0,
    generation = 0, maxBatchCalls = 1600, budgetStops = 0,
    startedAt = os.clock()
}
_G.IY_NOVA_DISPATCH = novaDispatch

-- Quoted arguments preserve names such as: novabeacon "Golden Orb".
-- Escaped quotes are supported inside quoted text.
local function novaWords(raw)
    local words, current, quoted, occupied = {}, {}, nil, false
    local i, n = 1, #raw
    while i <= n do
        local ch = raw:sub(i, i)
        if quoted then
            if ch == quoted then
                quoted = nil
            elseif ch == "\\" and raw:sub(i + 1, i + 1) == quoted then
                i = i + 1
                current[#current + 1] = raw:sub(i, i)
            else
                current[#current + 1] = ch
            end
        elseif (ch == '"' or ch == "'") and not occupied then
            quoted = ch
            occupied = true
        elseif ch:match("%s") then
            if occupied then
                words[#words + 1] = table.concat(current)
                current, occupied = {}, false
            end
        else
            current[#current + 1] = ch
            occupied = true
        end
        i = i + 1
    end
    if occupied then words[#words + 1] = table.concat(current) end
    return words
end

local function novaSegments(raw)
    local segments, piece, quote = {}, {}, nil
    local i = 1
    while i <= #raw do
        local ch = raw:sub(i, i)
        if quote then
            piece[#piece + 1] = ch
            if ch == quote and raw:sub(i - 1, i - 1) ~= "\\" then quote = nil end
        elseif ch == '"' or ch == "'" then
            quote = ch
            piece[#piece + 1] = ch
        elseif ch == "\\" then
            if raw:sub(i + 1, i + 1) == "\\" then
                piece[#piece + 1] = "\\"
                i = i + 1
            else
                segments[#segments + 1] = table.concat(piece)
                piece = {}
            end
        else
            piece[#piece + 1] = ch
        end
        i = i + 1
    end
    segments[#segments + 1] = table.concat(piece)
    return segments
end

local function novaLoopCount()
    local count = 0
    for _ in pairs(novaInfiniteLoops) do count = count + 1 end
    return count
end
novaDispatch.loopCount = novaLoopCount
novaDispatch.stopLoop = function(input)
    local key = tostring(input or ""):lower()
    local cmd = findCmd(key)
    key = (cmd and cmd.NAME or key):lower()
    if not novaInfiniteLoops[key] then return false end
    novaInfiniteLoops[key] = nil
    novaDispatch.cancelled = novaDispatch.cancelled + 1
    return true
end
novaDispatch.stopAll = function()
    novaDispatch.generation = novaDispatch.generation + 1
    lastBreakTime = tick()
    local n = 0
    for name in pairs(novaInfiniteLoops) do
        novaInfiniteLoops[name] = nil
        n = n + 1
    end
    novaDispatch.cancelled = novaDispatch.cancelled + n
    return n
end

local function novaInvoke(command, args, actor, requested, index, total, infinite)
    -- Legacy callbacks may read cargs. The argument table remains local to
    -- every invocation, while only legacy compatibility uses the global.
    cargs = args
    local ok, result = pcall(command.FUNC, args, actor)
    novaDispatch.executed = novaDispatch.executed + 1
    if not ok then
        novaDispatch.failures = novaDispatch.failures + 1
        -- The instrumented wrapper has already logged a detailed failure.
        if not tostring(result):find("^%[NOVA:") then
            recordCommandError(requested, result)
        end
        if _G.IY_DEBUG then warn("NOVA command failed:", requested, result) end
        return false
    end
    if type(result) == "string" and not infinite and (index == 1 or index == total)
        and not table.find(args, "nonotify") then
        notify("Command: " .. requested, result)
    end
    return true
end

local function novaExecuteSegment(piece, actor, originalInput, saveHistory, guard)
    local repetitions, seconds, infinite = 1, 0, false
    local prefix, after = piece:match("^(%d+)%^(.*)$")
    if prefix then
        repetitions = math.clamp(tonumber(prefix) or 1, 1, 1000)
        piece = after
        local waitValue, rest = piece:match("^([%d%.]+)%^(.*)$")
        if waitValue then seconds, piece = tonumber(waitValue) or 0, rest end
    elseif piece:sub(1, 4):lower() == "inf^" then
        infinite = true
        piece = piece:sub(5)
        local waitValue, rest = piece:match("^([%d%.]+)%^(.*)$")
        if waitValue then seconds, piece = tonumber(waitValue) or 0.1, rest
        else seconds = 0.1 end
        seconds = math.clamp(seconds, 0.05, 60)
    end
    repetitions = math.floor(repetitions)
    seconds = math.clamp(seconds, 0, 60)
    if piece:sub(1, 1) == "!" then
        local shortcut = novaWords(piece:sub(2))[1]
        if shortcut and lastCmds[shortcut:lower()] then piece = lastCmds[shortcut:lower()] end
    end
    local args = novaWords(piece)
    local requested = args[1] and args[1]:lower()
    if not requested then return end
    local command = findCmd(requested)
    if not command or type(command.FUNC) ~= "function" then
        recordCommandError(requested, "Unknown command")
        return
    end
    table.remove(args, 1)
    if saveHistory and actor == Players.LocalPlayer then
        if cmdHistory[1] ~= originalInput and requested ~= "lastcommand" and requested ~= "lastcmd" then
            table.insert(cmdHistory, 1, originalInput)
            if #cmdHistory > 30 then table.remove(cmdHistory) end
        end
        lastCmds[requested] = piece
    end
    local began = tick()
    if guard and guard.generation ~= novaDispatch.generation then return end
    if infinite then
        local key = command.NAME:lower()
        if not novaInfiniteLoops[key] and novaLoopCount() >= novaDispatch.maxLoops then
            novaDispatch.blocked = novaDispatch.blocked + 1
            recordCommandError(requested, "Maximum concurrent repeating commands reached")
            return
        end
        local marker = {name = key, interval = seconds, started = os.clock(), count = 0}
        novaInfiniteLoops[key] = marker -- cancels the old copy, if any
        task.spawn(function()
            local failures = 0
            while novaInfiniteLoops[key] == marker and lastBreakTime <= began
                and (not guard or guard.generation == novaDispatch.generation) do
                marker.count = marker.count + 1
                if novaInvoke(command, args, actor, requested, marker.count, math.huge, true) then
                    failures = 0
                else
                    failures = failures + 1
                    if failures >= 3 then
                        recordCommandError(key, "Repeating command stopped after three failures")
                        break
                    end
                end
                task.wait(seconds)
            end
            if novaInfiniteLoops[key] == marker then novaInfiniteLoops[key] = nil end
        end)
        return -- continue other chained commands; infinite tasks no longer block the chain
    end
    local failures = 0
    for i = 1, repetitions do
        if lastBreakTime > began or (guard and guard.generation ~= novaDispatch.generation) then break end
        if guard then
            if guard.remaining <= 0 then
                novaDispatch.budgetStops = novaDispatch.budgetStops + 1
                recordCommandError("dispatcher", "Batch execution budget reached; remaining calls cancelled")
                break
            end
            guard.remaining = guard.remaining - 1
        end
        if novaInvoke(command, args, actor, requested, i, repetitions, false) then
            failures = 0
        else
            failures = failures + 1
            if failures >= 3 then break end
        end
        if seconds > 0 then task.wait(seconds)
        elseif i % 15 == 0 then task.wait() end
    end
end

function execCmd(cmdStr, speaker, store)
    if cmdStr == nil then return end
    cmdStr = tostring(cmdStr):gsub("^%s+", ""):gsub("%s+$", "")
    if cmdStr == "" then return end
    if #cmdStr > 4096 then
        recordCommandError("dispatcher", "Input exceeds 4096 characters")
        novaDispatch.blocked = novaDispatch.blocked + 1
        return
    end
    local segments = novaSegments(cmdStr)
    if #segments > 40 then
        recordCommandError("dispatcher", "Maximum of 40 chained commands")
        novaDispatch.blocked = novaDispatch.blocked + 1
        return
    end
    if novaDispatch.active >= novaDispatch.maxActive then
        recordCommandError("dispatcher", "Too many active command batches; try again shortly")
        novaDispatch.blocked = novaDispatch.blocked + 1
        return
    end
    novaDispatch.active = novaDispatch.active + 1
    novaDispatch.launched = novaDispatch.launched + 1
    local guard = {generation = novaDispatch.generation, remaining = novaDispatch.maxBatchCalls}
    task.spawn(function()
        local ok, err = pcall(function()
            local actor = speaker or Players.LocalPlayer
            for _, raw in ipairs(segments) do
                if guard.generation ~= novaDispatch.generation or guard.remaining <= 0 then break end
                local segment = raw:gsub("^%s+", ""):gsub("%s+$", "")
                if segment ~= "" then novaExecuteSegment(segment, actor, cmdStr, store, guard) end
            end
        end)
        novaDispatch.active = math.max(0, novaDispatch.active - 1)
        novaDispatch.completed = novaDispatch.completed + 1
        if not ok then
            novaDispatch.failures = novaDispatch.failures + 1
            recordCommandError("dispatcher", err)
        end
    end)
end

function addcmd(name, alias, func, plgn)
    if type(name) ~= "string" or name == "" or type(func) ~= "function" then
        if _G.IY_DEBUG then warn("Rejected invalid command:", tostring(name)) end
        return nil
    end
    local existing = findCmd(name)
    if existing then
        if _G.IY_DEBUG then warn("Skipped ambiguous command registration:", name,
            "already owned by", existing.NAME) end
        return existing
    end
    local cleanAliases, used = {}, {}
    for _, raw in ipairs(type(alias) == "table" and alias or {}) do
        if type(raw) == "string" then
            local key = raw:lower():match("^%s*(.-)%s*$")
            if key ~= "" and key ~= name:lower() and not used[key] then
                used[key] = true
                if not findCmd(key) then
                    cleanAliases[#cleanAliases + 1] = raw
                else
                    _G.IY_NOVA_ALIAS_CONFLICTS = _G.IY_NOVA_ALIAS_CONFLICTS or {}
                    if #_G.IY_NOVA_ALIAS_CONFLICTS < 100 then
                        table.insert(_G.IY_NOVA_ALIAS_CONFLICTS, name .. ": " .. raw)
                    end
                end
            end
        end
    end
    local cmd = {NAME = name, ALIAS = cleanAliases, FUNC = func, PLUGIN = plgn}
    cmds[#cmds + 1] = cmd
    invalidateCommandIndex()
    local hook = _G.IY_NOVA_REBUILD_HOOK
    if type(hook) == "function" then pcall(hook, cmd) end
    return cmd
end

function removecmd(cmd)
    if type(cmd) ~= "string" then return false end
    local input = cmd:lower():match("^%s*(.-)%s*$")
    if input == "" then return false end
    local found = findCmd(input)
    if not found then return false end
    local canonical = tostring(found.NAME):lower()
    local removed = false
    for i = #cmds, 1, -1 do
        if cmds[i] == found then
            table.remove(cmds, i)
            removed = true
            break
        end
    end
    if not removed then return false end
    invalidateCommandIndex()
    for _, item in ipairs(CMDsF:GetChildren()) do
        if item:IsA("TextButton") then
            local label = tostring(item:GetAttribute("Title") or item.Text):lower()
            local first = label:match("^%s*([%w_]+)")
            if first == canonical then
                item.TextTransparency = 0.65
                if not item:GetAttribute("NOVA_RemovedNotice") then
                    item:SetAttribute("NOVA_RemovedNotice", true)
                    item.MouseButton1Click:Connect(function()
                        notify("Command disabled", "This command was removed from the registry.")
                    end)
                end
            end
        end
    end
    return true
end

function overridecmd(name, func)
    local command = findCmd(name)
    if command and type(func) == "function" then
        command.FUNC = func
        local hook = _G.IY_NOVA_REBUILD_HOOK
        if type(hook) == "function" then pcall(hook, command) end
    end
end

function addbind(cmd,key,iskeyup,toggle)
	if toggle then
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
				TOGGLE = toggle;
			}
	else
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
			}
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
		newcmd.MouseButton1Down:Connect(function()
			if newcmd.Visible and newcmd.TextTransparency == 0 then
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text)
				maximizeHolder()
			end
		end)
	end
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end)

Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end)

Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
	if Cmdbar:IsFocused() then
		IndexContents(Cmdbar.Text,true,true)
	end
end)

local tabComplete = nil
tabAllowed = true
Cmdbar.FocusLost:Connect(function(enterpressed)
	if enterpressed then
        local cmdbarText = Cmdbar.Text
        if type(prefix) == "string" and prefix ~= "" and cmdbarText:sub(1, #prefix) == prefix then
            cmdbarText = cmdbarText:sub(#prefix + 1)
        end
		execCmd(cmdbarText,Players.LocalPlayer,true)
	end
	if tabComplete then tabComplete:Disconnect() end
	wait()
	if not Cmdbar:IsFocused() then
		Cmdbar.Text = ""
		IndexContents('',true,false,true)
		if SettingsOpen == true then
			wait(0.2)
			Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
			CMDsF.Visible = false
		end
	end
	CMDsF.CanvasPosition = canvasPos
end)

Cmdbar.Focused:Connect(function()
	historyCount = 0
	canvasPos = CMDsF.CanvasPosition
	if SettingsOpen == true then
		wait(0.2)
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
	end
	tabComplete = UserInputService.InputBegan:Connect(function(input,gameProcessed)
		if Cmdbar:IsFocused() then
			if tabAllowed == true and input.KeyCode == Enum.KeyCode.Tab and topCommand ~= nil then
				autoComplete(topCommand)
			end
		else
			tabComplete:Disconnect()
		end
	end)
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					if logic == true then
						a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
					else
						a.Color = plr.TeamColor
					end
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newbind.Text.Delete.MouseButton1Click:Connect(function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

PositionsFrame.Delete.MouseButton1Click:Connect(function()
	execCmd('cpos')
end)

function refreshwaypoints()
	if #WayPoints > 0 or #pWayPoints > 0 then
		PositionsHint:Destroy()
	end
	if Holder_4 then
		Holder_4:ClearAllChildren()
		Holder_4.CanvasSize = UDim2.new(0, 0, 0, 10)
		local YSize = 25
		local num = 1
		for i = 1, #WayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = WayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..WayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..WayPoints[i].NAME)
			end)
			num = num+1
		end
		for i = 1, #pWayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = pWayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..pWayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..pWayPoints[i].NAME)
			end)
			num = num+1
		end
	end
end

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			table.insert(shade3,newalias.Text.Delete)
			table.insert(text2,newalias.Text.Delete)
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newalias.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('removealias '..aliases[i].ALIAS)
			end)
		end
	end
end

local bindChosenKeyUp = false

BindTo.MouseButton1Click:Connect(function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

BindTriggerSelect.MouseButton1Click:Connect(function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
On_2.MouseButton1Click:Connect(function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
	else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

Add_2.MouseButton1Click:Connect(function()
	if keySelected then
		if string.find(Cmdbar_2.Text, "\\\\") or string.find(Cmdbar_3.Text, "\\\\") then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			BindTo.Text = keyPressed:sub(14)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			BindTo.Text = 'LeftClick'
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			BindTo.Text = 'RightClick'
		end
		awaitingInput = false
		keySelected = true
	end
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

ClickTP.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clicktp',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
		end
	end
end)

ClickDelete.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clickdel',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
		end
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		breakVelocity()
	end)
end

clickFor = false
clickType = "bang"
IYMouse.Button1Down:Connect(function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end

	if clickFor and IYMouse.Target then
		pcall(function()
			local tmodel = IYMouse.Target:FindFirstAncestorOfClass("Model")
			if tmodel and tmodel:FindFirstChild("Humanoid") then
				local target = Players:GetPlayerFromCharacter(tmodel)
				if target and target ~= Players.LocalPlayer then
					execCmd(clickType .. " " .. target.Name) -- potential feat: save clickType to a file?
				end
			end
		end)
	end
end)

PluginsGUI = PluginEditor.background

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	if PluginsTable ~= nil and type(PluginsTable) == "table" then
		for i,v in pairs(PluginsTable) do
			LoadPlugin(v,true)
		end
		refreshplugins(true)
	end
end

AddPlugin.MouseButton1Click:Connect(function()
	addPlugin(PluginsGUI.FileName.Text)
end)

Exit_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	FileName.Text = 'Plugin File Name'
end)

Add_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
end)

Plugins.MouseButton1Click:Connect(function()
	if writefileExploit() then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		SettingsHolder.Visible = false
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

Close_4.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	if KeepInfYield and (not TeleportCheck) and queueteleport then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()")
	end
end)

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/78ZuWSq')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/78ZuWSq')
	else
		notify('Discord Invite', 'discord.gg/78ZuWSq')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = '78ZuWSq'}
			})
		})
	end
end)

addcmd('keepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = true
		notify('KeepIY','Infinite Yield will now run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = false
		notify('KeepIY','Infinite Yield will no longer run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = not KeepInfYield
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
	toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

teleportRespawnHandler = [[
local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
if ok and typeof(data) == "CFrame" then
    local Players = game:GetService("Players")
    local ME = Players.LocalPlayer
    while not ME do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        ME = Players.LocalPlayer
    end

    local Character = ME.Character or ME.CharacterAdded:Wait()
    Character:WaitForChild("HumanoidRootPart")

    local t = tick()
    while (tick() - t) <= 0.3 do
        Character:PivotTo(data)
        task.wait()
    end
end
]]
addcmd("rejoin", {"rj"}, function(args, speaker)
    local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            notify("Incompatible Exploit", "Your exploit does not support this argument (missing queue_on_teleport)")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
end)

addcmd("inviteprompt", {}, function(args, speaker)
    local player = getPlayer(args[1], speaker)[1]
    local target = player and Players:FindFirstChild(player)
    if not target then return end
    local success, err = pcall(function()
        ExperienceService:LaunchExperience({
            placeId = PlaceId,
            gameInstanceId = JobId,
            referredByPlayerId = target.UserId
        })
    end)
    if success then
        return "Prompted user. Rejoin for it to work."
    else
        return "There was an error in game:GetService('ExperienceService'):LaunchExperience(). Contact the developer of your exploit."
    end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	else
		return notify("Serverhop", "Couldn't find a server.")
	end
end)

addcmd("exit", {"shutdown", "leave"}, function(args, speaker)
	game:Shutdown()
end)

local NoclipParts = {}
local Noclipping = nil
addcmd("noclip", {}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = false
    task.wait(0.1)
    NoclipParts = {}
    Noclipping = RunService.Stepped:Connect(function()
        if Clip == false and speaker.Character ~= nil then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                    NoclipParts[child] = true
                end
            end
        end
    end)
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Enabled")
end)

addcmd("unnoclip", {"clip"}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = true
    task.wait(0.1)
    for child, _ in pairs(NoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            child.CanCollide = true
        end
    end
    NoclipParts = {}
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Disabled")
end)

addcmd("togglenoclip", {}, function(args, speaker)
    execCmd(Clip and "noclip" or "unnoclip")
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

floating = false
local beganListener: RBXScriptConnection
local endListener: RBXScriptConnection
local floatingFunc: RBXScriptConnection

addcmd('float', {'platform'},function(args, speaker)
	local pchar = speaker.Character
	floatName = randomString()
	floating = true
	
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local floatPoint = -3.1
			local floatPart = Instance.new('Part')
			floatPart.Name = floatName
			floatPart.Parent = pchar
			floatPart.Transparency = 1
			floatPart.Size = Vector3.new(2, 0.2, 1.5)
			floatPart.Anchored = true
			
			notify('Float', 'Started floating (Q = down & E = up)')
			
			beganListener = UserInputService.InputBegan:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint -= 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint += 1.5
				end
			end)
			endListener = UserInputService.InputEnded:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint += 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint -= 1.5
				end
			end)
			
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				floatingFunc:Disconnect()
				floatPart:Destroy()
				floatDied:Disconnect()
				beganListener:Disconnect()
				endListener:Disconnect()
				floatName = nil
			end)
			local function floatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					floatPart.CFrame = getRoot(pchar).CFrame * CFrame.new(0, floatPoint, 0)
				else
					floatingFunc:Disconnect()
					floatPart:Destroy()
					floatDied:Disconnect()
					beganListener:Disconnect()
					endListener:Disconnect()
					floatName = nil
				end
			end			
			floatingFunc = RunService.PreAnimation:Connect(floatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	floating = false
	local pchar = speaker.Character
	notify('Float', 'Stopped floating')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		floatingFunc:Disconnect()
		floatDied:Disconnect()
		beganListener:Disconnect()
		endListener:Disconnect()
		floatName = nil
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(speaker.Character).Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(speaker.Character).Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	end
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1, args)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)


local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)

local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

local wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		On.BackgroundTransparency = 1
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		On.BackgroundTransparency = 0
	else
		minimizeHolder()
	end
end)

addcmd('rec', {'record'}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
	if saveinstance then
		notify("Loading", "Downloading game. This will take a while")
		saveinstance()
		notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
	end
end)

addcmd("clearerror", {"clearerrors"}, function(args, speaker)
    GuiService:ClearError()
end)

addcmd("antigameplaypaused", {}, function(args, speaker)
    pcall(function() networkPaused:Disconnect() end)
    networkPaused = COREGUI.RobloxGui.ChildAdded:Connect(function(obj)
        if obj.Name == "CoreScripts/NetworkPause" then
            obj:Destroy()
        end
    end)
    COREGUI.RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

addcmd("unantigameplaypaused", {}, function(args, speaker)
    networkPaused:Disconnect()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    	local method = getnamecallmethod and getnamecallmethod() or ""
    	if select(1, ...) == LocalPlayer and method == "Kick" or method == "kick" then
        	return nil
    	end
    	return oldNamecall(...)
	end))
	hookfunction(LocalPlayer.Kick, newcclosure(function(self, _)
    	if self ~= lp then
        	error("Expected ':' not '.' calling member function Kick", 2)
    	end
    	return nil
	end))

	notify('Client Antikick','Client anti kick is now active (only effective on LocalScript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end

	local oldTp; oldTp = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, _teleportData, customLoadingScreen)
		if checkcaller() or (allow_rj and placeId == game.PlaceId) then
			return oldTp(self, placeId, player, _teleportData, customLoadingScreen)
		end
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function Teleport", 2)
		end
		if placeId == nil then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(placeId) ~= "number" and placeId ~= true then
			error(`Unable to cast {typeof(placeId)} to int64`, 2)
		elseif placeId == true then
			-- somehow raise raiseTeleportInitFailedEvent
			return
		end
		if typeof(customLoadingScreen) ~= "Instance" and customLoadingScreen ~= nil then
			error("Unable to cast value to Object", 2)
		end
		return nil
	end))
	hookfunction(TeleportService.TeleportAsync, newcclosure(function(self, placeId, players, teleportOptions)
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function TeleportAsync", 2)
		end
		if players == nil then
			error("Argument 2 missing or nil", 2)
		end
		if typeof(players) ~= "table" then
			error("Unable to cast value to Objects", 2)
		end
		error("TeleportUnknown must be called from a Server", 2)
	end))
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local nmc = getnamecallmethod()
		if select(1, ...) == TeleportService and nmc == "teleport" or nmc == "Teleport" or nmc == "TeleportToPlaceInstance" or nmc == "TeleportAsync" then
			if checkcaller() or (allow_rj and select(2, ...) == game.PlaceId) then
				return oldNamecall(...)
			end
			return
		end
		return oldNamecall(...)
	end))

	notify('Client AntiTP','Client anti teleport is now active (only effective on LocalScript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	allow_rj = not allow_rj
	notify("Client AntiTP", `Scripts now may{allow_rj and "" or " not"} make you rejoin the server`)
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
	TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
	UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
	if fpscaploop then
		task.cancel(fpscaploop)
		fpscaploop = nil
	end

	local fpsCap = 60
	local num = tonumber(args[1]) or 1e6
	if num == "none" then
		return
	elseif num > 0 then
		fpsCap = num
	else
		return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
	end

	if setfpscap and type(setfpscap) == "function" then
		setfpscap(fpsCap)
	else
		fpscaploop = task.spawn(function()
			local timer = os.clock()
			while true do
				if os.clock() >= timer + 1 / fpsCap then
					timer = os.clock()
					task.wait()
				end
			end
		end)
	end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1, args))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd("esptransparency", {}, function(args, speaker)
    espTransparency = tonumber(args[1]) or 0.3
    if ESPenabled then execCmd("esp") end
    if CHMSenabled then execCmd("chams") end
    updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1, args):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1, args):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)


fcRunning = false
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
    if not fcRunning then return end
    Input.StopCapture()
    RunService:UnbindFromRenderStep("Freecam")
    PlayerState.Pop()
    workspace.Camera.FieldOfView = 70
    fcRunning = false
end

addcmd("freecam", {"fcam", "fc"},function(args, speaker)
    StartFreecam()
end)

addcmd("freecampos", {"fcpos", "fcp", "freecamposition", "fcposition"},function(args, speaker)
    if not args[1] then return end
    local freecamPos = CFrame.new(args[1], args[2], args[3])
    StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
	local function enableShiftlock() 
		speaker.DevEnableMouseLock = true 
	end
	speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock)
	enableShiftlock()
	notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
	for i = 1, 4 do
		local Tool = Instance.new("HopperBin")
		Tool.BinType = i
		Tool.Name = randomString()
		Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
	end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
	selectPart()
end)

local antiAfkCon = nil
addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end) -- supposed to "pause" it
            pcall(function() c:Disconnect() end) -- supposed to disconnect it
        end
    end

    pcall(function() antiAfkCon:Disconnect() end)
    antiAfkCon = speaker.Idled:Connect(function()
        local VirtualInputManager = Instance.new("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:Destroy()
    end)

    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
	local kbps = tonumber(args[1])
	if kbps then
		Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
	end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
	toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
	toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		toClipboard(game.CreatorId)
		notify('Copied ID','Copied creator ID to clipboard')
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		toClipboard(OwnerID)
		notify('Copied ID','Copied creator ID to clipboard')
	end
end)

addcmd('setcreatorid',{'setcreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify('Set ID','Set UserId to '..game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Set ID','Set UserId to '..OwnerID)
	end
end)

addcmd('appearanceid',{'aid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		notify('Appearance ID',aid)
	end
end)

addcmd('copyappearanceid',{'caid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		toClipboard(aid)
	end
end)

addcmd('norender',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(false)
end)

addcmd('render',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(true)
end)

addcmd('2022materials',{'use2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", true)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('un2022materials',{'unuse2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", false)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd("goto", {"to"}, function(args, speaker)
	local character = speaker and speaker.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	if humanoid == nil then return end

	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end

	local waitForStream = parseBoolean(args[2], false)
	for _, name in getPlayer(args[1], speaker) do
		local targetCharacter = Players[name].Character
		if targetCharacter ~= nil then
			local targetPivot = targetCharacter:GetPivot()
			local targetPosition = targetPivot.Position

			if waitForStream and workspace.StreamingEnabled then
				task.spawn(speaker.RequestStreamAroundAsync, speaker, targetPosition, 5)
				targetCharacter:WaitForChild("HumanoidRootPart", 5)
			end

			speaker.Character:PivotTo(CFrame.new(targetPosition + (targetPivot.LookVector * 3), targetPosition))
			breakVelocity()
			break
		end
	end
end)

addcmd("tweengoto", {"tgoto", "tto", "tweento"}, function(args, speaker)
    local character = speaker and speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

    local oldState = humanoid and humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated)
    if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end

    local players = getPlayer(args[1], speaker)
    for _, v in pairs(players) do
        if Players[v].Character ~= nil then
            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.1)
            end
            TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {
                CFrame = getRoot(Players[v].Character):GetPivot() + Vector3.new(3, 1, 0)
            }):Play()
        end
    end
    execCmd("breakvelocity")

    if type(oldState) == "boolean" then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, oldState)
    end
end)

addcmd("vehiclegoto", {"vgoto", "vtp", "vehicletp"}, function(args, speaker)
    local character = speaker.Character
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not humanoid then return end

    local seat = humanoid.SeatPart
    local vehicleModel = if seat then seat:FindFirstAncestorWhichIsA("Model") else nil
    if vehicleModel == nil then
        notify("Vehicle Goto", "Make sure you're sitting in a vehicle.")
        return
    end

    for _, v in getPlayer(args[1], speaker) do
        if Players[v].Character == nil then continue end

        local root = getRoot(Players[v].Character)
        if root == nil then continue end

        vehicleModel:PivotTo(root:GetPivot())
        break
    end
end)

addcmd('pulsetp',{'ptp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local startPos = getRoot(speaker.Character).CFrame
			local seconds = args[2] or 1
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
			wait(seconds)
			getRoot(speaker.Character).CFrame = startPos
		end
	end
	execCmd('breakvelocity')
end)

local vnoclipParts = {}
addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	vnoclipParts = {}
	local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
	local vehicleModel = seat.Parent
	repeat
		if vehicleModel.ClassName ~= "Model" then
			vehicleModel = vehicleModel.Parent
		end
	until vehicleModel.ClassName == "Model"
	wait(0.1)
	execCmd('noclip')
	for i,v in pairs(vehicleModel:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			table.insert(vnoclipParts,v)
			v.CanCollide = false
		end
	end
end)

addcmd("vehicleclip", {"vclip", "unvnoclip", "unvehiclenoclip"}, function(args, speaker)
	execCmd("clip")
	for i, v in pairs(vnoclipParts) do
		v.CanCollide = true
	end
	vnoclipParts = {}
end)

addcmd("togglevnoclip", {}, function(args, speaker)
	execCmd(Clip and "vnoclip" or "vclip")
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if Players[v].Character:FindFirstChildOfClass('Humanoid') then
				Players[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if Players:FindFirstChild(v) then
							pchar = Players[v].Character
							if pchar~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

local walkto = false
local waypointwalkto = false
addcmd('walkto',{'follow'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalkto',{'pathfindfollow'},function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path:ComputeAsync(getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path:GetWaypoints()
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum:MoveTo(waypointPosition)
						repeat 
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
				end
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalktowaypoint',{'pathfindwalktowp'},function(args, speaker)
	waypointwalkto = false
	wait()
	local WPName = tostring(getstring(1, args))
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = Vector3.new(WayPoints[i].COORD[1], WayPoints[i].COORD[2], WayPoints[i].COORD[3])
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = pWayPoints[i].COORD[1].Position
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
	end
end)

addcmd('unwalkto',{'nowalkto','unfollow','nofollow'},function(args, speaker)
	walkto = false
	waypointwalkto = false
end)

addcmd("orbit", {}, function(args, speaker)
	execCmd("unorbit nonotify")

	local target = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = getRoot(speaker.Character)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")

	if target and target.Character and getRoot(target.Character) and root and humanoid then
		local rotation = 0
		local speed = tonumber(args[2]) or 0.2
		local distance = tonumber(args[3]) or 6

		orbit1 = RunService.Stepped:Connect(function()
			breakVelocity()
			rotation = rotation + speed

			local targetRoot = getRoot(target.Character).Position
			local orbitPosition = (CFrame.new(targetRoot) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)).Position
			root.CFrame = CFrame.lookAt(orbitPosition, Vector3.new(targetRoot.X, orbitPosition.Y, targetRoot.Z))
		end)

		orbit2 = humanoid.Died:Connect(function() execCmd("unorbit") end)

		orbit3 = humanoid.Seated:Connect(function(value)
			if value then execCmd("unorbit") end
		end)

		notify("Orbit", "Started orbiting " .. formatUsername(target))
	end
end)

addcmd("unorbit", {}, function(args, speaker)
	if orbit1 then orbit1:Disconnect() end
	if orbit2 then orbit2:Disconnect() end
	if orbit3 then orbit3:Disconnect() end
	if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)


addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)


addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

addcmd("anchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = true
end)

addcmd("unanchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = false
end)

oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild'Head' then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

local notifiedRespectFiltering = false
addcmd('muteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, Players[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	else
		speaker.Character:BreakJoints()
	end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

addcmd("respawn", {}, function(args, speaker)
	respawn(speaker)
end)

addcmd("refresh", {"re"}, function(args, speaker)
	refresh(speaker)
end)

addcmd("god", {}, function(args, speaker)
	local Cam = workspace.CurrentCamera
	local Char, Pos = speaker.Character, Cam.CFrame
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local nHuman = Human:Clone()
	nHuman.Parent = char
	speaker.Character = nil
	nHuman:SetStateEnabled(15, false)
	nHuman:SetStateEnabled(1, false)
	nHuman:SetStateEnabled(0, false)
	nHuman.BreakJointsOnDeath = true
	Human:Destroy()
	speaker.Character = char
	Cam.CameraSubject = nHuman
	Cam.CFrame = task.wait() and pos
	nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local Script = Char:FindFirstChild("Animate")
	if Script then
		Script.Disabled = true
		task.wait()
		Script.Disabled = false
	end
	nHuman.Health = nHuman.MaxHealth
end)

invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	-- Full credit to AmokahFox @V3rmillion
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = RunService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.Humanoid.RootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.Humanoid.RootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.Humanoid.RootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.Humanoid.RootPart.CFrame
		Character.Humanoid.RootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	notify('Invisible','You now appear invisible to other players')
end)

addcmd("visible", {"vis","uninvisible"}, function(args, speaker)
	TurnVisible()
end)

addcmd("toggleinvis", {}, function(args, speaker)
	execCmd(invisRunning and "visible" or "invisible")
end)

addcmd('toolinvisible',{'toolinvis','tinvis'},function(args, speaker)
	local Char  = Players.LocalPlayer.Character
	local touched = false
	local tpdback = false
	local box = Instance.new('Part')
	box.Anchored = true
	box.CanCollide = true
	box.Size = Vector3.new(10,1,10)
	box.Position = Vector3.new(0,10000,0)
	box.Parent = workspace
	local boxTouched = box.Touched:connect(function(part)
		if (part.Parent.Name == Players.LocalPlayer.Name) then
			if touched == false then
				touched = true
				local function apply()
					local no = Char.Humanoid.RootPart:Clone()
					task.wait(.25)
					Char.Humanoid.RootPart:Destroy()
					no.Parent = Char
					Char:MoveTo(loc)
					touched = false
				end
				if Char then
					apply()
				end
			end
		end
	end)
	repeat wait() until Char
	local cleanUp
	cleanUp = Players.LocalPlayer.CharacterAdded:connect(function(char)
		boxTouched:Disconnect()
		box:Destroy()
		cleanUp:Disconnect()
	end)
	loc = Char.Humanoid.RootPart.Position
	Char:MoveTo(box.Position + Vector3.new(0,.5,0))
end)

addcmd("strengthen", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
			end
		end
	end
end)

addcmd("weaken", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(-args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
			end
		end
	end
end)

addcmd("unweaken", {"unstrengthen"}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd("breakvelocity", {}, function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

addcmd('jpower',{'jumppower','jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd("maxslopeangle", {"msa"}, function(args, speaker)
	local sangle = args[1] or 89
	if isNumber(sangle) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").MaxSlopeAngle = sangle
	end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
	local grav = args[1] or oldgrav
	if isNumber(grav) then
		workspace.Gravity = grav
	end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
	local hipHeight = args[1] or (r15(speaker) and 2.1 or 0)
	if isNumber(hipHeight) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = hipHeight
	end
end)

addcmd("dance", {}, function(args, speaker)
	pcall(execCmd, "undance")
	local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
	if r15(speaker) then
		dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
	danceTrack = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack:Play()
end)

addcmd("undance", {"nodance"}, function(args, speaker)
	danceTrack:Stop()
	danceTrack:Destroy()
end)

addcmd("defemote", {}, function(args, speaker)
	if args[1] then
		if speaker.Character then
			speaker.Character.Animate.PlayEmote:Invoke(getstring(1, args))
		end
	end
end)

addcmd('nolimbs',{'rlimbs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" or
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" or
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('noarms',{'rarms'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('nolegs',{'rlegs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" then
				v:Destroy()
			end
		end
	end
end)

addcmd("sit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid").Sit = true
end)

addcmd("lay", {"laydown"}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Sit = true
	task.wait(0.1)
	humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

addcmd("sitwalk", {}, function(args, speaker)
	local anims = speaker.Character.Animate
	local sit = anims.sit:FindFirstChildWhichIsA("Animation").AnimationId
	anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sit
	speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = not r15(speaker) and -1.5 or 0.5
end)

addcmd("nosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

addcmd("unnosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local infJump
infJumpDebounce = false
addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = UserInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

local flyjump
addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = UserInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	-- Full credit to NoelGamer06 @V3rmillion
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.Humanoid.RootPart.CFrame = lastcf
				Char.Humanoid.RootPart.Velocity = Vector3.new(Char.Humanoid.RootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.Humanoid.RootPart.Velocity.Z)
			end
			lastcf = Char.Humanoid.RootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd("team", {}, function(args, speaker)
	local teamName = getstring(1, args)
	local team = nil
	local root = speaker.Character and getRoot(speaker.Character)
	for _, v in ipairs(Teams:GetChildren()) do
		if v.Name:lower():match(teamName:lower()) then
			team = v
			break
		end
	end
	if not team then
		return notify("Invalid Team", teamName .. " is not a valid team")
	end
	if root and firetouchinterest then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("SpawnLocation") and v.BrickColor == team.TeamColor and v.AllowTeamChangeOnTouch == true then
				firetouchinterest(v, root, 0)
				firetouchinterest(v, root, 1)
				break
			end
		end
	else
		speaker.Team = team
	end
end)

addcmd('nobgui',{'unbgui','nobillboardgui','unbillboardgui','noname','rohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
end)

addcmd('loopnobgui',{'loopunbgui','loopnobillboardgui','loopunbillboardgui','loopnoname','looprohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
	local function charPartAdded(part)
		if part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
			wait()
			part:Destroy()
		end
	end
	charPartTrigger = speaker.Character.DescendantAdded:Connect(charPartAdded)
end)

addcmd('unloopnobgui',{'unloopunbgui','unloopnobillboardgui','unloopunbillboardgui','unloopnoname','unlooprohg'},function(args, speaker)
	if charPartTrigger then
		charPartTrigger:Disconnect()
	end
end)

addcmd('spasm',{},function(args, speaker)
	if not r15(speaker) then
		local pchar=speaker.Character
		local AnimationId = "33796059"
		SpasmAnim = Instance.new("Animation")
		SpasmAnim.AnimationId = "rbxassetid://"..AnimationId
		Spasm = pchar:FindFirstChildOfClass('Humanoid'):LoadAnimation(SpasmAnim)
		Spasm:Play()
		Spasm:AdjustSpeed(99)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('unspasm',{'nospasm'},function(args, speaker)
	Spasm:Stop()
	SpasmAnim:Destroy()
end)

addcmd('headthrow',{},function(args, speaker)
	if not r15(speaker) then
		local AnimationId = "35154961"
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..AnimationId
		local k = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Anim)
		k:Play(0)
		k:AdjustSpeed(1)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

local function anim2track(asset_id)
	local objs = game:GetObjects(asset_id)
	for i = 1, #objs do
		if objs[i]:IsA("Animation") then
			return objs[i].AnimationId
		end
	end
	return asset_id
end

addcmd("animation", {"anim"}, function(args, speaker)
	local animid = tostring(args[1])
	if not animid:find("rbxassetid://") then
		animid = "rbxassetid://" .. animid
	end
	animid = anim2track(animid)
	local animation = Instance.new("Animation")
	animation.AnimationId = animid
	local anim = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	anim.Priority = Enum.AnimationPriority.Movement
	anim:Play()
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd("emote", {"em"}, function(args, speaker)
	local anim = humanoid:PlayEmoteAndGetAnimTrackById(args[1])
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd('noanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = true
end)

addcmd('reanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = false
end)

addcmd('animspeed',{},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(args[1] or 1))
	end
end)

addcmd('copyanimation',{'copyanim','copyemote'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		for _, v1 in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			v1:Stop()
		end
		for _, v1 in pairs(Players[v].Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local ANIM = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(v1.Animation)
				ANIM:Play(.1, 1, v1.Speed)
				ANIM.TimePosition = v1.TimePosition
				task.spawn(function()
					v1.Stopped:Wait()
					ANIM:Stop()
					ANIM:Destroy()
				end)
			end
		end
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
	local copyAnimId = function(player)
		local found = "Animations Copied"

		for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
			local animationId = v.Animation.AnimationId
			local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")

			if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
				if assetId then
					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(tonumber(assetId)).Name
					end)
					local name = success and result or "Failed to get name"
					found = found .. "\n\nName: " .. name .. "\nAnimation Id: " .. animationId
				else
					found = found .. "\n\nAnimation Id: " .. animationId
				end
			end
		end

		if found ~= "Animations Copied" then
			toClipboard(found)
		else
			notify("Animations", "No animations to copy")
		end
	end

	if args[1] then
		copyAnimId(Players[getPlayer(args[1], speaker)[1]])
	else
		copyAnimId(speaker)
	end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('allowcustomanim', {'allowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = true
	execCmd('refreshanimations')
end)

addcmd('unallowcustomanim', {'unallowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = false
	execCmd('refreshanimations')
end)

addcmd('loopanimation', {'loopanim'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Looped = true
	end
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('tweentpposition',{'ttppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd("offset", {}, function(args, speaker)
    if #args < 3 then return end
    speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
end)

addcmd("tweenoffset", {"toffset"}, function(args, speaker)
    if #args < 3 then return end
    local tpX, tpY, tpZ = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    local root = getRoot(speaker.Character)
    local pos = root.Position + Vector3.new(tpX, tpY, tpZ)
    TweenService:Create(root, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}):Play()
    breakVelocity()
end)

addcmd("clickteleport", {}, function(args, speaker)
    if speaker ~= Players.LocalPlayer then return end
    notify("Click TP", "Go to Settings > Keybinds > Add to set up click teleport")
end)

addcmd("mouseteleport", {"mousetp"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local pos = IYMouse.Hit
    if root and pos then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end
end)

addcmd("tptool", {"teleporttool"}, function(args, speaker)
    local TpTool = Instance.new("Tool")
    TpTool.Name = "Teleport Tool"
    TpTool.RequiresHandle = false
    TpTool.Parent = speaker:FindFirstChildOfClass("Backpack")
    TpTool.Activated:Connect(function()
        local root = getRoot(speaker.Character)
        local pos = IYMouse.Hit
        if not root or not pos then return end
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end)
end)

addcmd("thru", {}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local num = tonumber(args[1]) or 5
    local pos = root.CFrame.Position + (root.CFrame.LookVector * num)
    root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
end)

addcmd('clickdelete',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click Delete','Go to Settings > Keybinds > Add to set up click delete')
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('walktopos',{'walktoposition'},function(args, speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
	speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(args[1],args[2],args[3])
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('spoofspeed',{'spoofws','spoofwalkspeed'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setspeed;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return setspeed or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					setspeed = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopspeed',{'loopws'},function(args, speaker)
	local speed = args[1] or 16
	if args[2] then
		speed = args[2] or 16
	end
	if isNumber(speed) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function WalkSpeedChange()
			if Char and Human then
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		end)
	end
end)

addcmd('unloopspeed',{'unloopws'},function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
end)

addcmd('spoofjumppower',{'spoofjp'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setpower;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return setpower or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					setpower = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopjumppower',{'loopjp','loopjpower'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function JumpPowerChange()
			if Char and Human then
				if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
				else
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		end)
	end
end)

addcmd('unloopjumppower',{'unloopjp','unloopjpower'},function(args, speaker)
	local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or nil
	if Char and Human then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = 50
		end
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(Lighting)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(ReplicatedStorage)
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('deleteselectedtool',{'dst'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
	StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	-- Thanks wally!!
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

-- NOVA Dex++ right-click remote repeater: optional arguments per remote and per-remote stop.
-- This patches Dex++'s real Explorer context menu before loading it, without modifying
-- its upstream scripts or intercepting unrelated game traffic.
local NOVA_DEX_URL = "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"
local NOVA_DEX_MENU_MARKER = 'if presentClasses["RemoteEvent"] then context:AddRegistered("BLOCK_REMOTE", env.hookfunction == nil) end'
local NOVA_DEX_REG_MARKER = 'Explorer.RightClickContext = context'

local NOVA_DEX_MENU_INSERT = [==[
		-- NOVA: show actions only for one selected client-to-server remote.
		if #sList == 1 and (presentClasses["RemoteEvent"] or presentClasses["RemoteFunction"] or presentClasses["UnreliableRemoteEvent"]) then
			context:AddRegistered("NOVA_REPEAT_START")
			context:AddRegistered("NOVA_REPEAT_STOP")
		end

]==]

local NOVA_DEX_REG_INSERT = [==[
		-- NOVA remote repeater. Keep its state across Dex windows and repeated loads.
		local novaGlobal = (type(getgenv) == "function" and getgenv()) or _G
		local novaState = novaGlobal.NOVA_DexRemoteRepeater
		if type(novaState) ~= "table" then
			novaState = {
				loops = setmetatable({}, {__mode = "k"}),
				args = setmetatable({}, {__mode = "k"}),
			}
			novaGlobal.NOVA_DexRemoteRepeater = novaState
		end
		novaState.loops = novaState.loops or setmetatable({}, {__mode = "k"})
		novaState.args = novaState.args or setmetatable({}, {__mode = "k"})

		local function novaSelectedRemote()
			local entries = selection.List
			if #entries ~= 1 then return nil end
			local remote = entries[1].Obj
			if not remote then return nil end
			if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("UnreliableRemoteEvent") then
				return remote
			end
			return nil
		end

		local function novaNotice(message)
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "NOVA Dex++",
					Text = message,
					Duration = 4,
				})
			end)
		end

		context:Register("NOVA_REPEAT_START", {
			Name = "NOVA: Start Auto Fire (0.01s)",
			IconMap = Explorer.MiscIcons,
			Icon = "Play",
			OnClick = function()
				local remote = novaSelectedRemote()
				if not remote then return end
				local existing = novaState.loops[remote]
				if existing and existing.running then
					novaNotice("Already running: " .. remote.Name)
					return
				end
				local job = {running = true, sent = 0, errors = 0}
				novaState.loops[remote] = job
				novaNotice("Started: " .. remote.Name .. " (0.01s)")

				task.spawn(function()
					local isFunction = remote:IsA("RemoteFunction")
					while job.running and remote.Parent ~= nil do
						-- Default to no arguments. For remotes expecting args, set
						-- getgenv().NOVA_DexRemoteRepeater.args[remote] = table.pack(...)
						local savedArgs = novaState.args[remote]
						local params = type(savedArgs) == "table" and savedArgs or {}
						local count = type(params.n) == "number" and params.n or #params
						local ok, err = pcall(function()
							if isFunction then
								remote:InvokeServer(table.unpack(params, 1, count))
							else
								remote:FireServer(table.unpack(params, 1, count))
							end
						end)
						if ok then
							job.sent = job.sent + 1
							job.errors = 0
						else
							job.errors = job.errors + 1
							if job.errors >= 3 then
								warn("[NOVA Dex] Repeater stopped for " .. remote.Name .. ": " .. tostring(err))
								novaNotice("Stopped after errors: " .. remote.Name)
								break
							end
						end
						-- Requested minimum interval; frame rate/network/server may limit rate.
						task.wait(0.01)
					end
					job.running = false
					if novaState.loops[remote] == job then
						novaState.loops[remote] = nil
					end
				end)
			end,
		})

		context:Register("NOVA_REPEAT_STOP", {
			Name = "NOVA: Stop Auto Fire",
			IconMap = Explorer.MiscIcons,
			Icon = "Pause",
			OnClick = function()
				local remote = novaSelectedRemote()
				if not remote then return end
				local job = novaState.loops[remote]
				if job and job.running then
					job.running = false
					novaNotice("Stopping: " .. remote.Name)
				else
					novaNotice("Not running: " .. remote.Name)
				end
			end,
		})

]==]

local function novaDexInsertBefore(sourceText, marker, injection)
    local at = string.find(sourceText, marker, 1, true)
    if not at then return nil end
    return string.sub(sourceText, 1, at - 1) .. injection .. string.sub(sourceText, at)
end

local function novaPatchDex(sourceText)
    if type(sourceText) ~= "string" or #sourceText < 1000 then
        return nil, "Dex++ download was empty or invalid"
    end
    if string.find(sourceText, "NOVA_REPEAT_START", 1, true) then
        return sourceText -- Already patched.
    end
    local patched = novaDexInsertBefore(sourceText, NOVA_DEX_MENU_MARKER, NOVA_DEX_MENU_INSERT)
    if not patched then
        return nil, "Dex++ Explorer menu layout has changed"
    end
    patched = novaDexInsertBefore(patched, NOVA_DEX_REG_MARKER, NOVA_DEX_REG_INSERT)
    if not patched then
        return nil, "Dex++ Explorer registration layout has changed"
    end
    return patched
end

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Loading Dex++ with NOVA remote actions")
    local downloaded, sourceOrError = pcall(function()
        return game:HttpGet(NOVA_DEX_URL)
    end)
    if not downloaded then
        warn("[NOVA Dex] Download failed: " .. tostring(sourceOrError))
        notify("Dex++", "Download failed; check console")
        return
    end
    local patched, patchError = novaPatchDex(sourceOrError)
    if not patched then
        warn("[NOVA Dex] " .. tostring(patchError))
        notify("Dex++", "Patch incompatible with this Dex++ version")
        return
    end
    local compiled, syntaxError = loadstring(patched)
    if type(compiled) ~= "function" then
        warn("[NOVA Dex] Compilation failed: " .. tostring(syntaxError))
        notify("Dex++", "Failed to compile patched Dex++")
        return
    end
    local launched, runtimeError = pcall(compiled)
    if not launched then
        warn("[NOVA Dex] Launch error: " .. tostring(runtimeError))
        notify("Dex++", "Launch failed; check console")
    end
end)

addcmd("moondex", {"mdex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd("remotespy", {"rspy", "cobalt", "cspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to notpoiu, creator of Cobalt
    loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
end)

addcmd("simplespy", {"sspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to exx, creator of SimpleSpy
    -- also thanks to Amity for fixing
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

local loopgoto = nil
addcmd('loopgoto',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		loopgoto = nil
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		loopgoto = Players[v]
		local distance = 3
		if args[2] and isNumber(args[2]) then
			distance = args[2]
		end
		local lDelay = 0
		if args[3] and isNumber(args[3]) then
			lDelay = args[3]
		end
		repeat
			if Players:FindFirstChild(v) then
				if Players[v].Character ~= nil then
					getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,1,0)
				end
				wait(lDelay)
			else
				loopgoto = nil
			end
		until loopgoto ~= Players[v]
	end
end)

addcmd('unloopgoto',{'noloopgoto'},function(args, speaker)
	loopgoto = nil
end)

addcmd('headsit',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if headSit then headSit:Disconnect() end
	for i,v in pairs(players)do
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
		headSit = RunService.Heartbeat:Connect(function()
			if Players:FindFirstChild(Players[v].Name) and Players[v].Character ~= nil and getRoot(Players[v].Character) and getRoot(speaker.Character) and speaker.Character:FindFirstChildOfClass('Humanoid').Sit == true then
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame * CFrame.Angles(0,math.rad(0),0)* CFrame.new(0,1.6,0.4)
			else
				headSit:Disconnect()
			end
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1, args)
	chatMessage(cString)
end)

addcmd("vsay", {}, function(args, speaker)
	if speaker.Character and speaker.Character:FindFirstChild("Head") then
		game.Chat:Chat(speaker.Character.Head, getstring(1, args), Enum.ChatColor.White)
	end
end)

spamming = false
spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1, args)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('whisper',{'pm'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2, args)
			chatMessage("/w "..plrName.." "..pmstring)
		end)
	end
end)

pmspamming = {}
addcmd('pmspam',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			if FindInTable(pmspamming, plrName) then return end
			table.insert(pmspamming, plrName)
			local pmspamstring = getstring(2, args)
			repeat
				if Players:FindFirstChild(v) then
					wait(spamspeed)
					chatMessage("/w "..plrName.." "..pmspamstring)
				else
					for a,b in pairs(pmspamming) do if b == plrName then table.remove(pmspamming, a) end end
				end
			until not FindInTable(pmspamming, plrName)
		end)
	end
end)

addcmd('nopmspam',{'unpmspam'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(pmspamming) do
				if b == Players[v].Name then
					table.remove(pmspamming, a)
				end
			end
		end)
	end
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('bubblechat',{},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

addcmd('unbubblechat',{'nobubblechat'},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end)

addcmd("chatwindow", {}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = true
end)

addcmd("unchatwindow", {"nochatwindow"}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = false
end)

addcmd("darkchat", {}, function(args, speaker)
    local BCC = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
    local CWC = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    local CIBC = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
    if BCC then
        BCC.Enabled = true
        BCC.BackgroundColor3 = Color3.fromRGB()
        BCC.BackgroundTransparency = 0.3
        BCC.TailVisible = true
        BCC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
    end
    if CWC then
        CWC.Enabled = true
        CWC.BackgroundColor3 = Color3.fromRGB()
        CWC.BackgroundTransparency = 0.3
        CWC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CWC.TextStrokeColor3 = Color3.fromRGB()
        CWC.TextStrokeTransparency = 0.5
    end
    if CIBC then
        CIBC.Enabled = true
        CIBC.BackgroundColor3 = Color3.fromRGB()
        CIBC.BackgroundTransparency = 0.5
        CIBC.PlaceholderColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextStrokeColor3 = Color3.fromRGB()
        CIBC.TextStrokeTransparency = 0.5
    end
end)

addcmd('blockhead',{},function(args, speaker)
	speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

addcmd('blockhats',{},function(args, speaker)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		for i,c in pairs(v:GetDescendants()) do
			if c:IsA("SpecialMesh") then
				c:Destroy()
			end
		end
	end
end)

addcmd('blocktool',{},function(args, speaker)
	for _,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			for i,c in pairs(v:GetDescendants()) do
				if c:IsA("SpecialMesh") then
					c:Destroy()
				end
			end
		end
	end
end)

addcmd('creeper',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character.LeftUpperArm:Destroy()
		speaker.Character.RightUpperArm:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	else
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character["Left Arm"]:Destroy()
		speaker.Character["Right Arm"]:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	end
end)

function getTorso(x)
	x = x or Players.LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

addcmd("bang", {"rape"}, function(args, speaker)
	execCmd("unbang")
	wait()
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(args[2] or 3)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)
	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
			break
		end
	end
end)

addcmd("unbang", {"unrape"}, function(args, speaker)
	if bangDied then
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
	end
end)

addcmd('carpet',{},function(args, speaker)
	if not r15(speaker) then
		execCmd('uncarpet')
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players)do
			carpetAnim = Instance.new("Animation")
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
			carpet:Play(.1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = speaker.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
				carpetLoop:Disconnect()
				carpet:Stop()
				carpetAnim:Destroy()
				carpetDied:Disconnect()
			end)
			carpetLoop = RunService.Heartbeat:Connect(function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('uncarpet',{'nocarpet'},function(args, speaker)
	if carpetLoop then
		carpetLoop:Disconnect()
		carpetDied:Disconnect()
		carpet:Stop()
		carpetAnim:Destroy()
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(Players[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(Players[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('bringpartclass',{'bpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

gotopartDelay = 0.1
addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopart',{'tgotopart','ttopart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotopartclass',{'gpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopartclass',{'tgpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotomodel',{'tomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v:GetModelCFrame()
		end
	end
end)

addcmd('tweengotomodel',{'tgotomodel','ttomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v:GetModelCFrame()}):Play()
		end
	end
end)

addcmd('gotopartdelay',{},function(args, speaker)
	local gtpDelay = args[1] or 0.1
	if isNumber(gtpDelay) then
		gotopartDelay = gtpDelay
	end
end)

addcmd('noclickdetectorlimits',{'nocdlimits','removecdlimits'},function(args, speaker)
	for i,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireclickdetectors',{'firecd','firecds'}, function(args, speaker)
	if fireclickdetector then
		if args[1] then
			local name = getstring(1, args):lower()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") and descendant.Name:lower() == name or descendant.Parent.Name:lower() == name then
					fireclickdetector(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireclickdetector)")
	end
end)

addcmd('noproximitypromptlimits',{'nopplimits','removepplimits'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireproximityprompts',{'firepp'},function(args, speaker)
	if fireproximityprompt then
		if args[1] then
			local name = getstring(1, args)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Name == name or descendant.Parent.Name == name then
					fireproximityprompt(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					fireproximityprompt(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
	end
end)

local PromptButtonHoldBegan = nil
addcmd('instantproximityprompts',{'instantpp'},function(args, speaker)
	if fireproximityprompt then
		execCmd("uninstantproximityprompts")
		wait(0.1)
		PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			fireproximityprompt(prompt)
		end)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing fireproximityprompt)')
	end
end)

addcmd('uninstantproximityprompts',{'uninstantpp'},function(args, speaker)
	if PromptButtonHoldBegan ~= nil then
		PromptButtonHoldBegan:Disconnect()
		PromptButtonHoldBegan = nil
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd('grabtools', {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(workspace:GetChildren()) do
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end

	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	grabtoolsFunc = workspace.ChildAdded:Connect(function(child)
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end)

	notify("Grabtools", "Picking up any dropped tools")
end)

addcmd('nograbtools',{'ungrabtools'},function(args, speaker)
	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	notify("Grabtools", "Grabtools has been disabled")
end)

local specifictoolremoval = {}
addcmd('removespecifictool',{},function(args, speaker)
	if args[1] and speaker:FindFirstChildOfClass("Backpack") then
		local tool = string.lower(getstring(1, args))
		local RST = RunService.RenderStepped:Connect(function()
			if speaker:FindFirstChildOfClass("Backpack") then
				for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
					if v.Name:lower() == tool then
						v:Remove()
					end
				end
			end
		end)
		specifictoolremoval[tool] = RST
	end
end)

addcmd('unremovespecifictool',{},function(args, speaker)
	if args[1] then
		local tool = string.lower(getstring(1, args))
		if specifictoolremoval[tool] ~= nil then
			specifictoolremoval[tool]:Disconnect()
			specifictoolremoval[tool] = nil
		end
	end
end)

addcmd('clearremovespecifictool',{},function(args, speaker)
	for obj in pairs(specifictoolremoval) do
		specifictoolremoval[obj]:Disconnect()
		specifictoolremoval[obj] = nil
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('copytools',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for i,v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
				if v:IsA('Tool') or v:IsA('HopperBin') then
					v:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
				end
			end
		end)
	end
end)

addcmd('naked',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
end)

addcmd('noface',{'removeface'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name == 'face' then
			v:Destroy()
		end
	end
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
end)

addcmd('nospawnpoint',{'nospawn','removespawnpoint'},function(args, speaker)
	spawnpoint = false
	notify('Spawn Point','Removed spawn point')
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
	if lastDeath ~= nil then
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = lastDeath
	end
end)

addcmd('hatspin',{'spinhats'},function(args, speaker)
	execCmd('unhatspin')
	wait(.5)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		local keep = Instance.new("BodyPosition") keep.Name = randomString() keep.Parent = v.Handle
		local spin = Instance.new("BodyAngularVelocity") spin.Name = randomString() spin.Parent = v.Handle
		v.Handle:FindFirstChildOfClass("Weld"):Destroy()
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = RunService.Stepped:Connect(function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

addcmd('unhatspin',{'unspinhats'},function(args, speaker)
	if spinhats then
		spinhats:Disconnect()
	end
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
				c:Destroy()
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

addcmd('clearhats',{'cleanhats'},function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = getRoot(Character).CFrame
		local Hats = {}

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(Hats, child)
			end
		end

		for _, accessory in ipairs(Character:FindFirstChildOfClass("Humanoid"):GetAccessories()) do
			accessory:Destroy()
		end

		for i = 1, #Hats do
			repeat RunService.Heartbeat:wait() until Hats[i]
			firetouchinterest(Hats[i].Handle,getRoot(Character),0)
			repeat RunService.Heartbeat:wait() until Character:FindFirstChildOfClass("Accessory")
			Character:FindFirstChildOfClass("Accessory"):Destroy()
			repeat RunService.Heartbeat:wait() until not Character:FindFirstChildOfClass("Accessory")
		end

		execCmd("reset")

		Player.CharacterAdded:Wait()

		for i = 1,20 do 
			RunService.Heartbeat:Wait()
			if getRoot(Player.Character) then
				getRoot(Player.Character).Humanoid.RootPart.CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit","Your exploit does not support this command (missing firetouchinterest)")
	end
end)

addcmd('split',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.UpperTorso.Waist:Destroy()
	else
		notify('R15 Required','This command requires the r15 rig type')
	end
end)

addcmd('nilchar',{},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = nil
	end
end)

addcmd('unnilchar',{'nonilchar'},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = workspace
	end
end)

addcmd('noroot',{'removeroot','rroot'},function(args, speaker)
	if speaker.Character ~= nil then
		local char = Players.LocalPlayer.Character
		char.Parent = nil
		char.Humanoid.RootPart:Destroy()
		char.Parent = workspace
	end
end)

addcmd('replaceroot',{'replacerootpart'},function(args, speaker)
	if speaker.Character ~= nil and getRoot(speaker.Character) then
		local Char = speaker.Character
		local OldParent = Char.Parent
		local HRP = Char and getRoot(Char)
		local OldPos = HRP.CFrame
		Char.Parent = game
		local HRP1 = HRP:Clone()
		HRP1.Parent = Char
		HRP = HRP:Destroy()
		HRP1.CFrame = OldPos
		Char.Parent = OldParent
	end
end)

addcmd('clearcharappearance',{'clearchar','clrchar'},function(args, speaker)
	speaker:ClearCharacterAppearance()
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

local function GetHandleTools(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and p.Character:GetChildren() or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(p.Backpack:GetChildren()) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end
addcmd('dupetools', {'clonetools'}, function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.Humanoid.RootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = speaker.Character:WaitForChild("Humanoid")
		wait(.1, Human.Parent:MoveTo(TempPos))
		Human.RootPart.Anchored = speaker:ClearCharacterAppearance(wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				task.spawn(function()
					for _ = 1, 25 do
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = speaker.Character:Destroy()
		speaker.CharacterAdded:Wait():WaitForChild("Humanoid").Parent:MoveTo(LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.Humanoid.RootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					task.spawn(function()
						local x = v.CanCollide
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

addcmd('touchinterests', {'touchinterest', 'firetouchinterests', 'firetouchinterest'}, function(args, speaker)
	local Root = getRoot(speaker.Character) or speaker.Character:FindFirstChildWhichIsA("BasePart")

	if not firetouchinterest then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
		return
	end

	local function Touch(x)
		x = x.FindFirstAncestorWhichIsA(x, "Part")
		if x then
			return task.spawn(function()
				firetouchinterest(x, Root, 1, wait() and firetouchinterest(x, Root, 0))
			end)
		end
		x.CFrame = Root.CFrame
	end

	if args[1] then
		local name = getstring(1, args):lower()
		print(name..' -name')
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("TouchTransmitter") and v.Name:lower() == name or v.Parent.Name:lower() == name then
				Touch(v)
			end
		end
	else
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.IsA(v, "TouchTransmitter") then
				Touch(v)
			end
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('loopfullbright',{'loopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
	local function brightFunc()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end

	brightLoop = RunService.RenderStepped:Connect(brightFunc)
end)

addcmd('unloopfullbright',{'unloopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
end)

addcmd('ambient',{},function(args, speaker)
	Lighting.Ambient = Color3.new(args[1],args[2],args[3])
	Lighting.OutdoorAmbient = Color3.new(args[1],args[2],args[3])
end)

addcmd('day',{},function(args, speaker)
	Lighting.ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	Lighting.ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('brightness',{},function(args, speaker)
	Lighting.Brightness = args[1]
end)

addcmd("globalshadows", {"gshadows"}, function(args, speaker)
    Lighting.GlobalShadows = true
end)

addcmd("unglobalshadows", {"ungshadows"}, function(args, speaker)
    Lighting.GlobalShadows = false
end)

origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}

addcmd('restorelighting',{'rlighting'},function(args, speaker)
	Lighting.Ambient = origsettings.abt
	Lighting.OutdoorAmbient = origsettings.oabt
	Lighting.Brightness = origsettings.brt
	Lighting.ClockTime = origsettings.time
	Lighting.FogEnd = origsettings.fe
	Lighting.FogStart = origsettings.fs
	Lighting.GlobalShadows = origsettings.gs
end)

addcmd('stun',{'platformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
end)

addcmd('unstun',{'nostun','unplatformstand','noplatformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
end)

addcmd('norotate',{'noautorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = false
end)

addcmd('unnorotate',{'autorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = true
end)

addcmd('enablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, true)
end)

addcmd('disablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, false)
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			for i,p in next, v:GetDescendants() do
				if p:IsA("Weld") then
					p:Destroy()
				end
			end
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = Players.LocalPlayer.Character
		end
	end
	wait()
	for i,v in pairs(Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('droppabletools',{},function(args, speaker)
	if speaker.Character then
		for _,obj in pairs(speaker.Character:GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
	if speaker:FindFirstChildOfClass("Backpack") then
		for _,obj in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
end)

local currentToolSize = ""
local currentGripPos = ""
addcmd('reach',{},function(args, speaker)
	execCmd('unreach')
	wait()
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,args[1])
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,60)
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			end
		end
	end
end)

addcmd("boxreach", {}, function(args, speaker)
	execCmd("unreach")
	wait()
	for i, v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			local size = tonumber(args[1]) or 60
			currentToolSize = v.Handle.Size
			currentGripPos = v.GripPos
			local a = Instance.new("SelectionBox")
			a.Name = "SelectionBoxCreated"
			a.Parent = v.Handle
			a.Adornee = v.Handle
			v.Handle.Massless = true
			v.Handle.Size = Vector3.new(size, size, size)
			v.GripPos = Vector3.new(0, 0, 0)
			speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		end
	end
end)

addcmd('unreach',{'noreach','unboxreach'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			v.Handle.SelectionBoxCreated:Destroy()
		end
	end
end)

addcmd('grippos',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = speaker:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(args[1],args[2],args[3])
			v.Parent = speaker.Character
		end
	end
end)

addcmd('usetools', {}, function(args, speaker)
	local Backpack = speaker:FindFirstChildOfClass("Backpack")
	local amount = tonumber(args[1]) or 1
	local delay_ = tonumber(args[2]) or false
	for _, v in ipairs(Backpack:GetChildren()) do
		v.Parent = speaker.Character
		task.spawn(function()
			for _ = 1, amount do
				v:Activate()
				if delay_ then
					wait(delay_)
				end
			end
			v.Parent = Backpack
		end)
	end
end)

addcmd("logs", {}, function(args, speaker)
	logsEnabled = true
	jLogsEnabled = true
	Toggle.Text = "Enabled"
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogs", {"clogs"}, function(args, speaker)
	logsEnabled = true
	join.Visible = false
	chat.Visible = true
	table.remove(shade3, table.find(shade3, selectChat))
	table.remove(shade2, table.find(shade2, selectJoin))
	table.insert(shade2, selectChat)
	table.insert(shade3, selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
	Toggle.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("joinlogs", {"jlogs"}, function(args, speaker)
	jLogsEnabled = true
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3, table.find(shade3, selectJoin))
	table.remove(shade2, table.find(shade2, selectChat))
	table.insert(shade2, selectJoin)
	table.insert(shade3, selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogswebhook", {"logswebhook"}, function(args, speaker)
	if not httprequest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing request)")
	end
	logsWebhook = args[1] or nil
	updatesaves()
end)

flinging = false
addcmd('fling',{},function(args, speaker)
	flinging = false
	for _, child in next, speaker.Character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
		end
	end
	execCmd('noclip nonotify')
	task.wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	for i, v in next, speaker.Character:GetChildren() do
		if v:IsA("BasePart") then
			v.Massless = true
			v.Velocity = Vector3.zero
		end
	end
	flinging = true
	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
		execCmd('unfling')
	end)
	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		task.wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		task.wait(.1)
	until flinging == false
end)

addcmd('unfling',{'nofling'},function(args, speaker)
	execCmd('clip nonotify')
	if flingDied then flingDied:Disconnect() end
	flinging = false
	task.wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for _, v in next, speakerChar:GetDescendants() do
		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
			v.Massless = false
			v.Velocity = Vector3.zero
		elseif v:IsA("BodyAngularVelocity") then
			v:Destroy()
		end
	end
end)

addcmd('togglefling',{},function(args, speaker)
	if flinging then
		execCmd('unfling')
	else
		execCmd('fling')
	end
end)

addcmd("flyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling")
	task.wait()
	vehicleflyspeed = tonumber(args[1]) or vehicleflyspeed
	execCmd("vehiclefly\\walkfling")
end)

addcmd("unflyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling\\breakvelocity")
end)

addcmd("toggleflyfling", {}, function(args, speaker)
	execCmd(flinging and "unflyfling" or "flyfling")
end)

walkflinging = false
addcmd("walkfling", {}, function(args, speaker)
	execCmd("unwalkfling")
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			execCmd("unwalkfling")
		end)
	end

	execCmd("noclip nonotify")
	walkflinging = true
	repeat RunService.Heartbeat:Wait()
		local character = speaker.Character
		local root = getRoot(character)
		local vel, movel = nil, 0.1

		while not (character and character.Parent and root and root.Parent) do
			RunService.Heartbeat:Wait()
			character = speaker.Character
			root = getRoot(character)
		end

		vel = root.Velocity
		root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

		RunService.RenderStepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel
		end

		RunService.Stepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel + Vector3.new(0, movel, 0)
			movel = movel * -1
		end
	until walkflinging == false
end)

addcmd("unwalkfling", {"nowalkfling"}, function(args, speaker)
	walkflinging = false
	execCmd("unnoclip nonotify")
end)

addcmd("togglewalkfling", {}, function(args, speaker)
	execCmd(walkflinging and "unwalkfling" or "walkfling")
end)

addcmd('invisfling',{},function(args, speaker)
	local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

addcmd("clickfor", {}, function(args, speaker)
	clickFor = true
end)

addcmd("unclickfor", {}, function(args, speaker)
	clickFor = false
end)

addcmd("clicktype", {}, function(args, speaker)
	clickType = args[1]:lower() or "bang"
	return "Assigned as " .. clickType
end)

addcmd("antifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
	antifling = RunService.Stepped:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= speaker and player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
		end
	end)
end)

addcmd("unantifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
end)

addcmd("toggleantifling", {}, function(args, speaker)
	execCmd(antifling and "unantifling" or "antifling")
end)

function attach(speaker,target)
	if tools(speaker) then
		local char = speaker.Character
		local tchar = target.Character
		local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
		local hrp = getRoot(speaker.Character)
		local hrp2 = getRoot(target.Character)
		hum.Name = "1"
		local newHum = hum:Clone()
		newHum.Parent = char
		newHum.Name = "Humanoid"
		wait()
		hum:Destroy()
		workspace.CurrentCamera.CameraSubject = char
		newHum.DisplayDistanceType = "None"
		local tool = speaker:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool")
		tool.Parent = char
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= char or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function kill(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5,999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd("handlekill", {"hkill"}, function(args, speaker)
	if not firetouchinterest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
	end
	if not speaker.Character then return end
	local tool = speaker.Character:FindFirstChildWhichIsA("Tool")
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then
		return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example a common Sword tool.")
	end
	local range = tonumber(args[2]) or math.huge
	if range ~= math.huge then notify("Handle Kill", ("Started!\nRadius: %s"):format(tostring(range):upper())) end

	while task.wait() and speaker.Character and tool.Parent and tool.Parent == speaker.Character do
		for _, plr in next, getPlayer(args[1], speaker) do
			plr = Players[plr]
			if plr ~= speaker and plr.Character then
				local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
				local root = hum and getRoot(plr.Character)

				if root and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and speaker:DistanceFromCharacter(root.Position) <= range then
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
				end
			end
		end
	end

	notify("Handle Kill", "Stopped!")
end)

tpwalkStack = 0
addcmd("teleportwalk", {"tpwalk"}, function(args, speaker)
    pcall(function() tpwalking:Disconnect() end)

    local character = speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local speed = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 1

    if parseBoolean(args[2]) then
        tpwalkStack = tpwalkStack + speed
    end

    tpwalking = RunService.Heartbeat:Connect(function(delta)
        if not (character and humanoid and humanoid.Parent) then
            tpwalking:Disconnect()
            return
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            character:TranslateBy(humanoid.MoveDirection * (speed + tpwalkStack) * delta * 10)
        end
    end)
end)

addcmd("unteleportwalk", {"untpwalk"}, function(args, speaker)
    tpwalkStack = 0
    tpwalking:Disconnect()
end)

function bring(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function teleport(speaker,target,target2,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd('spin',{},function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

addcmd('unspin',{},function(args, speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
end)

xrayEnabled = false
function xray()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
			v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
		end
	end
end

addcmd("xray", {}, function(args, speaker)
	xrayEnabled = true
	xray()
end)

addcmd("unxray", {"noxray"}, function(args, speaker)
	xrayEnabled = false
	xray()
end)

addcmd("togglexray", {}, function(args, speaker)
	xrayEnabled = not xrayEnabled
	xray()
end)

addcmd("loopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayLoop = RunService.RenderStepped:Connect(function()
		xrayEnabled = true
		xray()
	end)
end)

addcmd("unloopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayEnabled = false
	xray()
end)

local walltpTouch = nil
addcmd('walltp',{},function(args, speaker)
	local torso
	if r15(speaker) then
		torso = speaker.Character.UpperTorso
	else
		torso = speaker.Character.Torso
	end
	local function touchedFunc(hit)
		local Root = getRoot(speaker.Character)
		if hit:IsA("BasePart") and hit.Position.Y > Root.Position.Y - speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight then
			local hitP = getRoot(hit.Parent)
			if hitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hitP.Size.Z/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			elseif hitP == nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			end
		end
	end
	walltpTouch = torso.Touched:Connect(touchedFunc)
end)

addcmd('unwalltp',{'nowalltp'},function(args, speaker)
	if walltpTouch then
		walltpTouch:Disconnect()
	end
end)

autoclicking = false
addcmd('autoclick',{},function(args, speaker)
	if mouse1press and mouse1release then
		execCmd('unautoclick')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		autoclicking = true
		cancelAutoClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoclicking = false
					cancelAutoClick:Disconnect()
				end
			end
		end)
		notify('Auto Clicker',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until autoclicking == false
	else
		notify('Auto Clicker',"Your exploit doesn't have the ability to use the autoclick")
	end
end)

addcmd('unautoclick',{'noautoclick'},function(args, speaker)
	autoclicking = false
	if cancelAutoClick then cancelAutoClick:Disconnect() end
end)

addcmd('mousesensitivity',{'ms'},function(args, speaker)
	UserInputService.MouseDeltaSensitivity = args[1]
end)

local nameBox = nil
local nbSelection = nil
addcmd('hovername',{},function(args, speaker)
	execCmd('unhovername')
	wait()
	nameBox = Instance.new("TextLabel")
	nameBox.Name = randomString()
	nameBox.Parent = ScaledHolder
	nameBox.BackgroundTransparency = 1
	nameBox.Size = UDim2.new(0,200,0,30)
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 16
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.TextStrokeTransparency = 0
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ZIndex = 10
	nbSelection = Instance.new('SelectionBox')
	nbSelection.Name = randomString()
	nbSelection.LineThickness = 0.03
	nbSelection.Color3 = Color3.new(1, 1, 1)
	local function updateNameBox()
		local t
		local target = IYMouse.Target

		if target then
			local humanoid = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = IYMouse.X
			local y = IYMouse.Y
			local xP
			local yP
			if IYMouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = IYMouse.Move:Connect(updateNameBox)
end)

addcmd('unhovername',{'nohovername'},function(args, speaker)
	if nbUpdateFunc then
		nbUpdateFunc:Disconnect()
		nameBox:Destroy()
		nbSelection:Destroy()
	end
end)

addcmd('headsize',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('Head') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Head = Players[v].Character:FindFirstChild('Head')
			if Head:IsA("BasePart") then
				Head.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Head.Size = Vector3.new(2,1,1)
				else
					Head.Size = Size
				end
			end
		end
	end
end)

addcmd('hitbox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local transparency = args[3] and tonumber(args[3]) or 0.4
	for i,v in pairs(players) do
		if Players[v] ~= speaker and getRoot(Players[v].Character) then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Root = getRoot(Players[v].Character)
			if Root:IsA("BasePart") then
				Root.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Root.Size = Vector3.new(2,1,1)
					Root.Transparency = transparency
				else
					Root.Size = Size
					Root.Transparency = transparency
				end
			end
		end
	end
end)

addcmd("hitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = true
end)

addcmd("unhitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = false
end)

addcmd('stareat',{'stare'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if stareLoop then
			stareLoop:Disconnect()
		end
		if not getRoot(Players.LocalPlayer.Character) and getRoot(Players[v].Character) then return end
		local function stareFunc()
			if Players.LocalPlayer.Character.PrimaryPart and Players:FindFirstChild(v) and Players[v].Character ~= nil and getRoot(Players[v].Character) then
				local chrPos=Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos=getRoot(Players[v].Character).Position
				local modTPos=Vector3.new(tPos.X,chrPos.Y,tPos.Z)
				local newCF=CFrame.new(chrPos,modTPos)
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCF)
			elseif not Players:FindFirstChild(v) then
				stareLoop:Disconnect()
			end
		end

		stareLoop = RunService.RenderStepped:Connect(stareFunc)
	end
end)

addcmd('unstareat',{'unstare','nostare','nostareat'},function(args, speaker)
	if stareLoop then
		stareLoop:Disconnect()
	end
end)

RolewatchData = {Group = 0, Role = "", Leave = false}
RolewatchConnection = Players.PlayerAdded:Connect(function(player)
	if RolewatchData.Group == 0 then return end
	if player:IsInGroup(RolewatchData.Group) then
		if tostring(player:GetRoleInGroup(RolewatchData.Group)):lower() == RolewatchData.Role:lower() then
			if RolewatchData.Leave == true then
				Players.LocalPlayer:Kick("\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)

addcmd("rolewatch", {}, function(args, speaker)
	local groupId = tonumber(args[1] or 0)
	local roleName = args[2] and tostring(getstring(2, args))
	if groupId and roleName then
		RolewatchData.Group = groupId
		RolewatchData.Role = roleName
		notify("Rolewatch", "Watching Group ID \"" .. tostring(groupId) .. "\" for Role \"" .. roleName .. "\"")
	end
end)

addcmd("rolewatchstop", {}, function(args, speaker)
	RolewatchData.Group = 0
	RolewatchData.Role = ""
	RolewatchData.Leave = false
	notify("Rolewatch", "Disabled")
end)

addcmd("rolewatchleave", {"unrolewatch"}, function(args, speaker)
	RolewatchData.Leave = not RolewatchData.Leave
	notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

getStaffRole = function(player)
	local playerRole = player:GetRoleInGroup(game.CreatorId)
	local result = {Role = playerRole, Staff = false}
	if player:IsInGroup(1200769) then
		result.Role = "Roblox Employee"
		result.Staff = true
	end
	for _, role in pairs(staffRoles) do
		if string.find(string.lower(playerRole), role) then
			result.Staff = true
		end
	end
	return result
end

addcmd("staffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local found = {}
		staffwatchjoin = Players.PlayerAdded:Connect(function(player)
			local result = getStaffRole(player)
			if result.Staff then
				notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
			end
		end)
		for _, player in pairs(Players:GetPlayers()) do
			local result = getStaffRole(player)
			if result.Staff then
				table.insert(found, formatUsername(player) .. " is a " .. result.Role)
			end
		end
		if #found > 0 then
			notify("Staffwatch", table.concat(found, ",\n"))
		else
			notify("Staffwatch", "Enabled")
		end
	else
		notify("Staffwatch", "Game is not owned by a Group")
	end
end)

addcmd("unstaffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	notify("Staffwatch", "Disabled")
end)

local function playerGroups()
    local players = Players:GetPlayers()
    local graph = {}
    local seen = {}
    local groups = {}

    for _, p in ipairs(players) do
        graph[p] = {}
    end

    for i = 1, #players do
        for j = i + 1, #players do
            local p1 = players[i]
            local p2 = players[j]

            local success, result = pcall(function()
                return p1:IsFriendsWithAsync(p2.UserId)
            end)

            if success and result then
                table.insert(graph[p1], p2)
                table.insert(graph[p2], p1)
            end
        end
    end

    local function dfs(player, group)
        seen[player] = true
        table.insert(group, player)

        for _, possible in ipairs(graph[player]) do
            if not seen[possible] then
                dfs(possible, group)
            end
        end
    end

    for _, p in ipairs(players) do
        if not seen[p] then
            local group = {}
            dfs(p, group)
            table.insert(groups, group)
        end
    end

    return groups
end

addcmd("findfriendgroups", {}, function(args, speaker)
    notify("Checking Players", "This might take a while (slow function)")

    local groups = playerGroups()
    local playerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)

    local result = ""
    local index = 1
    local found = 0

    for _, group in ipairs(groups) do
        if #group == 1 then continue end
        local names = {}
        for _, player in ipairs(group) do
            table.insert(names, playerList and player.DisplayName or player.Name)
        end
        result = result .. index .. ". " .. table.concat(names, ", ") .. "\n"
        index = index + 1
        found = found + 1
    end

    createPopup("Friend Groups", found == 0 and "None" or result)
end)

addcmd('removeterrain',{'rterrain','noterrain'},function(args, speaker)
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

addcmd('clearnilinstances',{'nonilinstances','cni'},function(args, speaker)
	if getnilinstances then
		for i,v in pairs(getnilinstances()) do
			v:Destroy()
		end
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing getnilinstances)')
	end
end)

addcmd('destroyheight',{'dh'},function(args, speaker)
	local dh = args[1] or -500
	if isNumber(dh) then
		workspace.FallenPartsDestroyHeight = dh
	end
end)

OrgDestroyHeight = workspace.FallenPartsDestroyHeight
addcmd("antivoid", {}, function(args, speaker)
	execCmd("unantivoid nonotify")
	task.wait()
	antivoidloop = RunService.Stepped:Connect(function()
		local root = getRoot(speaker.Character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
		end
	end)
	if args[1] ~= "nonotify" then notify("antivoid", "Enabled") end
end)

addcmd("unantivoid", {"noantivoid"}, function(args, speaker)
	pcall(function() antivoidloop:Disconnect() end)
	antivoidloop = nil
	if args[1] ~= "nonotify" then notify("antivoid", "Disabled") end
end)

antivoidWasEnabled = false
addcmd("fakeout", {}, function(args, speaker)
	local root = getRoot(speaker.Character)
	local oldpos = root.CFrame
	if antivoidloop then
		execCmd("unantivoid nonotify")
		antivoidWasEnabled = true
	end
	workspace.FallenPartsDestroyHeight = 0/1/0
	root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
	task.wait(1)
	root.CFrame = oldpos
	workspace.FallenPartsDestroyHeight = OrgDestroyHeight
	if antivoidWasEnabled then
		execCmd("antivoid nonotify")
		antivoidWasEnabled = false
	end
end)

addcmd("trip", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local root = speaker.Character and getRoot(speaker.Character)
	if humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

addcmd("removeads", {"adblock"}, function(args, speaker)
	while wait() do
		pcall(function()
			for i, v in pairs(workspace:GetDescendants()) do
				if v:IsA("PackageLink") then
					if v.Parent:FindFirstChild("ADpart") then
						v.Parent:Destroy()
					end
					if v.Parent:FindFirstChild("AdGuiAdornee") then
						v.Parent.Parent:Destroy()
					end
				end
			end
		end)
	end
end)

addcmd("scare", {"spook"}, function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local oldpos = nil

	for _, v in pairs(players) do
		local root = speaker.Character and getRoot(speaker.Character)
		local target = Players[v]
		local targetRoot = target and target.Character and getRoot(target.Character)

		if root and targetRoot and target ~= speaker then
			oldpos = root.CFrame
			root.CFrame = targetRoot.CFrame + targetRoot.CFrame.lookVector * 2
			root.CFrame = CFrame.new(root.Position, targetRoot.Position)
			task.wait(0.5)
			root.CFrame = oldpos
		end
	end
end)

addcmd("alignmentkeys", {}, function(args, speaker)
	alignmentKeys = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma then workspace.CurrentCamera:PanUnits(-1) end
		if input.KeyCode == Enum.KeyCode.Period then workspace.CurrentCamera:PanUnits(1) end
	end)
	alignmentKeysEmotes = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

addcmd("unalignmentkeys", {"noalignmentkeys"}, function(args, speaker)
	if type(alignmentKeysEmotes) == "boolean" then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, alignmentKeysEmotes)
	end
	alignmentKeys:Disconnect()
end)

addcmd("ctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftControl"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftControl"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("unctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftShift"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftShift"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("listento", {}, function(args, speaker)
	execCmd("unlistento")
	if not args[1] then return end

	local player = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = player and player.Character and getRoot(player.Character)

	if root then
		SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
		listentoChar = player.CharacterAdded:Connect(function()
			repeat task.wait() until Players[player.Name].Character ~= nil and getRoot(Players[player.Name].Character)
			SoundService:SetListener(Enum.ListenerType.ObjectPosition, getRoot(Players[player.Name].Character))
		end)
	end
end)

addcmd("unlistento", {}, function(args, speaker)
	SoundService:SetListener(Enum.ListenerType.Camera)
	listentoChar:Disconnect()
end)

addcmd("jerk", {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local backpack = speaker:FindFirstChildWhichIsA("Backpack")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk Off"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	while task.wait() do
		if not jorkin then continue end

		local isR15 = r15(speaker)
		if not track then
			local anim = Instance.new("Animation")
			anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(isR15 and 0.7 or 0.65)
		track.TimePosition = 0.6
		task.wait(0.1)
		while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

addcmd("guiscale", {}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		local scale = tonumber(args[1])
		if scale % 1 == 0 then scale = scale / 100 end
		-- me when i divide and it explodes
		if scale == 0.01 then scale = 1 end
		if scale == 0.02 then scale = 2 end

		if scale >= 0.4 and scale <= 2 then
			guiScale = scale
		end
	else
		guiScale = defaultGuiScale
	end

	Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale)
	updatesaves()
end)

addcmd("muteallvoices", {"muteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(true)
end)

addcmd("unmuteallvoices", {"unmuteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(false)
end)

addcmd("mutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, true)
	end
end)

addcmd("unmutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, false)
	end
end)

addcmd("phonebook", {"call"}, function(args, speaker)
	local success, canInvite = pcall(function()
		return SocialService:CanSendCallInviteAsync(speaker)
	end)
	if success and canInvite then
		SocialService:PromptPhoneBook(speaker, "")
	else
		notify("Phonebook", "It seems you're not able to call anyone. Sorry!")
	end
end)

local freezingua = nil
frozenParts = {}
addcmd('freezeunanchored',{'freezeua'},function(args, speaker)
	local badnames = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"LeftUpperArm",
		"RightLowerArm",
		"LeftLowerArm",
		"RightHand",
		"LeftHand",
		"RightUpperLeg",
		"LeftUpperLeg",
		"RightLowerLeg",
		"LeftLowerLeg",
		"RightFoot",
		"LeftFoot",
		"Torso",
		"Right Arm",
		"Left Arm",
		"Right Leg",
		"Left Leg",
		"HumanoidRootPart"
	}
	local function FREEZENOOB(v)
		if v:IsA("BasePart" or "UnionOperation") and v.Anchored == false then
			local BADD = false
			for i = 1,#badnames do
				if v.Name == badnames[i] then
					BADD = true
				end
			end
			if speaker.Character and v:IsDescendantOf(speaker.Character) then
				BADD = true
			end
			if BADD == false then
				for i,c in pairs(v:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local bodypos = Instance.new("BodyPosition")
				bodypos.Parent = v
				bodypos.Position = v.Position
				bodypos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				local bodygyro = Instance.new("BodyGyro")
				bodygyro.Parent = v
				bodygyro.CFrame = v.CFrame
				bodygyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
				if not table.find(frozenParts,v) then
					table.insert(frozenParts,v)
				end
			end
		end
	end
	for i,v in pairs(workspace:GetDescendants()) do
		FREEZENOOB(v)
	end
	freezingua = workspace.DescendantAdded:Connect(FREEZENOOB)
end)

addcmd('thawunanchored',{'thawua','unfreezeunanchored','unfreezeua'},function(args, speaker)
	if freezingua then
		freezingua:Disconnect()
	end
	for i,v in pairs(frozenParts) do
		for i,c in pairs(v:GetChildren()) do
			if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
				c:Destroy()
			end
		end
	end
	frozenParts = {}
end)

addcmd('tpunanchored',{'tpua'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local Forces = {}
		for _,part in pairs(workspace:GetDescendants()) do
			if Players[v].Character:FindFirstChild('Head') and part:IsA("BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part:IsDescendantOf(speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
				for i,c in pairs(part:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local ForceInstance = Instance.new("BodyPosition")
				ForceInstance.Parent = part
				ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				table.insert(Forces, ForceInstance)
				if not table.find(frozenParts,part) then
					table.insert(frozenParts,part)
				end
			end
		end
		for i,c in pairs(Forces) do
			c.Position = Players[v].Character.Head.Position
		end
	end
end)

keycodeMap = {
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["a"] = 0x41,
	["b"] = 0x42,
	["c"] = 0x43,
	["d"] = 0x44,
	["e"] = 0x45,
	["f"] = 0x46,
	["g"] = 0x47,
	["h"] = 0x48,
	["i"] = 0x49,
	["j"] = 0x4A,
	["k"] = 0x4B,
	["l"] = 0x4C,
	["m"] = 0x4D,
	["n"] = 0x4E,
	["o"] = 0x4F,
	["p"] = 0x50,
	["q"] = 0x51,
	["r"] = 0x52,
	["s"] = 0x53,
	["t"] = 0x54,
	["u"] = 0x55,
	["v"] = 0x56,
	["w"] = 0x57,
	["x"] = 0x58,
	["y"] = 0x59,
	["z"] = 0x5A,
	["enter"] = 0x0D,
	["shift"] = 0x10,
	["ctrl"] = 0x11,
	["alt"] = 0x12,
	["pause"] = 0x13,
	["capslock"] = 0x14,
	["spacebar"] = 0x20,
	["space"] = 0x20,
	["pageup"] = 0x21,
	["pagedown"] = 0x22,
	["end"] = 0x23,
	["home"] = 0x24,
	["left"] = 0x25,
	["up"] = 0x26,
	["right"] = 0x27,
	["down"] = 0x28,
	["insert"] = 0x2D,
	["delete"] = 0x2E,
	["f1"] = 0x70,
	["f2"] = 0x71,
	["f3"] = 0x72,
	["f4"] = 0x73,
	["f5"] = 0x74,
	["f6"] = 0x75,
	["f7"] = 0x76,
	["f8"] = 0x77,
	["f9"] = 0x78,
	["f10"] = 0x79,
	["f11"] = 0x7A,
	["f12"] = 0x7B,
}
autoKeyPressing = false
cancelAutoKeyPress = nil

addcmd('autokeypress',{'keypress'},function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = keycodeMap[args[1]:lower()]
		if not code then notify('Auto Key Press',"Invalid key") return end
		execCmd('unautokeypress')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		autoKeyPressing = true
		cancelAutoKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoKeyPressing = false
					cancelAutoKeyPress:Disconnect()
				end
			end
		end)
		notify("Auto Key Press", "Press [backspace] and [=] at the same time to stop (or type 'unautokeypress')")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until autoKeyPressing == false
		if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() keyrelease(code) end
	else
		notify("Auto Key Press", "Your exploit does not support this command (missing keypress or keyrelease)")
	end
end)

addcmd('unautokeypress',{'noautokeypress','unkeypress','nokeypress'},function(args, speaker)
	autoKeyPressing = false
	if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() end
end)

addcmd('addplugin',{'plugin'},function(args, speaker)
	addPlugin(getstring(1, args))
end)

addcmd('removeplugin',{'deleteplugin'},function(args, speaker)
	deletePlugin(getstring(1, args))
end)

addcmd('reloadplugin',{},function(args, speaker)
	local pluginName = getstring(1, args)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

addcmd("addallplugins", {"loadallplugins"}, function(args, speaker)
	if not listfiles or not isfolder then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing listfiles/isfolder)")
		return
	end

	for _, filePath in ipairs(listfiles("")) do
		local fileName = filePath:match("([^/\\]+%.iy)$")

		if fileName and
			fileName:lower() ~= "iy_fe.iy" and
			not isfolder(fileName) and
			not table.find(PluginsTable, fileName)
		then
			addPlugin(fileName)
		end
	end
end)

addcmd('removecmd',{'deletecmd'},function(args, speaker)
	removecmd(args[1])
end)

addcmd("debug", {}, function(args, speaker)
    _G.IY_DEBUG = parseBoolean(args[1], true)
    return _G.IY_DEBUG and "Enabled" or "Disabled"
end)

if IsOnMobile then
	local QuickCapture = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	QuickCapture.Name = randomString()
	QuickCapture.Parent = PARENT
	QuickCapture.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	QuickCapture.BackgroundTransparency = 0.14
	QuickCapture.Position = UDim2.new(0.489, 0, 0, 0)
	QuickCapture.Size = UDim2.new(0, 32, 0, 33)
	QuickCapture.Font = Enum.Font.SourceSansBold
	QuickCapture.Text = "IY"
	QuickCapture.TextColor3 = Color3.fromRGB(255, 255, 255)
	QuickCapture.TextSize = 20
	QuickCapture.TextWrapped = true
	QuickCapture.ZIndex = 10
	QuickCapture.Draggable = true
	UICorner.Name = randomString()
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = QuickCapture
	QuickCapture.MouseButton1Click:Connect(function()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end)
	table.insert(shade1, QuickCapture)
	table.insert(text1, QuickCapture)
end

pcall(function() Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale) end)
Scale.Parent = ScaledHolder
ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
Scale:GetPropertyChangedSignal("Scale"):Connect(function()
	ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
	for _, v in ScaledHolder:GetDescendants() do
		if v:IsA("GuiObject") and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end)

updateColors(currentShade1,shade1)
updateColors(currentShade2,shade2)
updateColors(currentShade3,shade3)
updateColors(currentText1,text1)
updateColors(currentText2,text2)
updateColors(currentScroll,scroll)

if PluginsTable ~= nil or PluginsTable ~= {} then
	FindPlugins(PluginsTable)
end

-- Events
eventEditor.RegisterEvent("OnExecute")
eventEditor.RegisterEvent("OnSpawn",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDied",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDamage",{
	{Type="Player",Name="Player Filter ($1)"},
	{Type="Number",Name="Below Health ($2)"}
})
eventEditor.RegisterEvent("OnKilled",{
	{Type="Player",Name="Victim Player ($1)"},
	{Type="Player",Name="Killer Player ($2)",Default = 1}
})
eventEditor.RegisterEvent("OnJoin",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnLeave",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnChatted",{
	{Type="Player",Name="Player Filter ($1)",Default = 1},
	{Type="String",Name="Message Filter ($2)"}
})

function hookCharEvents(plr, instant)
	task.spawn(function()
		local char = plr.Character
		if not char then return end

		local humanoid = char:WaitForChild("Humanoid", 10)
		if not humanoid or not humanoid:IsA("Humanoid") then return end

		local oldHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			local change = math.abs(oldHealth - health)
			if oldHealth > health then
				eventEditor.FireEvent("OnDamage", plr.Name, tonumber(health))
			end
			oldHealth = health
		end)

		humanoid.Died:Connect(function()
			eventEditor.FireEvent("OnDied", plr.Name)

			local killedBy = humanoid:FindFirstChild("creator")
			if killedBy and killedBy:IsA("ObjectValue") and killedBy.Value and killedBy.Value.Parent then
				eventEditor.FireEvent("OnKilled", plr.Name, killedBy.Name)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if isLegacyChat then plr.Chatted:Connect(function(msg) eventEditor.FireEvent("OnChatted",tostring(plr),msg) end) end
	plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
	JoinLog(plr)
	if isLegacyChat then ChatLog(plr) end
	if ESPenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		ESP(plr)
	end
	if CHMSenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		CHMS(plr)
	end
end)

if not isLegacyChat then
	TextChatService.MessageReceived:Connect(function(textChatMessage)
		if textChatMessage.TextSource and textChatMessage.Status ~= Enum.TextChatMessageStatus.InvalidTextChannelPermissions then
			local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
			if not player then return end

            local message = textChatMessage.Text
            pcall(function() if textChatMessage.WasRewritten == true then message = "(rephrased) " .. textChatMessage.RewrittenText end end)

			if logsEnabled == true then
				CreateLabel(player.Name, message)
			end
			if player.UserId == Players.LocalPlayer.UserId then
				do_exec(message, Players.LocalPlayer)
			end
			eventEditor.FireEvent("OnChatted", player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

for _, plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn", tostring(plr)) hookCharEvents(plr) end)
		hookCharEvents(plr)
	end)
end

if spawnCmds and #spawnCmds > 0 then
	for i,v in pairs(spawnCmds) do
		eventEditor.AddCmd("OnSpawn",{v.COMMAND or "",{0},v.DELAY or 0})
	end
	updatesaves()
end

if loadedEventData then eventEditor.LoadData(loadedEventData) end
eventEditor.Refresh()

eventEditor.FireEvent("OnExecute")

if aliases and #aliases > 0 then
	local cmdMap = {}
	for i,v in pairs(cmds) do
		cmdMap[v.NAME:lower()] = v
		for _,alias in pairs(v.ALIAS) do
			cmdMap[alias:lower()] = v
		end
	end
	for i = 1, #aliases do
		local cmd = string.lower(aliases[i].CMD)
		local alias = string.lower(aliases[i].ALIAS)
		if cmdMap[cmd] then
			customAlias[alias] = cmdMap[cmd]
		end
	end
	refreshaliases()
end

IYMouse.Move:Connect(checkTT)

CaptureService.CaptureBegan:Connect(function()
	PARENT.Enabled = false
end)

CaptureService.CaptureEnded:Connect(function()
	task.delay(0.1, function()
		PARENT.Enabled = true
	end)
end)

task.spawn(function()
	local success, latestVersionInfo = pcall(function() 
		local versionJson = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/version")
		return HttpService:JSONDecode(versionJson)
	end)

	if success then
		if currentVersion ~= latestVersionInfo.Version then
			notify("Outdated", "Get the new version at infyiff.github.io")
		end

		if latestVersionInfo.Announcement and latestVersionInfo.Announcement ~= "" then
			local AnnGUI = Instance.new("Frame")
			local background = Instance.new("Frame")
			local TextBox = Instance.new("TextLabel")
			local shadow = Instance.new("Frame")
			local PopupText = Instance.new("TextLabel")
			local Exit = Instance.new("TextButton")
			local ExitImage = Instance.new("ImageLabel")

			AnnGUI.Name = randomString()
			AnnGUI.Parent = ScaledHolder
			AnnGUI.Active = true
			AnnGUI.BackgroundTransparency = 1
			AnnGUI.Position = UDim2.new(0.5, -180, 0, -500)
			AnnGUI.Size = UDim2.new(0, 360, 0, 20)
			AnnGUI.ZIndex = 10

			background.Name = "background"
			background.Parent = AnnGUI
			background.Active = true
			background.BackgroundColor3 = currentShade1
			background.BorderSizePixel = 0
			background.Position = UDim2.new(0, 0, 0, 20)
			background.Size = UDim2.new(0, 360, 0, 150)
			background.ZIndex = 10

			TextBox.Parent = background
			TextBox.BackgroundTransparency = 1
			TextBox.Position = UDim2.new(0, 5, 0, 5)
			TextBox.Size = UDim2.new(0, 350, 0, 140)
			TextBox.Font = Enum.Font.SourceSans
			TextBox.TextSize = 18
			TextBox.TextWrapped = true
			TextBox.Text = latestVersionInfo.Announcement
			TextBox.TextColor3 = currentText1
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.TextYAlignment = Enum.TextYAlignment.Top
			TextBox.ZIndex = 10

			shadow.Name = "shadow"
			shadow.Parent = AnnGUI
			shadow.BackgroundColor3 = currentShade2
			shadow.BorderSizePixel = 0
			shadow.Size = UDim2.new(0, 360, 0, 20)
			shadow.ZIndex = 10

			PopupText.Name = "PopupText"
			PopupText.Parent = shadow
			PopupText.BackgroundTransparency = 1
			PopupText.Size = UDim2.new(1, 0, 0.95, 0)
			PopupText.ZIndex = 10
			PopupText.Font = Enum.Font.SourceSans
			PopupText.TextSize = 14
			PopupText.Text = "Server Announcement"
			PopupText.TextColor3 = currentText1
			PopupText.TextWrapped = true

			Exit.Name = "Exit"
			Exit.Parent = shadow
			Exit.BackgroundTransparency = 1
			Exit.Position = UDim2.new(1, -20, 0, 0)
			Exit.Size = UDim2.new(0, 20, 0, 20)
			Exit.Text = ""
			Exit.ZIndex = 10

			ExitImage.Parent = Exit
			ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
			ExitImage.BackgroundTransparency = 1
			ExitImage.Position = UDim2.new(0, 5, 0, 5)
			ExitImage.Size = UDim2.new(0, 10, 0, 10)
			ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
			ExitImage.ZIndex = 10

			task.wait(1)
			AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

			Exit.MouseButton1Click:Connect(function()
				AnnGUI:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
				task.wait(0.6)
				AnnGUI:Destroy()
			end)
		end
	end
end)

task.spawn(function()
    task.wait()
    pcall(function()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 0), "Out", "Quart", 0.2)
        Logo:TweenSizeAndPosition(UDim2.new(0, 175, 0, 175), UDim2.new(0, 37, 0, 45), "Out", "Quart", 0.3)
        task.wait(1)
        local OutInfo = TweenInfo.new(1.6809, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(Logo, OutInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(IntroBackground, OutInfo, {BackgroundTransparency = 1}):Play()
        Credits:TweenPosition(UDim2.new(0, 0, 0.9, 30), "Out", "Quart", 0.2)
        task.wait(0.2)
    end)
    Logo:Destroy()
    Credits:Destroy()
    IntroBackground:Destroy()
    minimizeHolder()
end)

--[[
    IY NOVA ENHANCEMENTS | additive extension to Infinite Yield FE 6.4.2
    Keeps original command registrations, settings, themes and plugins intact.
    New features: command palette, favorites, persistent recents, usage statistics,
    in-client performance monitor, searchable help and error diagnostics.
    No externally fetched code or third-party dependencies are added here.
]]
do
    local localPlayer = Players.LocalPlayer
    local sessionStart = os.clock()
    -- Capture provenance BEFORE registering the first NOVA command. This avoids
    -- guesses based on names and keeps pre-existing IY / plugin commands intact.
    local originalCommandNames = {}
    local originalCount = 0
    for _, command in ipairs(cmds) do
        if type(command.NAME) == "string" then
            originalCommandNames[command.NAME:lower()] = true
            originalCount = originalCount + 1
        end
    end
    local theme = {
        bg = Color3.fromRGB(18, 22, 32),
        panel = Color3.fromRGB(28, 34, 47),
        hover = Color3.fromRGB(43, 53, 72),
        input = Color3.fromRGB(35, 42, 57),
        text = Color3.fromRGB(238, 243, 252),
        muted = Color3.fromRGB(151, 166, 189),
        accent = Color3.fromRGB(101, 157, 255),
        success = Color3.fromRGB(82, 229, 174),
        indigo = Color3.fromRGB(135, 110, 255),
        stroke = Color3.fromRGB(68, 82, 117),
    }
    local storePath = "IY_NOVA.iy"
    local store = {favorites = {}, recent = {}, counts = {}, appearance = {theme="blue", scale=1, quickbar=false}}
    local sessionRuns = 0
    local savePending = false
    local paletteOpen = false
    local mode = "All"
    local group = "All"
    local selectedCommand = nil
    local groupCache = {}
    local groupCacheCount = -1
    local lastSearch = ""
    local refreshList
    local refreshQuickbar
    local pageLimit = 48
    local paletteSelectionIndex = 1
    local activatePalette
    local setPaletteVisible

    -- A bad or outdated extension save should never stop Infinite Yield booting.
    if type(waxreadfile) == "function" then
        local ok, contents = pcall(waxreadfile, storePath)
        if ok and type(contents) == "string" then
            local decoded, loaded = pcall(function() return HttpService:JSONDecode(contents) end)
            if decoded and type(loaded) == "table" then
                if type(loaded.appearance) == "table" then
                    local ap = loaded.appearance
                    if type(ap.theme) == "string" then store.appearance.theme = ap.theme end
                    if type(ap.quickbar) == "boolean" then store.appearance.quickbar = ap.quickbar end
                    if type(ap.scale) == "number" and ap.scale == ap.scale then
                        store.appearance.scale = math.clamp(ap.scale, 0.8, 1.25)
                    end
                end
                if type(loaded.favorites) == "table" then
                    for _, value in ipairs(loaded.favorites) do
                        if type(value) == "string" and #value <= 72 and #store.favorites < 100 then
                            table.insert(store.favorites, value:lower())
                        end
                    end
                end
                if type(loaded.recent) == "table" then
                    for _, value in ipairs(loaded.recent) do
                        if type(value) == "string" and #value <= 256 and #store.recent < 40 then
                            table.insert(store.recent, value)
                        end
                    end
                end
                if type(loaded.counts) == "table" then
                    for name, count in pairs(loaded.counts) do
                        if type(name) == "string" and type(count) == "number" and count >= 0 and count < math.huge then
                            store.counts[name] = math.floor(count)
                        end
                    end
                end
            end
        end
    end

    -- Reuse IY's built-in Up/Down history navigation after a reconnect.
    for index = 1, math.min(#store.recent, 30) do
        cmdHistory[index] = store.recent[index]
    end

    local function saveSoon()
        if savePending or type(waxwritefile) ~= "function" then return end
        savePending = true
        task.delay(1.25, function()
            savePending = false
            local ok, data = pcall(function()
                return HttpService:JSONEncode(store)
            end)
            if ok then
                local wrote, err = pcall(waxwritefile, storePath, data)
                if not wrote and _G.IY_DEBUG then warn("NOVA settings save failed:", err) end
            end
        end)
    end

    local function normalizeName(raw)
        if type(raw) ~= "string" then return nil end
        local first = raw:match("^%s*([^%s]+)")
        if not first then return nil end
        local command = findCmd(first)
        return command and command.NAME:lower() or nil
    end

    local function favoriteIndex(name)
        for index, value in ipairs(store.favorites) do
            if value == name then return index end
        end
        return nil
    end

    local function toggleFavorite(name)
        if not name or not findCmd(name) then return false end
        local index = favoriteIndex(name)
        if index then
            table.remove(store.favorites, index)
        elseif #store.favorites < 100 then
            table.insert(store.favorites, name)
        else
            notify("Favorites", "The 100-command favorites limit has been reached.")
            return false
        end
        saveSoon()
        if refreshList then refreshList() end
        if refreshQuickbar then refreshQuickbar() end
        return not index
    end

    -- A light wrapper logs command dispatches without modifying IY's existing parser,
    -- plugins, aliases, commands, or keybind callbacks.
    local originalExecute = execCmd
    execCmd = function(commandString, speaker, shouldStore)
        local clean = tostring(commandString or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if clean == "" then return end
        if not speaker or speaker == localPlayer then
            sessionRuns = sessionRuns + 1
            local key = (clean:match("^([^%s]+)") or ""):lower()
            local repeatPrefix = key:match("^%d+%^") or key:match("^inf%^")
            if repeatPrefix then
                local withoutPrefix = clean:gsub("^%d+%^[%d%.]*%^?", ""):gsub("^inf%^[%d%.]*%^?", "")
                key = (withoutPrefix:match("^([^%s]+)") or key):lower()
            end
            local command = findCmd(key)
            if command then key = command.NAME:lower() end
            store.counts[key] = (store.counts[key] or 0) + 1
            if store.recent[1] ~= clean then
                table.insert(store.recent, 1, clean:sub(1, 256))
                while #store.recent > 40 do table.remove(store.recent) end
            end
            saveSoon()
        end
        return originalExecute(clean, speaker, shouldStore)
    end

    local function node(kind, parent, props)
        local item = Instance.new(kind)
        for key, value in pairs(props or {}) do item[key] = value end
        item.Parent = parent
        return item
    end

    local function round(item, size)
        node("UICorner", item, {CornerRadius = UDim.new(0, size or 9)})
    end

    local helpMap = {}
    for _, record in ipairs(CMDs) do
        local key = type(record.NAME) == "string" and record.NAME:match("^%s*([%w_]+)")
        if key and type(record.DESC) == "string" and record.DESC ~= "" then
            helpMap[key:lower()] = record.DESC
        end
    end
    local function commandHelp(name)
        local value = helpMap[name:lower()]
        if value then return value end
        for _, gui in ipairs(CMDsF:GetChildren()) do
            if gui:IsA("TextButton") and gui:GetAttribute("Desc") then
                local title = tostring(gui:GetAttribute("Title") or ""):lower()
                local lowered = name:lower()
                if title == lowered or title:sub(1, #lowered + 1) == lowered .. " " or
                    title:sub(1, #lowered + 1) == lowered .. "[" then
                    helpMap[lowered] = tostring(gui:GetAttribute("Desc"))
                    return helpMap[lowered]
                end
            end
        end
        return "Added command (see command documentation for arguments)."
    end

    local function updateCommandGroups()
        if groupCacheCount == #cmds then return end
        groupCacheCount = #cmds
        groupCache = {}
        for _, label in ipairs(CMDsF:GetChildren()) do
            if label:IsA("TextButton") and label.Name:sub(1, 11) == "PLUGIN_NOVA" then
                local key = tostring(label.Text):match("^([%w_]+)")
                if key then
                    local pack = "Utilities"
                    if label.Name:find("GAMEPLAY", 1, true) then pack = "Gameplay"
                    elseif label.Name:find("PROGRESSION", 1, true) then pack = "Progression"
                    elseif label.Name:find("ADVANCED", 1, true) then pack = "Advanced"
                    elseif label.Name:find("STUDIO", 1, true) then pack = "Studio" end
                    groupCache[key:lower()] = pack
                end
            end
        end
    end
    local function commandGroup(name)
        name = tostring(name or ""):lower()
        if originalCommandNames[name] then return "Infinite Yield" end
        updateCommandGroups()
        return groupCache[name] or "Utilities"
    end
    local function groupMatches(name)
        local original = originalCommandNames[tostring(name):lower()] == true
        if mode == "Infinite Yield" and not original then return false end
        if mode == "NOVA Additions" and original then return false end
        if mode == "NOVA Additions" and group ~= "All" and commandGroup(name) ~= group then return false end
        return true
    end
    local function countGroups()
        local old, extra = 0, 0
        for _, cmd in ipairs(cmds) do
            if originalCommandNames[tostring(cmd.NAME):lower()] then old = old + 1 else extra = extra + 1 end
        end
        return old, extra
    end

    -- The palette is part of the existing GUI tree, so no second ScreenGui is
    -- needed, and the CaptureService visibility behavior stays consistent.
    local overlay = node("Frame", ScaledHolder, {
        Name = "NOVA_CommandPaletteOverlay", Active = true,
        BackgroundColor3 = Color3.fromRGB(2, 5, 14), BackgroundTransparency = 0.16,
        Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 60
    })
    local palette = node("Frame", overlay, {
        Name = "Palette", BackgroundColor3 = theme.bg,
        BorderSizePixel = 0, ZIndex = 61,
    })
    round(palette, 18)
    node("UIStroke", palette, {Color = theme.stroke, Thickness = 1.5, Transparency = 0.12})
    node("UIGradient", palette, {Rotation = 120, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 22, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 26))})})
    local topAccent = node("Frame", palette, {Name = "NOVA_AccentBar", BorderSizePixel = 0,
        BackgroundColor3 = theme.accent, Size = UDim2.new(1, -40, 0, 3),
        Position = UDim2.fromOffset(20, 0), ZIndex = 62})
    round(topAccent, 3)
    node("UIGradient", topAccent, {Color = ColorSequence.new(theme.accent, theme.indigo)})

    local heading = node("TextLabel", palette, {
        Name = "Header", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 11), Size = UDim2.new(1, -175, 0, 30),
        Font = Enum.Font.GothamBold, TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.text,
        Text = "NOVA   /   COMMAND CENTER", ZIndex = 62
    })
    local countText = node("TextLabel", palette, {Name = "CommandCounts",
        Position = UDim2.new(1, -177, 0, 17), Size = UDim2.fromOffset(129, 20),
        Text = "", BackgroundTransparency = 1, TextColor3 = theme.muted,
        TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 63})
    local close = node("TextButton", palette, {
        Position = UDim2.new(1, -42, 0, 13), Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = theme.panel, Text = "×", TextSize = 25,
        Font = Enum.Font.Gotham, TextColor3 = theme.text, ZIndex = 63,
        AutoButtonColor = true
    })
    round(close, 7)
    local search = node("TextBox", palette, {
        Name = "Search", Position = UDim2.new(0, 20, 0, 56),
        Size = UDim2.new(1, -40, 0, 42), BackgroundColor3 = theme.input,
        BorderSizePixel = 0, Font = Enum.Font.Gotham,
        TextSize = 14, TextColor3 = theme.text, PlaceholderColor3 = theme.muted,
        PlaceholderText = "⌕   Search by command, description, or alias...",
        Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 63
    })
    round(search, 10)
    node("UIStroke", search, {Color = theme.stroke, Transparency = 0.55, Thickness = 1})
    node("UIPadding", search, {PaddingLeft = UDim.new(0, 13), PaddingRight = UDim.new(0, 9)})

    -- Horizontally scrollable tabs never squash the names on smaller viewports.
    local tabHolder = node("ScrollingFrame", palette, {
        Name = "Sources", BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 108), Size = UDim2.new(1, -40, 0, 34),
        ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 0,
        CanvasSize = UDim2.fromOffset(641, 0), ZIndex = 62
    })
    local buttons = {}
    local tabItems = {
        {"All", 76}, {"Infinite Yield", 141}, {"NOVA Additions", 143},
        {"Favorites", 111}, {"Recent", 94}
    }
    local tabX = 0
    for _, item in ipairs(tabItems) do
        local tab, width = item[1], item[2]
        local button = node("TextButton", tabHolder, {
            Name = tab, Position = UDim2.fromOffset(tabX, 1),
            Size = UDim2.fromOffset(width, 31), BackgroundColor3 = theme.panel,
            BorderSizePixel = 0, Text = tab, TextColor3 = theme.muted,
            Font = Enum.Font.GothamSemibold, TextSize = 12,
            AutoButtonColor = true, ZIndex = 63
        })
        round(button, 8)
        buttons[tab] = button
        tabX = tabX + width + 8
    end
    tabHolder.CanvasSize = UDim2.fromOffset(tabX, 0)

    local groupBar = node("ScrollingFrame", palette, {
        Name = "AdditionFilters", BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 148), Size = UDim2.new(1, -40, 0, 30),
        ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 0,
        CanvasSize = UDim2.fromOffset(545, 0), ZIndex = 63,
        Visible = false
    })
    local groupButtons = {}
    local groupX = 0
    for _, item in ipairs({{"All", 64}, {"Gameplay", 91}, {"Progression", 103},
        {"Advanced", 91}, {"Utilities", 82}, {"Studio", 69}}) do
        local category, width = item[1], item[2]
        local button = node("TextButton", groupBar, {
            Name = category, Position = UDim2.fromOffset(groupX, 0),
            Size = UDim2.fromOffset(width, 27),
            BackgroundColor3 = theme.panel, BorderSizePixel = 0,
            Text = category, TextColor3 = theme.muted,
            Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 64
        })
        round(button, 8)
        groupButtons[category] = button
        groupX = groupX + width + 7
    end
    groupBar.CanvasSize = UDim2.fromOffset(groupX, 0)

    local listFrame = node("ScrollingFrame", palette, {
        Name = "Results", Position = UDim2.new(0, 20, 0, 184),
        Size = UDim2.new(1, -40, 1, -299), BackgroundColor3 = theme.panel,
        BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.accent, CanvasSize = UDim2.fromOffset(0, 0),
        ZIndex = 62
    })
    round(listFrame, 11)
    node("UIStroke", listFrame, {Color = theme.stroke, Thickness = 1, Transparency = 0.72})
    local layout = node("UIListLayout", listFrame, {
        Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder
    })
    node("UIPadding", listFrame, {
        PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 9), PaddingBottom = UDim.new(0, 5)
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
    end)

    local commandInput = node("TextBox", palette, {
        Name = "CommandInput", Position = UDim2.new(0, 20, 1, -101),
        Size = UDim2.new(1, -40, 0, 37), BackgroundColor3 = theme.input,
        BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = theme.text, PlaceholderColor3 = theme.muted,
        PlaceholderText = "Select a command, then edit its arguments", Text = "",
        ClearTextOnFocus = false, ZIndex = 63
    })
    round(commandInput, 9)
    node("UIStroke", commandInput, {Color = theme.stroke, Thickness = 1, Transparency = 0.58})
    node("UIPadding", commandInput, {PaddingLeft = UDim.new(0, 10)})
    local runButton = node("TextButton", palette, {
        Name = "Run", Position = UDim2.new(0, 20, 1, -52),
        Size = UDim2.new(0.5, -26, 0, 36), BackgroundColor3 = theme.accent,
        TextColor3 = theme.bg, Text = "Run command", Font = Enum.Font.GothamBold,
        TextSize = 13, ZIndex = 63
    })
    round(runButton, 7)
    local editButton = node("TextButton", palette, {
        Name = "Edit", Position = UDim2.new(0.5, 6, 1, -52),
        Size = UDim2.new(0.5, -26, 0, 36), BackgroundColor3 = theme.hover,
        TextColor3 = theme.text, Text = "Open in command bar",
        Font = Enum.Font.GothamSemibold, TextSize = 12, ZIndex = 63
    })
    round(editButton, 9)
    node("UIGradient", runButton, {Color = ColorSequence.new(theme.accent, theme.indigo)})
    node("UIStroke", editButton, {Color = theme.stroke, Transparency = 0.5})
    local footerHint = node("TextLabel", palette, {
        Name = "FooterHint", Position = UDim2.new(0, 22, 1, -120),
        Size = UDim2.new(1, -44, 0, 16), BackgroundTransparency = 1,
        Text = "F2 / CTRL+K  •  STAR TO FAVORITE  •  ESC TO CLOSE",
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = theme.muted, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 63
    })

    local function resizePalette()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(900, 650)
        local guiScaleNumber = (Scale and Scale.Scale) or 1
        if guiScaleNumber <= 0 then guiScaleNumber = 1 end
        local w = math.floor(math.clamp(viewport.X / guiScaleNumber - 28, 280, 740))
        local h = math.floor(math.clamp(viewport.Y / guiScaleNumber - 36, 345, 600))
        palette.Size = UDim2.fromOffset(w, h)
        palette.Position = UDim2.new(0.5, -math.floor(w / 2), 0.5, -math.floor(h / 2))
        if paletteOpen and refreshList then refreshList() end
    end
    resizePalette()
    if Scale then Scale:GetPropertyChangedSignal("Scale"):Connect(resizePalette) end
    local paletteCameraConnection
    local function bindPaletteCamera()
        if paletteCameraConnection then
            paletteCameraConnection:Disconnect()
            paletteCameraConnection = nil
        end
        local camera = workspace.CurrentCamera
        if camera then
            paletteCameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resizePalette)
        end
        resizePalette()
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindPaletteCamera)
    bindPaletteCamera()

    local function updateTabs()
        local core, nova = countGroups()
        countText.Text = string.format("%d CORE  /  %d NOVA", core, nova)
        for name, button in pairs(buttons) do
            local active = name == mode
            button.BackgroundColor3 = active and theme.accent or theme.panel
            button.TextColor3 = active and theme.bg or theme.muted
        end
        groupBar.Visible = mode == "NOVA Additions"
        for name, button in pairs(groupButtons) do
            local active = name == group
            button.BackgroundColor3 = active and theme.indigo or theme.panel
            button.TextColor3 = active and theme.text or theme.muted
        end
        local h = palette.Size.Y.Offset
        local narrow = palette.Size.X.Offset < 570
        local short = h < 465
        countText.Visible = not narrow
        heading.TextSize = narrow and 15 or 20
        heading.Size = UDim2.new(1, narrow and -60 or -175, 0, 30)
        footerHint.Visible = not short
        if short then
            search.Position = UDim2.fromOffset(20, 50)
            search.Size = UDim2.new(1, -40, 0, 34)
            tabHolder.Position = UDim2.fromOffset(20, 91)
            groupBar.Position = UDim2.fromOffset(20, 124)
            commandInput.Position = UDim2.new(0, 20, 1, -91)
            commandInput.Size = UDim2.new(1, -40, 0, 32)
            runButton.Position = UDim2.new(0, 20, 1, -48)
            editButton.Position = UDim2.new(0.5, 6, 1, -48)
            if mode == "NOVA Additions" then
                listFrame.Position = UDim2.new(0, 20, 0, 157)
                listFrame.Size = UDim2.new(1, -40, 1, -260)
            else
                listFrame.Position = UDim2.new(0, 20, 0, 123)
                listFrame.Size = UDim2.new(1, -40, 1, -226)
            end
        else
            search.Position = UDim2.fromOffset(20, 56)
            search.Size = UDim2.new(1, -40, 0, 42)
            tabHolder.Position = UDim2.fromOffset(20, 108)
            groupBar.Position = UDim2.fromOffset(20, 148)
            commandInput.Position = UDim2.new(0, 20, 1, -101)
            commandInput.Size = UDim2.new(1, -40, 0, 37)
            runButton.Position = UDim2.new(0, 20, 1, -52)
            editButton.Position = UDim2.new(0.5, 6, 1, -52)
            if mode == "NOVA Additions" then
                listFrame.Position = UDim2.new(0, 20, 0, 184)
                listFrame.Size = UDim2.new(1, -40, 1, -299)
            else
                listFrame.Position = UDim2.new(0, 20, 0, 150)
                listFrame.Size = UDim2.new(1, -40, 1, -265)
            end
        end
    end

    local function selectCommand(value)
        selectedCommand = normalizeName(value)
        commandInput.Text = value
    end

    local function appendRow(name, detail, key, position)
        local source = key and commandGroup(key) or "History"
        local line = node("Frame", listFrame, {
            Name = "NOVA_Row", LayoutOrder = position,
            Size = UDim2.new(1, -5, 0, 58), BackgroundColor3 = theme.bg,
            BorderSizePixel = 0, ZIndex = 63
        })
        round(line, 9)
        node("UIStroke", line, {Color = theme.stroke, Transparency = 0.84, Thickness = 1})
        line:SetAttribute("CommandText", name)
        local pick = node("TextButton", line, {
            Size = UDim2.new(1, -45, 1, 0), BackgroundTransparency = 1,
            Text = "", ZIndex = 64
        })
        node("TextLabel", pick, {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4),
            Size = UDim2.new(1, -16, 0, 20),
            Font = Enum.Font.GothamSemibold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = name, TextColor3 = theme.text, ZIndex = 65
        })
        node("TextLabel", pick, {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 29),
            Size = UDim2.new(1, -16, 0, 22), Font = Enum.Font.Gotham,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = string.upper(source) .. "   •   " .. detail,
            TextColor3 = theme.muted, ZIndex = 65
        })
        pick.MouseButton1Click:Connect(function()
            selectCommand(name)
            commandInput:CaptureFocus()
            commandInput.CursorPosition = #commandInput.Text + 1
        end)
        if key then
            local favorite = node("TextButton", line, {
                Position = UDim2.new(1, -39, 0, 12),
                Size = UDim2.fromOffset(32, 32), BackgroundColor3 = theme.panel,
                Text = favoriteIndex(key) and "★" or "☆", TextSize = 23,
                TextColor3 = theme.accent, Font = Enum.Font.Gotham,
                ZIndex = 65
            })
            round(favorite, 7)
            favorite.MouseButton1Click:Connect(function()
                toggleFavorite(key)
            end)
        end
    end

    local function addEmpty(message)
        node("TextLabel", listFrame, {
            Name = "Empty", Size = UDim2.new(1, -7, 0, 55),
            LayoutOrder = 1, BackgroundTransparency = 1,
            Text = message, TextColor3 = theme.muted,
            Font = Enum.Font.Gotham, TextSize = 13,
            TextWrapped = true, ZIndex = 63
        })
    end

    refreshList = function()
        if not overlay or not overlay.Parent then return end
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel")
                or (child:IsA("TextButton") and child.Name == "NOVA_LoadMore") then
                child:Destroy()
            end
        end
        updateTabs()
        updateCommandGroups()
        local q = search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        local shown, total = 0, 0
        local limit = pageLimit -- 48 at first, optional extra pages (max 192)
        if mode == "Recent" then
            for _, raw in ipairs(store.recent) do
                local key = normalizeName(raw)
                if q == "" or raw:lower():find(q, 1, true) then
                    total = total + 1
                    if shown < limit then
                        shown = shown + 1
                        appendRow(raw, key and commandHelp(key) or "Previous command", key, shown)
                    end
                end
            end
        else
            local candidates = {}
            for _, cmd in ipairs(cmds) do
                local name = cmd.NAME
                local desc = commandHelp(name)
                local matches = q == "" or name:lower():find(q, 1, true)
                    or desc:lower():find(q, 1, true)
                if not matches then
                    for _, alias in ipairs(cmd.ALIAS or {}) do
                        if alias:lower():find(q, 1, true) then matches = true break end
                    end
                end
                if matches and groupMatches(name) and (mode ~= "Favorites" or favoriteIndex(name:lower())) then
                    table.insert(candidates, {name = name, desc = desc})
                end
            end
            table.sort(candidates, function(a, b)
                local aFav = favoriteIndex(a.name:lower()) and 1 or 0
                local bFav = favoriteIndex(b.name:lower()) and 1 or 0
                if aFav ~= bFav then return aFav > bFav end
                if q ~= "" then
                    local ae = a.name:lower():find(q, 1, true) == 1
                    local be = b.name:lower():find(q, 1, true) == 1
                    if ae ~= be then return ae end
                end
                return a.name:lower() < b.name:lower()
            end)
            total = #candidates
            for _, row in ipairs(candidates) do
                if shown >= limit then break end
                shown = shown + 1
                appendRow(row.name, row.desc, row.name:lower(), shown)
            end
        end
        if shown == 0 then
            addEmpty(mode == "Favorites" and "No favorites yet. Star a command to keep it here."
                or "No commands found in this category. Try another search or tab.")
        elseif total > shown then
            local more = node("TextButton", listFrame, {
                Name = "NOVA_LoadMore", LayoutOrder = shown + 1,
                Size = UDim2.new(1, -5, 0, 36), BackgroundColor3 = theme.hover,
                TextColor3 = theme.text, Font = Enum.Font.GothamSemibold,
                TextSize = 12, ZIndex = 65,
                Text = pageLimit >= 192 and "Refine search to see more results"
                    or string.format("Load more  •  %d of %d shown", shown, total)
            })
            round(more, 8)
            more.MouseButton1Click:Connect(function()
                if pageLimit >= 192 then return end
                local y = listFrame.CanvasPosition.Y
                pageLimit = math.min(192, pageLimit + 48)
                refreshList()
                listFrame.CanvasPosition = Vector2.new(0, y)
            end)
        end
        footerHint.Text = string.format("SHOWING %d / %d  •  ↑ / ↓ SELECT  •  ENTER TO EDIT  •  ESC TO CLOSE", shown, total)
        if pageLimit == 48 then listFrame.CanvasPosition = Vector2.new(0, 0) end
        local selected = nil
        local selectedIndex = math.clamp(paletteSelectionIndex or 1, 1, math.max(1, shown))
        paletteSelectionIndex = selectedIndex
        for _, row in ipairs(listFrame:GetChildren()) do
            if row:IsA("Frame") and row.Name == "NOVA_Row" then
                row.BackgroundColor3 = row.LayoutOrder == selectedIndex and theme.hover or theme.bg
                if row.LayoutOrder == selectedIndex then selected = row end
            end
        end
    end

    setPaletteVisible = function(state)
        paletteOpen = state == true
        overlay.Visible = paletteOpen
        if paletteOpen then
            resizePalette()
            refreshList()
            task.defer(function()
                if paletteOpen then search:CaptureFocus() end
            end)
        else
            search:ReleaseFocus()
            commandInput:ReleaseFocus()
        end
    end
    activatePalette = function(initialMode)
        if initialMode then mode = initialMode end
        setPaletteVisible(true)
    end
    close.MouseButton1Click:Connect(function() setPaletteVisible(false) end)
    for tab, button in pairs(buttons) do
        button.MouseButton1Click:Connect(function()
            mode = tab
            pageLimit = 48
            if tab ~= "NOVA Additions" then group = "All" end
            refreshList()
        end)
    end
    for category, button in pairs(groupButtons) do
        button.MouseButton1Click:Connect(function()
            group = category
            mode = "NOVA Additions"
            pageLimit = 48
            refreshList()
        end)
    end
    local refreshToken = 0
    local function listedRows()
        local rows = {}
        for _, item in ipairs(listFrame:GetChildren()) do
            if item:IsA("Frame") and item.Name == "NOVA_Row" then
                rows[#rows + 1] = item
            end
        end
        table.sort(rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        return rows
    end
    local function movePaletteSelection(change)
        local rows = listedRows()
        if #rows == 0 then return end
        paletteSelectionIndex = math.clamp(paletteSelectionIndex + change, 1, #rows)
        for i, item in ipairs(rows) do
            item.BackgroundColor3 = (i == paletteSelectionIndex) and theme.hover or theme.bg
        end
        local chosen = rows[paletteSelectionIndex]
        if chosen and chosen.Parent then
            -- Keep the selection visible without an expensive list rebuild.
            local top = chosen.AbsolutePosition.Y - listFrame.AbsolutePosition.Y
                + listFrame.CanvasPosition.Y
            local y = listFrame.CanvasPosition.Y
            if top < y then
                listFrame.CanvasPosition = Vector2.new(0, math.max(0, top))
            elseif top + chosen.AbsoluteSize.Y > y + listFrame.AbsoluteSize.Y then
                listFrame.CanvasPosition = Vector2.new(0,
                    math.max(0, top + chosen.AbsoluteSize.Y - listFrame.AbsoluteSize.Y))
            end
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(function()
        paletteSelectionIndex = 1
        refreshToken = refreshToken + 1
        local token = refreshToken
        pageLimit = 48
        task.delay(0.075, function()
            if token == refreshToken and paletteOpen then refreshList() end
        end)
    end)
    search.FocusLost:Connect(function(submitted)
        if submitted and paletteOpen then
            local rows = listedRows()
            local selected = rows[math.clamp(paletteSelectionIndex, 1, #rows)]
            if selected then
                local commandName = selected:GetAttribute("CommandText")
                if commandName then
                    selectCommand(commandName)
                    commandInput:CaptureFocus()
                end
            end
        end
    end)
    local function runPaletteCommand()
        local chosen = commandInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if chosen == "" then
            notify("NOVA Palette", "Select or type a command first.")
            return
        end
        setPaletteVisible(false)
        execCmd(chosen, localPlayer, true)
    end
    runButton.MouseButton1Click:Connect(runPaletteCommand)
    commandInput.FocusLost:Connect(function(submitted)
        if submitted and paletteOpen then runPaletteCommand() end
    end)
    editButton.MouseButton1Click:Connect(function()
        local chosen = commandInput.Text
        setPaletteVisible(false)
        Cmdbar.Text = chosen
        maximizeHolder()
        Cmdbar:CaptureFocus()
        Cmdbar.CursorPosition = #Cmdbar.Text + 1
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Escape and paletteOpen then
            setPaletteVisible(false)
            return
        end
        if paletteOpen and UserInputService:GetFocusedTextBox() == search then
            if input.KeyCode == Enum.KeyCode.Down then
                movePaletteSelection(1)
                return
            elseif input.KeyCode == Enum.KeyCode.Up then
                movePaletteSelection(-1)
                return
            end
        end
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.F2
            or (input.KeyCode == Enum.KeyCode.K and
                (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                or UserInputService:IsKeyDown(Enum.KeyCode.RightControl))) then
            setPaletteVisible(not paletteOpen)
        end
    end)

    -- Lightweight FPS / memory / ping HUD (only runs while enabled).
    local perfPanel = node("Frame", ScaledHolder, {
        Name = "NOVA_PerformanceHUD", Visible = false,
        Position = UDim2.new(0, 14, 0, 16), Size = UDim2.fromOffset(254, 100),
        BackgroundColor3 = theme.bg, BackgroundTransparency = 0.08,
        ZIndex = 30
    })
    round(perfPanel, 11)
    local performanceTitle = node("TextLabel", perfPanel, {
        Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -22, 0, 23),
        BackgroundTransparency = 1, Text = "NOVA  /  PERFORMANCE",
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = theme.accent, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31
    })
    local perfLabel = node("TextLabel", perfPanel, {
        Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -22, 0, 60),
        BackgroundTransparency = 1, Text = "Collecting frame data...",
        Font = Enum.Font.Code, TextSize = 14,
        TextColor3 = theme.text, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 31
    })
    local fpsConnection
    local frames, accumulated = 0, 0
    local function setPerformance(enabled)
        if fpsConnection then fpsConnection:Disconnect() fpsConnection = nil end
        perfPanel.Visible = enabled
        frames, accumulated = 0, 0
        if enabled then
            fpsConnection = RunService.RenderStepped:Connect(function(dt)
                frames = frames + 1
                accumulated = accumulated + dt
                if accumulated < 0.65 then return end
                local fps = math.floor(frames / accumulated + 0.5)
                frames, accumulated = 0, 0
                local ping = "n/a"
                pcall(function() ping = string.format("%.0f ms", localPlayer:GetNetworkPing() * 1000) end)
                local mem = "n/a"
                pcall(function() mem = string.format("%.0f MB", StatsService:GetTotalMemoryUsageMb()) end)
                perfLabel.Text = string.format("FPS     %d\nPing    %s\nMemory  %s", fps, ping, mem)
            end)
        end
        return enabled
    end

    -- Persisted accessible accent presets + global GUI sizing.
    local colorPresets = {
        blue = Color3.fromRGB(101, 157, 255),
        violet = Color3.fromRGB(163, 118, 255),
        mint = Color3.fromRGB(85, 229, 175),
        ember = Color3.fromRGB(255, 152, 99),
    }
    local function applyAccent(name)
        name = tostring(name or "blue"):lower()
        local color = colorPresets[name]
        if not color then return false end
        theme.accent = color
        topAccent.BackgroundColor3 = color
        local gradient = topAccent:FindFirstChildOfClass("UIGradient")
        if gradient then gradient.Color = ColorSequence.new(color, theme.indigo) end
        local runGradient = runButton:FindFirstChildOfClass("UIGradient")
        if runGradient then runGradient.Color = ColorSequence.new(color, theme.indigo) end
        runButton.BackgroundColor3 = color
        listFrame.ScrollBarImageColor3 = color
        local boxStroke = search:FindFirstChildOfClass("UIStroke")
        if boxStroke then boxStroke.Color = color end
        CMDsF.ScrollBarImageColor3 = color
        store.appearance.theme = name
        updateTabs()
        saveSoon()
        return true
    end
    -- Commands are registered after the original commands, preserving all of them.
    local function showFavorites()
        activatePalette("Favorites")
    end
    addcmd("palette", {"commandpalette", "nova"}, function()
        activatePalette("All")
        return "F2 or Ctrl+K opens the command palette."
    end)
    addcmd("iycore", {"originalcommands", "iycommands"}, function()
        activatePalette("Infinite Yield")
        return "Showing original Infinite Yield commands."
    end)
    addcmd("novaaddons", {"newcommands", "novacommands"}, function()
        activatePalette("NOVA Additions")
        return "Showing NOVA's new commands, separated from the original commands."
    end)
    addcmd("novagroup", {"commandgroup"}, function(args)
        local name = tostring(args[1] or "All"):lower()
        local groups = {all="All", gameplay="Gameplay", progression="Progression",
            advanced="Advanced", utilities="Utilities", studio="Studio"}
        if not groups[name] then return "Usage: novagroup [all/gameplay/progression/advanced/utilities/studio]" end
        group = groups[name]
        activatePalette("NOVA Additions")
        return "Showing NOVA: " .. group
    end)
    addcmd("novatheme", {"novacolor"}, function(args)
        local preset = tostring(args[1] or ""):lower()
        if not applyAccent(preset) then return "Usage: novatheme [blue/violet/mint/ember]" end
        return "NOVA theme: " .. preset
    end)
    addcmd("novascale", {"novaguiscale"}, function(args)
        local n = tonumber(args[1])
        if not n then return "Usage: novascale [0.8 to 1.25]" end
        n = math.clamp(n, 0.8, 1.25)
        if Scale then Scale.Scale = n end
        store.appearance.scale = n
        saveSoon()
        resizePalette()
        return "GUI scale: " .. string.format("%.2f", n)
    end)
    addcmd("refreshpalette", {"reindexcommands"}, function()
        groupCacheCount = -1
        refreshList()
        return "Command groups reindexed."
    end)
    addcmd("favorites", {"favs"}, showFavorites)
    addcmd("favorite", {"fav"}, function(args)
        local name = normalizeName(args[1])
        if not name then return "Usage: favorite [existing command]" end
        if not favoriteIndex(name) then toggleFavorite(name) end
        return "Favorited: " .. name
    end)
    addcmd("unfavorite", {"unfav"}, function(args)
        local name = normalizeName(args[1])
        if not name then return "Usage: unfavorite [existing command]" end
        if favoriteIndex(name) then toggleFavorite(name) end
        return "Removed favorite: " .. name
    end)
    addcmd("runfavorite", {"runfav"}, function(args)
        local name = normalizeName(args[1])
        if not name or not favoriteIndex(name) then return "That command is not in your favorites." end
        local rest = table.concat(args, " ", 2)
        -- Prevent runfavorite from recursively calling itself.
        if name == "runfavorite" then return "Cannot invoke runfavorite recursively." end
        execCmd(name .. (rest ~= "" and " " .. rest or ""), localPlayer, true)
    end)
    addcmd("clearfavorites", {"clearfavs"}, function()
        store.favorites = {}
        saveSoon()
        refreshList()
        if refreshQuickbar then refreshQuickbar() end
        return "Favorites cleared."
    end)
    addcmd("cmdsearch", {"commandsearch"}, function(args)
        search.Text = table.concat(args or {}, " ")
        activatePalette("All")
    end)
    addcmd("cmdinfo", {"commandinfo"}, function(args)
        local name = normalizeName(args[1])
        if not name then return "Usage: cmdinfo [existing command]" end
        local cmd = findCmd(name)
        local aliasesText = table.concat(cmd.ALIAS or {}, ", ")
        notify("Command: " .. name,
            commandHelp(name) .. "\nAliases: " .. (aliasesText ~= "" and aliasesText or "none"), 14)
    end)
    addcmd("recentcmds", {"recentcommands"}, function()
        activatePalette("Recent")
    end)
    addcmd("clearhistory", {"clearrecent"}, function()
        store.recent = {}
        cmdHistory = {}
        saveSoon()
        refreshList()
        return "Command history cleared."
    end)
    addcmd("cmdstats", {"commandstats"}, function()
        local sorted = {}
        for name, count in pairs(store.counts) do
            table.insert(sorted, {name = name, count = count})
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)
        local lines = {"Session dispatches: " .. sessionRuns}
        for i = 1, math.min(#sorted, 5) do
            table.insert(lines, string.format("%d. %s - %d", i, sorted[i].name, sorted[i].count))
        end
        notify("NOVA Command Analytics", table.concat(lines, "\n"), 15)
    end)
    addcmd("perfmon", {"performancehud", "performance"}, function()
        return setPerformance(not perfPanel.Visible) and "Performance HUD enabled" or "Performance HUD disabled"
    end)
    addcmd("unperfmon", {"noperfmon"}, function()
        setPerformance(false)
        return "Performance HUD disabled"
    end)
    addcmd("sessioninfo", {"novainfo"}, function()
        local elapsed = math.floor(os.clock() - sessionStart)
        return string.format("Uptime %dm %ds | %d commands dispatched | %d favorites",
            math.floor(elapsed / 60), elapsed % 60, sessionRuns, #store.favorites)
    end)
    addcmd("cmderrors", {"commanderrors"}, function()
        local records = _G.IY_NOVA_ERRORS or {}
        if #records == 0 then return "No command errors recorded this session." end
        local parts = {}
        for i = 1, math.min(3, #records) do
            table.insert(parts, tostring(records[i].command) .. ": " .. tostring(records[i].message):sub(1, 80))
        end
        notify("Recent Command Errors (" .. #records .. ")", table.concat(parts, "\n"), 15)
    end)
    addcmd("clearcmderrors", {"clearcommanderrors"}, function()
        _G.IY_NOVA_ERRORS = {}
        return "Command errors cleared."
    end)
    addcmd("novacheck", {"novadiag", "novadiagnostics"}, function()
        local saving = type(waxwritefile) == "function" and type(waxreadfile) == "function"
        local clipboard = type(everyClipboard) == "function"
        notify("NOVA Diagnostics",
            string.format("Commands: %d | Plugins: %d\nFile persistence: %s\nClipboard: %s\nError records: %d",
                #cmds, type(PluginsTable) == "table" and #PluginsTable or 0,
                saving and "available" or "session-only", clipboard and "available" or "unavailable",
                #(_G.IY_NOVA_ERRORS or {})), 12)
    end)
    addcmd("exportfavorites", {"copyfavorites"}, function()
        if type(everyClipboard) ~= "function" then return "Clipboard API is unavailable." end
        local raw = table.concat(store.favorites, "\n")
        if raw == "" then return "No favorites to export." end
        local ok = pcall(everyClipboard, raw)
        return ok and "Copied favorites to clipboard." or "Clipboard write failed."
    end)

    -- Register the new commands with the original searchable command list too.
    local addedHelp = {
        {"palette / commandpalette / nova", "Open the NOVA command palette (F2 or Ctrl+K)."},
        {"iycore / iycommands", "Browse original Infinite Yield commands only."},
        {"novaaddons / novacommands", "Browse every new NOVA command separately."},
        {"novagroup [category]", "Filter NOVA commands by Gameplay, Progression, Advanced, Utilities or Studio."},
        {"refreshpalette", "Refresh the command source and category index."},
        {"novatheme [color]", "Change accent to blue, violet, mint or ember (saved)."},
        {"novascale [0.8-1.25]", "Resize NOVA and the compact IY GUI (saved)."},
        {"favorites / favs", "Show commands you have starred."},
        {"favorite / fav [command]", "Add a command to favorites."},
        {"unfavorite / unfav [command]", "Remove a command from favorites."},
        {"runfavorite / runfav [command] [args]", "Run a favorited command."},
        {"clearfavorites / clearfavs", "Clear all favorited commands."},
        {"cmdsearch [query]", "Search all commands from the palette."},
        {"cmdinfo [command]", "Display a command description and aliases."},
        {"recentcmds / recentcommands", "Browse recently executed commands."},
        {"clearhistory / clearrecent", "Clear stored recent commands."},
        {"cmdstats / commandstats", "Show command usage statistics."},
        {"perfmon / performancehud", "Toggle the FPS, ping and memory monitor."},
        {"unperfmon", "Close the performance monitor."},
        {"sessioninfo / novainfo", "Show session uptime and dispatch count."},
        {"cmderrors / commanderrors", "Show recent command failures."},
        {"clearcmderrors", "Clear command error diagnostics."},
        {"exportfavorites", "Copy your favorites to clipboard."},
        {"novacheck / novadiag", "Check available APIs, commands and recent errors."},
    }
    for _, item in ipairs(addedHelp) do
        addcmdtext(item[1], "NOVA", item[2])
        local name = item[1]:match("^[%w_]+")
        if name then helpMap[name:lower()] = item[2] end
    end
    if IsOnMobile then
        local mobileButton = node("TextButton", ScaledHolder, {
            Name = "NOVA_MobilePalette", Position = UDim2.fromOffset(12, 45),
            Size = UDim2.fromOffset(54, 34), BackgroundColor3 = theme.accent,
            BorderSizePixel = 0, Text = "NOVA", Font = Enum.Font.GothamBold,
            TextColor3 = theme.bg, TextSize = 13, ZIndex = 25
        })
        round(mobileButton, 8)
        mobileButton.MouseButton1Click:Connect(function()
            setPaletteVisible(not paletteOpen)
        end)
    end
    -- Polished compact legacy IY console. Keep its exact dimensions and layout
    -- because existing settings, minimization and animations depend on them.
    local function skinWidget(widget, radius, strokeColor)
        if not widget or not widget.Parent then return end
        if not widget:FindFirstChild("NOVA_Rounding") then
            local corner = Instance.new("UICorner")
            corner.Name = "NOVA_Rounding"
            corner.CornerRadius = UDim.new(0, radius or 8)
            corner.Parent = widget
        end
        if strokeColor and not widget:FindFirstChild("NOVA_Outline") then
            local line = Instance.new("UIStroke")
            line.Name = "NOVA_Outline"
            line.Color = strokeColor
            line.Transparency = 0.44
            line.Thickness = 1
            line.Parent = widget
        end
    end
    Holder.BackgroundColor3 = theme.bg
    Title.BackgroundColor3 = theme.panel
    Dark.BackgroundColor3 = theme.bg
    Cmdbar.Font = Enum.Font.Gotham
    Cmdbar.TextSize = 14
    Cmdbar.PlaceholderText = "Type a command  •  F2 for NOVA"
    Cmdbar.TextColor3 = theme.text
    CMDsF.ScrollBarImageColor3 = theme.accent
    skinWidget(Holder, 11, theme.stroke)
    skinWidget(Title, 9)
    skinWidget(Settings, 9)
    skinWidget(Notification, 10, theme.stroke)
    skinWidget(Tooltip, 9)
    local edge = Instance.new("UIGradient")
    edge.Name = "NOVA_HeaderGradient"
    edge.Color = ColorSequence.new(theme.panel, theme.hover)
    edge.Rotation = 10
    edge.Parent = Title
    for _, iconButton in ipairs({SettingsButton, ReferenceButton}) do
        pcall(function() iconButton.ImageColor3 = theme.accent end)
    end
    Title.Text = "✦   INFINITE YIELD  /  NOVA"
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    -- A visible, mobile-friendly shortcut to the significantly larger UI.
    local launcher = node("TextButton", ScaledHolder, {
        Name = "NOVA_Launcher", Position = UDim2.new(1, -182, 1, -262),
        Size = UDim2.fromOffset(170, 33), BackgroundColor3 = theme.panel,
        Text = "✦   NOVA COMMAND CENTER", Font = Enum.Font.GothamSemibold,
        TextSize = 11, TextColor3 = theme.text, ZIndex = 32,
        AutoButtonColor = true
    })
    skinWidget(launcher, 10, theme.stroke)
    node("UIGradient", launcher, {Color = ColorSequence.new(theme.panel, theme.hover)})
    launcher.MouseButton1Click:Connect(function() activatePalette("All") end)
    pcall(function()
        if Scale then Scale.Scale = math.clamp(store.appearance.scale or 1, 0.8, 1.25) end
    end)
    applyAccent(store.appearance.theme or "blue")
    -- Pinned quick-access dock: compact buttons using *existing favorite names*.
    -- No new per-frame work, and it follows the palette's persisted preferences.
    local quickbar = node("Frame", ScaledHolder, {
        Name = "NOVA_Quickbar", Visible = store.appearance.quickbar, Active = true,
        Position = UDim2.new(0, 14, 0, 126), Size = UDim2.fromOffset(212, 44),
        BackgroundColor3 = theme.bg, BackgroundTransparency = 0.04, ZIndex = 36
    })
    round(quickbar, 10)
    dragGUI(quickbar)
    node("UIStroke", quickbar, {Color = theme.stroke, Thickness = 1, Transparency = 0.2})
    local qbTitle = node("TextLabel", quickbar, {
        Name = "Title", Position = UDim2.fromOffset(9, 5), Size = UDim2.new(1, -36, 0, 20),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = theme.accent, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "✦  NOVA QUICKBAR", ZIndex = 37
    })
    local qbClose = node("TextButton", quickbar, {
        Name = "CloseQuickbar", Position = UDim2.new(1, -28, 0, 5),
        Size = UDim2.fromOffset(22, 21), BackgroundColor3 = theme.hover,
        TextColor3 = theme.text, Font = Enum.Font.GothamBold, TextSize = 16,
        Text = "×", ZIndex = 37
    })
    round(qbClose, 6)
    local function setQuickbar(enabled)
        quickbar.Visible = enabled == true
        store.appearance.quickbar = quickbar.Visible
        saveSoon()
        return quickbar.Visible
    end
    qbClose.MouseButton1Click:Connect(function() setQuickbar(false) end)
    refreshQuickbar = function()
        if not quickbar.Parent then return end
        qbTitle.TextColor3 = theme.accent
        for _, child in ipairs(quickbar:GetChildren()) do
            if child:IsA("TextButton") and child.Name == "FavoriteRun" then child:Destroy() end
            if child:IsA("TextLabel") and child.Name == "EmptyFavorites" then child:Destroy() end
        end
        local available = {}
        for _, name in ipairs(store.favorites) do
            if findCmd(name) then
                available[#available + 1] = name
                if #available >= 5 then break end
            end
        end
        local count = #available
        quickbar.Size = UDim2.fromOffset(212, count == 0 and 62 or (36 + count * 32))
        if count == 0 then
            node("TextLabel", quickbar, {
                Name = "EmptyFavorites", Position = UDim2.fromOffset(8, 28),
                Size = UDim2.new(1, -16, 0, 27), BackgroundTransparency = 1,
                Text = "Star a command in the palette to pin it.",
                TextColor3 = theme.muted, Font = Enum.Font.Gotham, TextSize = 11,
                TextWrapped = true, ZIndex = 37
            })
            return
        end
        for i, name in ipairs(available) do
            local target = name
            local button = node("TextButton", quickbar, {
                Name = "FavoriteRun", Position = UDim2.fromOffset(7, 28 + (i - 1) * 32),
                Size = UDim2.new(1, -14, 0, 28),
                BackgroundColor3 = theme.panel, TextColor3 = theme.text,
                Text = string.format("★  %s", target), TextTruncate = Enum.TextTruncate.AtEnd,
                Font = Enum.Font.GothamSemibold, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 37
            })
            round(button, 6)
            node("UIPadding", button, {PaddingLeft = UDim.new(0, 9)})
            button.MouseButton1Click:Connect(function()
                if findCmd(target) then execCmd(target, localPlayer, true) end
            end)
        end
    end
    refreshQuickbar()
    addcmd("novaquickbar", {"nqbar"}, function(args)
        local state = tostring(args[1] or "toggle"):lower()
        if state == "off" or state == "hide" then setQuickbar(false)
        elseif state == "on" or state == "show" then setQuickbar(true)
        else setQuickbar(not quickbar.Visible) end
        if quickbar.Visible then refreshQuickbar() end
        return "Quickbar " .. (quickbar.Visible and "enabled" or "disabled") .. "."
    end)
    addcmdtext("novaquickbar [on/off]", "NOVA", "Pin your first five favorite commands in a movable-feeling compact dock.")
    _G.IY_NOVA_UI = {
        open = function(section) activatePalette(section or "All") end,
        refresh = function() groupCacheCount = -1; refreshList() end,
        category = commandGroup,
        theme = applyAccent,
        original = originalCommandNames,
        counts = countGroups,
        isOpen = function() return paletteOpen end,
        quickbar = setQuickbar,
        refreshQuickbar = refreshQuickbar,
    }
    IndexContents("", true)
    if _G.IY_DEBUG then print("[NOVA] Extension loaded. F2 or Ctrl+K opens palette.") end
end

--[[
  INFINITE YIELD NOVA | GAMEPLAY COMMAND PACK
  Additive and dependency-free. Commands are client-side; server authority may
  override movement, interaction and character property changes.
  Intentionally does not hook network remotes, spoof anti-cheat, or run HTTP code.
]]
do
    local me = Players.LocalPlayer
    local uis = UserInputService
    local rs = RunService
    local live = {}
    local cns = {}
    local registered = 0
    local function unbind(id)
        if cns[id] then cns[id]:Disconnect(); cns[id] = nil end
    end
    local function bind(id, signal, fn)
        unbind(id)
        cns[id] = signal:Connect(fn)
    end
    local function numeric(value, default, minimum, maximum)
        local n = tonumber(value)
        if not n or n ~= n or n == math.huge or n == -math.huge then n = default end
        return math.clamp(n, minimum, maximum)
    end
    local function character()
        local char = me.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        if not (char and hum and root and hum.Health > 0) then return nil end
        return char, hum, root
    end
    local function register(name, aliases, usage, description, fn)
        if findCmd(name) then
            warn("[NOVA gameplay] Skipping existing command:", name)
            return
        end
        local safeAliases = {}
        for _, alias in ipairs(aliases or {}) do
            if not findCmd(alias) then table.insert(safeAliases, alias) end
        end
        addcmd(name, safeAliases, fn)
        addcmdtext(usage or name, "NOVA GAMEPLAY", description)
        registered = registered + 1
    end
    local function playerRoot(plr)
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        if root and hum.Health > 0 then return root, hum, char end
    end
    local function sameTeam(plr)
        return me.Team ~= nil and plr.Team == me.Team and not me.Neutral and not plr.Neutral
    end
    local function playerColor(plr)
        return sameTeam(plr) and Color3.fromRGB(88, 220, 164) or Color3.fromRGB(255, 118, 115)
    end
    local function nearestPlayer(maxStuds, fieldOfViewPixels, includeFriends)
        local _, _, root = character()
        local camera = workspace.CurrentCamera
        if not root or not camera then return nil end
        local center = camera.ViewportSize * 0.5
        local best, bestScore = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me and (includeFriends or not sameTeam(plr)) then
                local otherRoot = playerRoot(plr)
                if otherRoot then
                    local dist = (otherRoot.Position - root.Position).Magnitude
                    if dist <= maxStuds then
                        local p, onScreen = camera:WorldToViewportPoint(otherRoot.Position)
                        local screenDist = (Vector2.new(p.X, p.Y) - center).Magnitude
                        if onScreen and p.Z > 0 and screenDist < fieldOfViewPixels and screenDist < bestScore then
                            best, bestScore = plr, screenDist
                        end
                    end
                end
            end
        end
        return best
    end
    local function getPlayerByName(raw)
        if not raw then return nil end
        local match = tostring(raw):lower()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me and (plr.Name:lower() == match or plr.DisplayName:lower() == match) then return plr end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me and (plr.Name:lower():sub(1, #match) == match or plr.DisplayName:lower():sub(1, #match) == match) then return plr end
        end
        return nil
    end
    local function decorate(frame, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 8)
        corner.Parent = frame
    end
    local function textLabel(parent, content, pos, size, fontSize)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text = content
        label.Font = Enum.Font.GothamMedium
        label.TextColor3 = Color3.fromRGB(233, 240, 252)
        label.TextSize = fontSize or 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = pos
        label.Size = size
        label.Parent = parent
        return label
    end
    -- Movement powers ---------------------------------------------------------
    local function directionalDash(direction, length)
        local char, _, root = character()
        if not root then return "Dash unavailable: character not ready." end
        local forward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
        local right = Vector3.new(root.CFrame.RightVector.X, 0, root.CFrame.RightVector.Z)
        if forward.Magnitude < 0.01 then return "Dash unavailable: no forward direction." end
        forward, right = forward.Unit, right.Unit
        local vec = (direction == "back" and -forward)
            or (direction == "left" and -right)
            or (direction == "right" and right) or forward
        local requested = numeric(length, 18, 2, 45)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        params.IgnoreWater = true
        local hit = workspace:Raycast(root.Position + Vector3.new(0, 1, 0), vec * requested, params)
        local travelled = hit and math.max(0, (hit.Position - (root.Position + Vector3.new(0, 1, 0))).Magnitude - 3) or requested
        if travelled < 1 then return "Dash blocked by a nearby obstacle." end
        char:PivotTo(char:GetPivot() + vec * travelled)
        return string.format("%s dash: %.0f studs", direction, travelled)
    end
    register("dash", {"forwarddash"}, "dash [studs]", "Short forward dash with obstruction checking (2-45 studs).", function(a)
        return directionalDash("forward", a[1])
    end)
    register("backdash", {}, "backdash [studs]", "Dash backwards without intentionally passing through walls.", function(a)
        return directionalDash("back", a[1])
    end)
    register("leftdash", {}, "leftdash [studs]", "Quick sideways dash to the left.", function(a)
        return directionalDash("left", a[1])
    end)
    register("rightdash", {}, "rightdash [studs]", "Quick sideways dash to the right.", function(a)
        return directionalDash("right", a[1])
    end)
    register("longjump", {"leap"}, "longjump [horizontal] [vertical]", "Launch forward with configurable horizontal/vertical velocity.", function(a)
        local _, hum, root = character()
        if not root then return "Character not ready." end
        local horizontal = numeric(a[1], 67, 10, 130)
        local vertical = numeric(a[2], 52, 10, 110)
        local face = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
        if face.Magnitude < 0.01 then return "No forward direction." end
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.AssemblyLinearVelocity = face.Unit * horizontal + Vector3.new(0, vertical, 0)
        return string.format("Long jump: %.0f horizontal / %.0f vertical", horizontal, vertical)
    end)
    register("superjump", {"skyjump"}, "superjump [power]", "Single high jump, without changing permanent JumpPower.", function(a)
        local _, hum, root = character()
        if not root then return "Character not ready." end
        local power = numeric(a[1], 100, 35, 150)
        local v = root.AssemblyLinearVelocity
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.AssemblyLinearVelocity = Vector3.new(v.X, power, v.Z)
        return "Super jump launched."
    end)

    local jumps = {enabled = false, extra = 1, spent = 0, last = 0, lastGrounded = os.clock()}
    local function stopMultiJump()
        jumps.enabled = false; jumps.spent = 0
        unbind("multiJump")
        unbind("multiJumpGround")
    end
    register("multijump", {"doublejump"}, "multijump [extra jumps]", "Allow 1-3 additional jumps in midair (default 1).", function(a)
        stopMultiJump()
        jumps.extra = math.floor(numeric(a[1], 1, 1, 3))
        jumps.enabled = true
        bind("multiJumpGround", rs.Heartbeat, function()
            local _, hum = character()
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                jumps.spent = 0
                jumps.lastGrounded = os.clock()
            end
        end)
        bind("multiJump", uis.JumpRequest, function()
            local _, hum, root = character()
            if not hum or not jumps.enabled then return end
            if hum.FloorMaterial ~= Enum.Material.Air then
                jumps.spent = 0
                return
            end
            if os.clock() - jumps.lastGrounded < 0.15 or
                os.clock() - jumps.last < 0.18 or jumps.spent >= jumps.extra then return end
            jumps.spent = jumps.spent + 1
            jumps.last = os.clock()
            local v = root.AssemblyLinearVelocity
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, 49), v.Z)
        end)
        return "Multi-jump enabled (" .. jumps.extra .. " additional jump(s))."
    end)
    register("unmultijump", {"undoublejump"}, "unmultijump", "Disable additional midair jumps.", function()
        stopMultiJump(); return "Multi-jump disabled."
    end)
    register("togglemultijump", {"toggledoublejump"}, "togglemultijump", "Toggle midair jumps.", function()
        if jumps.enabled then stopMultiJump(); return "Multi-jump disabled." end
        execCmd("multijump " .. jumps.extra, me)
        return "Multi-jump enabled."
    end)

    local hop = {enabled = false, last = 0}
    local function setHop(enabled)
        hop.enabled = enabled
        unbind("hop")
        if enabled then
            bind("hop", rs.Heartbeat, function()
                local _, hum = character()
                if not hum or hum.Sit or hum.MoveDirection.Magnitude < 0.1 then return end
                if hum.FloorMaterial ~= Enum.Material.Air and os.clock() - hop.last >= 0.13 then
                    hop.last = os.clock()
                    hum.Jump = true
                end
            end)
        end
    end
    register("bunnyhop", {"bhop"}, "bunnyhop", "Automatically jump when running on the ground.", function()
        setHop(true); return "Bunny hop enabled."
    end)
    register("unbunnyhop", {"unbhop"}, "unbunnyhop", "Disable automatic bunny hopping.", function()
        setHop(false); return "Bunny hop disabled."
    end)
    register("togglebunnyhop", {"togglebhop"}, "togglebunnyhop", "Toggle bunny hopping.", function()
        setHop(not hop.enabled); return "Bunny hop " .. (hop.enabled and "enabled." or "disabled.")
    end)

    local glide = {enabled = false, limit = 9}
    local function setGlide(enabled)
        glide.enabled = enabled
        unbind("glide")
        if enabled then
            bind("glide", rs.Heartbeat, function()
                local _, hum, root = character()
                if hum and hum.FloorMaterial == Enum.Material.Air and not hum.Sit then
                    local v = root.AssemblyLinearVelocity
                    if v.Y < -glide.limit then
                        root.AssemblyLinearVelocity = Vector3.new(v.X, -glide.limit, v.Z)
                    end
                end
            end)
        end
    end
    register("glide", {"slowfall"}, "glide [max fall speed]", "Limit downward velocity while airborne (default 9).", function(a)
        glide.limit = numeric(a[1], 9, 2, 35)
        setGlide(true); return "Glide enabled."
    end)
    register("unglide", {"unslowfall"}, "unglide", "Disable fall-speed limiting.", function()
        setGlide(false); return "Glide disabled."
    end)
    register("toggleglide", {}, "toggleglide", "Toggle glide mode.", function()
        setGlide(not glide.enabled); return "Glide " .. (glide.enabled and "enabled." or "disabled.")
    end)

    local climb = {enabled = false, speed = 18}
    local function setClimb(enabled)
        climb.enabled = enabled
        unbind("climb")
        if enabled then
            bind("climb", rs.Heartbeat, function()
                local char, hum, root = character()
                if not root or hum.Sit or not uis:IsKeyDown(Enum.KeyCode.Space) then return end
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {char}
                params.IgnoreWater = true
                local hit = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, params)
                if hit and math.abs(hit.Normal.Y) < 0.35 then
                    local v = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, climb.speed), v.Z)
                end
            end)
        end
    end
    register("wallclimb", {"spiderclimb"}, "wallclimb [speed]", "Hold Space against a near-vertical wall to climb.", function(a)
        climb.speed = numeric(a[1], 18, 5, 45)
        setClimb(true); return "Wall climb enabled (Space near a wall)."
    end)
    register("unwallclimb", {"unspiderclimb"}, "unwallclimb", "Disable wall climbing.", function()
        setClimb(false); return "Wall climb disabled."
    end)
    register("togglewallclimb", {}, "togglewallclimb", "Toggle wall climb.", function()
        setClimb(not climb.enabled); return "Wall climb " .. (climb.enabled and "enabled." or "disabled.")
    end)

    local burst = {token = 0, humanoid = nil, original = nil, active = false, speed = nil}
    local sprint = {enabled = false, locked = false, speed = 31, original = nil, activeHum = nil}
    local function restoreSprint()
        if sprint.activeHum and sprint.activeHum.Parent and sprint.original then
            -- Do not undo a speed change made by another command.
            if math.abs(sprint.activeHum.WalkSpeed - sprint.speed) < 0.01 then
                sprint.activeHum.WalkSpeed = sprint.original
            end
        end
        sprint.original = nil
        sprint.activeHum = nil
    end
    local function tickSprint()
        if burst.active then return end
        local _, hum = character()
        local shouldSprint = sprint.enabled and hum and (sprint.locked
            or uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift))
        if not shouldSprint then restoreSprint(); return end
        if sprint.activeHum ~= hum then
            restoreSprint()
            sprint.activeHum, sprint.original = hum, hum.WalkSpeed
        end
        if math.abs(hum.WalkSpeed - sprint.speed) > 0.01 then
            -- External speed modifiers take precedence if changed during sprint.
            if sprint.original ~= nil and hum.WalkSpeed ~= sprint.original then
                sprint.original = hum.WalkSpeed
            end
            hum.WalkSpeed = sprint.speed
        end
    end
    local function setSprint(enabled, locked)
        sprint.enabled = enabled
        sprint.locked = locked or false
        unbind("sprint")
        if enabled then
            bind("sprint", rs.Heartbeat, function()
                local now = os.clock()
                if not sprint.last or now - sprint.last >= 0.09 then
                    sprint.last = now
                    tickSprint()
                end
            end)
        else
            restoreSprint()
        end
    end
    register("sprint", {"shiftsprint"}, "sprint [speed]", "Hold Shift for temporary run speed (default 31).", function(a)
        if sprint.enabled then restoreSprint() end
        sprint.speed = numeric(a[1], 31, 17, 150)
        setSprint(true, false); return "Shift-sprint enabled."
    end)
    register("sprintlock", {"alwayssprint"}, "sprintlock [speed]", "Run faster continuously without holding Shift.", function(a)
        if sprint.enabled then restoreSprint() end
        sprint.speed = numeric(a[1], 31, 17, 150)
        setSprint(true, true); return "Sprint lock enabled."
    end)
    register("unsprint", {"unsprintlock", "noshiftsprint"}, "unsprint", "Disable both sprint modes and restore original speed.", function()
        setSprint(false, false); return "Sprint disabled."
    end)
    register("togglesprint", {}, "togglesprint", "Toggle Shift sprint at the previously chosen speed.", function()
        setSprint(not sprint.enabled, false)
        return "Shift sprint " .. (sprint.enabled and "enabled." or "disabled.")
    end)

    register("speedburst", {"burstspeed"}, "speedburst [speed] [seconds]", "Temporary speed boost with automatic restoration.", function(a)
        local _, hum = character()
        if not hum then return "Character not ready." end
        local speed = numeric(a[1], 60, 18, 160)
        local seconds = numeric(a[2], 3, 0.25, 15)
        local baseline
        if burst.active and burst.humanoid == hum then
            baseline = burst.original
        else
            restoreSprint()
            baseline = hum.WalkSpeed
        end
        burst.token = burst.token + 1
        local ownToken = burst.token
        burst.humanoid, burst.original = hum, baseline
        burst.speed, burst.active = speed, true
        hum.WalkSpeed = speed
        task.delay(seconds, function()
            if ownToken ~= burst.token then return end
            if hum.Parent and math.abs(hum.WalkSpeed - speed) < 0.01 then
                hum.WalkSpeed = baseline
            end
            burst.active = false
            burst.humanoid, burst.original, burst.speed = nil, nil, nil
        end)
        return string.format("Speed burst %.0f for %.1fs.", speed, seconds)
    end)

    -- Player ESP --------------------------------------------------------------
    local tracers = {enabled = false, range = 600, container = nil, items = {}, revision = 0}
    local function stopTracers()
        tracers.enabled = false
        tracers.revision = tracers.revision + 1
        for _, line in pairs(tracers.items) do line:Destroy() end
        table.clear(tracers.items)
        if tracers.container then tracers.container:Destroy(); tracers.container = nil end
        unbind("tracers")
    end
    local function enableTracers()
        stopTracers()
        tracers.enabled = true
        local overlay = Instance.new("Frame")
        overlay.Name = "NOVA_GameplayTracers"
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundTransparency = 1
        overlay.Active = false
        overlay.ZIndex = 35
        overlay.Parent = ScaledHolder
        tracers.container = overlay
        local accumulated = 0
        bind("tracers", rs.RenderStepped, function(dt)
            accumulated = accumulated + dt
            if accumulated < 0.05 then return end
            accumulated = 0
            local camera = workspace.CurrentCamera
            local _, _, myRoot = character()
            if not camera or not myRoot then return end
            local viewport = camera.ViewportSize
            local origin = Vector2.new(viewport.X * 0.5, viewport.Y * 0.87)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= me then
                    local other = playerRoot(plr)
                    local point, onScreen
                    if other then point, onScreen = camera:WorldToScreenPoint(other.Position) end
                    local distance = other and (other.Position - myRoot.Position).Magnitude or math.huge
                    local visible = onScreen and point.Z > 0 and distance <= tracers.range
                    local line = tracers.items[plr]
                    if visible then
                        if not line then
                            line = Instance.new("Frame")
                            line.Name = "Tracer_" .. plr.UserId
                            line.AnchorPoint = Vector2.new(0, 0.5)
                            line.BorderSizePixel = 0
                            line.ZIndex = 36
                            line.Parent = overlay
                            tracers.items[plr] = line
                        end
                        local target = Vector2.new(point.X, point.Y)
                        local diff = target - origin
                        line.Position = UDim2.fromOffset(origin.X, origin.Y)
                        line.Size = UDim2.fromOffset(diff.Magnitude, 2)
                        line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                        line.BackgroundColor3 = playerColor(plr)
                        line.Visible = true
                    elseif line then
                        line.Visible = false
                    end
                end
            end
            for plr, line in pairs(tracers.items) do
                if plr.Parent ~= Players then line:Destroy(); tracers.items[plr] = nil end
            end
        end)
    end
    register("tracers", {"playertracers"}, "tracers [max distance]", "Draw team-colored 2D lines to nearby players.", function(a)
        tracers.range = numeric(a[1], 600, 25, 2500)
        enableTracers(); return "Player tracers enabled."
    end)
    register("untracers", {"notracers"}, "untracers", "Remove all player tracer lines and the update connection.", function()
        stopTracers(); return "Player tracers disabled."
    end)
    register("toggletracers", {}, "toggletracers", "Toggle player tracers.", function()
        if tracers.enabled then stopTracers() else enableTracers() end
        return "Tracers " .. (tracers.enabled and "enabled." or "disabled.")
    end)

    local radar = {enabled = false, range = 160, frame = nil, dots = {}}
    local function stopRadar()
        radar.enabled = false
        unbind("radar")
        if radar.frame then radar.frame:Destroy(); radar.frame = nil end
        table.clear(radar.dots)
    end
    local function enableRadar()
        stopRadar()
        radar.enabled = true
        local panel = Instance.new("Frame")
        panel.Name = "NOVA_GameplayRadar"
        panel.Size = UDim2.fromOffset(222, 244)
        panel.Position = UDim2.new(1, -239, 0, 20)
        panel.BackgroundColor3 = Color3.fromRGB(20, 27, 39)
        panel.BackgroundTransparency = 0.07
        panel.BorderSizePixel = 0
        panel.ZIndex = 44
        panel.Parent = ScaledHolder
        decorate(panel, 10)
        textLabel(panel, "NOVA  /  PLAYER RADAR", UDim2.fromOffset(12, 7), UDim2.fromOffset(202, 23), 13).ZIndex = 45
        local circle = Instance.new("Frame")
        circle.Name = "RadarDisplay"
        circle.Size = UDim2.fromOffset(190, 190)
        circle.Position = UDim2.fromOffset(16, 34)
        circle.BackgroundColor3 = Color3.fromRGB(30, 41, 56)
        circle.BorderSizePixel = 0
        circle.ClipsDescendants = true
        circle.ZIndex = 45
        circle.Parent = panel
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(92, 117, 156)
        stroke.Transparency = 0.25
        stroke.Parent = circle
        local selfDot = Instance.new("Frame")
        selfDot.Size = UDim2.fromOffset(9, 9)
        selfDot.AnchorPoint = Vector2.new(0.5, 0.5)
        selfDot.Position = UDim2.fromOffset(95, 95)
        selfDot.BackgroundColor3 = Color3.fromRGB(110, 165, 255)
        selfDot.BorderSizePixel = 0
        selfDot.ZIndex = 47
        selfDot.Parent = circle
        decorate(selfDot, 10)
        radar.frame = panel
        local elapsed = 0
        bind("radar", rs.Heartbeat, function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.1 then return end
            elapsed = 0
            local _, _, root = character()
            if not root then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= me then
                    local other = playerRoot(plr)
                    local dot = radar.dots[plr]
                    if other then
                        if not dot then
                            dot = Instance.new("Frame")
                            dot.Name = "Radar_" .. plr.UserId
                            dot.Size = UDim2.fromOffset(7, 7)
                            dot.AnchorPoint = Vector2.new(0.5, 0.5)
                            dot.BorderSizePixel = 0
                            dot.ZIndex = 46
                            dot.Parent = circle
                            decorate(dot, 7)
                            radar.dots[plr] = dot
                        end
                        local relative = root.CFrame:VectorToObjectSpace(other.Position - root.Position)
                        local horizontal = Vector2.new(relative.X, relative.Z)
                        local dist = horizontal.Magnitude
                        dot.Visible = dist <= radar.range
                        if dot.Visible then
                            dot.Position = UDim2.fromOffset(95 + horizontal.X / radar.range * 90,
                                95 + horizontal.Y / radar.range * 90)
                            dot.BackgroundColor3 = playerColor(plr)
                        end
                    elseif dot then
                        dot.Visible = false
                    end
                end
            end
            for plr, dot in pairs(radar.dots) do
                if plr.Parent ~= Players then dot:Destroy(); radar.dots[plr] = nil end
            end
        end)
    end
    register("radar", {"playerradar"}, "radar [range]", "Compact top-down player radar; green teammates and red others.", function(a)
        radar.range = numeric(a[1], 160, 25, 1500)
        enableRadar(); return "Player radar enabled."
    end)
    register("unradar", {"noradar"}, "unradar", "Close player radar and disconnect its loop.", function()
        stopRadar(); return "Player radar disabled."
    end)
    register("toggleradar", {}, "toggleradar", "Toggle the player radar.", function()
        if radar.enabled then stopRadar() else enableRadar() end
        return "Player radar " .. (radar.enabled and "enabled." or "disabled.")
    end)

    local tags = {enabled = false, range = 450, revision = 0, items = {}}
    local function stopTags()
        tags.enabled = false
        tags.revision = tags.revision + 1
        for _, gui in pairs(tags.items) do gui:Destroy() end
        table.clear(tags.items)
    end
    local function enableTags()
        stopTags()
        tags.enabled = true
        tags.revision = tags.revision + 1
        local thisRevision = tags.revision
        task.spawn(function()
            while tags.enabled and thisRevision == tags.revision do
                local _, _, root = character()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= me then
                        local theirRoot, hum, char = playerRoot(plr)
                        local head = char and char:FindFirstChild("Head")
                        local current = tags.items[plr]
                        if current and (not head or current.Adornee ~= head) then
                            current:Destroy(); tags.items[plr] = nil; current = nil
                        end
                        local distance = root and theirRoot and (theirRoot.Position - root.Position).Magnitude or math.huge
                        if head and distance <= tags.range then
                            if not current then
                                current = Instance.new("BillboardGui")
                                current.Name = "NOVA_PlayerTag"
                                current.Size = UDim2.fromOffset(200, 40)
                                current.StudsOffsetWorldSpace = Vector3.new(0, 2.3, 0)
                                current.AlwaysOnTop = true
                                current.Adornee = head
                                current.Parent = head
                                local t = textLabel(current, "", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 13)
                                t.Name = "Text"
                                t.TextXAlignment = Enum.TextXAlignment.Center
                                t.TextStrokeTransparency = 0.35
                                tags.items[plr] = current
                            end
                            local label = current:FindFirstChild("Text")
                            if label then
                                label.Text = string.format("%s   %.0f studs   %d HP", plr.DisplayName,
                                    distance, math.ceil(hum.Health))
                                label.TextColor3 = playerColor(plr)
                            end
                            current.Enabled = true
                        elseif current then current.Enabled = false end
                    end
                end
                for plr, gui in pairs(tags.items) do
                    if plr.Parent ~= Players then gui:Destroy(); tags.items[plr] = nil end
                end
                task.wait(0.25)
            end
        end)
    end
    register("distancetags", {"playerlabels"}, "distancetags [range]", "Overhead player distance and health labels (client-side).", function(a)
        tags.range = numeric(a[1], 450, 20, 1500)
        enableTags(); return "Player distance tags enabled."
    end)
    register("undistancetags", {"unplayerlabels"}, "undistancetags", "Remove player distance labels.", function()
        stopTags(); return "Player distance tags disabled."
    end)
    register("toggledistancetags", {}, "toggledistancetags", "Toggle the overhead player labels.", function()
        if tags.enabled then stopTags() else enableTags() end
        return "Distance tags " .. (tags.enabled and "enabled." or "disabled.")
    end)

    local toolESP = {enabled = false, items = {}, revision = 0}
    local function stopToolESP()
        toolESP.enabled = false
        toolESP.revision = toolESP.revision + 1
        unbind("toolESP")
        for _, obj in pairs(toolESP.items) do obj:Destroy() end
        table.clear(toolESP.items)
    end
    local function highlightTool(tool)
        if not toolESP.enabled or not tool:IsA("Tool") or not tool:IsDescendantOf(workspace) then return end
        if tool.Parent and tool.Parent:IsA("Model") and Players:GetPlayerFromCharacter(tool.Parent) then return end
        if toolESP.items[tool] then return end
        local n = 0
        for _ in pairs(toolESP.items) do n = n + 1 end
        if n >= 120 then return end
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
        if not handle then return end
        local high = Instance.new("Highlight")
        high.Name = "NOVA_ToolHighlight"
        high.Adornee = handle
        high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        high.FillColor = Color3.fromRGB(255, 213, 101)
        high.OutlineColor = Color3.fromRGB(255, 246, 181)
        high.FillTransparency = 0.72
        high.Parent = handle
        toolESP.items[tool] = high
    end
    local function enableToolESP()
        stopToolESP()
        toolESP.enabled = true
        toolESP.revision = toolESP.revision + 1
        local revision = toolESP.revision
        bind("toolESP", workspace.DescendantAdded, function(obj)
            if obj:IsA("Tool") then
                task.defer(function() if revision == toolESP.revision then highlightTool(obj) end end)
            elseif obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Tool") then
                task.defer(function() if revision == toolESP.revision then highlightTool(obj.Parent) end end)
            end
        end)
        task.spawn(function()
            local all = workspace:GetDescendants()
            for i, obj in ipairs(all) do
                if revision ~= toolESP.revision then return end
                if obj:IsA("Tool") then highlightTool(obj) end
                if i % 300 == 0 then task.wait() end
            end
            while revision == toolESP.revision do
                for tool, marker in pairs(toolESP.items) do
                    if not tool.Parent or not tool:IsDescendantOf(workspace) or
                        (tool.Parent and tool.Parent:IsA("Model") and Players:GetPlayerFromCharacter(tool.Parent)) or not marker.Parent then
                        marker:Destroy(); toolESP.items[tool] = nil
                    end
                end
                task.wait(1)
            end
        end)
    end
    register("toolesp", {"itemesp"}, "toolesp", "Highlight dropped Tools in the workspace (max 120).", function()
        enableToolESP(); return "Dropped-tool ESP enabled."
    end)
    register("untoolesp", {"unitemesp"}, "untoolesp", "Remove dropped Tool highlights.", function()
        stopToolESP(); return "Dropped-tool ESP disabled."
    end)
    register("toggletoolesp", {}, "toggletoolesp", "Toggle Tool ESP.", function()
        if toolESP.enabled then stopToolESP() else enableToolESP() end
        return "Tool ESP " .. (toolESP.enabled and "enabled." or "disabled.")
    end)
    register("nearbyplayers", {"nearestplayers"}, "nearbyplayers [radius]", "List up to 8 players sorted by distance.", function(a)
        local _, _, root = character()
        if not root then return "Character not ready." end
        local radius = numeric(a[1], 250, 10, 2500)
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me then
                local other = playerRoot(plr)
                if other then
                    local distance = (other.Position - root.Position).Magnitude
                    if distance <= radius then table.insert(list, {player = plr, distance = distance}) end
                end
            end
        end
        table.sort(list, function(a, b) return a.distance < b.distance end)
        if #list == 0 then return "No players within " .. math.floor(radius) .. " studs." end
        local lines = {}
        for i = 1, math.min(#list, 8) do
            local item = list[i]
            table.insert(lines, string.format("%s: %d studs", item.player.Name, item.distance))
        end
        notify("Nearby players (" .. #list .. ")", table.concat(lines, "\n"), 12)
    end)

    -- Optional aim camera assist: only with right mouse held. Does not fire tools.
    local aim = {enabled = false, target = nil, maxDist = 300}
    local function stopAim()
        aim.enabled = false
        aim.target = nil
        pcall(function() rs:UnbindFromRenderStep("NOVA_AimCamera") end)
    end
    local function startAim()
        stopAim()
        aim.enabled = true
        rs:BindToRenderStep("NOVA_AimCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
            if not aim.enabled or not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
            if uis:GetFocusedTextBox() then return end
            local camera = workspace.CurrentCamera
            local _, _, root = character()
            if not camera or not root then return end
            local target = aim.target or nearestPlayer(aim.maxDist, 230, false)
            local targetRoot, _, targetChar = target and playerRoot(target)
            if not targetRoot or (targetRoot.Position - root.Position).Magnitude > aim.maxDist then return end
            local head = targetChar:FindFirstChild("Head") or targetRoot
            local goal = CFrame.lookAt(camera.CFrame.Position, head.Position)
            local alpha = 1 - math.pow(0.8, math.clamp(dt, 0, 0.1) * 60)
            camera.CFrame = camera.CFrame:Lerp(goal, alpha)
        end)
    end
    register("aimassist", {"aimlock"}, "aimassist [closest|player] [max distance]", "Smooth camera lock while holding right mouse; no autofire.", function(a)
        local name = a[1]
        local requestedTarget = name and name:lower() ~= "closest" and getPlayerByName(name) or nil
        if name and name:lower() ~= "closest" and not requestedTarget then
            return "Player not found: " .. tostring(name)
        end
        aim.target = requestedTarget
        aim.maxDist = numeric(a[2], 300, 30, 1200)
        -- startAim resets the target; capture it first.
        local selected = aim.target
        startAim()
        aim.target = selected
        return "Aim assist enabled (hold right mouse)."
    end)
    register("unaimassist", {"unaimlock"}, "unaimassist", "Remove camera aim assist.", function()
        stopAim(); return "Aim assist disabled."
    end)
    register("toggleaimassist", {}, "toggleaimassist", "Toggle right-mouse aim assist.", function()
        if aim.enabled then stopAim() else startAim() end
        return "Aim assist " .. (aim.enabled and "enabled." or "disabled.")
    end)

    -- Lifecycle and help ------------------------------------------------------
    me.CharacterAdded:Connect(function()
        jumps.spent = 0
        jumps.lastGrounded = os.clock()
        burst.token = burst.token + 1
        burst.active = false
        burst.humanoid, burst.original, burst.speed = nil, nil, nil
        sprint.original, sprint.activeHum = nil, nil
    end)
    register("gameplayhelp", {"novacheats"}, "gameplayhelp", "Show all gameplay extension commands by category.", function()
        notify("NOVA Gameplay: " .. registered .. " commands", 
            "Movement: dash, longjump, superjump, multijump, bunnyhop, sprint, glide, wallclimb, speedburst\n"
            .. "ESP: tracers, radar, distancetags, toolesp, nearbyplayers\n"
            .. "Camera: aimassist [closest|player] [range]\n"
            .. "Use F2 or Ctrl+K to search any command.", 17)
        return nil
    end)
    IndexContents("", true)
    if _G.IY_DEBUG then print("[NOVA gameplay] Added", registered, "gameplay commands") end
end


--[[
    INFINITE YIELD NOVA | PROGRESSION LAB
    A client-observable objective explorer and confirmed-collection autopilot.
    Integrates with the existing IY command registry; no remote guessing,
    purchase automation, anti-cheat bypass, or claims of server-side rewards.
]]
do
    local player = Players.LocalPlayer
    local http = HttpService
    local run = RunService
    local world = workspace
    local PROG = {
        running = false, paused = false, farm = false, token = 0,
        candidates = {}, scanGeneration = 0, scanActive = false,
        scanned = 0, indexCount = 0, scanAt = 0, scanLimit = 25000, candidateLimit = 500,
        category = "collect", radius = 1200, strategy = "adaptive",
        travel = "teleport", verifySeconds = 2.5, attempts = 2,
        filter = "", ignores = {}, selectedStat = "", goal = nil,
        attempted = 0, confirmed = 0, failed = 0, current = nil,
        lastPosition = nil, waypoint = nil, visitCooldown = setmetatable({}, {__mode = "k"}),
        learning = {}, log = {}, startedAt = os.clock(), samples = {},
        markerMode = false, markers = {}, overlay = nil, overlayVisible = false,
        stopReason = "Not started", saved = false, saveQueued = false,
    }
    _G.IY_NOVA_PROGRESSION = PROG
    local saveFile = "IY_NOVA_Progression.json"

    local function say(title, body, seconds)
        notify("PROGRESSION  /  " .. title, tostring(body), seconds or 9)
    end
    local function limitNumber(raw, default, low, high)
        local value = tonumber(raw)
        if not value or value ~= value or value == math.huge or value == -math.huge then value = default end
        return math.clamp(value, low, high)
    end
    local function cleaned(raw, maxLength)
        return string.lower(tostring(raw or "")):sub(1, maxLength or 60):match("^%s*(.-)%s*$") or ""
    end
    local function log(text)
        local entry = os.date("%H:%M:%S") .. "  " .. tostring(text):sub(1, 150)
        table.insert(PROG.log, 1, entry)
        if #PROG.log > 60 then table.remove(PROG.log) end
        if _G.IY_DEBUG then print("[NOVA progression]", entry) end
    end
    local function getBody()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and (char:FindFirstChild("HumanoidRootPart") or (hum and hum.RootPart))
        if hum and root and hum.Health > 0 then return char, hum, root end
        return nil
    end
    local function getRootPosition()
        local _, _, root = getBody()
        return root and root.Position or nil
    end
    local function available(instance)
        return typeof(instance) == "Instance" and instance.Parent ~= nil and instance:IsDescendantOf(world)
    end
    local function matchesAny(str, terms)
        for _, term in ipairs(terms) do
            if string.find(str, term, 1, true) then return true end
        end
        return false
    end
    local forbiddenTerms = {"lava", "killbrick", "killpart", "hazard", "damagepart", "death", "void", "shop", "buy", "purchase", "robux", "gamepass", "donation", "devproduct", "price"}
    local checkpoints = {"checkpoint", "stage", "savepoint", "finish", "endzone", "respawnpoint"}
    local collectibles = {"orb", "coin", "gem", "pickup", "collect", "drop", "star", "token", "crystal", "chest", "diamond", "cash", "money", "treasure", "loot", "ring", "reward", "present", "egg"}
    local resources = {"ore", "mineral", "tree", "log", "rock", "harvest", "resource", "farm", "crop", "fruit", "plant", "wheat", "mine", "wood"}
    local interactables = {"button", "lever", "switch", "trigger", "unlock", "open", "claim", "interact"}
    local function contextName(part)
        local chunks = {string.lower(part.Name)}
        local ancestor = part.Parent
        local steps = 0
        while ancestor and ancestor ~= world and steps < 3 do
            if ancestor:IsA("Model") and Players:GetPlayerFromCharacter(ancestor) then return "" end
            table.insert(chunks, string.lower(ancestor.Name))
            ancestor = ancestor.Parent
            steps = steps + 1
        end
        return table.concat(chunks, " ")
    end
    local function classify(part)
        if not part:IsA("BasePart") or part.Size.Magnitude > 110 then return nil end
        if player.Character and part:IsDescendantOf(player.Character) then return nil end
        local s = contextName(part)
        if s == "" or matchesAny(s, forbiddenTerms) then return nil end
        if matchesAny(s, checkpoints) then return "checkpoint", s end
        if matchesAny(s, collectibles) then return "collect", s end
        if matchesAny(s, resources) then return "resource", s end
        if matchesAny(s, interactables) then return "interact", s end
        local hasPrompt = part:FindFirstChildOfClass("ProximityPrompt") ~= nil
        local hasClick = part:FindFirstChildOfClass("ClickDetector") ~= nil
        if (hasPrompt or hasClick) and not matchesAny(s, {"shop", "buy", "sell", "upgrade", "purchase", "price"}) then
            return "interact", s
        end
        return nil
    end
    local function eligible(entry)
        if not available(entry.part) then return false end
        if PROG.category ~= "all" and PROG.category ~= entry.kind then return false end
        if PROG.filter ~= "" and not string.find(entry.path, PROG.filter, 1, true) then return false end
        for _, excluded in ipairs(PROG.ignores) do
            if string.find(entry.path, excluded, 1, true) then return false end
        end
        if (PROG.visitCooldown[entry.part] or 0) > os.clock() then return false end
        return true
    end
    local function addCandidate(part, targetTable)
        if not available(part) or targetTable[part] then return false end
        local kind, path = classify(part)
        if not kind then return false end
        targetTable[part] = {part = part, kind = kind, path = path, label = part.Name:sub(1, 50)}
        return true
    end
    local function candidateCount()
        local n = 0
        for _, entry in pairs(PROG.candidates) do
            if eligible(entry) then n = n + 1 end
        end
        return n
    end
    local function refreshMarkers()
        for _, obj in pairs(PROG.markers) do pcall(function() obj:Destroy() end) end
        table.clear(PROG.markers)
        if not PROG.markerMode then return end
        local rootPos = getRootPosition()
        if not rootPos then return end
        local choices = {}
        for _, item in pairs(PROG.candidates) do
            if eligible(item) then
                local distance = (rootPos - item.part.Position).Magnitude
                if distance <= PROG.radius then
                    table.insert(choices, {entry = item, distance = distance})
                end
            end
        end
        table.sort(choices, function(a, b) return a.distance < b.distance end)
        for i = 1, math.min(#choices, 38) do
            local entry = choices[i].entry
            local highlight = Instance.new("Highlight")
            highlight.Name = "NOVA_ProgressObjective"
            highlight.Adornee = entry.part
            highlight.FillTransparency = 0.75
            highlight.OutlineTransparency = 0.05
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = entry.kind == "checkpoint" and Color3.fromRGB(96, 230, 180)
                or entry.kind == "resource" and Color3.fromRGB(170, 160, 252)
                or Color3.fromRGB(255, 209, 107)
            highlight.Parent = entry.part
            table.insert(PROG.markers, highlight)
        end
    end
    local function scheduleSave()
        if PROG.saveQueued or type(waxwritefile) ~= "function" then return end
        PROG.saveQueued = true
        task.delay(1.4, function()
            PROG.saveQueued = false
            local settings = {
                category = PROG.category, radius = PROG.radius,
                strategy = PROG.strategy, travel = PROG.travel,
                filter = PROG.filter, ignores = PROG.ignores,
                selectedStat = PROG.selectedStat, verifySeconds = PROG.verifySeconds,
                attempts = PROG.attempts,
            }
            local ok, encoded = pcall(function() return http:JSONEncode(settings) end)
            if ok then pcall(waxwritefile, saveFile, encoded) end
        end)
    end
    if type(waxreadfile) == "function" then
        local ok, contents = pcall(waxreadfile, saveFile)
        if ok and type(contents) == "string" then
            local decoded, settings = pcall(function() return http:JSONDecode(contents) end)
            if decoded and type(settings) == "table" then
                if table.find({"collect", "checkpoint", "resource", "interact", "all"}, settings.category) then PROG.category = settings.category end
                if table.find({"adaptive", "nearest", "rarity"}, settings.strategy) then PROG.strategy = settings.strategy end
                if table.find({"teleport", "walk"}, settings.travel) then PROG.travel = settings.travel end
                PROG.radius = limitNumber(settings.radius, 1200, 30, 5000)
                PROG.filter = cleaned(settings.filter)
                PROG.selectedStat = cleaned(settings.selectedStat)
                PROG.verifySeconds = limitNumber(settings.verifySeconds, 2.5, 0.6, 8)
                PROG.attempts = math.floor(limitNumber(settings.attempts, 2, 1, 3))
                if type(settings.ignores) == "table" then
                    for _, value in ipairs(settings.ignores) do
                        if type(value) == "string" and #PROG.ignores < 20 then
                            table.insert(PROG.ignores, cleaned(value))
                        end
                    end
                end
            end
        end
    end

    local function scanObjectives(callback)
        PROG.scanGeneration = PROG.scanGeneration + 1
        local generation = PROG.scanGeneration
        PROG.scanActive = true
        task.spawn(function()
            local nextCandidates, count = {}, 0
            local ok, descendants = pcall(function() return world:GetDescendants() end)
            if not ok then
                PROG.scanActive = false
                log("Workspace scan failed: " .. tostring(descendants))
                return
            end
            for i = 1, math.min(#descendants, PROG.scanLimit) do
                if generation ~= PROG.scanGeneration then return end
                local obj = descendants[i]
                if obj:IsA("BasePart") and addCandidate(obj, nextCandidates) then
                    count = count + 1
                end
                if i % 400 == 0 then task.wait() end
                if count >= PROG.candidateLimit * 3 then break end
            end
            if generation ~= PROG.scanGeneration then return end
            local nearest, selected = {}, {}
            local root = getRootPosition()
            for _, item in pairs(nextCandidates) do
                local distance = root and (root - item.part.Position).Magnitude or 0
                table.insert(nearest, {item = item, distance = distance})
            end
            table.sort(nearest, function(a, b) return a.distance < b.distance end)
            for i = 1, math.min(#nearest, PROG.candidateLimit) do
                local item = nearest[i].item
                selected[item.part] = item
            end
            PROG.candidates = selected
            PROG.indexCount = math.min(#nearest, PROG.candidateLimit)
            PROG.scanned = #nearest
            PROG.scanAt = os.clock()
            PROG.scanActive = false
            refreshMarkers()
            log("Indexed " .. #nearest .. " candidate objects (" .. candidateCount() .. " matching filters)")
            if callback then callback() end
        end)
    end

    local function keyFromStat(stat)
        return stat.Parent.Name .. "." .. stat.Name
    end
    local function collectStats()
        local values, total = {}, 0
        local sources = {player:FindFirstChild("leaderstats")}
        for _, name in ipairs({"Stats", "Data", "NormalStats", "PlayerStats", "Currencies"}) do
            local folder = player:FindFirstChild(name)
            if folder then table.insert(sources, folder) end
        end
        for _, source in ipairs(sources) do
            if source then
                for _, obj in ipairs(source:GetChildren()) do
                    if total >= 80 then break end
                    if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                        values[keyFromStat(obj)] = obj.Value
                        total = total + 1
                    elseif obj:IsA("Folder") then
                        for _, nested in ipairs(obj:GetChildren()) do
                            if total >= 80 then break end
                            if nested:IsA("IntValue") or nested:IsA("NumberValue") then
                                values[source.Name .. "." .. obj.Name .. "." .. nested.Name] = nested.Value
                                total = total + 1
                            end
                        end
                    end
                end
            end
        end
        return values
    end
    local function matchingStat(stats)
        local requested = PROG.selectedStat
        if requested == "" then return nil, nil end
        for name, value in pairs(stats) do
            if cleaned(name) == requested then return name, value end
        end
        for name, value in pairs(stats) do
            if cleaned(name):match("[^%.]+$") == requested then return name, value end
        end
        return nil, nil
    end
    local function changedStats(before, after)
        local selectedName = matchingStat(before)
        local totalChange, selectedChange = 0, nil
        for name, oldValue in pairs(before) do
            local current = after[name]
            if current and current ~= oldValue then
                totalChange = totalChange + 1
                if name == selectedName then selectedChange = current - oldValue end
            end
        end
        if PROG.selectedStat ~= "" then
            return selectedChange ~= nil, selectedChange or 0, selectedName or PROG.selectedStat
        end
        return totalChange > 0, totalChange, "any stat"
    end
    local function sampleTracked()
        local _, value = matchingStat(collectStats())
        if value == nil then return nil end
        table.insert(PROG.samples, {when = os.clock(), value = value})
        while #PROG.samples > 90 do table.remove(PROG.samples, 1) end
        return value
    end
    local function ratePerMinute()
        if #PROG.samples < 2 then return 0 end
        local oldest, newest = PROG.samples[1], PROG.samples[#PROG.samples]
        local seconds = newest.when - oldest.when
        if seconds < 2 then return 0 end
        return (newest.value - oldest.value) * 60 / seconds
    end
    local function goalReached()
        if PROG.goal == nil or PROG.selectedStat == "" then return false end
        local _, value = matchingStat(collectStats())
        return value ~= nil and value >= PROG.goal
    end
    local function chooseTarget(origin, excluded)
        local best, bestScore = nil, -math.huge
        for _, item in pairs(PROG.candidates) do
            if not (excluded and (excluded == item.part or (type(excluded) == "table" and excluded[item.part]))) and eligible(item) then
                local distance = (item.part.Position - origin).Magnitude
                if distance <= PROG.radius then
                    local score = -(distance / 30)
                    if PROG.strategy == "adaptive" then
                        local learned = PROG.learning[item.kind]
                        if learned and learned.count > 0 then
                            score = score + math.clamp(learned.sum / learned.count, 0, 60) * 5
                        end
                    elseif PROG.strategy == "rarity" then
                        score = score + (item.kind == "checkpoint" and 25 or 0)
                        score = score + (item.kind == "collect" and 10 or 0)
                        if matchesAny(item.path, {"legendary", "rare", "mythic", "epic", "rainbow", "gold"}) then score = score + 45 end
                    end
                    if score > bestScore then best, bestScore = item, score end
                end
            end
        end
        return best
    end
    local function targetName(entry)
        return (entry and (entry.label .. " [" .. entry.kind .. "]") or "None")
    end
    local function travelTo(entry, token)
        local char, hum, root = getBody()
        if not root then return false, "Character unavailable" end
        local part = entry.part
        if not available(part) then return false, "Object despawned" end
        local position = part.Position
        if PROG.travel == "teleport" then
            PROG.lastPosition = char:GetPivot()
            local offset = Vector3.new(0, math.clamp(part.Size.Y / 2 + 1.7, 1.3, 5), 0)
            local ok = pcall(function() char:PivotTo(CFrame.new(position + offset)) end)
            task.wait(0.16)
            if token ~= PROG.token then return false, "Cancelled" end
            if not ok or (root.Position - position).Magnitude > math.max(15, part.Size.Magnitude) then
                return false, "Position was rejected or corrected"
            end
        else
            local destination = position + Vector3.new(0, math.min(part.Size.Y * 0.5, 3), 0)
            -- Standard Humanoid movement; avoid blocking for long distances.
            local ok = pcall(function() hum:MoveTo(destination) end)
            if not ok then return false, "MoveTo failed" end
            local start = os.clock()
            while token == PROG.token and os.clock() - start < 8 do
                if (root.Position - destination).Magnitude <= 7 then break end
                task.wait(0.14)
            end
            if token ~= PROG.token then return false, "Cancelled" end
            if (root.Position - destination).Magnitude > 9 then return false, "Walk target timed out" end
        end
        return true
    end
    local function tryInteraction(entry, token)
        local part = entry.part
        if not available(part) or matchesAny(entry.path, forbiddenTerms) then return end
        local prompt = part:FindFirstChildOfClass("ProximityPrompt")
            or (part.Parent and part.Parent:FindFirstChildOfClass("ProximityPrompt"))
        if prompt and prompt.Enabled and not matchesAny(cleaned(prompt.ActionText .. " " .. prompt.ObjectText),
            {"buy", "purchase", "donate", "robux", "shop", "gamepass", "price"}) then
            local _, _, root = getBody()
            local promptParent = prompt.Parent
            local promptPos = promptParent and (promptParent:IsA("BasePart") and promptParent.Position
                or promptParent:IsA("Attachment") and promptParent.WorldPosition)
            if root and promptPos and (root.Position - promptPos).Magnitude <= prompt.MaxActivationDistance + 3 then
                pcall(function() prompt:InputHoldBegin() end)
                task.wait(math.clamp(prompt.HoldDuration + 0.12, 0.12, 4))
                if token ~= PROG.token then pcall(function() prompt:InputHoldEnd() end) return end
                pcall(function() prompt:InputHoldEnd() end)
            end
        end
        local click = part:FindFirstChildOfClass("ClickDetector")
            or (part.Parent and part.Parent:FindFirstChildOfClass("ClickDetector"))
        if click and type(fireclickdetector) == "function" then
            pcall(fireclickdetector, click)
        end
    end
    local function verifyInteraction(entry, before, token)
        local start = os.clock()
        while token == PROG.token and os.clock() - start < PROG.verifySeconds do
            if not available(entry.part) then return true, "despawn", 1 end
            local after = collectStats()
            local changed, delta, statName = changedStats(before, after)
            if changed then return true, "changed " .. tostring(statName), delta end
            task.wait(0.15)
        end
        return false, "no observed reward or despawn", 0
    end
    local function attempt(entry, token)
        local before = collectStats()
        local started = os.clock()
        for try = 1, PROG.attempts do
            if token ~= PROG.token then return nil, "cancelled" end
            if not available(entry.part) then return true, "despawn", 1 end
            local moved, reason = travelTo(entry, token)
            if not moved then
                if reason == "Cancelled" then return nil, reason end
                return false, reason
            end
            tryInteraction(entry, token)
            local verified, method, delta = verifyInteraction(entry, before, token)
            if verified then
                local elapsed = math.max(0.1, os.clock() - started)
                local learned = PROG.learning[entry.kind] or {sum = 0, count = 0}
                local rewardRate = math.log(1 + math.max(0, delta)) / elapsed
                learned.sum = learned.sum + math.clamp(rewardRate, 0, 80)
                learned.count = learned.count + 1
                PROG.learning[entry.kind] = learned
                return true, method
            end
            task.wait(0.22)
        end
        return false, "no confirmed collection"
    end
    local function stop(reason)
        PROG.token = PROG.token + 1
        PROG.running = false
        PROG.paused = false
        PROG.current = nil
        PROG.stopReason = reason or "Stopped"
        log(PROG.stopReason)
    end
    local function start(farm)
        if PROG.running then
            PROG.farm = farm
            PROG.paused = false
            return "Autopilot already running; farm mode " .. (farm and "enabled" or "disabled")
        end
        PROG.running = true
        PROG.paused = false
        PROG.farm = farm
        PROG.token = PROG.token + 1
        PROG.startedAt = os.clock()
        local token = PROG.token
        log("Autopilot started (" .. (farm and "repeating" or "one-pass") .. ", " .. PROG.travel .. ")")
        scanObjectives()
        task.spawn(function()
            while PROG.scanActive and token == PROG.token do task.wait(0.15) end
            local emptySince = os.clock()
            while token == PROG.token and PROG.running do
                if PROG.paused then
                    task.wait(0.25)
                elseif not getRootPosition() then
                    task.wait(0.75)
                elseif goalReached() then
                    stop("Goal reached")
                    say("Goal reached", "Stopped because the tracked statistic reached your goal.")
                    break
                else
                    local pos = getRootPosition()
                    local entry = pos and chooseTarget(pos)
                    if entry then
                        emptySince = os.clock()
                        PROG.current = entry
                        PROG.attempted = PROG.attempted + 1
                        local confirmed, method = attempt(entry, token)
                        if token ~= PROG.token then break end
                        if confirmed then
                            PROG.confirmed = PROG.confirmed + 1
                            PROG.visitCooldown[entry.part] = os.clock() + 12
                            log("CONFIRMED " .. targetName(entry) .. " via " .. tostring(method))
                        elseif confirmed == false then
                            PROG.failed = PROG.failed + 1
                            PROG.visitCooldown[entry.part] = os.clock() + 35
                            log("SKIPPED " .. targetName(entry) .. ": " .. tostring(method))
                        end
                        PROG.current = nil
                        task.wait(0.1)
                    else
                        PROG.current = nil
                        if os.clock() - PROG.scanAt >= (farm and 9 or 20) and not PROG.scanActive then
                            scanObjectives()
                        end
                        if not farm and os.clock() - emptySince > 2.5 and not PROG.scanActive then
                            stop("One-pass finished: no eligible objectives in range")
                            say("Route complete", "Confirmed " .. PROG.confirmed .. " objects; " .. PROG.failed .. " unverified attempts.")
                            break
                        end
                        task.wait(0.6)
                    end
                end
            end
        end)
        return "Autopilot enabled. Progress is counted only after a stat change or target despawn."
    end
    local function register(name, aliases, usage, description, callback)
        if findCmd(name) then
            log("Command name already exists: " .. name)
            return false
        end
        local accepted = {}
        for _, alias in ipairs(aliases or {}) do
            if not findCmd(alias) then table.insert(accepted, alias) end
        end
        addcmd(name, accepted, callback)
        addcmdtext(usage, "NOVA PROGRESSION", description)
        return true
    end
    local function getClosest(limit)
        local root = getRootPosition()
        if not root then return {} end
        local all = {}
        for _, item in pairs(PROG.candidates) do
            if eligible(item) then
                local distance = (root - item.part.Position).Magnitude
                if distance <= PROG.radius then
                    table.insert(all, {entry = item, distance = distance})
                end
            end
        end
        table.sort(all, function(a, b) return a.distance < b.distance end)
        while #all > limit do table.remove(all) end
        return all
    end
    local function getStatus()
        local elapsed = math.max(1, os.clock() - PROG.startedAt)
        local _, tracked = matchingStat(collectStats())
        return string.format(
            "Mode: %s (%s)%s\nTargets: %d   |   Verified: %d   |   Unverified: %d\nRate: %.1f verified/min  |  Radius: %d\nStat: %s%s\nCurrent: %s",
            PROG.running and (PROG.paused and "PAUSED" or "RUNNING") or "STOPPED",
            PROG.category, PROG.farm and " / FARM" or "",
            candidateCount(), PROG.confirmed, PROG.failed,
            PROG.confirmed * 60 / elapsed, PROG.radius,
            PROG.selectedStat ~= "" and PROG.selectedStat or "auto (any observable stat)",
            tracked and (" = " .. string.format("%.3g", tracked)) or "",
            targetName(PROG.current)
        )
    end

    -- Dashboard: no per-frame loops or input capture while hidden.
    local function makeDashboard()
        if PROG.overlay then return PROG.overlay end
        local panel = Instance.new("Frame")
        panel.Name = "NOVA_ProgressionHub"
        panel.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
        panel.BorderSizePixel = 0
        panel.Position = UDim2.new(0, 15, 0.34, 0)
        panel.Size = UDim2.fromOffset(302, 232)
        panel.ZIndex = 90
        panel.Active = true
        panel.Parent = PARENT
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = panel
        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.Position = UDim2.fromOffset(12, 5)
        header.Size = UDim2.new(1, -50, 0, 27)
        header.Text = "NOVA  /  PROGRESSION LAB"
        header.Font = Enum.Font.GothamBold
        header.TextSize = 14
        header.TextColor3 = Color3.fromRGB(128, 189, 255)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 92
        header.Parent = panel
        local close = Instance.new("TextButton")
        close.Text = "×"
        close.TextSize = 22
        close.Font = Enum.Font.Gotham
        close.TextColor3 = Color3.new(1, 1, 1)
        close.BackgroundTransparency = 1
        close.Size = UDim2.fromOffset(30, 28)
        close.Position = UDim2.new(1, -34, 0, 3)
        close.ZIndex = 93
        close.Parent = panel
        close.MouseButton1Click:Connect(function() PROG.overlayVisible = false panel.Visible = false end)
        local detail = Instance.new("TextLabel")
        detail.Name = "Readout"
        detail.BackgroundColor3 = Color3.fromRGB(32, 39, 57)
        detail.BorderSizePixel = 0
        detail.Position = UDim2.fromOffset(10, 38)
        detail.Size = UDim2.new(1, -20, 0, 133)
        detail.Font = Enum.Font.Code
        detail.TextColor3 = Color3.fromRGB(224, 238, 250)
        detail.TextSize = 12
        detail.TextXAlignment = Enum.TextXAlignment.Left
        detail.TextYAlignment = Enum.TextYAlignment.Top
        detail.TextWrapped = true
        detail.Text = "Loading progression status..."
        detail.ZIndex = 92
        detail.Parent = panel
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 7)
        pad.Parent = detail
        local function addButton(textValue, x, width, callback)
            local button = Instance.new("TextButton")
            button.Text = textValue
            button.Font = Enum.Font.GothamMedium
            button.TextSize = 12
            button.TextColor3 = Color3.new(1, 1, 1)
            button.BackgroundColor3 = Color3.fromRGB(52, 69, 99)
            button.BorderSizePixel = 0
            button.Position = UDim2.fromOffset(x, 182)
            button.Size = UDim2.fromOffset(width, 36)
            button.ZIndex = 92
            button.Parent = panel
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = button
            button.MouseButton1Click:Connect(callback)
        end
        addButton("SCAN", 10, 62, function() scanObjectives() end)
        addButton("START", 79, 62, function() say("Autopilot", start(false)) end)
        addButton("FARM", 148, 62, function() say("Farm", start(true)) end)
        addButton("STOP", 217, 74, function() stop("Stopped from dashboard") end)
        PROG.overlay = panel
        task.spawn(function()
            while panel.Parent do
                if PROG.overlayVisible then detail.Text = getStatus() end
                task.wait(0.6)
            end
        end)
        return panel
    end

    register("proghub", {"progresshub"}, "proghub", "Open/close a compact live progression dashboard with scan, start, farm, stop.", function()
        local panel = makeDashboard()
        PROG.overlayVisible = not PROG.overlayVisible
        panel.Visible = PROG.overlayVisible
        return "Progression dashboard " .. (PROG.overlayVisible and "opened" or "hidden")
    end)
    register("progscan", {"objectivescan"}, "progscan", "Asynchronously discover relevant orbs, coins, resources, checkpoints and interactables.", function()
        scanObjectives(function() say("Scan complete", string.format("Found %d possible targets; %d fit your filters.", PROG.scanned, candidateCount())) end)
        return "Scanning the world for observable objectives..."
    end)
    register("proglist", {"objectivefinder"}, "proglist", "Show nearest matching objectives and their approximate distances.", function()
        local items = getClosest(10)
        local lines = {}
        for i, item in ipairs(items) do table.insert(lines, string.format("%d. %s [%s]  %d studs", i, item.entry.label, item.entry.kind, item.distance)) end
        say("Nearby objectives", #lines > 0 and table.concat(lines, "\n") or "None indexed. Try progscan or change progtypes.", 16)
    end)
    register("progtypes", {"objectivetype"}, "progtypes [collect|resource|checkpoint|interact|all]", "Choose which objective category the route engine is permitted to visit.", function(a)
        local requested = cleaned(a[1])
        if not table.find({"collect", "resource", "checkpoint", "interact", "all"}, requested) then return "Choose collect, resource, checkpoint, interact or all." end
        PROG.category = requested; scheduleSave(); refreshMarkers()
        return "Objective type: " .. requested
    end)
    register("progfilter", {}, "progfilter [name|clear]", "Include only objectives whose name/path contains the phrase (use clear to reset).", function(a)
        PROG.filter = cleaned(a[1])
        if PROG.filter == "clear" then PROG.filter = "" end
        scheduleSave(); refreshMarkers()
        return "Name filter: " .. (PROG.filter ~= "" and PROG.filter or "any")
    end)
    register("progignore", {}, "progignore [word]", "Ignore matching objects, e.g. progignore lava or progignore x20.", function(a)
        local phrase = cleaned(a[1])
        if phrase == "" then return "Usage: progignore [word]" end
        if #PROG.ignores >= 20 then return "The ignore list is full (20 patterns)." end
        if not table.find(PROG.ignores, phrase) then table.insert(PROG.ignores, phrase) end
        scheduleSave(); refreshMarkers()
        return "Ignoring objective names that contain: " .. phrase
    end)
    register("progunignore", {}, "progunignore [word]", "Remove an ignored objective keyword.", function(a)
        local phrase = cleaned(a[1])
        for i = #PROG.ignores, 1, -1 do if PROG.ignores[i] == phrase then table.remove(PROG.ignores, i) end end
        scheduleSave(); refreshMarkers()
        return "Removed ignored keyword: " .. phrase
    end)
    register("progclearignore", {}, "progclearignore", "Clear all ignored object name patterns.", function()
        table.clear(PROG.ignores); scheduleSave(); refreshMarkers(); return "Ignore list cleared."
    end)
    register("progradius", {}, "progradius [studs]", "Set objective scanning/route distance from 30 to 5000 studs.", function(a)
        PROG.radius = limitNumber(a[1], PROG.radius, 30, 5000)
        scheduleSave(); refreshMarkers()
        return "Route radius: " .. PROG.radius .. " studs."
    end)
    register("progstrategy", {}, "progstrategy [nearest|adaptive|rarity]", "Nearest route, learned reward-per-time routing, or rare-name priority.", function(a)
        local value = cleaned(a[1])
        if not table.find({"nearest", "adaptive", "rarity"}, value) then return "Choose nearest, adaptive or rarity." end
        PROG.strategy = value; scheduleSave()
        return "Routing strategy: " .. value
    end)
    register("progtravel", {}, "progtravel [teleport|walk]", "Choose how the progression autopilot approaches objectives.", function(a)
        local value = cleaned(a[1])
        if value ~= "teleport" and value ~= "walk" then return "Choose teleport or walk." end
        PROG.travel = value; scheduleSave()
        return "Approach mode: " .. value
    end)
    register("progroute", {}, "progroute", "Preview an optimized nearest-neighbor path without moving your character.", function()
        local position = getRootPosition()
        if not position then return "Character not available." end
        local visited, routes, distance = {}, {}, 0
        for i = 1, 10 do
            -- Pure preview: use a local visited set, do not change the live route state.
            local entry = chooseTarget(position, visited)
            if not entry then break end
            visited[entry.part] = true
            local leg = (entry.part.Position - position).Magnitude
            distance = distance + leg
            table.insert(routes, string.format("%d. %s  (+%d studs)", i, entry.label, leg))
            position = entry.part.Position
        end
        say("Route preview", #routes > 0 and (table.concat(routes, "\n") .. "\nTotal: " .. math.floor(distance) .. " studs (straight line)") or "No eligible targets.", 17)
    end)
    register("proggoto", {"objectivegoto"}, "proggoto [index]", "Move to an indexed objective from proglist without enabling a loop.", function(a)
        local index = math.floor(limitNumber(a[1], 1, 1, 10))
        local items = getClosest(10)
        local entry = items[index] and items[index].entry
        if not entry then return "Objective not found. Run progscan and proglist first." end
        local moved, reason = travelTo(entry, PROG.token)
        return moved and ("Approached: " .. targetName(entry)) or ("Unable to approach: " .. tostring(reason))
    end)
    register("progstart", {"objectiverun"}, "progstart", "One-pass objective autopilot, with confirmed collection and failure quarantine.", function()
        return start(false)
    end)
    register("progfarm", {"objectfarm"}, "progfarm", "Repeat objective discovery and routing as collectibles respawn.", function()
        return start(true)
    end)
    register("progpause", {}, "progpause", "Pause progression after the current interaction.", function()
        PROG.paused = true; return "Autopilot paused."
    end)
    register("progresume", {}, "progresume", "Resume the paused objective autopilot.", function()
        if not PROG.running then return "No active run. Use progstart or progfarm." end
        PROG.paused = false; return "Autopilot resumed."
    end)
    register("progstop", {"unprogfarm"}, "progstop", "Cancel pending movement/interactions and stop the progression loop.", function()
        stop("Stopped by command")
        return "Progression autopilot stopped."
    end)
    register("progstatus", {}, "progstatus", "Show live route status, success confirmation and observed progress.", function()
        return getStatus()
    end)
    register("progstat", {}, "progstat [name|clear]", "Track a specific numeric player stat; set before starting for reliable reward confirmation.", function(a)
        local name = cleaned(a[1])
        if name == "clear" then
            PROG.selectedStat = ""; PROG.goal = nil; table.clear(PROG.samples); scheduleSave()
            return "Tracking any observable numeric player stat."
        end
        if name == "" then
            local names = {}
            for k in pairs(collectStats()) do table.insert(names, k) end
            table.sort(names)
            say("Observable numeric stats", #names > 0 and table.concat(names, "\n") or "No recognized numeric stats available.", 16)
            return nil
        end
        PROG.selectedStat = name
        local actual, value = matchingStat(collectStats())
        table.clear(PROG.samples)
        scheduleSave()
        return actual and ("Tracking " .. actual .. " = " .. tostring(value)) or ("Stat '" .. name .. "' isn't currently observable. Use progstat to list possible names.")
    end)
    register("proggoal", {}, "proggoal [number|clear]", "Automatically stop progression when the tracked statistic reaches an amount.", function(a)
        if cleaned(a[1]) == "clear" then PROG.goal = nil return "Goal disabled." end
        if PROG.selectedStat == "" then return "Choose a stat first: progstat Cash" end
        local amount = tonumber(a[1])
        if not amount or amount ~= amount or math.abs(amount) == math.huge then return "Usage: proggoal [numeric target]" end
        PROG.goal = amount
        return "Run will stop if " .. PROG.selectedStat .. " reaches " .. tostring(amount)
    end)
    register("progforecast", {}, "progforecast", "Estimate time to stat goal using actually observed gains per minute.", function()
        if PROG.selectedStat == "" then return "Select a statistic using progstat [name] first." end
        local _, value = matchingStat(collectStats())
        if value == nil then return "The selected stat isn't observable." end
        local rate = ratePerMinute()
        if not PROG.goal then return string.format("%s = %.4g | observed: %.2f/min. Set proggoal [number] for ETA.", PROG.selectedStat, value, rate) end
        if value >= PROG.goal then return "Goal is already reached." end
        if rate <= 0 then return "No positive measured progress yet; can't estimate ETA." end
        return string.format("Current: %.4g | Goal: %.4g | Gain: %.2f/min | ETA: %.1f minutes", value, PROG.goal, rate, (PROG.goal - value) / rate)
    end)
    register("progverify", {}, "progverify [seconds] [attempts]", "Adjust confirmation timeout and retry budget to handle delayed game rewards.", function(a)
        PROG.verifySeconds = limitNumber(a[1], PROG.verifySeconds, 0.6, 8)
        PROG.attempts = math.floor(limitNumber(a[2], PROG.attempts, 1, 3))
        scheduleSave()
        return string.format("Verification window %.1fs, maximum %d attempts per target.", PROG.verifySeconds, PROG.attempts)
    end)
    register("progmarkers", {"objectiveesp"}, "progmarkers", "Highlight up to 38 nearby possible objectives.", function()
        PROG.markerMode = true; refreshMarkers(); return "Objective markers enabled."
    end)
    register("unprogmarkers", {"unobjectiveesp"}, "unprogmarkers", "Remove all progression objective highlights.", function()
        PROG.markerMode = false; refreshMarkers(); return "Objective markers disabled."
    end)
    register("progcheckpoint", {}, "progcheckpoint", "Save your current position as a local return point.", function()
        local char = getBody()
        if not char then return "Character unavailable." end
        PROG.waypoint = char:GetPivot()
        return "Saved a local return waypoint."
    end)
    register("progback", {}, "progback", "Return to your saved waypoint or previous pre-teleport location.", function()
        local char = getBody()
        if not char then return "Character unavailable." end
        local restore = PROG.waypoint or PROG.lastPosition
        if not restore then return "No return position saved. Use progcheckpoint first." end
        local current = char:GetPivot()
        local ok = pcall(function() char:PivotTo(restore) end)
        if ok then PROG.lastPosition = current end
        return ok and "Returned to saved position (subject to game rules)." or "Return failed."
    end)
    register("proglog", {}, "proglog", "View the latest verification successes, failures and route decisions.", function()
        local lines = {}
        for i = 1, math.min(10, #PROG.log) do table.insert(lines, PROG.log[i]) end
        say("Activity log", #lines > 0 and table.concat(lines, "\n") or "No activity yet.", 16)
    end)
    register("progcopylog", {}, "progcopylog", "Copy progression diagnostics and activity logs to your clipboard if supported.", function()
        if type(everyClipboard) ~= "function" then return "Clipboard API is unavailable." end
        local report = "NOVA Progression Diagnostics\n" .. getStatus() .. "\n" .. table.concat(PROG.log, "\n")
        local ok = pcall(everyClipboard, report)
        return ok and "Progression diagnostics copied." or "Copy failed."
    end)
    register("proglearn", {}, "proglearn", "View the observed reward-rate model used by adaptive routing.", function()
        local lines = {}
        for kind, data in pairs(PROG.learning) do
            table.insert(lines, string.format("%s: %d confirmed, score %.2f", kind, data.count, data.sum / math.max(1, data.count)))
        end
        say("Adaptive model", #lines > 0 and table.concat(lines, "\n") or "No confirmations yet. Successful routes teach the model.")
    end)
    register("progreset", {}, "progreset", "Reset session counters, reward learning, and temporary failed-target quarantines.", function()
        stop("Session stats reset")
        PROG.attempted, PROG.confirmed, PROG.failed = 0, 0, 0
        PROG.visitCooldown = setmetatable({}, {__mode = "k"})
        PROG.learning = {}
        PROG.log = {}
        PROG.startedAt = os.clock()
        table.clear(PROG.samples)
        refreshMarkers()
        return "Progression session data reset. Saved preferences kept."
    end)
    register("progconfig", {}, "progconfig", "Display progression filters, route settings and verification configuration.", function()
        return "Type: " .. PROG.category .. " | Filter: " .. (PROG.filter ~= "" and PROG.filter or "any")
            .. " | Strategy: " .. PROG.strategy .. " | Travel: " .. PROG.travel
            .. " | Radius: " .. PROG.radius .. " | Ignore terms: " .. #PROG.ignores
            .. " | Verify: " .. PROG.verifySeconds .. "s × " .. PROG.attempts
    end)
    register("proghelp", {"progressionhelp"}, "proghelp", "Show progression engine setup and key commands.", function()
        say("Getting started", "1. progscan  →  proglist  →  progmarkers\n"
            .. "2. progtypes collect  →  progfilter orb\n"
            .. "3. progstat Cash  →  proggoal 10000\n"
            .. "4. progstrategy adaptive  →  progfarm\n"
            .. "5. progstatus / proghub / progstop\n"
            .. "Advanced: progverify, progtravel, progignore, progforecast, proglog", 18)
    end)


    -- Resource-agnostic tool scoring. Values come only from visible tool attributes.
    local toolAssist = {enabled = false, metric = "auto", connection = nil, lastEquip = 0}
    local metrics = {power = true, damage = true, multiplier = true, strength = true, level = true, speed = true, rarity = true}
    local function toolScore(tool)
        if not tool or not tool:IsA("Tool") then return -math.huge, "invalid" end
        local best, bestSource = 0, "name fallback"
        local attributes = tool:GetAttributes()
        local weights = {power = 1, damage = 1, multiplier = 1, strength = 1, level = 0.1, speed = 0.5, rarity = 0.2}
        for key, value in pairs(attributes) do
            local lower = cleaned(key)
            local weight = weights[lower]
            if type(value) == "number" and value == value and value >= 0 and weight then
                local score = value * weight
                if toolAssist.metric == lower then score = score * 100 end
                if toolAssist.metric == "auto" or toolAssist.metric == lower then
                    if score > best then best, bestSource = score, "attribute " .. key end
                end
            end
        end
        for _, stat in ipairs(tool:GetChildren()) do
            local lower = cleaned(stat.Name)
            local weight = weights[lower]
            if (stat:IsA("NumberValue") or stat:IsA("IntValue")) and weight then
                local value = stat.Value
                if value == value and value >= 0 and (toolAssist.metric == "auto" or lower == toolAssist.metric) then
                    local score = value * weight * (toolAssist.metric == lower and 100 or 1)
                    if score > best then best, bestSource = score, "value " .. stat.Name end
                end
            end
        end
        if best == 0 and toolAssist.metric == "auto" then
            local lower = cleaned(tool.Name)
            for rank, term in ipairs({"common", "uncommon", "rare", "epic", "legendary", "mythic", "divine"}) do
                if string.find(lower, term, 1, true) then best = rank bestSource = "rarity word" end
            end
        end
        return best, bestSource
    end
    local function rankedTools()
        local char = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        local found = {}
        for _, folder in ipairs({backpack, char}) do
            if folder then
                for _, tool in ipairs(folder:GetChildren()) do
                    if tool:IsA("Tool") then
                        local score, reason = toolScore(tool)
                        table.insert(found, {tool = tool, score = score, source = reason})
                    end
                end
            end
        end
        table.sort(found, function(a, b)
            if a.score == b.score then return a.tool.Name < b.tool.Name end
            return a.score > b.score
        end)
        return found
    end
    local function equipBest()
        local _, hum = getBody()
        if not hum then return "Character unavailable." end
        local ranked = rankedTools()
        local top = ranked[1]
        if not top then return "No tools in your inventory." end
        if top.score <= 0 then return "No meaningful tool stats detected. Use progtoolrank to inspect inventory." end
        if top.tool.Parent == player.Character then return "Already equipped: " .. top.tool.Name end
        local ok = pcall(function() hum:EquipTool(top.tool) end)
        return ok and ("Equipped: " .. top.tool.Name .. " (visible score " .. string.format("%.2f", top.score) .. ")")
            or "Couldn't equip tool; game may restrict equipping."
    end
    local function scheduleEquip()
        local now = os.clock()
        if now - toolAssist.lastEquip < 1.2 then return end
        toolAssist.lastEquip = now
        task.delay(0.2, function()
            if toolAssist.enabled then equipBest() end
        end)
    end
    register("progtoolrank", {}, "progtoolrank", "Rank inventory tools by observable power/damage/multiplier attributes or numeric values.", function()
        local list = rankedTools()
        local output = {}
        for i = 1, math.min(#list, 10) do
            local item = list[i]
            table.insert(output, string.format("%d. %s | %.2f (%s)", i, item.tool.Name, item.score, item.source))
        end
        say("Tool ratings", #output > 0 and table.concat(output, "\n") or "No inventory tools detected.", 16)
    end)
    register("progbesttool", {}, "progbesttool", "Equip the highest-rated owned tool using visible numeric stats.", function()
        return equipBest()
    end)
    register("progtoolmetric", {}, "progtoolmetric [auto|power|damage|multiplier|strength|level|speed|rarity]", "Choose which observable tool property matters most for auto-equipping.", function(a)
        local metric = cleaned(a[1])
        if metric ~= "auto" and not metrics[metric] then return "Choose auto, power, damage, multiplier, strength, level, speed or rarity." end
        toolAssist.metric = metric
        return "Tool scorer now prioritizes " .. metric
    end)
    register("progautotool", {}, "progautotool", "Automatically equip the strongest recognized tool when your backpack changes.", function()
        toolAssist.enabled = true
        if toolAssist.connection then toolAssist.connection:Disconnect() toolAssist.connection = nil end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then toolAssist.connection = backpack.ChildAdded:Connect(scheduleEquip) end
        return "Auto-best-tool enabled. " .. equipBest()
    end)
    register("unprogautotool", {}, "unprogautotool", "Disable automatic owned-tool upgrades and disconnect the backpack listener.", function()
        toolAssist.enabled = false
        if toolAssist.connection then toolAssist.connection:Disconnect() toolAssist.connection = nil end
        return "Auto-best-tool disabled."
    end)

    -- Nearby reward/claim prompts only. We deliberately exclude shops and purchases.
    local claim = {enabled = false, generation = 0, cooldown = setmetatable({}, {__mode = "k"}), tries = 0}
    local function claimNearby()
        local _, _, root = getBody()
        if not root then return 0 end
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {player.Character}
        params.MaxParts = 140
        local ok, nearby = pcall(function() return world:GetPartBoundsInRadius(root.Position, 18, params) end)
        if not ok then return 0 end
        local eligiblePrompts = {}
        for _, part in ipairs(nearby) do
            local title = cleaned(part.Name .. " " .. (part.Parent and part.Parent.Name or ""))
            if matchesAny(title, {"claim", "bonus", "daily", "free", "gift", "reward"}) and
                not matchesAny(title, {"buy", "shop", "robux", "purchase", "product", "donation", "gamepass"}) then
                for _, prompt in ipairs(part:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local promptTitle = cleaned(prompt.Name .. " " .. prompt.ActionText .. " " .. prompt.ObjectText)
                        if not matchesAny(promptTitle, {"buy", "shop", "robux", "purchase", "product", "donation", "gamepass"}) and
                            (claim.cooldown[prompt] or 0) < os.clock() then
                            table.insert(eligiblePrompts, prompt)
                        end
                    end
                end
            end
            if #eligiblePrompts >= 6 then break end
        end
        local count = 0
        for _, prompt in ipairs(eligiblePrompts) do
            if prompt.Parent and prompt.Enabled then
                local anchor = prompt.Parent
                local pos = anchor:IsA("BasePart") and anchor.Position or anchor:IsA("Attachment") and anchor.WorldPosition
                if pos and (root.Position - pos).Magnitude <= prompt.MaxActivationDistance + 2 then
                    claim.cooldown[prompt] = os.clock() + 18
                    pcall(function() prompt:InputHoldBegin() end)
                    task.wait(math.clamp(prompt.HoldDuration + 0.1, 0.1, 3.5))
                    pcall(function() prompt:InputHoldEnd() end)
                    count = count + 1
                    claim.tries = claim.tries + 1
                end
            end
        end
        return count
    end
    register("progclaim", {}, "progclaim", "Attempt eligible nearby free-reward prompts; no purchases or reward guarantees.", function()
        local count = claimNearby()
        return count .. " nearby eligible reward prompt(s) attempted (not guaranteed)."
    end)
    register("progautoclaim", {}, "progautoclaim", "Repeat nearby free-reward prompt checks at modest intervals; avoids purchases.", function()
        if claim.enabled then return "Nearby auto-claim is already enabled." end
        claim.enabled = true
        claim.generation = claim.generation + 1
        local generation = claim.generation
        task.spawn(function()
            while claim.enabled and generation == claim.generation do
                pcall(claimNearby)
                task.wait(5)
            end
        end)
        return "Nearby free-reward auto-claim enabled (checks about every 5 seconds)."
    end)
    register("unprogautoclaim", {}, "unprogautoclaim", "Stop nearby free-reward prompt checks.", function()
        claim.enabled = false
        claim.generation = claim.generation + 1
        return "Nearby auto-claim disabled; " .. claim.tries .. " attempts this session."
    end)
    register("progshutdown", {}, "progshutdown", "Stop all Progression Lab loops, auto-equipping, reward prompts and objective highlights.", function()
        stop("Progression Lab stopped by user")
        claim.enabled = false
        claim.generation = claim.generation + 1
        toolAssist.enabled = false
        if toolAssist.connection then toolAssist.connection:Disconnect() toolAssist.connection = nil end
        PROG.markerMode = false
        refreshMarkers()
        PROG.overlayVisible = false
        if PROG.overlay then PROG.overlay.Visible = false end
        return "All progression background features and highlights shut down."
    end)

    -- Incremental objective discovery avoids full rescans whenever a farm respawns items.
    local lastMarkerUpdate = 0
    world.DescendantAdded:Connect(function(obj)
        if not obj:IsA("BasePart") or PROG.candidates[obj] then return end
        if PROG.indexCount >= PROG.candidateLimit then return end
        local added = {}
        if addCandidate(obj, added) then
            PROG.candidates[obj] = added[obj]
            PROG.indexCount = PROG.indexCount + 1
            if PROG.markerMode and os.clock() - lastMarkerUpdate > 3 then
                lastMarkerUpdate = os.clock()
                task.defer(refreshMarkers)
            end
        end
    end)
    world.DescendantRemoving:Connect(function(obj)
        if PROG.candidates[obj] then
            PROG.candidates[obj] = nil
            PROG.indexCount = math.max(0, PROG.indexCount - 1)
        end
    end)

    -- Track the rate of the selected stat only while the hub or autopilot is in use.
    task.spawn(function()
        while true do
            if PROG.running or PROG.overlayVisible then
                sampleTracked()
            end
            task.wait(2)
        end
    end)
    player.CharacterAdded:Connect(function()
        if PROG.running then
            log("Character respawn detected; autopilot will resume after root becomes ready")
        end
    end)
    IndexContents("", true)
    log("Progression Lab loaded: discover, route, verify and farm")
end

--[[
  INFINITE YIELD NOVA | ADVANCED CHEAT PACK
  Adds bounded, reversible client-side gameplay abilities.
  Client authority is limited: server-validated rewards/stages are not guaranteed.
  No remote discovery, purchases, or anti-cheat evasion.
]]
do
    local plr = Players.LocalPlayer
    local world = workspace
    local runService = RunService
    local inv = plr:FindFirstChildOfClass("Backpack") or plr:WaitForChild("Backpack", 10)
    local controller = {
        generation = {}, active = {}, errors = {},
        toolInterval = 0.25, cycleInterval = 0.6,
        promptFilter = "", clickFilter = "", touchFilter = "",
        promptCooldowns = setmetatable({}, {__mode = "k"}),
        clickCooldowns = setmetatable({}, {__mode = "k"}),
        touchCooldowns = setmetatable({}, {__mode = "k"}),
        phaseOriginals = setmetatable({}, {__mode = "k"}),
        lootHighlights = {}, stageFailures = 0,
        restorableGravity = nil, gravityTarget = nil,
        stats = {tools = 0, prompts = 0, clicks = 0, touches = 0, stages = 0},
    }
    _G.IY_NOVA_ADVANCED = controller
    local added = 0
    local function bounded(v, fallback, minimum, maximum)
        local n = tonumber(v)
        if not n or n ~= n or n == math.huge or n == -math.huge then n = fallback end
        return math.clamp(n, minimum, maximum)
    end
    local function norm(v)
        return tostring(v or ""):lower():sub(1, 65):match("^%s*(.-)%s*$") or ""
    end
    local function charRoot()
        local c = plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and (c:FindFirstChild("HumanoidRootPart") or (h and h.RootPart))
        if c and h and r and h.Health > 0 then return c, h, r end
        return nil
    end
    local function stop(name)
        controller.active[name] = nil
        controller.generation[name] = (controller.generation[name] or 0) + 1
    end
    local function start(name, interval, callback)
        stop(name)
        controller.active[name] = true
        local rev = controller.generation[name]
        task.spawn(function()
            local errors = 0
            while controller.active[name] and controller.generation[name] == rev do
                local ok, err = pcall(callback)
                if not ok then
                    errors = errors + 1
                    controller.errors[name] = tostring(err):sub(1, 110)
                    if errors >= 4 then
                        stop(name)
                        warn("[NOVA Advanced] disabled " .. name .. ": " .. tostring(err))
                        break
                    end
                else
                    errors = 0
                end
                task.wait(interval)
            end
        end)
    end
    local function reg(name, aliases, usage, description, callback)
        if findCmd(name) then return end
        local valid = {}
        for _, alias in ipairs(aliases or {}) do
            if not findCmd(alias) then table.insert(valid, alias) end
        end
        addcmd(name, valid, callback)
        addcmdtext(usage, "NOVA ADVANCED", description)
        added = added + 1
    end
    local function sourceName(inst)
        local parent = inst.Parent
        local grand = parent and parent.Parent
        return norm(inst.Name .. " " .. (parent and parent.Name or "") .. " " .. (grand and grand.Name or ""))
    end
    local forbidden = {"buy", "purchase", "shop", "robux", "gamepass", "product", "donate", "donation", "pay", "upgrade", "premium", "trade", "sell", "delete", "discard", "reset", "rebirth"}
    local function prohibited(s)
        for _, term in ipairs(forbidden) do
            if s:find(term, 1, true) then return true end
        end
        return false
    end
    local function nearby(radius, maxParts)
        local c, _, root = charRoot()
        if not root then return {}, nil end
        local overlap = OverlapParams.new()
        overlap.FilterType = Enum.RaycastFilterType.Exclude
        overlap.FilterDescendantsInstances = {c}
        overlap.MaxParts = maxParts or 250
        local ok, parts = pcall(function()
            return world:GetPartBoundsInRadius(root.Position, radius, overlap)
        end)
        return ok and parts or {}, root
    end
    local function ownedTools()
        local list = {}
        local c = plr.Character
        for _, folder in ipairs({c, inv}) do
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Tool") then table.insert(list, obj) end
                end
            end
        end
        return list
    end
    local function equippedTool()
        local c = plr.Character
        return c and c:FindFirstChildOfClass("Tool")
    end
    local function performTool(tool)
        if not tool or not tool.Parent then return end
        local ok = pcall(function() tool:Activate() end)
        if ok then controller.stats.tools = controller.stats.tools + 1 end
    end

    -- Automatic tools, useful for clicker and collection games exposing a Tool.Activate workflow.
    reg("toolspam", {"autouse"}, "toolspam [interval]", "Auto-activate the equipped tool (0.12-5 seconds).", function(a)
        local interval = bounded(a[1], 0.25, 0.12, 5)
        controller.toolInterval = interval
        stop("toolcycle")
        start("toolspam", interval, function() performTool(equippedTool()) end)
        return string.format("Tool activation enabled every %.2f seconds.", interval)
    end)
    reg("untoolspam", {"unautouse"}, "untoolspam", "Stop automatically activating the equipped tool.", function()
        stop("toolspam")
        return "Automatic tool activation disabled."
    end)
    local cycleIndex = 0
    reg("toolcycle", {}, "toolcycle [interval]", "Cycle through owned tools, equipping and activating each in turn.", function(a)
        local interval = bounded(a[1], 0.65, 0.3, 6)
        controller.cycleInterval = interval
        stop("toolspam")
        cycleIndex = 0
        start("toolcycle", interval, function()
            local _, h = charRoot()
            if not h then return end
            local tools = ownedTools()
            if #tools == 0 then return end
            table.sort(tools, function(a, b) return a.Name < b.Name end)
            cycleIndex = (cycleIndex % #tools) + 1
            local tool = tools[cycleIndex]
            pcall(function() h:EquipTool(tool) end)
            if tool.Parent == plr.Character then performTool(tool) end
        end)
        return "Tool cycling started (" .. interval .. "s)."
    end)
    reg("untoolcycle", {}, "untoolcycle", "Stop tool cycling and activation.", function()
        stop("toolcycle")
        return "Tool cycling disabled."
    end)

    -- Nearby actions: bounded, low-rate, with purchase and destructive action exclusions.
    local function validPrompt(prompt, root, radius)
        if not prompt.Enabled or not prompt.Parent then return false end
        local parent = prompt.Parent
        local pos = parent:IsA("Attachment") and parent.WorldPosition or parent:IsA("BasePart") and parent.Position
        if not pos then return false end
        local dist = (root.Position - pos).Magnitude
        if dist > radius or dist > prompt.MaxActivationDistance + 0.5 then return false end
        local name = sourceName(prompt) .. " " .. norm(prompt.ActionText) .. " " .. norm(prompt.ObjectText)
        if prohibited(name) then return false end
        if controller.promptFilter ~= "" and not name:find(controller.promptFilter, 1, true) then return false end
        return true
    end
    local function promptsInRange(radius, limit)
        local parts, root = nearby(radius, 200)
        if not root then return {}, nil end
        local prompts, seen = {}, {}
        for _, part in ipairs(parts) do
            local items = part:GetDescendants()
            for _, inst in ipairs(items) do
                if inst:IsA("ProximityPrompt") and not seen[inst] then
                    seen[inst] = true
                    if validPrompt(inst, root, radius) then
                        table.insert(prompts, inst)
                        if #prompts >= limit then return prompts, root end
                    end
                end
            end
        end
        return prompts, root
    end
    reg("promptfilter", {}, "promptfilter [keyword|clear]", "Restrict automated prompts by a name/action keyword.", function(a)
        controller.promptFilter = norm(table.concat(a, " "))
        if controller.promptFilter == "clear" then controller.promptFilter = "" end
        return controller.promptFilter == "" and "Prompt filter cleared." or "Prompt filter: " .. controller.promptFilter
    end)
    reg("promptscan", {}, "promptscan [radius]", "List eligible prompts within normal interaction reach.", function(a)
        local radius = bounded(a[1], 14, 4, 32)
        local list = promptsInRange(radius, 12)
        local names = {}
        for _, prompt in ipairs(list) do table.insert(names, prompt.ObjectText ~= "" and prompt.ObjectText or prompt.Name) end
        local message = #names > 0 and table.concat(names, ", ") or "No eligible prompts in reach."
        notify("NOVA / PROMPT SCAN", message:sub(1, 420), 10)
        return "Eligible nearby prompts: " .. #names
    end)
    reg("promptaura", {}, "promptaura [radius] [interval]", "Auto-activate eligible nearby prompts within their normal reach.", function(a)
        local radius = bounded(a[1], 12, 4, 25)
        local interval = bounded(a[2], 1.3, 0.6, 8)
        local queue = {}
        start("promptaura", interval, function()
            local now = os.clock()
            local prompts = promptsInRange(radius, 8)
            for _, prompt in ipairs(prompts) do
                if (controller.promptCooldowns[prompt] or 0) <= now then
                    controller.promptCooldowns[prompt] = now + math.max(4, prompt.HoldDuration + 2)
                    if prompt.HoldDuration <= 2.5 then
                        table.insert(queue, prompt)
                        break
                    end
                end
            end
            if #queue > 0 then
                local prompt = table.remove(queue, 1)
                if prompt and prompt.Parent and prompt.Enabled then
                    pcall(function() prompt:InputHoldBegin() end)
                    task.wait(math.min(prompt.HoldDuration + 0.12, 2.62))
                    pcall(function() prompt:InputHoldEnd() end)
                    controller.stats.prompts = controller.stats.prompts + 1
                end
            end
        end)
        return "Prompt aura started (normal reach only; purchase/destructive prompts skipped)."
    end)
    reg("unpromptaura", {}, "unpromptaura", "Disable automatic nearby prompt activation.", function()
        stop("promptaura")
        return "Prompt aura stopped."
    end)

    local clickAPI = type(fireclickdetector) == "function" and fireclickdetector or nil
    local function clickables(radius, maxCount)
        local parts, root = nearby(radius, 180)
        if not root then return {} end
        local list, found = {}, {}
        for _, part in ipairs(parts) do
            for _, item in ipairs(part:GetDescendants()) do
                if item:IsA("ClickDetector") and not found[item] then
                    found[item] = true
                    local text = sourceName(item)
                    local anchor = item.Parent
                    local dist = anchor:IsA("BasePart") and (anchor.Position - root.Position).Magnitude or 1e9
                    if dist <= radius and dist <= item.MaxActivationDistance + 0.5
                        and not prohibited(text)
                        and (controller.clickFilter == "" or text:find(controller.clickFilter, 1, true)) then
                        table.insert(list, item)
                        if #list >= maxCount then return list end
                    end
                end
            end
        end
        return list
    end
    reg("clickfilter", {}, "clickfilter [keyword|clear]", "Restrict ClickDetector automation to matching names.", function(a)
        controller.clickFilter = norm(table.concat(a, " "))
        if controller.clickFilter == "clear" then controller.clickFilter = "" end
        return controller.clickFilter == "" and "Click filter cleared." or "Click filter: " .. controller.clickFilter
    end)
    reg("clickscan", {}, "clickscan [radius]", "Count nearby ClickDetectors reachable by the player.", function(a)
        local targets = clickables(bounded(a[1], 15, 4, 32), 30)
        return #targets .. " eligible nearby ClickDetector(s)."
    end)
    reg("clickaura", {}, "clickaura [radius] [interval]", "Trigger nearby eligible ClickDetectors if supported by executor.", function(a)
        if not clickAPI then return "Executor does not provide fireclickdetector." end
        local radius = bounded(a[1], 13, 4, 30)
        local interval = bounded(a[2], 1, 0.35, 8)
        start("clickaura", interval, function()
            local now = os.clock()
            for _, item in ipairs(clickables(radius, 12)) do
                if (controller.clickCooldowns[item] or 0) <= now then
                    controller.clickCooldowns[item] = now + 2
                    local ok = pcall(clickAPI, item)
                    if ok then controller.stats.clicks = controller.stats.clicks + 1 end
                    break
                end
            end
        end)
        return "Click aura enabled; targets must be in reach."
    end)
    reg("unclickaura", {}, "unclickaura", "Stop automatic ClickDetector activation.", function()
        stop("clickaura")
        return "Click aura stopped."
    end)

    local touchAPI = type(firetouchinterest) == "function" and firetouchinterest or nil
    local pickupTerms = {"orb", "coin", "gem", "star", "token", "pickup", "loot", "collect", "drop", "crystal", "chest", "reward"}
    local function touchables(radius, cap)
        local parts, root = nearby(radius, 250)
        if not root then return {}, nil end
        local results = {}
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") and part.CanTouch then
                local name = sourceName(part)
                local matching = controller.touchFilter ~= "" and name:find(controller.touchFilter, 1, true) ~= nil
                if controller.touchFilter == "" then
                    for _, token in ipairs(pickupTerms) do
                        if name:find(token, 1, true) then matching = true break end
                    end
                end
                if matching and not prohibited(name) and part ~= root and (part.Position - root.Position).Magnitude <= radius then
                    table.insert(results, part)
                    if #results >= cap then break end
                end
            end
        end
        return results, root
    end
    reg("touchfilter", {}, "touchfilter [keyword|clear]", "Restrict collectible-touch automation to a named item type.", function(a)
        controller.touchFilter = norm(table.concat(a, " "))
        if controller.touchFilter == "clear" then controller.touchFilter = "" end
        return controller.touchFilter == "" and "Default collectible categories enabled." or "Touch filter: " .. controller.touchFilter
    end)
    reg("touchscan", {}, "touchscan [radius]", "Count nearby likely collectibles that could respond to touch.", function(a)
        local radius = bounded(a[1], 12, 3, 28)
        local parts = touchables(radius, 50)
        return #parts .. " likely collectible part(s) within " .. radius .. " studs."
    end)
    reg("touchaura", {}, "touchaura [radius] [interval]", "Attempt touch collection on nearby named collectibles if supported.", function(a)
        if not touchAPI then return "Executor does not provide firetouchinterest." end
        local radius = bounded(a[1], 10, 3, 20)
        local interval = bounded(a[2], 0.9, 0.35, 8)
        start("touchaura", interval, function()
            local parts, root = touchables(radius, 15)
            if not root then return end
            local now = os.clock()
            local used = 0
            for _, part in ipairs(parts) do
                if (controller.touchCooldowns[part] or 0) < now then
                    controller.touchCooldowns[part] = now + 3
                    local ok = pcall(function()
                        touchAPI(root, part, 0)
                        touchAPI(root, part, 1)
                    end)
                    if ok then controller.stats.touches = controller.stats.touches + 1 end
                    used = used + 1
                    if used >= 3 then break end
                end
            end
        end)
        return "Collectible touch aura started; rewards depend on game/server logic."
    end)
    reg("untouchaura", {}, "untouchaura", "Disable collectible touch aura.", function()
        stop("touchaura")
        return "Collectible touch aura disabled."
    end)

    -- Movement locks: resilient across respawns, with explicit disable options.
    local oldSpeed, oldJump, oldGravity
    reg("speedlock", {}, "speedlock [walkspeed]", "Keep local WalkSpeed at a chosen value (8-130).", function(a)
        local value = bounded(a[1], 32, 8, 130)
        oldSpeed = nil
        start("speedlock", 0.25, function()
            local _, h = charRoot()
            if h then
                if oldSpeed == nil then oldSpeed = h.WalkSpeed end
                if math.abs(h.WalkSpeed - value) > 0.01 then h.WalkSpeed = value end
            end
        end)
        return "WalkSpeed lock enabled at " .. value .. "."
    end)
    reg("unspeedlock", {}, "unspeedlock", "Disable WalkSpeed lock and restore saved WalkSpeed.", function()
        stop("speedlock")
        local _, h = charRoot()
        if h and oldSpeed then pcall(function() h.WalkSpeed = oldSpeed end) end
        oldSpeed = nil
        return "WalkSpeed lock disabled."
    end)
    reg("jumplock", {}, "jumplock [power]", "Keep local jump strength at a chosen value.", function(a)
        local value = bounded(a[1], 80, 15, 200)
        oldJump = nil
        start("jumplock", 0.25, function()
            local _, h = charRoot()
            if h then
                if oldJump == nil then oldJump = {use = h.UseJumpPower, power = h.JumpPower, height = h.JumpHeight} end
                if h.UseJumpPower then h.JumpPower = value else h.JumpHeight = math.clamp(value / 10, 2, 35) end
            end
        end)
        return "Jump lock enabled at " .. value .. " (game jump mode respected)."
    end)
    reg("unjumplock", {}, "unjumplock", "Disable Jump lock and restore original local jump settings.", function()
        stop("jumplock")
        local _, h = charRoot()
        if h and oldJump then
            pcall(function()
                h.UseJumpPower = oldJump.use
                h.JumpPower = oldJump.power
                h.JumpHeight = oldJump.height
            end)
        end
        oldJump = nil
        return "Jump lock disabled."
    end)
    reg("gravitylock", {}, "gravitylock [gravity]", "Continuously enforce local gravity (0-196.2).", function(a)
        local target = bounded(a[1], 70, 0, 196.2)
        if oldGravity == nil then oldGravity = world.Gravity end
        controller.gravityTarget = target
        start("gravitylock", 0.25, function()
            if math.abs(world.Gravity - target) > 0.01 then world.Gravity = target end
        end)
        return "Local gravity lock enabled at " .. target .. "."
    end)
    reg("ungravitylock", {}, "ungravitylock", "Disable gravity lock and restore the previous gravity.", function()
        stop("gravitylock")
        if oldGravity then pcall(function() world.Gravity = oldGravity end) end
        oldGravity = nil
        controller.gravityTarget = nil
        return "Gravity lock disabled."
    end)
    reg("antistun", {}, "antistun", "Attempt recovery from local stun, sitting and PlatformStand states.", function()
        start("antistun", 0.35, function()
            local _, h = charRoot()
            if not h then return end
            if h.PlatformStand then h.PlatformStand = false end
            local state = h:GetState()
            if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll then
                h:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        return "Anti-stun enabled; server-enforced stuns may still apply."
    end)
    reg("unantistun", {}, "unantistun", "Disable anti-stun monitoring.", function()
        stop("antistun")
        return "Anti-stun disabled."
    end)
    reg("autovault", {}, "autovault [distance]", "Auto-jump toward short obstacles when the space above is clear.", function(a)
        local distance = bounded(a[1], 3.7, 2, 7)
        local lastJump = 0
        start("autovault", 0.15, function()
            local c, h, root = charRoot()
            if not c or h.FloorMaterial == Enum.Material.Air or os.clock() - lastJump < 0.7 then return end
            if h.MoveDirection.Magnitude < 0.35 then return end
            local direction = h.MoveDirection.Unit
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {c}
            local forward = world:Raycast(root.Position - Vector3.new(0, 1, 0), direction * distance, params)
            if not forward then return end
            local overhead = world:Raycast(root.Position + Vector3.new(0, 2.5, 0), direction * distance, params)
            if not overhead then
                lastJump = os.clock()
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        return "Automatic obstacle vaulting enabled."
    end)
    reg("unautovault", {}, "unautovault", "Disable automatic obstacle jumps.", function()
        stop("autovault")
        return "Auto-vault disabled."
    end)

    -- Gate phasing is intentionally selective: touching floors should remain walkable.
    local phaseName, phaseRadius = "gate", 15
    local function restorePhase()
        for part, original in pairs(controller.phaseOriginals) do
            if part and part.Parent then pcall(function() part.CanCollide = original end) end
            controller.phaseOriginals[part] = nil
        end
    end
    reg("phasegate", {}, "phasegate [keyword] [radius]", "Make nearby named gates/doors locally non-collidable.", function(a)
        phaseName = norm(a[1])
        if phaseName == "" then phaseName = "gate" end
        if #phaseName < 3 then return "Use a keyword of at least 3 characters." end
        phaseRadius = bounded(a[2], 15, 5, 45)
        restorePhase()
        start("phasegate", 0.5, function()
            local parts = nearby(phaseRadius, 300)
            local seen = {}
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") and sourceName(part):find(phaseName, 1, true) then
                    seen[part] = true
                    if controller.phaseOriginals[part] == nil then controller.phaseOriginals[part] = part.CanCollide end
                    if part.CanCollide then part.CanCollide = false end
                end
            end
            for part, wasCollidable in pairs(controller.phaseOriginals) do
                if not seen[part] then
                    if part.Parent then pcall(function() part.CanCollide = wasCollidable end) end
                    controller.phaseOriginals[part] = nil
                end
            end
        end)
        return "Local phase enabled for nearby objects matching: " .. phaseName
    end)
    reg("unphasegate", {}, "unphasegate", "Restore collision settings changed by phasegate.", function()
        stop("phasegate")
        restorePhase()
        return "Local gate phasing disabled and collisions restored."
    end)

    -- Highlight containers / loot chests that tool ESP doesn't cover.
    local glowTokens = {"chest", "crate", "treasure", "loot", "safe", "vault", "supply", "rare", "legendary", "mythic"}
    local function clearGlow()
        for object, highlight in pairs(controller.lootHighlights) do
            pcall(function() highlight:Destroy() end)
            controller.lootHighlights[object] = nil
        end
    end
    reg("lootglow", {}, "lootglow [radius]", "Highlight nearby chests, loot crates and rare resources.", function(a)
        local radius = bounded(a[1], 180, 25, 600)
        clearGlow()
        start("lootglow", 2, function()
            local parts, root = nearby(radius, 700)
            if not root then return end
            local seen = {}
            local count = 0
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") then
                    local name = sourceName(part)
                    local okName = false
                    for _, token in ipairs(glowTokens) do
                        if name:find(token, 1, true) then okName = true break end
                    end
                    local target = part.Parent and part.Parent:IsA("Model") and part.Parent or part
                    if okName and not prohibited(name) and not seen[target] then
                        seen[target] = true
                        if not controller.lootHighlights[target] then
                            local hi = Instance.new("Highlight")
                            hi.Name = "NOVA_AdvancedLootGlow"
                            hi.Adornee = target
                            hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hi.FillColor = Color3.fromRGB(255, 184, 70)
                            hi.OutlineColor = Color3.fromRGB(255, 239, 165)
                            hi.FillTransparency = 0.8
                            hi.Parent = target
                            controller.lootHighlights[target] = hi
                        end
                        count = count + 1
                        if count >= 70 then break end
                    end
                end
            end
            for target, hi in pairs(controller.lootHighlights) do
                if not target.Parent or not seen[target] then
                    pcall(function() hi:Destroy() end)
                    controller.lootHighlights[target] = nil
                end
            end
        end)
        return "Loot glow enabled (up to 70 nearby targets)."
    end)
    reg("unlootglow", {}, "unlootglow", "Remove chest / loot highlighting.", function()
        stop("lootglow")
        clearGlow()
        return "Loot highlights removed."
    end)

    -- Rescue from a local collision trap, with conservative displacement checks.
    local lastPosition, stillSince = nil, 0
    reg("autounstuck", {}, "autounstuck", "Move slightly upward after 3 seconds stuck while walking.", function()
        lastPosition, stillSince = nil, 0
        start("autounstuck", 0.5, function()
            local c, h, root = charRoot()
            if not c then lastPosition = nil return end
            if h.MoveDirection.Magnitude < 0.4 or h.FloorMaterial == Enum.Material.Air then
                lastPosition, stillSince = root.Position, 0
                return
            end
            if lastPosition and (root.Position - lastPosition).Magnitude < 0.65 then
                if stillSince == 0 then stillSince = os.clock() end
                if os.clock() - stillSince >= 3 then
                    root.CFrame = root.CFrame + Vector3.new(0, 3.5, 0)
                    stillSince = 0
                end
            else
                lastPosition, stillSince = root.Position, 0
            end
        end)
        return "Auto-unstuck enabled."
    end)
    reg("unautounstuck", {}, "unautounstuck", "Stop automatic unstuck attempts.", function()
        stop("autounstuck")
        lastPosition, stillSince = nil, 0
        return "Auto-unstuck disabled."
    end)

    -- Checkpoint assistance: require a readable Stage stat and visible map parts.
    local stageCache = {}
    local stagePrefixes = {"checkpoint", "stage", "level"}
    local function stageFromName(str)
        str = norm(str)
        for _, prefix in ipairs(stagePrefixes) do
            local n = str:match("^" .. prefix .. "[%s_%-]*(%d+)$")
            if n then return tonumber(n) end
        end
        return nil
    end
    local function refreshStages()
        table.clear(stageCache)
        local visited = 0
        for _, obj in ipairs(world:GetDescendants()) do
            visited = visited + 1
            if visited > 26000 then break end
            if obj:IsA("BasePart") then
                local n = stageFromName(obj.Name) or (obj.Parent and obj.Parent:IsA("Model") and stageFromName(obj.Parent.Name))
                if n and n >= 0 and n < 5000 and not stageCache[n] then stageCache[n] = obj end
            end
            if visited % 1200 == 0 then task.wait() end
        end
        local count = 0
        for _ in pairs(stageCache) do count = count + 1 end
        return count
    end
    local function getStage()
        for _, folder in ipairs({plr:FindFirstChild("leaderstats"), plr:FindFirstChild("Data"), plr}) do
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    if v:IsA("IntValue") or v:IsA("NumberValue") then
                        local name = norm(v.Name)
                        if name == "stage" or name == "checkpoint" or name == "level" then
                            return v.Value, v
                        end
                    end
                end
            end
        end
        return nil
    end
    local function moveToStage(n)
        local c, _, root = charRoot()
        local target = stageCache[n]
        if not c or not target or not target.Parent then return false end
        root.CFrame = CFrame.new(target.Position + Vector3.new(0, math.max(target.Size.Y / 2 + 3, 4), 0))
        return true
    end
    reg("stagefinder", {}, "stagefinder", "Scan for numbered checkpoint parts and display the current Stage stat.", function()
        local count = refreshStages()
        local current = getStage()
        return string.format("Found %d numbered stages. Reported stage: %s.", count, tostring(current or "not available"))
    end)
    reg("stageteleport", {"stp"}, "stageteleport [number|next]", "Locally move to a discovered numbered checkpoint.", function(a)
        if next(stageCache) == nil then refreshStages() end
        local stage = getStage()
        local target = norm(a[1]) == "next" and (stage and math.floor(stage) + 1) or tonumber(a[1])
        if not target or target < 0 or target > 4999 then return "Usage: stageteleport [checkpoint number|next]." end
        if moveToStage(math.floor(target)) then return "Moved locally to visible stage " .. math.floor(target) .. "." end
        return "Checkpoint part not found. Try stagefinder."
    end)
    reg("stageassist", {}, "stageassist", "Attempt the next visible stage; continue only after Stage stat increases.", function()
        local stage = getStage()
        if type(stage) ~= "number" then return "No numeric Stage/Checkpoint/Level stat found." end
        if next(stageCache) == nil then refreshStages() end
        controller.stageFailures = 0
        local pending, lastStage = nil, stage
        start("stageassist", 3.5, function()
            local current = getStage()
            if type(current) ~= "number" then stop("stageassist") return end
            if pending then
                if current > lastStage then
                    controller.stats.stages = controller.stats.stages + (current - lastStage)
                    controller.stageFailures = 0
                    pending = nil
                else
                    controller.stageFailures = controller.stageFailures + 1
                    if controller.stageFailures >= 2 then stop("stageassist") return end
                end
            end
            lastStage = current
            local n = math.floor(current) + 1
            if not stageCache[n] or not stageCache[n].Parent then refreshStages() end
            local _, _, root = charRoot()
            local part = stageCache[n]
            if part and root and (part.Position - root.Position).Magnitude < 300 then
                pending = n
                moveToStage(n)
            else
                stop("stageassist")
            end
        end)
        return "Stage assist enabled. It stops after repeated unverified checkpoint attempts."
    end)
    reg("unstageassist", {}, "unstageassist", "Stop checkpoint progression assistance.", function()
        stop("stageassist")
        return "Stage assist disabled."
    end)

    reg("cheatstatus", {}, "cheatstatus", "Show active advanced cheats, attempted actions and errors.", function()
        local active = {}
        for name, enabled in pairs(controller.active) do
            if enabled then table.insert(active, name) end
        end
        table.sort(active)
        local count = controller.stats
        local text = string.format("Active: %s\nTool uses: %d | Prompt attempts: %d | Clicks: %d | Touches: %d | Stages: %d",
            #active == 0 and "none" or table.concat(active, ", "),
            count.tools, count.prompts, count.clicks, count.touches, count.stages)
        notify("NOVA ADVANCED STATUS", text, 12)
        return text
    end)
    local function shutdown()
        local keys = {}
        for name in pairs(controller.active) do table.insert(keys, name) end
        for _, name in ipairs(keys) do stop(name) end
        restorePhase()
        clearGlow()
        if oldGravity then pcall(function() world.Gravity = oldGravity end) end
        oldGravity = nil
        local _, h = charRoot()
        if h then
            if oldSpeed then pcall(function() h.WalkSpeed = oldSpeed end) end
            if oldJump then
                pcall(function()
                    h.UseJumpPower = oldJump.use
                    h.JumpPower = oldJump.power
                    h.JumpHeight = oldJump.height
                end)
            end
        end
        oldSpeed, oldJump = nil, nil
    end
    reg("cheatshutdown", {}, "cheatshutdown", "Stop every advanced-cheat loop, restore changed physics and remove highlights.", function()
        shutdown()
        return "Advanced cheats disabled; tracked local physics restored."
    end)
    reg("cheathelp", {"advancedcheats"}, "cheathelp", "Show the new advanced cheat categories and sample commands.", function()
        notify("NOVA ADVANCED", "Tools: toolspam, toolcycle\nInteractions: promptaura, clickaura, touchaura (+ filters/scans)\nMovement: speedlock, jumplock, gravitylock, antistun, autovault, phasegate, autounstuck\nProgress: lootglow, stagefinder, stageteleport, stageassist\nControl: cheatstatus, cheatshutdown", 16)
        return "Use F2 / Ctrl+K to search advanced cheats, or cheatstatus to inspect active modules."
    end)
    -- Ensure no loops from the new pack remain active after the player leaves the game.
    plr.AncestryChanged:Connect(function(_, parent)
        if parent == nil then shutdown() end
    end)
    IndexContents("", true)
    if _G.IY_DEBUG then print("[NOVA Advanced] Registered", added, "commands") end
end

--[[ NOVA STUDIO | exploration, navigation and command UX (client-side only) ]]
do
    local plr = Players.LocalPlayer
    local runtime = {beacon = nil, beaconConnection = nil, pathToken = 0,
        pathRunning = false, burstToken = 0, burstSpeed = nil,
        status = "Idle"}
    _G.IY_NOVA_STUDIO = runtime
    local newCommands = 0
    local function register(name, aliases, usage, detail, callback)
        if findCmd(name) then
            if _G.IY_DEBUG then warn("[NOVA Studio] Existing name: " .. name) end
            return
        end
        local valid = {}
        for _, alias in ipairs(aliases or {}) do
            if not findCmd(alias) then table.insert(valid, alias) end
        end
        addcmd(name, valid, callback)
        addcmdtext(usage, "NOVA STUDIO", detail)
        newCommands = newCommands + 1
    end
    local function root()
        local char = plr.Character
        return char and char:FindFirstChild("HumanoidRootPart"), char
    end
    local function meHumanoid()
        local char = plr.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end
    local function nameOf(inst)
        return tostring(inst.Name or ""):lower()
    end
    local function visibleTarget(inst)
        return inst and inst:IsA("BasePart") and inst:IsDescendantOf(workspace)
            and not (plr.Character and inst:IsDescendantOf(plr.Character))
    end
    local function collectible(inst)
        local name = nameOf(inst)
        return name:find("orb", 1, true) or name:find("coin", 1, true)
            or name:find("gem", 1, true) or name:find("token", 1, true)
            or name:find("loot", 1, true) or name:find("chest", 1, true)
            or name:find("pickup", 1, true) or name:find("reward", 1, true)
    end
    local function findNearby(keyword, radius, onlyCollectibles)
        local rp = root()
        if not rp then return {} end
        local list = {}
        keyword = tostring(keyword or ""):lower()
        radius = math.clamp(tonumber(radius) or 250, 10, 1200)
        local visited = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            visited = visited + 1
            if visited > 50000 then break end -- no infinite unbounded scans
            if visibleTarget(obj) and (keyword == "" or nameOf(obj):find(keyword, 1, true))
                and (not onlyCollectibles or collectible(obj)) then
                local dist = (obj.Position - rp.Position).Magnitude
                if dist <= radius then
                    table.insert(list, {part=obj, distance=dist})
                end
            end
        end
        table.sort(list, function(a, b) return a.distance < b.distance end)
        return list
    end
    local function ui(section)
        local api = _G.IY_NOVA_UI
        if api and type(api.open) == "function" then api.open(section) return true end
        return false
    end
    register("novahome", {"novacenter", "novastudio"}, "novahome", "Open the redesigned NOVA command center.", function()
        ui("All")
    end)
    register("novacore", {}, "novacore", "Show only original Infinite Yield commands.", function()
        ui("Infinite Yield")
    end)
    register("novanew", {}, "novanew", "Show all added NOVA commands, separate from IY.", function()
        ui("NOVA Additions")
    end)
    register("novascope", {"novascout"}, "novascope [radius]", "Scan local world interactables, items and objectives.", function(args)
        local rp = root()
        if not rp then return "Character not ready." end
        local radius = math.clamp(tonumber(args[1]) or 150, 15, 900)
        local out = {parts=0, collectibles=0, prompts=0, detectors=0, tools=0}
        local n = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            n = n + 1
            if n > 50000 then break end
            if obj:IsA("BasePart") and (obj.Position-rp.Position).Magnitude <= radius then
                out.parts = out.parts + 1
                if collectible(obj) then out.collectibles = out.collectibles + 1 end
            elseif obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") or obj:IsA("Tool") then
                local ancestor = obj.Parent
                local pos = ancestor and (ancestor:IsA("BasePart") and ancestor.Position
                    or ancestor:IsA("Model") and ancestor:GetPivot().Position)
                if pos and (pos-rp.Position).Magnitude <= radius then
                    if obj:IsA("ProximityPrompt") then out.prompts = out.prompts + 1
                    elseif obj:IsA("ClickDetector") then out.detectors = out.detectors + 1
                    else out.tools = out.tools + 1 end
                end
            end
        end
        return string.format("Within %d studs: %d parts, %d collectibles, %d prompts, %d click detectors, %d tools.",
            radius, out.parts, out.collectibles, out.prompts, out.detectors, out.tools)
    end)
    register("novanear", {"novapickups"}, "novanear [radius] [name]", "Show the closest 8 collectible-like objects with distances.", function(args)
        local radius = math.clamp(tonumber(args[1]) or 250, 10, 1200)
        local keyword = table.concat(args, " ", 2)
        local items = findNearby(keyword, radius, true)
        if #items == 0 then return "No matching collectible-like objects nearby." end
        local lines = {}
        for i = 1, math.min(8, #items) do
            local entry = items[i]
            lines[i] = string.format("%d. %s  (%.0f studs)", i, entry.part.Name:sub(1, 35), entry.distance)
        end
        notify("NOVA / NEARBY OBJECTIVES (" .. #items .. ")", table.concat(lines, "\n"), 16)
    end)
    local function stopBeacon()
        if runtime.beaconConnection then runtime.beaconConnection:Disconnect(); runtime.beaconConnection = nil end
        if runtime.beacon then runtime.beacon:Destroy(); runtime.beacon = nil end
    end
    register("novabeacon", {"trackobject"}, "novabeacon [object name]", "Highlight the nearest named world object and show distance.", function(args)
        local key = table.concat(args, " ")
        if key == "" then return "Usage: novabeacon [object name]" end
        local near = findNearby(key, 1200, false)
        if #near == 0 then return "No matching world object within 1200 studs." end
        stopBeacon()
        local part = near[1].part
        local gui = Instance.new("BillboardGui")
        gui.Name = "NOVA_Beacon"
        gui.Adornee = part
        gui.AlwaysOnTop = true
        gui.Size = UDim2.fromOffset(190, 52)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
        gui.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(16, 24, 42)
        label.BackgroundTransparency = 0.18
        label.TextColor3 = Color3.fromRGB(238, 246, 255)
        label.TextSize = 13
        label.Font = Enum.Font.GothamBold
        label.TextWrapped = true
        label.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = label
        local line = Instance.new("UIStroke")
        line.Color = Color3.fromRGB(101, 157, 255)
        line.Thickness = 1.5
        line.Parent = label
        runtime.beacon = gui
        local elapsed = 0
        runtime.beaconConnection = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.35 then return end
            elapsed = 0
            local rp = root()
            if not gui.Parent or not part:IsDescendantOf(workspace) then stopBeacon(); return end
            local dist = rp and (rp.Position - part.Position).Magnitude or 0
            label.Text = "◆ " .. part.Name:sub(1, 26) .. "\n" .. math.floor(dist) .. " STUDS"
        end)
        return "Beacon tracking " .. part.Name .. " (local visual only)."
    end)
    register("unnovabeacon", {"untrackobject"}, "unnovabeacon", "Remove the objective beacon and its update connection.", function()
        stopBeacon()
        return "Beacon removed."
    end)
    register("novapath", {"novawalkto"}, "novapath [object name]", "Pathfind on foot to the nearest named world object.", function(args)
        local key = table.concat(args, " ")
        if key == "" then return "Usage: novapath [object name]" end
        if runtime.pathRunning then return "Navigation is already running. Use unnovapath first." end
        local near = findNearby(key, 800, false)
        if #near == 0 then return "No matching object within 800 studs." end
        local target = near[1].part
        runtime.pathToken = runtime.pathToken + 1
        local token = runtime.pathToken
        runtime.pathRunning = true
        runtime.status = "Pathfinding to " .. target.Name
        task.spawn(function()
            local ok, err = pcall(function()
                local rp = root()
                local hum = meHumanoid()
                if not rp or not hum then return end
                local path = PathService:CreatePath({AgentCanJump=true})
                path:ComputeAsync(rp.Position, target.Position)
                if token ~= runtime.pathToken or path.Status ~= Enum.PathStatus.Success then
                    runtime.status = "No safe walkable path"
                    return
                end
                for _, point in ipairs(path:GetWaypoints()) do
                    if token ~= runtime.pathToken or hum.Health <= 0 then break end
                    if point.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                    hum:MoveTo(point.Position)
                    -- MoveToFinished:Wait() is not cancellable; poll with a
                    -- distance-based timeout so unnovapath reacts immediately.
                    local waypointStart = os.clock()
                    local initialDistance = (rp.Position - point.Position).Magnitude
                    local timeout = math.clamp(initialDistance / math.max(4, hum.WalkSpeed) + 2, 3, 13)
                    local reached = false
                    while token == runtime.pathToken and hum.Parent and hum.Health > 0 do
                        if not rp.Parent then break end
                        if (rp.Position - point.Position).Magnitude <= 3.5 then
                            reached = true
                            break
                        end
                        if os.clock() - waypointStart > timeout then break end
                        task.wait(0.08)
                    end
                    if token ~= runtime.pathToken or not reached then
                        if token == runtime.pathToken then runtime.status = "Path blocked or timed out" end
                        break
                    end
                end
                if token == runtime.pathToken then runtime.status = "Navigation finished" end
            end)
            if not ok then runtime.status = "Navigation error: " .. tostring(err):sub(1, 70) end
            if token == runtime.pathToken then runtime.pathRunning = false end
        end)
        return "Walking toward " .. target.Name .. ". Use unnovapath to stop."
    end)
    register("unnovapath", {"novapathstop"}, "unnovapath", "Cancel the current smart navigation route.", function()
        runtime.pathToken = runtime.pathToken + 1
        runtime.pathRunning = false
        local hum = meHumanoid()
        local rp = root()
        if hum and rp then pcall(function() hum:MoveTo(rp.Position) end) end
        runtime.status = "Navigation cancelled"
        return runtime.status
    end)
    register("novastatview", {"novaleaderstats"}, "novastatview", "Show the numeric statistics currently visible to the client.", function()
        local statFolder = plr:FindFirstChild("leaderstats")
        if not statFolder then return "No leaderstats folder was found." end
        local values = {}
        for _, item in ipairs(statFolder:GetChildren()) do
            if item:IsA("ValueBase") then
                table.insert(values, item.Name .. ": " .. tostring(item.Value):sub(1, 30))
            end
        end
        table.sort(values)
        if #values == 0 then return "leaderstats has no directly visible ValueBase entries." end
        notify("NOVA / CURRENT STATS", table.concat(values, "\n"):sub(1, 750), 13)
    end)
    register("novatoolview", {"novainventory"}, "novatoolview", "Inspect all equipped and backpack tools at once.", function()
        local entries = {}
        local char = plr.Character
        local backpack = plr:FindFirstChildOfClass("Backpack")
        for _, holder in ipairs({char, backpack}) do
            if holder then
                for _, item in ipairs(holder:GetChildren()) do
                    if item:IsA("Tool") then
                        local a = item:GetAttributes()
                        local attrs = {}
                        for k,v in pairs(a) do
                            if type(v) == "number" then table.insert(attrs, tostring(k) .. "=" .. tostring(v)) end
                            if #attrs >= 2 then break end
                        end
                        table.insert(entries, (holder==char and "[E] " or "[B] ")
                            .. item.Name:sub(1, 27) .. (#attrs>0 and " (" .. table.concat(attrs, ",") .. ")" or ""))
                    end
                end
            end
        end
        if #entries == 0 then return "No tools found in inventory." end
        table.sort(entries)
        notify("NOVA / INVENTORY (" .. #entries .. ")", table.concat(entries, "\n"):sub(1, 820), 14)
    end)
    register("novaspeedburst", {"novaburst"}, "novaspeedburst [speed] [seconds]", "Apply a short local sprint burst, then restore speed.", function(args)
        local hum = meHumanoid()
        if not hum then return "Character is not ready." end
        local speed = math.clamp(tonumber(args[1]) or 35, 16, 75)
        local duration = math.clamp(tonumber(args[2]) or 3, 0.5, 12)
        runtime.burstToken = runtime.burstToken + 1
        local token = runtime.burstToken
        local original = runtime.burstSpeed or hum.WalkSpeed
        runtime.burstSpeed = original
        hum.WalkSpeed = speed
        task.delay(duration, function()
            if token == runtime.burstToken then
                -- Restore only the humanoid that received the temporary boost.
                if hum.Parent and hum == meHumanoid() then hum.WalkSpeed = original end
                runtime.burstSpeed = nil
            end
        end)
        return string.format("Local sprint burst: %.0f speed for %.1fs", speed, duration)
    end)
    register("unnovaburst", {"novaburststop"}, "unnovaburst", "End a temporary NOVA speed burst and restore speed.", function()
        runtime.burstToken = runtime.burstToken + 1
        local hum = meHumanoid()
        if hum and runtime.burstSpeed then hum.WalkSpeed = runtime.burstSpeed end
        runtime.burstSpeed = nil
        return "Sprint burst stopped."
    end)
    register("novacmdcount", {"novasources"}, "novacmdcount", "Count original IY commands separately from NOVA additions.", function()
        local api = _G.IY_NOVA_UI
        if api and api.counts then
            local original, added = api.counts()
            return string.format("Infinite Yield: %d commands | NOVA: %d additions | Total: %d", original, added, original + added)
        end
        return "Command provenance is unavailable."
    end)
    register("novastudiostatus", {}, "novastudiostatus", "Show navigation, beacon and short-burst status.", function()
        return string.format("Navigation: %s | Beacon: %s | Burst: %s",
            runtime.status, runtime.beacon and "on" or "off", runtime.burstSpeed and "on" or "off")
    end)
    register("novastopall", {"novastudioshutdown"}, "novastopall", "Stop Studio navigation, beacons and movement bursts.", function()
        runtime.pathToken = runtime.pathToken + 1
        runtime.pathRunning = false
        local hum = meHumanoid()
        local rp = root()
        if hum and rp then pcall(function() hum:MoveTo(rp.Position) end) end
        stopBeacon()
        runtime.burstToken = runtime.burstToken + 1
        if hum and runtime.burstSpeed then hum.WalkSpeed = runtime.burstSpeed end
        runtime.burstSpeed = nil
        runtime.status = "Stopped"
        return "All NOVA Studio activity stopped."
    end)
    -- A temporary speed lease must not affect the replacement character.
    plr.CharacterAdded:Connect(function()
        runtime.burstToken = runtime.burstToken + 1
        runtime.burstSpeed = nil
        runtime.pathToken = runtime.pathToken + 1
        runtime.pathRunning = false
        runtime.status = "Character respawned; navigation cancelled"
    end)
    -- Remove local adornments and stop loops if the character/session exits.
    plr.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            runtime.pathToken = runtime.pathToken + 1
            runtime.burstToken = runtime.burstToken + 1
            stopBeacon()
        end
    end)
    IndexContents("", true)
    if _G.IY_NOVA_UI and _G.IY_NOVA_UI.refresh then _G.IY_NOVA_UI.refresh() end
    if _G.IY_DEBUG then print("[NOVA Studio] Registered", newCommands, "commands") end
end


--[[
 NOVA UNIVERSAL REBUILD | 2026-11
 Post-registration command upgrade and audit layer.
 Command definitions remain available under their original names and aliases.
 The protective wrapper instruments every command individually; explicit rewrites
 below fix commands with confirmed correctness/performance problems.
 No attempt is made to bypass server-side game authority.
]]
do
    local RB = {
        version = "2.0.0", started = os.clock(), commands = {}, logs = {},
        patches = {}, wrapped = {}, connections = {}, states = {},
        cap = 140, auditCount = 0, patchCount = 0
    }
    _G.IY_NOVA_REBUILD = RB

    local me = Players.LocalPlayer
    local function log(name, err)
        table.insert(RB.logs, 1, {name = tostring(name), error = tostring(err), at = os.time()})
        if #RB.logs > 70 then table.remove(RB.logs) end
        local shared = _G.IY_NOVA_ERRORS
        if type(shared) ~= "table" then shared = {}; _G.IY_NOVA_ERRORS = shared end
        table.insert(shared, 1, {command = tostring(name), message = tostring(err), timestamp = os.time()})
        if #shared > 60 then table.remove(shared) end
        if _G.IY_DEBUG then warn("[NOVA rebuild]", name, err) end
    end
    local function disconnect(which)
        local old = RB.connections[which]
        RB.connections[which] = nil
        if old then pcall(function() old:Disconnect() end) end
    end
    local function human(player)
        player = player or me
        local char = player and player.Character
        return char and char:FindFirstChildWhichIsA("Humanoid"), char
    end
    local function root(player)
        local _, char = human(player)
        return char and (getRoot(char) or char:FindFirstChild("HumanoidRootPart"))
    end
    local function finite(raw, default, low, high, label)
        if raw == nil or raw == "" then return default end
        local n = tonumber(raw)
        if not n or n ~= n or n == math.huge or n == -math.huge then
            return nil, (label or "Number") .. " must be finite and numeric."
        end
        if low and (n < low or n > high) then
            return nil, string.format("%s must be between %s and %s.", label or "Number", tostring(low), tostring(high))
        end
        return n
    end
    local function withHumanoid(args, player, label, default, low, high, property)
        local hum = human(player)
        if not hum then return "A live character with a Humanoid is required." end
        local number, issue = finite(args[1], default, low, high, label)
        if not number then return issue end
        hum[property] = number
        return string.format("%s: %g", label, number)
    end
    local function stateType(raw)
        if raw == nil then return nil end
        local wanted = tostring(raw):lower()
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
            if state.Name:lower() == wanted or tostring(state.Value) == wanted then return state end
        end
        return nil
    end
    local function patch(name, reason, implementation)
        local cmd = findCmd(name)
        if not cmd or tostring(cmd.NAME):lower() ~= name:lower() then
            log("patch:" .. name, "Missing command")
            return
        end
        cmd.FUNC = implementation
        RB.patches[name] = reason
        RB.patchCount = RB.patchCount + 1
    end
    local function note(name, text)
        if not RB.commands[name] then RB.commands[name] = {calls = 0, failures = 0, totalMs = 0, worstMs = 0} end
        RB.commands[name].note = text
    end

    -- BUGFIX 01: the original numeric callbacks pass raw string arguments to
    -- property setters.  All rewrites convert and validate before assignment.
    patch("speed", "typed WalkSpeed; preserve optional second-argument syntax", function(args, player)
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local number, err = finite(args[2] or args[1], 16, 0, 5000, "WalkSpeed")
        if not number then return err end
        hum.WalkSpeed = number
        return "WalkSpeed set to " .. tostring(number)
    end)
    patch("jpower", "validate and use Humanoid jump mode", function(args, player)
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local number, err = finite(args[1], hum.UseJumpPower and 50 or 7.2, 0, 1000, "Jump")
        if not number then return err end
        if hum.UseJumpPower then hum.JumpPower = number else hum.JumpHeight = number end
        return "Jump set to " .. tostring(number)
    end)
    patch("gravity", "finite, bounded gravity", function(args)
        local number, err = finite(args[1], oldgrav or 196.2, 0, 10000, "Gravity")
        if not number then return err end
        workspace.Gravity = number
        return "Gravity set to " .. tostring(number)
    end)
    patch("hipheight", "nil-safe rig-aware hip height", function(args, player)
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local default = hum.RigType == Enum.HumanoidRigType.R15 and 2.1 or 0
        local number, err = finite(args[1], default, -50, 500, "HipHeight")
        if not number then return err end
        hum.HipHeight = number
        return "HipHeight set to " .. tostring(number)
    end)
    patch("maxslopeangle", "numeric property safety", function(args, player)
        return withHumanoid(args, player, "MaxSlopeAngle", 89, 0, 89, "MaxSlopeAngle")
    end)
    patch("fov", "valid numeric FOV", function(args)
        local camera = workspace.CurrentCamera
        if not camera then return "No active camera." end
        local value, err = finite(args[1], 70, 1, 120, "FieldOfView")
        if not value then return err end
        camera.FieldOfView = value
        return "FOV set to " .. tostring(value)
    end)
    patch("brightness", "typed brightness with range checks", function(args)
        local value, err = finite(args[1], 2, 0, 10, "Brightness")
        if not value then return err end
        Lighting.Brightness = value
        return "Brightness set to " .. tostring(value)
    end)
    patch("ambient", "accept normalized colors or RGB values", function(args)
        local rgb = {}
        for i = 1, 3 do
            local number, err = finite(args[i], nil, 0, 255, "RGB channel")
            if not number then return err or "Usage: ambient [r] [g] [b]" end
            rgb[i] = number
        end
        local color
        if math.max(rgb[1], rgb[2], rgb[3]) <= 1 then
            color = Color3.new(rgb[1], rgb[2], rgb[3])
        else
            color = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        end
        Lighting.Ambient, Lighting.OutdoorAmbient = color, color
        return "Ambient color applied."
    end)
    patch("maxzoom", "keep camera min/max valid", function(args, player)
        player = player or me
        local n, err = finite(args[1], 128, 0.5, 1000, "Maximum zoom")
        if not n then return err end
        if player.CameraMinZoomDistance > n then player.CameraMinZoomDistance = n end
        player.CameraMaxZoomDistance = n
        return "Maximum zoom: " .. tostring(n)
    end)
    patch("minzoom", "keep camera min/max valid", function(args, player)
        player = player or me
        local n, err = finite(args[1], 0.5, 0.5, 1000, "Minimum zoom")
        if not n then return err end
        if player.CameraMaxZoomDistance < n then player.CameraMaxZoomDistance = n end
        player.CameraMinZoomDistance = n
        return "Minimum zoom: " .. tostring(n)
    end)
    patch("camdistance", "validate and restore camera zoom correctly", function(args, player)
        player = player or me
        local n, err = finite(args[1], 10, 0.5, 1000, "Camera distance")
        if not n then return err end
        local oldMin, oldMax = player.CameraMinZoomDistance, player.CameraMaxZoomDistance
        player.CameraMinZoomDistance = math.min(oldMin, n)
        player.CameraMaxZoomDistance = math.max(oldMax, n)
        player.CameraMinZoomDistance = n
        player.CameraMaxZoomDistance = n
        -- Original command temporarily locks the camera; restore in the same task.
        task.wait()
        player.CameraMinZoomDistance = math.min(oldMin, oldMax)
        player.CameraMaxZoomDistance = math.max(oldMin, oldMax)
        return "Camera distance updated."
    end)
    patch("mousesensitivity", "finite mouse sensitivity", function(args)
        local n, err = finite(args[1], 1, 0.01, 10, "Mouse sensitivity")
        if not n then return err end
        UserInputService.MouseDeltaSensitivity = n
        return "Mouse sensitivity: " .. tostring(n)
    end)
    patch("tweenspeed", "finite tween duration", function(args)
        local n, err = finite(args[1], 1, 0.05, 600, "Tween duration")
        if not n then return err end
        tweenSpeed = n
        return "Tween duration: " .. tostring(n)
    end)
    patch("freecamspeed", "numeric camera movement speed", function(args)
        local n, err = finite(args[1], 1, 0.1, 200, "Freecam speed")
        if not n then return err end
        NAV_KEYBOARD_SPEED = Vector3.new(n, n, n)
        return "Freecam speed: " .. tostring(n)
    end)
    patch("enablestate", "correct Enum lookup and avoid local shadowing", function(args, player)
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local state = stateType(args[1])
        if not state then return "Usage: enablestate [valid HumanoidStateType]" end
        hum:SetStateEnabled(state, true)
        return "Enabled state: " .. state.Name
    end)
    patch("disablestate", "correct Enum lookup and avoid local shadowing", function(args, player)
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local state = stateType(args[1])
        if not state then return "Usage: disablestate [valid HumanoidStateType]" end
        hum:SetStateEnabled(state, false)
        return "Disabled state: " .. state.Name
    end)
    patch("setfpscap", "fix invalid 'none' handling; check API support", function(args)
        if type(setfpscap) ~= "function" then return "setfpscap API unavailable in this environment." end
        local text = tostring(args[1] or "60"):lower()
        local value, err
        if text == "none" or text == "unlimited" then value = 1000
        else value, err = finite(text, 60, 10, 1000, "FPS cap") end
        if not value then return err end
        local ok, failure = pcall(setfpscap, value)
        if not ok then return "FPS cap failed: " .. tostring(failure) end
        return text == "none" and "FPS cap released (1000)." or "FPS cap: " .. tostring(value)
    end)

    -- BUGFIX 02: no duplicate lifecycle listeners, and proper restoration of
    -- original CanCollide states instead of setting every recorded part to true.
    local collisions = setmetatable({}, {__mode = "k"})
    local function stopNoclip()
        disconnect("noclip")
        if Noclipping then pcall(function() Noclipping:Disconnect() end) end
        Noclipping = nil
        Clip = true
        for part, previous in pairs(collisions) do
            if part.Parent and part:IsA("BasePart") then
                pcall(function() part.CanCollide = previous end)
            end
            collisions[part] = nil
        end
    end
    patch("noclip", "stateful collision restoration and one loop", function(args, player)
        stopNoclip()
        Clip = false
        Noclipping = RunService.Stepped:Connect(function()
            local char = player and player.Character
            if Clip or not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide and part.Name ~= floatName then
                    if collisions[part] == nil then collisions[part] = part.CanCollide end
                    part.CanCollide = false
                end
            end
        end)
        RB.connections.noclip = Noclipping
        if args[1] ~= "nonotify" then return "Noclip enabled." end
    end)
    patch("unnoclip", "restore exact prior collision states", function(args)
        stopNoclip()
        if args[1] ~= "nonotify" then return "Noclip disabled; original collisions restored." end
    end)
    patch("togglenoclip", "direct toggle without asynchronous races", function(args, player)
        local fn = findCmd(Clip and "noclip" or "unnoclip")
        if fn and fn.FUNC then return fn.FUNC(args, player) end
    end)

    -- BUGFIX 03: remove recursive listener registration and render-frame scans.
    patch("autorejoin", "single error listener with duplicate prevention", function()
        disconnect("autorejoin")
        local lastTry = 0
        RB.connections.autorejoin = GuiService.ErrorMessageChanged:Connect(function(message)
            if type(message) ~= "string" or message == "" then return end
            if os.clock() - lastTry < 12 then return end
            lastTry = os.clock()
            execCmd("rejoin")
        end)
        return "Auto rejoin enabled (one listener)."
    end)
    if not findCmd("unautorejoin") then
        addcmd("unautorejoin", {"noautorejoin", "unautorj"}, function()
            disconnect("autorejoin")
            return "Auto rejoin disabled."
        end)
        addcmdtext("unautorejoin", "NOVA REBUILD", "Stop automatic reconnect attempts and clean up its listener.")
    end

    patch("infjump", "respawn-safe JumpRequest listener", function(args, player)
        disconnect("infjump")
        if infJump then pcall(function() infJump:Disconnect() end) end
        local busy = false
        infJump = UserInputService.JumpRequest:Connect(function()
            if busy then return end
            local hum = human(player)
            if not hum or hum.Health <= 0 then return end
            busy = true
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            task.delay(0.08, function() busy = false end)
        end)
        RB.connections.infjump = infJump
        return "Infinite jump enabled."
    end)
    patch("uninfjump", "disconnect JumpRequest reliably", function()
        disconnect("infjump")
        if infJump then pcall(function() infJump:Disconnect() end) end
        infJump = nil
        return "Infinite jump disabled."
    end)
    patch("autojump", "raycast on a throttled heartbeat", function(args, player)
        disconnect("autojump")
        if HumanModCons then
            for _, key in ipairs({"ajLoop", "ajCA"}) do
                if HumanModCons[key] then pcall(function() HumanModCons[key]:Disconnect() end); HumanModCons[key] = nil end
            end
        end
        local elapsed = 0
        RB.connections.autojump = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.12 then return end
            elapsed = 0
            local hum = human(player)
            local anchor = root(player)
            if not hum or not anchor or hum.Health <= 0 then return end
            if hum.MoveDirection.Magnitude < 0.05 then return end
            local settings = RaycastParams.new()
            settings.FilterType = Enum.RaycastFilterType.Exclude
            settings.FilterDescendantsInstances = {player.Character}
            local hit = workspace:Raycast(anchor.Position + Vector3.new(0, -1.2, 0), hum.MoveDirection * 3, settings)
            if hit then hum.Jump = true end
        end)
        return "Autojump enabled."
    end)
    patch("unautojump", "guaranteed connection cleanup", function()
        disconnect("autojump")
        if HumanModCons then
            for _, key in ipairs({"ajLoop", "ajCA"}) do
                if HumanModCons[key] then pcall(function() HumanModCons[key]:Disconnect() end); HumanModCons[key] = nil end
            end
        end
        return "Autojump disabled."
    end)
    patch("loopfullbright", "reduce 60Hz lighting mutations to a low-frequency loop", function()
        RB.states.bright = (RB.states.bright or 0) + 1
        local token = RB.states.bright
        if brightLoop then pcall(function() brightLoop:Disconnect() end); brightLoop = nil end
        task.spawn(function()
            while RB.states.bright == token do
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                task.wait(0.35)
            end
        end)
        return "Fullbright loop enabled (throttled)."
    end)
    patch("unloopfullbright", "cancel fullbright token", function()
        RB.states.bright = (RB.states.bright or 0) + 1
        if brightLoop then pcall(function() brightLoop:Disconnect() end); brightLoop = nil end
        return "Fullbright loop disabled."
    end)
    patch("antivoid", "bounded void detection and no duplicate Stepped hook", function(args, player)
        disconnect("antivoid")
        if antivoidloop then pcall(function() antivoidloop:Disconnect() end) end
        local lastSave = 0
        antivoidloop = RunService.Stepped:Connect(function()
            local hrp = root(player)
            if not hrp or os.clock() - lastSave < 0.35 then return end
            if hrp.Position.Y < workspace.FallenPartsDestroyHeight + 30 then
                lastSave = os.clock()
                hrp.AssemblyLinearVelocity = Vector3.new(
                    hrp.AssemblyLinearVelocity.X,
                    math.max(hrp.AssemblyLinearVelocity.Y, 150),
                    hrp.AssemblyLinearVelocity.Z)
            end
        end)
        RB.connections.antivoid = antivoidloop
        if args[1] ~= "nonotify" then return "Anti-void enabled." end
    end)
    patch("unantivoid", "clean up anti-void loop", function(args)
        disconnect("antivoid")
        if antivoidloop then pcall(function() antivoidloop:Disconnect() end) end
        antivoidloop = nil
        if args[1] ~= "nonotify" then return "Anti-void disabled." end
    end)
    patch("teleportwalk", "valid speed and one Heartbeat loop", function(args, player)
        disconnect("teleportwalk")
        if tpwalking then pcall(function() tpwalking:Disconnect() end) end
        local amount, err = finite(args[1], 1, 0, 200, "Teleport-walk speed")
        if not amount then return err end
        local hum = human(player)
        if not hum then return "Humanoid unavailable." end
        local additive = parseBoolean(args[2], false)
        if additive then tpwalkStack = math.clamp((tpwalkStack or 0) + amount, 0, 200)
        else tpwalkStack = 0 end
        tpwalking = RunService.Heartbeat:Connect(function(dt)
            local humanNow = human(player)
            local part = root(player)
            if not humanNow or not part or humanNow.Health <= 0 then return end
            if humanNow.MoveDirection.Magnitude < 0.01 then return end
            local distance = (amount + (tpwalkStack or 0)) * math.clamp(dt, 0, 0.06)
            part.CFrame = part.CFrame + humanNow.MoveDirection * distance
        end)
        RB.connections.teleportwalk = tpwalking
        return "Teleport walk enabled."
    end)
    patch("unteleportwalk", "nil-safe teleport-walk stop", function()
        disconnect("teleportwalk")
        if tpwalking then pcall(function() tpwalking:Disconnect() end) end
        tpwalking = nil
        tpwalkStack = 0
        return "Teleport walk disabled."
    end)

    -- BUGFIX 04: correct precedence in selective interaction queries. Avoid
    -- accidentally calling an API on unrelated Instances with matching parents.
    local function interactionObjects(class, args)
        local results = {}
        local needle = table.concat(args or {}, " "):lower()
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA(class) and (needle == "" or
                item.Name:lower() == needle or
                (item.Parent and item.Parent.Name:lower() == needle)) then
                table.insert(results, item)
                if #results >= 2000 then break end
            end
        end
        return results
    end
    patch("fireclickdetectors", "filter only actual ClickDetectors", function(args)
        if type(fireclickdetector) ~= "function" then return "fireclickdetector is unavailable." end
        local matched, fired = interactionObjects("ClickDetector", args), 0
        for _, part in ipairs(matched) do
            if part.Parent and pcall(fireclickdetector, part) then fired = fired + 1 end
            if fired % 30 == 0 then task.wait() end
        end
        return "Click detectors triggered: " .. fired .. " / " .. #matched
    end)
    patch("fireproximityprompts", "filter only ProximityPrompts and guard failures", function(args)
        if type(fireproximityprompt) ~= "function" then return "fireproximityprompt is unavailable." end
        local matched, fired = interactionObjects("ProximityPrompt", args), 0
        for _, item in ipairs(matched) do
            if item.Parent and pcall(fireproximityprompt, item) then fired = fired + 1 end
            if fired % 30 == 0 then task.wait() end
        end
        return "Proximity prompts triggered: " .. fired .. " / " .. #matched
    end)
    patch("touchinterests", "correct touch sender and protect nil parents", function(args, player)
        if type(firetouchinterest) ~= "function" then return "firetouchinterest is unavailable." end
        local hrp = root(player)
        if not hrp then return "Character root unavailable." end
        local objs = interactionObjects("TouchTransmitter", args)
        local count = 0
        for _, touch in ipairs(objs) do
            local part = touch.Parent
            if part and part:IsA("BasePart") then
                local ok = pcall(function()
                    firetouchinterest(hrp, part, 0)
                    firetouchinterest(hrp, part, 1)
                end)
                if ok then count = count + 1 end
                if count % 35 == 0 then task.wait() end
            end
        end
        return "Touch transmitters processed: " .. count .. " / " .. #objs
    end)
    patch("instantproximityprompts", "single active prompt listener", function()
        disconnect("instantprompts")
        if PromptButtonHoldBegan then pcall(function() PromptButtonHoldBegan:Disconnect() end) end
        if type(fireproximityprompt) ~= "function" then return "fireproximityprompt is unavailable." end
        PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(item)
            if item and item.Parent then pcall(fireproximityprompt, item) end
        end)
        RB.connections.instantprompts = PromptButtonHoldBegan
        return "Instant prompts enabled."
    end)
    patch("uninstantproximityprompts", "disconnect instant prompt handler", function()
        disconnect("instantprompts")
        if PromptButtonHoldBegan then pcall(function() PromptButtonHoldBegan:Disconnect() end) end
        PromptButtonHoldBegan = nil
        return "Instant prompts disabled."
    end)

    -- BUGFIX 05: choose exactly one nearest matching target. The original
    -- implementation teleports through *every* same-named part/model.
    local function findNearest(class, query, player)
        query = tostring(query or ""):lower()
        if query == "" then return nil end
        local origin = root(player)
        if not origin then return nil end
        local chosen, best = nil, math.huge
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA(class) and item.Name:lower() == query then
                local point = item:IsA("BasePart") and item.Position or item:GetPivot().Position
                local distance = (point - origin.Position).Magnitude
                if distance < best then best, chosen = distance, item end
            end
        end
        return chosen
    end
    local function moveToNamed(class, args, player)
        local query = table.concat(args or {}, " ")
        if query == "" then return "Provide an object name." end
        local part = findNearest(class, query, player)
        if not part then return "No matching " .. class .. " named '" .. query .. "'." end
        local hrp = root(player)
        if not hrp then return "Character root unavailable." end
        local cf = part:IsA("BasePart") and part.CFrame or part:GetPivot()
        local hum = human(player)
        if hum and hum.SeatPart then hum.Sit = false; task.wait(0.1) end
        hrp.CFrame = cf + Vector3.new(0, 3, 0)
        return "Moved to " .. part:GetFullName()
    end
    patch("gotopart", "nearest match, nil safety, no repeated teleports", function(args, player)
        return moveToNamed("BasePart", args, player)
    end)
    patch("gotomodel", "nearest model, Pivot APIs, nil safety", function(args, player)
        return moveToNamed("Model", args, player)
    end)
    patch("mouseteleport", "correct CFrame construction and preserve orientation", function(args, player)
        local hrp = root(player)
        if not hrp then return "Character root unavailable." end
        local hit = IYMouse and IYMouse.Hit
        if not hit then return "Mouse is not targeting a point." end
        hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * hrp.CFrame.Rotation
        return "Teleported to cursor."
    end)
    patch("notools", "nil-safe inventory deletion", function(args, player)
        local removed = 0
        local function clean(container)
            if not container then return end
            for _, item in ipairs(container:GetDescendants()) do
                if item:IsA("Tool") or item:IsA("HopperBin") then
                    item:Destroy()
                    removed = removed + 1
                end
            end
        end
        clean(player and player:FindFirstChildOfClass("Backpack"))
        clean(player and player.Character)
        return "Removed " .. removed .. " tools."
    end)
    patch("antifling", "0.2-second selective monitoring and collision restoration", function(args, player)
        disconnect("antifling")
        if antifling then pcall(function() antifling:Disconnect() end) end
        RB.states.antiFlingParts = RB.states.antiFlingParts or setmetatable({}, {__mode = "k"})
        local elapsed = 0
        antifling = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.20 then return end
            elapsed = 0
            local myRoot = root(player)
            if not myRoot then return end
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and other.Character then
                    local otherRoot = root(other)
                    if otherRoot and (otherRoot.Position - myRoot.Position).Magnitude < 50
                        and otherRoot.AssemblyLinearVelocity.Magnitude > 85 then
                        for _, part in ipairs(other.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                RB.states.antiFlingParts[part] = true
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end)
        RB.connections.antifling = antifling
        return "Anti-fling enabled (adaptive scan)."
    end)
    patch("unantifling", "restore changed collisions and disconnect", function()
        disconnect("antifling")
        if antifling then pcall(function() antifling:Disconnect() end) end
        antifling = nil
        for part in pairs(RB.states.antiFlingParts or {}) do
            if part.Parent then pcall(function() part.CanCollide = true end) end
        end
        RB.states.antiFlingParts = nil
        return "Anti-fling disabled."
    end)

    -- BUGFIX 06: history and auto-click tasks used to fail on empty input or
    -- duplicate executor callbacks.  Both are now explicitly cancellable.
    patch("lastcommand", "empty-history guard and recursion prevention", function()
        local last = cmdHistory and cmdHistory[1]
        if type(last) ~= "string" or last == "" then return "No previously executed command." end
        local name = last:match("^%s*(%S+)")
        if name == "lastcommand" or name == "lastcmd" then return "Cannot repeat lastcommand recursively." end
        execCmd(last, me, false)
        return "Repeated previous command."
    end)
    patch("notifyping", "nil-safe one-way and round-trip latency reporting", function(args, player)
        local ok, value = pcall(function() return (player or me):GetNetworkPing() end)
        if not ok or type(value) ~= "number" then return "Ping data unavailable." end
        return string.format("Network latency: %.0f ms one-way (about %.0f ms round trip)", value * 1000, value * 2000)
    end)
    patch("autoclick", "bounded auto-click delay and single active task", function(args)
        if type(mouse1press) ~= "function" or type(mouse1release) ~= "function" then
            return "Click simulation API unavailable."
        end
        local delayClick, err = finite(args[1], 0.10, 0.03, 5, "Click interval")
        if not delayClick then return err end
        local delayRelease, err2 = finite(args[2], 0.05, 0.03, 5, "Release interval")
        if not delayRelease then return err2 end
        RB.states.autoClickToken = (RB.states.autoClickToken or 0) + 1
        local token = RB.states.autoClickToken
        autoclicking = true
        disconnect("autoclickHotkey")
        RB.connections.autoclickHotkey = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            local key = input.KeyCode
            if (key == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals))
                or (key == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
                RB.states.autoClickToken = RB.states.autoClickToken + 1
                autoclicking = false
                disconnect("autoclickHotkey")
            end
        end)
        task.spawn(function()
            while autoclicking and RB.states.autoClickToken == token do
                local ok = pcall(mouse1press)
                task.wait(delayRelease)
                pcall(mouse1release)
                if not ok then
                    autoclicking = false
                    RB.states.autoClickToken = RB.states.autoClickToken + 1
                    break
                end
                task.wait(delayClick)
            end
        end)
        return "Autoclick enabled; use unautoclick to stop."
    end)
    patch("unautoclick", "stop clicks and restore released mouse state", function()
        RB.states.autoClickToken = (RB.states.autoClickToken or 0) + 1
        autoclicking = false
        disconnect("autoclickHotkey")
        if cancelAutoClick then pcall(function() cancelAutoClick:Disconnect() end); cancelAutoClick = nil end
        if type(mouse1release) == "function" then pcall(mouse1release) end
        return "Autoclick disabled."
    end)
    patch("fullbright", "consistent lighting preset", function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        return "Fullbright applied."
    end)
    patch("freezeunanchored", "avoid anchoring character parts and keep undo state", function()
        RB.states.frozenParts = RB.states.frozenParts or setmetatable({}, {__mode = "k"})
        local total, scanned = 0, 0
        for _, item in ipairs(workspace:GetDescendants()) do
            scanned = scanned + 1
            if item:IsA("BasePart") and not item.Anchored
                and not (me.Character and item:IsDescendantOf(me.Character)) then
                if RB.states.frozenParts[item] == nil then
                    RB.states.frozenParts[item] = false
                    item.Anchored = true
                    total = total + 1
                end
            end
            if scanned % 250 == 0 then task.wait() end
        end
        return "Anchored " .. total .. " previously unanchored parts (local)."
    end)
    patch("thawunanchored", "restore only parts changed by freezeunanchored", function()
        local total = 0
        for item, previous in pairs(RB.states.frozenParts or {}) do
            if item.Parent and item:IsA("BasePart") then
                item.Anchored = previous
                total = total + 1
            end
        end
        RB.states.frozenParts = nil
        return "Restored " .. total .. " anchored parts."
    end)

    -- Every registered command, including the original 430+ and all prior NOVA
    -- additions, is wrapped with its OWN metrics, diagnostics and safe dispatch.
    -- The underlying command implementation is retained unless explicitly
    -- replaced above; wrapping is not a claim that all underlying logic is rewritten.
    function RB.wrap(command)
        if type(command) ~= "table" then return false end
        if type(command.NAME) ~= "string" or type(command.FUNC) ~= "function" then
            log("registry", "Invalid command registration")
            return false
        end
        if RB.wrapped[command] and RB.wrapped[command] == command.FUNC then return true end
        local old = command.FUNC
        local name = command.NAME:lower()
        local stat = RB.commands[name]
        if not stat then
            stat = {calls = 0, failures = 0, totalMs = 0, worstMs = 0, lastError = "", lastRun = 0}
            RB.commands[name] = stat
        end
        local wrapped = function(args, speaker)
            args = type(args) == "table" and args or {}
            speaker = speaker or me
            local started = os.clock()
            local okay, result = pcall(old, args, speaker)
            local duration = math.max(0, (os.clock() - started) * 1000)
            stat.calls = stat.calls + 1
            stat.totalMs = stat.totalMs + duration
            stat.worstMs = math.max(stat.worstMs, duration)
            stat.lastRun = os.time()
            if not okay then
                stat.failures = stat.failures + 1
                stat.lastError = tostring(result):sub(1, 400)
                log(name, result)
                -- Do not turn exceptions into apparent successes. The dispatcher
                -- catches this and stops repeated commands after three failures.
                error("[NOVA:" .. name .. "] " .. tostring(result), 0)
            end
            return result
        end
        command.FUNC = wrapped
        RB.wrapped[command] = wrapped
        RB.auditCount = RB.auditCount + 1
        return true
    end
    function RB.audit()
        local found = {}
        local issues = {}
        local count, inspected = 0, 0
        for _, command in ipairs(cmds) do
            local name = tostring(command.NAME or ""):lower()
            if name == "" or type(command.FUNC) ~= "function" then
                table.insert(issues, "Invalid registration at " .. tostring(count + 1))
            else
                inspected = inspected + 1
                if found[name] then table.insert(issues, "Duplicate name: " .. name) end
                found[name] = name
                RB.wrap(command)
            end
            count = count + 1
        end
        local aliasOwners = {}
        for _, command in ipairs(cmds) do
            for _, alias in ipairs(type(command.ALIAS) == "table" and command.ALIAS or {}) do
                alias = tostring(alias):lower()
                if aliasOwners[alias] and aliasOwners[alias] ~= command.NAME then
                    table.insert(issues, "Alias conflict: " .. alias)
                end
                aliasOwners[alias] = command.NAME
            end
        end
        RB.lastAudit = {total = count, checked = inspected, issues = issues, patched = RB.patchCount}
        return RB.lastAudit
    end
    _G.IY_NOVA_REBUILD_HOOK = function(command)
        if RB and RB.wrap then RB.wrap(command) end
    end

    local function register(name, aliases, usage, description, func)
        if findCmd(name) then return end
        addcmd(name, aliases or {}, func)
        addcmdtext(usage or name, "NOVA REBUILD", description)
    end
    register("nvaudit", {"nvcmdcheck"}, "nvaudit", "Check all registered command records and alias conflicts.", function()
        local result = RB.audit()
        return string.format("Checked %d/%d commands; %d individual corrections; %d registry warnings. Use nvissues to inspect.",
            result.checked, result.total, RB.patchCount, #result.issues)
    end)
    register("nvissues", {"nvconflicts"}, "nvissues", "Show any registry or alias conflicts.", function()
        local result = RB.audit()
        if #result.issues == 0 then return "No duplicate names or alias conflicts found." end
        notify("NOVA / Registry Warnings", table.concat(result.issues, "\n"):sub(1, 900), 15)
    end)
    register("nverrors", {"nvfailures"}, "nverrors", "Show command errors recorded by the universal wrapper.", function()
        if #RB.logs == 0 then return "No captured command failures." end
        local lines = {}
        for i = 1, math.min(6, #RB.logs) do
            table.insert(lines, RB.logs[i].name .. ": " .. RB.logs[i].error:sub(1, 86))
        end
        notify("NOVA / Recent Failures", table.concat(lines, "\n"), 16)
    end)
    register("nvprofile", {"nvcmdprofile"}, "nvprofile [command]", "Show execution timing and failures for a command.", function(args)
        local name = tostring(args[1] or ""):lower()
        if name == "" then
            local top = {}
            for n, stat in pairs(RB.commands) do if stat.calls > 0 then table.insert(top, {name = n, stat = stat}) end end
            table.sort(top, function(a, b) return a.stat.totalMs > b.stat.totalMs end)
            local lines = {}
            for i = 1, math.min(#top, 6) do
                table.insert(lines, string.format("%s  %.1fms in %d calls", top[i].name, top[i].stat.totalMs, top[i].stat.calls))
            end
            if #lines == 0 then return "No command calls have been profiled yet." end
            notify("NOVA / Heavy Commands", table.concat(lines, "\n"), 16)
            return
        end
        local cmd = findCmd(name)
        if not cmd then return "Unknown command: " .. name end
        local stat = RB.commands[cmd.NAME:lower()]
        if not stat then return "No profile recorded yet." end
        return string.format("%s: %d runs, %d errors, avg %.2f ms, max %.2f ms", cmd.NAME,
            stat.calls, stat.failures, stat.calls > 0 and stat.totalMs / stat.calls or 0, stat.worstMs)
    end)
    register("nvpatches", {"nvfixes"}, "nvpatches", "List rewritten commands and fixes in this release.", function()
        local names = {}
        for name in pairs(RB.patches) do table.insert(names, name) end
        table.sort(names)
        notify("NOVA / Rewritten Commands (" .. #names .. ")", table.concat(names, ", "):sub(1, 1300), 16)
    end)
    register("nvrestore", {"nvstopmanaged"}, "nvrestore", "Stop managed loops, restore collision settings and reset listeners.", function()
        for name in pairs(RB.connections) do disconnect(name) end
        stopNoclip()
        RB.states.bright = (RB.states.bright or 0) + 1
        RB.states.autoClickToken = (RB.states.autoClickToken or 0) + 1
        autoclicking = false
        if type(mouse1release) == "function" then pcall(mouse1release) end
        for part in pairs(RB.states.antiFlingParts or {}) do
            if part.Parent then pcall(function() part.CanCollide = true end) end
        end
        RB.states.antiFlingParts = nil
        if antivoidloop then pcall(function() antivoidloop:Disconnect() end); antivoidloop = nil end
        if tpwalking then pcall(function() tpwalking:Disconnect() end); tpwalking = nil end
        if infJump then pcall(function() infJump:Disconnect() end); infJump = nil end
        if Noclipping then pcall(function() Noclipping:Disconnect() end); Noclipping = nil end
        Clip = true
        return "Managed command features stopped and collision state restored."
    end)
    register("nvstatus", {"nvhealth"}, "nvstatus", "Summarize command registry, instrumentation, patch count and failures.", function()
        local report = RB.audit()
        return string.format("NOVA Rebuild %s | %d commands | %d rewritten | %d wrapper records | %d failures | %d warnings",
            RB.version, report.total, RB.patchCount, report.checked, #RB.logs, #report.issues)
    end)
    RB.audit()
    if _G.IY_NOVA_UI and _G.IY_NOVA_UI.refresh then pcall(_G.IY_NOVA_UI.refresh) end
    if _G.IY_DEBUG then print("[NOVA Rebuild] All", RB.auditCount, "commands wrapped;", RB.patchCount, "individually repaired") end
end


--[[
  NOVA HELIX | 2026-11-20
  Reliability commands, bounded recipes and progression metrics.
  Compatible with old IY/NOVA names. No automatic purchases or server spoofing.
]]
do
    local H = {version = "4.0.0", recipes = {}, recipeToken = 0, activeRecipe = nil,
        metrics = nil, metricSince = nil, metricFilter = nil, registered = 0}
    _G.IY_NOVA_HELIX = H
    local me = Players.LocalPlayer
    local recipePath = "IY_NOVA_RECIPES.iy"
    local function register(name, aliases, usage, details, handler)
        if findCmd(name) then return false end
        addcmd(name, aliases, handler)
        addcmdtext(usage, "NOVA HELIX", details)
        H.registered = H.registered + 1
        return true
    end
    local function statusText()
        local d = _G.IY_NOVA_DISPATCH
        local rb = _G.IY_NOVA_REBUILD
        local loopCount = d and d.loopCount and d.loopCount() or 0
        local last = rb and rb.lastAudit or {}
        return string.format("HELIX %s | %d registered | workers %d/%d | loops %d | command calls %d | errors %d | registry warnings %d",
            H.version, #cmds, d and d.active or 0, d and d.maxActive or 0,
            loopCount, d and d.executed or 0, d and d.failures or 0,
            #(last.issues or {}))
    end
    register("novahealth", {"nhealth"}, "novahealth", "Show active workers, loops, error counts and registry health.", function()
        return statusText()
    end)
    register("novaloops", {"nloops"}, "novaloops", "List currently running infinite command tasks.", function()
        local d = _G.IY_NOVA_DISPATCH
        local lines = {}
        for name, detail in pairs(d.infinite) do
            lines[#lines + 1] = string.format("%s  (%d runs, %.2fs delay)", name, detail.count or 0, detail.interval or 0)
        end
        table.sort(lines)
        if #lines == 0 then return "No infinite command tasks are running." end
        notify("NOVA / ACTIVE COMMAND LOOPS", table.concat(lines, "\n"):sub(1, 1300), 14)
    end)
    register("novastoploop", {"nstoploop"}, "novastoploop [name/all]", "Stop one infinite command or all repeating command tasks.", function(args)
        local target = tostring(args[1] or ""):lower()
        if target == "" then return "Usage: novastoploop [command/all]" end
        local d = _G.IY_NOVA_DISPATCH
        if target == "all" then
            local count = d.stopAll()
            return "Stopped " .. count .. " repeating tasks and cancelled active command batches."
        end
        return d.stopLoop(target) and ("Stopped repeating " .. target .. ".")
            or ("No running repeating task for " .. target .. ".")
    end)
    register("novaworkers", {"nworkers"}, "novaworkers [2-16]", "Limit simultaneous command batches to prevent executor overload.", function(args)
        local d = _G.IY_NOVA_DISPATCH
        if not args[1] then return string.format("Worker limit: %d | Active: %d", d.maxActive, d.active) end
        local n = tonumber(args[1])
        if not n or n ~= n or n == math.huge or n == -math.huge then return "Usage: novaworkers [2-16]" end
        d.maxActive = math.clamp(math.floor(n), 2, 16)
        return "Maximum simultaneous command batches: " .. d.maxActive
    end)
    register("novasafestop", {"nstopall"}, "novasafestop", "Cancel managed loops, recipes and recently patched character mechanics.", function()
        local d = _G.IY_NOVA_DISPATCH
        local loops = d.stopAll()
        H.recipeToken = H.recipeToken + 1
        H.activeRecipe = nil
        local stop = findCmd("nvrestore")
        if stop then pcall(stop.FUNC, {}, me) end
        return string.format("Stopped %d looping tasks, recipes, and managed movement effects.", loops)
    end)

    local function validRecipeName(raw)
        if type(raw) ~= "string" or #raw == 0 or #raw > 24 then return nil end
        if not raw:match("^[%w_%-]+$") then return nil end
        return raw:lower()
    end
    local function recipeKeys()
        local names = {}
        for name in pairs(H.recipes) do names[#names + 1] = name end
        table.sort(names)
        return names
    end
    local function saveRecipes()
        if type(waxwritefile) ~= "function" then return false end
        local okay, encoded = pcall(function() return HttpService:JSONEncode({version=1, recipes=H.recipes}) end)
        if not okay then return false end
        return pcall(waxwritefile, recipePath, encoded)
    end
    if type(waxreadfile) == "function" then
        local success, content = pcall(waxreadfile, recipePath)
        if success and type(content) == "string" and #content < 32000 then
            local valid, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            if valid and type(decoded) == "table" and type(decoded.recipes) == "table" then
                local count = 0
                for name, steps in pairs(decoded.recipes) do
                    if count >= 20 then break end
                    if validRecipeName(name) and type(steps) == "table" and #steps <= 8 then
                        local cleaned = {}
                        for _, step in ipairs(steps) do
                            if type(step) == "string" and #step <= 180 then
                                local first = step:match("^%s*([^%s]+)")
                                if first and findCmd(first)
                                    and first:lower() ~= "novarecipe" and first:lower() ~= "nrecipe" then
                                    cleaned[#cleaned + 1] = step
                                end
                            end
                        end
                        if #cleaned > 0 then H.recipes[name:lower()] = cleaned; count = count + 1 end
                    end
                end
            end
        end
    end
    register("novarecipe", {"nrecipe"},
        "novarecipe [save/list/show/run/delete/stop] ...",
        "Save and replay up to eight validated commands. Separate steps with |.", function(args)
        local operation = tostring(args[1] or "list"):lower()
        if operation == "list" then
            local names = recipeKeys()
            return #names == 0 and "No recipes saved. Example: novarecipe save setup perfmon | novastatview"
                or ("Recipes (" .. #names .. "): " .. table.concat(names, ", "))
        end
        if operation == "stop" then
            H.recipeToken = H.recipeToken + 1
            H.activeRecipe = nil
            return "Recipe dispatch cancelled. Already-running commands may still finish."
        end
        local name = validRecipeName(args[2])
        if not name then return "Usage: novarecipe [save/show/run/delete] [name] ..." end
        if operation == "show" then
            local steps = H.recipes[name]
            return steps and (name .. ": " .. table.concat(steps, " | ")) or "Unknown recipe."
        elseif operation == "delete" then
            if not H.recipes[name] then return "Unknown recipe." end
            H.recipes[name] = nil
            saveRecipes()
            return "Deleted recipe: " .. name
        elseif operation == "save" then
            if #recipeKeys() >= 20 and not H.recipes[name] then return "Maximum 20 recipes reached." end
            local raw = table.concat(args, " ", 3)
            if #raw > 1000 then return "Recipe is too long (limit 1000 characters)." end
            local steps = {}
            for text in (raw .. "|"):gmatch("(.-)|") do
                local step = text:match("^%s*(.-)%s*$")
                if step ~= "" then
                    if #step > 180 or #steps >= 8 then return "A recipe may contain at most 8 steps (180 chars each)." end
                    local first = step:match("^([^%s]+)")
                    if not first or not findCmd(first) or first:lower() == "novarecipe"
                        or first:lower() == "nrecipe" then
                        return "Unknown or recursive step: " .. tostring(first)
                    end
                    steps[#steps + 1] = step
                end
            end
            if #steps == 0 then return "Add commands separated by | after the recipe name." end
            H.recipes[name] = steps
            saveRecipes()
            return string.format("Saved recipe %s with %d steps.", name, #steps)
        elseif operation == "run" then
            local steps = H.recipes[name]
            if not steps then return "Unknown recipe." end
            if H.activeRecipe then return "Another recipe is active; use novarecipe stop first." end
            H.recipeToken = H.recipeToken + 1
            local token = H.recipeToken
            H.activeRecipe = name
            task.spawn(function()
                for _, step in ipairs(steps) do
                    if token ~= H.recipeToken then break end
                    execCmd(step, me, true)
                    task.wait(0.45)
                end
                if token == H.recipeToken then H.activeRecipe = nil end
            end)
            return "Started recipe " .. name .. " (" .. #steps .. " steps)."
        end
        return "Usage: novarecipe [save/list/show/run/delete/stop]"
    end)
    register("novarecipestatus", {"nrecipestatus"}, "novarecipestatus", "Check recipe state and persistence.", function()
        return string.format("Recipes: %d/20 | Running: %s | Persistence: %s", #recipeKeys(),
            H.activeRecipe or "none", type(waxwritefile) == "function" and "available" or "session-only")
    end)

    local function getNumberValues()
        local collected, visited = {}, 0
        for _, obj in ipairs(me:GetDescendants()) do
            visited = visited + 1
            if visited > 1800 or #collected >= 80 then break end
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local value = tonumber(obj.Value)
                if value and value == value and math.abs(value) ~= math.huge then
                    collected[#collected + 1] = {ref=obj, name=obj.Name, value=value}
                end
            end
        end
        return collected
    end
    register("novametric", {"nmetric"}, "novametric [start/show/stop] [stat-filter]",
        "Measure changes in client-visible numeric progression stats.", function(args)
        local action = tostring(args[1] or "show"):lower()
        if action == "stop" or action == "clear" then
            H.metrics, H.metricSince, H.metricFilter = nil, nil, nil
            return "Progress metric baseline cleared."
        elseif action == "start" then
            H.metrics = {}
            H.metricFilter = table.concat(args, " ", 2):lower()
            local items = getNumberValues()
            for _, item in ipairs(items) do
                if H.metricFilter == "" or item.name:lower():find(H.metricFilter, 1, true) then
                    H.metrics[#H.metrics + 1] = item
                end
            end
            H.metricSince = os.clock()
            return string.format("Tracking %d numeric values (baseline captured).", #H.metrics)
        elseif action == "show" then
            if not H.metrics then return "No baseline. Use novametric start [optional stat name]." end
            local elapsed = math.max(0.01, os.clock() - H.metricSince)
            local changes = {}
            for _, item in ipairs(H.metrics) do
                if item.ref.Parent then
                    local ok, current = pcall(function() return tonumber(item.ref.Value) end)
                    if ok and current and current == current and math.abs(current) ~= math.huge then
                        local delta = current - item.value
                        if delta ~= 0 then
                            changes[#changes + 1] = {name=item.name, delta=delta, rate=delta/elapsed}
                        end
                    end
                end
            end
            table.sort(changes, function(a,b) return math.abs(a.delta) > math.abs(b.delta) end)
            if #changes == 0 then return string.format("No numeric stat changes over %.1fs (%d tracked).", elapsed, #H.metrics) end
            local lines = {}
            for i = 1, math.min(6, #changes) do
                local e = changes[i]
                lines[#lines + 1] = string.format("%s  %+g  (%+.2f/s)", e.name, e.delta, e.rate)
            end
            notify("NOVA / PROGRESSION DELTAS", table.concat(lines, "\n"), 16)
            return string.format("Observed %d changed stats over %.1fs.", #changes, elapsed)
        end
        return "Usage: novametric [start/show/stop] [optional name]"
    end)
    register("novaexporthealth", {"nexporthealth"}, "novaexporthealth", "Copy local command health diagnostics as JSON when clipboard is available.", function()
        if type(everyClipboard) ~= "function" then return "Clipboard API not available." end
        local d = _G.IY_NOVA_DISPATCH
        local rb = _G.IY_NOVA_REBUILD
        local payload = {version=H.version, commandCount=#cmds, activeWorkers=d.active,
            maxWorkers=d.maxActive, activeLoops=d.loopCount(), calls=d.executed,
            errors=d.failures, blocked=d.blocked, corrected=rb and rb.patchCount or 0,
            recentErrors={}}
        local records = _G.IY_NOVA_ERRORS or {}
        for i=1, math.min(8,#records) do
            payload.recentErrors[i] = {command=tostring(records[i].command or ""),
                message=tostring(records[i].message or ""):sub(1,180)}
        end
        local ok, data = pcall(function() return HttpService:JSONEncode(payload) end)
        if not ok then return "JSON diagnostics unavailable." end
        local done = pcall(everyClipboard, data)
        return done and "Copied diagnostics JSON locally; no network upload was performed."
            or "Clipboard write failed."
    end)
    register("novahelixhelp", {"nhelix"}, "novahelixhelp", "Show reliability commands, recipes and stat tracking.", function()
        notify("NOVA HELIX / COMMANDS",
            "novahealth | novaloops | novastoploop [name/all] | novaworkers [2-16] | " ..
            "novasafestop | novarecipe [save/list/show/run/delete/stop] | " ..
            "novametric [start/show/stop] | novaquickbar [on/off] | novaexporthealth", 18)
    end)
    if _G.IY_NOVA_REBUILD and _G.IY_NOVA_REBUILD.audit then
        pcall(_G.IY_NOVA_REBUILD.audit)
    end
    if _G.IY_NOVA_UI and _G.IY_NOVA_UI.refresh then pcall(_G.IY_NOVA_UI.refresh) end
    if type(IndexContents) == "function" then pcall(IndexContents, "", true) end
    if _G.IY_DEBUG then print("[NOVA HELIX] Registered", H.registered, "additional commands") end
end


--[[
 NOVA HELIX v4 | Recovery and Diagnostics
 No remote manipulation, bypass logic, or network telemetry.
 All actions run locally and preserve existing command names.
]]
do
    local V4 = {version = "4.0.0", registered = 0, cleanupFailures = {},
        startedAt = os.clock(), snapshots = nil}
    _G.IY_NOVA_HELIX_V4 = V4
    local me = Players.LocalPlayer
    local function reg(name, aliases, desc, handler)
        if findCmd(name) then return false end
        local command = addcmd(name, aliases, handler)
        if command and command.NAME == name then
            addcmdtext(name, "NOVA HELIX V4", desc)
            V4.registered = V4.registered + 1
            return true
        end
        return false
    end
    local function invokeExisting(name)
        local command = findCmd(name)
        if not command then return false, "missing" end
        local ok, result = pcall(command.FUNC, {}, me)
        return ok, result
    end
    local function stopEverything()
        local d = _G.IY_NOVA_DISPATCH
        local loops = d and d.stopAll and d.stopAll() or 0
        local helix = _G.IY_NOVA_HELIX
        if helix then
            helix.recipeToken = helix.recipeToken + 1
            helix.activeRecipe = nil
        end
        local stopped, failed = 0, {}
        -- Every module keeps its own reversible teardown; use those APIs.
        local cleanup = {
            "progshutdown", "cheatshutdown", "novastopall", "nvrestore",
            "unmultijump", "unbunnyhop", "unglide", "unwallclimb",
            "unsprint", "untracers", "unradar", "undistancetags",
            "untoolesp", "unaimassist", "unperfmon"
        }
        for _, command in ipairs(cleanup) do
            if findCmd(command) then
                local ok, err = invokeExisting(command)
                if ok then stopped = stopped + 1
                else failed[#failed + 1] = command .. ": " .. tostring(err):sub(1, 80) end
            end
        end
        V4.cleanupFailures = failed
        local msg = string.format("Cancelled %d repeating tasks; ran %d cleanup handlers.", loops, stopped)
        if #failed > 0 then
            msg = msg .. " Failed: " .. table.concat(failed, ", "):sub(1, 220)
        end
        return msg
    end
    -- Keep previous stop command name, but extend its scope to all NOVA packs.
    overridecmd("novasafestop", function() return stopEverything() end)
    reg("novapanic", {"novaemergency", "nresetall"},
        "Stop managed gameplay, progression, navigation, overlays and repeat tasks.",
        function() return stopEverything() end)

    reg("novabudget", {"nbudget"},
        "Get or set the maximum number of command calls in one dispatch batch.",
        function(args)
            local d = _G.IY_NOVA_DISPATCH
            if not args[1] then return "Command batch budget: " .. tostring(d.maxBatchCalls) end
            local n = tonumber(args[1])
            if not n or n ~= n or n == math.huge or n == -math.huge
                or n ~= math.floor(n) or n < 50 or n > 4000 then
                return "Usage: novabudget [integer 50-4000]"
            end
            d.maxBatchCalls = n
            return "Per-batch command limit set to " .. n
        end)

    reg("novaauditlive", {"nauditlive", "novaverify"},
        "Inspect registered commands, aliases, callbacks, API availability and worker state.",
        function()
            local seen, conflicts = {}, {}
            local missingCallbacks, registered = 0, 0
            for _, command in ipairs(cmds) do
                registered = registered + 1
                if type(command.FUNC) ~= "function" then missingCallbacks = missingCallbacks + 1 end
                local names = {command.NAME}
                for _, alias in ipairs(command.ALIAS or {}) do names[#names + 1] = alias end
                for _, name in ipairs(names) do
                    local key = tostring(name):lower()
                    if seen[key] and #conflicts < 8 then
                        conflicts[#conflicts + 1] = key
                    else
                        seen[key] = true
                    end
                end
            end
            local d = _G.IY_NOVA_DISPATCH
            local detail = string.format(
                "Commands: %d | missing callbacks: %d | duplicate names/aliases (sample): %d | workers: %d/%d | loop count: %d | cancelled by budget: %d | clipboard: %s | settings files: %s",
                registered, missingCallbacks, #conflicts,
                d and d.active or 0, d and d.maxActive or 0,
                d and d.loopCount and d.loopCount() or 0,
                d and d.budgetStops or 0,
                type(everyClipboard) == "function" and "yes" or "no",
                type(waxreadfile) == "function" and type(waxwritefile) == "function" and "yes" or "no")
            if #conflicts > 0 then detail = detail .. "\nConflicts: " .. table.concat(conflicts, ", ") end
            notify("NOVA HELIX / LIVE AUDIT", detail, 15)
            return detail
        end)

    reg("novacmdinspect", {"ncmdinspect"},
        "Inspect a command's aliases, source group and usage without executing it.",
        function(args)
            local raw = args[1]
            if not raw or raw == "" then return "Usage: novacmdinspect [command name]" end
            local command = findCmd(raw)
            if not command then return "Unknown command: " .. tostring(raw) end
            local group = "Unknown"
            local ui = _G.IY_NOVA_UI
            if ui and type(ui.category) == "function" then
                local ok, value = pcall(ui.category, command.NAME)
                if ok then group = tostring(value) end
            end
            local aliases = table.concat(command.ALIAS or {}, ", ")
            local detail = string.format("%s | %s | Aliases: %s | Callback: %s",
                tostring(command.NAME), group, aliases ~= "" and aliases or "none",
                type(command.FUNC))
            notify("NOVA / COMMAND DETAILS", detail, 12)
            return detail
        end)

    local function getBody()
        local character = me.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        return humanoid
    end
    reg("novaphysics", {"nphysics"},
        "Save or restore local movement and camera properties (does not alter server stats).",
        function(args)
            local action = tostring(args[1] or "status"):lower()
            local hum = getBody()
            local camera = workspace.CurrentCamera
            if action == "save" then
                if not hum then return "Character is not ready." end
                V4.snapshots = {humanoid = hum,
                    walkSpeed = hum.WalkSpeed, useJumpPower = hum.UseJumpPower,
                    jumpPower = hum.JumpPower, jumpHeight = hum.JumpHeight,
                    hipHeight = hum.HipHeight, gravity = workspace.Gravity,
                    camera = camera, fov = camera and camera.FieldOfView or nil}
                return "Saved local movement, gravity and camera FOV snapshot."
            elseif action == "restore" then
                local snap = V4.snapshots
                if not snap then return "No snapshot. Use novaphysics save first." end
                if hum and hum == snap.humanoid then
                    pcall(function()
                        hum.WalkSpeed = snap.walkSpeed
                        hum.UseJumpPower = snap.useJumpPower
                        hum.JumpPower = snap.jumpPower
                        hum.JumpHeight = snap.jumpHeight
                        hum.HipHeight = snap.hipHeight
                    end)
                end
                workspace.Gravity = snap.gravity
                if camera and camera == snap.camera and snap.fov then
                    pcall(function() camera.FieldOfView = snap.fov end)
                end
                return "Restored snapshot for objects still present. Stop active movement commands first."
            elseif action == "clear" then
                V4.snapshots = nil
                return "Local physics snapshot cleared."
            end
            return "Snapshot: " .. (V4.snapshots and "saved" or "none") .. " | novaphysics [save/restore/clear]"
        end)

    reg("novav4help", {"nhelix4"},
        "Display this release's diagnostics and recovery commands.",
        function()
            return "HELIX v4: novapanic, novabudget, novaauditlive, novacmdinspect, novaphysics. Use F2 or Ctrl+K to open the organized palette."
        end)
    if _G.IY_NOVA_UI and _G.IY_NOVA_UI.refresh then pcall(_G.IY_NOVA_UI.refresh) end
    if type(IndexContents) == "function" then pcall(IndexContents, "", true) end
end
