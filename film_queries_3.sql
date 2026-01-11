
/*Consultas SQL – Pantalla 3
En esta ventana se encuentran únicamente las consultas 37 a 54.
Para acceder al resto de las queries, por favor consultar el archivo film_queries_4*/


--37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

select
    min(actor_id) as id_mas_bajo,
    max(actor_id) as id_mas_alto
from
    actor;

--38. Cuenta cuántos actores hay en la tabla “actor”

select count(*) as total_actores
from actor;

--39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.

select a.actor_id, a.first_name, a.last_name
from actor a
order by a.last_name asc;


--40. Selecciona las primeras 5 películas de la tabla “film”

select title
from film
order by title
limit 5;


/*41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el
mismo nombre. ¿Cuál es el nombre más repetido?*/

select first_name, count(*) as cantidad
from actor
group by first_name
order by cantidad desc
limit 1;



--42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.

select r.rental_id, c.first_name, c.last_name, r.rental_date
from rental r
join customer c on r.customer_id = c.customer_id;



/*43. Muestra todos los clientes y sus alquileres si existen, incluyendo
aquellos que no tienen alquileres*/

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    r.rental_id,
    date(r.rental_date) as fecha   --elegimos fecha sin hora
from customer c
left join rental r on c.customer_id = r.customer_id
order by c.customer_id, r.rental_date;



/*44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor
esta consulta? ¿Por qué? Deja después de la consulta la contestación.*/

select f.film_id, 
	   f.title as titulo, 
	   c.category_id, 
	   c.name as nombre_categoria
from film f
cross join category c;

/*Esta consulta no es útil porque :
1-Combina todas las películas con todas las categorías sin filtrar.
2-Genera muchísimas filas que no reflejan relaciones reales.
3-No muestra qué categoría pertenece realmente a cada película.

La forma correcta sería unir las tablas a través de la tabla intermedia 
`film_category`, que relaciona cada película con sus categorías reales. 
Así se mostraría cada película junto únicamente con las categorías a las que 
pertenece, evitando combinaciones irrelevantes y filas innecesarias*/



--45. Encuentra los actores que han participado en películas de la categoría 'Action'

select distinct 
    a.actor_id, 
    a.first_name || ' ' || a.last_name as nombre_actor,
    c.category_id, 
    c."name" as nombre_categoria
from actor a
inner join film_actor fa on a.actor_id = fa.actor_id
inner join film f on fa.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
where c.name = 'Action'
order by  a.actor_id asc;


--46. Encuentra todos los actores que no han participado en películas.

select a.actor_id, a.first_name, a.last_name
from actor a
left join film_actor fa on a.actor_id = fa.actor_id
where fa.film_id is null
order by a.actor_id;



/*47. Selecciona el nombre de los actores y la cantidad de películas en las
que han participado*/

select 
    a.first_name || ' ' || a.last_name as nombre_actor,
    count(fa.film_id) as cantidad_peliculas
from actor a
left join film_actor fa on a.actor_id = fa.actor_id 
group by a.actor_id, a.first_name, a.last_name
order by cantidad_peliculas desc, nombre_actor;


/*48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres
de los actores y el número de películas en las que han participado.*/

create view actor_num_peliculas as
select 
    a.first_name || ' ' || a.last_name as nombre_actor,
    count(fa.film_id) as cantidad_peliculas
from actor a
left join film_actor fa on a.actor_id = fa.actor_id
group by a.actor_id, a.first_name, a.last_name;



--49. Calcula el número total de alquileres realizados por cada cliente.

select 
    c.customer_id,
    c.first_name || ' ' || c.last_name as nombre_cliente,
    count(r.rental_id) as total_alquileres
from 
    customer c
left join 
    rental r on c.customer_id = r.customer_id
group by 
    c.customer_id, c.first_name, c.last_name
order by 
    total_alquileres desc, nombre_cliente;


--50. Calcula la duración total de las películas en la categoría 'Action'.
select 
    sum(f.length) as duracion_total_minutos
from 
    film f
inner join 
    film_category fc on f.film_id = fc.film_id
inner join 
    category c on fc.category_id = c.category_id
where 
    c.name = 'Action';

/*51. Crea una tabla temporal llamada “cliente_rentas_temporal” para
almacenar el total de alquileres por cliente*/

create temporary table cliente_rentas_temporal as
select 
    c.customer_id,
    c.first_name || ' ' || c.last_name as nombre_cliente,
    count(r.rental_id) as total_alquileres
from 
    customer c
left join 
    rental r on c.customer_id = r.customer_id
group by 
    c.customer_id, c.first_name, c.last_name
order by 
    total_alquileres desc;

--consulta--
select * from cliente_rentas_temporal;


/*52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las
películas que han sido alquiladas al menos 10 veces*/

create temporary table peliculas_alquiladas as
select 
    f.film_id,
    f.title as titulo_pelicula,
    count(r.rental_id) as veces_alquilada
from 
    film f
inner join 
    inventory i on f.film_id = i.film_id
inner join 
    rental r on i.inventory_id = r.inventory_id
group by 
    f.film_id, f.title
having 
    count(r.rental_id) >= 10
order by 
    veces_alquilada desc, titulo_pelicula;

-- consulta--
select * from peliculas_alquiladas;


/*53. Encuentra el título de las películas que han sido alquiladas por el cliente
con el nombre ‘Tammy Sanders’ y que aún no se han devuelto. Ordena
los resultados alfabéticamente por título de película.*/

select 
    f.title as titulo_pelicula
from 
    customer c
inner join 
    rental r on c.customer_id = r.customer_id
inner join 
    inventory i on r.inventory_id = i.inventory_id
inner join 
    film f on i.film_id = f.film_id
where 
    c.first_name = 'TAMMY' 
    and c.last_name = 'SANDERS'
    and r.return_date is null
order by 
    f.title;


/*54. Encuentra los nombres de los actores que han actuado en al menos una
película que pertenece a la categoría ‘Sci-Fi’. Ordena los resultados
alfabéticamente por apellido.*/

select 
    a.first_name || ' ' || a.last_name as nombre_completo
from 
    actor a
inner join 
    film_actor fa on a.actor_id = fa.actor_id
inner join 
    film f on fa.film_id = f.film_id
inner join 
    film_category fc on f.film_id = fc.film_id
inner join 
    category c on fc.category_id = c.category_id
where 
    c.name = 'Sci-Fi'
order by 
    nombre_completo  asc;
