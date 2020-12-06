
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gglabelr

<a href="https://github.com/jhelvy/gglabelr" target="_blank">
<i class="fa fa-github fa-lg"></i></a>
<a href="https://shiny.rstudio.com/" target="_blank">Built with
<img alt="Shiny" src="https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png" height="20"></a>

A shiny gadget for interactively annotating a ggplot. Currently
supports:

  - Adding a label
  - Drawing a box

<img src="images/preview.gif" width=660>

## Installation

You can install the development version of the package via GitHub:

## Usage

First, load the libraries and create a plot using ggplot

Use the `gglabelr()` function to interactively annotate the plot:

    gglabelr(p)

Copy the code to produce the annotations in the “Get the code” tab. The
code will also print to the console when you close the app by pressing
the “done” button.

## Author, Version, and License Information

  - Author: *John Paul Helveston*
    [www.jhelvy.com](http://www.jhelvy.com/)
  - Date First Written: *September 27, 2020*
  - Most Recent Update: December 06 2020
  - License:
    [MIT](https://github.com/jhelvy/gglabelr/blob/master/LICENSE.md)
  - [Latest
    Release](https://github.com/jhelvy/gglabelr/releases/latest): 0.0.1

## Citation Information

If you use this package for in a publication, I would greatly appreciate
it if you cited it. You can get the citation information by typing
`citation("gglabelr")` into R:

    #> Warning in citation("gglabelr"): no date field in DESCRIPTION file of package
    #> 'gglabelr'

To cite package ‘gglabelr’ in publications use:

John Helveston (2020). gglabelr: gglabelr. R package version 0.1.0.

A BibTeX entry for LaTeX users is

@Manual{, title = {gglabelr: gglabelr}, author = {John Helveston}, year
= {2020}, note = {R package version 0.1.0}, }
