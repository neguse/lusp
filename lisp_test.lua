
require("busted.runner")
require("lisp")

describe("symbol test", function()

	describe("given same symbol", function()
		local s_a = Symbol.new("a")
		it("should equal", function()
			assert.are.equal(s_a, s_a)
		end)
	end)

	describe("given different symbol", function()
		local s_a = Symbol.new("a")
		local s_b = Symbol.new("b")
		it("should not equal", function()
			assert.are_not.equal(s_a, s_b)
		end)
	end)

	describe("given two symbol from same string", function()
		local s_a1 = Symbol.new("a")
		local s_a2 = Symbol.new("a")
		it("should equal", function()
			assert.are.equal(s_a1, s_a2)
		end)
	end)
end)

describe("cons test", function()

	describe("given cons", function()
		local c = Cons.new(1, 2)
		it("should retrieve car and cdr", function()
			assert.are.equal(c:car(), 1)
			assert.are.equal(c:cdr(), 2)
		end)
		it("should overwrite with set_car", function()
			c:set_car(3)
			assert.are.equal(c:car(), 3)
		end)
		it("should overwrite with set_cdr", function()
			c:set_cdr(4)
			assert.are.equal(c:cdr(), 4)
		end)
	end)
end)

describe("list test", function()
	it("tests", function()
		assert.are.same(list(), nil)
		assert.are.same(list(1), Cons.new(1, nil))
		assert.are.same(list(1, 2), Cons.new(1, Cons.new(2, nil)))
	end)
end)

describe("length test", function()
	it("tests", function()
		assert.are.equal(length(nil), 0)
		assert.are.equal(length(list(1)), 1)
		assert.are.equal(length(list(1, 2)), 2)
		assert.are.equal(length(list(1, 2, 3)), 3)
		assert.are.equal(length(list(Cons.new(1, 2), 2, 3)), 3)
	end)
end)

