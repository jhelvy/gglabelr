library(gglabelr)
library(ggplot2)

# Make plot
p <- ggplot(mpg, aes(x = hwy, y = displ)) +
    geom_point()

# Interactively annotate the plot
gglabelr(p)
