function device_linear_rateofchange(ps_m::CanonicalModel,
                                    rate_data::Tuple{Vector{String}, Vector{UpDown}},
                                    initial_conditions::Vector{InitialCondition},
                                    cons_name::Symbol,
                                    var_name::Symbol)

    time_steps = model_time_steps(ps_m)
    up_name = Symbol(cons_name, :_up)
    down_name = Symbol(cons_name, :_down)

    set_name = rate_data[1]

    ps_m.constraints[up_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[down_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for (ix, name) in enumerate(rate_data[1])
        ps_m.constraints[up_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, 1] - initial_conditions[ix].value <= rate_data[2][ix].up)
        ps_m.constraints[down_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, initial_conditions[ix].value - ps_m.variables[var_name][name, 1] <= rate_data[2][ix].down)
    end

    for t in time_steps[2:end], (ix, name) in enumerate(rate_data[1])
        ps_m.constraints[up_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, t-1] - ps_m.variables[var_name][name, t] <= rate_data[2][ix].up)
        ps_m.constraints[down_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, t] - ps_m.variables[var_name][name, t-1] <= rate_data[2][ix].down)
    end

    return

end

function device_mixedinteger_rateofchange(ps_m::CanonicalModel,
                                          rate_data::Tuple{Vector{String}, Vector{UpDown}, Vector{MinMax}},
                                          initial_conditions::Vector{InitialCondition},
                                          cons_name::Symbol,
                                          var_names::Tuple{Symbol, Symbol, Symbol})

    time_steps = model_time_steps(ps_m)
    up_name = Symbol(cons_name, :_up)
    down_name = Symbol(cons_name, :_down)

    set_name = rate_data[1]

    ps_m.constraints[up_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[down_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for (ix, name) in enumerate(rate_data[1])
        ps_m.constraints[up_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, 1] - initial_conditions[ix].value <= rate_data[2][ix].up + rate_data[3][ix].max*ps_m.variables[var_names[2]][name, 1])
        ps_m.constraints[down_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, initial_conditions[ix].value - ps_m.variables[var_names[1]][name, 1] <= rate_data[2][ix].down + rate_data[3][ix].min*ps_m.variables[var_names[3]][name, 1])
    end

    for t in time_steps[2:end], (ix, name) in enumerate(rate_data[1])
        ps_m.constraints[up_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, t-1] - ps_m.variables[var_names[1]][name, t] <= rate_data[2][ix].up + rate_data[3][ix].max*ps_m.variables[var_names[2]][name, t])
        ps_m.constraints[down_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, t] - ps_m.variables[var_names[1]][name, t-1] <= rate_data[2][ix].down + rate_data[3][ix].min*ps_m.variables[var_names[3]][name, t])
    end

    return

end

#Old implementation of initial_conditions
#=
function device_linear_rateofchange(ps_m::CanonicalModel,
                                    rate_data::Vector{UpDown},
                                    initial_conditions::Vector{Float64},
                                    time_steps::UnitRange{Int64},
                                    cons_name::Symbol,
                                    var_name::Symbol)


    up_name = Symbol(cons_name, :_up)
    down_name = Symbol(cons_name, :_down)

    set_name = [name for r in rate_data]

    ps_m.constraints[up_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[down_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for (ix, r) in enumerate(rate_data)
        ps_m.constraints[up_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, 1] - initial_conditions[ix] <= rate_data[2][ix].up)
        ps_m.constraints[down_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, initial_conditions[ix] - ps_m.variables[var_name][name, 1] <= rate_data[2][ix].down)
    end

    for t in time_steps[2:end], r in rate_data
        ps_m.constraints[up_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, t-1] - ps_m.variables[var_name][name, t] <= rate_data[2][ix].up)
        ps_m.constraints[down_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][name, t] - ps_m.variables[var_name][name, t-1] <= rate_data[2][ix].down)
    end

    return

end

function device_mixedinteger_rateofchange(ps_m::CanonicalModel,
                                            rate_data::Array{Tuple{String, NamedTuple{(:up, :down), NTuple{2, Float64}}, NamedTuple{(:min, :max), NTuple{2, Float64}}}, 1},
                                            initial_conditions::Vector{Float64},
                                            time_steps::UnitRange{Int64},
                                            cons_name::Symbol,
                                            var_names::Tuple{Symbol, Symbol, Symbol})

    up_name = Symbol(cons_name, :_up)
    down_name = Symbol(cons_name, :_down)

    set_name = [name for r in rate_data]

    ps_m.constraints[up_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[down_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for (ix, r) in enumerate(rate_data)
        ps_m.constraints[up_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, 1] - initial_conditions[ix] <= rate_data[2][ix].up + rate_data[3][ix].max*ps_m.variables[var_names[2]][name, 1])
        ps_m.constraints[down_name][name, 1] = JuMP.@constraint(ps_m.JuMPmodel, initial_conditions[ix] - ps_m.variables[var_names[1]][name, 1] <= rate_data[2][ix].down + rate_data[3][ix].min*ps_m.variables[var_names[3]][name, 1])
    end

    for t in time_steps[2:end], r in rate_data
        ps_m.constraints[up_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, t-1] - ps_m.variables[var_names[1]][name, t] <= rate_data[2][ix].up + rate_data[3][ix].max*ps_m.variables[var_names[2]][name, t])
        ps_m.constraints[down_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_names[1]][name, t] - ps_m.variables[var_names[1]][name, t-1] <= rate_data[2][ix].down + rate_data[3][ix].min*ps_m.variables[var_names[3]][name, t])
    end

    return

end
=#