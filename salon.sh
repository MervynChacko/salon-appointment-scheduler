#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~Mervyns Saloon~~~~~\n"
echo "Welcome! Please select from the services listed below"
MAIN_MENU() {
  # when we pass control back to the MAIN_MENU the below if condition is triggered
  if [[ $1 ]] 
    then
      echo -e "\n$1"
  fi
  # display the services provided
  MENU_OPTIONS=$($PSQL "SELECT service_id, name FROM services;")
  echo "$MENU_OPTIONS" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  # when invalid/valid service ID is selected
  if [[ -z $SERVICE_SELECTED ]]
  then
    # pass control back to main menu to list valid options
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_CUSTOMER=$($PSQL "SELECT customer_id, phone, name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    # when customer does not exist
    if [[ -z $CHECK_CUSTOMER ]]
      then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert into the customers table
      CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');") ###
      echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # get info and insert into appointments table
      CUSTOMER_ID_INS=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # inserting for new customer
      APPOINTMENT_INSERT_NEW=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID_INS,$SERVICE_ID_SELECTED,'$SERVICE_TIME')") ###
      echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
        echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID_INS=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        APPOINTMENT_INSERT_EXIST=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID_INS,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}
MAIN_MENU