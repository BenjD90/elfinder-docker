# Doker container to serve elFinder lightly

Use :
 - [php 7 fpm](https://www.php.net/manual/fr/install.fpm.php)
 - [nginx](https://www.nginx.com/)
 - [elFinder](https://github.com/Studio-42/elFinder)

Add custom themes :
 - Material themes : https://github.com/RobiNN1/elFinder-Material-Theme
 - Dark Slim : https://github.com/johnfort/elFinder.themes

Fix classic bugs :
 - User privileges
 - Disable ftp network volumes

Php FPM + nginx from : https://github.com/TrafeX/docker-php-nginx

To run :

```sh
docker run -it --rm -p 8080:8080 -v `pwd`:/data -u 1000:1000 benjd90/elfinder
```

To build :
```sh
docker build -t benjd90/elfinder .
```
