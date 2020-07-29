#' Interactively make a box for a ggplot.
#'
#' When called, this function opens a window with options to interactively
#' add a box to the ggplot. When you press the "done" button, the code
#' to create the box will be printed to the console.
#'
#' @export
#' @examples
#' library(gglabelr)
#' library(ggplot2)
#'
#' # Make plot
#' p <- ggplot(mpg, aes(x = hwy, y = displ)) +
#'     geom_point()
#'
#' # Interactively make a box
#' makeBox(p)
makeBox <- function(p) {

    ui <- miniUI::miniPage(
        miniUI::gadgetTitleBar("gglabelr"),
        miniUI::miniContentPanel(
            shiny::sliderInput(
                inputId = 'opacity',
                label   = 'Box opacity (0 = lighter, 1 = darker):',
                min     = 0,
                max     = 1,
                value   = 0.25,
                step    = 0.05
            ),
            shiny::HTML("<b>Click and drag to draw the box:</b>"),
            shiny::plotOutput(
                outputId = "plot",
                brush    = shiny::brushOpts(
                    id = "plot_brush", resetOnNew = TRUE)
            )
        )
    )

    server <- function(input, output, session) {

        # Reactive clicking issue solved here:
        # https://stackoverflow.com/questions/49351533/how-to-display-plot-clicks-on-a-plot-in-shiny
        coords <- shiny::reactiveValues(xmin = NULL, xmax = NULL,
                                        ymin = NULL, ymax = NULL)

        shiny::observeEvent(input$plot_brush, {
            coords$xmin <- round(input$plot_brush$xmin, 1)
            coords$xmax <- round(input$plot_brush$xmax, 1)
            coords$ymin <- round(input$plot_brush$ymin, 1)
            coords$ymax <- round(input$plot_brush$ymax, 1)
        })

        output$plot <- shiny::renderPlot({
            if (is.null(coords$xmin)) {
                p
            } else {
                p +
                annotate(geom = "rect",
                         xmin = coords$xmin, xmax = coords$xmax,
                         ymin = coords$ymin, ymax = coords$ymax,
                         fill = "grey55", alpha = input$opacity)
            }
        })

        print_label_code <- function() {
            cat(paste0(
                'annotate(geom = "rect",\n',
                '\txmin = ', coords$xmin, ', xmax = ', coords$xmax, '\n',
                '\tymin = ', coords$ymin, ', ymax = ', coords$ymax, '\n',
                '\tfill = "grey55", alpha = ', input$opacity, ')'))
        }

        shiny::observeEvent(input$done, {
            print_label_code()
            shiny::stopApp()
        })
    }

    shiny::runGadget(
        ui, server, viewer = shiny::dialogViewer("gglabelr::makeBox()"))

}
