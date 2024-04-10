--!strict
--!nolint LocalUnused
-- (c) Studio Elttob 2024. All rights reserved, seek permission before use.

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent
local plugin = script:FindFirstAncestorWhichIsA("Plugin") :: Plugin
-- LibOpen
local Oklab = require(Package.LibOpen.Oklab)
local Fusion = require(Package.LibOpen.Fusion)
local peek, scoped, doCleanup = Fusion.peek, Fusion.scoped, Fusion.doCleanup
local New, Children, OnEvent, OnChange, Out, Ref = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref
local Tween, Spring = Fusion.Tween, Fusion.Spring
-----

local chroma = 0.15
local hues = {
	0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 
	250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350
}
local lightnesses = {
	0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0
}

local cellSize = UDim2.fromOffset(28, 28)
local padding = UDim.new(0, 0)

return function(parent)
	local scope = scoped(Fusion)

	local colourText = scope:Value("")
	local highlightedHue = scope:Value(nil :: number?)
	local highlightedLightness = scope:Value(nil :: number?)

	scope:New "Frame" {
		Parent = parent,
		BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			scope:New "UIListLayout" {
				SortOrder = "LayoutOrder",
				FillDirection = "Vertical",
				HorizontalAlignment = "Center",
				VerticalAlignment = "Center",
				Padding = padding
			} :: any,

			scope:New "TextLabel" {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(200, 50),

				Text = colourText,
				TextSize = 28
			},

			scope:New "Frame" {
				BackgroundTransparency = 1,
				AutomaticSize = "XY",

				[Children] = {
					scope:New "UIListLayout" {
						SortOrder = "LayoutOrder",
						FillDirection = "Horizontal",
						HorizontalAlignment = "Center",
						VerticalAlignment = "Center",
						Padding = padding
					} :: any,

					scope:New "TextLabel" {
						BackgroundTransparency = 1,
						Size = cellSize,

						Text = "",
					},
		
					scope:ForPairs(hues, function(use, scope: typeof(scope), index, hue)
						return index, scope:New "TextLabel" {
							BackgroundColor3 = Color3.new(0, 0, 0),
							BackgroundTransparency = scope:Computed(function(use)
								if use(highlightedHue) == hue then
									return 0
								else
									return 1
								end
							end),
							Size = cellSize,

							Text = hue,
							TextColor3 = scope:Computed(function(use)
								if use(highlightedHue) == hue then
									return Color3.new(1, 1, 1)
								else
									return Color3.new(0, 0, 0)
								end
							end),

							[Children] = scope:New "UICorner" {
								CornerRadius = UDim.new(1, 0)
							}
						}
					end)
				}
			},

			scope:ForPairs(lightnesses, function(use, scope: typeof(scope), index, lightness)
				return index, scope:New "Frame" {
					BackgroundTransparency = 1,
					AutomaticSize = "XY",

					[Children] = {
						scope:New "UIListLayout" {
							SortOrder = "LayoutOrder",
							FillDirection = "Horizontal",
							HorizontalAlignment = "Center",
							VerticalAlignment = "Center",
							Padding = padding
						} :: any,

						scope:New "TextLabel" {
							BackgroundColor3 = Color3.new(0, 0, 0),
							BackgroundTransparency = scope:Computed(function(use)
								if use(highlightedLightness) == lightness then
									return 0
								else
									return 1
								end
							end),
							Size = cellSize,

							Text = lightness,
							TextColor3 = scope:Computed(function(use)
								if use(highlightedLightness) == lightness then
									return Color3.new(1, 1, 1)
								else
									return Color3.new(0, 0, 0)
								end
							end),

							[Children] = scope:New "UICorner" {
								CornerRadius = UDim.new(1, 0)
							}
						},
			
						scope:ForPairs(hues, function(use, scope: typeof(scope), index, hue)
							local colour = Oklab.linear_srgb_to_color3(
								Oklab.oklab_to_linear_srgb(
									Oklab.oklch_to_oklab(
										Vector3.new(lightness, chroma, hue / 360)
									)
								)
							)
							local text = "#" .. colour:ToHex()
							return index, scope:New "Frame" {
								BackgroundColor3 = colour,
								Size = cellSize,

								[OnEvent "MouseEnter"] = function()
									highlightedHue:set(hue)
									highlightedLightness:set(lightness)
									colourText:set(text)
								end,

								[Children] = {
									scope:New "Frame" {
										Position = UDim2.fromScale(0.5, 0.5),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Size = UDim2.fromScale(0.1, 0.1),
										BackgroundColor3 = Color3.new(1, 1, 1),
									}
								}
							}
						end)
					}
				}
			end)
		}
	}

	return function()
		doCleanup(scope)
	end
end