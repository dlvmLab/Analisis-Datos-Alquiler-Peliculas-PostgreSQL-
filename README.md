
# 🎥 Análisis de Datos de Alquiler de Películas con PostgreSQL 🍿

Este proyecto consiste en un **análisis de datos con SQL** sobre una base de datos relacional que simula un sistema real de alquiler de películas.  

Se trabaja directamente sobre la base de datos entregada, **`bbdd_proyecto_films.sql`**, sin necesidad de crear tablas manualmente, extrayendo **insights de negocio** mediante consultas SQL avanzadas.

---

## 📌 Tabla de Contenido

- [Objetivos del Proyecto](#objetivos-del-proyecto)  
- [Estructura del Repositorio](#estructura-del-repositorio)  
- [Carga de la Base de Datos en DBeaver](#carga-de-la-base-de-datos-en-dbeaver)  
- [Conexión Minimalista a PostgreSQL](#conexión-minimalista-a-postgresql)  
- [Metodología de Trabajo](#metodología-de-trabajo)  
- [Consultas de Ejemplo](#consultas-de-ejemplo)  
  - [Consulta 11 – Antepenúltimo alquiler](#consulta-11--antepenultimo-alquiler)  
  - [Consulta 31 – Películas y actores](#consulta-31--peliculas-y-actores)  
  - [Consulta 52 – Películas alquiladas ≥10 veces](#consulta-52--peliculas-alquiladas-10-veces)  
  - [Consulta 48 – Número de películas por actor](#consulta-48--numero-de-peliculas-por-actor)  
  - [Consulta 60 – Clientes con ≥7 películas distintas](#consulta-60--clientes-con-7-peliculas-distintas)  
  - [Consulta 63 – Combinaciones de trabajadores y tiendas](#consulta-63--combinaciones-de-trabajadores-y-tiendas)  
- [Conclusiones](#conclusiones)  
- [Posibles Mejoras](#posibles-mejoras)  
- [Objetivos Alcanzados](#objetivos-alcanzados)  
- [Autora](#-autora)  

---

## Objetivos del Proyecto

- Analizar una base de datos relacional entregada (**`bbdd_proyecto_films.sql`**)  
- Practicar SQL intermedio y avanzado en PostgreSQL  
- Resolver preguntas de negocio reales  
- Documentar y presentar los resultados de manera profesional  
- Construir un proyecto completo para portafolio  

Las consultas incluidas muestran **distintas técnicas SQL** y su aplicabilidad para obtener información relevante de negocio.

---

## Estructura del Repositorio

```

├── bbdd_proyecto_films.sql       # Base de datos entregada completa
├── bbdd_films_public.png         # Captura del esquema entidad–relación
├── film_queries_1.sql            # Consultas de ejemplo (bloque 1)
├── film_queries_2.sql            # Consultas de ejemplo (bloque 2)
├── film_queries_3.sql            # Consultas de ejemplo (bloque 3)
├── film_queries_4.sql            # Consultas de ejemplo (bloque 4)
└── README.md                     # Documentación del proyecto

````

> Las consultas están fragmentadas por bloques para facilitar la lectura y ejecución progresiva.

---

## Carga de la Base de Datos en DBeaver

1. Crear una base de datos vacía en PostgreSQL:

```sql
CREATE DATABASE films;
````

2. Abrir **DBeaver**, conectarse a PostgreSQL y seleccionar la base de datos `films`.
3. Abrir el archivo **`bbdd_proyecto_films.sql`** y ejecutar todo el script.

> Todas las tablas y relaciones ya están definidas; no es necesario crearlas manualmente.

4. Verificar que las tablas y relaciones existen y que coinciden con `bbdd_films_public.png`.

---

## Conexión Minimalista a PostgreSQL

* **Host:** `localhost`
* **Puerto:** `5432`
* **Usuario:** tu usuario de PostgreSQL
* **Contraseña:** tu contraseña
* **Base de datos:** `films`

En **DBeaver**:

1. Abrir → Nueva conexión → PostgreSQL
2. Ingresar host, puerto, usuario y contraseña
3. Seleccionar la base de datos `films`
4. Testear conexión y conectar

> Esto permite ejecutar las consultas SQL directamente sobre la base de datos cargada (**`bbdd_proyecto_films.sql`**).

---

## Metodología de Trabajo

1. Analizar el esquema entidad–relación (`bbdd_films_public.png`).
2. Explorar las tablas y sus relaciones.
3. Formular preguntas de negocio para resolver mediante SQL.
4. Escribir consultas fragmentadas en bloques (`film_queries_X.sql`).
5. Documentar resultados y patrones encontrados.
6. Extraer conclusiones y recomendaciones.

---

## Consultas de Ejemplo

### Consulta 11 – Antepenúltimo alquiler

**Pregunta:**

> Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

```sql
select 
    concat(
        'Alquiler id: ', r.rental_id, 
        ' | Fecha: ', r.rental_date, 
        ' | Costo: $', p.amount
    ) as info_alquiler
from rental r
join payment p on r.rental_id = p.rental_id
order by r.rental_date desc
limit 1 offset 2;
```

**Explicación y objetivo:**

* `JOIN` une la tabla de alquileres (`rental`) con los pagos (`payment`) para conocer el valor exacto de cada alquiler.
* `ORDER BY r.rental_date DESC` organiza los alquileres de más recientes a más antiguos.
* `LIMIT 1 OFFSET 2` selecciona el **antepenúltimo registro** (el tercero contando desde el más reciente).
* Útil para auditoría puntual o verificar transacciones históricas.

---

### Consulta 31 – Películas y actores

**Pregunta:**

> Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.

```sql
select 
    f.film_id as id,
    f.title as titulo_pelicula,
    string_agg(
        a.first_name || ' ' || a.last_name, ', '
        order by a.first_name, a.last_name
    ) as actores
from film f
left join film_actor fa on f.film_id = fa.film_id
left join actor a on fa.actor_id = a.actor_id
group by f.film_id, f.title
order by f.title;
```

**Explicación y objetivo:**

* `LEFT JOIN` asegura que todas las películas aparezcan, aunque no tengan actores asignados.
* `string_agg` combina los nombres de los actores en una sola cadena separada por comas, ordenada alfabéticamente.
* Permite tener un listado completo de películas con sus actores, útil para inventario o reportes de catálogo.

---

### Consulta 52 – Películas alquiladas ≥10 veces

```sql
create temporary table peliculas_alquiladas as
select 
    f.film_id,
    f.title as titulo_pelicula,
    count(r.rental_id) as veces_alquilada
from film f
inner join inventory i on f.film_id = i.film_id
inner join rental r on i.inventory_id = r.inventory_id
group by f.film_id, f.title
having count(r.rental_id) >= 10
order by veces_alquilada desc;
```

**Explicación y objetivo:**

* Se crea una **tabla temporal** para no alterar la base de datos original.
* `INNER JOIN` conecta películas con inventario y alquileres, asegurando solo registros existentes.
* `HAVING count(r.rental_id) >= 10` filtra películas populares.
* Útil para análisis de ventas y marketing.

---

### Consulta 48 – Número de películas por actor

```sql
create view actor_num_peliculas as
select 
    a.first_name || ' ' || a.last_name as nombre_actor,
    count(fa.film_id) as cantidad_peliculas
from actor a
left join film_actor fa on a.actor_id = fa.actor_id
group by a.actor_id, a.first_name, a.last_name;
```

**Explicación y objetivo:**

* Crea una **vista** reutilizable.
* `LEFT JOIN` incluye actores sin películas asignadas.
* `COUNT(fa.film_id)` calcula la cantidad de películas por actor.
* Facilita análisis de participación y generación de informes.

---

### Consulta 60 – Clientes con ≥7 películas distintas

```sql
select 
    c.first_name,
    c.last_name
from customer c
join rental r on c.customer_id = r.customer_id
join inventory i on r.inventory_id = i.inventory_id
group by c.customer_id, c.first_name, c.last_name
having count(distinct i.film_id) >= 7
order by c.last_name;
```

**Explicación y objetivo:**

* `COUNT(DISTINCT i.film_id)` asegura contar **películas distintas** alquiladas por cliente.
* `HAVING` filtra los clientes frecuentes.
* Útil para identificar clientes leales y planificar estrategias de fidelización.

---

### Consulta 63 – Combinaciones de trabajadores y tiendas

```sql
select 
    s.staff_id,
    concat(s.first_name, ' ', s.last_name) as trabajador,
    st.store_id,
    c.city
from staff s
cross join store st
join address a on st.address_id = a.address_id
join city c on a.city_id = c.city_id;
```

**Explicación y objetivo:**

* `CROSS JOIN` genera todas las combinaciones posibles entre trabajadores y tiendas.
* `JOIN` con dirección y ciudad agrega contexto geográfico.
* Útil para asignación de recursos, planificación logística o análisis organizacional.

---

## Conclusiones

* Identificación de patrones de consumo y clientes de alto valor.
* Detección de películas y actores clave.
* SQL permite obtener insights sin depender de herramientas externas.

---

## Posibles Mejoras

* Añadir índices para optimización.
* Incorporar funciones de ventana.
* Visualizaciones externas (Power BI, Tableau).
* Automatización de reportes.
* Ampliar métricas financieras y de fidelización.

---

## Objetivos Alcanzados

✔ Comprensión de una base de datos entregada (**`bbdd_proyecto_films.sql`**)
✔ Uso avanzado de SQL (JOINs, agregaciones, vistas, tablas temporales)
✔ Documentación clara y profesional
✔ Proyecto completo listo para portafolio

---

## ✒ Autora

**Dayana Valdés**
📧 [dvm.focus@gmail.com](mailto:dvm.focus@gmail.com)
linkedin.com/in/dayanavm | github.com/dlvmLab

> **Proyecto realizado como parte del módulo SQL – Máster en Data & Analytics V3 – The PowerMBA**
> *Actualizado: 11 de enero de 2026*



