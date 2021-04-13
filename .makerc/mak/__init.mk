#! @revision  2021-04-13 (Tue) 17:39:01
#! @brief     Make and KornShell environment setup

NPM_VENDORDIR   = node_modules
export MAKEHOME = $(PWD)
export MAKERC  := $(MAKEHOME)/$(MAKERC)
export FPATH   := $(MAKERC)/ksh:$(FPATH)
export  PATH   := $(PATH):$(NPM_VENDORDIR)/.bin:$(MAKERC)/bin

# vim: noet fdm=marker fmr=@{,@} ts=4
