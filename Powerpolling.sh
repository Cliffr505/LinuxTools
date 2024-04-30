#!/bin/bash                                                                     
                                                                                
### CSV Creation, Interval of recording, and Number of 'INTERVALS' by the total recordings wanted.
OUTPUT_FILE="pdu_power_usage.csv"                                               
INTERVAL=30                                                                     
DURATION=$((10 * INTERVAL))                                                     
                                                                                
### Function to extract power data from the PDU. Adjust the SNMP String and IP Address if needed
get_a_power() {                                                                 
   snmpwalk -v 2c -c 'string' ***.***.***.*** SNMPv2-SMI::enterprises.21239.5.2.3.1.1.9.1 | awk -F'=' '{print $2}' | awk -F: '{print $2}'
}                                                                               
                                                                                
get_b_power() {                                                                 
   snmpwalk -v 2c -c 'string' ***.***.***.*** SNMPv2-SMI::enterprises.21239.5.2.3.1.1.9.1 | awk -F'=' '{print $2}' | awk -F: '{print $2}'
}                                                                               
                                                                                
### Initialize CSV file with headers. Change Headers to appropriate rack                                        
echo "Index, Time, 'PDU'-A, 'PDU'-B, 'RACK' Total" > "$OUTPUT_FILE"                 
                                                                                
### Record power usage every 30 seconds. Change 'i<' to match the 'DURATION'                                     
for ((i=0; i<10; i++))                                                          
do                                                                              
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")                                        
  POWER_A=$(get_a_power)                                                        
  POWER_B=$(get_b_power)                                                        
  POWER_SUM=$(( POWER_A + POWER_B ))                                            
                                                                                
### Write data to CSV file                                                      
  echo "$i, $TIMESTAMP, $POWER_A, $POWER_B, $POWER_SUM" >> "$OUTPUT_FILE"       
### Wait for the next interval                                                  
  sleep "$INTERVAL"                                                             
done                                                                            
                                                                                
killall Powerpolling.sh
