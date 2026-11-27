include(joinpath(@__DIR__, "..", "src", "HDMIEavesdropping.jl"))
using .HDMIEavesdropping, DSP, WAV, FFTW, Plots
include(joinpath(@__DIR__, "config.jl"))

# Load the first data file
z = load_iq(RECORDING_1);

# Take the first 30 million samples for pixel clock estimation
z_short = z[1:30_000_000]  

# Add noise
noise_db = -5
z_noisy = add_noise(z_short, noise_db)

# Estimate fp
fp_estimated = estimate_pixel_clock_frequency(z_noisy, fs, xt, yt)[2]

# Resample
z_resampled = resample(z_noisy, fp_estimated / fs)

# Find the frame start
start = find_frame_start(z_resampled, xt, yt; n=10)

# Truncate to the first live pixel
z_truncated = z_resampled[start:end]

print(fp_estimated)

# Average the frames
num_frames_to_avg = 10
averaged_image = average_frames(z_truncated, xt, yt, num_frames_to_avg; shift=(0,0))

# Plot the averaged image
p1 = heatmap(averaged_image, color = :grays, yflip=true, size=(1600,900), aspectratio=1, title="Average Over $num_frames_to_avg Images w/ $noise_db dB SNR")