#' Interactively make a label for a ggplot.
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
#' # Interactively annotate the plot
#' gglabelr(p)
gglabelr <- function(p) {

    ui <- miniUI::miniPage(
        miniUI::gadgetTitleBar("gglabelr"),
        miniTabstripPanel(
            miniTabPanel(
                title = "Make a label", icon = icon("tag"),
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
                        outputId = "label_plot",
                        click = "label_plot_click"
                    ),
                    shiny::HTML("<b>Code to make label:</b>"),
                    verbatimTextOutput(outputId = "label_code")
                )
            ),
            miniTabPanel(
                title = "Draw a box", icon = icon("vector-square"),
                miniUI::miniContentPanel(
                    shiny::sliderInput(
                        inputId = 'box_opacity',
                        label   = 'Box opacity (0 = lighter, 1 = darker):',
                        min     = 0,
                        max     = 1,
                        value   = 0.25,
                        step    = 0.05
                    ),
                    colourInput(
                        inputId = "box_fill", 
                        label = "Select fill color", 
                        value = "grey55", 
                        allowTransparent = TRUE),
                    shiny::HTML("<b>Click and drag to draw the box:</b>"),
                    shiny::plotOutput(
                        outputId = "box_plot",
                        brush = shiny::brushOpts(
                            id = "box_plot_brush", resetOnNew = TRUE)
                    ),
                    shiny::HTML("<b>Code to make box:</b>"),
                    verbatimTextOutput(outputId = "box_code")
                )
            )
        )
    )

    server <- function(input, output, session) {

        # Reactive clicking issue solved here:
        # https://stackoverflow.com/questions/49351533/how-to-display-plot-clicks-on-a-plot-in-shiny
        coords <- shiny::reactiveValues(
            label_x = NULL, label_y = NULL, 
            box_xmin = NULL, box_xmax = NULL, 
            box_ymin = NULL, box_ymax = NULL)

        shiny::observeEvent(input$label_plot_click, {
            coords$label_x <- round(input$label_plot_click$x, 1)
            coords$label_y <- round(input$label_plot_click$y, 1)
        })

        shiny::observeEvent(input$box_plot_brush, {
            coords$box_xmin <- round(input$box_plot_brush$xmin, 1)
            coords$box_xmax <- round(input$box_plot_brush$xmax, 1)
            coords$box_ymin <- round(input$box_plot_brush$ymin, 1)
            coords$box_ymax <- round(input$box_plot_brush$ymax, 1)
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

        output$label_plot <- shiny::renderPlot({
            if (is.null(coords$label_x)) {
                return(p)
            } else {
                d <- label_data()
                return(p +
                geom_text(aes(x = coords$label_x, 
                              y = coords$label_y,
                              label = d$text),
                          size = d$size, hjust = d$hjust))
            }
        })

        output$box_plot <- shiny::renderPlot({
            if (is.null(coords$box_xmin)) {
                return(p)
            } else {
                return(p +
                annotate(geom = "rect",
                         xmin = coords$box_xmin, xmax = coords$box_xmax,
                         ymin = coords$box_ymin, ymax = coords$box_ymax,
                         fill = input$box_fill, alpha = input$box_opacity))
            }
        })
        
        get_label_code <- function() {
            if (is.null(coords$label_x)) { return(NULL) }
            d <- label_data()
            return(paste0(
                'geom_text(aes(x = ', coords$label_x, ', ',
                "y = ", coords$label_y, ', ',
                'label = "', d$text, '"),\n\t',
                "size = ", d$size, ', ',
                "hjust = ", d$hjust, ')\n'))
        }

        get_box_code <- function() {
            if (is.null(coords$box_xmin)) { return(NULL) }
            return(paste0(
                'annotate(geom = "rect",\n',
                '\txmin = ', coords$box_xmin, ', ',
                'xmax = ', coords$box_xmax, ',\n',
                '\tymin = ', coords$box_ymin, ', ',
                'ymax = ', coords$box_ymax, ',\n',
                '\tfill = "', input$box_fill, '", ',
                'alpha = ', input$box_opacity, ')\n'))
        }
        
        output$label_code <- renderText({
            get_label_code()
        })
        
        output$box_code <- renderText({
            get_box_code()
        })
        
        shiny::observeEvent(input$done, {
            if (!is.null(coords$label_x)) { 
                cat("# Code to make label:\n\n")
                cat(get_label_code())
                cat("\n")
            }
            if (!is.null(coords$box_xmin)) {
                cat("# Code to make box:\n\n")
                cat(get_box_code())    
            }
            shiny::stopApp()
        })
    }

    shiny::runGadget(
        ui, server, viewer = shiny::dialogViewer("gglabelr"))
}
