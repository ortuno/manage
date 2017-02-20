# This is the main configuration file for OpenCMISS developers.
#
# See http://www.opencmiss.org/documentation/cmake/docs/config/developer for more details
# or see the subsequent comments.

##
# .. _`component_branches`:
#
# <COMP>_BRANCH
# -------------
#
# Manually set the target branch to checkout for the specified component. Applies to own builds only.
# If this variable is not set, the build system automatically derives the branch name
# from the :var:`<COMP>_VERSION` variable (pattern :cmake:`v<COMP>_VERSION`).
#
# See also: `<COMP>_REPO`_ :ref:`comp_version`

#set(IRON_BRANCH myironbranch)

##
# <COMP>_DEVEL
# ------------
#
# At first, a flag :var:`<COMPNAME>_DEVEL` must be set in order to notify the setup that
# this component (Iron, Zinc, any dependency) should be under development.
#
# See also: `OPENCMISS_DEVEL_ALL`_.
#
# .. default:: NO

#set(IRON_DEVEL YES)

##
# <COMP>_REPO
# ---------------
#
# Set this variable for any component to have the build system checkout the sources from that repository. Applies to own builds only.
#
# If this variable is not specified, the build system setup chooses the default
# public locations at the respective GitHub organizations (OpenCMISS, OpenCMISS-Dependencies etc).
# 
# .. caution::
# 
#    Those adoptions *must* currently be made before the first build is started - once a repository is
#    created there is no logic on changing the repository location (has at least not been tested).
#
# Use in conjunction with `<COMP>_BRANCH`_ if necessary.

#set(IRON_REPO git@github.com:mygithub/iron)

##
# GITHUB_USERNAME
# ---------------
#
# If you set a github username, cmake will automatically try and locate all the
# components as repositories under that github account.
# Currently applies to **all** repositories.
#
# .. default:: <empty>
set(GITHUB_USERNAME )

##
# OC_CLEAN_REBUILDS_COMPONENTS
# ----------------------------
#
# If you issue "make clean" from the manage build folder, normally the external projects (i.e. dependencies) wont completely re-build.
# Set this to true to have the build system remove the CMakeCache.txt of each dependency, which triggers a complete re-build.
# 
# .. default:: YES 
set(OC_CLEAN_REBUILDS_COMPONENTS YES)

##
# OC_DEFAULT_MPI
# --------------
#
# When installing OpenCMISS, the opencmiss-config file defines a default MPI version.
#
# If unspecified, this will always be set to the version used for the latest build.
#
# .. default:: mpich
set(OC_DEFAULT_MPI mpich)

##
# OC_DEFAULT_MPI_BUILD_TYPE
# -------------------------
#
# When installing OpenCMISS, the opencmiss-config file defines a default MPI build type.
#
# If unspecified, this will always be set to the build type used for the latest build.
#
# .. default:: <empty>
set(OC_DEFAULT_MPI_BUILD_TYPE )

##
# OPENCMISS_USE_ARCHITECTURE_PATH
# -------------------------------
#
# Use architecture path to enable multiple configs in the same installation.
#
# .. default:: YES
option(OPENCMISS_USE_ARCHITECTURE_PATH "Use architecture path to enable multiple configs in the same installation." YES)

##
# OPENCMISS_DEVEL_ALL
# ------------
#
# Override any local variable and have CMake download/checkout the "devel" branch of any components repository
#
# See also: `<COMP>_DEVEL`_
#
# .. default:: NO
option(OPENCMISS_DEVEL_ALL "Download/checkout development branches of all components of the OpenCMISS build." NO)

##
# OPENCMISS_INSTALLATION_SUPPORT_EMAIL
# ------------------------------------
# 
# Please set this to your email address, especially if you plan to provide several architecture installations and
# expect people to use your installation
#
# .. default:: OPENCMISS_BUILD_SUPPORT_EMAIL
set(OPENCMISS_INSTALLATION_SUPPORT_EMAIL ${OPENCMISS_BUILD_SUPPORT_EMAIL} CACHE STRING "Please set this to your email address, especially if you plan to provide several architecture installations and expect people to use your installation")

