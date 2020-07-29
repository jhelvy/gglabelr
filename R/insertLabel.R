#' Interactively insert a label to a ggplot.
#'
#' When called, this function opens a window with options to interactively
#' add a label to the ggplot. When you press the "done" button, the code
#' to create the label will be printed to the console.
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
#' # Interactively insert a label
#' insertLabel(p)
insertLabel <- function(p) {

    ui <- miniUI::miniPage(
        miniUI::gadgetTitleBar("gglabelr"),
        miniUI::miniContentPanel(
            shiny::textInput(
                inputId = "label_text",
                label = "Label text:",
                value = "Hello World!"),
            shiny::numericInput(
                inputId = "label_size",
                label = "Label size:",
                value = 6),
            shiny::radioButtons(
                inputId = "label_hjust",
                label = "Label justification:",
                choices = c("Left", "Center", "Right"),
                inline = TRUE,
                selected = "Left"),
            shiny::HTML("<b>Click where you want the label:</b>"),
            shiny::plotOutput(
                outputId = "plot",
                click = "plot_click"
            )
        )
    )

    server <- function(input, output, session) {

        # Reactive clicking issue solved here:
        # https://stackoverflow.com/questions/49351533/how-to-display-plot-clicks-on-a-plot-in-shiny
        coords <- shiny::reactiveValues(x = NULL, y = NULL)

        shiny::observeEvent(input$plot_click, {
            coords$x <- round(input$plot_click$x, 1)
            coords$y <- round(input$plot_click$y, 1)
        })

        label_data <- shiny::reactive({
            return(list(
                text   = input$label_text,
                size   = input$label_size,
                hjust  = get_label_hjust(input$label_hjust)))
        })

        get_label_hjust <- function(e) {
            if (e == "Left")   { return(0) }
            if (e == "Center") { return(0.5) }
            if (e == "Right")  { return(1) }
            return(0)
        }

        print_label_code <- shiny::reactive({
            d <- label_data()
            cat(paste0(
                "geom_text(aes(x = ", coords$x, ", y = ", coords$y,
                ", label = ", '"', d$text, '"),\n',
                "\tsize = ", d$size,
                ", hjust = ", d$hjust, ')\n'))
        })

        output$plot <- shiny::renderPlot({
            d <- label_data()
            if (is.null(coords$x)) {
                p
            } else {
                p +
                geom_text(aes(x = coords$x, y = coords$y,
                              label = d$text),
                          size = d$size, hjust = d$hjust)
            }
        })

        shiny::observeEvent(input$done, {
            print_label_code()
            shiny::stopApp()
        })
    }

    shiny::runGadget(ui, server, viewer = dialogViewer("gglabelr"))

}
