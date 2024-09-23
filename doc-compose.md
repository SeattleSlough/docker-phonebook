# docker-compose primer

## inputs

### images

bookstore-api   latest    9a6962bf40db   4 minutes ago   60.7MB
mysql           5.7       5107333e08a8   9 months ago    501MB

### network

books-net

### volume

mysql-volume

### database environment variables

MYSQL_ROOT_PASSWORD=abc123
MYSQL_DATABASE=bookstore_db
MYSQL_USER=clarusway
MYSQL_PASSWORD=Clarusway_1

## Docker Run

### database

docker run -d --name database --net books-net -v mysql-volume:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=abc123 -e MYSQL_DATABASE=bookstore_db -e MYSQL_USER=clarusway -e MYSQL_PASSWORD=Clarusway_1 mysql:5.7

### phonebook api

docker run -d --name bookstore --net books-net -p 80:80 bookstore-api

