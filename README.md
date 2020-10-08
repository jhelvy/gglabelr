
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

<a href="https://github.com/jhelvy/gglabelr" target="_blank">
<i class="fa fa-github fa-lg"></i></a>
<a href="https://shiny.rstudio.com/" target="_blank">Built with <img alt="Shiny" src="https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png" height="20"></a>

A shiny gadget that helps you interactively annotate a ggplot. Currently supports:

- Adding a label
- Drawing a box

<img src="images/preview.gif" width=660>

## Installation

You can install the development version of the package via GitHub:
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

Use the `gglabelr()` function to interactively annotate the plot:

```
gglabelr(p)
```

Copy the code to produce the annotations in the "Get the code" tab. The code will also print to the console when you close the app by pressing the "done" button.
