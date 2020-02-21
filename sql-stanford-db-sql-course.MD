# DB SQL 

**Stanford University** https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/course/

reference https://github.com/MathWay/db_course_stanford_winter2013/tree/master/06_SQL 


## Movie-Rating Query Exercises 
- Movie ( mID, title, year, director )
- Reviewer ( rID, name )
- Rating ( rID, mID, stars, ratingDate )

1. Find the names of all reviewers who rated Gone with the Wind. 

```SQL
select distinct name
from Reviewer join Rating using (rid)
where mid in (select mid 
              from movie 
              where title = 'Gone with the Wind')
```

2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 

```SQL
select name, title, stars
from movie join reviewer join rating using (rid, mid)
where name = director
```

3. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

```SQL
select name
from (select name
      from reviewer
      union
      select title
      from movie)
order by name
```

4. Find the titles of all movies not reviewed by Chris Jackson. 

```SQL
select title
from movie
where not mid in (select mid 
                  from rating
                  where rid = (select rid 
                               from reviewer 
                               where name = 'Chris Jackson'))
```

5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 

```SQL
select distinct (select name 
                 from reviewer 
                 where rid = r1.rid) as n1, 
                 (select name 
                  from reviewer 
                  where rid = r2.rid)
from rating r1 join rating r2 using (mid)
where r1.rid <> r2.rid and (select name 
                            from reviewer 
                            where r1.rid = rid) < (select name 
                                                   from reviewer 
                                                   where rid = r2.rid)
order by n1
```

6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 

```SQL
select name, title, stars
from movie join reviewer join rating using (mid, rid)
where stars in (select min(stars) 
                from rating)
```

7. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

```SQL
select title, max(stars)-min(stars) as spread
from rating join movie using (mid)
group by mid
order by spread desc, title
```


8. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

```SQL
select (select avg(av)
        from (select mid, year, avg(stars) as av 
              from rating join movie using(mid) 
              group by mid) 
        where year<1980) 
     - (select avg(av)
        from (select mid, year, avg(stars) as av 
              from rating join movie using(mid) 
              group by mid) 
        where year>1980)
```


9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 

```SQL
select title, director 
from movie 
where director in (select director 
                   from movie 
                   group by director 
                   having count(*)>1) 
order by director, title
```


10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 

```SQL
select title, av
from (select title, avg(stars) as av 
      from rating join movie using(mid) 
      group by mid) a
where av in (select max(av) 
             from (select title, avg(stars) as av 
                   from rating join movie using(mid) 
                   group by mid))
```


11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 

```SQL
select title, av
from (select title, avg(stars) as av 
      from rating join movie using(mid) 
      group by mid)
where av in (select min(av) 
             from (select title, avg(stars) as av 
                   from rating join movie using(mid) 
                   group by mid))
```


12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 

```SQL
select distinct director, title, stars
from (movie join rating using(mid)) m
where stars in (select max(stars) 
                from rating join movie using (mid) 
                where m.director = director)
```


## Social-Network Query Exercises
- Highschooler ( ID, name, grade )
- Friend ( ID1, ID2 ) -- Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 
- Likes ( ID1, ID2 ) -- Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present.


1. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 

```SQL
select (select name from Highschooler where id=l1.id1), 
       (select grade from Highschooler where id=l1.id1), 
       (select name from Highschooler where id=l1.id2), 
       (select grade from Highschooler where id=l1.id2), 
       (select name from Highschooler where id=l2.id2), 
       (select grade from Highschooler where id=l2.id2)
from likes l1 join likes l2  on l1.id2=l2.id1
where l1.id1 <> l2.id2
```

2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 

```SQL
select name, grade
from Highschooler h1
where not grade in (select grade 
                    from (Highschooler h2 join friend on h2.id=id1) a 
                    where a.id2=h1.id)
```

3. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 

```SQL
select (select name from Highschooler where id=id1), 
       (select grade from Highschooler where id=id1), 
       (select name from Highschooler where id=id2), 
       (select grade from Highschooler where id=id2)
from likes
where id2 not in (select id1 from likes)
```


4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 

```SQL
select name, grade
from Highschooler
where id not in (select id1 from likes union select id2 from likes)
order by grade, name
```


5. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 

```SQL
SELECT ha.name, ha.grade,  hb.name, hb.grade, hc.name, hc.grade 
FROM highschooler ha, highschooler hb, highschooler hc
WHERE ha.id IN (SELECT f.id1 FROM friend f WHERE f.id2 = hc.id) 
    AND hb.id IN (SELECT f.id2 FROM friend f WHERE f.id1 = hc.id)
    AND hb.id IN (SELECT l.id2 FROM likes l WHERE l.id1 = ha.id) 
    AND hb.id NOT IN (SELECT f.id2 FROM friend f WHERE f.id1 = ha.id);  
```


6. Find the name and grade of all students who are liked by more than one other student.  

```SQL
select h.name, h.grade 
from highschooler h 
join (
    select id2 
    from likes 
    group by id2
    having count(id1) >1) ll
    on ll.id2 = h.id ; 
```


7. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 

```SQL
select count(*)
from (select * from friend where id1 = (select id from Highschooler where name = 'Cassandra')) a
     join
     (select * from friend) b on a.id2=b.id1
```


8. Find the name and grade of the student(s) with the greatest number of friends. 

```SQL
select name, grade
from (select id1 as id, count(*) as c 
      from friend 
      group by id1) join Highschooler using (id)
where c = (select max(c) 
           from (select id1, count(*) as c 
                 from friend 
                 group by id1))
```

## Data manipulation language

1. Add the reviewer Roger Ebert to your database, with an rID of 209. 

```SQL
insert into Reviewer values (209, 'Roger Ebert')
```


2. Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 

```SQL
insert into rating 
select rid, mid, 5, null
from reviewer, movie
where name='James Cameron'
```

3. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.) 

```SQL
update movie
set year = year+25
where mid in (select mid 
              from rating 
              group by mid 
              having avg(stars) >=4)
```


4. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars. 

```SQL
delete from rating
where mid in (select mid 
              from movie 
              where year<1970 or year>2000) 
      and stars <4
```


1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler. 

```SQL
delete from Highschooler
where grade =12
```


2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. 

```SQL
delete from likes
where id1 in (select likes.id1 
              from friend join likes using (id1) 
              where friend.id2 = likes.id2) 
      and not id2 in (select likes.id1 
                      from friend join likes using (id1) 
                      where friend.id2 = likes.id2)
```


3. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. 

```SQL
insert into friend
select f1.id1, f2.id2
from friend f1 join friend f2 on f1.id2 = f2.id1
where f1.id1 <> f2.id2
except
select * from friend
```
---

```SQL
insert into friend 
select distinct f1.id1, f2.id2
from friend f1, friend f2 
where f1.id2 = f2.id1 and f1.id1 <> f2.id2 
and not f1.id1 in (select f3.id1 from friend f3 where f3.id2 = f2.id2);
```
