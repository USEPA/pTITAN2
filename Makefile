PKG_ROOT    = .
PKG_VERSION = $(shell gawk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION) PKG_NAME    = $(shell gawk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)

CRAN = "https://cran.rstudio.com"

# General Package Dependencies
DATA      = $(PKG_ROOT)/data/C_IC_N_06_wID.rda
DATA     += $(PKG_ROOT)/data/C_IC_D_06_wID.rda
DATA     += $(PKG_ROOT)/data/CD_06_Mall_wID.rda
DATA     += $(PKG_ROOT)/data/CN_06_Mall_wID.rda
RFILES    = $(wildcard $(PKG_ROOT)/R/*.R)
VIGNETTES = $(wildcard $(PKG_ROOT)/vignettes/*.Rmd)
TESTS     = $(wildcard $(PKG_ROOT)/tests/testthat/*.R)

################################################################################
# Recipes

.PHONY: all check install clean coverage-report.html

all: $(PKG_NAME)_$(PKG_VERSION).tar.gz

$(PKG_NAME)_$(PKG_VERSION).tar.gz: .install_dev_deps.Rout .document.Rout $(VIGNETTES) $(TESTS) $(DATA)
	R CMD build --md5 $(build-options) $(PKG_ROOT)

.install_dev_deps.Rout : $(PKG_ROOT)/DESCRIPTION
	Rscript --vanilla --quiet -e "options(repo = c('$(CRAN)'))" \
		-e "if (!require(devtools)) {install.packages('devtools', repo = c('$(CRAN)'))}" \
		-e "options(warn = 2)" \
		-e "devtools::install_dev_deps()"
	@touch $@

.document.Rout: $(SRC) $(RFILES) $(DATA) $(PKG_ROOT)/data/permutation_example.rda $(EXAMPLES) $(PKG_ROOT)/DESCRIPTION
	Rscript --vanilla --quiet -e "options(warn = 2)" \
		-e "devtools::document('$(PKG_ROOT)')"
	@touch $@

$(PKG_ROOT)/data/%.rda : inst/extdata/%.csv
	Rscript --vanilla -e "$(basename $(notdir $<)) <- read.csv('$<', colClasses = c(StationID = 'character'))"
		-e "save($(basename $(notdir $<)), file = '$@')"

$(PKG_ROOT)/data/permutation_example.rda : inst/example-scripts/permutation_example.R $(DATA) $(PKG_ROOT)/R/permute.R $(PKG_ROOT)/R/occurrences.R
	Rscript --vanilla -e "source('$<')"\
		-e "save($(basename $(notdir $<)), file = '$@')"

check: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	Rscript --vanilla --quiet -e "options(repo = c('$(CRAN)'))" \
		-e "if (!require(rcmdcheck)) {install.packages('rcmdcheck', repo = c('$(CRAN)'))}" \
	  -e 'rcmdcheck::rcmdcheck("$<", error_on = "note")'

check-as-cran: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD check --as-cran $(PKG_NAME)_$(PKG_VERSION).tar.gz

install: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD INSTALL $(PKG_NAME)_$(PKG_VERSION).tar.gz

uninstall :
	R --vanilla --quiet -e "try(remove.packages('pTITAN2'), silent = TRUE)"

coverage-report.html : $(R) $(TESTS) $(VIGNETTES)
	Rscript --vanilla --quiet -e "options(repo = c('$(CRAN)'))" \
		-e "if (!require(git2r)) {install.packages('git2r', repo = c('$(CRAN)'))}" \
		-e "if (!require(covr)) {install.packages('covr', repo = c('$(CRAN)'))}" \
		-e "git2r::status()"\
		-e "git2r::repository('.')"\
		-e "coverage <- covr::package_coverage(type = 'tests')"\
		-e "covr::report(coverage, file = 'coverage-report.html')"

manuscript.docx : vignettes/pTITAN2.Rmd vignettes/template.docx
	R --vanilla --quiet -e 'rmarkdown::render("$<", output_format = "bookdown::word_document2")'
	mv vignettes/pTITAN2.docx $@

clean:
	$(RM) -f  $(PKG_NAME)_$(PKG_VERSION).tar.gz
	$(RM) -rf $(PKG_NAME).Rcheck
	$(RM) -f .document.Rout
	$(RM) -f .install_dev_deps.Rout

