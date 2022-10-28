function bench(x)
    b1 = @benchmark SpecialFunctions.loggamma($x)
    b2 = @benchmark OpenLibmPorts.logabsgamma($x)
    b3 = @benchmark OpenLibmPorts.loggamma($x)
    b1, b2, b3
end
meantimes(x) = map(x -> mean(x).time, bench(x))
mintimes(x) = map(x -> minimum(x).time, bench(x))
