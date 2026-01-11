/*Consultas SQL – Pantalla 1
En esta ventana se encuentran únicamente las consultas 1 a 17.
Para acceder al resto de las queries, por favor consultar el archivo film_queries_2*/



--1. Crea el esquema de la BBDD.

--2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’

select 
    CONCAT(f.title, ' (Clasificación: ', f.rating, ')') AS pelicula_clasificacion
from film f
where f.rating = 'R'
order by f.title;

--3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

select  
    a.actor_id AS id_actor,
    CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo
from actor a
where a.actor_id between  30 and 40
order by a.actor_id;


--4. Obtén las películas cuyo idioma coincide con el idioma original.

select title AS nombre_película, f.original_language_id AS idioma_original
from film f 
where original_language_id is null ;


--5. Ordena las películas por duración de forma ascendente.
select f.title AS título_película, f.length AS duración
from film f 
order by f.length ASC ;

--6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.

select 
    CONCAT(a.first_name, ' ', a.last_name) AS nombre_completo
from actor a
where  a.last_name = 'ALLEN';


/*7. Encuentra la cantidad total de películas en cada clasificación 
de la tabla“film” y muestra la clasificación junto con el recuento*/

select rating, count(*) AS cant_total_peliculas
from film f 
group by f.rating 
order by cant_total_peliculas DESC;


/*8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una
duración mayor a 3 horas en la tabla film*/


select  
    CONCAT (title,'| Clasificación:', rating,'| Duración:',length,' min'
    ) AS detalle_pelicula
from  film
where rating = 'PG-13'
   or length > 180
order by length DESC;

--9. Encuentra la variabilidad de lo que costaría reemplazar las películas.
	
select
    ROUND(VARIANCE(replacement_cost), 4)   AS varianza,
    ROUND(STDDEV(replacement_cost), 4)     AS desviacion_tipica,
    ROUND(AVG(replacement_cost), 2)        AS costo_promedio_reemplazo,
    MIN(replacement_cost)                  AS costo_minimo,
    MAX(replacement_cost)                  AS costo_maximo
from film;

-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD

select
     (select CONCAT (title, ' | Duración: ', length, ' min') 
     from film 
     order by length DESC 
     limit 1) as pelicula_mas_larga,
     (select CONCAT (title, ' | Duración: ', length, ' min') 
     from film 
     order by length ASC 
     limit 1) as pelicula_mas_corta;

--2da opción 

select 
	MAX(f.length)as durac_max_minutos,
	MIN(f.length)as durac_min_minutos
from film f ;

--11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.


select 
    CONCAT(
        'Alquiler id: ', r.rental_id, 
        ' | Fecha: ', r.rental_date, 
        ' | Costo: $', p.amount
    ) as Info_alquiler
from rental r
join payment p on r.rental_id = p.rental_id
order by r.rental_date DESC
limit 1 offset 2;

/*12. Encuentra el título de las películas en la tabla “film” 
que no sean ni ‘NC-17' ni ‘G’ en cuanto a su clasificación*/

select 
    title AS titulo_pelicula, rating AS clasificacion
from film
where rating not in ('NC-17', 'G')
order by rating;


/*13. Encuentra el promedio de duración de las películas para cada
clasificación de la tabla film y muestra la clasificación junto con el
promedio de duración*/

select 
    f.rating as Clasificacion,
    round(avg(f.length), 2) AS promedio_duracion
from film f
group by f.rating
order by promedio_duracion DESC;

--14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.

select title AS Título_pelicula , length AS Duracion_pelicula
from film
where length > 180
order by length DESC;

--15. ¿Cuánto dinero ha generado en total la empresa?
select SUM(f.rental_rate ) as Ganancias_totales_empresa
from film f ;

--16. Muestra los 10 clientes con mayor valor de id.

select 
    c.customer_id AS id_cliente,
    CONCAT (c.first_name, ' ', c.last_name) AS nombre_completo
from customer c
order by c.customer_id DESC
limit 10;

/*17. Encuentra el nombre y apellido de los actores que aparecen en la
película con título ‘Egg Igby’*/

select  
    CONCAT(a.first_name, ' ', a.last_name) AS nombre_actor,
    f.title AS titulo_pelicula
from actor a
join film_actor fa ON a.actor_id = fa.actor_id
join film f ON fa.film_id = f.film_id
where f.title = 'EGG IGBY';


