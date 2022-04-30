# README

## Resume

La función principal de esta api es establecer la conexión con la base de datos "bsale_test", el cual está alojado en aws(Amazon Web Service), el controlador será el encargado en hacer las consultas respectivas a la base de datos. Esta api sera consumida por una app frontent, desarrollada en JavaScript vanila.

## Característica de la base de datos

- Motor: MySQL
- Host: mdb-test.c6vunyturrl6.us-west-1.rds.amazonaws.com
- Usuario: bsale_test
- Contraseña: bsale_test
- Nombre db: bsale_test

Debido a la caraterísticas de la base de datos necesitaremos usar la gema mysql2 (para más información, acceder al enlace: https://github.com/brianmario/mysql2 ) y realizar las configuraciones necesarias para hacer uso de ella.

1. Añadir `gem 'mysql2'` al archivo Gemfile.
2. Ir al archivo yml, `config/database.yml` y modificar los campos correspondientes, a las keys de test, develoment y production:

   ```
    adapter: mysql2
    encoding: utf8mb4
    database: <%= ENV['RDS_DB_NAME'] %>
    username: <%= ENV['RDS_USERNAME'] %>
    password: <%= ENV['RDS_PASSWORD'] %>
    host: <%= ENV['RDS_HOSTNAME'] %>
   ```

3. Podemos ir al controlador y generar las consultas que se requieran.

## ¿Cómo se realiza una consulta con Mysql2?

```
  client = Mysql2::Client.new(credentials)
  result = client.query(consulta).to_a
```

la consulta será de tipo SQL, por ejemplo `SELECT id, name FROM product`, en nuetro caso la información que se encuentra en la base de datos, está almacenada de esta forma:

### Tabla Product

| id  | name                 | url_image | price | discount | category_id |
| --- | -------------------- | --------- | ----- | -------- | ----------- |
| 5   | ENERGETICA MR BIG    | url       | 1490  | 20       | 1           |
| 6   | "ENERGETICA RED BULL | url       | 1490  | 0        | 1           |
| 7   | ENERGETICA SCORE     | url       | 1290  | 0        | 1           |

### Tabla Category

| id  | name              |
| --- | ----------------- |
| 1   | bebida energética |
| 2   | pisco             |

A este pundo se tienen dos manera de trabajar, la primera sería hacer el filtrado y el ordenamiento de productos directamente en las consultas, como por ejemplo:

1. si quisieramos obtener todos lo productos de la categoría, se tendría que hacer la consulta de es ta manera `SELECT * FROM product WHERE category_id == 1 ORDER BY name DESC`, lo anterior no solo filtraría, sino lo ordena. Incluso se podría hacer más fácil en términos de sintaxis con la ayuda de la gema pg (para más información revisar el enlace: https://github.com/ged/ruby-pg).
2. la segunda foma es obtener toda la información de la tablas y realizar el filtrado y ordenamiendo en la api misma y luego rederizarla como json.

En el proyecto actual se uso la segunda manera, extraemos la información de la tabla y luego hacemos el trabajo de filtrar y orderna.

`@categories = client.query("SELECT * FROM products").to_a`
`@categories = client.query("SELECT * FROM category").to_a`

Cómo se puede ver, adicionalmente se hace uso del método `to_a`, el cuál covertirá el resultado de la consulta en un array de hashes, que tiene la estructura de la siguiente forma:

```
[{"id"=>5,
  "name"=>"ENERGETICA MR BIG",
  "url_image"=>
   "https://dojiw2m9tvv09.cloudfront.net/11132/product/misterbig3308256.jpg",
  "price"=>1490.0,
  "discount"=>20,
  "category"=>1},
 {"id"=>6,
  "name"=>"ENERGETICA RED BULL",
  "url_image"=>
   "https://dojiw2m9tvv09.cloudfront.net/11132/product/redbull8381.jpg",
  "price"=>1490.0,
  "discount"=>0,
  "category"=>1},
 {"id"=>7,
  "name"=>"ENERGETICA SCORE",
  "url_image"=>
   "https://dojiw2m9tvv09.cloudfront.net/11132/product/logo7698.png",
  "price"=>1290.0,
  "discount"=>0,
  "category"=>1},
  ...
]
```

```
[
	{
		"id": 1,
		"name": "bebida energetica"
	},
	{
		"id": 2,
		"name": "pisco"
	},
	{
		"id": 3,
		"name": "ron"
	},
	{
		"id": 4,
		"name": "bebida"
	},
	{
		"id": 5,
		"name": "snack"
	},
	{
		"id": 6,
		"name": "cerveza"
	},
	{
		"id": 7,
		"name": "vodka"
	}
]
```

Con este tipo de estructura de datos se puede manipular como más nos convenga.

## Product Controller

Si bien es cierto que tenemos dos tablas, category y product, se podrían realizar dos controladores uno para cada tabla. Yo he decidido usar solo el controlador products debido a que de la tabla categoría solo podríamos hacer uso de la acción index, entonces esa acción la estoy considerando como una acción dentro del controller products y ya no sería necesario un controller para caregories.

El controller products está realizando las siguientes peticiones:

1. `index`: esta acción se encargará en devolver todos lo productos indistintamente de su categoría.

`GET /prouducts` devuelve: `[{producto 1}, {producto 2}, ... ,{producto n}]`

2.  `show`: esta acción se encargará en devolver un hash único, especificamente de un producto, según el id qué reciba.

    `GET /products/:product_id` devuelve:

         GET /products/35

    ```
    {
       "id": 35,
       "name": "ENERGETICA MAKKA DRINKS",
       "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/makka-drinks-250ml0455.jpg",
       "price": 1190.0,
       "discount": 0,
       "category": 1
       }
    ```

3.  `sort`: esta acción se encargará de ordenar segun los datos que reciba, ¿qué datos recibe? recibe el nombre de la columna por el cual se va realizar el ordenamiento, esto podría ser `name`, `price` y `discount`, ademá recibe el sentido del ordenamiento, el cual puede ser ascendente o descendente, en caso del `name` para ascendente recibirá `A-Z`, de lo contrario `Z-A`, y para `price` y `discount`; las abreviaciones `asc` y `desc`. Y tambien puede recibir el `category_id`, que es opcional, para que no regrese todos los productos ordenados sino de una categoría en específico.

- `GET /products/category/:category_id/:sort_by/:order`

       GET /products/category/4/price/desc

- `GET /products/:sort_by/:order`

       GET /products/name/asc

  `:category_id` recibe cualquier id, del 1 al 7 que pueda recibir, de recibir otro numero devolverá un error con el mensaje "`product doesn't exist or it was deleted`", con status `bad_request`.

  `:sort_by` puede ser `name`, `discount` o `price`

  `:order` toma valores `desc`, `asc`, `Z-A`, `A-Z`

4. `categories_products`: esta acción se encargará en devolver todas las categorías existentes.

- `GET /categories` devuelve:

```
[
	{
		"id": 1,
		"name": "bebida energetica"
	},
	{
		"id": 2,
		"name": "pisco"
	},
	{
		"id": 3,
		"name": "ron"
	},
	{
		"id": 4,
		"name": "bebida"
	},
	{
		"id": 5,
		"name": "snack"
	},
	{
		"id": 6,
		"name": "cerveza"
	},
	{
		"id": 7,
		"name": "vodka"
	}
]
```

5. `show_products_by_category`: esta acción devuelve solo los productos de una categoría, específicada por el `category_id` que recibe como dato.

`GET categories/:category_id` devuelve:

      GET categories/6

```
[
	{
		"id": 98,
		"name": "Cerveza Escudo Normal LATA 350CC",
		"url_image": "",
		"price": 600.0,
		"discount": 0,
		"category": 6
	},
	{
		"id": 99,
		"name": "Cerveza Escudo Sin Filtrar LATA 350CC",
		"url_image": "",
		"price": 800.0,
		"discount": 0,
		"category": 6
	}
]
```

6.  `clasification_types`: esta acción devuelve todas la modalidades de ordenamiento que puede realizar la api.

        GET product/cladification_types

    devuelve:

    ```
      [
        "name A-Z",
        "name Z-A",
        "price asc",
        "price desc",
        "discount asc",
        "discount desc"
      ]

    ```

7.  `search`: esta acción recibe el string que es lo que el usario intenta buscar entre los productos, recorré todos los productos buscando match con uno o más productos del array.

    `GET products/search/:search`

        GET products/search/papa

    devuelve:

    ```
    [
      {
        "id": 54,
        "name": "Papas Fritas Lisas Bolsa Grande",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/papaslisasgrande7128.jpg",
        "price": 1490.0,
        "discount": 0,
        "category": 5
      },
      {
        "id": 55,
        "name": "Papas Fritas Bolsa Pequeña",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/papaslisas7271.jpg",
        "price": 500.0,
        "discount": 0,
        "category": 5
      },
      {
        "id": 56,
        "name": "Papas Fritas Tarro",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/78028005335657432.jpg",
        "price": 1990.0,
        "discount": 0,
        "category": 5
      }
    ]
    ```

    Y para ordenar los productos que se ha buscado solo se tiene que añadir el parametro por el cual se va ha guiar para que se ordenen(`sort_by` = `name`, `price`, `discount`) y el sentido (`asc` o `desc`)

    `GET products/search/:search/:sort_by/:order`

        GET products/search/papa/price/desc

    devuelve:

    ```
    [
      {
        "id": 56,
        "name": "Papas Fritas Tarro",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/78028005335657432.jpg",
        "price": 1990.0,
        "discount": 0,
        "category": 5
      },
      {
        "id": 54,
        "name": "Papas Fritas Lisas Bolsa Grande",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/papaslisasgrande7128.jpg",
        "price": 1490.0,
        "discount": 0,
        "category": 5
      },
      {
        "id": 55,
        "name": "Papas Fritas Bolsa Pequeña",
        "url_image": "https://dojiw2m9tvv09.cloudfront.net/11132/product/papaslisas7271.jpg",
        "price": 500.0,
        "discount": 0,
        "category": 5
      }
    ]
    ```

## Keep Alive

Ya que la base de datos está configurado para cerrar la conexión luego de los 5 segundos de inactividad, se pensó en la solución de hacer que se genere una consulta a los 4 segundos de inactividad, para evitar que se cierre la conexión.

Buscando información me tope con un post(`https://dalibornasevic.com/posts/77-auto-reconnect-for-activerecord-connections`) del programdor `Dalibor Nasevic`(`https://github.com/dalibor`), la solución tiene un aproach similiar al que me plantie, el sugiere parchear la configuración del Mysql2, como se muestra más abajo, buscar reconectar automáticamente cada cierto intervalo, el cual debe ser inferior al tiempo en que se aborta la conexión o sea intervalos menores a 5 segundos.

```
module Mysql2AdapterPatch
def execute(*args)
 # During `reconnect!`, `Mysql2Adapter` first disconnect and set the
 # @connection to nil, and then tries to connect. When connect fails,
 # @connection will be left as nil value which will cause issues later.
 connect if @connection.nil?

 begin
   super(*args)
 rescue ActiveRecord::StatementInvalid => e
   if e.message =~ /server has gone away/i
     in_transaction = transaction_manager.current_transaction.open?
     try_reconnect
     in_transaction ? raise : retry
   else
     raise
   end
 end
end

private
def try_reconnect
 sleep_times = [0.1, 0.5, 1.5, 3, 4]

 begin
   reconnect!
 rescue Mysql2::Error => e
   sleep_time = sleep_times.shift
   if sleep_time && e.message =~ /can't connect/i
     warn "Server timed out, retrying in #{sleep_time} sec."
     sleep sleep_time
     retry
   else
     raise
   end
 end
end
end

require 'active_record/connection_adapters/mysql2_adapter'
ActiveRecord::ConnectionAdapters::Mysql2Adapter.prepend Mysql2AdapterPatch

```

Por mi parte seguiré investigando, para poder implementar mi propuesta.
