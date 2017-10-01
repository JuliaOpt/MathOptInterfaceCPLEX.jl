module MathOptInterfaceCPLEX

import Base.show, Base.copy

# Standard LP interface
# importall MathProgBase.SolverInterface

using CPLEX
const CPX = CPLEX
using MathOptInterface
const MOI = MathOptInterface
using LinQuadOptInterface
const LQOI = LinQuadOptInterface


export MOICPLEXSolver
struct MOICPLEXSolver <: LQOI.LinQuadSolver
    options
end
function MOICPLEXSolver(;kwargs...)
    return MOICPLEXSolver(kwargs)
end

import CPLEX.Model
mutable struct CPLEXSolverInstance <: LQOI.LinQuadSolverInstance

    LQOI.@LinQuadSolverInstanceBase
    
end

function MOI.SolverInstance(s::MOICPLEXSolver)

    env = CPX.Env()
    m = CPLEXSolverInstance(
        (LQOI.@LinQuadSolverInstanceBaseInit)...,
    )
    for (name,value) in s.options
        CPX.cpx_setparam!(m.inner.env, string(name), value)
    end
    # csi.inner.mipstart_effort = s.mipstart_effortlevel
    # if s.logfile != ""
    #     LQOI.lqs_setlogfile!(env, s.logfile)
    # end
    return m
end

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
LQOI.lqs_setparam!(m::CPLEXSolverInstance, name, val) = CPX.cpx_setparam!(m.inner, string(name), val)

# LQOI.lqs_setlogfile!(env, path)
# TODO fix this one
LQOI.lqs_setlogfile!(m::CPLEXSolverInstance, path) = CPX.setlogfile(m.inner, path::String)

# LQOI.lqs_getprobtype(m)
# TODO - consider removing, apparently useless

#=
    Constraints
=#

cintvec(v::Vector) = convert(Vector{Int32}, v)
cdoublevec(v::Vector) = convert(Vector{Float64}, v)

# LQOI.lqs_chgbds!(m, colvec, valvec, sensevec)
LQOI.lqs_chgbds!(m::CPX.Model, colvec, valvec, sensevec) = CPX.cpx_chgbds!(m, colvec, valvec, sensevec)

# LQOI.lqs_getlb(m, col)
LQOI.lqs_getlb(m::CPX.Model, col) = CPX.cpx_getlb(m, col)
# LQOI.lqs_getub(m, col)
LQOI.lqs_getub(m::CPX.Model, col) = CPX.cpx_getub(m, col)

# LQOI.lqs_getnumrows(m)
LQOI.lqs_getnumrows(m::CPX.Model) = CPX.cpx_getnumrows(m)

# LQOI.lqs_addrows!(m, rowvec, colvec, coefvec, sensevec, rhsvec)
LQOI.lqs_addrows!(m::CPX.Model, rowvec, colvec, coefvec, sensevec, rhsvec) = CPX.cpx_addrows!(m::CPX.Model, rowvec, colvec, coefvec, sensevec, rhsvec)

# LQOI.lqs_getrhs(m, rowvec)
LQOI.lqs_getrhs(m::CPX.Model, row) = CPX.cpx_getrhs(m, row)  

# colvec, coef = LQOI.lqs_getrows(m, rowvec)
# TODO improve
function LQOI.lqs_getrows(m::CPX.Model, idx)
    return CPX.cpx_getrows(m, idx)
end

# LQOI.lqs_getcoef(m, row, col) #??
# TODO improve
LQOI.lqs_getcoef(m::CPX.Model, row, col) = CPX.cpx_getcoef(m, row, col)

# LQOI.lqs_chgcoef!(m, row, col, coef)
# TODO SPLIT THIS ONE
LQOI.lqs_chgcoef!(m::CPX.Model, row, col, coef)  = CPX.cpx_chgcoef!(m::CPX.Model, row, col, coef)

# LQOI.lqs_delrows!(m, row, row)
LQOI.lqs_delrows!(m::CPX.Model, rowbeg, rowend) = CPX.cpx_delrows!(m::CPX.Model, rowbeg, rowend)

# LQOI.lqs_chgctype!(m, colvec, typevec)
# TODO fix types
LQOI.lqs_chgctype!(m::CPX.Model, colvec, typevec) = CPX.cpx_chgctype!(m::CPX.Model, colvec, typevec)

# LQOI.lqs_chgsense!(m, rowvec, sensevec)
# TODO fix types
LQOI.lqs_chgsense!(m::CPX.Model, rowvec, sensevec) = CPX.cpx_chgsense!(m::CPX.Model, rowvec, sensevec)

const VAR_TYPE_MAP = Dict{Symbol,Cchar}(
    :CONTINUOUS => Cchar('C'),
    :INTEGER => Cchar('I'),
    :BINARY => Cchar('B')
)
LQOI.lqs_vartype_map(m::CPLEXSolverInstance) = VAR_TYPE_MAP

# LQOI.lqs_addsos(m, colvec, valvec, typ)
LQOI.lqs_addsos!(m::CPX.Model, colvec, valvec, typ) = CPX.add_sos!(m::CPX.Model, typ, colvec, valvec)
# LQOI.lqs_delsos(m, idx, idx)
LQOI.lqs_delsos!(m::CPX.Model, idx1, idx2) = CPX.cpx_delsos!(m::CPX.Model, idx1, idx2)

const SOS_TYPE_MAP = Dict{Symbol,Symbol}(
    :SOS1 => :SOS1,#Cchar('1'),
    :SOS2 => :SOS2#Cchar('2')
)
LQOI.lqs_sertype_map(m::CPLEXSolverInstance) = SOS_TYPE_MAP

# LQOI.lqs_getsos(m, idx)
# TODO improve getting processes
function LQOI.lqs_getsos(m::CPX.Model, idx)
    indices, weights, types = CPX.cpx_getsos(m::CPX.Model, idx)

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
LQOI.lqs_getnumqconstrs(m::CPX.Model) = CPX.cpx_getnumqconstrs(m::CPX.Model)

# LQOI.lqs_addqconstr(m, cols,coefs,rhs,sense, I,J,V)
LQOI.lqs_addqconstr!(m::CPX.Model, cols,coefs,rhs,sense, I,J,V) = CPX.cpx_addqconstr!(m::CPX.Model, cols,coefs,rhs,sense, I,J,V)

# LQOI.lqs_chgrngval
LQOI.lqs_chgrngval!(m::CPX.Model, rows, vals) = CPX.cpx_chgrngval!(m::CPX.Model, rows, vals)

const CTR_TYPE_MAP = Dict{Symbol,Cchar}(
    :RANGE => Cchar('R'),
    :LOWER => Cchar('L'),
    :UPPER => Cchar('U'),
    :EQUALITY => Cchar('E')
)
LQOI.lqs_ctrtype_map(m::CPLEXSolverInstance) = CTR_TYPE_MAP

#=
    Objective
=#

# LQOI.lqs_copyquad(m, intvec,intvec, floatvec) #?
LQOI.lqs_copyquad!(m::CPX.Model, I, J, V) = CPX.cpx_copyquad!(m::CPX.Model, I, J, V)

# LQOI.lqs_chgobj(m, colvec,coefvec)
LQOI.lqs_chgobj!(m::CPX.Model, colvec, coefvec)  = CPX.cpx_chgobj!(m::CPX.Model, colvec, coefvec) 

# LQOI.lqs_chgobjsen(m, symbol)
# TODO improve min max names
LQOI.lqs_chgobjsen!(m::CPX.Model, symbol) = CPX.cpx_chgobjsen!(m::CPX.Model, symbol)
    

# LQOI.lqs_getobj(m)
LQOI.lqs_getobj(m::CPX.Model) = CPX.cpx_getobj(m::CPX.Model) 

# lqs_getobjsen(m)
LQOI.lqs_getobjsen(m::CPX.Model) = CPX.cpx_getobjsen(m::CPX.Model)

#=
    Variables
=#

# LQOI.lqs_getnumcols(m)
LQOI.lqs_getnumcols(m::CPX.Model) = CPX.cpx_getnumcols(m::CPX.Model)

# LQOI.lqs_newcols!(m, int)
LQOI.lqs_newcols!(m::CPX.Model, int) = CPX.cpx_newcols!(m::CPX.Model, int)

# LQOI.lqs_delcols!(m, col, col)
LQOI.lqs_delcols!(m::CPX.Model, col, col2) = CPX.cpx_delcols!(m::CPX.Model, col, col2)

# LQOI.lqs_addmipstarts(m, colvec, valvec)
LQOI.lqs_addmipstarts!(m::CPX.Model, colvec, valvec)  = CPX.cpx_addmipstarts!(m::CPX.Model, colvec, valvec) 

#=
    Solve
=#

# LQOI.lqs_mipopt!(m)
LQOI.lqs_mipopt!(m::CPX.Model) = CPX.cpx_mipopt!(m::CPX.Model)

# LQOI.lqs_qpopt!(m)
LQOI.lqs_qpopt!(m::CPX.Model) = CPX.cpx_qpopt!(m::CPX.Model)

# LQOI.lqs_lpopt!(m)
LQOI.lqs_lpopt!(m::CPX.Model) = CPX.cpx_lpopt!(m::CPX.Model)


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
function LQOI.lqs_terminationstatus(model::CPLEXSolverInstance)
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

function LQOI.lqs_primalstatus(model::CPLEXSolverInstance)
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
function LQOI.lqs_dualstatus(model::CPLEXSolverInstance)
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
LQOI.lqs_getx!(m::CPX.Model, place) = CPX.cpx_getx!(m::CPX.Model, place) 

# LQOI.lqs_getax!(m, place)
LQOI.lqs_getax!(m::CPX.Model, place) = CPX.cpx_getax!(m::CPX.Model, place)

# LQOI.lqs_getdj!(m, place)
LQOI.lqs_getdj!(m::CPX.Model, place) = CPX.cpx_getdj!(m::CPX.Model, place)

# LQOI.lqs_getpi!(m, place)
LQOI.lqs_getpi!(m::CPX.Model, place) = CPX.cpx_getpi!(m::CPX.Model, place)

# LQOI.lqs_getobjval(m)
LQOI.lqs_getobjval(m::CPX.Model) = CPX.cpx_getobjval(m::CPX.Model)

# LQOI.lqs_getbestobjval(m)
LQOI.lqs_getbestobjval(m::CPX.Model) = CPX.cpx_getbestobjval(m::CPX.Model)

# LQOI.lqs_getmiprelgap(m)
LQOI.lqs_getmiprelgap(m::CPX.Model) = CPX.cpx_getmiprelgap(m::CPX.Model)

# LQOI.lqs_getitcnt(m)
LQOI.lqs_getitcnt(m::CPX.Model)  = CPX.cpx_getitcnt(m::CPX.Model)

# LQOI.lqs_getbaritcnt(m)
LQOI.lqs_getbaritcnt(m::CPX.Model) = CPX.cpx_getbaritcnt(m::CPX.Model)

# LQOI.lqs_getnodecnt(m)
LQOI.lqs_getnodecnt(m::CPX.Model) = CPX.cpx_getnodecnt(m::CPX.Model)

# LQOI.lqs_dualfarkas(m, place)
LQOI.lqs_dualfarkas!(m::CPX.Model, place) = CPX.cpx_dualfarkas!(m::CPX.Model, place)

# LQOI.lqs_getray(m, place)
LQOI.lqs_getray!(m::CPX.Model, place) = CPX.cpx_getray!(m::CPX.Model, place)


MOI.free!(m::CPLEXSolverInstance) = CPX.free_model(m.inner)

"""
    writeproblem(m::AbstractSolverInstance, filename::String)
Writes the current problem data to the given file.
Supported file types are solver-dependent.
"""
MOI.writeproblem(m::CPLEXSolverInstance, filename::String, flags::String="") = CPX.write_model(m.inner, filename, flags)


LQOI.lqs_make_problem_type_continuous(m::CPX.Model) = CPX._make_problem_type_continuous(m)
end # module