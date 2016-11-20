
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

