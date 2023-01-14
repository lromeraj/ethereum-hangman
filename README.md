<style>
  @import "./md-utils/style.css";
</style>

*En fecha 14/01/2023*, por:   
  - *Alberto Carlos Martin Rodriguez*  
  - *Javier Romera Llave*

# Práctica 4 | DII | Blockchain: el juego del ahorcado

<div class="img-centered">
  <img src="./img/blockchain.png" width="250">
</div>

<div class="index">

- [Práctica 4 | DII | Blockchain: el juego del ahorcado](#práctica-4--dii--blockchain-el-juego-del-ahorcado)
- [Descripción general](#descripción-general)
- [Dependencias](#dependencias)
- [Guía de usuario de la aplicación](#guía-de-usuario-de-la-aplicación)
  - [Configurar una instancia propia](#configurar-una-instancia-propia)
- [Mecánica de juego](#mecánica-de-juego)
- [Descripción del código implementado](#descripción-del-código-implementado)
- [Repositorio](#repositorio)
  - [GitLab propietario (recomendado)](#gitlab-propietario-recomendado)
  - [GitHub](#github)
- [Referencias](#referencias)

</div>

<p break/>

# Descripción general

Hemos decidido implementar una versión modificada del juego del ahorcado para la *blockchain* de *Ethereum*. La mecánica del juego es muy similar a la del ahorcado original pero con algunas modificaciones que mostraremos en la sección [de mecánica de juego](#mecánica-de-juego). Además, también hemos implementado una pequeña y simple interfaz que permite interactuar con el contrato correspondiente y poder así participar en el juego más cómodamente. 

# Dependencias

Dado que ofrecemos una solución con interfaz, la configuración del entorno será ligeramente más compleja que en la práctica anterior, ya que a parte de utilizar *Remix* utilizaremos una instancia de una red privada para la blockchain de *Ethereum* usando el cliente `geth`. También será necesario tener instalado el manejador de paquetes de *Node JS* (`npm`).

- Cómo instalar `npm` -> [https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04-es](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04-es) (recomendamos la segunda opción)

- Cómo instalar `geth` -> [https://geth.ethereum.org/docs/getting-started/installing-geth](https://geth.ethereum.org/docs/getting-started/installing-geth)

> **ATENCIÓN**: estos pasos son necesarios si finalmente decide configurar una instancia propia para probarlo, pero como verá en el siguiente apartado **no es estrictamente necesario**.

# Guía de usuario de la aplicación

Para facilitar la corrección y evitar que el corrector tenga la necesidad de montar y configurar su propia instancia, hemos instanciado una *blokchain* de *Ethereum* propia (*on-premise*) así como un pequeño servidor *HTTP* que sirve la interfaz, para que tan solo sea necesario usar el navegador con `Remix` para crear un contrato nuevo (aunque se dejarán algunas instancias vacías para que se puedan probar sin necesidad de tener que abrir *Remix* ).

> **NOTA**: la interfaz de usuario permite cargar una instancia de un contrato creado anteriormente **pero NO permite crear un contrato**, para crear un contrato será estrictamente necesario el uso de *Remix* usando el proveedor correspondiente (como veremos posteriormente).

A continuación detallamos los pasos necesarios para probar nuestra aplicación de la forma más cómoda posible:

1. Abra su navegador y acceda a la siguiente URL [https://hangman.lromeraj.net](https://hangman.lromeraj.net)

> Antes de comenzar a jugar, le recordamos que hemos implementado un sistema de eventos para dar soporte a cambios en tiempo real que ocurran en el contrato y poder así notificar al resto de jugadores que se encuentren en línea.

2. Como podrá observar en la interfaz de usuario, el primer *input* permite introducir la dirección del contrato correspondiente, a continuación le adjuntamos una serie de instancias con un juego ya creado pero sin interacción previa alguna:
    ``` js
    // poner aquí las direcciones
    ```
3. si desea crear sus propios contratos deberá abrir *Remix* y copiar el código del contrato tal cual se encuentra en el repositorio, se recomienda NO modificar el contrato, ya que esto podría entrar en conflicto con el *ABI* grabado en el servidor *HTTP* que le sirve la interfaz y dejarla inservible (si modifica las cabeceras de algunas funciones por ejemplo). Cuando vaya a desplegar el contrato seleccione el entorno `External Http Provider` y escriba la siguiente URL `https://geth.lromeraj.net:443`. El siguiente paso simplemente consiste en crear un contrato, ¡piense en un buen secreto a la hora de crearlo! ;)

## Configurar una instancia propia

Si por alguna razón el servicio se encuentra caído, recomendamos esperar unos minutos (puede dar la casualidad ed que estemos dando retoques), o simplemente prefiere instanciar el servicio en su propia máquina, se adjuntan algunas indicaciones adicionales para tal efecto:

1. Eliminar la restricción de `Chrome` sobre redes [privadas que no usan conexiones seguras](https://stackoverflow.com/questions/66534759/cors-error-on-request-to-localhost-dev-server-from-remote-site).
    **IMPORTANTE**: ¡recuerde volver a activarla después de las pruebas!

2. Lanzar el servidor local usando la implementación escrita en *Go* de la *blockchain* de *Ethereum* (`geth`):
    ``` bash
    geth \
      --ws \
        --ws.origins="*" \
        --ws.addr="0.0.0.0" \
      --http \
        --http.vhosts="*" \
        --http.corsdomain="*" \
        --http.addr="0.0.0.0" \
        --http.api="web3,eth,personal,net" \
      --allow-insecure-unlock \
      --datadir="data/" \
      --dev \
      --preload="unlock.js" \
      console
    ```
    **ATENCIÓN**: no hace falta que ejecute este comando ahora, es simplemente para que pueda ver algunos de los parámetros que se pasan cuando se ejecute posteriormente de forma automática. El *script* `unlock.js` crea un pequeño conjunto de 10 cuentas, les otorga un balance inicial y desbloquea todas ellas para que puedan ser utilizadas durante las pruebas del juego (la contraseña de todas las cuentas creadas por el script es `1234`):
    ``` js
    const toWei = web3.toWei;
    const BN = web3.BigNumber;

    const DEFAULT_ACCOUNT_PASSWORD = "1234";
    const DEFAULT_ACCOUNT_BALANCE = toWei( new BN( 100 ), 'ether' ); // ether

    function createAccounts() {
      if ( eth.accounts.length === 1 ) {
        for ( let i=0; i < 10; i++ ) {
          personal.newAccount( DEFAULT_ACCOUNT_PASSWORD );
        }
      }
    } 

    function getCurrentAccounts() {
      const currentAccounts = [ ... eth.accounts ]
      currentAccounts.shift();
      return currentAccounts;
    }

    function unlockAccounts() {

      const accounts = getCurrentAccounts();
      console.log( "\n================ UNLOCKING ================\n" )

      for ( let account of accounts ) {
        let strOut = `Unlocking account ${ account } ... `
        const result = personal.unlockAccount( account, DEFAULT_ACCOUNT_PASSWORD, 0 ); 
        strOut += result ? "OK" : "ERR";
        console.log( strOut )
      }

      console.log( "\n================ ========= ================\n" )

    }

    function seedAccounts() {
      const accounts = getCurrentAccounts();

      for ( let account of accounts ) {
        const balanceDiff = DEFAULT_ACCOUNT_BALANCE
          .minus( eth.getBalance( account ) );
        
        if ( balanceDiff.gt( 0 ) ) {
          console.log(`Sending ${ balanceDiff } ether to ${account} ...`);
          eth.sendTransaction({
            from: eth.accounts[ 0 ],
            to: account,
            value: balanceDiff
          })
        }
      }

    }

    function main() {
      
      createAccounts();
      unlockAccounts();
      seedAccounts();

      while ( 1 ) { // this will allow us to keep accounts unlocked
        console.log( "Unlocker heartbeat ..." )
        admin.sleep( 60*60 );
      }
    }

    main();
    ```
    > **IMPORTANTE**: el cliente web de la interfaz de usuario trata de resolver el dominio en función de si utiliza su instancia o la remota, en caso de que surja algún problema recuerde que puede modificar el fichero `index.html` y modificar la *URL* por la siguiente:  
    > ```config
    > ws://localhost:8545
    > ```

3. Ahora debe instalar las dependencias del servidor local *HTTP* ejecutando simplemente:
    ``` bash
    npm install
    ```
4. Ejecute el servidor local *HTTP* junto a la *blockchain* de *Ethereum* con el siguiente comando:
    ``` bash
    npm run start
    ```
5. Abra en su navegador la siguiente URL [http://localhost:5002](http://localhost:5002) ¡y a jugar!

> **ATENCIÓN**: este proyecto incluye claves y configuraciones especiales para un entorno de pruebas y en ningún caso debería usarse para entornos de producción sin una previa limpieza y revisión.

# Mecánica de juego

- Existe un precio fijo por letra (hemos fijado este valor en `0.1 ether`).
- El creador del contrato (propietario) elige un secreto utilizando caracteres *ASCII* alfanuméricos (también se incluyen los espacios), el coste para formalizar la creación del contrato será en base al número de caracteres que conformen el secreto (en este caso, $C = N * 0.1_{Ether}$).
- El secreto a descubrir puede estar en cualquier lenguaje o formato utilizando los caracteres anteriormente mencionados (no se aplica ningún mecanismo para comprobar si realmente es un texto con "sentido").
- La longitud máxima posible para el secreto será de $36$ letras.

- Dado que el precio gira entorno al número de letras, los participantes cada vez que quieran revelar letras tendrán que pagar en función de las mismas. Uno se convierte en participante con el simple hecho de incorporar alguna letra.
  1. Si la letra solicitada no existe se acumula un reembolso que se devolverá al finalizar.
  2. Si la letra solicitada se ingresa en una cantidad superior a las existentes/restantes se procederá al reembolso cuando finalice el juego.

- Siempre que se finaliza el juego (gane quien gane) lo primero que se hace es reembolsar (en caso de que haya reembolso) el valor correspondiente a cada uno de los participantes.

- En caso de que los participantes hayan agotado todas sus vidas, el propietario recibirá un reembolso íntegro correspondiente al coste total de la creación del contrato, el dinero restante (aportado por los participantes), será distribuido de la siguiente forma:
  - Valor para los participantes -> $V_{Participantes} = D_{Total} * N_{LetrasAcertadas} / N_{LetrasRestantes}$
  - Valor para el propietario -> $V_{Propietario} = D_{Total} - V_{Participantes}$
  - Valor para cada participante -> $V_{Participantes} / N_{Participantes}$  
  **NOTA**: $D_{Total}$ es el depósito total restante tras haber realizado los reembolsos correspondientes.

- En caso de que los participantes resulten ganadores, de nuevo, el primer paso es reembolsar el valor correspondiente a cada uno de ellos, pero en este caso el depósito restante $D_{Total}$ será igual a la suma de la contribución del propietario más todas las contribuciones de los participantes:
  - Valor para cada participante -> $V_{Participante} = D_{total} / N_{Participantes}$

- El propietario NO puede actuar como participante.
- El límite máximo de participantes será de $N_{CaracteresSecreto} / 6$
- Se deduce el número máximo absoluto de participantes por $N_{MaxCaracteres} / N_{MaxParticipantes} = 6$


# Descripción del código implementado
Describiremos las partes más relevantes del código implementado para el contrato correspondiente.

<p break />

# Repositorio

## GitLab propietario (recomendado)
El siguiente repositorio contiene todo el código fuente de esta práctica -> [https://gitlab.lromeraj.net/ucm/miot/dii/p4](https://gitlab.lromeraj.net/ucm/miot/dii/p4)

___

## GitHub
Si el enlace de arriba no le funciona puede utilizar este otro repositorio: [https://github.com/lromeraj/ethereum-hangman](https://github.com/lromeraj/ethereum-hangman)

# Referencias

Hemos consultado distintos ejemplos y referencias web para poder conocer los objetos y derivados de Selenium para implementar toda la funcionalidad de la aplicación *Blockchain*:

1. Servidor local para la blockchain de Etherium - [https://github.com/ethereum/go-ethereum](https://github.com/ethereum/go-ethereum)


