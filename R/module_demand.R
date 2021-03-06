#' Demand Module
#'
#' A shiny module that renders all of the content for the demand page.
#'
#' @name demand_module
#'
#' @param id An ID string that uniquely identifies an instance of this module
#' @param params reactive object passed in from the main server
#' @param upload_event a reactiveValues that is updated when a file is uploaded

#' @rdname demand_module
#' @import shiny
#' @import shinydashboard
#' @import shinycssloaders
demand_ui <- function(id) {
  # a drop down for the service
  # a line per month with the following:
  # - underlying demand numeric input
  # - suppressed demand numeric input

  tagList(
    fluidRow(
      primary_box(
        title = "Demand",
        width = 12,
        tags$p(
          "If you want to plot the surge model outputs alongside your own projections for underlying demand and",
          "catch-up of suppressed referrals then please enter the data by month here. Alternatively, this can be",
          "uploaded in the 'demand' tab of the whole model parameter file."
        ),
        selectInput(NS(id, "service"), "Service", NULL),
        uiOutput(NS(id, "container"))
      )
    )
  )
}

#' @rdname demand_module
#' @import shiny
#' @import shinydashboard
#' @importFrom dplyr %>% mutate
#' @importFrom purrr walk pmap
demand_server <-  function(id, params, upload_event) {
  moduleServer(id, function(input, output, session) {
    services <- reactive_changes(names(params$demand))

    observe({
      # event fired from params module when a file is uploaded
      force(req(upload_event$counter))

      if (upload_event$success) {
        updateSelectInput(session, "service", choices = services())
      }
    }, priority = -1)

    demand_observables <- list()

    output$container <- renderUI({
      # update the demand-data div
      service <- req(input$service)
      demand <- params$demand[[service]]

      # ensures we have rows of data
      req(demand)

      walk(demand_observables, ~.x$destroy())
      demand_observables <<- list()

      table_rows <- demand %>%
        mutate(month_ix = row_number()) %>%
        pmap(function(month, underlying, suppressed, month_ix) {
          month_fmt <- format(month, "%b-%y")

          m_text <- div(month_fmt)

          u_name <- paste0(month_fmt, "-underlying")
          u_input <- numericInput(NS(id, u_name), NULL, underlying, min = 0, step = 1)

          s_name <- paste0(month_fmt, "-suppressed")
          s_input <- numericInput(NS(id, s_name), NULL, suppressed, min = 0, step = 1)

          demand_observables[[u_name]] <<- observeEvent(input[[u_name]], {
            params$demand[[input$service]]$underlying[[month_ix]] <- input[[u_name]]
          })

          demand_observables[[s_name]] <<- observeEvent(input[[s_name]], {
            params$demand[[input$service]]$suppressed[[month_ix]] <- input[[s_name]]
          })

          tags$tr(
            tags$td(m_text, style = "padding: 0px 5px 0px 0px;"),
            tags$td(u_input, style = "padding: 0px 2px 0px 2px;"),
            tags$td(s_input, style = "padding: 0px 0px 1px 2px;")
          )
        })

      table_header <- tags$tr(
        tags$th("Month"),
        tags$th("Underlying"),
        tags$th("Suppressed")
      )

      tags$table(tagList(table_header, table_rows))
    })
  })
}
