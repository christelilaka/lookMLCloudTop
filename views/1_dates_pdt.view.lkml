view: 1_dates_pdt {
  derived_table: {
    datagroup_trigger: pdt_dates
    indexes: ["id"]
    sql: SELECT 1 AS id,'Horace' AS first_name,'Jaggard' AS last_name,'24-09-2020' AS order_at,'27-09-2020' AS return_at
            UNION ALL SELECT 2,'Flint','Hans','24-09-2020','23-09-2020'
            UNION ALL SELECT 3,'Rosita','Slator','27-09-2020','23-09-2020'
            UNION ALL SELECT 4,'Hughie','Jacquemard','26-09-2020','23-09-2020'
            UNION ALL SELECT 5,'Sheff','Giacometti','28-09-2020','29-09-2020'
            UNION ALL SELECT 6,'Helen','McGuane','25-09-2020','25-09-2020'
            UNION ALL SELECT 7,'Coletta','Dyball','28-09-2020','28-09-2020'
            UNION ALL SELECT 8,'Raychel','Yurocjkin','28-09-2020','25-09-2020'
            UNION ALL SELECT 9,'Aloise','Dickens','23-09-2020','28-09-2020'
            UNION ALL SELECT 10,'Morris','Bulfit','22-09-2020','25-09-2020'
            UNION ALL SELECT 11,'Court','Taber','24-09-2020','24-09-2020'
            UNION ALL SELECT 12,'Letta','Jecks','25-09-2020','25-09-2020'
            UNION ALL SELECT 13,'Tedie','Deetlefs','25-09-2020','26-09-2020'
            UNION ALL SELECT 14,'Berky','Hatrick','27-09-2020','28-09-2020'
            UNION ALL SELECT 15,'Gerrie','Maylard','23-09-2020','25-09-2020';;
  }

  dimension: id {
    primary_key: yes
    type: number
  }

  dimension: first_name {
    label: "First Name"
    type: string
  }

  dimension: last_name {
    type: string
  }

  dimension_group: order_at {
    type: time
    timeframes: [raw, date, day_of_month, month, month_name, month_num, week, year]
    sql: STR_TO_DATE(${TABLE}.order_at, '%d-%m-%Y') ;;
  }

  dimension_group: return_at {
    type: time
    timeframes: [raw, date, day_of_month, month, month_name, month_num, week, year]
    sql: STR_TO_DATE(${TABLE}.return_at, '%d-%m-%Y') ;;
  }

  dimension: is_order_greater {
    type: yesno
    sql: ${order_at_date} > ${return_at_date} ;;
  }

  dimension: max_date {
    type: date
    sql:
        CASE
            WHEN ${order_at_date} > ${return_at_date} THEN ${order_at_date}
            ELSE ${return_at_date} END;;
  }

 }
