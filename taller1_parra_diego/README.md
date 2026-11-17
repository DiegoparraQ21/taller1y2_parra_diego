# Taller 1 - BiblioRed

En este taller hice una base de datos para una red de bibliotecas. La idea era poder saber qué libros hay en cada sede, quién tiene un ejemplar prestado, cuándo lo debe devolver y si le queda alguna multa por pagar.

Primero hice el diagrama para organizar las tablas y sus relaciones. Una parte importante fue separar el título del ejemplar. Un mismo libro puede tener varias copias y cada copia puede estar en una sede distinta. También quedó registrado el historial de préstamos, renovaciones, reservas y pagos.

## Archivos

| Archivo | Qué contiene |
| --- | --- |
| [00-diagrama.md](00-diagrama.md) | Diagrama en Mermaid, relaciones y explicación de la normalización. |
| [01_ddl.sql](01_ddl.sql) | Creación de la base `bibliored`, las tablas y sus restricciones. |
| [02_dml.sql](02_dml.sql) | Datos de prueba y ejemplos de cambios y eliminaciones. |
| [03_dql.sql](03_dql.sql) | Las 12 consultas del taller. Se puede ver, por ejemplo, quién tiene préstamos vencidos o multas pendientes. |
| [04_dql_avanzado.sql](04_dql_avanzado.sql) | Procedimientos para prestar, devolver, renovar y pagar multas, entre otros. |
| [05_tcl.sql](05_tcl.sql) | Pruebas con transacciones. Por ejemplo, si el préstamo falla, se puede deshacer el cambio de estado del ejemplar. |
| [06_retos.sql](06_retos.sql) | Los tres retos adicionales sobre socios pendientes, categorías y reservas vencidas. |

## Cómo probarlo

1. Abrir los archivos en MySQL Workbench con MySQL 8.0.16 o superior.
2. Ejecutar los archivos SQL en orden, desde `01_ddl.sql` hasta `05_tcl.sql`. El primero borra y vuelve a crear la base `bibliored` si ya existe.
3. Ejecutar `06_retos.sql` al final para revisar los retos.

La fecha de corte principal es el **10 de noviembre de 2026**. Las pruebas que deben fallar están comentadas con el error esperado. Para comprobarlas, se pueden ejecutar de una en una en el punto donde aparecen.
