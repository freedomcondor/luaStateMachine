------------------------------------------------------
-- a lua Behaviour Tree
-- Weixu Zhu (Harry)
-- 		zhuweixu_harry@126.com
-- version 1.0
-- 		basic sequence, selector, looper
------------------------------------------------------
function tableCopy(x)
	local image = {}
	setmetatable(image,getmetatable(x))
	if type(x) ~= "table" then return x end
	for index,value in pairs(x) do
		image[index] = tableCopy(value)
	end
	return image
end
------------------------------------------------------
-- Behaviour Tree
------------------------------------------------------
local BehaviourTree = {CLASSBEHAVIOURTREE = true}
BehaviourTree.__index = BehaviourTree

function BehaviourTree:new(option)
	return self:create(option)
end

function BehaviourTree:create(option)
	local instance = {}
	setmetatable(instance, self)

	-- validation check
	if option == nil then return nil end

	-- copy configuration
	instance.id = option.id
	for i, v in ipairs(option) do
		instance[i] = tableCopy(v)
	end
	instance.run = option.run

	instance.current = 0

	return instance
end

------------------------------------------------------
-- Sequence
------------------------------------------------------
BehaviourTree.Sequence = {CLASSBEHAVIOURTREESEQUENCE = true}
BehaviourTree.Sequence.__index = BehaviourTree.Sequence
setmetatable(BehaviourTree.Sequence, BehaviourTree)

function BehaviourTree.Sequence:new(option)
	return self:create(option)
end

function BehaviourTree.Sequence:create(option)
	local instance = BehaviourTree:create(option)
	setmetatable(instance, self)
	instance.lastReturn = true
	return instance
end

function BehaviourTree.Sequence:run()
	local ret = self.lastReturn
	if self.lastReturn == "running" then
		ret = self[self.current]:run()
	end
	while ret == true do
		self.current = self.current + 1
		if self[self.current] == nil then
			ret = true
			break
		else
			if type(self[self.current].run) == "function" then
				ret = self[self.current]:run()
			else 
				ret = false
			end
		end
	end
	if ret == true or ret == false then
		self.current = 0
		self.lastReturn = true
	else
		self.lastReturn = ret
	end
	return ret
end
------------------------------------------------------
-- Selector
------------------------------------------------------
BehaviourTree.Selector = {CLASSBEHAVIOURTREESELECTOR= true}
BehaviourTree.Selector.__index = BehaviourTree.Selector
setmetatable(BehaviourTree.Selector, BehaviourTree)

function BehaviourTree.Selector:new(option)
	return self:create(option)
end

function BehaviourTree.Selector:create(option)
	local instance = BehaviourTree:create(option)
	setmetatable(instance, self)
	instance.lastReturn = false
	return instance
end

function BehaviourTree.Selector:run()
	local ret = self.lastReturn
	if self.lastReturn == "running" then
		ret = self[self.current]:run()
	end
	while ret == false do
		self.current = self.current + 1
		if self[self.current] == nil then
			ret = false
			break
		else
			if type(self[self.current].run) == "function" then
				ret = self[self.current]:run()
			else 
				ret = false
			end
		end
	end
	if ret == true or ret == false then
		self.current = 0
		self.lastReturn = false
	else
		self.lastReturn = ret
	end
	return ret
end
------------------------------------------------------
-- Looper
------------------------------------------------------
BehaviourTree.Looper = {CLASSBEHAVIOURTREELOOPER = true}
BehaviourTree.Looper.__index = BehaviourTree.Looper
setmetatable(BehaviourTree.Looper, BehaviourTree)

function BehaviourTree.Looper:new(option)
	return self:create(option)
end

function BehaviourTree.Looper:create(option)
	local instance = BehaviourTree:create(option)
	setmetatable(instance, self)
	instance.count = 0
	instance.times = option.times
	instance.current = 1
	return instance
end

function BehaviourTree.Looper:run()
	if self.count ~= self.times then
		if type(self[self.current].run) == "function" then
			self[self.current]:run()
		end
		self.count = self.count + 1
	end
	if self.count == self.times then
		self.count = 0
		return true
	else
		return "running"
	end
end

return BehaviourTree
