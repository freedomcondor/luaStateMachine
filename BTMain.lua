local BT = require('BehaviourTree')
require("debugger")

local count = 0

local a = BT.Sequence:new{
	id = "theBTtest",
	BT.Sequence:new{
		id = "Sequence",
		BT:new{ run = function()
			return true
		end,},

		BT.Selector:new{ 
			BT:new{ run = function()
				print("i am select 1")
				return false
			end,},

			BT.Looper:new{ times = 5,
				BT:new{ run = function()
					print("i am select 2")
					return false
				end,},
			},

			BT:new{ run = function()
				print("i am select 3")
				return false
			end,},
		},

		BT:new{ run = function()
			print("i am 3")
			return false
		end,},
	},
}

for i = 1, 20 do
	print("step", i, "-----------------")
	a:run()	-- run means a step
end

