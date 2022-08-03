
pupil_profile_ui <- function(id) {
  
  # Initiate namespace for module
  ns <- NS(id)
  
  fluidRow(
    
    section_header_output(ns("pupil_header")),
    
    box(
      
      title = NULL,
      width = 12,
      collapsible = FALSE,
      
      column(plotlyOutput(ns("chart1")), width = 12),
      column(plotlyOutput(ns("chart2")), width = 12)
      
    )
    
  )
  
}

pupil_profile_server <- function(input, output, session, data) {
  
  callModule(section_header_server, "pupil_header", "Pupil", box_colour = "navy")
  
  output$chart1 <- renderPlotly({
    
    ggplotly(
      data() %>%
        filter(measure_category %in% 
                 c("sex", "primary_stage", "deprivation")) %>%
        ggplot(aes(measure, value, group = 1)) + 
        geom_col() +
        theme(axis.text.x = ggplot2::element_text(angle = 40, hjust = 1)) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
        labs(x = NULL , y = NULL)
    )
    
  })
  
  output$chart2 <- renderPlotly({
    
    ggplotly(
      data() %>%
        filter(measure_category %in% 
                 c("free_school_meals", "additional_support_needs",
                   "english_additional_language", "ethnicity", 
                   "urban_rural")) %>%
        ggplot(aes(measure, value, group = 1)) + 
        geom_col() +
        theme(axis.text.x = ggplot2::element_text(angle = 40, hjust = 1)) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
        labs(x = NULL , y = NULL)
    )
    
  })
  
}