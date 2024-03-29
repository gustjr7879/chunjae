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



-- 윈도우 함수(window function)는 행과 행 간의 관계를 쉽게 정의한다. 분석함수나 순위함수로도 알려져있다.
-- 윈도우 함수는 다른 함수와 다르게 중첩해서 사용 못하지만 서브쿼리에는 이용 가능하다. 

select userid,mcode,start_timestamp,end_timestamp, learning_time, learning_seq, row_number() over 
(partition by userid order by start_timestamp asc) as _row_number,
rank() over (partition by userid order by start_timestamp asc) as _rank,
dense_rank() over (partition by userid order by start_timestamp asc) as _dense_rank,
percent_rank() over (partition by userid order by start_timestamp asc) as _percent_rank,
sum(learning_time) over (partition by userid order by start_timestamp asc) as _sum
from "text_biz_dw"."e_learning_time_proc" where concat(yyyy,mm,dd) = '20221201' order by userid asc, learning_seq asc limit 100;
-- yyyy mm dd가 20221201인 데이터에서 순위를 구하는데 특정범위(partition)에서 구한다.
-- rank : 유저 아이디 별로 timestamp가 높은 순대로 랭킹해준다.
-- dense_rank : rank와 유사하지만 동일한 순위를 하나의 건수로 취급
-- row_number : 동일한 값이라도 고유한 순위를 부여한다.
-- sum : sum함수를 사용해서 파티션 별 윈도우 합을 구할 수 있다. 같은 learning 타임 합



WITH 
    ym AS ( -- ym 을 202212 값인 변수로 선언
        VALUES (CHAR '202212')
    ),
    ymd AS (
        VALUES (CHAR '20221201') -- ymd를 20221201를 가지는 변수로 선언
    )
SELECT *
FROM ym;
-- 이와 같이 with은 변수나 테이블을 선언할 수 있다. 다른 테이블에서 가지고 와서 선언하는 것도 가능하다.

WITH 
    table1 AS (
        SELECT userid FROM "text_biz_dw"."e_member" WHERE CONCAT(yyyy, mm) = '202201' AND memberstatus_codename = '학습생(정)'
    ),
    table2 AS (
        SELECT userid FROM "text_biz_dw"."e_member" WHERE CONCAT(yyyy, mm) = '202212' AND memberstatus_codename = '학습생(정)'
    )
SELECT *
FROM table1;

-- 데이터 베이스에서 데이터를 가져와서 변수로 지정하는 예시





select * from text_biz_dw.e_content_meta as a
    inner join text_biz_dw.e_learning_time_proc as b on a.mcode = b.mcode
    inner join text_biz_dw.e_test as c on a.mcode = c.mcode
    inner join text_biz_dw.e_media as d on a.mcode = d.mcode
    inner join text_biz_dw.e_study as ee on a.mcode = ee.mcode
        where a.yyyy = '2022'
            and a.grade >2
limit 5;


-- 조건 1 grade가 2보다 큰 데이터
-- 조건 2 영상/문제풀이 둘다 제공되는 데이터 
-- 조건 3 22년도 
-- 실행 1 content 별 학습을 진행한 학생 수 
-- 실행 2 content 별 학습을 진행한 학생의 학년 평균
-- 실행 3 content 별 학습시간 
-- 실행 4 content 별 평가 문항 평균 개수 / 정답 문항 평균 개수 / 평가 점수 평균 
-- 학생회원의 학년 
-- 3학년 컨텐츠를 2학년이 했을수도 4학년이 했을 수도 

with
    
    a as (select * from (
        select a.mcode,a.grade,a.yyyy,a.mm, 
                                            case
                                                when a.mm in ('01','02','03') then  1
                                                when a.mm in ('04','05','06') then  2
                                                when a.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_content_meta as a -- 1번 조건 3번 조건
            where a.yyyy = '2022'
                and a.grade > 2 
                and a.grade < 7

            limit 500000
    ) as a where a.bungi = ?),

    b as ( select * from (
        select b.userid,b.mcode,b.yyyy,b.mm, case
                                                when b.mm in ('01','02','03') then  1
                                                when b.mm in ('04','05','06') then  2
                                                when b.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        
        from text_biz_dw.e_media as b -- 영상인지 판단
            where b.yyyy = '2022'
            limit 500000
    ) as b where b.bungi = ?),
    c as (select * from (
        select c.userid,c.mcode,c.system_learning_time,c.yyyy,c.mm, case
                                                when c.mm in ('01','02','03') then  1
                                                when c.mm in ('04','05','06') then  2
                                                when c.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_study as c -- 학습시간 
            where c.yyyy = '2022'
                and (c.system_learning_time is not null)
            limit 500000
    ) as c where c.bungi = ?),
    d as (select * from (
        select d.userid,d.mcode,d.score,d.item_count,d.correct_count,d.yyyy,d.mm, case
                                                when d.mm in ('01','02','03') then  1
                                                when d.mm in ('04','05','06') then  2
                                                when d.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_test as d -- 문제풀이 제공 판단
            where d.yyyy = '2022'
                and (d.score is not null)
                and (d.item_count is not null)
                and (d.correct_count is not null)
            limit 500000
    ) as d where d.bungi = ?),
    ee as ( 
        select b.mcode -- 문제풀이와 강의영상 모두 있는 content 
            from b 
            inner join d on b.mcode = d.mcode
            limit 500000
    ),
    f as ( 
        select ee.mcode from ee -- 1,2,3번 조건을 모두 충족하는 mcode만 
            inner join a on ee.mcode = a.mcode
        ),
    num_student as (
        select c.mcode,avg(c.bungi), count(c.userid) as num_student from c
            inner join f on c.mcode = f.mcode
        group by c.mcode
    ),
    content_time as ( 
        select c.mcode,avg(c.bungi), sum(c.system_learning_time) as _sum from c -- content 별 학습시간 
             inner join f on c.mcode = f.mcode
            group by c.mcode
    ),
    mean_grade as (
        select a.mcode,avg(a.bungi), avg(a.grade) as mean_grade from a
                inner join f on a.mcode = f.mcode
            group by a.mcode
    ),
    all_mean as ( 
        select d.mcode,avg(d.bungi), avg(d.item_count) as mean_count, -- 평가 문항 평균개수, 정답문항 평균개수, 평가점수 평균
            avg(d.correct_count) as mean_corr_count,
            avg(d.score) as mean_score
            from d
            inner join f on d.mcode = f.mcode
        group by d.mcode
    )
select * from all_mean limit 10;