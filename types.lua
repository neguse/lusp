
-- Implementation of Symbol

Symbol = {}
Symbol.__index = Symbol

function Symbol.new(s)
	return setmetatable({s}, Symbol)
end

function Symbol:__tostring()
	return self[1]
end

function Symbol:__eq(o)
	return self[1] == o[1]
end

-- Implementation of Cons

Cons = {}
Cons.__index = Cons

function Cons.new(car, cdr)
	return setmetatable({car, cdr}, Cons)
end

function Cons:car()
	return self[1]
end

function Cons:cdr()
	return self[2]
end

function Cons:set_car(a)
	self[1] = a
end

function Cons:set_cdr(d)
	self[2] = d
end

function ltype(v)
	t = type(v)
	if t ~= 'table' then
		return t
	else
		meta = getmetatable(v)
		if meta == Symbol then
			return 'symbol'
		elseif meta == Cons then
			return 'cons'
		end
		return 'unknown'
	end
end

