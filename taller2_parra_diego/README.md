# Taller 2 - FlotaYa

En este taller hice una base de datos para una empresa de alquiler de carros. Se puede revisar la flota, las reservas, los contratos, los mantenimientos y los pagos. El precio del alquiler se calcula por cada noche, usando la temporada que corresponde.

El modelo tiene 27 tablas. Los extras conservan el precio que se pactó en el contrato. Las inspecciones permiten distinguir un daño previo de uno que sí se cobra al devolver el carro.

## Archivos

| Archivo | Contenido |
| --- | --- |
| [00_diagrama.md](00_diagrama.md) | Diagrama, relaciones, normalización y preguntas guía. |
| [01_ddl.sql](01_ddl.sql) | Base y restricciones. |
| [02_dml.sql](02_dml.sql) | Datos, cambios del día y errores de prueba. |
| [03_dql.sql](03_dql.sql) | Las 12 consultas. |
| [04_dql_avanzado.sql](04_dql_avanzado.sql) | Funciones, procedimientos, cuentas y permisos. |
| [05_tcl.sql](05_tcl.sql) | Cierres con COMMIT, ROLLBACK y SAVEPOINT. |
| [06_retos.sql](06_retos.sql) | Los tres retos adicionales. |
| [evidencias/README.md](evidencias/README.md) | Pasos para hacer las pruebas de acceso y guardar las capturas. |

## Ejecución

Se necesita MySQL 8.0.16 o superior y una conexión con permisos para crear la base, rutinas, cuentas y roles.

1. Ejecutar los archivos SQL en orden, del 01 al 06, desde la conexión de administrador.
2. Revisar los resultados de las consultas y los cierres.
3. Hacer las pruebas de las cuentas siguiendo la guía de `evidencias/`.

El archivo 01 borra y vuelve a crear `flotaya`. Para reiniciar el taller completo se vuelve a ejecutar desde ese archivo. El 04 también admite ejecutarse dos veces seguidas, antes de hacer las pruebas manuales de las cuentas.

Las sentencias que deben fallar están comentadas y llevan su código de error. Se ejecutan individualmente, en el lugar donde aparecen. La fecha de corte es el 23 de noviembre de 2026.

Los cierres de Ricardo, Paola y Carlos dan saldos de 60.000, 750.000 y 970.000. El cierre de Carlos se revierte completo. La auditoría termina con 0 inconsistencias, 1 contrato abierto y 16 pagos.

Las tres capturas de las cuentas quedan pendientes de tomar en Workbench.
