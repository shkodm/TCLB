# Setting permissive access policy.
#  * This skips checks of fields being overwritten or read prematurely.
#  * Otherwise the model compilation was failing.
#  * This should be removed if the issue is fixed
SetOptions(permissive.access=TRUE)  ### WARNING

# Density - table of variables of LB Node to stream
#	Velocity-based Evolution d3q27:
source("lattice.R")


# macroscopic params
# - consider migrating to fields
AddDensity(name="pnorm", dx=0, dy=0, dz=0, group="Vel")
AddDensity(name="U", dx=0, dy=0, dz=0, group="Vel")
AddDensity(name="V", dx=0, dy=0, dz=0, group="Vel")
AddDensity(name="W", dx=0, dy=0, dz=0, group="Vel")
AddField("PhaseF",stencil3d=1, group="PF")

# Helper fields for the staircase improvement
extra_fields_to_load_for_bc = c()
extra_save_iteration = c()
extra_load_iteration = c()
extra_load_phase = c()

save_initial_PF = c("PF","Vel")
save_initial    = c("g","h","PF")
save_iteration  = c("g","h","Vel","nw", "solid_boundary", extra_save_iteration)
load_iteration  = c("g","h","Vel","nw", "solid_boundary", extra_load_iteration)
load_phase      = c("g","h","Vel","nw", "solid_boundary", extra_load_phase)


######################
########STAGES########
######################
# Remember stages must be added after fields/densities!
AddStage("PhaseInit", "Init", save=Fields$group %in% save_initial_PF)
AddStage("BaseInit" , "Init_distributions", save=Fields$group %in% save_initial)
AddStage("BaseIter" , "Run", save=Fields$group %in% save_iteration, load=DensityAll$group %in% load_iteration )

#######################
########ACTIONS########
#######################
AddAction("Iteration", c("BaseIter"))
AddAction("Init"     , c("PhaseInit", "BaseInit"))

	AddSetting(name="Density_h", comment='High density')
	AddSetting(name="Density_l", comment='Low  density')
	AddSetting(name="PhaseField_h", default=1, comment='PhaseField in Liquid')
	AddSetting(name="PhaseField_l", default=0, comment='PhaseField gas')
	AddSetting(name="PhaseField", 	   comment='Initial PhaseField distribution', zonal=T)
	AddSetting(name="IntWidth", default=4,    comment='Anti-diffusivity coeff')
	AddSetting(name="omega_phi", comment='one over relaxation time (phase field)')
	AddSetting(name="M", omega_phi='1.0/(3*M+0.5)', default=0.02, comment='Mobility')
	AddSetting(name="sigma", comment='surface tension')
    AddSetting(name="UseExternalPressure", default=0, comment='Use external pressure (set from RunR)')
	AddSetting(name="force_fixed_iterator", default=2, comment='to resolve implicit relation of viscous force')
	AddSetting(name="radAngle", default='1.570796', comment='Contact angle in radians, can use units -> 90d where d=2pi/360', zonal=T)
	AddSetting(name="minGradient", default='1e-8', comment='if the phase gradient is less than this, set phase normals to zero')
	##SPECIAL INITIALISATIONS
	# RTI
		AddSetting(name="RTI_Characteristic_Length", default=-999, comment='Use for RTI instability')
	    AddSetting(name="pseudo2D", default="0", comment="if 1, assume model is pseduo2D")
	# Annular Taylor bubble
		AddSetting(name="DonutTime", default=0.0, comment='Radius of a Torus - initialised to travel along x-axis')
		AddSetting(name="Donut_h",   default=0.0, comment='Half donut thickness, i.e. the radius of the cross-section')
		AddSetting(name="Donut_D",   default=0.0, comment='Dilation factor along the x-axis')
		AddSetting(name="Donut_x0",  default=0.0, comment='Position along x-axis')
##############################
########INPUTS - FLUID########
##############################
	AddSetting(name="tau_l", comment='relaxation time (low density fluid)')
	AddSetting(name="tau_h", comment='relaxation time (high density fluid)')
    AddSetting(name="tauUpdate", default="1", comment="Interpolation: 1-linear, 2- inverse, 3- dyn viscosity")
	AddSetting(name="Viscosity_l", tau_l='(3*Viscosity_l)', default=0.16666666, comment='kinematic viscosity')
	AddSetting(name="Viscosity_h", tau_h='(3*Viscosity_h)', default=0.16666666, comment='kinematic viscosity')
	AddSetting(name="VelocityX", default=0.0, comment='inlet/outlet/init velocity', zonal=T)
	AddSetting(name="VelocityY", default=0.0, comment='inlet/outlet/init velocity', zonal=T)
	AddSetting(name="VelocityZ", default=0.0, comment='inlet/outlet/init velocity', zonal=T)
	AddSetting(name="Pressure" , default=0.0, comment='inlet/outlet/init density', zonal=T)
    AddSetting(name='InvasionDrainage', default=0, comment="0 nothing, anything bigger is invasion/drainage case")
	AddSetting(name="GravitationX", default=0.0, comment='applied (rho)*GravitationX')
	AddSetting(name="GravitationY", default=0.0, comment='applied (rho)*GravitationY')
	AddSetting(name="GravitationZ", default=0.0, comment='applied (rho)*GravitationZ')
	AddSetting(name="BuoyancyX", default=0.0, comment='applied (rho_h-rho)*BuoyancyX')
	AddSetting(name="BuoyancyY", default=0.0, comment='applied (rho_h-rho)*BuoyancyY')
	AddSetting(name="BuoyancyZ", default=0.0, comment='applied (rho_h-rho)*BuoyancyZ')
########NODE TYPES########
##########################
	AddNodeType("Smoothing",group="ADDITIONALS")
	AddNodeType(name="flux_nodes", group="ADDITIONALS")
    # the first one are "fflux"
	AddNodeType(name="MovingWall_N", group="BOUNDARY")
	AddNodeType(name="MovingWall_S", group="BOUNDARY")
	AddNodeType(name="Solid", group="BOUNDARY")
	AddNodeType(name="Wall", group="BOUNDARY")
	AddNodeType(name="BGK", group="COLLISION")
	AddNodeType(name="MRT", group="COLLISION")
