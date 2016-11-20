
require("types")

function true_p(e)
	return e == true
end

function list(...)
	l = {...}
	if #l == 0 then
		return nil
	else
		return Cons.new(l[1], list(unpack(l, 2)))
	end
end

