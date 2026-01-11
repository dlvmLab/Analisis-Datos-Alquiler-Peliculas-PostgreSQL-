/*Consultas SQL – Pantalla 4
En esta ventana se encuentran las consultas 55 a la 64.
Con estas consultas concluye el DataProject: LógicaConsultasSQL */


/*55. Encuentra el nombre y apellido de los actores que han actuado en
películas que se alquilaron después de que la película ‘Spartacus
Cheaper’ se alquilara por primera vez. Ordena los resultados
alfabéticamente por apellido*/

with
primer_alquiler_spartacus as (
    select min(r.rental_date) as fecha_primer_spartacus
    from film f
    join inventory i on f.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    where f.title = 'SPARTACUS CHEAPER'
),
alquileres_posteriores as (
    select r.inventory_id
    from rental r
    where r.rental_date > (select fecha_primer_spartacus from primer_alquiler_spartacus)
),
peliculas_alquiladas_despues as (
    select distinct f.film_id
    from inventory i
    join film f on i.film_id = f.film_id
    where i.inventory_id in (select inventory_id from alquileres_posteriores)
),
actores_final as (
    select a.first_name as nombre_actor,
           a.last_name  as apellido_actor
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    where fa.film_id in (select film_id from peliculas_alquiladas_despues)
)
select nombre_actor,
       apellido_actor
from actores_final
order by apellido_actor, nombre_actor;


5/*6. Encuentra el nombre y apellido de los actores que no han actuado en
ninguna película de la categoría ‘Music’*/

select a.first_name as nombre_actor,
       a.last_name  as apellido_actor
from actor a
where a.actor_id not in (
    select fa.actor_id
    from film_actor fa
    join film f on fa.film_id = f.film_id
    join film_category fc on f.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where c.name = 'Music'
)
order by apellido_actor, nombre_actor;
.
/*57. Encuentra el título de todas las películas que fueron alquiladas por más
de 8 días*/

select distinct f.title as titulo_pelicula
from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
where r.return_date is not null                          -- solo alquileres ya devueltos
  and r.return_date - r.rental_date > interval '8 days'   -- más de 8 días de alquiler
order by titulo_pelicula;


/*58. Encuentra el título de todas las películas que son de la misma categoría
que ‘Animation’*/
select f.title as titulo_pelicula
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
where c.name = 'Animation'
order by f.title;
.
/*59. Encuentra los nombres de las películas que tienen la misma duración
que la película con el título ‘Dancing Fever’. Ordena los resultados
alfabéticamente por título de película.*/

select f.title as titulo_pelicula
from film f
where f.length = (
    select f2.length
    from film f2
    where f2.title = 'DANCING FEVER'
)
order by f.title;

/*60. Encuentra los nombres de los clientes que han alquilado al menos 7
películas distintas. Ordena los resultados alfabéticamente por apellido*/

select 
    c.first_name as nombre,
    c.last_name as apellido
from 
    customer c
join 
    rental r on c.customer_id = r.customer_id
join 
    inventory i on r.inventory_id = i.inventory_id
group by 
    c.customer_id, c.first_name, c.last_name
having 
    count(distinct i.film_id) >= 7
order by 
    c.last_name asc, c.first_name asc;



/*61. Encuentra la cantidad total de películas alquiladas por categoría y
muestra el nombre de la categoría junto con el recuento de alquileres*/

select 
   c.category_id as id_cat, 
	c.name as categoria,
    count(r.rental_id) as total_alquileres
from 
    category c
join 
    film_category fc on c.category_id = fc.category_id
join 
    film f on fc.film_id = f.film_id
join 
    inventory i on f.film_id = i.film_id
join 
    rental r on i.inventory_id = r.inventory_id
group by 
    c.category_id, c.name
order by 
    total_alquileres desc, c.name asc;

--62. Encuentra el número de películas por categoría estrenadas en 2006.

select 
    c.name as categoria,
    count(f.film_id) as numero_peliculas
from 
    category c
join 
    film_category fc on c.category_id = fc.category_id
join 
    film f on fc.film_id = f.film_id
where 
    f.release_year = 2006
group by 
    c.category_id, c.name
order by 
    numero_peliculas desc;



/*63. Obtén todas las combinaciones posibles de trabajadores con las tiendas
que tenemos.*/

select 
    s.staff_id as id_trabajador,
    concat(s.first_name, ' ', s.last_name) as trabajador,
    st.store_id as id_tienda,
    a.address as direccion_tienda,
    c.city as ciudad
from 
    staff s
cross join 
    store st
inner join 
    address a on st.address_id = a.address_id
inner join 
    city c on a.city_id = c.city_id
order by 
    st.store_id,
    s.last_name,
    s.first_name;


/*64. Encuentra la cantidad total de películas alquiladas por cada cliente y
muestra el ID del cliente, su nombre y apellido junto con la cantidad de
películas alquiladas*/

select 
    c.customer_id as id_cliente,
    c.first_name as nombre,
    c.last_name as apellido,
    count(r.rental_id) as cantidad_alquileres
from 
    customer c
left join 
    rental r on c.customer_id = r.customer_id
group by 
    c.customer_id, c.first_name, c.last_name
order by 
    cantidad_alquileres desc, 
    c.last_name asc, 
    c.first_name asc;