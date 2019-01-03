#SSHPAMLDAP 
## PRACTICA SSH PAM Y LDAP @EDT 2018-19
Archivos necesarios para generar una imagen docker con la que montar containers de 
Fedora 27 capaces de comunicarse con un container LDAP y permitir acceso remoto mediante SSH. Los usuarios locales y de LDAP
pueden loguearse en la máquina de forma local o remota, creandose un directorio HOME si no existía.
   Se configura tambien el acceso de los usuarios mediante restricciones tipo AllowUsers en SSH, mediante PAM con pam_access.so y con pam_listfile.so.

La imagen ya creada se encuentra en https://hub.docker.com/r/agalilea/
```docker pull agalilea/m06pam```
La imagen del servidor LDAP se encuentra en https://hub.docker.com/r/agalilea/ldap/
```docker pull agalilea/ldap```

El repositorio contiene los siguientes archivos:
  * access.conf: archivo de configuración del módulo de PAM pam.access. Contiene una lista de usuarios con permiso para conectar por SSH
  * authconfig.conf: script que utiliza el comando authconfig para configurar la conexión con LDAP  
  * Dockerfile: archivo de creación de la imagen Docker  
  * install.sh: script que se ejecuta al arrancar la imagen, configura el container y arranca servicios necesarios  
  * nsswitch.conf: archivo de configuracion de nsswitch, sobrescribe al predefinido al ejecutar install.sh  
  * ssh_allowed: archivo de texto con una lista de usuarios con permiso para conectar por SSH. Es utilizado por el módulo pam_listfile para controlar el acceso via SSH.
  * sshd: archivo de modulos de pam específico para el servicio de SSH.
  * sshd_config: archivo de configuración del servidor SSH. Incluye una lista de usuarios con derecho de acceso y se ha modificado para que el puerto de escucha del servicio sea el 1022.
  * startup.sh: llama al script install.sh y especifica el programa padre al arrancar el container  
  * system-auth.edt: archivo de módulos pam para la autenticación de usuarios, se encarga de controlar la   
autenticación de usuarios y de que se cree automáticamente el HOME del usuario si no existía.
