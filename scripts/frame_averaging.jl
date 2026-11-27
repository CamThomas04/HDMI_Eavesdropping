include(joinpath(@__DIR__, "..", "src", "HDMIEavesdropping.jl"))
using .HDMIEavesdropping, DSP, WAV, FFTW, Plots
include(joinpath(@__DIR__, "config.jl"))

# Load the first data file
z = load_iq(RECORDING_1);

# Take the first 15 million samples for pixel clock estimation
z_short = z[1:30_000_000]  

fp_estimated = estimate_pixel_clock_frequency(z_short, fs, xt, yt)[2]

# Interpolate and resample to the pixel clock frequency
z_resampled_emp = resample(z_short, fp / fs)
z_resampled_est = resample(z_short, fp_estimated / fs)

num_frames_to_avg = 10

# Average the frames
averaged_image_emp = average_frames(z_resampled_emp, xt, yt, num_frames_to_avg)
averaged_image_est = average_frames(z_resampled_est, xt, yt, num_frames_to_avg)

# Plot the averaged images
p1 = heatmap(averaged_image_emp, color = :grays, yflip=true, size=(1600,900), aspectratio=1, title="Average Over $num_frames_to_avg Images Using Empircal Frame Rate Guess")
p2 = heatmap(averaged_image_est, color = :grays, yflip=true, size=(1600,900), aspectratio=1, title="Average Over $num_frames_to_avg Images Using Estimated Frame Rate")

display(p1)
savefig(p1, "Images/empirical.png")

display(p2)
savefig(p2, "Images/estimated.png")

println("empirical: ", fp / 1e6, " MHz")
println("estimated: ", fp_estimated / 1e6, " MHz")
println("difference: ", (fp_estimated - fp) / fp * 1e6, " ppm")