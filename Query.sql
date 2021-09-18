CREATE INDEX members_names ON members (last_name, first_name);

CREATE INDEX authors_names ON authors (last_name, first_name);


-- کتاب‌های نشر چشمه که نویسنده ‌آن دولت آبادی نیست.
select title, isbn
from authors
         natural join books_authors
         natural join books
         natural join publishers
where name like 'چشمه'
    except
select title, isbn
from authors
         natural join books_authors
         natural join books
where last_name = 'دولت آبادی';

-- کتب ادبی
select distinct title, isbn
from books
where category like 'رمان خارجی'
union
select distinct title, isbn
from books
where category like 'داستان';

-- کتاب‌هایی که هم کتاب‌خانه‌های عمومی ساری و هم  کتاب‌خانه‌های عمومی بابل دارند
select title, isbn
from books_libraries
         natural join books
         natural join libraries
where city like 'بابل'
intersect
select title, isbn
from books_libraries
         natural join books
         natural join libraries
where city like 'ساری';


-- نام نویسندگانی که کتاب‌خانه رشت، کتابشان را موجود دارد
select distinct author
from (
         select (first_name || ' ' || last_name) as author, isbn
         from authors
                  natural join books_authors
                  natural join books
     ) q1
         natural join books_libraries
         natural join libraries
where city = 'رشت';

-- کتاب‌هایی که بابل دارد
select distinct title, isbn, name as library, total_quantity
from books
         natural join books_libraries
         natural join libraries
where city = 'بابل';

-- کتابی که همه‌ی کتاب‌خانه‌ها دارند
select distinct b1.title
from books b1
where not exists(
            (select l.library_id from libraries l)
            except
            (select b2.library_id from books_libraries b2 where b1.isbn = b2.isbn)
    );

-- کتابی که همه‌ی شهر‌ها دارند
select distinct b1.title
from books b1
where not exists(
        (select distinct city
         from books_libraries
                  natural join libraries)
        except
        (select b2.city
         from (books_libraries natural join libraries) b2
         where b1.isbn = b2.isbn)
    );

-- تعداد کتاب‌خانه‌های هر شهر
select city, count(*) count
from libraries
group by city
order by count;

--تعداد کل کتاب‌های هر شهر
select city, sum(total_quantity) total
from books_libraries
         natural join libraries
group by city
order by total;

--تعداد کل کتاب‌های هر کتاب‌خانه
select city, name, sum(total_quantity) total
from books_libraries
         natural join libraries
group by city, name
order by total;

-- کتاب‌خانه‌های که بیشترین کتاب را دارند
select a.city, a.name, sum(a.total_quantity)
from (books_libraries natural join libraries) a
group by city, name
having sum(a.total_quantity) = (select max(b.total)
                                from (
                                         select sum(total_quantity) total
                                         from books_libraries
                                                  natural join libraries
                                         group by library_id
                                     ) b
);

-- کتاب‌خانه‌های که کمترین کتاب را دارند
select a.city, a.name, sum(a.total_quantity)
from (books_libraries natural join libraries) a
group by city, name
having sum(a.total_quantity) = (select min(b.total)
                                from (
                                         select sum(total_quantity) total
                                         from books_libraries
                                                  natural join libraries
                                         group by library_id
                                     ) b
);

-- شهرهایی که حداقل یک کتاب‌خانه با ۷ کتاب دارند
select distinct l.city
from libraries l
where l.library_id in (select library_id from books_libraries group by library_id having sum(total_quantity) > 7);


-- افرادی که کتاب پس نیاوردند
select (first_name || ' ' || last_name) as member, phone_number, issue_date, title
from borrows
         natural join members
         natural join books_libraries
         natural join books
where returned_date is null;

-- افرادی که بعد از موعد کتاب را پس دادند
select (first_name || ' ' || last_name) as member, phone_number, issue_date, title
from borrows
         natural join members
         natural join books_libraries
         natural join books
where returned_date is not null
  and (issue_date + deadline_day) < returned_date;


-- افرادی که از موعد برگرداندن امانتشان گذشته و برنگرداندند
select (first_name || ' ' || last_name) as member, phone_number, issue_date, title
from borrows
         natural join members
         natural join books_libraries
         natural join books
where returned_date is null
  and (issue_date + deadline_day) < now();

--ادریس محمدی به کد ملی ۲۰۵۰۹۰۱۵۹۳ همه کتاب‌های امانتی‌اش را پس داد
update borrows
set returned_date = now()
where returned_date is null
  and member_id = '2050901593';

-- علی نعیمی طبیعی به کد ملی ۲۰۵۰۹۰۱۵۹۳ آخرین امانتش را تمدید کرد
update borrows
set deadline_day = deadline_day + 14
where issue_date = (select max(issue_date) from borrows where member_id = '2050901593')
  and member_id = '2050901593';

-- یک نفر یک کتاب من پیش از تو به کتاب‌خانه‌ی آزادگان ساری اهدا کرد که تعداد این کتاب باید به علاوه یک شود
update books_libraries
set total_quantity = total_quantity + 1
where isbn = '9786006605425'
  and library_id = 1;

-- شماره تلفن دریانی به کد ملی ۲۶۸۰۲۱۱۵۷۰ به ۰۹۹۹۹۸۷۱۳۷۷ تغییر کرده است.
update members
set phone_number = '09999871377'
where member_id = '2680211570';




------------------------------فاز نهایی---------------------


-- کتاب‌هایی که این کد ملی برنگردانده و از تاریخ بازگشت آن گذشت.
select *
from should_return('2050901593');

-- افرادی که باید کتاب‌های امانت گرفته شده این کتاب‌خانه را برگردانند.
select *
from members_should_return(5);

-- تعداد کتبی که کتاب‌خانه آزادگان ساری بازگردانده نشده است.
select count_not_turn_back(1);

-- تمدید دوهفته آخرین امانت این فرد
call extend('2050901593');

-- این کد ملی همه‌ی امانت‌هایش را پس داد
call return_all('2050901593');


select * from books_view;

