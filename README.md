# pTITAN2

[![R-CMD-check](https://github.com/sfigary/pTITAN2/actions/workflows/check-full.yaml/badge.svg)](https://github.com/sfigary/pTITAN2/actions/workflows/check-full.yaml)

pTITAN2 is an extension to the
[TITAN2](https://CRAN.R-project.org/package=TITAN2) package by Matthew E. Baker,
Ryan S. King and David Kahle. The TITAN2 package is used for performing Taxa
Indicator Threshold ANalysis (TITAN) in R (Baker and King, 2010). The TITAN2 package
generates change points along an environmental gradient for individual taxa and for
composites of increasing or decreasing taxa, along with associated confidence intervals,
the latter via bootstrapping.  While some scientists examine the overlap between
confidence intervals to determine whether the difference between two point estimates
is significantly different, this approach is more conservative than the standard
approach for assessing significant differences and rejects the null hypothesis
less often than standard approaches (Schenker and Gentleman 2001, Greenland et al. 2016).
"As with P values, comparison between groups requires statistics that directly test and
estimate the differences across groups." (Greenland et al. 2016). __This package,
pTITAN2, enables comparing TITAN2 output between treatments by permuting
the observed data between treatments and rerunning TITAN on the permuted
data.__ There are some limitations on the permutations, including (1) a site
cannot occur in a category more than once, the same limitation as in the original
TITAN runs and (2) the original sample size distribution is maintained. This
addresses potential sample size effects and enables comparisons between
treatments with different sampling sizes.


## EPA Disclaimer

The United States Environmental Protection Agency (EPA) GitHub project code is
provided on an "as is" basis and the user assumes responsibility for its use.
EPA has relinquished control of the information and no longer has responsibility
to protect the integrity , confidentiality, or availability of the information.
Any reference to specific commercial products, processes, or services by service
mark, trademark, manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by EPA.  The EPA seal and logo shall not
be used in any manner to imply endorsement of any commercial product or activity
by EPA or the United States Government.

## License
This package is released under the MIT license.
