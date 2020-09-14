#!/usr/bin/env bash
set -e

FORCE_REINIT_CONFIG=${FORCE_REINIT_CONFIG:=false}
USE_SSL=${USE_SSL:=true}
PASSV_MIN_PORT=${PASSV_MIN_PORT:=60000}
PASSV_MAX_PORT=${PASSV_MAX_PORT:=63000}
APP_UMASK=${APP_UMASK:=007}
APP_UID=${APP_UID:=1000}
APP_GID=${APP_GID:=1000}
APP_USER_NAME=${APP_USER_NAME:=admin}
APP_USER_PASSWD=${APP_USER_PASSWD:=admin}
if [ -f "$FTPS_SOURCE_DIR/Initialized" ] && [ "$FORCE_REINIT_CONFIG" = false ]; then
	echo "[] Skip initializing"
else
	echo "[] Creating initial data ..."	
	chmod 770 $FTPS_SOURCE_DIR/eventscripts/*.sh || true
	echo "[] Running on_pre_init.sh ..."
		. $FTPS_SOURCE_DIR/eventscripts/on_pre_init.sh || true
	echo "[] Done."
	
	
	echo "[] Creating User: $APP_USER_NAME ..."
		mkdir -p $FTPS_USER_HOME/data
		useradd -m -d $FTPS_USER_HOME -s /bin/bash $APP_USER_NAME || true
		
		groupadd $APP_USER_NAME || true
		useradd $APP_USER_NAME -g $APP_USER_NAME || true
	echo "[] Done."
	
	echo "[] Changing UID/GID: $APP_UID|$APP_GID ..."
		groupmod -o -g $APP_GID $APP_USER_NAME || true
		usermod -o -u $APP_UID $APP_USER_NAME || true
	echo "[] Done."
	
	echo "[] Setting password: ${APP_USER_NAME}"	
		echo -e "${APP_USER_PASSWD}\n${APP_USER_PASSWD}\n" | passwd ${APP_USER_NAME}
	echo "[] Done."
	
	echo "[] Coping configs ..."		
		cp $FTPS_SOURCE_DIR/vsftpd.conf /etc/vsftpd/vsftpd.conf
		echo "" >> /etc/vsftpd/vsftpd.conf
		echo "pasv_min_port=$PASSV_MIN_PORT" >> /etc/vsftpd/vsftpd.conf
		echo "pasv_max_port=$PASSV_MAX_PORT" >> /etc/vsftpd/vsftpd.conf
		echo "local_umask=$APP_UMASK" >> /etc/vsftpd/vsftpd.conf
		if [ "$USE_SSL" = true ]; then
			echo "ssl_enable=YES" >> /etc/vsftpd/vsftpd.conf
			echo "rsa_cert_file=/usr/certs/cert.crt" >> /etc/vsftpd/vsftpd.conf
			echo "rsa_private_key_file=/usr/certs/cert.key" >> /etc/vsftpd/vsftpd.conf
			echo "allow_anon_ssl=NO" >> /etc/vsftpd/vsftpd.conf
			echo "force_local_data_ssl=YES" >> /etc/vsftpd/vsftpd.conf
			echo "force_local_logins_ssl=YES" >> /etc/vsftpd/vsftpd.conf
			echo "ssl_tlsv1=YES" >> /etc/vsftpd/vsftpd.conf
			echo "ssl_sslv2=NO" >> /etc/vsftpd/vsftpd.conf
			echo "ssl_sslv3=NO" >> /etc/vsftpd/vsftpd.conf
			echo "require_ssl_reuse=NO" >> /etc/vsftpd/vsftpd.conf
			echo "ssl_ciphers=HIGH" >> /etc/vsftpd/vsftpd.conf
			echo "implicit_ssl=YES" >> /etc/vsftpd/vsftpd.conf
		else
			echo "ssl_enable=NO" >> /etc/vsftpd/vsftpd.conf
		fi
	echo "[] Done."
	
	echo "[] Fixing permision ..."
		chown $APP_USER_NAME:$APP_USER_NAME $FTPS_USER_HOME || true
		chown $APP_USER_NAME:$APP_USER_NAME $FTPS_USER_HOME/data || true
	echo "Done."
	
	
	touch $FTPS_SOURCE_DIR/Initialized || true
	echo "[] Running on_post_init.sh ..."
		. $FTPS_SOURCE_DIR/eventscripts/on_post_init.sh || true
	echo "[] Done."	
	echo "[] Initialize complete."
fi

echo "[] Running on_run.sh ..."
. $FTPS_SOURCE_DIR/eventscripts/on_run.sh || true
echo "[] Done."	
echo "[] Run vsftpd ..."
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
echo "[] Done."	