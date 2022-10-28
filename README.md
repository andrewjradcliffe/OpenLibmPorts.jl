# OpenLibmPorts

## Installation
```julia
using Pkg
Pkg.add("OpenLibmPorts")
```

## Description
As the name says, ports from openlibm
(https://github.com/JuliaMath/openlibm). This effort was borne of the
need for pure Julia implementations of various special functions for
use in automatic differentation. Expect low coverage as I create ports
only as need dictates.

Why bother, you might ask? In the construction of Bayesian models,
certain special functions may show up in the likelihood (!!!
e.g. loggamma in negative binomial), which means that considerable
latency can be introduced by marginally slower special functions. One
might be inclined to be incredulous at such a statement, but consider
that a log-likelihood computation is essentially a sum involving M
terms, i.e. ∑ᵢ₌₁ᴹ f(xᵢ). The total cost is linear in the number of
terms.  If we assume the cost of summation itself to be negligible
(it's not), then the cost of the log-likelihood is equal to M times
the cost of f. In this light, any reduction to the cost of f
translates directly to an equivalent reduction in the log-likelihood
computation. As the log-likelihood is most often the dominant cost in
a probabilistic model (which does not involve ODEs), reductions
thereof translate directly to reductions in overall time required to
fit a model. 

Note that I am being purposefully vague on what "fitting" means -- we
might require both the evaluation of the log-posterior _and_ its
gradient, or, just the log-posterior (though, that is rare these
days).  In either case, the cost of special functions is not to be
ignored.

## Example
```julia
using OpenLibmPorts

julia> OpenLibmPorts.loggamma(2.009904444771008)
0.004219012233950873

julia> OpenLibmPorts.logabsgamma(2.009904444771008)
(0.004219012233950873, 1)
```

## Benchmark of logabsgamma, loggamma
![benchplot_64](https://github.com/andrewjradcliffe/OpenLibmPorts.jl/main/docs/src/assets/benchplot_64.svg)

![benchplot_32](https://github.com/andrewjradcliffe/OpenLibmPorts.jl/main/docs/src/assets/benchplot_32.svg)
