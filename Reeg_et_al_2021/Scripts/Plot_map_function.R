#####
# Code is adapted from https://github.com/marcosci/layer
#####
plot_tiltedmaps_2 <- function(map_list, layer = NA, palette = "viridis", color = "grey50", direction = 1, begin = 0, end = 1, alpha = 1, limit = c(5, max(getValues(feed.raster.100))),
                              label = "Landcape", xmin = NA, ymax = NA) {
  
  ## checks ----
  if(all(is.na(layer))) layer <- "value"
  if(length(layer) == 1) layer <- rep(layer, length(map_list))
  if(length(alpha) == 1) alpha <- rep(alpha, length(map_list))
  if(length(direction) == 1) direction <- rep(direction, length(map_list))
  if(length(begin) == 1) begin <- rep(begin, length(map_list))
  if(length(end) == 1) end <- rep(end, length(map_list))
  
  # fill in palettes and colors
  if(length(palette) == 1) palette <- rep(palette, length(map_list))
  if(length(color) == 1) color <- rep(color, length(map_list))

  if(length(map_list) > 1) {
    for (i in seq_along(map_list)[-1]) {
      if(!is.na(layer[[i]])){
        map_tilt <- map_tilt +
          ggnewscale::new_scale_fill() +
          ggnewscale::new_scale_color()  +
          geom_sf(
            data = map_list[[i]],
            aes_string(fill = layer[[i]],
                       color = layer[[i]]), size = .5
          ) +
          annotate("Text", x = xmin[i], y = ymax[i] , label = label[i]) +
          {
            if (palette[i] %in% c("viridis", "inferno", "magma", "plasma", "cividis", "mako", "rocket", "turbo", letters[1:9])) 
              scale_fill_viridis_c(limits=c(0,limit[i]), option = palette[i], direction = direction[i], begin = begin[i], end = end[i], alpha = alpha[i], guide = "none")
          } +
          {
            if (palette[i] %in% c("viridis", "inferno", "magma", "plasma", "cividis", "mako", "rocket", "turbo", letters[1:9])) 
              scale_color_viridis_c(limits=c(0,limit[i]),option = palette[i], direction = direction[i], begin = begin[i], end = end[i], alpha = alpha[i], guide = "none")
          } +
          {
            if (palette[i] %in% scico::scico_palette_names()) 
              scico::scale_fill_scico(limits=c(0,limit[i]),palette = palette[i], direction = direction[i], begin = begin[i], end = end[i], alpha = alpha[i], guide = "none")
          } +
          {
            if (palette[i] %in% scico::scico_palette_names()) 
              scico::scale_color_scico(limits=c(0,limit[i]),palette = palette[i], direction = direction[i], begin = begin[i], end = end[i], alpha = alpha[i], guide = "none")
          }     
      } else {
        map_tilt <- map_tilt +
          geom_sf(
            data  = map_list[[i]],
            color = color[i],
            alpha = alpha[i]
          )
      }
    }
    map_tilt <- map_tilt +
      guides(fill=guide_colorbar(title="Feeding intensity"))
  }
  
  map_tilt +
    theme_void() 
  
}