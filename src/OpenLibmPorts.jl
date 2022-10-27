module OpenLibmPorts

include("e_lgamma_r.jl")
include("e_lgammaf_r.jl")

# Matches behavior of SpecialFunctions' loggamma, but is ≈ 25% faster since the
# negative sign is not returned, but rather, a DomainError is thrown.
loggamma(x::Number) = loggamma(float(x))
loggamma(x::Float64) = loggamma_r(x)
loggamma(x::Float32) = loggammaf_r(x)
loggamma(x::Float16) = Float16(loggammaf_r(Float32(x)))


# Matches behavior of SpecialFunctions' logabsgamma
_logabsgamma(x::Float64) = lgamma_r(x)
function _logabsgamma(x::Float32)
    y, s = lgammaf_r(x)
    y, Int(s)
end
function _logabsgamma(x::Float16)
    y, s = lgammaf_r(Float32(x))
    Float16(y), s
end

logabsgamma(x::Number) = logabsgamma(float(x))
logabsgamma(x::Base.IEEEFloat) = _logabsgamma(x)

####
#=
Equivalent functions from SpecialFunctions, defined using the above drop-in
replacements. Why bother? Pure Julia, hence, differentiable without
ChainRules, ChainRulesCore, etc.

Why bother, you might ask? In the construction of Bayesian models,
certain special functions may show up in the likelihood (!!!
e.g. loggamma in negative binomial), which means that considerable
latency can be introduced by marginally slower special functions. One
might be inclined to be incredulous at such a statement, but consider
that a log-likelihood computation is essentially a sum involving M
terms, i.e. ∑ᵢ₌₁ᴹ f(xᵢ). This cost is linear in the number terms,
thus, we have M evals of f. If we assume the cost of summation itself
to be negligible (it's not), then the cost of the log-likelihood is
equal to M times the cost of f. In this light, any reduction to the
cost of f translates directly to an equivalent reduction in the
log-likelihood computation. As the log-likelihood is most often the
dominant cost in a probabilistic model (which does not involve ODEs),
reductions thereof translate directly to reductions in overall time
required to fit the model.

=#

end
