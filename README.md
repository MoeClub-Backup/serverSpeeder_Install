-----------------------------   
#\#  serverSpeeder Install  \#                           
-----------------------------      
----------------------------- 
Debian 7.0 3.2.0-4
```
wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeser_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh
```
----------------------------- 
Nginx反代 (锐速检测许可证,嫌麻烦可不设置)
```
echo "$yourIP dl.serverspeeder.com" > /etc/hosts
```
```
	server {
		listen 80;
		server_name dl.serverspeeder.com;
		location /  {
			proxy_pass http://serverspeeder.azurewebsites.net;
		}
	}
```
