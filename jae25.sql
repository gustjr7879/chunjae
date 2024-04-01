-- postgresql의 공식적인 데이터베이스는 pdadmin이다. (GUI)
-- CLI로 하는 방법은 sql shell으로 들어갈 수 있다. 
-- server는 127.0.0.1 (local host)
-- database 목록 \l (show databases)
-- database 접근 \c (use ***)
-- data목록 조회 \df
-- 이 강의에서는 gui로 dbeaver를 사용한다. (여러가지 지원하는 데이터베이스)
-- dbeaver에서 sql스크립트를 누르면 athena에서 했던 환경과 동일한 환경을 세팅할 수 있다. 


-- Create and Alter and drop 실습해보기 
-- 데이터를 정의한다 라는 말은
-- 데이터 베이스를 정의한다. 
-- 라는 말이 되면서 나중에 수정할 것 까지 모아서 data definition 이라고 한다.
-- create를 사용해서 table과 column을 정의할 수 있다.
-- alter를 사용해서 데이터 베이스와 컬럼의 속성을 변경할 수 있다. (alter table table_name alter column col_name type data_type;)
-- drop을 사용해서 table을 제거할 수 있다. (drop table table_name, truncate table table_name, delete from table_name)
-- drop을 사용해서 database를 제거할 수 있다. 

create table temp0 (col0 varchar, col1 int, col2 timestamp); -- table 정의
alter table temp0 add column col3 char(10); -- table 안에 column 정의
alter table temp0 drop column col3; -- table 안에 column제거 
alter table temp0 rename column col0 to text; -- table 안에 column 이름 재정의
alter table temp0 rename to temp1; -- table이름을 변경 
alter table temp1 alter column col1 type float; -- temp1의 column 중 col1의 type을 float로 변경 
drop table temp1; -- temp1을 제거 


create table today_study ( today char(8),
							summary varchar,
							note varchar); -- table과 각 컬럼 정의


alter table today_study add column idx int; -- column 추가 



insert into today_study(
				today, summary, note, idx) values (
													'20221230','orientation',' ',1); -- 값들을 추가
insert into today_study values ('20221230', '관련직무', '   ', 2)
    , ('20221230', '환경구성', '   ', 3)
    , ('20221230', '데이터의 위치', '     ', 3)
    , ('20221230', '데이터의 종류', '     ', 3)
; -- 여러가지 값 추가


create table today_study_bak as select * from today_study where 0=1; -- table 복사 (where은 false. 따라서 없다.)

insert into today_study_bak select * from today_study ; -- table 복사 전체 


update today_study set note = null where note = '   '; -- note에 '    '이 있다면 null로 세팅
delete from today_study where note = '     '; -- note '    '제거


delete from today_study ; -- today_study 틀은 남아있음 (row단위로 drop과 다름)
TRUNCATE TABLE today_study_bak; -- today_study_bak 틀은 남아있음 (row단위가 아닌 한번에)

-- 복습 
insert into today_study values ('fri','허깅페이스','딥러닝',1);-- insert into를 쓸 때 열 이름을 지정해줄 필요가 없음.

select * from today_study; 
alter table today_study alter column today type varchar; -- alter를 사용해서 재정의 가능
select * from today_study;

alter table today_study rename column today  to "오늘"; -- column rename을 하는 방법
select * from today_study;

update today_study set "오늘" = 'thus' where "오늘" = 'fri'; -- fri를 thus로 바꿔주기
select * from today_study;




with
    
    member as (
    select member.userid, member.grade, member.bungi from  ( -- member 테이블에서 유저 아이디, 학년 달을 가져옴
        select member.userid, member.grade, member.yyyy,member.mm, case
                                                when member.mm in ('01','02','03') then  1
                                                when member.mm in ('04','05','06') then  2
                                                when member.mm in ('07','08','09') then  3
                                                else 4 -- 달 기준으로 분기 나눠줌 
                                            end as bungi 
        from text_biz_dw.e_member as member 
            where member.yyyy = '2022' -- 실제 학년 데이터를 가져와야 하기 때문에 grade 제한 안걸어줌
                
            ) as member where member.bungi = ?),
    a as (
    select a.mcode  from ( -- meta data에서 학년과 2022년으로 설정해주고 grade를 가져와서 콘텐츠 타겟 학년으로 사용함
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
    ) as a where a.bungi = ?),

    b as ( select b.userid,b.mcode from ( -- media 활동이 있는 강의는 영상이 제공된다는 뜻이므로 영상인지 판단하는데 사용함 
        select b.userid,b.mcode,b.yyyy,b.mm, case
                                                when b.mm in ('01','02','03') then  1 -- 조건걸음
                                                when b.mm in ('04','05','06') then  2
                                                when b.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        
        from text_biz_dw.e_media as b 
            where b.yyyy = '2022'

    ) as b where b.bungi = ?),
    c as (select c.userid,c.mcode,c.system_learning_time,c.bungi from ( -- 학습시간을 얻기 위해서 사용함
        select c.userid,c.mcode,c.system_learning_time,c.yyyy,c.mm, case
                                                when c.mm in ('01','02','03') then  1
                                                when c.mm in ('04','05','06') then  2
                                                when c.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_study as c
            where c.yyyy = '2022'
                and (c.system_learning_time is not null) -- null 값 제거거

    ) as c where c.bungi = ?),
    d as (select d.mcode,d.score,d.item_count,d.correct_count,d.bungi  from ( -- score가 있다는 것이 문제풀이가 제공된다는 것이므로 사용
        select d.userid,d.mcode,d.score,d.item_count,d.correct_count,d.yyyy,d.mm, case
                                                when d.mm in ('01','02','03') then  1
                                                when d.mm in ('04','05','06') then  2
                                                when d.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_test as d 
            where d.yyyy = '2022'
                and (d.score is not null) -- null값 제거
                and (d.item_count is not null)
                and (d.correct_count is not null)
    ) as d where d.bungi = ?),
    ee as ( 
        select b.mcode,b.userid -- 문제풀이와 강의영상 모두 있는 content 
            from b 
            inner join d on b.mcode = d.mcode
    ),
    f as ( 
        select ee.mcode as mcode,ee.userid as userid from ee -- 1,2,3번 조건을 모두 충족하는 mcode만 
            inner join a on ee.mcode = a.mcode
        ),
    chk_user as (
        select f.userid  as userid, avg(member.grade) as grade from f 
            inner join member on f.userid = member.userid -- 모든 조건을 만족하는 유저들의 실제 학년 등록
        group by f.userid
    ),

    num_student as ( -- c(학습시간) 테이블에서 모든 조건 만족하는 user id의 count를 세줘서 content 별 학습을 진행한 학생 수 구함
        select c.mcode,avg(c.bungi) as bungi, count(c.userid) as num_student from c
            inner join f on c.mcode = f.mcode
        group by c.mcode
    ),
    content_time as ( -- c(학습시간) 테이블에서 모든 조건 만족하는 content의 system_learning_time 합계로 총 학습시간 
        select c.mcode,avg(c.bungi) as bungi, sum(c.system_learning_time) as _sum from c  
             inner join f on c.mcode = f.mcode
            group by c.mcode
    ),

    user_mean_grade as ( -- f(모든 조건 만족하는 user id와 mcode)테이블에서 chk_user(grade)와 비교해서 같다면 유저의 실제 학년 평균
        select f.mcode as mcode, avg(chk_user.grade) as user_mean_grade from f
            inner join chk_user on f.userid = chk_user.userid
        group by f.mcode
    ),
    all_mean as ( 
        select d.mcode,avg(d.bungi) as bungi, avg(d.item_count) as mean_count, -- 평가 문항 평균개수, 정답문항 평균개수, 평가점수 평균
            avg(d.correct_count) as mean_corr_count,
            avg(d.score) as mean_score
            from d
            inner join f on d.mcode = f.mcode
        group by d.mcode
    ),
    combined_results as (
        select 
            am.mcode,
            umg.user_mean_grade as user_mean_grade,
            ct._sum as total_learning_time,
            ns.num_student as num_student,
            am.mean_count as mean_count,
            am.mean_corr_count as mean_corr_count,
            am.mean_score as mean_score
        from 
            all_mean am
        inner join 
            user_mean_grade umg on am.mcode = umg.mcode
        inner join 
            content_time ct on am.mcode = ct.mcode
        inner join 
            num_student ns on am.mcode = ns.mcode
    )

select * from combined_results;





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
    member as (
    select  member.userid, max(member.grade) as grade, max(member.bungi) as bungi from  ( -- member 테이블에서 유저 아이디, 학년 달을 가져옴
        select member.userid, member.grade, member.yyyy,member.mm, case
                                                when member.mm in ('01','02','03') then  1
                                                when member.mm in ('04','05','06') then  2
                                                when member.mm in ('07','08','09') then  3
                                                else 4 -- 달 기준으로 분기 나눠줌 
                                            end as bungi 
        from text_biz_dw.e_member as member 
            where member.yyyy = '2022' -- 실제 학년 데이터를 가져와야 하기 때문에 grade 제한 안걸어줌
                
            ) as member where member.bungi = ? group by member.userid), -- ?는 파라미터 

    a as (
    select a.mcode  from ( -- meta data에서 학년과 2022년으로 설정해주고 grade를 가져와서 콘텐츠 타겟 학년으로 사용함
        select a.mcode,a.grade,a.yyyy,a.mm, 
                                            case
                                                when a.mm in ('01','02','03') then  1
                                                when a.mm in ('04','05','06') then  2
                                                when a.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_content_meta as a 
            where a.yyyy = '2022'
                and a.grade > 2 
                and a.grade < 7
    ) as a where a.bungi = ?),

    b as ( select b.userid,b.mcode from ( -- media 활동이 있는 강의는 영상이 제공된다는 뜻이므로 영상인지 판단하는데 사용함 
        select b.userid,b.mcode,b.yyyy,b.mm, case
                                                when b.mm in ('01','02','03') then  1 -- 조건걸음
                                                when b.mm in ('04','05','06') then  2
                                                when b.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        
        from text_biz_dw.e_media as b 
            where b.yyyy = '2022'

    ) as b where b.bungi = ?),
    c as (select c.userid,c.mcode,c.system_learning_time,c.bungi from ( -- 학습시간을 얻기 위해서 사용함
        select c.userid,c.mcode,c.system_learning_time,c.yyyy,c.mm, case
                                                when c.mm in ('01','02','03') then  1
                                                when c.mm in ('04','05','06') then  2
                                                when c.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_study as c
            where c.yyyy = '2022'
                and (c.system_learning_time is not null) -- null 값 제거거

    ) as c where c.bungi = ?),
    d as (select d.mcode,d.score,d.item_count,d.correct_count,d.bungi  from ( -- score가 있다는 것이 문제풀이가 제공된다는 것이므로 사용
        select d.userid,d.mcode,d.score,d.item_count,d.correct_count,d.yyyy,d.mm, case
                                                when d.mm in ('01','02','03') then  1
                                                when d.mm in ('04','05','06') then  2
                                                when d.mm in ('07','08','09') then  3
                                                else 4
                                            end as bungi
        from text_biz_dw.e_test as d 
            where d.yyyy = '2022'
                and (d.score is not null) -- null값 제거
                and (d.item_count is not null)
                and (d.correct_count is not null)
    ) as d where d.bungi = ?),
    ee as ( 
        select b.mcode, b.userid as userid -- 문제풀이를 제공하고 미디어 강의를 제공하는 것만 
            from b
        where b.mcode in (select d.mcode from d) -- join은 시간이 오래 걸려서 서브쿼리로 처리해줌 
    ),
    f as ( 
        select ee.mcode as mcode,ee.userid as userid from ee -- 동영상 + 문제풀이 + 3,4,5,6학년 타겟 정보 (모든조건)
            where ee.mcode in (select a.mcode from a)

        ),
    chk_user as (
        select f.userid  as userid, avg(member.grade) as grade from f 
        
            inner join member on f.userid = member.userid
             -- 모든 조건을 만족하는 유저들의 실제 학년 등록
        group by f.userid
    ),

    num_student as ( -- c(학습시간) 테이블에서 모든 조건 만족하는 user id의 count를 세줘서 content 별 학습을 진행한 학생 수 구함
        select c.mcode, count(c.userid) as num_student from c
            where c.mcode in (select f.mcode from f)
        group by c.mcode
    ),
    content_time as ( -- c(학습시간) 테이블에서 모든 조건 만족하는 content의 system_learning_time 합계로 총 학습시간 
        select c.mcode, sum(c.system_learning_time) as _sum from c  
            where c.mcode in (select f.mcode from f)
            group by c.mcode
    ),

    user_mean_grade as ( -- f(모든 조건 만족하는 user id와 mcode)테이블에서 chk_user(grade)와 비교해서 같다면 유저의 실제 학년 평균
        select f.mcode as mcode, avg(chk_user.grade) as user_mean_grade from f
            
            inner join chk_user on f.userid = chk_user.userid
        group by f.mcode
    ),
    all_mean as ( 
        select d.mcode,avg(d.bungi) as bungi, avg(d.item_count) as mean_count, -- 평가 문항 평균개수, 정답문항 평균개수, 평가점수 평균
            avg(d.correct_count) as mean_corr_count,
            avg(d.score) as mean_score
            from d
            where d.mcode in (select f.mcode from f)
        group by d.mcode
    ),
    combined_results as ( -- 전체 결과 테이블 반환 
        select 
            am.mcode,
            umg.user_mean_grade as user_mean_grade,
            ct._sum as total_learning_time,
            ns.num_student as num_student,
            am.mean_count as mean_count,
            am.mean_corr_count as mean_corr_count,
            am.mean_score as mean_score
        from 
            all_mean am
        inner join 
            user_mean_grade umg on am.mcode = umg.mcode
        inner join 
            content_time ct on am.mcode = ct.mcode
        inner join 
            num_student ns on am.mcode = ns.mcode
    )

select count(mcode) from combined_results;
