#' @title Recode population measures
#'
#' @param measure Character vector of measure names
#' @param category Logical; if `TRUE`, function will recode measures into
#' categories.
#' @param measure_factor Logical; only used when `category = FALSE`. If `TRUE`, 
#' return value will be a factor, if `FALSE`, a character vector.
#'
#' @return Default behaviour is to return a character vector of measures recoded
#' into 'clean' readable format; e.g. 'ptr' is recoded to 'Pupil Teacher Ratio'.
#' If `category = TRUE`, then a character vector of measure categories 
#' corresponding to each element of `measure` supplied is returned; 
#' e.g. 'simd1' is categorised at 'deprivation'. 
#' 
#' @export
#'
#' @examples
#' recode_population_measures("p1", category = TRUE)
#' recode_population_measures("gaelic")


recode_population_measures <- function(measure, category = FALSE, measure_factor = TRUE) {

  recode_category <- case_when(
    measure %in% c("roll", "fte_teacher_numbers", "ptr", "average_class") ~ 
      "trend",
    str_detect(measure, "^p[1-7]$") ~ "primary_stage",
    str_detect(measure, "^s[1-6]$") ~ "secondary_stage",
    str_detect(measure, "^sp_(13_15|16plus|9_12|to_8)$") ~ "special_stage",
    str_detect(measure, "^(fe)?male$") ~ "sex",
    str_detect(measure, "^simd([1-5]|_unknown)") ~ "deprivation",
    str_detect(measure, "fsm") ~ "free_school_meals",
    str_detect(measure, "asn") ~ "additional_support_needs",
    str_detect(measure, "eal") ~ "english_additional_language",
    str_detect(measure, "gaelic") ~ "gaelic",
    str_detect(measure, "(urban|rural|small_town)") ~ "urban_rural",
    str_detect(measure, "(white|ethnic)") ~ "ethnicity",
    TRUE ~ "unmatched"
  )
    
  recode_measure <- case_when(
    str_detect(measure, "^(p[1-7]|s[1-6])$") ~ toupper(measure),
    str_detect(measure, "^simd[1-5]$") ~ 
      paste0("SIMD Q", str_sub(measure, -1)),
    str_detect(measure, "^(asn|eal|fsm)$") ~ toupper(measure),
    str_detect(measure, "^no_(asn|eal|fsm)$") ~ 
      paste("No", toupper(word(measure, 2, sep = "_"))),
    str_detect(measure, "^(fe)?male$") ~ str_to_title(measure),
    measure == "urban_rural_missing" ~ "Urban Rural Not Known",
    str_detect(measure, "(urban|rural|small_town)") ~ 
      str_replace_all(measure, "_", " ") %>% str_to_title(),
    TRUE ~ 
      recode(measure,
             roll = "Pupil Numbers",
             average_class = "Average Class",
             fte_teacher_numbers = "Teacher Numbers (FTE)",
             ptr = "Pupil Teacher Ratio",
             sp_to_8 = "0-8",
             sp_9_12 = "9-12",
             sp_13_15 = "13-15",
             sp_16plus = "16+",
             simd_unknown = "SIMD Unknown",
             gaelic = "Taught in Gaelic",
             no_gaelic = "Not Taught in Gaelic",
             white_british = "White UK",
             white_other = "White Other",
             min_ethnic = "Ethnic Minority",
             unknown_ethnicity = "Ethnicity Not Known",
             .default = "unmatched"
      )
  )
  
  # Check that all measures have been categorised and recoded
  # If not, then the function will stop and an error message will be printed
  # If this happens, it's likely that some column names in one of the
  # school_summary_statistics data files have changed.
  if(any(recode_category == "unmatched", recode_measure == "unmatched")) {
    abort(
      c("At least one measure has not been categorised and/or recoded.",
        i = paste("This has likely been caused by unexpected column names in",
                  "the school_summary_statistics data."))
    )
  }
  
  # Convert measure to factor to control sort order
  if(measure_factor) {
    recode_measure <- factor(
      recode_measure,
      c("Pupil Numbers", "Teacher Numbers (FTE)", "Pupil Teacher Ratio",
        "Average Class", "Female", "Male", 
        paste0("P", 1:7), paste0("S", 1:6), "0-8", "9-12", "13-15", "16+",
        paste0("SIMD Q", 1:5), "SIMD Unknown", 
        "ASN", "No ASN", "FSM", "No FSM", "EAL", "No EAL", 
        "White UK", "White Other", "Ethnic Minority", "Ethnicity Not Known",
        "Taught in Gaelic", "Not Taught in Gaelic",
        "Urban", "Small Town", "Rural", "Urban Rural Not Known")
    )
  }
  
  if(category) recode_category else recode_measure
    
}


### END OF SCRIPT ###