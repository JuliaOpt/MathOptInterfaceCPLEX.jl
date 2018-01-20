using CPLEX, Base.Test, MathOptInterface, MathOptInterfaceTests, MathOptInterfaceCPLEX


const MOIT = MathOptInterfaceTests
const MOICPX = MathOptInterfaceCPLEX

@testset "MathOptInterfaceCPLEX" begin
    @testset "Linear tests" begin
        linconfig = MOIT.TestConfig()
        solverf() = CPLEXSolverInstance()
        MOIT.contlineartest(solverf, linconfig, ["linear12","linear8a","linear8b","linear8c"])
        
        solverf_nopresolve() = CPLEXSolverInstance(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.contlineartest(solverf_nopresolve , linconfig, ["linear12","linear8b","linear8c"])

        linconfig_nocertificate = MOIT.TestConfig(infeas_certificates=false)
        MOIT.linear12test(solverf, linconfig_nocertificate)
        MOIT.linear8ctest(solverf, linconfig_nocertificate)
        MOIT.linear8btest(solverf, linconfig_nocertificate)
    end

    @testset "Quadratic tests" begin
        quadconfig = MOIT.TestConfig(atol=1e-3, rtol=1e-4, duals=false, query=false)
        solverf() = CPLEXSolverInstance()
        MOIT.contquadratictest(solverf, quadconfig)
    end

    @testset "Linear Conic tests" begin
        linconfig = MOIT.TestConfig()
        solverf() = CPLEXSolverInstance()
        MOIT.lintest(solverf, linconfig, ["lin3","lin4"])

        solverf_nopresolve() = CPLEXSolverInstance(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.lintest(solverf_nopresolve, linconfig)
    end

    @testset "Integer Linear tests" begin
        intconfig = MOIT.TestConfig()
        solverf() = CPLEXSolverInstance()
        MOIT.intlineartest(solverf, intconfig)
    end
end
;
