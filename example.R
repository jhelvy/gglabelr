# library(gglabelr)
library(ggplot2)

# Make plot
p <- ggplot(mpg, aes(x = displ, y = hwy)) +
    geom_point(aes(fill = as.factor(cyl)),
               color = 'white', alpha = 0.8,
               size = 3.5, shape = 21) + 
    theme_minimal(base_size = 15) +
    labs(x = "Engine displacement",
         y = "Fuel efficiency (mpg)",
         fill = '# cylinders',
         title = "Vehicle fuel efficiency vs. engine displacement",
         caption = "Data source: U.S. EPA.")

# Interactively annotate the plot
gglabelr(p)
