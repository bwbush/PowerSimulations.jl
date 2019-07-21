function get_branch_to_pm(ix::Int64, branch::PSY.PhaseShiftingTransformer)
    PM_branch = Dict{String, Any}(
        "br_r"        => PSY.get_r(branch),
        "rate_a"      => PSY.get_rate(branch),
        "shift"       => PSY.get_α(branch),
        "rate_b"      => PSY.get_rate(branch),
        "br_x"        => PSY.get_x(branch),
        "rate_c"      => PSY.get_rate(branch),
        "g_to"        => 0.0,
        "g_fr"        => 0.0,
        "b_fr"        => PSY.get_primaryshunt(branch)/2,
        "f_bus"       => PSY.get_arch(branch).from |> PSY.get_number,
        "br_status"   => Float64(PSY.get_available(branch)),
        "t_bus"       => PSY.get_arch(branch).to |> PSY.get_number,
        "b_to"        => PSY.get_primaryshunt(branch)/2,
        "index"       => ix,
        "angmin"      => -π/2,
        "angmax"      =>  π/2,
        "transformer" => true,
        "tap"         => PSY.get_tap(branch),
    )
    return PM_branch
end

function get_branch_to_pm(ix::Int64, branch::PSY.Transformer2W)
    PM_branch = Dict{String, Any}(
        "br_r"        => PSY.get_r(branch),
        "rate_a"      => PSY.get_rate(branch),
        "shift"       => 0.0,
        "rate_b"      => PSY.get_rate(branch),
        "br_x"        => PSY.get_x(branch),
        "rate_c"      => PSY.get_rate(branch),
        "g_to"        => 0.0,
        "g_fr"        => 0.0,
        "b_fr"        => PSY.get_primaryshunt(branch)/2,
        "f_bus"       => PSY.get_arch(branch).from |> PSY.get_number,
        "br_status"   => Float64(PSY.get_available(branch)),
        "t_bus"       => PSY.get_arch(branch).to |> PSY.get_number,
        "b_to"        => PSY.get_primaryshunt(branch)/2,
        "index"       => ix,
        "angmin"      => -π/2,
        "angmax"      =>  π/2,
        "transformer" => true,
        "tap"         => 1.0,
    )
    return PM_branch
end

function get_branch_to_pm(ix::Int64, branch::PSY.TapTransformer)
    PM_branch = Dict{String, Any}(
        "br_r"        => PSY.get_r(branch),
        "rate_a"      => PSY.get_rate(branch),
        "shift"       => 0.0,
        "rate_b"      => PSY.get_rate(branch),
        "br_x"        => PSY.get_x(branch),
        "rate_c"      => PSY.get_rate(branch),
        "g_to"        => 0.0,
        "g_fr"        => 0.0,
        "b_fr"        => PSY.get_primaryshunt(branch)/2,
        "f_bus"       => PSY.get_arch(branch).from |> PSY.get_number,
        "br_status"   => Float64(PSY.get_available(branch)),
        "t_bus"       => PSY.get_arch(branch).to |> PSY.get_number,
        "b_to"        => PSY.get_primaryshunt(branch)/2,
        "index"       => ix,
        "angmin"      => -π/2,
        "angmax"      =>  π/2,
        "transformer" => true,
        "tap"         => PSY.get_tap(branch)
    )
    return PM_branch
end

function get_branch_to_pm(ix::Int64, branch::PSY.Line)
    PM_branch = Dict{String, Any}(
        "br_r"        => PSY.get_r(branch),
        "rate_a"      => PSY.get_rate(branch),
        "shift"       => 0.0,
        "rate_b"      => PSY.get_rate(branch),
        "br_x"        => PSY.get_x(branch),
        "rate_c"      => PSY.get_rate(branch),
        "g_to"        => 0.0,
        "g_fr"        => 0.0,
        "b_fr"        => PSY.get_b(branch).from,
        "f_bus"       => PSY.get_arch(branch).from |> PSY.get_number,
        "br_status"   => Float64(PSY.get_available(branch)),
        "t_bus"       => PSY.get_arch(branch).to |> PSY.get_number,
        "b_to"        => PSY.get_b(branch).to,
        "index"       => ix,
        "angmin"      => PSY.get_anglelimits(branch).min,
        "angmax"      => PSY.get_anglelimits(branch).max,
        "transformer" => false,
        "tap"         => 1.0,
    )
    return PM_branch
end

function get_branch_to_pm(ix::Int64, branch::PSY.HVDCLine)
    PM_branch = Dict{String, Any}(
        "loss1"         => PSY.get_loss(branch).l1,
        "mp_pmax"       => PSY.get_reactivepowerlimits_from(branch).max,
        "model"         => 2,
        "shutdown"      => 0.0,
        "pmaxt"         => PSY.get_activepowerlimits_to(branch).max,
        "pmaxf"         => PSY.get_activepowerlimits_from(branch).max,
        "startup"       => 0.0,
        "loss0"         => PSY.get_loss(branch).l1,
        "pt"            => 0.0,
        "vt"            => PSY.get_arch(branch).to |> PSY.get_voltage,
        "qmaxf"         => PSY.get_reactivepowerlimits_from(branch).max,
        "pmint"         => PSY.get_activepowerlimits_to(branch).min,
        "f_bus"         => PSY.get_arch(branch).from |> PSY.get_number,
        "mp_pmin"       => PSY.get_reactivepowerlimits_from(branch).min,
        "br_status"     => Float64(PSY.get_available(branch)),
        "t_bus"         => PSY.get_arch(branch).to |> PSY.get_number,
        "index"         => ix,
        "qmint"         => PSY.get_reactivepowerlimits_to(branch).min,
        "qf"            => 0.0,
        "cost"          => 0.0,
        "pminf"         => PSY.get_activepowerlimits_from(branch).min,
        "qt"            => 0.0,
        "qminf"         => PSY.get_reactivepowerlimits_from(branch).min,
        "vf"            => PSY.get_arch(branch).from |> PSY.get_voltage,
        "qmaxt"         => PSY.get_reactivepowerlimits_to(branch).max,
        "ncost"         => 0,
        "pf"            => 0.0
    )
    return PM_branch
end

function get_branches_to_pm(sys::PSY.System)

        PM_ac_branches = Dict{String, Any}()
        PM_dc_branches = Dict{String, Any}()

        for (ix, branch) in enumerate(PSY.get_components(PSY.Branch, sys))
            if isa(branch, PSY.DCBranch)
                PM_dc_branches["$(ix)"] = get_branch_to_pm(ix, branch)
            else
                PM_ac_branches["$(ix)"] = get_branch_to_pm(ix, branch)
            end
        end

    return PM_ac_branches, PM_dc_branches
end

function get_buses_to_pm(buses::PSY.FlattenIteratorWrapper{PSY.Bus})
    PM_buses = Dict{String, Any}()
    for bus in buses
        PM_bus = Dict{String, Any}(
        "zone"     => 1,
        "bus_i"    => PSY.get_number(bus),
        "bus_type" => PSY.get_bustype(bus),
        "vmax"     => PSY.get_voltagelimits(bus).max,
        "area"     => 1,
        "vmin"     => PSY.get_voltagelimits(bus).min,
        "index"    => PSY.get_number(bus),
        "va"       => PSY.get_angle(bus),
        "vm"       => PSY.get_voltage(bus),
        "base_kv"  => PSY.get_basevoltage(bus),
        "pni"      => 0.0,
        "qni"      => 0.0,
        )
        PM_buses["$(PSY.get_number(bus))"] = PM_bus
    end
    return PM_buses
end

function pass_to_pm(sys::PSY.System, time_periods::Int64)

    ac_lines, dc_lines = get_branches_to_pm(sys)
    buses = PSY.get_components(PSY.Bus, sys)
    PM_translation = Dict{String, Any}(
    "bus"            => get_buses_to_pm(buses),
    "branch"         => ac_lines,
    "baseMVA"        => sys.basepower,
    "per_unit"       => true,
    "storage"        => Dict{String, Any}(),
    "dcline"         => dc_lines,
    "gen"            => Dict{String, Any}(),
    "shunt"          => Dict{String, Any}(),
    "load"           => Dict{String, Any}(),
    )

    # TODO: this function adds overhead in large number of time_steps
    # We can do better later.

    PM_translation = PM.replicate(PM_translation, time_periods)

    return PM_translation

end