local State = require('StateMachine')

local a = State:new{
	id = "testStateMachine",
	data = {i = 5},
	initMethod = function (data)
		data.i = 5
	end,
	substates = {
		a = State:new{
			id = "a",
			enterMethod = function(data)
				data.i = 5
				print("i am enter Method of a")
				return 1	-- jump to next step for trans
			end,
			transMethod = function(data)
				data.i = data.i - 1
				print("i am trans Method of a, i =",data.i)
				if data.i == 0 then
					return "b"
				end
			end,
			leaveMethod = function()
				print("i am leave Method of a")
			end,
		},
		b = State:new{
			id = "b",
			data = {i = 5},
			initMethod = function(data)
				data.i = 5
			end,
			enterMethod = function()
				print("i am enter Method of b")
			end,
			onExit = "c",
			leaveMethod = function()
				print("i am leave Method of b")
			end,
			initial = "b_a",
			substates = {
				b_a = State:new{
					enterMethod = function()
						print("i am enter Method of b_a")
					end,
					transMethod = function(fdata)
						fdata.i = fdata.i - 1
						print("i am trans Method of b_a")
						if fdata.i == 0 then
							return "b_b"
						end
					end,
					leaveMethod = function()
						print("i am leave Method of b_a")
					end,
				},
				b_b = State:new{
					enterMethod = function()
						print("i am enter Method of b_b")
					end,
					transMethod = function()
						print("i am trans Method of b_b")
						return "EXIT"
					end,
					leaveMethod = function()
						print("i am leave Method of b_b")
					end,
				},
			}
		},
		c = State:new{
			id = "c",
			enterMethod = function()
				print("i am enter Method of c")
			end,
			transMethod = function()
				print("i am trans Method of c")
				return "EXIT"
				--return "a"
			end,
			leaveMethod = function()
				print("i am leave Method of c")
			end,
		}
	},
	initial = "a",
}

print(a.id)
print(a.class)
a:run()
