PKG_ROOT    = .
PKG_VERSION = $(shell gawk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    = $(shell gawk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)

CRAN = "https://cran.rstudio.com"

# General Package Dependencies
RFILES    = $(wildcard $(PKG_ROOT)/R/*.R)
EXAMPLES  = $(wildcard $(PKG_ROOT)/examples/*.R)
TESTS     = $(wildcard $(PKG_ROOT)/tests/testthat/*.R)

################################################################################
# Recipes

.PHONY: all check install clean covr

all: $(PKG_NAME)_$(PKG_VERSION).tar.gz

$(PKG_NAME)_$(PKG_VERSION).tar.gz: .install_dev_deps.Rout .document.Rout $(VIGNETTES) $(TESTS)
	R CMD build --md5 $(build-options) $(PKG_ROOT)

.install_dev_deps.Rout : $(PKG_ROOT)/DESCRIPTION
	Rscript --vanilla --quiet -e "options(repo = c('$(CRAN)'))" \
		-e "if (!require(devtools)) {install.packages('devtools', repo = c('$(CRAN)'))}" \
		-e "options(warn = 2)" \
		-e "devtools::install_dev_deps()"
	@touch $@

.document.Rout: $(SRC) $(RFILES) $(DATATARGETS) $(EXAMPLES) $(PKG_ROOT)/DESCRIPTION
	Rscript --vanilla --quiet -e "options(warn = 2)" \
		-e "devtools::document('$(PKG_ROOT)')"
	@touch $@

check: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	Rscript --vanilla --quiet -e "options(repo = c('$(CRAN)'))" \
		-e "if (!require(rcmdcheck)) {install.packages('rcmdcheck', repo = c('$(CRAN)'))}" \
	  -e 'rcmdcheck::rcmdcheck("$<", error_on = "note")'

check-as-cran: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD check --as-cran $(PKG_NAME)_$(PKG_VERSION).tar.gz

install: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD INSTALL $(PKG_NAME)_$(PKG_VERSION).tar.gz

uninstall :
	R --vanilla --quiet -e "try(remove.packages('pedalfast.data'), silent = TRUE)"

clean:
	$(RM) -f  $(PKG_NAME)_$(PKG_VERSION).tar.gz
	$(RM) -rf $(PKG_NAME).Rcheck
	$(RM) -f .document.Rout
	$(RM) -f .install_dev_deps.Rout

