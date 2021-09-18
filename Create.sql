----------------------
----- Drop table------
----------------------
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS members CASCADE;
DROP TABLE IF EXISTS books_authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS libraries CASCADE;
DROP TABLE IF EXISTS books_libraries CASCADE;
DROP TABLE IF EXISTS borrows CASCADE;


CREATE TABLE authors
(
    author_id  SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name  VARCHAR(30)
);

CREATE TABLE publishers
(
    publisher_id SERIAL PRIMARY KEY,
    name         VARCHAR(40) UNIQUE NOT NULL,
    address      VARCHAR(150)       NOT NULL
);

CREATE TABLE books
(
    --isbn13 format: xxx-xx-xxxxx-xx-x
    --isbn10 format: x-xxx-xxxxx-x
    isbn         VARCHAR PRIMARY KEY NOT NULL,
    title        VARCHAR(100)        NOT NULL,
    category     VARCHAR(100)        NOT NULL,
    edition      INT                 NOT NULL,
    publisher_id SERIAL REFERENCES publishers (publisher_id) ON DELETE CASCADE
);

CREATE TABLE books_authors
(
    books_authors_id SERIAL PRIMARY KEY,
    isbn             VARCHAR REFERENCES books (isbn) ON DELETE CASCADE,
    author_id        SERIAL REFERENCES authors (author_id) ON DELETE CASCADE
);


CREATE TABLE members
(
    member_id               VARCHAR(10) PRIMARY KEY,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    email                   VARCHAR(100) NOT NULL,
    phone_number            VARCHAR(11)  NOT NULL,
    number_of_books_allowed INT          NOT NULL
);


CREATE TABLE libraries
(
    library_id SERIAL PRIMARY KEY,
    name       VARCHAR(40)  NOT NULL,
    city       VARCHAR(40)  NOT NULL,
    address    VARCHAR(150) NOT NULL
);

CREATE TABLE books_libraries
(
    books_libraries_id SERIAL PRIMARY KEY,
    location           VARCHAR NOT NULL,
    total_quantity     INT     NOT NULL,
    isbn               VARCHAR REFERENCES books (isbn) ON DELETE CASCADE,
    library_id         SERIAL REFERENCES libraries (library_id) ON DELETE CASCADE
);


CREATE TABLE borrows
(
    borrow_id          SERIAL PRIMARY KEY,
    issue_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    deadline_day       INT  NOT NULL,
    returned_date      DATE,
    member_id          VARCHAR(10) REFERENCES members (member_id) ON DELETE CASCADE,
    books_libraries_id SERIAL REFERENCES books_libraries (books_libraries_id) ON DELETE CASCADE
);
-------------------------------------------------------------------
------------------------------ UDF --------------------------------
-------------------------------------------------------------------
DROP FUNCTION IF EXISTS should_return(character varying);
DROP FUNCTION IF EXISTS members_should_return(library int);
DROP FUNCTION IF EXISTS count_not_turn_back(library int);


-- کتاب‌هایی که این کد ملی برنگردانده و از تاریخ بازگشت آن گذشت.
CREATE OR REPLACE FUNCTION should_return(member VARCHAR)
    RETURNS TABLE
            (
                title    VARCHAR,
                library  VARCHAR,
                city     VARCHAR,
                deadline DATE
            )
    LANGUAGE 'plpgsql'
AS
$$
BEGIN
    RETURN QUERY SELECT books.title,
                        libraries.name,
                        libraries.city,
                        (borrows.issue_date + borrows.deadline_day) AS deadline
                 FROM borrows
                          NATURAL JOIN books_libraries
                          NATURAL JOIN books
                          NATURAL JOIN libraries
                 WHERE borrows.member_id = member
                   and borrows.returned_date is null
                   and (borrows.issue_date + borrows.deadline_day) < now();
END;
$$;

-- تعداد کتاب‌هایی که از کتاب‌خانه امانت گرفته شده و برگردانده نشده.
CREATE OR REPLACE FUNCTION count_not_turn_back(library int)
    RETURNS int
    LANGUAGE 'plpgsql'
AS
$$
DECLARE
    counter INTEGER;
BEGIN
    SELECT count(*)
    INTO counter
    FROM borrows
             NATURAL JOIN books_libraries
             NATURAL JOIN books
    WHERE books_libraries.library_id = library
      and borrows.returned_date is null;
    return counter;
END;
$$;

-- افرادی که باید کتاب‌های امانت گرفته شده این کتاب‌خانه را برگردانند.
CREATE OR REPLACE FUNCTION members_should_return(library int)
    RETURNS TABLE
            (
                id           VARCHAR,
                name         TEXT,
                phone_number VARCHAR,
                title        VARCHAR,
                deadline     DATE
            )
    LANGUAGE 'plpgsql'
AS
$$
BEGIN
    RETURN QUERY SELECT members.member_id,
                        (members.first_name || ' ' || members.last_name) as member_name,
                        members.phone_number,
                        books.title,
                        (borrows.issue_date + borrows.deadline_day)      AS deadline
                 FROM borrows
                          NATURAL JOIN books_libraries
                          NATURAL JOIN books
                          NATURAL JOIN libraries
                          NATURAL JOIN members
                 WHERE books_libraries.library_id = library
                   and borrows.returned_date is null
                   and (borrows.issue_date + borrows.deadline_day) < now();
END;
$$;

-------------------------------------------------------------------
------------------------------ SP ---------------------------------
-------------------------------------------------------------------

-- تمدید دوهفته آخرین امانت این فرد
CREATE OR REPLACE PROCEDURE extend(member VARCHAR)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE borrows
    SET deadline_day = deadline_day + 14
    WHERE issue_date = (select max(issue_date) FROM borrows WHERE member_id = member)
      AND member_id = member;
    COMMIT;
END;
$$;

-- این فرد همه‌ی امانت‌هایش را پس داد
CREATE OR REPLACE PROCEDURE return_all(member VARCHAR)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE borrows
    SET returned_date = now()
    WHERE returned_date is null
      and member_id = member;
    COMMIT;
END;
$$;

-------------------------------------------------------------------
------------------------- Trigger ---------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS books_allowed_audits CASCADE;
DROP TABLE IF EXISTS members_name_audits CASCADE;

CREATE TABLE books_allowed_audits
(
    id                          SERIAL PRIMARY KEY,
    member_id                   VARCHAR(10)  NOT NULL,
    old_number_of_books_allowed INT          NOT NULL,
    new_number_of_books_allowed INT          NOT NULL,
    changed_on                  TIMESTAMP(6) NOT NULL
);

CREATE TABLE members_name_audits
(
    id         SERIAL PRIMARY KEY,
    member_id  VARCHAR(10)  NOT NULL,
    old_name   TEXT,
    new_name   TEXT,
    changed_on TIMESTAMP(6) NOT NULL
);

DROP FUNCTION IF EXISTS log_books_allowed_changes();
DROP FUNCTION IF EXISTS log_members_name_changes();
DROP FUNCTION IF EXISTS member_id_checker();
DROP FUNCTION IF EXISTS is_isbn();
DROP FUNCTION IF EXISTS is_email();


CREATE OR REPLACE FUNCTION log_books_allowed_changes()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF NEW.number_of_books_allowed <> OLD.number_of_books_allowed THEN
        INSERT INTO books_allowed_audits(id, member_id, old_number_of_books_allowed, new_number_of_books_allowed,
                                         changed_on)
        VALUES (default, OLD.member_id, OLD.number_of_books_allowed, NEW.number_of_books_allowed, now());
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION log_members_name_changes()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF (OLD.first_name || ' ' || OLD.last_name) <> (NEW.first_name || ' ' || NEW.last_name) THEN
        INSERT INTO members_name_audits(id, member_id, old_name, new_name, changed_on)
        VALUES (default, OLD.member_id, (OLD.first_name || ' ' || OLD.last_name),
                (NEW.first_name || ' ' || NEW.last_name), now());
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION member_id_checker()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF NEW.member_id ~ '^\d{10}$' THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'The ID of member is not valid';
END ;
$$;

CREATE OR REPLACE FUNCTION is_isbn()
    RETURNS TRIGGER AS
$$
DECLARE
    tmp NUMERIC DEFAULT 11;
BEGIN
    --isbn10 format: x-xxx-xxxxx-x
    -- tmp is 11-remainder, so last char should equal tmp
    IF (length(new.isbn) = 13)
    THEN
        tmp = (11 - (
                            substr(NEW.isbn, 1, 1) :: NUMERIC * 10 +
                            substr(NEW.isbn, 3, 1) :: NUMERIC * 9 +
                            substr(NEW.isbn, 4, 1) :: NUMERIC * 8 +
                            substr(NEW.isbn, 5, 1) :: NUMERIC * 7 +
                            substr(NEW.isbn, 7, 1) :: NUMERIC * 6 +
                            substr(NEW.isbn, 8, 1) :: NUMERIC * 5 +
                            substr(NEW.isbn, 9, 1) :: NUMERIC * 4 +
                            substr(NEW.isbn, 10, 1) :: NUMERIC * 3 +
                            substr(NEW.isbn, 11, 1) :: NUMERIC * 2)
            % 11) % 11;

    END IF;

    --isbn13 format: xxx-xx-xxxxx-xx-x
    IF ((length(NEW.isbn) = 17
        AND (
                    substr(NEW.isbn, 1, 1) :: NUMERIC +
                    substr(NEW.isbn, 2, 1) :: NUMERIC * 3 +
                    substr(NEW.isbn, 3, 1) :: NUMERIC +
                    substr(NEW.isbn, 5, 1) :: NUMERIC * 3 +
                    substr(NEW.isbn, 6, 1) :: NUMERIC +
                    substr(NEW.isbn, 8, 1) :: NUMERIC * 3 +
                    substr(NEW.isbn, 9, 1) :: NUMERIC +
                    substr(NEW.isbn, 10, 1) :: NUMERIC * 3 +
                    substr(NEW.isbn, 11, 1) :: NUMERIC +
                    substr(NEW.isbn, 12, 1) :: NUMERIC * 3 +
                    substr(NEW.isbn, 14, 1) :: NUMERIC +
                    substr(NEW.isbn, 15, 1) :: NUMERIC * 3)
                % 10 = substr(NEW.isbn, 17, 1) :: NUMERIC)
        OR (length(new.isbn) = 13
            AND ((tmp = 10 AND substr(new.isbn, 13, 1) = 'X'
                     )
                OR tmp = substr(NEW.isbn, 13, 1) :: NUMERIC))
        )
    THEN
        RETURN NEW;
    END IF;
    RAISE EXCEPTION 'INVALID ISBN';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_email()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF NEW.email ~ '/^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/' THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'The Email of member is not valid';
END ;
$$;

DROP TRIGGER  IF EXISTS books_allowed_changes ON members CASCADE;
DROP TRIGGER  IF EXISTS members_name_changes ON members CASCADE;
DROP TRIGGER  IF EXISTS member_id_check ON members CASCADE;
DROP TRIGGER  IF EXISTS isbn_check ON books CASCADE;
DROP TRIGGER  IF EXISTS member_email_check ON members CASCADE;

CREATE TRIGGER books_allowed_changes
    BEFORE UPDATE
    ON members
    FOR EACH ROW
EXECUTE PROCEDURE log_books_allowed_changes();

CREATE TRIGGER members_name_changes
    BEFORE UPDATE
    ON members
    FOR EACH ROW
EXECUTE PROCEDURE log_members_name_changes();

CREATE TRIGGER member_id_check
    BEFORE INSERT OR UPDATE
    ON members
    FOR EACH ROW
EXECUTE PROCEDURE member_id_checker();

CREATE TRIGGER isbn_check
    BEFORE INSERT OR UPDATE
    ON books
    FOR EACH ROW
EXECUTE PROCEDURE is_isbn();

CREATE TRIGGER member_email_check
    BEFORE INSERT OR UPDATE
    ON members
    FOR EACH ROW
EXECUTE PROCEDURE is_email();
-------------------------------------------------------------------
-------------------------- cursor ---------------------------------
-------------------------------------------------------------------

-- ساخت چسباندن لیست نویسنده‌های یک کتاب با جدا کننده ویرگول

DROP FUNCTION IF EXISTS authors_of_book(text VARCHAR) CASCADE ;

CREATE OR REPLACE FUNCTION authors_of_book( text VARCHAR )
	RETURNS TEXT AS $$
	DECLARE temp TEXT;
	DECLARE d_row RECORD;
	DECLARE c CURSOR FOR (SELECT * FROM books_authors NATURAL JOIN authors WHERE books_authors.isbn=text);

BEGIN
	OPEN c;
	temp = '';
	LOOP
		FETCH c INTO d_row;
		IF NOT FOUND THEN EXIT; END IF;
        temp = temp || d_row.first_name || ' ' || d_row.last_name || ', ';
	END LOOP;
	CLOSE c;

    RETURN substring(temp from 1 for char_length(temp)-2);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------
------------------------- transaction -----------------------------
-------------------------------------------------------------------

--تغییر اسم و فامیلی در یک تراکنش
BEGIN TRANSACTION;
UPDATE members
SET first_name = 'علی'
WHERE member_id = '2050901593';
UPDATE members
SET last_name = 'محمدی'
WHERE member_id = '2050901593';
COMMIT;

--تغییر موقعیت و تعداد یک کتاب در یک تراکنش
BEGIN TRANSACTION;
UPDATE books_libraries
SET location = 'جای جدید'
WHERE books_libraries_id = 1;
UPDATE books_libraries
SET total_quantity = 10
WHERE books_libraries_id = 1;
COMMIT;

ROLLBACK;
-------------------------------------------------------------------
---------------------------- View ---------------------------------
-------------------------------------------------------------------
DROP VIEW IF EXISTS books_view;
DROP VIEW IF EXISTS get_authors;

CREATE OR REPLACE VIEW books_view AS (
  SELECT
    isbn,
    title,
    category,
    (SELECT name FROM publishers where books.publisher_id = publishers.publisher_id) AS publisher,
    authors_of_book(isbn) as authors
  FROM books
  ORDER BY title
);

CREATE OR REPLACE VIEW get_authors AS(
SELECT  author_id , (first_name || ' ' || last_name) as name FROM authors);


