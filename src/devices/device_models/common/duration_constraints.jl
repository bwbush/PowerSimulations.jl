"""
This formulation of the duration constraints, adds over the start times looking backwards.

"""
function device_duration_retrospective(ps_m::CanonicalModel,
                                        set_names::Vector{String},
                                        duration_data::Vector{UpDown},
                                        initial_duration_on::Vector{InitialCondition},
                                        initial_duration_off::Vector{InitialCondition},
                                        cons_name::Symbol,
                                        var_names::Tuple{Symbol, Symbol, Symbol})

    time_steps = model_time_steps(ps_m)
    name_up = Symbol(cons_name, :_up)
    name_down = Symbol(cons_name, :_down)

    ps_m.constraints[name_up] = JuMPConstraintArray(undef, set_names, time_steps)
    ps_m.constraints[name_down] = JuMPConstraintArray(undef, set_names, time_steps)


        for t in time_steps, (ix, name) in enumerate(set_names)
                if t - duration_data[ix].up >= 1
                    tst = duration_data[ix].up
                else
                    tst = max(1.0, duration_data[ix].up - initial_duration_on[ix].value)
                end

                if t - duration_data[ix].down >= 1
                    tsd = duration_data[ix].down
                else
                    tsd = max(1.0, duration_data[ix].down - initial_duration_off[ix].value)
                end

                ps_m.constraints[name_up][name, t] = JuMP.@constraint(ps_m.JuMPmodel, sum([ps_m.variables[var_names[2]][name, i] for i in ((t - round(tst) + 1) :t) if i > 0 ]) <= ps_m.variables[var_names[1]][name, t])
                ps_m.constraints[name_down][name, t] = JuMP.@constraint(ps_m.JuMPmodel, sum([ps_m.variables[var_names[3]][name, i] for i in ((t - round(tsd) + 1) :t) if i > 0]) <= (1 - ps_m.variables[var_names[1]][name, t]))

        end

    return

end


"""
This formulation of the duration constraints, uses an Indicator parameter value to show if the constraint was satisfied in the past.

"""
function device_duration_ind(ps_m::CanonicalModel,
                             set_names::Vector{String},
                             duration_data::Vector{UpDown},
                             duration_ind_status_on::Vector{InitialCondition},
                             duration_ind_status_off::Vector{InitialCondition},
                             cons_name::Symbol,
                             var_names::Tuple{Symbol, Symbol, Symbol})


    time_steps = model_time_steps(ps_m)
    name_up = Symbol(cons_name, :_up)
    name_down = Symbol(cons_name, :_down)

    ps_m.constraints[name_up] = JuMPConstraintArray(undef, set_names, time_steps)
    ps_m.constraints[name_down] = JuMPConstraintArray(undef, set_names, time_steps)

    for (ix, name) in enumerate(set_names)
        ps_m.constraints[name_up][name, 1] = JuMP.@constraint(ps_m.JuMPmodel,
                                            duration_ind_status_on[ix].value <= ps_m.variables[var_names[1]][name, 1])
        ps_m.constraints[name_down][name, 1] = JuMP.@constraint(ps_m.JuMPmodel,
                                            duration_ind_status_off[ix].value <= (1- ps_m.variables[var_names[1]][name, 1]))
    end

    for t in time_steps[2:end], (ix, name) in enumerate(set_names)
        if t <= duration_data[ix].up
            ps_m.constraints[name_up][name, t] = JuMP.@constraint(ps_m.JuMPmodel,
                                                            sum([ps_m.variables[var_names[2]][name, i] for i in 1:(t-1)]) + duration_ind_status_on[ix].value <= ps_m.variables[var_names[1]][name, t])
         else
            ps_m.constraints[name_up][name, t] = JuMP.@constraint(ps_m.JuMPmodel, sum([ps_m.variables[var_names[2]][name, i] for i in (t-duration_data[ix].up):t]) <= ps_m.variables[var_names[1]][name, t])
        end

        if t <= duration_data[ix].down
            ps_m.constraints[name_down][name, t] = JuMP.@constraint(ps_m.JuMPmodel,
                                                            sum([ps_m.variables[var_names[3]][name, i] for i in 1:(t-1)]) + duration_ind_status_off[ix].value <= (1 - ps_m.variables[var_names[1]][name, t]))
        else
            ps_m.constraints[name_down][name, t] = JuMP.@constraint(ps_m.JuMPmodel, sum([ps_m.variables[var_names[3]][name, i] for i in (t-duration_data[ix].down):t]) <= (1 - ps_m.variables[var_names[1]][name, t]))
        end

    end

    return

end