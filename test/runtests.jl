using CPLEX, Base.Test, MathOptInterface, MathOptInterface.Test, MathOptInterfaceCPLEX

const MOIT = MathOptInterface.Test
const MOICPX = MathOptInterfaceCPLEX

@testset "MathOptInterfaceCPLEX" begin
    @testset "Linear tests" begin
        linconfig = MOIT.TestConfig()
        solver = CPLEXOptimizer()
        MOIT.contlineartest(solver, linconfig, ["linear12","linear8a","linear8b","linear8c"])
        
        solver_nopresolve = CPLEXOptimizer(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.contlineartest(solver_nopresolve , linconfig, ["linear12","linear8b","linear8c"])

        linconfig_nocertificate = MOIT.TestConfig(infeas_certificates=false)
        MOIT.linear12test(solver, linconfig_nocertificate)
        MOIT.linear8ctest(solver, linconfig_nocertificate)
        MOIT.linear8btest(solver, linconfig_nocertificate)
    end

    @testset "Quadratic tests" begin
        quadconfig = MOIT.TestConfig(atol=1e-3, rtol=1e-4, duals=false, query=false)
        solver = CPLEXOptimizer()
        MOIT.contquadratictest(solver, quadconfig)
    end

    @testset "Linear Conic tests" begin
        linconfig = MOIT.TestConfig()
        solver = CPLEXOptimizer()
        MOIT.lintest(solver, linconfig, ["lin3","lin4"])

        solver_nopresolve = CPLEXOptimizer(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.lintest(solver_nopresolve, linconfig)
    end

    @testset "Integer Linear tests" begin
        intconfig = MOIT.TestConfig()
        solver = CPLEXOptimizer()
        MOIT.intlineartest(solver, intconfig)
    end
end
;
