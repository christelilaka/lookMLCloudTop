view: orders {
  sql_table_name: demo_db.orders ;;
  drill_fields: [id]

  #---------------------------------- Period Over Period Analysis ---------------------------------
  parameter: choose_breakdown {
    view_label: "_POP_v2"
    label: "Choose Field (Rows)"
    type: unquoted
    default_value: "Month"
    allowed_value: {label: "Month Name" value: "Month"}
    allowed_value: {label: "Day of Year" value: "DOY"}
    allowed_value: {label: "Day of Week" value: "DOW"}
    allowed_value: {label: "Day of Month" value: "DOM"}
    allowed_value: {value: "Date"}
  }

  parameter: choose_comparison {
    view_label: "_POP_v2"
    label: "Choose Comparison (Pivot)"
    type: unquoted
    default_value: "Year"
    allowed_value: {value: "Year"}
    allowed_value: {value: "Month"}
    allowed_value: {value: "Week"}
  }

  dimension: pop_pivot {
    view_label: "_POP_v2"
    description: "Use this dimension in PIVOT"
    group_label: "Period over Period 2.0"
    label_from_parameter: choose_comparison
    type:  string
    order_by_field: sort_hack2
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month_name}
    {% elsif choose_comparison._parameter_value == 'Week' %} ${created_week}
    {% else %} NULL {% endif %};;
  }

  dimension: pop_row {
    view_label: "_POP_v2"
    description: "Use this dimension in ROW"
    group_label: "Period over Period 2.0"
    label_from_parameter: choose_breakdown
    type: string
    order_by_field: sort_hack1 # Help sorting correctly
    sql:
    {% if choose_breakdown._parameter_value == 'Month' %} ${created_month_name}
    {% elsif choose_breakdown._parameter_value == 'DOY' %} ${created_day_of_year}
    {% elsif choose_breakdown._parameter_value == 'DOM' %} ${created_day_of_month}
    {% elsif choose_breakdown._parameter_value == 'DOW' %} ${created_day_of_week}
    {% elsif choose_breakdown._parameter_value == 'Date' %} ${created_date}
    {% else %} NULL {% endif %};;
  }

  # Make sure that the dimensions sort correctly
  dimension: sort_hack1 {
    hidden: yes
    type: number
    sql:
    {% if choose_breakdown._parameter_value == 'Month' %} ${created_month_num}
    {% elsif choose_breakdown._parameter_value == 'DOY' %} ${created_day_of_year}
    {% elsif choose_breakdown._parameter_value == 'DOM' %} ${created_day_of_month}
    {% elsif choose_breakdown._parameter_value == 'DOW' %} ${created_day_of_week_index}
    {% elsif choose_breakdown._parameter_value == 'Date' %} ${created_date}
    {% else %} NULL {% endif %};;
  }

  dimension: sort_hack2 {
    hidden: yes
    type: string
    sql:
    {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
    {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month_num}
    {% elsif choose_comparison._parameter_value == 'Week' %} ${created_week}
    {% else %} NULL {% endif %};;
  }


  #---------------------------------------- DIMENSIONS ---------------------------------------

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week,
      day_of_month,
      day_of_year,
      day_of_week_index,
      week,
      month,
      month_name,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

#--------------------------------- MEASURES -----------------------------------------------
  measure: count {
    type: count
    drill_fields: [id, users.last_name, users.id, users.first_name, order_items.count]
  }




}
