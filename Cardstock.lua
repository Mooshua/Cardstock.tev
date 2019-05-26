--[[

	Cardstock(tev)

	This is an oop system for a UI renderer, designed to make development of interfaces easier on tevdev members.

	(C) 2019 Teverse. All rights reserved.
	Written by @Mooshua (repl.it / Github / Teverse)

	Section 0: Preface
	 - Create globals	
	 - Prepare for section 1

]]

print("Cardstock.tev (1001) is starting")

local middleclass = require "middleclass"

function find(n,h) for i,g in pairs(h) do if g == n then return i end end end

function search(n,h) for i,g in pairs(h) do if i == n then return g end end end

function concat(tab)
	local ret = ""
	if type(tab) == "table" then
		for a,b in pairs(tab) do
			local s,e = pcall(function() ret = ret .. ", " .. a .. ": " .. b end)
			if s == false then print(e,b) end
		end
	else
		ret = tostring(tab)
	end
	return ret
end

--[[

	Section 1: Backend
	 - Create root class
	 - Create builtins
	 - Lock down metamethods

	Dependencies:
	 - middleclass (lib)

]]


local root = middleclass("Root")

function root:initialize(properties,build,...)
	rawset(self,"_advanced",true)
	
	self["properties"] = build
	for key,value in pairs(properties or {}) do
		if self.properties[key] and type(properties[key])==type(self.properties[key]) then
			self.properties[key] = value
		end
	end
	self["Cardstock"] = true
	self["children"] = {...} or {}
	for _,child in pairs(children or {parent=nil}) do
		child.parent = self
	end
	rawset(self,"_advanced",false)
end

-- Begin builtins

function root:getFirstChild(name)
	for i,child in pairs(rawget(self,"children")) do
		if child.name == name then				
			return child,i
		end
	end	
end

-- Begin backend

function root:_addChild(child)
	rawset(self,"_advanced",true)
	table.insert(self.children,1,child)
	rawset(self,"_advanced",false)
end

-- Begin metamethods

function root:__tostring()
	return self.name
end

function root:__eq(a,b)
	error("__eq not supported yet due to lua inconsistencies. Sorry. :(")
end

function root:__newindex(table,key,value)

	if rawget(self,"_advanced") then
		return rawset(self,table,key)
	end
	print(table,key,value,"new",type(table))

	if table == "parent" then
		if rawget(key,"Cardstock") then
			key:_addChild(self)
			rawset(rawget(self,"properties"),"parent",self)
		end
	end

	--error("No new indexes should be made to instance "..self.name..".")
end

function root:__index(table,...)
	--print(table,type(table),...,"yikes")

	if rawget(self,"_advanced") then
		return rawget(self,table)
	end

	local properties = rawget(self,"properties")
	if properties == nil and type(properties) ~= "table" then
		print("Cardstock: Warning, properties do not exist on an object")
	else
		for tag,val in pairs(properties) do
			local small = string.sub(string.lower(table),1,1)..string.sub(table,2,-1)
			if tag == table or small == tag then
				return val
			end
		end
	end

	local children = rawget(self,"children")
	if children == nil and type(children) ~= "table" then
		print("Cardstock: Warning, children do not exist on an object")
	else
		for id,child in pairs(children) do
			if rawget(rawget(child,"properties"),"name") == table then
				return child
			end
		end
	end

	return nil
end

--[[

	Section 1: Epilogue:
	 - Created base class (root) that behaves well in a parent-child oop environment.
	 - allowed base class to have expansions defined by children, not user
	 - created builtin functions

	Section 2: Main Classes
	 - Create generic Classes
	 - Start state implementations
	 - Define builtins
]]

local frame = middleclass("Frame",root)

function frame:initialize(properties,...)
	local build = {
		name="guiFrame",
		size=guiCoord(0,100,0,100),
		position=guiCoord(0.5,-50,0.5,-50),
		color=colour(1,1,1),
        visible=true,
        align=enum.align.middle,
	}
	
    root.initialize(self,properties,build,...)
    
    rawset(self,"_define",function(parent)
        local a = engine.construct("guiFrame",parent,{position=self.position,size=self.size,style=enum.guiStyle.basic,})
        return a
    )
end

local button = middleclass("Button",root)

function button:initialize(properties,...)
    local build = {
		name="guiButton",
		size=guiCoord(0,100,0,100),
		position=guiCoord(0.5,-50,0.5,-50),
		color=colour(1,1,1),
        visible=true,
        text="Button",
        align=enum.align.middle,
	}
	
    root.initialize(self,properties,build,...)
    
    rawset(self,"_define",function(parent)
        local a = engine.construct("guiButton",parent,{position=self.position,cropChildren=true,size=self.size,style=enum.guiStyle.basic,})
        local cC = nil
        a:mouseLeftPressed(function()
            wait(0.01)
            local mouse = engine.input.mousePosition
            cC = engine.construct("guiImage",a,{size=guiCoord(0,0,0,0),position=guiCoord(0,mousePosition.x-self.position:getScreenPosition().x,0,mousePosition.y-self.position:getScreenPosition().y),align=enum.align.middle,texture="fa:circle",style=enum.guiStyle.noBackground,imageColour=colour(1,1,1)})
            engine.tween:begin(cC,0.25,{size=guiCoord(1.2,0,(self.size.offsetX/self.size.offsetY)*1.2,0)},"outQuad")
        end)
        a:mouseLeftReleased(function())
            engine.tween:begin(cC,0.3,{imageTransparency=1},"linear")
        end
        return a
    )
end

local classes = {
    ["frame"] = frame
    ["button"] = button
}

--[[

	Section 2: Epilogue:
	 - Created base classes, each defining their creation
	 - Did some stately work to effect the definition
	Section 3: Renderer
	 - Create renderer to parse commands, accept input
	 - Finish cardstock. :)
]]

local cardstock = {}

function cardstock:render(card,gui)
    local rendered = rawget(card,"_define")(gui)
    for _,child in pairs(rawget(card,"children"))
        render(child,rendered)
    end
    return rendered
end

function cardstock:construct(class,...)
    for name,val in pairs(classes) do
        if name == class then
            return val:new(...)
        end
    end
end


print("Cardstock: ready")

return cardstock
