#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export DISPLAY=:0.0
# Above is to make the script silent for cron


# Logs
PDF_PRINT_LOG=/opt/pdfPrint/logs/pdf_print		# Logs all the pdfs that have been printed
FETCHMAIL_LOG=/opt/pdfPrint/logs/fetchmail		# Logs fetchmail errors
MUNPACK_LOG=/opt/pdfPrint/logs/munpack			# Logs Munpack Errors
CUPS_LOG=/opt/pdfPrint/logs/cups			# Logs for CUPS

# Variables
FETCHMAIL_CONFIG=/opt/pdfPrint/configs/fetchmail	# Configuration file for OfflineIMAP
MAIL_DIR=/opt/pdfPrint/mail/new/*			# Folder that munpack will be pulling attachments from
ATTACHMENT_DIR=/opt/pdfPrint/pdf-in			# Folder that munpack will be sending attachments too

# Operations
fetchmail -K -s -f $FETCHMAIL_CONFIG 2>> $FETCHMAIL_LOG 1>> $FETCHMAIL_LOG # Grabs mail via IMAP
munpack $MAIL_DIR -f -q -C $ATTACHMENT_DIR 2>> $MUNPACK_LOG 1>> $MUNPACK_LOG # Unpacks mail in MAIL_DIR to ATTACHEMNT_DIR

files=$(ls $ATTACHMENT_DIR/*.pdf 2> /dev/null | wc -l)	# counts number of pdfs in ATTACHMENT_DIR
if [ "$files" != "0" ]; then # If the number of pdf's is greater then 0 then;
	lp -d VRH-PRN-002 -o ColorModel=Grayscale $ATTACHMENT_DIR/*.pdf >> $CUPS_LOG # Prints all PDF's in $ATTACHMENT_DIR to VRH-PRN-002
	echo $(date +'%Y-%m-%d %T') >> $PDF_PRINT_LOG # Prints out date and time a print job was done
	find $ATTACHMENT_DIR/ -name *.pdf | awk -F'/' '{ print "\t"$5 }' >> $PDF_PRINT_LOG # Prints only the PDF name to the log
	rm -r $ATTACHMENT_DIR/*.* > /dev/null
	rm /opt/pdfPrint/mail/new/* > /dev/null

fi
