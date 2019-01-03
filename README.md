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
Los archivos para crear la imagen se encuentran en https://github.com/ClRDAN/sshpamldap  

El repositorio contiene los siguientes archivos:
  * access.conf: archivo de configuración del módulo de PAM pam.access. Contiene una lista de usuarios con permiso para conectar por SSH. Al arrancar el container este archivo se copia en /etc/security/  
  * authconfig.conf: script que utiliza el comando authconfig para configurar la conexión con LDAP. Se ejecuta automáticamente al arrancar el container.  
  * Dockerfile: archivo de creación de la imagen Docker. Este archivo hace que se instalen en el container los paquetes necesarios para la comunicación con el servidor LDAP (openldap-clients, nss-pam-ldapd, authconfig) y para hacer de servidor SSH (openssh-server). También copia todos los archivos de configuración al container y establece el script startup.sh como comando predeterminado a ejecutar al arrancar el container.  
  * install.sh: script que se ejecuta al arrancar la imagen, configura el container y arranca servicios necesarios (nslcd para LDAP, sshd para SSH)  
  * nsswitch.conf: archivo de configuracion de nsswitch, sobrescribe al predefinido al ejecutar install.sh. Necesario para la comunicación con LDAP.  
  * ssh_allowed: archivo de texto con una lista de usuarios con permiso para conectar por SSH. Es utilizado por el módulo pam_listfile para controlar el acceso via SSH. Este archivo debe estar en /opt/docker para ser utilizado.  
  * sshd: archivo de modulos de pam específico para el servicio de SSH. Al arrancar el container, es copiado automáticamente en /etc/pam.d/  
  * sshd_config: archivo de configuración del servidor SSH. Incluye una lista de usuarios con derecho de acceso y se ha modificado para que el puerto de escucha del servicio sea el 1022. Al arrancar el container es copiado automáticamente en /etc/sshd/  
  * startup.sh: llama al script install.sh y especifica el programa padre al arrancar el container.  
  * system-auth.edt: archivo de módulos pam para la autenticación de usuarios, se encarga de controlar la   
autenticación de usuarios y de que se cree automáticamente el HOME del usuario si no existía. Al arrancar el container este archivo se copia en /etc/pam.d/ y se crea un enlace simbólico llamado /etc/pam.d/system-auth que apunta a él.  

## PROCEDIMIENTO SEGUIDO  
1. configuramos el acceso a LDAP mediante authconfig y nsswitch, comprobamos que el container puede comunicarse con el servidor LDAP usando el comando  
```getent passwd```  
2. Configuramos PAM para que se pueda loguear en el sistema con usuarios locales y LDAP, y que se cree el HOME si no existía. Con la configuración del apartado anterior ya se ha activado la resolución de nombres LDAP y la autenticación, ahora modificamos el archivo de módulos system-auth.edt. Comprobamos que todo funciona cambiando de usuario con  
```su - pere` `su - local01```  
3. Ponemos en marcha el servicio SSH y comprobamos que podemos conectar al container remotamente con usuarios locales y LDAP mediante el comando  
```ssh pere@172.18.0.3```  
¡ATENCIÓN!: para que el servidor funcione debe crearse un par de claves en /etc/ssh/ que se usarán para autenticar el servidor. En este container he decidido crear un nuevo par de claves cada vez que se arranca el container, por lo que si se apaga y vuelve a encender el container los hosts que ya se habían conectado anteriormente por SSH detectarán este cambio de claves y no conectarán. O bien hay que borrar la clave vieja antes de conectarse (está en ~/.ssh/known_hosts) o habría que sustituir en el archivo install.sh la línea con el comando  
```ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" < /dev/null```  
por otra del tipo  
```cp /opt/docker/ssh_host_rsa_key* /etc/ssh/```  
en la que copiamos dentro del container un par de claves previamente generadas.  
4. Modificamos el archivo de configuración de SSH para que el servicio utilice el puerto 1022 en vez del 22.   
5. Establecemos restricciones de acceso por usuario y comprobamos que funciona, primero por separado con cada uno de los tres métodos de restricción y luego todo junto. La restricción tipo AllowUsers se establece en el archivo /etc/ssh/sshd_config, las restricciones de pam_access y pam_listfile necesitan cargar el módulo correspondiente en el archivo de configuración PAM para SSH llamado /etc/pam.d/sshd y un archivo de configuración auxiliar llamado /etc/security/access.conf y /opt/docker/ssh_allowed respectivamente. 

En la configuración predefinida los módulos pam_access y pam_listfile están cargados como REQUIRED, por lo que para que un usuario pueda loguear debe estar autorizado POR LOS TRES MÉTODOS. Si se quiere que sea suficiente con estar autorizado en uno de ellos habría que tener en cuenta que un resultado de success en estos módulos tan sólo dice que ese usuario tiene permiso de acceso pero no lo autentifica. A continuación adjunto una tabla con los distintos usuarios con permisos de SSH y el resultado final al intentar loguear.
<pre>
     __________________________________________________________________________      
    | USUARIO   |   AllowUsers   |   PAM_ACCESS   |   PAM_LISTFILE |   ACCESO  |  
    |--------------------------------------------------------------------------|  
    | pere      |       V        |      V         |      V         |    V      |  
    | pau       |       V        |      V         |      X         |    X      |  
    | marta     |       V        |      X         |      V         |    X      |  
    | jordi     |       X        |      V         |      V         |    X      |  
    | local01   |       V        |      X         |      X         |    X      |  
    | local02   |       X        |      V         |      X         |    X      |  
    | local03   |       X        |      X         |      V         |    X      |  
     __________________________________________________________________________  
 </pre>

## Comandos para arrancar los containers
```
docker run --rm --name sshd --hostname sshd --network redcasa -it agalilea/sshd
docker run --rm --name ldap --hostname ldap --network redcasa -d agalilea/ldap
```
## Comandos para establecer conexión SSH
Desde fuera de la red de containers "redcasa":  
``` ssh pere@172.18.0.3 -p 1022```  
Desde dentro de la red de containers "redcasa":  
```ssh pere@sshd -p 1022```  
La IP puede variar según cuántos dispositivos haya en la red al arrancar el servidor, para no tener que usar la IP cuando se conecte desde fuera de la red habría que configurar el servidor DNS para que resuelva el nombre o añadir una línea al archivo /etc/hosts del cliente desde el que conectamos.  
