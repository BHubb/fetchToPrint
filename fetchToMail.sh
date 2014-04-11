#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export DISPLAY=:0.0
# Above is to make the script silent for cron

# Importing fetchToPrint Configs
source fetchToPrint.conf

# Creating fetchmail and procmail confs

# Checking enviroment
if [ ! -d "$(pwd)/logs" ]
then
	mkdir $(pwd)/logs
fi

if [ ! -d "$(pwd)/mail" ]
then
	mkdir $(pwd)/mail
fi

if [ ! -d "$(pwd)/pdf-in" ]
then
	mkdir $(pwd)/pdf-in
fi

# Operations
fetchmail -K -s -f $FETCHMAIL_CONFIG 2>> $FETCHMAIL_LOG 1>> $FETCHMAIL_LOG # Grabs mail via IMAP
munpack $MAIL_DIR -f -q -C $ATTACHMENT_DIR 2>> $MUNPACK_LOG 1>> $MUNPACK_LOG # Unpacks mail in MAIL_DIR to ATTACHEMNT_DIR

files=$(ls $ATTACHMENT_DIR/*.$ATTACHMENT_TYPE 2> /dev/null | wc -l)	# counts number of pdfs in ATTACHMENT_DIR
if [ "$files" != "0" ]; then # If the number of pdf's is greater then 0 then;
	lp -d $CUPS_PRINTER -h $CUPS_HOSTNAME -o ColorModel=Grayscale $ATTACHMENT_DIR/*.$ATTACHMENT_TYPE >> $CUPS_LOG # Prints all $ATTACHEMNT_TYPE in $ATTACHMENT_DIR to VRH-PRN-002
	echo $(date +'%Y-%m-%d %T') >> $PDF_PRINT_LOG # Prints out date and time a print job was done
	find $ATTACHMENT_DIR/ -name *.$ATTACHMENT_TYPE | awk -F'/' '{ print "\t"$NF }' >> $PDF_PRINT_LOG # Prints only the PDF name to the log
	rm -r $ATTACHMENT_DIR/*.* > /dev/null
	rm /opt/pdfPrint/mail/new/* > /dev/null

fi
