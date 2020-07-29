library(gglabelr)
library(ggplot2)

# Make plot
p <- ggplot(mpg, aes(x = hwy, y = displ)) +
    geom_point()

# Interactively make a label
makeLabel(p)

# Interactively make a box
makeBox(p)
