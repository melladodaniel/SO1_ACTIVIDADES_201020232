## Actividad 6

## Procesos e Hilos

1. ¿Incluyendo el proceso inicial, cuantos procesos son creados por el siguiente programa? Razone su respuesta.

```C
#include <stdio.h>
#include <unistd.h>

int main()
{
/* fork a child process */
fork();

/* fork another child process */
fork();

/* and fork another */
fork();

return 0;
}
```

El programa crea **8 procesos en total** (incluyendo el proceso inicial).

### Explicación paso a paso:

**Proceso inicial (P0)**: Comienza ejecutándose el proceso original que se crea cuando el programa inicia.

**Primera llamada a `fork()`**:
   - La primera llamada a `fork()` crea un proceso hijo (P1).
   - Ahora tenemos 2 procesos ejecutando el mismo código: el proceso original (P0) y el nuevo proceso hijo (P1).

**Segunda llamada a `fork()`**:
   - Ambos procesos (P0 y P1) ejecutan la segunda llamada a `fork()`, lo que genera 2 nuevos procesos: uno desde P0 (P2) y otro desde P1 (P3).
   - Ahora tenemos 4 procesos: P0, P1, P2 y P3.

**Tercera llamada a `fork()`**:
   - Todos los 4 procesos (P0, P1, P2 y P3) ejecutan la tercera llamada a `fork()`, generando 4 nuevos procesos: uno desde P0 (P4), otro desde P1 (P5), otro desde P2 (P6) y otro desde P3 (P7).
   - En este punto, hay un total de 8 procesos: P0, P1, P2, P3, P4, P5, P6 y P7.


2. Utilizando un sistema Linux, escriba un programa en C que cree un proceso hijo (fork) que finalmente se convierta en un proceso zombie. Este proceso zombie debe permanecer en el sistema durante al menos 60 segundos. Los estados del proceso se pueden obtener del comando: ps -l

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    pid_t pid = fork();  // Crea el proceso hijo

    if (pid < 0) {
        // Si ocurre un error en fork()
        perror("fork failed");
        exit(1);
    } else if (pid == 0) {
        // Código del proceso hijo
        printf("Proceso hijo (PID: %d) terminado.\n", getpid());
        exit(0);  // El proceso hijo termina, lo que lo convierte en un zombie
    } else {
        // Código del proceso padre
        printf("Proceso padre (PID: %d), hijo creado (PID: %d).\n", getpid(), pid);
        
        // Esperar 60 segundos para observar el proceso zombie
        sleep(60);

        // Después de 60 segundos, el padre recoge el estado del hijo, eliminando el zombie
        wait(NULL);
        printf("Proceso zombie eliminado.\n");
    }

    return 0;
}
```

### Explicación:

- El proceso padre llama a `fork()` para crear un proceso hijo.
- El proceso hijo finaliza inmediatamente con `exit(0)`, lo que lo deja en estado zombie porque el proceso padre no recoge su estado de inmediato.
- El proceso padre imprime el PID del hijo y luego duerme durante 60 segundos usando `sleep(60)`. Durante este tiempo, el hijo queda en estado zombie.
- Después de 60 segundos, el padre recoge el estado del hijo con `wait(NULL)`, eliminando el proceso zombie.

3. Usando el siguiente código como referencia, completar el programa para que sea ejecutable y responder las siguientes preguntas:
* ¿Cuántos procesos únicos son creados?
* ¿Cuántos hilos únicos son creados?

```C
pid_t pid;

pid = fork();
if (pid == 0) { /* child process */
fork();
thread_create( . . .);
}
fork();
```

### Programa Completo:

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

void* thread_function(void* arg) {
    printf("Hilo creado con PID: %d, TID: %lu\n", getpid(), pthread_self());
    return NULL;
}

int main() {
    pid_t pid;

    // Primera llamada a fork()
    pid = fork();
    if (pid < 0) {
        perror("Error en fork");
        exit(1);
    }

    if (pid == 0) { /* proceso hijo */
        // Segunda llamada a fork() dentro del proceso hijo
        pid = fork();
        if (pid < 0) {
            perror("Error en fork");
            exit(1);
        }

        // Crear un hilo en el proceso hijo
        if (pid == 0) {
            pthread_t thread;
            pthread_create(&thread, NULL, thread_function, NULL);
            pthread_join(thread, NULL);  // Esperar que el hilo termine
        }
    }

    // Tercera llamada a fork() en ambos (proceso padre e hijo)
    fork();

    // Pausa para observar procesos e hilos
    sleep(2);

    return 0;
}
```

### Explicación del programa:

- **Primera llamada a `fork()`**: El proceso inicial se divide en dos procesos (el proceso padre y el proceso hijo).
  
- **Segunda llamada a `fork()`** dentro del proceso hijo: Se genera otro proceso en el proceso hijo, lo que crea un nieto del proceso inicial.

- **`pthread_create()`**: El proceso hijo (y no el nieto) crea un hilo con `pthread_create()`.

- **Tercera llamada a `fork()`**: Esta llamada se ejecuta en todos los procesos existentes, lo que significa que todos los procesos creados hasta el momento (padre, hijo y nieto) generan un nuevo proceso cada uno.

### Diagrama de creación de procesos:

Proceso inicial (P0).
`fork()` (en el proceso inicial): Crea el proceso hijo (P1).
   - Ahora tenemos dos procesos: P0, P1.
   
`fork()` (dentro del proceso hijo P1): El proceso hijo P1 crea otro proceso (P2).
   - Ahora tenemos tres procesos: P0, P1, P2.
   
`pthread_create()` (en el proceso P1): Solo el proceso P1 crea un hilo (T1).
   - Proceso P1 ahora tiene un hilo (T1).
   
`fork()` (se ejecuta en P0, P1, y P2): Cada uno de los tres procesos llama a `fork()`, creando un nuevo proceso para cada uno.
   - P0 crea P3, P1 crea P4, P2 crea P5.
   - En este punto tenemos seis procesos: P0, P1, P2, P3, P4, P5.
   
### Respuestas a las preguntas:

#### 1. ¿Cuántos **procesos únicos** son creados?

- Inicialmente, hay 1 proceso.
- La primera llamada a `fork()` crea 1 proceso (P1).
- La segunda llamada a `fork()` crea otro proceso (P2).
- La tercera llamada a `fork()` se ejecuta en 3 procesos, creando 3 nuevos procesos (P3, P4, P5).

En total, se crean **6 procesos únicos**: P0 (inicial), P1, P2, P3, P4, P5.

#### 2. ¿Cuántos **hilos únicos** son creados?

- Solo el proceso P1 crea un hilo (T1).

En total, se crea **1 hilo único**.
