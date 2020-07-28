library(shiny)
library(miniUI)
library(ggplot2)

makeLabel <- function(p) {

    ui <- miniPage(
        gadgetTitleBar("gglabelr"),
        miniContentPanel(
            textInput(
                inputId = "label_text",
                label = "Label text:",
                value = "Hello World!"),
            numericInput(
                inputId = "label_size",
                label = "Label size:",
                value = 6),
            radioButtons(
                inputId = "label_hjust",
                label = "Label justification:",
                choices = c("Left", "Center", "Right"),
                inline = TRUE,
                selected = "Left"),
            HTML("<b>Click where you want the label:</b>"),
            plotOutput(
                outputId = "plot",
                click = "plot_click"
            )
        )
    )

    server <- function(input, output, session) {
        
        # Reactive clicking issue solved here: 
        # https://stackoverflow.com/questions/49351533/how-to-display-plot-clicks-on-a-plot-in-shiny
        coords <- reactiveValues(x = NULL, y = NULL)

        observeEvent(input$plot_click, {
            coords$x <- round(input$plot_click$x, 1)
            coords$y <- round(input$plot_click$y, 1)
        })
        
        label_data <- reactive({
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

        print_label_code <- reactive({
            d <- label_data()
            cat(paste0(
                "geom_text(aes(x = ", coords$x, ", y = ", coords$y,
                ", label = ", '"', d$text, '"),\n',
                "\tsize = ", d$size,
                ", hjust = ", d$hjust, ')\n'))
        })

        output$plot <- renderPlot({
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

        observeEvent(input$done, {
            print_label_code()
            stopApp()
        })
    }

    runGadget(ui, server, viewer = dialogViewer("gglabelr"))

}
