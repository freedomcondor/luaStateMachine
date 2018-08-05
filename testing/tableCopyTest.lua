State = require('StateMachine')
local test = {
	id = "test",
	a = 5,
	b = {
			test = 1,
			test2 = "test",
			c = function ()
					print("i am function in b\n")
				end
		},
	c = function()
			print("i  am function in test\n")
		end,

}

print("test = ")
for index,value in pairs(test) do
	print("test.",index,"=",value)
end

local image = tableCopy(test)
print("image = ")
for index,value in pairs(image) do
	print("test.",index,"=",value)
end
image.b.c()
image.c()

test.b = 7
test.c = function() print("i am changed\n") end
print("test = ")
for index,value in pairs(test) do
	print("test.",index,"=",value)
end
test.c()

print("image = ")
for index,value in pairs(image) do
	print("test.",index,"=",value)
end
image.b.c()
image.c()
