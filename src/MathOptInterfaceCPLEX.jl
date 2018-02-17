__precompile__()
module MathOptInterfaceCPLEX

export CPLEXOptimizer

using CPLEX
const CPX = CPLEX
using MathOptInterface
const MOI = MathOptInterface
using LinQuadOptInterface
const LQOI = LinQuadOptInterface

const SUPPORTED_OBJECTIVES = [
    LQOI.Linear,
    LQOI.Quad
]

const SUPPORTED_CONSTRAINTS = [
    (LQOI.Linear, LQOI.EQ),
    (LQOI.Linear, LQOI.LE),
    (LQOI.Linear, LQOI.GE),
    (LQOI.Linear, LQOI.IV),
    (LQOI.Quad, LQOI.EQ),
    (LQOI.Quad, LQOI.LE),
    (LQOI.Quad, LQOI.GE),
    (LQOI.SinVar, LQOI.EQ),
    (LQOI.SinVar, LQOI.LE),
    (LQOI.SinVar, LQOI.GE),
    (LQOI.SinVar, LQOI.IV),
    (LQOI.SinVar, MOI.ZeroOne),
    (LQOI.SinVar, MOI.Integer),
    (LQOI.VecVar, LQOI.SOS1),
    (LQOI.VecVar, LQOI.SOS2),
    (LQOI.VecVar, MOI.Nonnegatives),
    (LQOI.VecVar, MOI.Nonpositives),
    (LQOI.VecVar, MOI.Zeros),
    (LQOI.VecLin, MOI.Nonnegatives),
    (LQOI.VecLin, MOI.Nonpositives),
    (LQOI.VecLin, MOI.Zeros)
]

mutable struct CPLEXOptimizer <: LQOI.LinQuadOptimizer
    LQOI.@LinQuadOptimizerBase
    env
    params::Dict{String,Any}
    CPLEXOptimizer(::Void) = new()
end

LQOI.LinQuadModel(::Type{CPLEXOptimizer},env) = CPX.Model(env)

function CPLEXOptimizer(;kwargs...)

    env = CPX.Env()
    m = CPLEXOptimizer(nothing)
    m.env = env
    m.params = Dict{String,Any}()
    MOI.empty!(m)
    for (name,value) in kwargs
        m.params[string(name)] = value        
        CPX.cpx_setparam!(m.inner.env, string(name), value)
    end
    return m
end

function MOI.empty!(m::CPLEXOptimizer) 
    MOI.empty!(m,m.env)
    for (name,value) in m.params
        CPX.cpx_setparam!(m.inner.env, string(name), value)
    end
end

LQOI.lqs_supported_constraints(s::CPLEXOptimizer) = SUPPORTED_CONSTRAINTS
LQOI.lqs_supported_objectives(s::CPLEXOptimizer) = SUPPORTED_OBJECTIVES


#=
    inner wrapper
=#

#=
    Main
=#

# LinQuadSolver # Abstract type
# done above

# LQOI.lqs_setparam!(env, name, val)
# TODO fix this one
LQOI.lqs_setparam!(m::CPLEXOptimizer, name, val) = CPX.cpx_setparam!(m.inner, string(name), val)

# LQOI.lqs_setlogfile!(env, path)
# TODO fix this one
LQOI.lqs_setlogfile!(m::CPLEXOptimizer, path) = CPX.setlogfile(m.inner, path::String)

# LQOI.lqs_getprobtype(m)
# TODO - consider removing, apparently useless

#=
    Constraints
=#

# LQOI.lqs_chgbds!(m, colvec, valvec, sensevec)
LQOI.lqs_chgbds!(instance::CPLEXOptimizer, colvec, valvec, sensevec) = CPX.cpx_chgbds!(instance.inner, colvec, valvec, sensevec)

# LQOI.lqs_getlb(m, col)
LQOI.lqs_getlb(instance::CPLEXOptimizer, col) = CPX.cpx_getlb(instance.inner, col)
# LQOI.lqs_getub(m, col)
LQOI.lqs_getub(instance::CPLEXOptimizer, col) = CPX.cpx_getub(instance.inner, col)

# LQOI.lqs_getnumrows(m)
LQOI.lqs_getnumrows(instance::CPLEXOptimizer) = CPX.cpx_getnumrows(instance.inner)

# LQOI.lqs_addrows!(m, rowvec, colvec, coefvec, sensevec, rhsvec)
LQOI.lqs_addrows!(instance::CPLEXOptimizer, rowvec, colvec, coefvec, sensevec, rhsvec) = CPX.cpx_addrows!(instance.inner, rowvec, colvec, coefvec, sensevec, rhsvec)

# LQOI.lqs_getrhs(m, rowvec)
LQOI.lqs_getrhs(instance::CPLEXOptimizer, row) = CPX.cpx_getrhs(instance.inner, row)  

# colvec, coef = LQOI.lqs_getrows(m, rowvec)
# TODO improve
function LQOI.lqs_getrows(instance::CPLEXOptimizer, idx)
    return CPX.cpx_getrows(instance.inner, idx)
end

# LQOI.lqs_getcoef(m, row, col) #??
# TODO improve
LQOI.lqs_getcoef(instance::CPLEXOptimizer, row, col) = CPX.cpx_getcoef(instance.inner, row, col)

# LQOI.lqs_chgcoef!(m, row, col, coef)
# TODO SPLIT THIS ONE
LQOI.lqs_chgcoef!(instance::CPLEXOptimizer, row, col, coef)  = CPX.cpx_chgcoef!(instance.inner, row, col, coef)

# LQOI.lqs_delrows!(m, row, row)
LQOI.lqs_delrows!(instance::CPLEXOptimizer, rowbeg, rowend) = CPX.cpx_delrows!(instance.inner, rowbeg, rowend)

# LQOI.lqs_chgctype!(m, colvec, typevec)
# TODO fix types
LQOI.lqs_chgctype!(instance::CPLEXOptimizer, colvec, typevec) = CPX.cpx_chgctype!(instance.inner, colvec, typevec)

# LQOI.lqs_chgsense!(m, rowvec, sensevec)
# TODO fix types
LQOI.lqs_chgsense!(instance::CPLEXOptimizer, rowvec, sensevec) = CPX.cpx_chgsense!(instance.inner, rowvec, sensevec)

const VAR_TYPE_MAP = Dict{Symbol,Cchar}(
    :CONTINUOUS => Cchar('C'),
    :INTEGER => Cchar('I'),
    :BINARY => Cchar('B')
)
LQOI.lqs_vartype_map(m::CPLEXOptimizer) = VAR_TYPE_MAP

# LQOI.lqs_addsos(m, colvec, valvec, typ)
LQOI.lqs_addsos!(instance::CPLEXOptimizer, colvec, valvec, typ) = CPX.add_sos!(instance.inner, typ, colvec, valvec)
# LQOI.lqs_delsos(m, idx, idx)
LQOI.lqs_delsos!(instance::CPLEXOptimizer, idx1, idx2) = CPX.cpx_delsos!(instance.inner, idx1, idx2)

const SOS_TYPE_MAP = Dict{Symbol,Symbol}(
    :SOS1 => :SOS1,#Cchar('1'),
    :SOS2 => :SOS2#Cchar('2')
)
LQOI.lqs_sertype_map(m::CPLEXOptimizer) = SOS_TYPE_MAP

# LQOI.lqs_getsos(m, idx)
# TODO improve getting processes
function LQOI.lqs_getsos(instance::CPLEXOptimizer, idx)
    indices, weights, types = CPX.cpx_getsos(instance.inner, idx)

    # types2 = Array{Symbol}(length(types))
    # for i in eachindex(types)
    #     if types[i] == Cchar('1')
    #         types2[i] = :SOS1
    #     elseif types[i] == Cchar('2')
    #         types2[i] = :SOS2
    #     end
    # end

    return indices, weights, types == Cchar('1') ? :SOS1 : :SOS2
end
# LQOI.lqs_getnumqconstrs(m)
LQOI.lqs_getnumqconstrs(instance::CPLEXOptimizer) = CPX.cpx_getnumqconstrs(instance.inner)

# LQOI.lqs_addqconstr(m, cols,coefs,rhs,sense, I,J,V)
LQOI.lqs_addqconstr!(instance::CPLEXOptimizer, cols,coefs,rhs,sense, I,J,V) = CPX.cpx_addqconstr!(instance.inner, cols,coefs,rhs,sense, I,J,V)

# LQOI.lqs_chgrngval
LQOI.lqs_chgrngval!(instance::CPLEXOptimizer, rows, vals) = CPX.cpx_chgrngval!(instance.inner, rows, vals)

const CTR_TYPE_MAP = Dict{Symbol,Cchar}(
    :RANGE => Cchar('R'),
    :LOWER => Cchar('L'),
    :UPPER => Cchar('U'),
    :EQUALITY => Cchar('E')
)
LQOI.lqs_ctrtype_map(m::CPLEXOptimizer) = CTR_TYPE_MAP

#=
    Objective
=#

# LQOI.lqs_copyquad(m, intvec,intvec, floatvec) #?
LQOI.lqs_copyquad!(instance::CPLEXOptimizer, I, J, V) = CPX.cpx_copyquad!(instance.inner, I, J, V)

# LQOI.lqs_chgobj(m, colvec,coefvec)
function LQOI.lqs_chgobj!(instance::CPLEXOptimizer, colvec, coefvec)
    ncols = CPX.cpx_getnumcols(instance.inner)
    new_colvec = collect(1:ncols)
    new_coefvec = zeros(ncols)
    for (ind,val) in enumerate(colvec)
        new_coefvec[val] = coefvec[ind]
    end
    # this only sums to obj
    CPX.cpx_chgobj!(instance.inner, new_colvec, new_coefvec) 
end
# LQOI.lqs_chgobjsen(m, symbol)
# TODO improve min max names
LQOI.lqs_chgobjsen!(instance::CPLEXOptimizer, symbol) = CPX.cpx_chgobjsen!(instance.inner, symbol)
    

# LQOI.lqs_getobj(m)
LQOI.lqs_getobj(instance::CPLEXOptimizer) = CPX.cpx_getobj(instance.inner) 

# lqs_getobjsen(m)
LQOI.lqs_getobjsen(instance::CPLEXOptimizer) = CPX.cpx_getobjsen(instance.inner)

#=
    Variables
=#

# LQOI.lqs_getnumcols(m)
LQOI.lqs_getnumcols(instance::CPLEXOptimizer) = CPX.cpx_getnumcols(instance.inner)

# LQOI.lqs_newcols!(m, int)
LQOI.lqs_newcols!(instance::CPLEXOptimizer, int) = CPX.cpx_newcols!(instance.inner, int)

# LQOI.lqs_delcols!(m, col, col)
LQOI.lqs_delcols!(instance::CPLEXOptimizer, col, col2) = CPX.cpx_delcols!(instance.inner, col, col2)

# LQOI.lqs_addmipstarts(m, colvec, valvec)
LQOI.lqs_addmipstarts!(instance::CPLEXOptimizer, colvec, valvec)  = CPX.cpx_addmipstarts!(instance.inner, colvec, valvec) 

#=
    Solve
=#

# LQOI.lqs_mipopt!(m)
LQOI.lqs_mipopt!(instance::CPLEXOptimizer) = CPX.cpx_mipopt!(instance.inner)

# LQOI.lqs_qpopt!(m)
LQOI.lqs_qpopt!(instance::CPLEXOptimizer) = CPX.cpx_qpopt!(instance.inner)

# LQOI.lqs_lpopt!(m)
LQOI.lqs_lpopt!(instance::CPLEXOptimizer) = CPX.cpx_lpopt!(instance.inner)

const TERMINATION_STATUS_MAP = Dict(
    CPX.CPX_STAT_OPTIMAL                => MOI.Success,
    CPX.CPX_STAT_UNBOUNDED              => MOI.UnboundedNoResult,
    CPX.CPX_STAT_INFEASIBLE             => MOI.InfeasibleNoResult,
    CPX.CPX_STAT_INForUNBD              => MOI.InfeasibleOrUnbounded,
    CPX.CPX_STAT_OPTIMAL_INFEAS         => MOI.Success,
    CPX.CPX_STAT_NUM_BEST               => MOI.NumericalError,
    CPX.CPX_STAT_ABORT_IT_LIM           => MOI.IterationLimit,
    CPX.CPX_STAT_ABORT_TIME_LIM         => MOI.TimeLimit,
    CPX.CPX_STAT_ABORT_OBJ_LIM          => MOI.ObjectiveLimit,
    CPX.CPX_STAT_ABORT_USER             => MOI.Interrupted,
    CPX.CPX_STAT_OPTIMAL_FACE_UNBOUNDED => MOI.UnboundedNoResult,
    CPX.CPX_STAT_ABORT_PRIM_OBJ_LIM     => MOI.ObjectiveLimit,
    CPX.CPX_STAT_ABORT_DUAL_OBJ_LIM     => MOI.ObjectiveLimit,
    CPX.CPXMIP_OPTIMAL                  => MOI.Success,
    CPX.CPXMIP_OPTIMAL_TOL              => MOI.Success,
    CPX.CPXMIP_INFEASIBLE               => MOI.InfeasibleNoResult,
    CPX.CPXMIP_SOL_LIM                  => MOI.SolutionLimit,
    CPX.CPXMIP_NODE_LIM_FEAS            => MOI.NodeLimit,
    CPX.CPXMIP_NODE_LIM_INFEAS          => MOI.NodeLimit,
    CPX.CPXMIP_TIME_LIM_FEAS            => MOI.TimeLimit,
    CPX.CPXMIP_TIME_LIM_INFEAS          => MOI.TimeLimit,
    CPX.CPXMIP_FAIL_FEAS                => MOI.OtherError,
    CPX.CPXMIP_FAIL_INFEAS              => MOI.OtherError,
    CPX.CPXMIP_MEM_LIM_FEAS             => MOI.MemoryLimit,
    CPX.CPXMIP_MEM_LIM_INFEAS           => MOI.MemoryLimit,
    CPX.CPXMIP_ABORT_FEAS               => MOI.Interrupted,
    CPX.CPXMIP_ABORT_INFEAS             => MOI.Interrupted,
    CPX.CPXMIP_OPTIMAL_INFEAS           => MOI.Success,
    CPX.CPXMIP_FAIL_FEAS_NO_TREE        => MOI.MemoryLimit,
    CPX.CPXMIP_FAIL_INFEAS_NO_TREE      => MOI.MemoryLimit,
    CPX.CPXMIP_UNBOUNDED                => MOI.UnboundedNoResult,
    CPX.CPXMIP_INForUNBD                => MOI.InfeasibleOrUnbounded
)

# LQOI.lqs_terminationstatus(m)
function LQOI.lqs_terminationstatus(model::CPLEXOptimizer)
    m = model.inner 

    code = CPX.cpx_getstat(m)
    mthd, soltype, prifeas, dualfeas = CPX.cpx_solninfo(m)

    
    if haskey(TERMINATION_STATUS_MAP, code)
        out = TERMINATION_STATUS_MAP[code]
        
        if code == CPX.CPX_STAT_UNBOUNDED && prifeas > 0
            out = MOI.Success
        elseif code == CPX.CPX_STAT_INFEASIBLE && dualfeas > 0
            out = MOI.Success
        end
        return out
    else
        error("Status $(code) has not been mapped to a MOI termination status.")
    end
end

function LQOI.lqs_primalstatus(model::CPLEXOptimizer)
    m = model.inner

    code = CPX.cpx_getstat(m)
    mthd, soltype, prifeas, dualfeas = CPX.cpx_solninfo(m)

    out = MOI.UnknownResultStatus

    if soltype in [CPX.CPX_NONBASIC_SOLN, CPX.CPX_BASIC_SOLN, CPX.CPX_PRIMAL_SOLN]
        if prifeas > 0
            out = MOI.FeasiblePoint
        else
            out = MOI.InfeasiblePoint
        end
    end
    if code == CPX.CPX_STAT_UNBOUNDED #&& prifeas > 0
        out = MOI.InfeasibilityCertificate
    end
    return out
end
function LQOI.lqs_dualstatus(model::CPLEXOptimizer)
    m = model.inner    

    code = CPX.cpx_getstat(m)
    mthd, soltype, prifeas, dualfeas = CPX.cpx_solninfo(m)
    if !LQOI.hasinteger(model)
        if soltype in [CPX.CPX_NONBASIC_SOLN, CPX.CPX_BASIC_SOLN]
            if dualfeas > 0
                out = MOI.FeasiblePoint
            else
                out = MOI.InfeasiblePoint
            end
        else
            out = MOI.UnknownResultStatus
        end
        if code == CPX.CPX_STAT_INFEASIBLE && dualfeas > 0
            out = MOI.InfeasibilityCertificate
        end
        return out
    end
    return MOI.UnknownResultStatus
end


# LQOI.lqs_getx!(m, place)
LQOI.lqs_getx!(instance::CPLEXOptimizer, place) = CPX.cpx_getx!(instance.inner, place) 

# LQOI.lqs_getax!(m, place)
LQOI.lqs_getax!(instance::CPLEXOptimizer, place) = CPX.cpx_getax!(instance.inner, place)

# LQOI.lqs_getdj!(m, place)
LQOI.lqs_getdj!(instance::CPLEXOptimizer, place) = CPX.cpx_getdj!(instance.inner, place)

# LQOI.lqs_getpi!(m, place)
LQOI.lqs_getpi!(instance::CPLEXOptimizer, place) = CPX.cpx_getpi!(instance.inner, place)

# LQOI.lqs_getobjval(m)
LQOI.lqs_getobjval(instance::CPLEXOptimizer) = CPX.cpx_getobjval(instance.inner)

# LQOI.lqs_getbestobjval(m)
LQOI.lqs_getbestobjval(instance::CPLEXOptimizer) = CPX.cpx_getbestobjval(instance.inner)

# LQOI.lqs_getmiprelgap(m)
LQOI.lqs_getmiprelgap(instance::CPLEXOptimizer) = CPX.cpx_getmiprelgap(instance.inner)

# LQOI.lqs_getitcnt(m)
LQOI.lqs_getitcnt(instance::CPLEXOptimizer)  = CPX.cpx_getitcnt(instance.inner)

# LQOI.lqs_getbaritcnt(m)
LQOI.lqs_getbaritcnt(instance::CPLEXOptimizer) = CPX.cpx_getbaritcnt(instance.inner)

# LQOI.lqs_getnodecnt(m)
LQOI.lqs_getnodecnt(instance::CPLEXOptimizer) = CPX.cpx_getnodecnt(instance.inner)

# LQOI.lqs_dualfarkas(m, place)
LQOI.lqs_dualfarkas!(instance::CPLEXOptimizer, place) = CPX.cpx_dualfarkas!(instance.inner, place)

# LQOI.lqs_getray(m, place)
LQOI.lqs_getray!(instance::CPLEXOptimizer, place) = CPX.cpx_getray!(instance.inner, place)


MOI.free!(instance::CPLEXOptimizer) = CPX.free_model(instance.inner)

"""
    writeproblem(m: :MOI.AbstractOptimizer, filename::String)
Writes the current problem data to the given file.
Supported file types are solver-dependent.
"""
writeproblem(instance::CPLEXOptimizer, filename::String, flags::String="") = CPX.write_model(instance.inner, filename)


LQOI.lqs_make_problem_type_continuous(instance::CPLEXOptimizer) = CPX._make_problem_type_continuous(instance.inner)
end # module