-- NoSQL (not only sql)이란 ? 
-- 키밸류(key value), 순차적 키밸류(ordered key value), 빅테이블(bigtable), 도큐먼트(document), 그래프(graph) 등 여러가지 방법들을 사용해서 데이터를 표현함. 점점 기본 sql의 영역을 침범하고 있음 ㅋㅋ
-- 읽기와 쓰기라는 기본적인 기능에 충실하다. 하지만 일관성과 ACID 트랜잭션은 잃어버릴 수 있다. 
-- 관계형 데이터베이스에서는 스키마로 강제하지만, NoSQL에서는 유연하게 스키마를 정의할 수 있어서,, 사용할 때 무결성 검증을 제대로 해야한다.

-- 이제부터 cli 단에서 모든 작업을 처리할 것이기 때문에 기본적인 powershell 사용법을 적어놓는다.
-- netstat -anp tcp | findstr "LISTENING" 은 tcp를 통해서 통신하는 포트들 중 Listening을 하고 있는 네트워크를 보여준다. 
-- mongodb를 원활하게 사용하기 위해서 환경변수를 설정해줘야한다.
-- window의 환경변수는 사용자변수/시스템변수가 있고 사용자변수는 윈도우의 유저, 시스템변수는 이 컴퓨터 자체에 등록해주는 것이다.
-- 환경변수를 등록해줘서 컴퓨터가 이제 경로를 찾을 수 있게 되었다. 어느 드라이브에서도 찾을 수 있기 때문에 드라이브를 옮겨다닐 때 편리하고 cli단에서 작업할 수 있게 되었다.
-- mongodb 의 컬렉션(collection)은 일종의 테이블이라고 생각하면 편하다.
-- vscode : control shift ` 하면 powershell이 열림 



use('yes24'); 
db.getCollection('bookcode'); 
db.bookcode.find({}); -- 찾기 (select)
-- relational : document
-- database : database
-- table : collection
-- row : document
-- column : field
-- primary key : primary key (_id)

--db.collection.insertOne() 와
--db.collection.insertMany() 는 다음과 같이 값을 추가할때 사용한다.
use('sample');
db.getCollection('inventory');
db.inventory.insertOne({_id:'hyunskki'});
db.inventory.find({}); -- select * from table;

--update는 구조를 그대로 두고 값을 update
--replace는 field의 구조 자체를 변경함
db.inventory.updateOne({_id:"hyunskki"},{$set : {id : "hyunskki3"}});
-- 위와같이 찾아서 값을 추가하거나 변경할 수 있다. _id의 경우 primary key이므로 안바꿔주는거같은데,,
db.inventory.find({}).count(); -- find하고 count한다.
db.inventory.find({'id':{$exists:true}}); -- 존재하는 것만 출력


db.inventory.updateOne({_id:"gustjr"},{$set : {id : "hyunskki"}});
db.inventory.find({'id':{$in :['hyunskki3','hyunskki']}}); -- in 뒤에 있는것 중 포함되면 출력
--조회하면 2개나옴 ㅎㅎ


-- redis 
-- ms에는 원래 안깔리지만 깃허브에서 깔 수 있음.
-- 깐 다음에 (환경변수는 설치과정에서 설정해줌) redis-cli를 사용해서 킬 수 있음
-- redis는 key와 value로 이루어져있다. 
set 'a' happyhyun -- 'a'의 value를 설정
get 'a' -- happyhyun이 가져와진다.
del 'a' -- 로 'a'를 지운다.
mset "a" "hyun" "b" "skki" -- 로 여러개 한번에 선언할 수 있음
get a -- hyun
get b -- skki
mget a b -- a와 b 다 가져옴 1) hyun 2) skki
keys * -- key 조회
-- 하지만 redis가 실행중에 이렇게 다 조회해버리면 서버가 key를 다 조회할때까지 멈춰버린다.
-- 따라서 scan명령으로 몇개씩 끊어서 조회해야함
lpush 'c' 'happy' 'hyun' -- key : c values : happy hyun
lrange c 0 -1 -- list를 조회할 때는 get을 사용해도 뭐가 안나옴 따라서 lrange key start end 로 조회할 수 있음.
rpush c 'good' -- list c의 오른쪽에 good을 집어넣음
lpop c -- list c의 왼쪽에서 pop
llen c -- list의 크기 조회
hset k a happy -- hash 선언 k의 a의 값은 happy이다.
hmset k b park c hyun -- k의 b는 park이고 c는 hyun이다
hget k a -- k의 a의 값을 보여줘라
hmget k a b c -- k의 a b c 값을 보여줘라