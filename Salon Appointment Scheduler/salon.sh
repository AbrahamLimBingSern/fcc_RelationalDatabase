#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n"
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  AVAILABLE_SERVICE=$($PSQL "SELECT service_id FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICE ]]
  then
    echo "There is no Service available"
  else
    echo "Here are the rest of Service available:"
    echo $AVAILABLE_SERVICE | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      AVAILABLE_SERV=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED' ORDER BY service_id")
      AVAILABLE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
      if [[ -z $AVAILABLE_SERV ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo "I don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUS_DETAIL=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        echo "What time would you like your$AVAILABLE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          SERV_DETAIL=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
          if [[ $SERV_DETAIL ]]
          then
            echo -e "\nI have put you down for a$AVAILABLE_NAME at $SERVICE_TIME, $CUSTOMER_NAME". | sed -r 's/^ *| *$//g'
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU
