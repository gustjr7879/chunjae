-- AWS athena 기준으로 작성된 쿼리문입니다.

select 1,2,1+2; --컬럼이 생성되는 것을 확인할 수 있다.
select 'a','b',concat('a','b');
select current_date, cast('2022-09-01' as date);
select current_timestamp, cast('2022-09-01' as timestamp); -- cast는 데이터 타입을 지정해준다. 이를 통해서 데이터 타입을 맞춰줄 수 있다.
select 1>2; -- boolean타입으로 지정된다.
select 'A' in ('A','B','C'); -- boolean타입으로 지정된다.

-- 이처럼 select는 단독으로도 사용 가능하다. 


select * from "text_biz_dw"."e_point" limit 10;
-- 데이터 베이스와 테이블, 컬럼은 "" 큰따옴표로 표시한다.
-- 데이터 베이스와 테이블은 위와 같이 .으로 구분해서 불러올 수 있다.
-- 데이터 베이스를 꼭 지정해줘야한다. (여러개의 데이터베이스가 존재할 수 있다.)
select "datestamp[active]" from "text_biz_dw"."e_point" limit 10;

select * from "text_biz_dm"."learning_analytics_user" limit 10;

select userid, * from "text_biz_dm"."learning_analytics_user" limit 10;
-- 위와 같이 하면 userid가 새로운 열로 추가가 된 상태로 나타나게 된다.

-- where 는 조건문이다.
--  between : a부터 b의 범위내에서 데이터 선택
-- in : in (a,b,c,...) : in 뒤의 목록에 포함된 데이터 선택
-- like : 특정 문자열이 포함된 데이터를 선택
select * from "text_biz_dm"."learning_analytics_user" 
where 1 = 1 
    and yyyy = '2022'
    and mm = '08'
    and gender != 'X'
    and grade_codename in ('키즈','초1','초2')
    and memberstatus_change like '-%'
    and postalcode is not null;
-- 1=1은 모든 조건으 true인 조건문이고 이쁘게 쓰려고 사용함.
-- and조건이 많으면 쿼리문이 잘 작동하는지 확인하기 힘들다. 따라서 count 데이터를 해줌으로서 잘 작동하는지 확인할 수 있다. 


select * from "text_biz_dw"."e_test"
where credate between cast('2022-08-01' as timestamp) and cast('2022-08-02' as timestamp);
-- credate가 저 사이인 행들을 뽑아줌


SELECT * 
FROM "text_biz_dw"."e_learning_time_proc"
WHERE 1 = 1
    AND yyyy = '2022'
    AND mm = '08'
    AND (mcode IS NULL OR LENGTH(TRIM(mcode)) < 1)
;
-- sql에는 trim이라는 공백제거 방법이 있다. ltrim rtrim 도 존재한다.

select length('    '), length(trim('    '));
-- 를 하면 4, 0이 출력된다. 
-- 즉 값이 없는 것을 확인하는건데 mcode not like '_%' 와 같이 사용할 수도 있다.


-- group by : select선언부에는 group by에 사용된 컬럼과 그룹함수만 선언 가능
-- group by 이후 having을 사용해서 출력 결과에 대한 조건을 지정할 수 있다. 
select subject_name, grade , count(study_count) as "차시학습 개수",
sum(study_count) as "학습 진행 횟수",
sum(study_completed_count) as "학습완료 개수",
sum(study_notcompleted_count) as "학습미완료 개수",
round(sum(cast(study_completed_count as double))/sum(cast(study_count as double))*100, 2) as "학습 완료율" 
from "text_biz_dm"."learning_analytics_content" where 1= 1
and concat(yyyy,mm) = '202208'
and subject_name = '수학'
and grade between 1 and 6
group by subject_name, grade having round(sum(cast(study_completed_count as double))/sum(cast(study_count as double))*100,2) < 95;

-- AS : 데이터에 별명을 지정
-- LIMIT : 몇개 출력할것인지 지정
-- DISTINCT : 중복 제거
-- if : 조건
-- case : 다수의 조건 만들기

select gender, case 
                when gender = 'M' then 'male'
                when gender = 'F' then 'female'
                else 'no_data'
                end as "성별"
from "text_biz_dm"."learning_analytics_user" limit 10;

select now(); -- 현재 날짜와 시간 반환해줌
select abs(-3); -- 절대값 반환해줌
select ceiling(3.4); -- 정수로 올림해서 반환
select floor(3.4); -- 정수로 내림
select round(3.444,2); -- 소수점 반올림
select week(now()); -- 일년의 몇번째 주인지 알려줌
select hour(now()); -- now의 시간이 몇시인지 알려줌
select minute(now()); -- 몇분인지 나타냄
select minute(now()) + 1 as "일분뒤";
select now() as "현재", -- ''로 뭘 더해줄지 정하고, 뒤에 더해줄 값을 정하고 어디에 더할지 작성해준다.
    date_add('year',1,now()),
    date_add('quarter',1,now()),
    date_add('month',1,now()),
    date_add('week',1,now()),
    date_add('day',1,now()),
    date_add('hour',1,now())