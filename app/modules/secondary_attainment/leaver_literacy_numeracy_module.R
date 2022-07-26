leaver_lit_num_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    # Attainment literacy and numeracy chart
    column(
      h3("Percentage of school leavers' achieving Literacy and Numeracy",
         align = "center"),
      withSpinner(plotlyOutput(ns("lit_num"))),
      width = 12
    ),

    # Attainment literacy chart
    column(
      h3("Percentage of school leavers' achieving Literacy",
         align = "center"),
      withSpinner(plotlyOutput(ns("literacy"))),
      width = 6
    ),

    # Attainment numeracy chart
    column(
      h3("Percentage of school leavers' achieving Numeracy",
         align = "center"),
      withSpinner(plotlyOutput(ns("numeracy"))),
      width = 6
    )
    
  )
  
}

leaver_lit_num_server <- function(input, output, session, data) {
  
  chart <- function(data, skill) {
    
    dat <-
      data() %>%
      filter(dataset == "literacy_numeracy" & 
               str_starts(measure, 
                          paste0("percentage_achieving_",
                                 skill,
                                 "_at_"))) %>%
      mutate(
        comparator = ifelse(comparator == "0",
                            str_wrap(school_name, width = 20),
                            "Virtual Comparator"),
        measure = to_title_case(word(measure, -4, -1, sep = "_")),
        measure = str_wrap(measure, 
                           ifelse(!str_detect(skill, "_and_"), 10, 100))
      )
    
    # Display error message if no data returned
    validate(need(nrow(dat) > 0, label = "data"), errorClass = "no-data")    
    
    plot <-
      ggplot(dat, aes(x = measure,
                      y = value,
                      text = paste0("School: ", comparator, "<br>",
                                    "Value: ", value_label)
      )) +
      geom_col(aes(fill = comparator, colour = comparator),
               width = 0.8, position = "dodge2") +
      geom_text(aes(y = value + 5, label = chart_label, group = comparator),
                hjust = 0.5, position = position_dodge2(width = 0.8)) +
      scale_fill_manual(values = c("#3182bd", "#9ecae1")) +
      scale_colour_manual(values = c("#3182bd", "#9ecae1")) +
      scale_y_continuous(limits = c(0, 100)) +
      labs(x = NULL , y = "% Achieving", fill = NULL, colour = NULL)
    
    ggplotly(plot, tooltip = "text") %>%
      config(displayModeBar = F, responsive = FALSE) %>%
      layout(xaxis = list(fixedrange = TRUE),
             yaxis = list(fixedrange = TRUE))
    
  }
  
  # Leavers literacy and numeracy chart
  output$lit_num <- renderPlotly({
    chart(data, "literacy_and_numeracy")
  })

  # Leavers literacy chart
  output$literacy <- renderPlotly({
    chart(data, "literacy")
  })

  # Leavers numeracy chart
  output$numeracy <- renderPlotly({
    chart(data, "numeracy")
  })
  
  
}