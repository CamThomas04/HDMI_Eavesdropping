using Random, Statistics

function add_noise(z, snr_db; rng=Random.default_rng())
    #Average Signal Power
    power = mean(abs2, z)

    # Noise standard deviation
    std_dev = sqrt(power / 10^(snr_db / 10))

    # Return the signal with random Gaussian noise scaled by the snr
    return z .+ std_dev .* randn(rng, eltype(z), size(z))
end