using DSP, WAV, FFTW, Plots

include("FileLoader.jl")
include("config.jl")
include("PixelClock.jl")

# Load the first data file
z = load_iq(RECORDING_1);

# Take the first 15 million samples for pixel clock estimation
z_short = z[1:30_000_000]  

fp_estimated = estimate_pixel_clock_frequency(z_short, fs, xt, yt)[2]

# Interpolate and resample to the pixel clock frequency
z_resampled_emp = resample(z_short, fp / fs)
z_resampled_est = resample(z_short, fp_estimated / fs)

function average_frames(z, xt, yt, n; shift=(195, 215))
    total = zeros(yt, xt)

    for i in 1:n
        # Extract the i-th frame from the resampled data
        z_i = z[(i-1)*xt*yt+1 : i*xt*yt]
        # Shape the data
        image_i = permutedims(reshape(abs.(z_i), xt, yt))
        # Add to running total
        total .+= circshift(image_i, shift)
    end

    return total ./ n
end

num_frames_to_avg = 20

# Average the frames
averaged_image_emp = average_frames(z_resampled_emp, xt, yt, num_frames_to_avg)
averaged_image_est = average_frames(z_resampled_est, xt, yt, num_frames_to_avg)

# Plot the averaged images
p1 = heatmap(averaged_image_emp, color = :grays, yflip=true, size=(1600,900), aspectratio=1, title="Average Over 20 Images Using Empircal Frame Rate Guess")
p2 = heatmap(averaged_image_est, color = :grays, yflip=true, size=(1600,900), aspectratio=1, title="Average Over 20 Images Using Estimated Frame Rate")

display(p1)
savefig(p1, "empirical.png")

display(p2)
savefig(p2, "estimated.png")

println("empirical: ", fp / 1e6, " MHz")
println("estimated: ", fp_estimated / 1e6, " MHz")
println("difference: ", (fp_estimated - fp) / fp * 1e6, " ppm")