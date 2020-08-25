view: order_items {
  sql_table_name: demo_db.order_items ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }


  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date, hour_of_day, hour2, time_of_day,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: date_string {
    type:  string
    sql: ${TABLE}.returned_at ;;
  }

  dimension: test_string {
    type:  string
    sql: "'Hello"
    "This is a new line'" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

#------------------------------------------ MEASURES ---------------------------------------------
  measure: count {
    type: count
    drill_fields: [id, orders.id, inventory_items.id]
  }

  measure: count_test {
    type: number
    sql: (${count} * 0) + 500 ;;
  }

  measure: total_sale_price {
    label: "Total Sales"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    html:
    <div style="background-color: #FFECEA">
    {% if value < 3000 %}</div>
    <font color = "darkred">{{value}}</font>
    {% else %}
    <font color = "#33b05c">{{value}}</font>
    {% endif %}
    ;;
  }




}
