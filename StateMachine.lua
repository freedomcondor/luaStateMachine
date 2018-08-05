------------------------------------------------------
-- a lua State Machine
-- Weixu Zhu (Harry)
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
local StateMachine = {class = "CLASSSTATEMACHINE"}
StateMachine.__index = StateMachine

StateMachine.INIT = {class = "CLASSFLAG",id = "INIT"}	-- flag constant
StateMachine.EXIT = {class = "CLASSFLAG",id = "EXIT"}

function StateMachine:new(option)
	return self:create(option)
end

function StateMachine:create(option)
	local instance = {}
	setmetatable(instance,self)

	-- validation check
	if option == nil then return nil end
	if option.substates ~= nil and option.initial == nil then
		print("bad create option: there are substates, but no initial assigned\n")
		return nil
	end

	-- copy configuration
	instance.id = option.id
	instance.substates = tableCopy(option.substates)
	if instance.substates ~= nil then
		instance.substates.INIT = StateMachine.INIT
		instance.substates.EXIT = StateMachine.EXIT
	end
	instance.data = tableCopy(option.data) -- or nil?
	instance.onExit = tableCopy(option.onExit) -- or nil?

	if type(option.enterMethod) == "function" then
		instance.enterMethod = tableCopy(option.enterMethod)	-- else nil
	end
	if type(option.transMethod) == "function" then
		instance.transMethod = tableCopy(option.transMethod)
	end
	if type(option.leaveMethod) == "function" then
		instance.leaveMethod = tableCopy(option.leaveMethod)
	end
	if type(option.initMethod) == "function" then
		instance.initMethod = tableCopy(option.initMethod)
	end

	instance.currentState = StateMachine.INIT
	instance.initState = option.initial
	instance.nextState = option.initial
	
	return instance
end

function StateMachine:init()
	self.currentState = StateMachine.INIT
	self.nextState = self.initState
	if self.initMethod ~= nil then
		self.initMethod(self.data)
	end
end

function StateMachine:run()
	local count = 0
	print("count = ",count)
	local ret = self:step()
	while ret == 1 do
		a = io.read()
		count = count + 1
		print("count = ",count)
		ret = self:step()
	end
end

function StateMachine:step(para)	
-- return 1 means ongoing, return -1 means finish
	-- if I don't have substate, joking, return -1
	if self.substates == nil then
		return 1
	end

	-- check nextState
	if self.nextState ~= nil then
		if self.nextState == "EXIT" then
			self.nextState = nil
			self.currentState = StateMachine.EXIT
			return -1
		end
		print("nextState = ",self.nextState)
		if self.substates[self.nextState] ~= nil then
			self.currentState = self.substates[self.nextState]
			print("current id = ",self.currentState.id)
			print("current class = ",self.currentState.class)
			self.currentState:init()
			if self.currentState.enterMethod ~= nil then
				self.currentState.enterMethod(self.data)
			end
		end
	end

	-- check transMethod
	self.nextState = nil
	local retNext = nil
	if self.currentState.transMethod ~= nil then
		retNext = self.currentState.transMethod(self.data)
	end
	if retNext ~= nil then
		if self.currentState.leaveMethod ~= nil then
			self.currentState.leaveMethod(self.data)
		end
		self.nextState = retNext
		if retNext == "EXIT" then
			self.nextState = nil
			self.currentState = StateMachine.EXIT
			return -1
		else
			return 1
		end
	end

	-- run step
	local ret = nil
	if self.currentState.step ~= nil then
		ret = self.currentState:step(para)
	end
	if ret == -1 then
		print("onExit = ",self.currentState.onExit)
		if self.currentState.onExit ~= nil then
			self.nextState = self.currentState.onExit
			if self.currentState.leaveMethod ~= nil then
				self.currentState.leaveMethod(self.data)
			end
			if self.nextState == "EXIT" then 
				return -1 
			end
		end
	end

	return 1
end

return StateMachine