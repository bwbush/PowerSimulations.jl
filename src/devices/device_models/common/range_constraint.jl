function device_range(ps_m::CanonicalModel,
                        range_data::Vector{NamedMinMax},
                        cons_name::Symbol,
                        var_name::Symbol)

    time_steps = model_time_steps(ps_m)
    ps_m.constraints[cons_name] = JuMPConstraintArray(undef, (r[1] for r in range_data), time_steps)

    for r in range_data
          if abs(r[2].min - r[2].max) <= eps()
            @warn("The min - max values in range constraint with eps() distance to each other. Range Constraint will be modified for Equality Constraint")
                for t in time_steps
                    ps_m.constraints[cons_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] == r[2].max)
                end
            else
                for t in time_steps
                    ps_m.constraints[cons_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, r[2].min <= ps_m.variables[var_name][r[1], t] <= r[2].max)
                end
            end
    end

    return

end

function device_semicontinuousrange(ps_m::CanonicalModel,
                                    scrange_data::Vector{NamedMinMax},
                                    cons_name::Symbol,
                                    var_name::Symbol,
                                    binvar_name::Symbol)

    time_steps = model_time_steps(ps_m)
    ub_name = Symbol(cons_name, :_ub)
    lb_name = Symbol(cons_name, :_lb)

    #MOI has a semicontinous set, but after some tests is not clear most MILP solvers support it. In the future this can be updated
    set_name = (r[1] for r in scrange_data)
    ps_m.constraints[ub_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[lb_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for t in time_steps, r in scrange_data

            if r[2].min == 0.0

                ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*ps_m.variables[binvar_name][r[1], t])
                ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= 0.0)

            else

                ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*ps_m.variables[binvar_name][r[1], t])
                ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= r[2].min*ps_m.variables[binvar_name][r[1], t])

            end

    end

    return

end

function device_semicontinuousrange_param(ps_m::CanonicalModel,
                                          scrange_data::Vector{NamedMinMax},
                                          cons_name::Symbol,
                                          var_name::Symbol,
                                          param_name::Symbol)

    time_steps = model_time_steps(ps_m)
    ub_name = Symbol(cons_name, :_ub)
    lb_name = Symbol(cons_name, :_lb)

    #MOI has a semicontinous set, but after some tests is not clear most MILP solvers support it. In the future this can be updated
    set_name = (r[1] for r in scrange_data)
    ps_m.parameters[param_name] = JuMPParamArray(undef, set_name, time_steps)
    ps_m.constraints[ub_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[lb_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for t in time_steps, r in scrange_data
        ps_m.parameters[param_name][r[1], t] = PJ.add_parameter(ps_m.JuMPmodel, 1.0)
        if r[2].min == 0.0
            ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*ps_m.parameters[param_name][r[1], t])
            ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= 0.0)

        else

            ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*ps_m.parameters[param_name][r[1], t])
            ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= r[2].min*ps_m.parameters[param_name][r[1], t])

        end

    end

    return

end

function reserve_device_semicontinuousrange(ps_m::CanonicalModel,
                                            scrange_data::Vector{NamedMinMax},
                                            cons_name::Symbol,
                                            var_name::Symbol,
                                            binvar_name::Symbol)

    time_steps = model_time_steps(ps_m)
    ub_name = Symbol(cons_name, :_ub)
    lb_name = Symbol(cons_name, :_lb)

    # MOI has a semicontinous set, but after some tests is not clear most MILP solvers support it.
    # In the future this can be updated

    set_name = (r[1] for r in scrange_data)
    ps_m.constraints[ub_name] = JuMPConstraintArray(undef, set_name, time_steps)
    ps_m.constraints[lb_name] = JuMPConstraintArray(undef, set_name, time_steps)

    for t in time_steps, r in scrange_data

            if r[2].min == 0.0

                ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*(1-ps_m.variables[binvar_name][r[1], t]))
                ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= 0.0)

            else

                ps_m.constraints[ub_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] <= r[2].max*(1-ps_m.variables[binvar_name][r[1], t]))
                ps_m.constraints[lb_name][r[1], t] = JuMP.@constraint(ps_m.JuMPmodel, ps_m.variables[var_name][r[1], t] >= r[2].min*(1-ps_m.variables[binvar_name][r[1], t]))

            end

    end

    return

 end
