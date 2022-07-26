leaver_awards_ui <- function(id) {
  
  ns <- NS(id)
  
  column(
    
    h3("Percentage of school leavers gaining SCQF credited awards"),
    withSpinner(dataTableOutput(ns("table"))),
    
    br(),
    
    h3("Percentage of school leavers gaining SCQF ",
       "credited awards (virtual comparator)"),
    withSpinner(dataTableOutput(ns("vc_table"))),
    
    width = 12
  )
  
}

leaver_awards_server <- function(input, output, session, data) {
  
  table <- function(data, vc) {
    
    renderDataTable({
      
      data() %>%
        filter(dataset == "breadth_depth" & comparator == vc) %>%
        select(minimum_scqf_level, minimum_number_of_awards, value_label) %>%
        mutate(
          minimum_number_of_awards = 
            paste(minimum_number_of_awards, "or more awards"),
          minimum_scqf_level = 
            paste("SCQF level", minimum_scqf_level, "or better")
        ) %>%
        rename(`Minimum number of awards` = minimum_number_of_awards) %>%
        pivot_wider(names_from = "minimum_scqf_level", 
                    values_from = "value_label")
      
    },
    
    rownames = FALSE,
    options = list(
      dom = 't',
      columnDefs = list(
        list(targets = '_all', className = 'dt-center', orderable = FALSE)
      )
    )
    
    )
    
  }
  
  output$table <- table(data, 0)

  output$vc_table <- table(data, 1)
  
}