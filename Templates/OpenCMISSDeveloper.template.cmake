# We recommend using the architecture path for OpenCMISS developers.
SET(OCM_USE_ARCHITECTURE_PATH YES)

# Set this to YES to build with the -p profiling flags.
SET(OCM_WITH_PROFILING NO)

# If you set a github username, cmake will automatically try and locate all the components as repositories under that github account.
#SET(GITHUB_USERNAME )

# If enabled, ssl connections like git@github.com/username are used instead of https access.
# Requires public key registration with github but wont require to enter the password every time. 
#SET(GITHUB_USE_SSL YES)

# If you issue "make clean" from the manage build folder, normally the external projects (i.e. dependencies) wont completely re-build.
# Set this to true to have the build system remove the CMakeCache.txt of each dependency, which triggers a complete re-build. 
SET(OCM_CLEAN_REBUILDS_COMPONENTS NO)