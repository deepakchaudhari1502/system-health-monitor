#! /bin/bash


TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="health_report_$TIMESTAMP.txt"


send_email()
{
    {
        echo "To: chaudharideepak9324@gmail.com"
        echo "Subject: System Health Report - $(hostname) - $OVERALL_STATUS"
        echo ""
        cat "$REPORT_FILE"
    } | msmtp -t
}



echo "============================================" >> "$REPORT_FILE"
echo "      System Health Monitor" >> "$REPORT_FILE"
echo "============================================" >> "$REPORT_FILE"

echo "Hostname: $(hostname)" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "uptime: $(uptime -p)" >> "$REPORT_FILE"

echo "============================================" >> "$REPORT_FILE"



echo ""
echo "CPU INFORMATION"
echo "-------------------------------------------"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 -$8}')
echo "CPU Usage: $CPU_USAGE%"

	
if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
    CPU_STATUS="Critical"
elif (( $(echo "$CPU_USAGE >= 80" | bc -l) )); then
    CPU_STATUS="Warning"
else
    CPU_STATUS="Healthy"
fi

echo "CPU Status: $CPU_STATUS"
echo "CPU Status: $CPU_STATUS" >> "$REPORT_FILE"

#echo "CPU usage%: $CPU_USAGE" >> "$REPORT_FILE"




echo ""
echo "MEMORY INFORMATION"
echo "-------------------------------------------"

MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 *100}')

echo "Memory Usage: $MEMORY_USAGE%"


if (( $(echo "$MEMORY_USAGE > 90" | bc -l) ));then
	MEMORY_STATUS="Critical"
elif (( $(echo "$MEMORY_USAGE >= 80" | bc -l) ));then
	MEMORY_STATUS="Warning"
else
	MEMORY_STATUS="Healthy"
fi

echo "Memory Status: $MEMORY_STATUS"
echo "Memory Status: $MEMORY_STATUS" >> "$REPORT_FILE"





echo ""
echo "DISK INFORMATION"
echo "-------------------------------------------"

DISK_USAGE=$(df -h | awk 'NR==3 {print $5}' | tr -d '%')

echo "Disk Usage: $DISK_USAGE%"


if [ "$DISK_USAGE" -gt 90 ]; then
    DISK_STATUS="Critical"
elif [ "$DISK_USAGE" -ge 80 ]; then
    DISK_STATUS="Warning"
else
    DISK_STATUS="Healthy"
fi

echo "Disk Status: $DISK_STATUS"
echo "Disk Status: $DISK_STATUS" >> "$REPORT_FILE"




echo ""
echo "SERVICE INFORMATION"
echo "-------------------------------------------"

SERVICES=("ssh" "cron")

for SERVICE in "${SERVICES[@]}"
do
	if systemctl is-active --quiet "$SERVICE"; then
            echo "$SERVICE: RUNNING"
	    echo "$SERVICE: RUNNING" >> "$REPORT_FILE"
        else
            echo "$SERVICE: NOT RUNNING"
	    echo "$SERVICE: NOT RUNNING" >> "$REPORT_FILE"
        fi
done



echo ""
echo "OVERALL SYSTEM STATUS"
echo "-------------------------------------------"

if [ "$CPU_STATUS" = "CRITICAL" ] || \
	[ "$MEMORY_STATUS" = "CRITICAL" ] || \
	[ "$DISK_STATUS" = "CRITICAL" ]; then 
    	OVERALL_STATUS="CRITICAL"
elif [ "$CPU_STATUS" = "WARNING" ] || \
	[ "$MEMORY_STATUS" = "WARNING" ] || \
        [ "$DISK_STATUS" = "WARNING" ]; then
	OVERALL_STATUS="WARNING"
else
        OVERALL_STATUS="HEALTHY"
fi

echo "Overall System Status: $OVERALL_STATUS"
echo "Overall System Status: $OVERALL_STATUS" >> "$REPORT_FILE"

send_email
