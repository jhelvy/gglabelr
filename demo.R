library(shiny)
library(miniUI)
library(ggplot2)

# Define plot
p <- ggplot(mpg, aes(x = hwy, y = displ)) +
    geom_point()

# Interactively create a label
makeLabel(p)
