### Docker 실행
도커는 기본적으로 linux, ubuntu환경에서 진행된다.     
따라서 wsl을 실행시켜서 활용해야한다.     
```python
docker ps -a
```    
를 입력하게 되면 container id, image, command, created 등 실행중인 컨테이너에 대한 정보를 알 수 있다.

```python
docker run -p 8000:80 nginx
```     
nginx라는 이미지를 가지고 도커를 실행해라 라는 뜻이다.    

```python
docker rm [Name] 
```    
컨테이너 Name을 삭제하는 커맨드이다.     

```python
docker run -d -p 8000:80 --name nginx-container -t nginx
```     
nginx-container 라는 이름을 가진 컨테이너를 nginx 이미지를 가지고 생성하고, -d를 사용해서 로그 출력을 막아두고 실행한다.     
이렇게 한다면 나중에 컨테이너를 삭제하고 싶을 때 꼭 stop해줘야한다.    
```python
docker stop nginx-container
docker rm nginx-container
```     
하면 정상적으로 삭제할 수 있다.    

```python
docker images
```     
를 입력해서 어떤 이미지가 있는지 출력할 수 있다.    
