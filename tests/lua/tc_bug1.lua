local env = environment()
local N   = Const("N")
local p   = Const("p")
local q   = Const("q")
local a   = Const("a")
local b   = Const("b")
local f   = Const("f")
local H1  = Const("H1")
local H2  = Const("H2")
local And = Const("and")
local and_intro = Const("and_intro")
local A   = Local("A", Bool)
local B   = Local("B", Bool)
env = add_decl(env, mk_var_decl("N", Type))
env = add_decl(env, mk_var_decl("p", mk_arrow(N, N, Bool)))
env = add_decl(env, mk_var_decl("q", mk_arrow(N, Bool)))
env = add_decl(env, mk_var_decl("f", mk_arrow(N, N)))
env = add_decl(env, mk_var_decl("a", N))
env = add_decl(env, mk_var_decl("b", N))
env = add_decl(env, mk_var_decl("and", mk_arrow(Bool, Bool, Bool)))
env = add_decl(env, mk_var_decl("and_intro", Pi({A, B}, mk_arrow(A, B, And(A, B)))))
env = add_decl(env, mk_var_decl("foo_intro", Pi({A, B}, mk_arrow(B, B))))
env = add_decl(env, mk_var_decl("foo_intro2", Pi({A, B}, mk_arrow(B, B))))
env = add_decl(env, mk_axiom("Ax1", q(a)))
env = add_decl(env, mk_axiom("Ax2", q(a)))
env = add_decl(env, mk_axiom("Ax3", q(b)))
local Ax1 = Const("Ax1")
local Ax2 = Const("Ax2")
local Ax3 = Const("Ax3")
local foo_intro  = Const("foo_intro")
local foo_intro2 = Const("foo_intro2")
local cs  = {}
local ng  = name_generator("foo")
local tc  = type_checker(env, ng, function (c) print(c); cs[#cs+1] = c end)
local m1  = mk_metavar("m1", Bool)
print("before is_def_eq")
assert(tc:is_def_eq(and_intro(m1, q(a)), and_intro(q(a), q(b))))
-- The constraint and_intro(m1, q(a)) == and_intro(q(a), q(b)) is added.
-- Reason: a unification hint may be able to solve it
assert(#cs == 1)
assert(cs[1]:lhs() == and_intro(m1, q(a)))
assert(cs[1]:rhs() == and_intro(q(a), q(b)))
local cs  = {}
local tc  = type_checker(env, ng, function (c) print(c); cs[#cs+1] = c end)
assert(tc:is_def_eq(foo_intro(m1, q(a), Ax1), foo_intro(q(a), q(a), Ax2)))
assert(#cs == 1) -- constraint is used, but there is an alternative that does not use it
assert(cs[1]:lhs() == m1)
assert(cs[1]:rhs() == q(a))
cs = {}
local tc  = type_checker(env, ng, function (c) print(c); cs[#cs+1] = c end)
assert(tc:is_def_eq(foo_intro(m1, q(a), Ax1), foo_intro2(q(a), q(a), Ax2)))
assert(#cs == 0) -- constraint should be ignored since we have shown definitional equality using proof irrelevance
cs = {}
local tc  = type_checker(env, ng, function (c) print(c); cs[#cs+1] = c end)
print("before failure")
assert(not pcall(function() print(tc:check(and_intro(m1, q(a), Ax1, Ax3))) end))
assert(#cs == 0) -- the check failed, so the constraints should be preserved
cs = {}
print("before success")
print(tc:check(and_intro(m1, q(a), Ax1, Ax2)))
assert(#cs == 1) -- the check succeeded, and we must get one constraint

-- Demo: infer method may generate constraints
-- local m2  = mk_metavar("m2", mk_metavar("ty_m2", mk_sort(mk_meta_univ("s_m2"))))
-- print(tc:infer(mk_pi("x", m2, Var(0))))
