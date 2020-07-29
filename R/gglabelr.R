#' Interactively make a label for a ggplot.
#'
#' When called, this function opens a window with options to interactively
#' annotate a ggplot. You can add a label and / or add a bounding box. You can
#' also view and copy the code to generate the annotations. When you press
#' the "done" button, the code to generate the annotations will be printed
#' to the console.
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
        miniUI::miniTabstripPanel(
            miniUI::miniTabPanel(
                title = "Add a label", icon = shiny::icon("tag"),
                miniUI::miniContentPanel(
                    shiny::actionButton(
                        inputId = "label_reset",
                        label   = "Remove label"),
                    shiny::br(),shiny::br(),
                    shiny::HTML("<b>Click where you want the label:</b>"),
                    shiny::plotOutput(
                        outputId = "label_plot",
                        click    = "label_plot_click"
                    ),
                    shiny::textInput(
                        inputId = "label_text",
                        label   = "Label text:",
                        value   = "Hello World!"),
                    shiny::fillRow(
                        shiny::radioButtons(
                            inputId  = "label_hjust",
                            label    = "Label justification:",
                            choices  = c("Left", "Center", "Right"),
                            inline   = TRUE,
                            selected = "Left"),
                        shiny::numericInput(
                            inputId = "label_size",
                            label   = "Label size:",
                            step    = 0.5,
                            value   = 6)
                    )
                )
            ),
            miniUI::miniTabPanel(
                title = "Draw a box", icon = shiny::icon("vector-square"),
                miniUI::miniContentPanel(
                    shiny::actionButton(
                        inputId = "box_reset",
                        label   = "Remove box"),
                    shiny::br(),shiny::br(),
                    shiny::HTML("<b>Click and drag to draw the box:</b>"),
                    shiny::plotOutput(
                        outputId = "box_plot",
                        brush = shiny::brushOpts(
                            id = "box_plot_brush", resetOnNew = TRUE)
                    ),
                    shiny::fillRow(
                        colourpicker::colourInput(
                            inputId = "box_fill",
                            label   = "Select fill color",
                            value   = "#8C8C8C",
                            allowTransparent = TRUE),
                        shiny::sliderInput(
                            inputId = 'box_opacity',
                            label   = 'Box opacity (0 = lighter, 1 = darker):',
                            min     = 0,
                            max     = 1,
                            value   = 0.25,
                            step    = 0.05
                        )
                    )
                )
            ),
            miniUI::miniTabPanel(
                title = "Get the code", icon = shiny::icon("code"),
                miniUI::miniContentPanel(
                    shiny::actionButton(
                        inputId = "copy_code",
                        label = "Copy code to clipboard"),
                    shiny::br(),shiny::br(),
                    shiny::verbatimTextOutput(outputId = "code")
                )
            )
        )
    )

    server <- function(input, output, session) {

        # Code for getting the coordinate values for annotations --------------

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

        shiny::observeEvent(input$label_reset, {
            coords$label_x <- NULL
            coords$label_y <- NULL
        })

        shiny::observeEvent(input$box_reset, {
            coords$box_xmin <- NULL
            coords$box_xmax <- NULL
            coords$box_ymin <- NULL
            coords$box_ymax <- NULL
        })

        # Code for making the plots to show -----------------------------------

        get_label_hjust <- function(e) {
            if (e == "Left")   { return(0) }
            if (e == "Center") { return(0.5) }
            if (e == "Right")  { return(1) }
            return(0)
        }

        get_label_data <- shiny::reactive({
            return(list(
                label  = input$label_text,
                size   = input$label_size,
                hjust  = get_label_hjust(input$label_hjust)))
        })

        label_missing <- function() {
            if (is.null(coords$label_x)) { return(TRUE) }
            return(FALSE)
        }

        box_missing <- function() {
            if (is.null(coords$box_xmin)) { return(TRUE) }
                return(FALSE)
        }

        makePlot <- function() {
            label_missing <- label_missing()
            box_missing <- box_missing()
            if (label_missing & box_missing) {
                return(p)
            } else if (box_missing) {
                return(p + makeLabel())
            } else if (label_missing) {
                return(p + makeBoxmakeBox())
            }
            return(p + makeLabel() + makeBox())
        }

        makeLabel <- function() {
            d <- get_label_data()
            return(annotate(geom = "text",
                x = coords$label_x, y = coords$label_y, label = d$label,
                size = d$size, hjust = d$hjust))
        }

        makeBox <- function() {
            return(annotate(geom = "rect",
                xmin = coords$box_xmin, xmax = coords$box_xmax,
                ymin = coords$box_ymin, ymax = coords$box_ymax,
                fill = input$box_fill, alpha = input$box_opacity))
        }

        output$label_plot <- shiny::renderPlot({
            makePlot()
        })

        output$box_plot <- shiny::renderPlot({
            makePlot()
        })

        # Code for making the code to copy ------------------------------------

        get_label_code <- function() {
            if (is.null(coords$label_x)) { return(NULL) }
            d <- get_label_data()
            return(paste0(
                'annotate(geom = "text",\n\t',
                'x = ', coords$label_x, ', ',
                'y = ', coords$label_y, ', ',
                'label = "', d$label, '",\n\t',
                'size = ', d$size, ', ',
                'hjust = ', d$hjust, ')\n'))
        }

        get_box_code <- function() {
            if (is.null(coords$box_xmin)) { return(NULL) }
            return(paste0(
                'annotate(geom = "rect",\n\t',
                'xmin = ', coords$box_xmin, ', ',
                'xmax = ', coords$box_xmax, ',\n\t',
                'ymin = ', coords$box_ymin, ', ',
                'ymax = ', coords$box_ymax, ',\n\t',
                'fill = "', input$box_fill, '", ',
                'alpha = ', input$box_opacity, ')\n'))
        }

        get_all_code <- function() {
            code <- NULL
            if (!is.null(coords$label_x)) {
                code <- paste0(
                    code,
                    "# Code to make the label:\n",
                    get_label_code(),
                    "\n")
            }
            if (!is.null(coords$box_xmin)) {
                code <- paste0(
                    code,
                    "# Code to make the box:\n",
                    get_box_code(),
                    "\n")
            }
            return(code)
        }

        shiny::observeEvent(input$copy_code, {
            clipr::write_clip(get_all_code())
        })

        output$code <- shiny::renderText({
            return(get_all_code())
        })

        shiny::observeEvent(input$done, {
            cat(get_all_code())
            shiny::stopApp()
        })
    }

    shiny::runGadget(
        ui, server, viewer = shiny::dialogViewer("gglabelr"))
}
