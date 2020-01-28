ST.scitype(image::AbstractArray{<:Gray,2}, ::MLJ) =
    GrayImage{size(image)...}
ST.scitype(image::AbstractArray{<:AbstractRGB,2}, ::MLJ) =
    ColorImage{size(image)...}
