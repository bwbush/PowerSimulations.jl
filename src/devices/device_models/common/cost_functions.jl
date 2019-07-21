#=
function ps_cost(ps_m::CanonicalModel,
                 variable::JuMP.Containers.DenseAxisArray{JV},
                 cost_component::Function,
                 sign::Int64) where {JV <: JuMP.AbstractVariableRef}

    store = Vector{Any}(undef, length(variable))

    for (ix, element) in enumerate(variable)
        store[ix] = cost_component(element)
    end

    gen_cost = sum(store)

    return sign*gen_cost

end
=#

function ps_cost(ps_m::CanonicalModel,
                variable::JuMP.Containers.DenseAxisArray{JV},
                cost_component::Float64,
                dt::Float64,
                sign::Float64) where {JV <: JuMP.AbstractVariableRef}

    gen_cost = sum(variable)*cost_component

    return sign*gen_cost*dt

end

function ps_cost(ps_m::CanonicalModel,
                variable::JuMP.Containers.DenseAxisArray{JV},
                cost_component::PSY.VariableCost{Float64},
                dt::Float64,
                sign::Float64) where {JV <: JuMP.AbstractVariableRef}

    return  ps_cost(ps_m, variable, PSY.get_cost(cost_component), dt, sign)

end

function ps_cost(ps_m::CanonicalModel,
                 variable::JuMP.Containers.DenseAxisArray{JV},
                 cost_component::PSY.VariableCost{NTuple{2, Float64}},
                 dt::Float64,
                 sign::Float64) where {JV <: JuMP.AbstractVariableRef}

    if cost_component[1] >= eps()
        gen_cost = dt*sign*(sum(variable.^2)*cost_component[1] + sum(variable)*cost_component[2])
    else
        return ps_cost(ps_m, variable, cost_component[2], dt, 1.0)
    end

end

function _pwlparamcheck(cost_)
    flag = true;
    for i in 1:(length(cost_)-1)
        if i == 1
            (cost_[i][1]/cost_[i][2]) <= ((cost_[i+1][1] - cost_[i][1])/(cost_[i+1][2] - cost_[i][2])) ? nothing : flag = false;
        else
            ((cost_[i][1] - cost_[i-1][1])/(cost_[i][2] - cost_[i-1][2])) <= ((cost_[i+1][1] - cost_[i][1])/(cost_[i+1][2] - cost_[i][2])) ? nothing : flag = false;
        end
    end
    return flag
end

function _pwlgencost(ps_m::CanonicalModel,
                    variable::JV,
                    cost_component::PSY.VariableCost{Array{Tuple{Float64, Float64}}}) where {JV <: JuMP.AbstractVariableRef}

    gen_cost = JuMP.GenericAffExpr{Float64, _variable_type(ps_m)}()
    _pwlparamcheck(cost_component) ? @warn("Data provide is not suitable for linear implementation of PWL cost, this will result in a INVALID SOLUTION") : nothing ;
    upperbound(i) = (i == 0 & (length(cost_component) > i) ? cost_component[i+1][2] : (cost_component[i+1][2] - cost_component[i][2]));
    pwlvars = JuMP.@variable(ps_m.JuMPmodel, [i = 0:(length(cost_component)-1)], base_name = "{$(variable)}_{pwl}", start = 0.0, lower_bound = 0.0, upper_bound = upperbound(i))

    for (ix, pwlvar) in enumerate(pwlvars)
        if ix == 1
            temp_gen_cost = cost_component[ix][1] * (pwlvar / cost_component[ix][2] ) ;
        else
            temp_gen_cost = (cost_component[ix][1] - cost_component[ix-1][1]) * (pwlvar/(cost_component[ix][2] - cost_component[ix-1][2]) );
        end
        gen_cost = gen_cost + temp_gen_cost
    end

    c = JuMP.@constraint(ps_m.JuMPmodel, variable == sum([pwlvar for (ix, pwlvar) in enumerate(pwlvars) if ix > 1]) )

    return gen_cost

end

function ps_cost(ps_m::CanonicalModel,
                 variable::JuMP.Containers.DenseAxisArray{JV},
                 cost_component::PSY.VariableCost{Array{Tuple{Float64, Float64}}},
                 dt::Float64,
                 sign::Float64) where {JV <: JuMP.AbstractVariableRef}

    gen_cost = JuMP.GenericAffExpr{Float64, _variable_type(ps_m)}()

    for var in variable
        c = _pwlgencost(ps_m, var, cost_component)
        gen_cost += c
    end

    return sign*gen_cost*dt

end

function add_to_cost(ps_m::CanonicalModel,
                     devices::D,
                     var_name::Symbol,
                     cost_symbol::Symbol,
                     sign::Float64 = 1.0) where {D <: PSY.FlattenIteratorWrapper{<:PSY.Device}}

    resolution = model_resolution(ps_m)
    dt = Dates.value(Dates.Minute(resolution))/60

    for d in devices
        cost_expression = ps_cost(ps_m,
                                  ps_m.variables[var_name][PSY.get_name(d), :],
                                  getfield(PSY.get_op_cost(d), cost_symbol),
                                  dt,
                                  sign)
        T_ce = typeof(cost_expression)
        T_cf = typeof(ps_m.cost_function)
        if  T_cf <: JuMP.GenericAffExpr && T_ce <: JuMP.GenericQuadExpr
            ps_m.cost_function += cost_expression
        else
            JuMP.add_to_expression!(ps_m.cost_function, cost_expression)
        end
    end

    return

end
