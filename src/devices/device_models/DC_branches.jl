abstract type AbstractDCLineForm<:AbstractBranchFormulation end

struct HVDCLossless<:AbstractDCLineForm end

struct HVDCDispatch<:AbstractDCLineForm end

struct VoltageSourceDC<:AbstractDCLineForm end

#################################### Branch Variables ##################################################

function flow_variables(ps_m::CanonicalModel,
                        system_formulation::Type{S},
                        devices::PSY.FlattenIteratorWrapper{B}) where {B<:PSY.DCBranch,
                                                                        S<:PM.AbstractPowerFormulation}

    return

end

function flow_variables(ps_m::CanonicalModel,
                        system_formulation::Type{StandardPTDFForm},
                        devices::PSY.FlattenIteratorWrapper{B}) where {B<:PSY.DCBranch}

    time_steps = model_time_steps(ps_m)
    var_name = Symbol("Fp_$(B)")
    ps_m.variables[var_name] = PSI._container_spec(ps_m.JuMPmodel,
                                                  (PSY.get_name(d) for d in devices),
                                                   time_steps)

    for d in devices
        bus_fr = PSY.get_arc(d).from |> PSY.get_number
        bus_to = PSY.get_arc(d).to |> PSY.get_number
        for t in time_steps
            ps_m.variables[var_name][PSY.get_name(d), t] = JuMP.@variable(ps_m.JuMPmodel,
                                                                base_name="$(bus_fr), $(bus_to)_{$(PSY.get_name(d)), $(t)}")
            _add_to_expression!(ps_m.expressions[:nodal_balance_active],
                                PSY.get_arc(d).from |> PSY.get_number,
                                t,
                                ps_m.variables[var_name][PSY.get_name(d), t],
                                -1.0)
            _add_to_expression!(ps_m.expressions[:nodal_balance_active],
                                PSY.get_arc(d).to |> PSY.get_number,
                                t,
                                ps_m.variables[var_name][PSY.get_name(d), t],
                                1.0)
        end
    end

    return

end

#################################### Flow Variable Bounds ##################################################


#################################### Rate Limits Constraints ##################################################

function branch_rate_constraint(ps_m::CanonicalModel,
                                devices::PSY.FlattenIteratorWrapper{B},
                                device_formulation::Type{D},
                                system_formulation::Type{S}) where {B<:PSY.DCBranch,
                                                                    D<:AbstractDCLineForm,
                                                                    S<:PM.DCPlosslessForm}

    var_name = Symbol("Fp_$(B)")
    con_name = Symbol("RateLimit_$(B)")
    time_steps = model_time_steps(ps_m)
    ps_m.constraints[con_name] = JuMPConstraintArray(undef, (PSY.get_name(d) for d in devices), time_steps)

    for t in time_steps, d in devices
        min_rate = max(PSY.get_activepowerlimits_from(d).min, PSY.get_activepowerlimits_to(d).min)
        max_rate = min(PSY.get_activepowerlimits_from(d).max, PSY.get_activepowerlimits_to(d).max)
        ps_m.constraints[con_name][PSY.get_name(d), t] = JuMP.@constraint(ps_m.JuMPmodel, min_rate <= ps_m.variables[var_name][PSY.get_name(d), t] <= max_rate)
    end

    return

end

function branch_rate_constraint(ps_m::CanonicalModel,
                                devices::PSY.FlattenIteratorWrapper{B},
                                device_formulation::Type{HVDCLossless},
                                system_formulation::Type{S}) where {B<:PSY.DCBranch,
                                                                    S<:PM.AbstractPowerFormulation}

    for dir in ("FT", "TF")
        var_name = Symbol("Fp$(dir)_$(B)")
        con_name = Symbol("RateLimit_$(dir)_$(B)")
        time_steps = model_time_steps(ps_m)
        ps_m.constraints[con_name] = JuMPConstraintArray(undef, (PSY.get_name(d) for d in devices), time_steps)

        for t in time_steps, d in devices
            min_rate = max(PSY.get_activepowerlimits_from(d).min, PSY.get_activepowerlimits_to(d).min)
            max_rate = min(PSY.get_activepowerlimits_from(d).max, PSY.get_activepowerlimits_to(d).max)
            name = PSY.get_name(d)
            ps_m.constraints[con_name][name, t] = JuMP.@constraint(ps_m.JuMPmodel, min_rate <= ps_m.variables[var_name][name, t] <= max_rate)
        end
    end

    return

end

function branch_rate_constraint(ps_m::CanonicalModel,
                                devices::PSY.FlattenIteratorWrapper{B},
                                device_formulation::Type{D},
                                system_formulation::Type{S}) where {B<:PSY.DCBranch,
                                                                    D<:AbstractDCLineForm,
                                                                    S<:PM.AbstractPowerFormulation}

    time_steps = model_time_steps(ps_m)

    for dir in ("FT", "TF")
        var_name = Symbol("Fp$(dir)_$(B)")
        con_name = Symbol("RateLimit$(dir)_$(B)")
        ps_m.constraints[con_name] = JuMPConstraintArray(undef, (PSY.get_name(d) for d in devices), time_steps)

        for t in time_steps, d in devices
            min_rate = max(PSY.get_activepowerlimits_from(d).min, PSY.get_activepowerlimits_to(d).min)
            max_rate = min(PSY.get_activepowerlimits_from(d).max, PSY.get_activepowerlimits_to(d).max)
            ps_m.constraints[con_name][PSY.get_name(d), t] = JuMP.@constraint(ps_m.JuMPmodel, min_rate <= ps_m.variables[var_name][PSY.get_name(d), t] <= max_rate)
            _add_to_expression!(ps_m.expressions[:nodal_balance_active],
                                PSY.get_arc(d).to |> PSY.get_number,
                                t,
                                ps_m.variables[var_name][PSY.get_name(d), t],
                                -PSY.get_loss(d).l1,
                                -PSY.get_loss(d).l0)
        end
    end

    return

end


#################################### Flow Limits Constraints ##################################################
