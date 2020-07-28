library(shiny)
library(ggplot2)
library(shinythemes)
library(rclipboard)

# -----------------------------------------------------------------------------
# Define plot here as object p

p <- ggplot(mpg, aes(x = hwy, y = displ)) +
    geom_point()

# -----------------------------------------------------------------------------

ui <- navbarPage(title = "gglabelr",
    theme = shinytheme("united"),
    tabPanel("Create label",
        icon = icon(name = "tag", lib = "font-awesome"),
        rclipboardSetup(),
        sidebarLayout(
            sidebarPanel(
                h2("Define label"),
                textInput(
                    inputId = "labelText",
                    label = "Label text:",
                    value = "Hello World!"),
                numericInput(
                    inputId = "labelSize",
                    label = "Label size:",
                    value = 6),
                radioButtons(
                    inputId = "labelJust",
                    label = "Label justification:",
                    choices = c("Left", "Center", "Right"),
                    inline = TRUE,
                    selected = "Left"),
                HTML("<b>Click where you want the label:</b>"),
                plotOutput(
                    outputId = "plotIn",
                    click = "plot_click"
                )
            ),
            mainPanel(
                width = 5,
                h2("Plot preview"),
                plotOutput(
                    outputId = "plotOut"
                ),
                h2("Code to add label:"),
                uiOutput("clip"),
                br(),
                verbatimTextOutput(outputId = "coords")
            )
        )
    ),
    tabPanel("About",
        icon = icon(name = "question-circle", lib = "font-awesome"),
        mainPanel(width = 6,
            includeMarkdown("README.md"),br()
        )
    )
)

server <- function(input, output) {
    get_coords <- function(e) {
        if (is.null(e)) {
            return(list(x = 0, y = 0))
        }
        return(list(x = round(e$x, 1), y = round(e$y, 1)))
    }
    get_just <- function(e) {
        if (e == "Left") { return(0) }
        if (e == "Center") { return(0.5) }
        if (e == "Right") { return(1) }
        return(0)
    }
    get_code <- function(e) {
        if (is.null(e)) { return("NULL\n") }
        coords = get_coords(input$plot_click)
        return(paste0(
            "geom_text(aes(x = ", coords$x, ", y = ", coords$y,
            ", label = ", '"', input$labelText, '"),\n',
            "\tsize = ", input$labelSize,
            ", hjust = ", get_just(input$labelJust), ')\n'))
    }

    output$plotIn <- renderPlot({
        p
    })

    output$plotOut <- renderPlot({
        coords = get_coords(input$plot_click)
        just = get_just(input$labelJust)
        p +
            geom_text(aes(x = coords$x,
                          y = coords$y,
                          label = input$labelText),
                      size = input$labelSize,
                      hjust = just)
    })

    output$coords <- renderText({
        get_code(input$plot_click)
    })

    # Add clipboard buttons
    output$clip <- renderUI({
        rclipButton("clipbtn", "Copy to clipboard", get_code(input$plot_click),
                    icon("clipboard"))
    })
}

shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
