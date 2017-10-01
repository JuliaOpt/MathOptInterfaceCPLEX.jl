using CPLEX, Base.Test, MathOptInterface, MathOptInterfaceCPLEX
include(joinpath(Pkg.dir("MathOptInterface"), "test", "contlinear.jl"))
include(joinpath(Pkg.dir("MathOptInterface"), "test", "intlinear.jl"))
include(joinpath(Pkg.dir("MathOptInterface"), "test", "contconic.jl"))
include(joinpath(Pkg.dir("MathOptInterface"), "test", "contquadratic.jl"))


# contlinear
linear1test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear2test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear3test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear4test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear5test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear6test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear7test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear8test(MathOptInterfaceCPLEX.MOICPLEXSolver()) # infeasible/unbounded
linear9test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear10test(MathOptInterfaceCPLEX.MOICPLEXSolver())
linear11test(MathOptInterfaceCPLEX.MOICPLEXSolver())

# intlinear
knapsacktest(MathOptInterfaceCPLEX.MOICPLEXSolver())
int1test(MathOptInterfaceCPLEX.MOICPLEXSolver())
int2test(MathOptInterfaceCPLEX.MOICPLEXSolver()) # SOS
int3test(MathOptInterfaceCPLEX.MOICPLEXSolver())

# contconic
lin1tests(MathOptInterfaceCPLEX.MOICPLEXSolver())
lin2tests(MathOptInterfaceCPLEX.MOICPLEXSolver())
lin3test(MathOptInterfaceCPLEX.MOICPLEXSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)) # infeasible
lin4test(MathOptInterfaceCPLEX.MOICPLEXSolver(CPX_PARAM_SCRIND=0, CPX_PARAM_PREIND=0)) # infeasible

# # contquadratic
qp1test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-5)
qp2test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-5)
qp3test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-3)
qcp1test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-4)
qcp2test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-5)
qcp3test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-5)
socp1test(MathOptInterfaceCPLEX.MOICPLEXSolver(), atol = 1e-5)
