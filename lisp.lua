
-- Symbol
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

-- Cons
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

-- returns type
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

-- functions
function car(l)
	assert(ltype(l) == 'cons', 'requires cons')
	return l:car()
end
function cdr(l)
	assert(ltype(l) == 'cons', 'requires cons')
	return l:cdr()
end
function cadr(l)
	return car(cdr(l))
end
function caddr(l)
	return car(cdr(cdr(l)))
end
function cadddr(l)
	return car(cdr(cdr(cdr(l))))
end

function list(...)
	l = {...}
	if #l == 0 then
		return nil
	else
		return Cons.new(l[1], list(unpack(l, 2)))
	end
end

