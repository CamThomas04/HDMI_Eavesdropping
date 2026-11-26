using FFTW, Statistics

function find_frame_start(z, xt, yt; n=10, H=(640, 16, 96, 48), V=(480, 10, 2, 33))

    # Circular Cross-Correlation Helper Function
    function circ_xcorr(a, b)
        real(ifft(fft(a .- mean(a)) .* conj(fft(b .- mean(b)))))
    end

    # Offset Finder Helper Function
    function best_offset(profile, template)
        # Compute the circular cross-correlation
        corr = circ_xcorr(profile, template)

        # Find the index of the maximum correlation
        max_index = argmax(abs.(corr)) - 1

        return max_index
    end

    # -- Pass 1: Fine the Line Start
    h = zeros(xt)
    # Fill with a mask for the sync interval (H[3])
    h[H[1]+1 : H[1]+H[2]] .= 1.0 # front porch
    h[H[1]+H[2]+H[3]+1 : end] .= 1.0 # back porch
    # Average the first n frames
    avg = average_frames(z, xt, yt, n; shift=(0, 0))
    # Calculate the profile and find the best offset
    column_shift = best_offset(vec(mean(avg, dims=1)), h)

    # -- Pass 2: Find the First Active Line
    v = zeros(yt)
    # Fill with a mask for the full vertical blanking interval
    v[V[1]+1:end] .= 1.0
    # Average the first n frames with the column shift applied
    avg = average_frames(z[column_shift+1:end], xt, yt, n; shift=(0, 0))
    row_shift = best_offset(vec(mean(avg, dims=2)), v) 

    # -- Return the index of the active pixel
    return row_shift * xt + column_shift + 1
end

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