function bench_lpgt(x)
    b1 = @benchmark looped($x)
    b2 = @benchmark goto($x)
    b1, b2
end
mintimes_lpgt(x) = map(x -> minimum(x).time, bench_lpgt(x))
