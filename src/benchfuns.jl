function bench(x)
    b1 = @benchmark SpecialFunctions.loggamma($x)
    b2 = @benchmark OpenLibmPorts.logabsgamma($x)
    b3 = @benchmark OpenLibmPorts.loggamma($x)
    b1, b2, b3
end
meantimes(x) = map(x -> mean(x).time, bench(x))
mintimes(x) = map(x -> minimum(x).time, bench(x))

function bench(f::F, x) where {F}
    b1 = @benchmark SpecialFunctions.($f)($x)
    b2 = @benchmark OpenLibmPorts.($f)($x)
    b1, b2
end
