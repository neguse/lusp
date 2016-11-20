
require("lisp")

function tagged_list_p(l, tag)
	if pair_p(l) then
		return l:car() == tag
	end
	return false
end

-- compound procedure
function make_procedure(parameters, body, env)
	return list(Symbol.new('procedure'), parameters, body, env)
end
function compound_procedure_p(p)
	return tagged_list_p(p, Symbol.new('procedure'))
end
function procedure_parameters(p)
	return cadr(p)
end
function procedure_body(p)
	return caddr(p)
end
function procedure_environment(p)
	return cadddr(p)
end


function make_frame(vars, vals)
	return Cons.new(vars, vals)
end
function frame_variables(frame)
	return car(frame)
end
function frame_values(frame)
	return cdr(frame)
end
function extend_environment(vars, vals, base_env)
	if length(vars) == length(vals) then
		return make_frame(vars, vals)
	elseif length(vars) < length(vals) then
		error("Too many arguments supplied " .. tostring(vars) .. tostring(vals))
	else
		error("Too few arguments supplied " .. tostring(vars) .. tostring(vals))
	end
end

