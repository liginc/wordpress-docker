# wordpress-docker

Web Server Docker Images for Wordpress built using [_Wordpress Boilerplate for Frontplate CLI_](https://github.com/liginc/wordpress-frontplate)

## Tags

- `noinit`: Images with `noinit` tag suffix do NOT attempt to install WordPress at initial launch.

### php7.2

- **Apache + PHP 7.2**: `1.3.0-php7.2-apache`, `php7.2-apache`, `php7.2`, `latest` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.2/apache/Dockerfile))
- **Apache + PHP 7.2 (noinit)**: `1.3.0-php7.2-apache-noinit`, `php7.2-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.2/apache-noinit/Dockerfile))

### php7.1

- **Apache + PHP 7.1**: `1.2.1-php7.1-apache`, `php7.1-apache`, `php7.1` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.1/apache/Dockerfile))
- **Apache + PHP 7.1 (noinit)**: `1.2.1-php7.1-apache-noinit`, `php7.1-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.1/apache-noinit/Dockerfile))

### php7.0

- **Apache + PHP 7.0**: `1.3.0-php7.0-apache`, `php7.0-apache`, `php7.0` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.0/apache/Dockerfile))
- **Apache + PHP 7.0 (noinit)**: `1.3.0-php7.0-apache-noinit`, `php7.0-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php7.0/apache-noinit/Dockerfile))

### php5.6

- **Apache + PHP 5.6**: `1.2.1-php5.6-apache`, `php5.6-apache`, `php5.6` ([source](https://github.com/liginc/wordpress-docker/blob/master/php5.6/apache/Dockerfile))
- **Apache + PHP 5.6 (noinit)**: `1.2.1-php5.6-apache-noinit`, `php5.6-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php5.6/apache-noinit/Dockerfile))

### php5.5

- **Apache + PHP 5.5**: `1.3.0-php5.5-apache`, `php5.5-apache`, `php5.5` ([source](https://github.com/liginc/wordpress-docker/blob/master/php5.5/apache/Dockerfile))
- **Apache + PHP 5.5 (noinit)**: `1.3.0-php5.5-apache-noinit`, `php5.5-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php5.5/apache-noinit/Dockerfile))

### php5.3

- **CentOS + Apache + PHP 5.3 (noinit)**: `1.4.0-php5.3-centos-apache-noinit`, `php5.3-centos-apache-noinit` ([source](https://github.com/liginc/wordpress-docker/blob/master/php5.3/centos-apache-noinit/Dockerfile))

## Usage

Use this Docker image to serve WordPress PHP files and static resources.

Note that you need MySQL database externally.

Following sample is how you could simply launch the environment using Docker Compose.

```yaml
# Sample docker-compose.yml
version: '2'
services:
  wordpress:
    image: liginccojp/wordpress:1.3.0-php7.2-apache-noinit
    mem_limit: 256m
    depends_on:
      - mysql
    ports:
      - 80:80
    links:
      - mysql:mysql
    volumes:
      - ./wp:/var/www/html
  mysql:
    image: mysql:8
    mem_limit: 256m
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: password
    ports:
      - 3306:3306
    volumes:
      - ./sql:/docker-entrypoint-initdb.d:rw
```

## Maintainer

- [ktogo](https://github.com/ktogo)
