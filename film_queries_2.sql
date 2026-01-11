/*Consultas SQL – Pantalla 2
En esta ventana se encuentran únicamente las consultas 18 a 36.
Para acceder al resto de las queries, por favor consultar el archivo film_queries_3*/



--18. Selecciona todos los nombres de las películas únicos.

select distinct f.title  as titulos_unicos
from film  f
order by f.title ;


/*19. Encuentra el título de las películas que son comedias y tienen una
duración mayor a 180 minutos en la tabla “film”*/

select  
    f.title as titulos_comedia,
    c.name as genero,
    f.length as duracion
from film f
join film_category fc 
    on fc.film_id = f.film_id
join category c 
    on fc.category_id = c.category_id
where c.name = 'Comedy'
  and f.length > 180
order by duracion asc;

.
/*20. Encuentra las categorías de películas que tienen un promedio de
duración superior a 110 minutos y muestra el nombre de la categoría
junto con el promedio de duración*/

select 
    c.name as categoria,
    round(avg(f.length), 2) as promedio_duracion
from film f
join film_category fc 
    on f.film_id = fc.film_id
join category c
    on fc.category_id = c.category_id
group by c.name
having avg(f.length) > 110
order by promedio_duracion desc;


--21. ¿Cuál es la media de duración del alquiler de las películas?

select round(avg(rental_duration ), 2) as prom_duracion_alquiler
from film;


--22. Crea una columna con el nombre y apellidos de todos los actores y actrices.

select first_name || ' ' || last_name as nombre_completo
from actor;

--23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.

select 
    date(rental_date) as fecha,
    count (*) as cantidad_alquileres
from rental
group by date (rental_date)
order by cantidad_alquileres desc;


--24. Encuentra las películas con una duración superior al promedio.

select 
    title as pelicula,               
    length as duracion,           
    round (length - (select avg(length) from film), 2) as diferencia_promedio  
from film
where length > (select avg(length) from film)  
order by duracion desc;



--25. Averigua el número de alquileres registrados por mes.
select
    to_char(r.rental_date, 'YYYY-MM') as periodo,
    count(*) as no_alquileres_reg
from
    rental r
group by
    to_char(r.rental_date, 'YYYY-MM')  -- Repetir la expresión x orden de ejecución
order by
    periodo;


--26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

select
    round(avg(total_pagado), 2) as prom_total_pagado,
    round(stddev(total_pagado), 2) as desv_estandar,
    round(variance(total_pagado), 2) as varianza
from (
    select
        customer_id,
        sum(amount) as total_pagado
    from
        payment
    group by
        customer_id
) as totales_por_cliente;


--27. ¿Qué películas se alquilan por encima del precio medio?
select 
	f.title as titulo,
	f.rental_rate as precio_alquiler
from film f 
where
    f.rental_rate  > (select AVG(rental_rate) from film)
order by
    f.rental_rate DESC,
    f.title;

--28. Muestra el id de los actores que hayan participado en más de 40 películas.
select
   actor_id ,
    COUNT (film_id ) as numero_peliculas
from
    film_actor
group by
    actor_id
having
    COUNT(film_id) > 40
order by
    numero_peliculas DESC,
    actor_id;



/*29. Obtener todas las películas y, si están disponibles en el inventario,
mostrar la cantidad disponible*/

select
    f.title as titulo_pelicula,
    coalesce (count(i.inventory_id), 0) as cantidad_disponible
from
    film f
left join
    inventory i on f.film_id = i.film_id
group by
    f.film_id,
    f.title
order by
    f.title;



--30. Obtener los actores y el número de películas en las que ha actuado.
select
    a.actor_id,
    a.first_name || ' ' || a.last_name as nombre_actor,
    count (fa.film_id) as numero_peliculas
from
    actor a
left join
    film_actor fa on a.actor_id = fa.actor_id
group by
    a.actor_id,
    a.first_name,
    a.last_name
order by
    numero_peliculas desc,
    nombre_actor;



/*31. Obtener todas las películas y mostrar los actores que han actuado en
ellas, incluso si algunas películas no tienen actores asociados*/

select 
    f.film_id as id , f.title as titulo_pelicula,
 	string_agg(a.first_name || ' ' || a.last_name, ', ' 
   order by a.first_name, a.last_name) as actores
from
    film f
left join
    film_actor fa on f.film_id = fa.film_id
left join
    actor a on fa.actor_id = a.actor_id
group by
    f.film_id,
    f.title
order by
    f.title;



/*32. Obtener todos los actores y mostrar las películas en las que han
actuado, incluso si algunos actores no han actuado en ninguna película*/


select 
    a.actor_id,
    a.first_name,
    a.last_name,
    f.title as pelicula
from 
    actor a
left join
    film_actor fa on a.actor_id = fa.actor_id
left join
    film f on fa.film_id = f.film_id
order by
    a.last_name, 
    a.first_name, 
    f.title;


--33. Obtener todas las películas que tenemos y todos los registros de alquiler
select  
    f.film_id,
    f.title as pelicula,
    i.inventory_id,
    r.rental_id,
    r.rental_date,
    r.return_date
from 
    film f
left join
    inventory i on f.film_id = i.film_id
left join 
    rental r on i.inventory_id = r.inventory_id
order by
    f.title,
    r.rental_date;


--34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as nombre_completo,
    sum(p.amount) as total_gastado
from
    customer c
join
    payment p on c.customer_id = p.customer_id
group by
    c.customer_id,
    concat(c.first_name, ' ', c.last_name)  -- repetimos la expresión porque el alias no existe aún en group by
order by
    total_gastado desc
limit 5;


--35. Selecciona todos los actores cuyo primer nombre es ' Johnny'.

select 
    actor_id,
    first_name,
    last_name
from 
    actor
where 
    first_name = 'JOHNNY'
order by 
    last_name;


--36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.

select  
    first_name as Nombre,
    last_name as Apellido,
    actor_id
from
    actor
order by 
    Apellido, 
    Nombre;
