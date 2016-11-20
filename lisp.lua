
function true_p(e)
	return e == true
end
function false_p(e)
	return e == false
end
function pair_p(l)
	return type(l) == 'table' and getmetatable(l) == Cons
end
function list_p(l)
	return null_p(l) or pair_p(l)
end
function null_p(l)
	return l == nil
end

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

-- functions
function car(l)
	assert(pair_p(l), 'requires pair')
	return l:car()
end
function cdr(l)
	assert(pair_p(l), 'requires pair')
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

function set_car(l, a)
	assert(pair_p(l), 'requires pair')
	l:set_car(l, a)
end
function set_cdr(l, d)
	assert(pair_p(l), 'requires pair')
	l:set_cdr(l, d)
end

function list(...)
	l = {...}
	if #l == 0 then
		return nil
	else
		return Cons.new(l[1], list(unpack(l, 2)))
	end
end

function length(e)
	assert(list_p(e), 'requires list')
	if null_p(e) then
		return 0
	else
		return 1 + length(cdr(e))
	end
end

