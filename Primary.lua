
local class = nil -- require middleclass here

local 
local dock = class("Dock")
function dock:initialize(id,parent)
	--[[
		@Purpose: create new instance of dock
		@Params: Identifier (name), parent (required)
		@Returns: Dock instance
	]]
 	table.insert(parent.Children,1,self)
 	self.Name = id
	self.Parent = parent
	self.Children = {}
	self.Visible = false
	self.Vector = {
		obj = nil,
		direction = nil
		portion = 1
	}
end
