include: "/views/orders.view.lkml"
explore: pop_parameters {}

view: pop_parameters {
  extends: [orders]

## ------------------------ USER FILTERS ----------------------------- ##

# This is required for choosing the date range of interest

  filter: current_date_range{
    type: date
    view_label: "_POP v_2"
    label: "1. Date Range"
    description: "Select the date range you are interested in using, this filter can be used itself. Make sure any other filter on Event DATE covers this period, or is removed."
    sql: ${period} IS NULL ;;
  }

  parameter: compare_to {
    view_label: "_POP v_2"
    description: "Choose the period you would like to compare to. Must be used with Current Date Range filter"
    label: "2. Compare To:"
    type: unquoted
    allowed_value: {label: "Previous Period" value: "Period"}
    allowed_value: {label: "Previous Week" value: "Week"}
    allowed_value: {label: "Previous Month" value: "Month"}
    allowed_value: {label: "Previous Quarter" value: "Quarter"}
    allowed_value: {label: "Previous Year" value: "Year"}
    default_value: "Period"
  }

  #------------- HIDDEN HELPER DIMENSIONS -----------------------
  dimension: days_in_period {
    hidden: yes
    view_label: "_POP v_2"
    description: "Gives the number of days in the current period date range"
    type: number
    sql: DATEDIFF(DAY, DATE({% date_start current_date_range %}), DATE({% date_end current_date_range %}) ;;
  }

  dimension: period_2_start {
    hidden: yes
    view_label: "_POP v_2"
    description: "Calculates the start of the previous period"
    type: date
    sql:
        {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -${days_in_period}, DATE({% date_start current_date_range %})
        {% else %}
            DATEADD({% parameter compare_to %}, -1, DATE({% date_start current_date_range %}))
        {% endif %};;

  }

  dimension: period_2_end {
    hidden: yes
    view_label: "_POP v_2"
    description: "Calculates the end of the previous period"
    type: date
    sql:
        {% if compare_to._parameter_value == "Period" %}
          DATEADD(DAY, -1, DATE({% date_start current_date_range %})
        {% else %}
          DATEADD({% parameter compare_to %}, -1, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
        {% endif %};;
  }

  dimension: day_in_period {
    hidden: yes
    description: "Gives the number of days since the start of each periods. Use this to align the event dates onto the same axis, the axes will read 1, 2, 3, etc."
    type:  number
    sql:
        {% if current_date_range._is_filtered %}
          CASE
              WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
                  THEN DATEDIFF(DAY, DATE({% date_start current_date_range %}), ${created_date}) + 1
              WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                  THEN DATEDIFF(DAY, ${period_2_start}, ${created_date}) + 1
          END
        {% else %} NULL
        {% endif %};;
  }

  dimension: order_for_period {
    hidden: yes
    type: number
    sql:
        {% if current_date_range._is_filtered %}
          CASE
              WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
                  THEN 1
              WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                  THEN 2
          END
        {% else %} NULL {% endif %};;
  }


  ## --------------------------------------- DIMENSION TO PLOT ------------------------------- ##
  dimension: period {
    view_label: "_POP v_2"
    label: "Period"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period' or 'Previous Period'"
    type: string
    order_by_field: order_for_period
    sql:
        {% if current_date_range._is_filtered %}
            CASE
                WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
                    THEN 'This {% parameter compare_to %}'
                WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                    THEN 'Last {% parameter compare_to %}'
            END
        {% else %} NULL {% endif %};;
  }

  dimension: period_filtered_measures {
    hidden: yes
    description: "We just use this for the filtered measures"
    type: string
    sql:
        {% if current_date_range._is_filtered %}
            CASE
                WHEN {% condition current_date_range %} ${created_raw} {% endcondition %} THEN 'this'
                WHEN ${created_date} between ${period_2_start} and ${period_2_end} THEN 'last' END
        {% else %} NULL {% endif %};;
  }

  dimension_group: date_in_period {
    description: "Use this as your date dimension when comparing periods. Aligns the previous periods onto the current period"
    label: "Current Period"
    type: time
    sql: DATEADD(DAY, ${day_in_period} - 1, DATE({% date_start current_date_range %})) ;;
    view_label: "_POP v_2"
    timeframes: [date, week, month, quarter, year]
  }







}
