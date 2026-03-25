#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    # ========== Оригинальный сервер localhost (можно оставить) ==========
    server {
        listen       80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    # ========== Сервер для glpi.upshepard.ru (HTTP → HTTPS) ==========
    server {
        listen 80;
        listen [::]:80;
        server_name glpi.upshepard.ru;
        return 301 https://$host$request_uri;
    }

    # ========== Сервер для glpi.upshepard.ru (HTTPS) ==========
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name glpi.upshepard.ru;

        ssl_certificate /etc/letsencrypt/live/glpi.upshepard.ru/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/glpi.upshepard.ru/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        access_log /var/log/nginx/glpi_access.log;
        error_log /var/log/nginx/glpi_error.log;

        # Статические файлы (отдаём напрямую для производительности)
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            root /var/www/glpi/public;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Прокси на Apache (порт 8080)
        location / {
            set $frontend_user $arg_user;
            if ($frontend_user = "") {
                set $frontend_user "post-only";
            }

            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-User $frontend_user;

            # Убираем X-Frame-Options, добавляем SameSite=None к кукам
            proxy_hide_header X-Frame-Options;
            proxy_cookie_flags ~ secure samesite=none;
        }

        # Прокси на Lisp-приложение (порт 11111) – например, /app/chat
        location /app/ {
            proxy_pass http://127.0.0.1:11111/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Запрет доступа к скрытым файлам
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}
root@glpi:/usr/local/openresty/nginx/conf# cat /usr/local/openresty/nginx/conf/nginx.conf
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    # ========== Оригинальный сервер localhost (можно оставить) ==========
    server {
        listen       80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    # ========== Сервер для glpi.upshepard.ru (HTTP → HTTPS) ==========
    server {
        listen 80;
        listen [::]:80;
        server_name glpi.upshepard.ru;
        return 301 https://$host$request_uri;
    }

    # ========== Сервер для glpi.upshepard.ru (HTTPS) ==========
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name glpi.upshepard.ru;

        ssl_certificate /etc/letsencrypt/live/glpi.upshepard.ru/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/glpi.upshepard.ru/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        access_log /var/log/nginx/glpi_access.log;
        error_log /var/log/nginx/glpi_error.log;

        # Статические файлы (отдаём напрямую для производительности)
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            root /var/www/glpi/public;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Прокси на Apache (порт 8080)
        location / {
            set $frontend_user $arg_user;
            if ($frontend_user = "") {
                set $frontend_user "post-only";
            }

            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-User $frontend_user;

            # Убираем X-Frame-Options, добавляем SameSite=None к кукам
            proxy_hide_header X-Frame-Options;
            proxy_cookie_flags ~ secure samesite=none;
        }

        # Прокси на Lisp-приложение (порт 11111) – например, /app/chat
        location /app/ {
            proxy_pass http://127.0.0.1:11111/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Запрет доступа к скрытым файлам
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}


<<
root@glpi:/home/administrator/clserv# cat /usr/local/openresty/nginx/conf/nginx.conf
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    # Shared memory for user sessions
    lua_shared_dict user_sessions 10m;

    # ========== Оригинальный сервер localhost (можно оставить) ==========
    server {
        listen       80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    # ========== Сервер для glpi.upshepard.ru (HTTP → HTTPS) ==========
    server {
        listen 80;
        listen [::]:80;
        server_name glpi.upshepard.ru;
        return 301 https://$host$request_uri;
    }

    # ========== Сервер для glpi.upshepard.ru (HTTPS) ==========
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name glpi.upshepard.ru;

        ssl_certificate /etc/letsencrypt/live/glpi.upshepard.ru/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/glpi.upshepard.ru/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        access_log /var/log/nginx/glpi_access.log;
        error_log /var/log/nginx/glpi_error.log;

        # Статические файлы (отдаём напрямую для производительности)
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            root /var/www/glpi/public;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Основной прокси на Apache (порт 8080)
        location / {
            access_by_lua_block {
                local user_sessions = ngx.shared.user_sessions
                local param_user = ngx.var.arg_user
                -- Декодируем параметр (преобразуем %40 в @ и т.п.)
                if param_user then
                    param_user = ngx.unescape_uri(param_user)
                end
                local session_cookie = ngx.var.cookie_openresty_session
                local final_user = nil

                if param_user and param_user ~= "" then
                    final_user = param_user
                    local session_id = ngx.md5(ngx.now() .. ngx.var.remote_addr .. ngx.var.http_user_agent)
                    user_sessions:set(session_id, final_user, 86400)
                    ngx.header["Set-Cookie"] = "openresty_session=" .. session_id ..
                        "; Path=/; Domain=.upshepard.ru; Max-Age=86400; Secure; SameSite=None"
                elseif session_cookie then
                    final_user = user_sessions:get(session_cookie)
                end

                if not final_user then
                    final_user = "post-only"
                end

                ngx.var.frontend_user = final_user

                -- Логирование (опционально)
                local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                local ip = ngx.var.remote_addr
                local log_line = timestamp .. " ip=" .. ip .. " user=" .. final_user .. " session=" .. (session_cookie or "") .. "\n"
                local file, err = io.open("/var/log/openresty/reqs.log", "a")
                if file then
                    file:write(log_line)
                    file:close()
                end
            }

            set $frontend_user "";
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-User $frontend_user;

            proxy_hide_header X-Frame-Options;
            proxy_set_header X-Frame-Options "";
            proxy_cookie_flags ~ secure samesite=none;
        }

        # Прокси на Lisp-приложение (порт 11111) – например, /app/chat
        location /app/ {
            proxy_pass http://127.0.0.1:11111/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Запрет доступа к скрытым файлам
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}



>>\




#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    # Shared memory for user sessions
    lua_shared_dict user_sessions 10m;

    # ========== Оригинальный сервер localhost (можно оставить) ==========
    server {
        listen       80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    # ========== Сервер для glpi.upshepard.ru (HTTP → HTTPS) ==========
    server {
        listen 80;
        listen [::]:80;
        server_name glpi.upshepard.ru;
        return 301 https://$host$request_uri;
    }

    # ========== Сервер для glpi.upshepard.ru (HTTPS) ==========
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name glpi.upshepard.ru;

        # Максимальный размер загружаемых файлов (100 МБ)
        client_max_body_size 100M;

        ssl_certificate /etc/letsencrypt/live/glpi.upshepard.ru/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/glpi.upshepard.ru/privkey.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        access_log /var/log/nginx/glpi_access.log;
        error_log /var/log/nginx/glpi_error.log;

        # Статические файлы (отдаём напрямую для производительности)
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            root /var/www/glpi/public;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Основной прокси на Apache (порт 8080)
        location / {
            access_by_lua_block {
                local user_sessions = ngx.shared.user_sessions
                local param_user = ngx.var.arg_user
                -- Декодируем параметр (преобразуем %40 в @ и т.п.)
                if param_user then
                    param_user = ngx.unescape_uri(param_user)
                end
                local session_cookie = ngx.var.cookie_openresty_session
                local final_user = nil

                if param_user and param_user ~= "" then
                    final_user = param_user
                    local session_id = ngx.md5(ngx.now() .. ngx.var.remote_addr .. ngx.var.http_user_agent)
                    user_sessions:set(session_id, final_user, 86400)
                    ngx.header["Set-Cookie"] = "openresty_session=" .. session_id ..
                        "; Path=/; Domain=.upshepard.ru; Max-Age=86400; Secure; SameSite=None"
                elseif session_cookie then
                    final_user = user_sessions:get(session_cookie)
                end

                if not final_user then
                    final_user = "post-only"
                end

                ngx.var.frontend_user = final_user

                -- Логирование (опционально)
                local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                local ip = ngx.var.remote_addr
                local log_line = timestamp .. " ip=" .. ip .. " user=" .. final_user .. " session=" .. (session_cookie or "") .. "\n"
                local file, err = io.open("/var/log/openresty/reqs.log", "a")
                if file then
                    file:write(log_line)
                    file:close()
                end
            }

            set $frontend_user "";
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-User $frontend_user;

            proxy_hide_header X-Frame-Options;
            proxy_set_header X-Frame-Options "";
            proxy_cookie_flags ~ secure samesite=none;
        }

        # Прокси на Lisp-приложение (порт 11111) – например, /app/chat
        location /app/ {
            proxy_pass http://127.0.0.1:11111/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Запрет доступа к скрытым файлам
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}