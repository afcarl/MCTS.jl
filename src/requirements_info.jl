function POMDPs.requirements_info(solver::AbstractMCTSSolver, problem::Union{POMDP,MDP})
    if @implemented initial_state(::typeof(problem), ::MersenneTwister)
        requirements_info(solver, problem, initial_state(problem, MersenneTwister(1)))
    elseif state_type(typeof(problem)) <: Number
        s = one(state_type(typeof(problem)))
        requirements_info(solver, problem, s)
    else
        println("""
            Since MCTS is an online solver, most of the computation occurs in `action(policy, state)`. In order to view the requirements for this function, please, supply a state as the third argument to `requirements_info`, e.g.

                @requirements_info $(typeof(solver))() $(typeof(problem))() $(state_type(typeof(problem)))()

                """)
    end
end

function POMDPs.requirements_info(solver::AbstractMCTSSolver, problem::Union{POMDP,MDP}, s)
    policy = solve(solver, problem)
    requirements_info(policy, s)
end

function POMDPs.requirements_info(policy::AbstractMCTSPlanner, s)
    if !isequal(deepcopy(s), s)
        warn("""
             isequal(deepcopy(s), s) returned false. Is isequal() defined correctly?

             For MCTS to work correctly, you must define isequal(::$(typeof(s)), ::$(typeof(s))) (see https://docs.julialang.org/en/stable/stdlib/collections/#Associative-Collections-1, https://github.com/andrewcooke/AutoHashEquals.jl#background, also consider using StaticArrays). This warning was thrown because isequal($(deepcopy(s)), $s) returned false.

             Note: isequal() should also be defined correctly for actions, but no warning will be issued.
             """)
    end
    if hash(deepcopy(s)) != hash(s)
        warn("""
             hash(deepcopy(s)) was not equal to hash(s). Is hash() defined correctly?

             For MCTS to work correctly, you must define hash(::$(typeof(s)), ::UInt) (see https://docs.julialang.org/en/stable/stdlib/collections/#Associative-Collections-1, https://github.com/andrewcooke/AutoHashEquals.jl#background, also consider using StaticArrays). This warning was thrown because hash($(deepcopy(s))) != hash($s).

             Note: hash() should also be defined correctly for actions, but no warning will be issued.
             """)
    end
    @show_requirements action(policy, s)    
end
