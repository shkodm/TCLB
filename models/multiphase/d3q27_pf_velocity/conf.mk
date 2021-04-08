ADJOINT=0
TEST=FALSE
OPT="(OutFlow+BGK+thermo*planarBenchmark)*autosym*(WETBC1 + WETBC2 + WETBC3)*(tauinverse + taulinear + visclinear + viscinverse)"
# SC: Solid Contact
# 	This option currently fixes the bottom layer of nodes to be 
# 	solid with the contact angle defined in input.
# thermo: thermocapillary flows
# 	Options resolves the temperature field with an RK4 integration
# 	and updates the surface tension as a result
