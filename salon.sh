#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
# show menu
echo "$SERVICES" | while read SERV_ID BAR SERV_NAME
do
  echo "$SERV_ID) $SERV_NAME"
done

read SERVICE_ID_SELECTED
SERVICE_CUST=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
if [[ -z $SERVICE_CUST ]]
then
  # Wrong input
  MAIN_MENU "I could not find that service. What would you like today?"
else
  #Right input
  #Ask phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INP_RES=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
  fi

  echo -e "\nWhat time would you like your$SERVICE_CUST, $CUSTOMER_NAME?"
  read SERVICE_TIME
  echo -e "\nI have put you down for a$SERVICE_CUST at $SERVICE_TIME, $CUSTOMER_NAME."
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INP_RES=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 
fi

}
MAIN_MENU