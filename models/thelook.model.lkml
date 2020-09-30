connection: "thelook"

# include all the views
include: "/views/**/*.view"

# Datagroup and persistence
datagroup: thelook_default_datagroup {
  max_cache_age: "1 hour"
}

datagroup: pdt_dates {
  max_cache_age: "240 hours"
  sql_trigger: SELECT 1 ;;
  description: "Used in 1_dates_pdt view file"
}

persist_with: thelook_default_datagroup

explore: 1_dates_pdt {}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  label: "Main Explore"
  description: "Explore with all views"
  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

explore: orders {
  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: products {}

explore: users {}

explore: persons {
  from: users
}
