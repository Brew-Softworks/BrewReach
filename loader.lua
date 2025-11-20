--!nolint
--!nocheck
-- Copyright (c) 2025 @dex4tw
-- This code is licensed under the GNU General Public License v3.0 (GPLv3).
-- You may use, modify, and redistribute it, but any redistributed or derivative work
-- must also be licensed under GPLv3.
-- Full license: https://www.gnu.org/licenses/gpl-3.0.en.html

--< Brew Objects >--
local Brew = {}
Brew.Configuration = {}
Brew.Configuration.reachRadius = 5
Brew.Configuration.reachVector = Vector3.new(5, 5, 5)
Brew.Configuration.reachMethod = {
	["Spoof"] = false,
	["Hitbox Extender"] = false,
	["CFrame"] = false,
}
Brew.Configuration.reachType = "Box"
Brew.Configuration.defaultSize = Vector3.new(1, 0.800000011920929, 4)
Brew.Configuration.damageAmplification = false
Brew.Configuration.Color = Color3.fromRGB(255, 255, 255)
Brew.Configuration.Alpha = 0
Brew.Configuration.spoofMethod = "none"
Brew.Configuration.allowedMethods = {}
Brew.Configuration.Notifications = true
Brew.Configuration.debugNotifications = false
Brew.Configuration.gameSwords = {}
Brew.Configuration.isMobile = false
Brew.Features = {}
Brew._Threads = {}
Brew._Temp = {}

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MacLib = loadstring(
	game:HttpGet(
		"https://gist.githubusercontent.com/dex4tw/3acf5660744c235ee4b6826e2db3e954/raw/aa7819b0bdd6ee158be3e0a1973eb10d94e5d438/Brew%2520MacLib.lua"
	)
)()
local varArgs = ...
local s, Analytics = pcall(function(varArgs)
	loadstring(game:HttpGet("https://gist.githubusercontent.com/dex4tw/59a71d3936684797cb1f1109464bea0e/raw/10774809e438bd4e1f308c7bd498666dba47dc15/Brew%2520Analytics"))(varArgs)
end)
local Window = MacLib:Window({
	Title = "Brew Reach",
	Subtitle = "Build - Free (Stable)",
	DragStyle = 2,
	Keybind = Enum.KeyCode.LeftControl,
	Size = UDim2.fromOffset(700, 500),
	AcrylicBlur = false,
	ShowUserInfo = false,
})
local originalScale = Window:GetScale()
Window:Dialog({
  Title = "Brew",
  Description = "This version of Brew is outdated, please get the new loadstring from our Discord Server @ discord.gg/GMTNFPUGGY",
  Buttons = {
    {
      Name = "Join Discord",
      Callback = function()
    		local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()
    		Module.Join("https://discord.gg/GMTNFPUGGY")
        Window:Unload()
      end
    },
    {
      Name = "Cancel",
      Callback = function()
        Window:Unload()
      end
    }
  },
})

--< Brew Detections & QoL >--
if hookmetamethod or getrawmetatable then
	Brew.Configuration.allowedMethods = { "Spoof", "Hitbox Extender", "CFrame" }
	Brew.Configuration.reachMethod.Spoof = true
	if hookmetamethod then
		Brew.Configuration.spoofMethod = "metamethod"
	elseif getrawmetatable and newcclosure then
		Brew.Configuration.spoofMethod = "metatable"
	else
		Brew.Configuration.spoofMethod = "none"
	end
else
	Brew.Configuration.allowedMethods = { "CFrame" }
	Brew.Configuration.reachMethod.CFrame = true
	Window:Notify({
		Title = "Brew",
		Description = "Your executor does not meet the requirements to completely prevent detection, therefore we've disabled some features. Please open a support ticket for help",
		Lifetime = 5,
		Scale = 1.2,
	})
end
if getconnections then 
	for i, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do 
		pcall(function()
			v:Disconnect()
		end)
	end
end

-- 📞 For mobile users
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
	Brew.Configuration.spoofMethod = "metatable"
	Brew.Configuration.isMobile = true
end

if game.GameId == 3737753748 then -- 😋 STFO Sword Giver
	for i, Sword in pairs(game:GetService("ReplicatedStorage").Assets.Swords:GetChildren()) do
		table.insert(Brew.Configuration.gameSwords, Sword.Name)
	end

	-- 😔 Here also lies the anti-cheat blocking because I don't want to organize this
	-- 	   old code anymore
	local s, e = pcall(function()
		setrawmetatable(game:GetService("ReplicatedStorage").Remotes.GiveTime, {
			__namecall = function()
				wait(9e9)

				return nil
			end
		})
	end)
	if not s then
		Window:Notify({
			Title = "Brew",
			Description = "⚠️ Could not disable STFO anticheat completely, please report this to our support server",
			Lifetime = 9e9,
			Scale = 1.2,
			Style = "Cancel",
		})
	end
end
if game.GameId == 2357812100 then
	local s, e = pcall(function()
		local Event = game:GetService("ReplicatedStorage").Remotes.EquipSword
		local OldFireServer; OldFireServer = hookfunction(Event.FireServer, function(...)
			local self = ...

			if rawequal(self, Event) then
				local Args = table.pack(...)

				if Args[2] == "UseSword " then 
					return OldFireServer(self, {
						"UseSword",
						Args[3]
					})
				end
			end

			return OldFireServer(self, ...)
		end)
	end)
	if not s then
		Window:Notify({
			Title = "Brew",
			Description = "⚠️ Could not disable STFO:ABTB anticheat completely, please report this to our support server",
			Lifetime = 9e9,
			Scale = 1.2,
			Style = "Cancel",
		})
		Window:Dialog({
			Title = "Brew",
			Description = "You may be detected if you use this right now, please report this issue to our support server",
			Buttons = {
				{
					Name = "Close",
					Callback = function()
						Window:Unload()
					end
				},
				{
					Name = "Cancel",
				}
			},
		})
	end
end

--< Brew Functions >--
Brew.Thread = function(self, thread: any, wait: number) -- 🔄️ Used for loops (e.g while, renderstepped)
	wait = wait or 0.3

	local threadId = math.random(0xfffffff)
	Brew.debugNotify("[Thread] Starting", tostring(threadId))

	local success, message = pcall(function()
		task.spawn(function()
			local accumulated = wait
			local newThread = RunService.Heartbeat:Connect(function(deltaTime)
				accumulated += deltaTime

				if accumulated >= wait then
					accumulated = 0
					local s, e = pcall(thread) -- 😼
					if not s then
						Brew.debugNotify("Thread Error", e, "so, thread ended")

						-- Brew:endThread(threadId) -- ‼️ This may break some things
					end
				end
			end)

			Brew._Threads[threadId] = newThread
		end)
	end)

	if success then
		return { StatusCode = 200, Message = threadId }
	else
		Brew.Notify("[Thread]", message)
	end
end

Brew.endThread = function(self, thread: number) -- ❌ Terminate loops (Brew Threads)
	success, message = pcall(function()
		if self._Threads[thread] then
			self._Threads[thread]:Disconnect()
			self._Threads[thread] = nil

			return { StatusCode = 200 }
		else
			return { StatusCode = 404, Message = "Thread not found" }
		end
	end)

	if success then
		if message.StatusCode == 404 then
			Brew.debugNotify("[Thread]", message.Message)
		else
			Brew.debugNotify("[Thread] Ended thread", tostring(thread))
		end
	else
		Brew.debugNotify("[Thread]", message)
	end
end

Brew.Spoof = function(self, index: Instance, property: string, value: any)
    if not self._Temp[index] then
        self._Temp[index] = {}
    end

    if self._Temp[index][property] then
        return { StatusCode = 409, Message = "Resource already exists" }
    end

    self._Temp[index][property] = value
    return { StatusCode = 200, Message = "Spoof applied" }
end

Brew.protectInstance = function(self, instance: Instance)
	instance.Name =
		string.sub(string.gsub(game:GetService("HttpService"):GenerateGUID(false), "-", ""), 1, math.random(25, 30))
	instance.Archivable = false
	Brew:Spoof(instance, "Parent", nil)
	Brew:Spoof(instance, "Name", nil)
	Brew:Spoof(instance, "ClassName", nil)
end

Brew.Notify = function(...)
	if not Brew.Configuration.Notifications then
		return
	end

	local args = { ... }
	local message = ""

	for i, v in ipairs(args) do
		message = message .. tostring(v)
		if i < #args then
			message = message .. " "
		end
	end

	Window:Notify({
		Title = "Brew",
		Description = message,
		Lifetime = 5,
		Scale = 1.2,
	})
end

Brew.debugNotify = function(...)
	if not Brew.Configuration.debugNotifications then
		return
	end

	local args = { ... }
	local message = ""

	for i, v in ipairs(args) do
		message = message .. tostring(v)
		if i < #args then
			message = message .. " "
		end
	end

	Window:Notify({
		Title = "Brew Debug",
		Description = message,
		Lifetime = 5,
		Scale = 1.2,
	})
end

--< Brew Features >--
Brew.Features.getSword = {
	Name = "getSword",
	Enabled = false,
	Function = function(self)
		repeat
			task.wait(0.1)
		until Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")

		local Sword = Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
		return Sword
	end,
}

Brew.Features.getHandle = {
	Name = "getHandle",
	Enabled = false,
	Function = function(self)
		local Handle
		local Sword = Brew.Features:getSword()
		for i, v in pairs(Sword:GetDescendants()) do
			if v:IsA("TouchTransmitter") then
				Handle = v.Parent
				break
			end
		end

		if Handle then
			Handle.Massless = true
			Handle.CanCollide = false
			pcall(function()
				for i,v in pairs(getconnections(Handle.Changed)) do
					v:Disconnect()
					Brew.debugNotify("Possible anti-cheat detected, signal disconnected")
				end
			end)
			return Handle
		else
			error("[Brew] Feature error Handle is nil")
		end
	end,
}

Brew.Features.Reach = {
	Name = "Reach",
	Enabled = false,
	Thread = nil,
	Thread2 = nil,
	Thread3 = nil,
	Function = function(self, enabled: boolean)
		Brew.Features.Reach.Enabled = enabled

		Brew.Features.Reach:Spoof(Brew.Configuration.reachMethod["Spoof"])
		Brew.Features.Reach:hitboxExtender(Brew.Configuration.reachMethod["Hitbox Extender"])
		Brew.Features.Reach:damageAmplification(Brew.Configuration.damageAmplification)
		Brew.Features.Reach:CFrame(Brew.Configuration.reachMethod["CFrame"])
	end,
	Spoof = function(self, enabled: boolean)
		local Handle = Brew.Features:getHandle()
		local reachRad = Brew.Configuration.reachRadius
		local reachType = Brew.Configuration.reachType

		Brew:Spoof(Handle, "Size", Brew.Configuration.defaultSize)
		if reachType == "Box" then
			Brew.Configuration.reachVector = Vector3.new(reachRad, reachRad, reachRad)
		elseif reachType == "Linear" then
			Brew.Configuration.reachVector = Vector3.new(1, 0.800000011920929, reachRad * 1.3)
		elseif reachType == "Wide" then
			Brew.Configuration.reachVector = Vector3.new(reachRad * 0.5, reachRad * 0.5, reachRad * 1.3)
		end

		if enabled and Brew.Features.Reach.Enabled then
			Handle.Size = Brew.Configuration.reachVector
		else
			Handle.Size = Brew.Configuration.defaultSize
		end
	end,
	hitboxExtender = function(self, enabled: boolean)
		if Brew.Features.Reach.Thread then
			Brew:endThread(Brew.Features.Reach.Thread.Message)
			Brew.Features.Reach.Thread = nil
		end

		Brew.Features.Reach.Thread = Brew:Thread(function()
			for i, Player in pairs(game:GetService("Players"):GetPlayers()) do
				if Player == game:GetService("Players").LocalPlayer then
					continue
				end
				
				pcall(function()
					local Character = Player.Character
					local Root = Character:FindFirstChild("HumanoidRootPart")
					local reachRad = Brew.Configuration.reachRadius

					Root.CanCollide = false
					Brew:Spoof(Root, "Size", Vector3.new(2, 2, 1))
					if Brew.Configuration.reachMethod["Hitbox Extender"] and Brew.Features.Reach.Enabled then
						Root.Size = Vector3.new(reachRad, reachRad, reachRad)
					else
						Root.Size = Vector3.new(2, 2, 1)
					end
				end)
			end
		end)
	end,
	damageAmplification = function(self, enabled: boolean)
		if Brew.Features.Reach.Thread2 then
			Brew:endThread(Brew.Features.Reach.Thread2.Message)
			Brew.Features.Reach.Thread2 = nil
		end

		if Brew.Configuration.damageAmplification then
			local Handle = Brew.Features:getHandle()
			
			Brew.Features.Reach.Thread2 = Brew:Thread(function()
				local Parts = workspace:GetPartBoundsInBox(Handle.CFrame, Handle.Size)

				for i, v in pairs(Parts) do
					pcall(function() -- 🔒 "new overlap in different world" & "attempt to index nil"
						if getrawmetatable and v.Parent:FindFirstChildOfClass("Humanoid") and v.Parent ~= Character then
							firetouchinterest(v, Handle, 0)
							task.wait()
							firetouchinterest(v, Handle, 1)
						else
							Limb = v.Parent:FindFirstChild("B Left Arm")
							Limb2 = v.Parent:FindFirstChild("B Left Leg")
							if Limb then
								firetouchinterest(Limb, Handle, 0)
								task.wait()
								firetouchinterest(Limb, Handle, 1)
							end
							if Limb2 then
								firetouchinterest(Limb2, Handle, 0)
								task.wait()
								firetouchinterest(Limb2, Handle, 1)
							end
						end
					end)
				end
			end, 0.1)
		end
	end,
	CFrame = function(self, enabled: boolean)
		if Brew.Features.Reach.Thread3 then
			Brew:endThread(Brew.Features.Reach.Thread3.Message)
			Brew.Features.Reach.Thread3 = nil

			-- 🧹 CFrame Thread Cleanup </3
			local Handle = Brew.Features:getHandle()
			if Handle:FindFirstChild("lHandle") then
				Handle:FindFirstChild("lHandle"):Destroy()
			end
		end

		if Brew.Configuration.reachMethod.CFrame and Brew.Features.Reach.Enabled then
			local Handle = Brew.Features:getHandle() -- ❤️‍🩹 This used to be inside the thread, woops

			Brew.Features.Reach.Thread3 = Brew:Thread(function()
				local Parts = workspace:GetPartBoundsInBox(Handle.CFrame, Brew.Configuration.reachVector)
				pcall(function()
					if not Handle:FindFirstChild("lHandle") then
						local lHandle = Instance.new("Part")
						Brew:protectInstance(lHandle)
						lHandle.Parent = Handle
						lHandle.Name = "lHandle"
						lHandle.Transparency = 1
						lHandle.CanCollide = false
						lHandle.Anchored = true
						Brew.Features:viewHitbox(Brew.Features.viewHitbox.Enabled)
					end
					if Handle:FindFirstChild("lHandle") then
						Handle:FindFirstChild("lHandle").Size = Brew.Configuration.reachVector
						Handle:FindFirstChild("lHandle").CFrame = Handle.CFrame
					end
				end)

				for i, v in pairs(Parts) do
					pcall(function() -- 🔒 "new overlap in different world" & "attempt to index nil"
						if v.Parent:FindFirstChildOfClass("Humanoid") then
							if
								v.Parent ~= Character
								and v.Parent:FindFirstChild("Left Arm")
								and v.Parent:FindFirstChild("Right Arm")
							then
								local Limb = v.Parent:FindFirstChild("Left Arm")
								if Limb then
									if not v.Parent:FindFirstChild("B") then
										local WL = Instance.new("StringValue")
										Brew:protectInstance(WL)
										WL.Parent = v.Parent
										WL.Name = "B"

										local s, e = pcall(function()
											-- Left Arm
											local Rig = v.Parent
											local lArm = Rig["Left Arm"]
											local lMotor = Rig.Torso["Left Shoulder"]:Clone()
											lArm.Parent = workspace
											lArm.CanCollide = false
											lArm.Anchored = true
											lArm:BreakJoints()

											fakeLArm = lArm:Clone()
											fakeLArm.Parent = Rig
											fakeLArm.Anchored = false
											lMotor.Part1 = fakeLArm
											lMotor.Parent = Rig.Torso

											lArm:ClearAllChildren()
											lArm.Transparency = 1
											lArm.Parent = Rig
											lArm.Name = "B Left Arm"

											-- Right Arm
											local rArm = Rig["Left Leg"]
											local rMotor = Rig.Torso["Left Hip"]:Clone()
											rArm.Parent = workspace
											rArm.CanCollide = false
											rArm.Anchored = true
											rArm:BreakJoints()

											fakeRArm = rArm:Clone()
											fakeRArm.Parent = Rig
											fakeRArm.Anchored = false
											rMotor.Part1 = fakeRArm
											rMotor.Parent = Rig.Torso

											rArm:ClearAllChildren()
											rArm.Transparency = 1
											rArm.Parent = Rig
											rArm.Name = "B Left Leg"
										end)
									end
									Limb = v.Parent:FindFirstChild("B Left Arm")
									Limb2 = v.Parent:FindFirstChild("B Left Leg")

									if table.find(Parts, Limb.Parent.HumanoidRootPart) then
										Limb.CFrame = Handle.CFrame
										Limb2.CFrame = Handle.CFrame
									else
										Limb.CFrame = Vector3.new(1e1, 0, 0)
										Limb2.CFrame = Vector3.new(1e1, 0, 0)
									end
								end
							end
						end
					end)
				end
			end, .1)
		end
	end,
}

Brew.Features.viewHitbox = {
	Name = "viewHitbox",
	Enabled = false,
	Function = function(self, enabled: boolean)
		Brew.Features.viewHitbox.Enabled = enabled

		local Handle = Brew.Features:getHandle()
		local Color = Brew.Configuration.Color
		local Alpha = Brew.Configuration.Alpha

		if Handle:FindFirstChildOfClass("SelectionBox") then
			Handle:FindFirstChildOfClass("SelectionBox"):Destroy()
		end
		if
			Handle:FindFirstChild("lHandle") and Handle:FindFirstChild("lHandle"):FindFirstChildOfClass("SelectionBox")
		then
			Handle:FindFirstChild("lHandle"):FindFirstChildOfClass("SelectionBox"):Destroy()
		end
		if Brew.Features.viewHitbox.Enabled then
			local Box = Instance.new("SelectionBox")
			Brew:protectInstance(Box)
			Box.Parent = Handle
			Box.Adornee = Handle
			Box.LineThickness = 0.01
			Box.Color3 = Color
			Box.Transparency = Alpha
			if Handle:FindFirstChild("lHandle") then
				local lBox = Instance.new("SelectionBox")
				Brew:protectInstance(lBox)
				lBox.Parent = Handle:FindFirstChild("lHandle")
				lBox.Adornee = Handle:FindFirstChild("lHandle")
				lBox.LineThickness = 0.01
				lBox.Color3 = Color
				lBox.Transparency = Alpha
			end
		end
	end,
}

Brew.Features.viewRoots = {
	Name = "viewRoots",
	Enabled = false,
	Thread = nil,
	Function = function(self, enabled: boolean)
		Brew.Features.viewRoots.Enabled = enabled

		if Brew.Features.viewRoots.Thread then
			Brew:endThread(Brew.Features.viewRoots.Thread.Message)
			Brew.Features.viewRoots.Thread = nil
		end

		Brew.Features.viewRoots.Thread = Brew:Thread(function()
			for i, Player in pairs(game:GetService("Players"):GetPlayers()) do
				if Player == game:GetService("Players").LocalPlayer then
					continue
				end
				pcall(function()
					local Character = Player.Character
					local Root = Character:FindFirstChild("HumanoidRootPart")
					local Color = Brew.Configuration.Color
					local Alpha = Brew.Configuration.Alpha

					if Brew.Features.viewRoots.Enabled then
						if Root:FindFirstChildOfClass("SelectionBox") then
							Box = Root:FindFirstChild("SelectionBox")
							Box.Color3 = Color
							Box.Transparency = Alpha
						else
							local Box = Instance.new("SelectionBox")
							Brew:protectInstance(Box)
							Box.Parent = Root
							Box.Adornee = Root
							Box.LineThickness = 0.01
							Box.Color3 = Color
							Box.Transparency = Alpha
						end
					else
						if Root:FindFirstChildOfClass("SelectionBox") then
							Root:FindFirstChildOfClass("SelectionBox"):Destroy()
						end
					end
				end)
			end
		end)
	end,
}

Brew.Features.Spin = {
	Name = "Spin",
	Enabled = false,
	Function = function(self, enabled: boolean)
		Brew.Features.Spin.Enabled = enabled

		local Root = Character:FindFirstChild("HumanoidRootPart")
		if Root:FindFirstChildOfClass("BodyAngularVelocity") then
			Root:FindFirstChildOfClass("BodyAngularVelocity"):Destroy()
		end
		if enabled then
			local Velocity = Instance.new("BodyAngularVelocity")
			Brew:protectInstance(Velocity)
			Velocity.Parent = Root
			Velocity.AngularVelocity = Vector3.new(0, 75, 0)
			Velocity.MaxTorque = Vector3.new(0, 9e9, 0)
			Velocity.P = 1250
		end
	end,
}

Brew.Features.orbExpander = {
	Name = "orbExpander",
	Enabled = false,
	Thread = nil,
	Function = function(self, enabled: boolean)
		Brew.Features.orbExpander.Enabled = enabled
		if Brew.Features.orbExpander.Thread then
			Brew:endThread(Brew.Features.orbExpander.Thread["Message"])
			Brew.Features.orbExpander.Thread = nil
		end

		local Orbs = workspace.Orbs
		Brew.Features.orbExpander.Thread = Brew:Thread(function()
			for i, Orb in pairs(Orbs:GetChildren()) do
				if enabled then
					Orb["Black"].Size = Vector3.new(10, 10, 10)
				else
					Orb["Black"].Size = Vector3.new(2.1500000953674316, 2.1500000953674316, 2.1500000953674316)
				end
			end
		end)
	end,
}

Brew.Features.Jitter = {
	Name = "Jitter",
	Enabled = false,
	Thread = nil,
	Function = function(self, enabled: boolean, caller: string)
		caller = caller or "user" -- 👀 Prevent jitter from activating on respawn
		if caller == "auto" then
			Brew.Features.Jitter.Enabled = false
		else
			Brew.Features.Jitter.Enabled = not Brew.Features.Jitter.Enabled
		end

		if Brew.Features.Jitter.Thread then
			Brew:endThread(Brew.Features.Jitter.Thread["Message"])
			Brew.Features.Jitter.Thread = nil

			-- 🧹 Jitter Cleanup
			Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
		end

		if Brew.Features.Jitter.Enabled then
			Character:FindFirstChildOfClass("Humanoid").AutoRotate = false

			local Root = Character:FindFirstChild("HumanoidRootPart")
			local Camera = workspace.CurrentCamera
			local t = 0

			Brew.Features.Jitter.Thread = Brew:Thread(function()
				if not Root or not Root.Parent or not Camera then
					return
				end

				t += 1 * 140
				local jitterY = math.sin(t) * math.rad(math.random(30, 40)) * (math.random() > 0.5 and 1 or -1)

				local camLook = Camera.CFrame.LookVector
				local rootPos = Root.Position
				local targetPos = rootPos + Vector3.new(camLook.X, 0, camLook.Z).Unit

				Root.CFrame = CFrame.new(rootPos, targetPos) * CFrame.Angles(0, jitterY, 0)
			end, 0.03)
		end
	end,
}

Brew.Features.Flicker = {
	Name = "Flicker",
	Enabled = false,
	Thread = nil,
	Thread2 = nil,
	Function = function(self, enabled: boolean)
		if Brew.Features.Flicker.Debounce then
			return
		end

		Brew.Features.Flicker.Enabled = enabled

		if Brew.Features.Flicker.Thread then
			Brew:endThread(Brew.Features.Flicker.Thread.Message)
			Brew.Features.Flicker.Thread = nil
		end

		Brew.Features.Flicker.Debounce = true
		if Brew.Features.Flicker.Enabled then
			Character.Archivable = true
			Brew.Features.Flicker.Character = Character
			Character.Humanoid:UnequipTools()

			local Lighting = game:GetService("Lighting")
			local Clone = Character:Clone()
			Clone.Parent = Lighting
			Clone.Name = ""
			Brew.Features.Flicker.Clone = Clone

			local cachedPos = Character.HumanoidRootPart.CFrame
			Brew.Features.Flicker.Thread = Brew:Thread(function()
				Brew.Features.Flicker.Character:MoveTo(
					Vector3.new(
						Player.Character.HumanoidRootPart.CFrame.X,
						Player.Character.HumanoidRootPart.CFrame.Y - 5,
						Player.Character.HumanoidRootPart.CFrame.Z
					)
				)
			end, 0.01)

			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			wait(0.2)
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

			Clone = Clone
			Brew.Features.Flicker.Character.Parent = Lighting
			Clone.Parent = workspace
			Clone.HumanoidRootPart.CFrame = cachedPos
			Player.Character = Clone

			workspace.CurrentCamera:Destroy()
			wait(0.1)
			repeat
				wait()
			until Character ~= nil
			workspace.CurrentCamera.CameraSubject = Player.Character:FindFirstChildWhichIsA("Humanoid")
			workspace.CurrentCamera.CameraType = "Custom"
			Player.CameraMinZoomDistance = 0.5
			Player.CameraMaxZoomDistance = 400
			Player.CameraMode = "Classic"
			Player.Character.Head.Anchored = false
			Player.Character.Animate.Disabled = true
			Player.Character.Animate.Disabled = false

			local Died
			Died = Clone.Humanoid.Died:Connect(function()
				Player.Character = Brew.Features.Flicker.Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA("Humanoid"):Destroy()
				Died:Disconnect()
			end)
		else
			local cachedCFrame = Player.Character.HumanoidRootPart.CFrame
			Brew.Features.Flicker.Character.HumanoidRootPart.CFrame = cachedCFrame
			Brew.Features.Flicker.Clone:Destroy()
			Player.Character = Brew.Features.Flicker.Character
			Character = Player.Character
			Player.Character.Parent = workspace
			Player.Character.Animate.Disabled = true
			Player.Character.Animate.Disabled = false

			for i, Tool in pairs(Player.Backpack:GetChildren()) do
				if Tool:IsA("Tool") then
					Brew:Spoof(Character.Humanoid, "WalkSpeed", 16)
					Brew:Spoof(Brew.Features.getHandle(), "Size", Brew.Configuration.defaultSize)
					Character.Humanoid:EquipTool(Tool)
				end
			end
		end
		wait(.25)
		Brew.Features.Flicker.Debounce = false
	end,
}

Brew.Features.swordGiver = {
	Name = "Sword Giver",
	Enabled = false,
	Function = function(self, swords: table)
		for i, Sword in pairs(Brew.Configuration.gameSwords) do
			if swords[Sword] and not Player.PlayerStats.PlayerSwords:FindFirstChild(Sword) then
				local newSword = Instance.new("BoolValue", Player.PlayerStats.PlayerSwords)
				newSword.Value = true
				newSword.Name = Sword
				newSword.Parent = Player.PlayerStats.PlayerSwords
			elseif not swords[Sword] then
				if Player.PlayerStats.PlayerSwords:FindFirstChild(Sword) then
					Player.PlayerStats.PlayerSwords:FindFirstChild(Sword):Destroy()
				end
			end
		end
	end,
}

Brew.Features.Tank = {
	Name = "Tank",
	Enabled = false,
	Function = function(self, enabled: boolean)
		Brew.Features.Tank.Enabled = enabled

		for i, Part in pairs(Character:GetChildren()) do
			if Part:IsA("BasePart") then
				Brew:Spoof(Part, "CanTouch", true)
				Part.CanTouch = Brew.Features.Tank.Enabled
			end
		end
	end,
}

Brew.Features.Speed = {
	Name = "Speed",
	Enabled = false,
	Thread = nil,
	Cache = {
		sameThread = false,
		Speed = 16,
	},
	Function = function(self, value: int)
		value = value or Brew.Features.Speed.Cache.Speed
		Brew.Features.Speed.Cache.Speed = value
		Brew.Features.Speed.Cache.sameThread = false
		if Brew.Features.Speed.Thread then
			Brew:endThread(Brew.Features.Speed.Thread["Message"])
			Brew.Features.Speed.Thread = nil
		end

		Brew.Features.Speed.Thread = Brew:Thread(function()
			Brew:Spoof(Character.Humanoid, "WalkSpeed", 16)
			if tonumber(value) >= 25 then
				Character.Humanoid.WalkSpeed = 24
				if not Brew.Features.Speed.Cache.sameThread then
					Brew.Notify("[Speed] Defaulted to 24 to prevent rubberbanding (lagback)")
					Brew.Features.Speed.Cache.sameThread = true
				end
			else
				Character.Humanoid.WalkSpeed = tonumber(value)
			end
		end, 0.1)
	end,
}

for i, Feature in Brew.Features do -- 😋 Metatable Magic
	setmetatable(Feature, {
		__call = function(table, ...)
			local s, e = pcall(table.Function, ...)

			if s then
				-- Brew.debugNotify("hi lol argument return on", Feature.Name .. ":", e)
				return e
			else
				Brew.debugNotify("Error while calling", Feature.Name .. ":", e)
			end
		end,
	})
end

--< Brew Interface >--
local reachGroup = Window:TabGroup()
local reachTab = reachGroup:Tab({
	Name = "Reach",
	Image = "rbxassetid://10709818534",
})
local reachSection = reachTab:Section({
	Side = "Left",
})

local reachToggle = reachSection:Toggle({
	Name = "Reach",
	Default = false,
	Callback = function(t)
		Brew.Features:Reach(t)
	end,
})
local reachRadius = reachSection:Slider({
	Name = "Reach Radius",
	Default = 5,
	Minimum = 1,
	Maximum = 20,
	DisplayMethod = "Round",
	Callback = function(t)
		Brew.Configuration.reachVector = Vector3.new(t, t, t)
		Brew.Configuration.reachRadius = t

		Brew.Features:Reach(Brew.Features.Reach.Enabled)
	end,
})
local reachMethod = reachSection:Dropdown({
	Name = "Reach Method",
	Search = false,
	Multi = true,
	Required = true,
	Options = Brew.Configuration.allowedMethods,
	Default = { Brew.Configuration.allowedMethods[1] },
	Callback = function(t)
		Brew.Configuration.reachMethod = t

		Brew.Features:Reach(Brew.Features.Reach.Enabled)
	end,
})
local reachType = reachSection:Dropdown({
	Name = "Reach Type",
	Search = false,
	Multi = false,
	Required = true,
	Options = {
		"Box",
		"Linear",
		"Wide",
	},
	Default = 1,
	Callback = function(t)
		Brew.Configuration.reachType = t

		Brew.Features:Reach(Brew.Features.Reach.Enabled)
	end,
})
reachSection:Dropdown({
	Name = "Reach Preset",
	Search = false,
	Multi = false,
	Required = true,
	Options = {
		"Closet",
	},
	Callback = function(t)
		if t == "Closet" then
			Brew.Configuration.reachVector = Vector3.new(5, 5, 5)
			Brew.Configuration.reachRadius = 5
			Brew.Configuration.reachMethod = Brew.Configuration.allowedMethods[1]

			reachMethod:UpdateSelection({ Brew.Configuration.allowedMethods[1] })
			reachType:UpdateSelection("Wide")
			reachRadius:UpdateValue(5)

			Brew.Features:Reach(Brew.Features.Reach.Enabled)
		end
	end,
})
reachSection:Toggle({
	Name = "Damage Amplification",
	Default = false,
	Callback = function(t)
		Brew.Configuration.damageAmplification = t

		Brew.Features.Reach:damageAmplification(Brew.Features.Reach.Enabled)
	end,
})
reachSection:SubLabel({
	Text = "Please be advised your exploit may not be able to completely prevent anti-cheat measures",
})

local visualSection = reachTab:Section({
	Side = "Right",
})
visualSection:Toggle({
	Name = "View Hitbox",
	Default = false,
	Callback = function(t)
		local Color = Brew.Configuration.Color
		local Alpha = Brew.Configuration.Alpha

		Brew.Features:viewHitbox(t)
	end,
})
visualSection:Toggle({
	Name = "View Roots",
	Default = false,
	Callback = function(t)
		local Color = Brew.Configuration.Color
		local Alpha = Brew.Configuration.Alpha

		Brew.Features:viewRoots(t)
	end,
})
visualSection:Colorpicker({
	Name = "Color",
	Default = Color3.fromRGB(255, 255, 255),
	Alpha = 0,
	Callback = function(color, alpha)
		Brew.Configuration.Color = color
		Brew.Configuration.Alpha = alpha

		Brew.Features:viewHitbox(Brew.Features.viewHitbox.Enabled)
		Brew.Features:viewRoots(Brew.Features.viewRoots.Enabled)
	end,
})

local characterTab = reachGroup:Tab({
	Name = "Character",
	Image = "rbxassetid://10747373176",
})
local characterSection = characterTab:Section({
	Side = "Left",
})

characterSection:Input({
	Name = "Speed",
	Placeholder = "1-24",
	AcceptedCharacters = "Numeric",
	Callback = function(input)
		if Brew.Configuration.spoofMethod ~= "none" then
			Brew.Features:Speed(tonumber(input))
		else
			Brew.Notify("[Speed] Your exploit cannot support this feature properly")
		end
	end,
})

characterSection:Toggle({
	Name = "Spin",
	Default = false,
	Callback = function(t)
		Brew.Features:Spin(t)
	end,
})

local flickerToggle = characterSection:Toggle({
	Name = "Flicker",
	Default = false,
	Callback = function(t)
		Brew.Features:Flicker(t)
	end,
})

characterSection:Toggle({
	Name = "Tank",
	Default = false,
	Callback = function(t)
		Brew.Features:Tank(t)
	end,
})

local legitTab = reachGroup:Tab({
	Name = "Legit",
	Image = "rbxassetid://10734906580",
})
local legitSection = legitTab:Section({
	Side = "Left",
})
local jitterToggle = legitSection:Toggle({
	Name = "Jitter",
	Default = false,
	Callback = function(t)
		Brew.Features:Jitter(t, "user")
	end,
})
legitSection:SubLabel({
	Text = "This can be paired with damage amplification",
})
legitSection:SubLabel({
	Text = "Features here were made & tested live to determine legitimacy, what may look suspicious on your screen does not reflect to other players",
})

local environmentTab = reachGroup:Tab({
	Name = "Environment",
	Image = "rbxassetid://10723404337",
})
local environmentSection = environmentTab:Section({
	Side = "Left",
})
local orbExpander = environmentSection:Toggle({
	Name = "Orb Expander",
	Default = false,
	Callback = function(t)
		Brew.Features:orbExpander(t)
	end,
})
local swordGiverTab = environmentSection:Dropdown({
	Name = "Sword Giver",
	Search = true,
	Multi = true,
	Required = false,
	Options = Brew.Configuration.gameSwords,
	Callback = function(t)
		Brew.Features:swordGiver(t)
	end,
})
if game.GameId ~= 3737753748 then
	orbExpander:SetVisibility(false)
	swordGiverTab:SetVisibility(false)
end
environmentSection:SubLabel({
	Text = "If this page is empty for you, the game you've joined likely has no cheats yet, feel free to request some!",
})

local customizeGroup = Window:TabGroup()
local customizeTab = customizeGroup:Tab({
	Name = "Customize",
	Image = "rbxassetid://10709810948",
})
local customizeSection = customizeTab:Section({
	Side = "Left",
})
local customizeSection2 = customizeTab:Section({
	Side = "Right",
})
customizeSection:Toggle({
	Name = "Notifications",
	Default = true,
	Callback = function(t)
		Brew.Configuration.Notifications = t
	end,
})
customizeSection:Toggle({
	Name = "Debug Notifications",
	Default = false,
	Callback = function(t)
		Brew.Configuration.debugNotifications = t
	end,
})
customizeSection:Button({
	Name = "UI Scale",
	Callback = function()
		if Window:GetScale() == originalScale then
			Window:SetScale(originalScale * 0.55)
		else
			Window:SetScale(originalScale)
		end
	end,
})
customizeSection:Button({
	Name = "Rejoin",
	Callback = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end,
})
customizeSection:Keybind({
	Name = "Reach Keybind",
	Default = Enum.KeyCode.R,
	Callback = function(binded)
		reachToggle:UpdateState(not Brew.Features.Reach.Enabled)
	end,
	onBinded = function(bind)
		Brew.Notify("Binded", "Reach to", bind)
	end,
})
customizeSection:Keybind({
	Name = "Jitter Keybind",
	Default = Enum.KeyCode.G,
	Callback = function(binded)
		jitterToggle:UpdateState(not Brew.Features.Jitter.Enabled)
	end,
	onBinded = function(bind)
		Brew.Notify("Binded", "Jitter to", bind)
	end,
})
customizeSection:Keybind({
	Name = "Flicker Keybind",
	Default = Enum.KeyCode.Z,
	Callback = function(binded)
		flickerToggle:UpdateState(not Brew.Features.Flicker.Enabled)
	end,
	onBinded = function(bind)
		Brew.Notify("Binded", "Flicker to", bind)
	end,
})


--< Brew Mobile >--
if debug.info(2, "f") == nil then
	Window:Notify({
		Title = "Brew",
		Description = "Outdated script, please use the loadstring for the latest updates & security features",
		Lifetime = 5,
		Scale = 1.2,
		Style = "Cancel",
	})
end

if Brew.Configuration.isMobile then
	Window:Dialog({
		Title = "Brew",
		Description = "Would you like to make the UI smaller? You can toggle this in the customization tab",
		Buttons = {
			{
				Name = "Confirm",
				Callback = function()
					Window:SetScale(originalScale * 0.55)
				end
			},
			{
				Name = "Cancel",
			}
		},
	})

	task.wait(2)
    local ScreenGui = Instance.new("ScreenGui")
    local ImageButton = Instance.new("ImageButton")
	
    ScreenGui.Parent = gethui() or game.CoreGui
	ScreenGui.ScreenInsets = Enum.ScreenInsets.None
	ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    -- ScreenGui.DisplayOrder = 2147483647

    ImageButton.Parent = ScreenGui
    ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageButton.BackgroundTransparency = 1.000
    ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageButton.BorderSizePixel = 0
    ImageButton.Position = UDim2.new(0.399686515, 0, 0.462569833, 0)
    ImageButton.Size = UDim2.new(0, 66, 0, 66)
    ImageButton.Image = "rbxassetid://12807028788"

    local dragging = false
    local dragInput, dragStart, startPos
	local Hidden = false

    ImageButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ImageButton.Position
			Hidden = not Hidden
			Window:SetState(Hidden)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ImageButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            ImageButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--< Brew Integrity >--
Brew:Thread(function() -- 🗑️ Garbage Collector
	local Amount = 0
	for i = #Brew._Temp, 1, -1 do
		local Table = Brew._Temp[i]
		if Table.index.Parent == nil then
			table.remove(Brew._Temp, i)
			Amount += 1
		end
	end
	if Amount > 0 then
		Brew.debugNotify("Garbage Collection cleaned", Amount, "object(s)")
	end
end, 30)

Player.CharacterAdded:Connect(function(newCharacter) -- 💩💩
	Character = newCharacter
	local Sword = Brew.Features:getSword()
	local Handle = Brew.Features:getHandle() -- 🔄️ acts as a wait

	for i, feature in pairs(Brew.Features) do
		if feature.Name == "Flicker" then
			continue
		end

		--/ Refresh Settings /--
		task.spawn(function()
			pcall(function()
				feature:Function(feature.Enabled, "auto")
			end)
		end)
	end
end)

if Brew.Configuration.spoofMethod == "metamethod" then
    if hookmetamethod then
        local old
        old = hookmetamethod(game, "__index", function(i, v)
            if not checkcaller() then
                local instTable = Brew._Temp[i]
                if instTable and instTable[v] ~= nil then
                    return instTable[v]
                end
            end
            return old(i, v)
        end)
    end
elseif Brew.Configuration.spoofMethod == "metatable" then
    Brew.Notify("[Spoof] You are using", Brew.Configuration.spoofMethod, "spoofing, it may be unstable")

    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index

    mt.__index = newcclosure(function(i, v)
        if not checkcaller() then
            local instTable = Brew._Temp[i]
            if instTable and instTable[v] ~= nil then
                return instTable[v]
            end
        end
        return oldIndex(i, v)
    end)
end
