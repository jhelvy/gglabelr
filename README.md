
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

<a href="https://github.com/jhelvy/gglabelr" target="_blank">
<i class="fa fa-github fa-lg"></i></a>
<a href="https://shiny.rstudio.com/" target="_blank">Built with <img alt="Shiny" src="https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png" height="20"></a>

Interactively add annotations to a ggplot.

## Installation

Currently you can only install the development version of the package via GitHub:
```
devtools::install_github('jhelvy/gglabelr')
```

## Usage

First, load the libraries and create a plot using ggplot

```
library(gglabelr)
library(ggplot2)

p <- ggplot(mpg, aes(x = hwy, y = displ)) +
    geom_point()
```

Use the `makeLabel()` function to interactively add a label to the plot:

```
makeLabel(p)
```

Use the `makeBox()` function to interactively add a box to the plot:

```
makeBox(p)
```

After you press the "done" button, the window will close and the code to create the label or box will print to the console.
