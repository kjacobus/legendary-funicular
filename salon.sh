#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Welcome to the Salon ~~~~~\n"

#$PSQL "TRUNCATE appointments, customers"

MAIN_MENU() {
 if [[ $1 ]]
 then
  echo -e "\n$1\n"
 fi

 
 AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services order by service_id;")
 if [[ -z $AVAILABLE_SERVICES ]]
 then
  echo "Sorry, no services available today."
  EXIT
 else

 echo -e "\nHere are the available services:"
 echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
 do 
 echo "$SERVICE_ID) $SERVICE_NAME"
 done
 echo -e "\nPlease select the service ID you would like."
 read SERVICE_ID_SELECTED
 if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
 then
  MAIN_MENU "That is not a valid service nubmer."
 else
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services where service_id='$SERVICE_ID_SELECTED';")
  if [[ -z SERVICE_NAME_SELECTED ]]
  then 
   MAIN_MENU "Sorry, this serice is not available. Select again:"
  else

  echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
     #get new customer name
     echo -e "\nWhat's your name?"
     read CUSTOMER_NAME
     #insert new customer
     INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
    fi
    
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    echo -e "\nWhat time do you want?"
    read SERVICE_TIME

    ADD_APOINTMENT_RESULT=$($PSQL "INSERT into appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME');")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
    EXIT
  fi

 fi
 fi

}


EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU