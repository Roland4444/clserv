server {
    listen 443 ssl;
    listen [::]:443 ssl; # Для поддержки IPv6

    server_name romach.space www.romach.space;
    ssl_certificate /etc/letsencrypt/live/romach.space/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/romach.space/privkey.pem; # managed by Certbot

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    client_max_body_size 50M;  # или нужный вам размер


    location / {
        proxy_pass http://127.0.0.1:11111;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }



}

server {
    server_name romach.space www.romach.space;

    return 301 https://$host$request_uri;

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/romach.space/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/romach.space/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}


server {
    if ($host = www.romach.space) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = romach.space) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;
    server_name romach.space www.romach.space;
    return 404; # managed by Certbot




}
