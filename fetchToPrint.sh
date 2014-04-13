#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export DISPLAY=:0.0
# Above is to make the script silent for cron

# Importing fetchToPrint Configs
source fetchToPrint.conf

# Checking enviroment
if [ ! -d "$FETCHTOPRINT_DIR/logs" ]
then
	mkdir $FETCHTOPRINT_DIR/logs
fi

if [ ! -d "$FETCHTOPRINT_DIR/mail" ]
then
	mkdir $FETCHTOPRINT_DIR/mail
fi

if [ ! -d "$FETCHTOPRINT_DIR/attachments" ]
then
	mkdir $FETCHTOPRINT_DIR/attachments
fi

# Creating fetchmail and procmail confs
sed -e "s/:MAIL_SERVER:/$MAIL_SERVER/g" \
    -e "s/:MAIL_PROTO:/$MAIL_PROTO/g" \
    -e "s/:MAIL_USER:/$MAIL_USER/g" \
    -e "s/:MAIL_PASSWORD:/$MAIL_PASSWORD/g" \
    -e "s@:PROCMAIL_CONFIG:@$PROCMAIL_CONFIG@g" \
    $FETCHTOPRINT_DIR/configs/fetchmail.template > $FETCHTOPRINT_DIR/configs/fetchmail

sed -e "s@:FETCHTOPRINT_DIR:@$FETCHTOPRINT_DIR@g" \
    -e "s@:PROCMAIL_LOG:@$PROCMAIL_LOG@g" \
    $FETCHTOPRINT_DIR/configs/procmail.template > $FETCHTOPRINT_DIR/configs/procmail

# Operations
fetchmail -K -s -f $FETCHMAIL_CONFIG 2>> $FETCHMAIL_LOG 1>> $FETCHMAIL_LOG # Grabs mail via IMAP
munpack $MAIL_NEWDIR -f -q -C $ATTACHMENT_DIR 2>> $MUNPACK_LOG 1>> $MUNPACK_LOG # Unpacks mail in MAIL_DIR to ATTACHEMNT_DIR

files=$(ls $ATTACHMENT_DIR/*.$ATTACHMENT_TYPE 2> /dev/null | wc -l)	# counts number of pdfs in ATTACHMENT_DIR
if [ "$files" != "0" ]; then # If the number of pdf's is greater then 0 then;
	lp -d $CUPS_PRINTER -h $CUPS_SERVER:$CUPS_PORT $ATTACHMENT_DIR/*.$ATTACHMENT_TYPE 2>> $CUPS_LOG 1>> $CUPS_LOG # Prints all $ATTACHEMNT_TYPE in $ATTACHMENT_DIR to $CUPS_SERVER
	echo $(date +'%Y-%m-%d %T') >> $FETCHTOPRINT_LOG # Prints out date and time a print job was done
	ls $ATTACHMENT_DIR/*.$ATTACHMENT_TYPE | awk -F'/' '{ print "\t"$NF }' >> $FETCHTOPRINT_LOG # Prints only the $ATTACHMENT_TYPE name to the log
	# Clean up
	rm -r $ATTACHMENT_DIR/*.* > /dev/null
	rm $FETCHTOPRINT_DIR/mail/new/* > /dev/null

fi
