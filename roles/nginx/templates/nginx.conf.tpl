#From Ansible


#user  nobody;
worker_processes auto;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}

rtmp {
	server {
     	   listen 1935; # Listen on standard RTMP port
   	   chunk_size 4000;

           application live {
     	   live on;
   	   # Turn on HLS
           hls on;
           hls_path /mnt/hls/;
           hls_fragment 3;
     	   hls_playlist_length 60;
           # disable consuming the stream from nginx as rtmp
           allow play all;
           }
	}
}

http {
    include       mime.types;
    directio 512;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
    	listen	     443 ssl;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        ssl_certificate      MyCertificate.crt;
        ssl_certificate_key  MyKey.key;

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

	location /hls {
        # Disable cache
        add_header 'Cache-Control' 'no-cache';

        # CORS setup
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length';
	
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        types {
            application/dash+xml mpd;
	    application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }

        root /mnt/;
        }  


#        location / {
#            root   html;
#            index  index.html index.htm;
      }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
#        error_page   500 502 503 504  /50x.html;
#        location = /hls/50x.html {
#            root   html;
#        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
#    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


}

