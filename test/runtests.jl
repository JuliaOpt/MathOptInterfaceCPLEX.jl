using CPLEX, Base.Test, MathOptInterface, MathOptInterfaceTests, MathOptInterfaceCPLEX


const MOIT = MathOptInterfaceTests
const MOICPX = MathOptInterfaceCPLEX

@testset "MathOptInterfaceCPLEX" begin
    @testset "Linear tests" begin
        linconfig = MOIT.TestConfig(1e-8,1e-8,true,true,true)
        solver = MOICPX.MOICPLEXSolver()
        MOIT.contlineartest(solver , linconfig, ["linear12","linear8a","linear8b","linear8c"])
        
        solver_nopresolve = MOICPX.MOICPLEXSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.contlineartest(solver_nopresolve , linconfig, ["linear12","linear8b","linear8c"])

        linconfig_nocertificate = MOIT.TestConfig(1e-8,1e-8,true,true,false)
        MOIT.linear12test(solver, linconfig_nocertificate)
        MOIT.linear8ctest(solver, linconfig_nocertificate)
        MOIT.linear8btest(solver, linconfig_nocertificate)
    end

    @testset "Quadratic tests" begin
        quadconfig = MOIT.TestConfig(1e-5,1e-3,false,true,true)
        solver = MOICPX.MOICPLEXSolver()
        MOIT.contquadratictest(solver, quadconfig)
    end

    @testset "Linear Conic tests" begin
        linconfig = MOIT.TestConfig(1e-8,1e-8,true,true,true)
        solver = MOICPX.MOICPLEXSolver()
        MOIT.lintest(solver, linconfig, ["lin3","lin4"])

        solver_nopresolve = MOICPX.MOICPLEXSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)
        MOIT.lintest(solver_nopresolve, linconfig)
    end

    @testset "Integer Linear tests" begin
        intconfig = MOIT.TestConfig(1e-8,1e-8,true,true,true)
        solver = MOICPX.MOICPLEXSolver()
        MOIT.intlineartest(solver, intconfig)
    end
end
;
