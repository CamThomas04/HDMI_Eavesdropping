using DSP, WAV, FFTW, Plots

include("FileLoader.jl")
include("config.jl")

# Load the first data file
z = load_iq(RECORDING_1);

# Interpolate and resample to the pixel clock frequency
z_resampled = resample(z, fp / fs)

function average_frames(z_resampled, xt, yt, n; shift=(235, 215))
    total = zeros(yt, xt)

    for i in 1:n
        # Extract the i-th frame from the resampled data
        z_i = z_resampled[(i-1)*xt*yt+1 : i*xt*yt]
        # Shape the data
        image_i = permutedims(reshape(abs.(z_i), xt, yt))
        # Add to running total
        total .+= circshift(image_i, shift)
    end

    return total ./ n
end

num_frames_to_avg = 10

# Average the frames
averaged_image = average_frames(z_resampled, xt, yt, num_frames_to_avg)

# Plot the averaged image
heatmap(averaged_image, color = :grays, yflip=true)