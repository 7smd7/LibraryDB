TRUNCATE authors CASCADE;
TRUNCATE publishers CASCADE;
TRUNCATE books CASCADE;
TRUNCATE members CASCADE;
TRUNCATE books_authors CASCADE;
TRUNCATE libraries CASCADE;
TRUNCATE books_libraries CASCADE;
TRUNCATE borrows CASCADE;

ALTER SEQUENCE authors_author_id_seq RESTART;
ALTER SEQUENCE publishers_publisher_id_seq RESTART;
ALTER SEQUENCE books_authors_books_authors_id_seq RESTART;
ALTER SEQUENCE libraries_library_id_seq RESTART;
ALTER SEQUENCE books_libraries_books_libraries_id_seq RESTART;
ALTER SEQUENCE borrows_borrow_id_seq RESTART;


INSERT INTO authors
VALUES (DEFAULT, 'رولف', 'دوبلی');
INSERT INTO authors
VALUES (DEFAULT, 'جوجو', 'مویز');
INSERT INTO authors
VALUES (DEFAULT, 'محمود', 'دولت آبادی');
INSERT INTO authors
VALUES (DEFAULT, 'مریم', 'مفتاحی');
INSERT INTO authors
VALUES (DEFAULT, 'عادل', 'فردوسی‌پور');
INSERT INTO authors
VALUES (DEFAULT, 'سارا', 'میتلند');
INSERT INTO authors
VALUES (DEFAULT, 'سما', 'قرایی');
INSERT INTO authors
VALUES (DEFAULT, 'نادیا', 'فغانی');
INSERT INTO authors
VALUES (DEFAULT, 'کریستوفر', 'همیلتون');

INSERT INTO publishers
VALUES (DEFAULT, 'چشمه', 'تهران، خ. انقلاب، خ. ابوریحان، خ. وحید نظری، پ. 35');
INSERT INTO publishers
VALUES (DEFAULT, 'هنوز', 'تهران، سعادت آباد، شهرک بوعلی، بلوک 501، ط. 8، ش. 39');
INSERT INTO publishers
VALUES (DEFAULT, 'آموت', 'تهران، خ. انقلاب، خ. لبافی نژاد، نرسیده به کارگر، ک. درخشان، پ. 3، واحد. 3');

INSERT INTO books
VALUES ('9786006605425', 'من پیش از تو', 'رمان خارجی', 4, 3);
INSERT INTO books
VALUES ('9786003840188', 'من پس از تو', 'رمان خارجی', 5, 3);
INSERT INTO books
VALUES ('9786002295224', 'هنر شفاف اندیشیدن', 'توسعه فردی', 2, 1);
INSERT INTO books
VALUES ('9786002299628', 'هنر خوب زندگی کردن', 'توسعه فردی', 3, 1);
INSERT INTO books
VALUES ('9786002290854', 'میم و آن دیگران', 'داستان', 1, 1);
INSERT INTO books
VALUES ('9789643625283', 'نون نوشتن', 'داستان', 4, 1);
INSERT INTO books
VALUES ('9786006047003', 'چگونه از تنهایی لذت ببریم', 'توسعه فردی', 1, 2);
INSERT INTO books
VALUES ('9786229558799', 'مصیبت‌های عاشق بودن', 'توسعه فردی', 1, 2);
INSERT INTO books
VALUES ('9786006047539', 'چگونه رنج بکشیم', 'توسعه فردی', 1, 2);


INSERT INTO books_authors
VALUES (DEFAULT, '9786006605425', 2);
INSERT INTO books_authors
VALUES (DEFAULT, '9786006605425', 4);
INSERT INTO books_authors
VALUES (DEFAULT, '9786003840188', 2);
INSERT INTO books_authors
VALUES (DEFAULT, '9786003840188', 4);
INSERT INTO books_authors
VALUES (DEFAULT, '9786002295224', 1);
INSERT INTO books_authors
VALUES (DEFAULT, '9786002295224', 5);
INSERT INTO books_authors
VALUES (DEFAULT, '9786002299628', 1);
INSERT INTO books_authors
VALUES (DEFAULT, '9786002299628', 5);
INSERT INTO books_authors
VALUES (DEFAULT, '9786002290854', 3);
INSERT INTO books_authors
VALUES (DEFAULT, '9789643625283', 3);
INSERT INTO books_authors
VALUES (DEFAULT, '9786006047003', 6);
INSERT INTO books_authors
VALUES (DEFAULT, '9786006047003', 7);
INSERT INTO books_authors
VALUES (DEFAULT, '9786229558799', 8);
INSERT INTO books_authors
VALUES (DEFAULT, '9786006047539', 7);
INSERT INTO books_authors
VALUES (DEFAULT, '9786006047539', 9);


INSERT INTO libraries
VALUES (DEFAULT, 'آزادگان', 'ساری', 'خیابان فرهنگ، کوچه سعدی');
INSERT INTO libraries
VALUES (DEFAULT, 'ابن شهرآشوب', 'ساری', 'خیابان نادر، کوچه شهید مشهدی');
INSERT INTO libraries
VALUES (DEFAULT, 'امام حسن مجتبي', 'رشت', 'خيابان اسد آبادي، داخل پارك');
INSERT INTO libraries
VALUES (DEFAULT, 'امام رضا', 'رشت', 'خيابان رسالت، پارك كشاورز');
INSERT INTO libraries
VALUES (DEFAULT, 'آیت الله روحانی', 'بابل', 'خیابان مدرس ،خیابان روحانی');
INSERT INTO libraries
VALUES (DEFAULT, 'امامزاده یحیی', 'بابل', 'سبزه میدان، فرهنگ ۵، جنب اداره پست');


INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۱', 2, '9786006605425', 1);
INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۱', 3, '9786006605425', 3);
INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۱', 1, '9786006605425', 5);

INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۲', 3, '9786003840188', 1);
INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۲', 4, '9786003840188', 3);
INSERT INTO books_libraries
VALUES (DEFAULT, 'رخ-۲', 2, '9786003840188', 5);

INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۱', 1, '9786002295224', 2);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۱', 2, '9786002295224', 4);

INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۲', 3, '9786002299628', 5);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۲', 3, '9786002299628', 4);


INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۱', 1, '9786002290854', 1);
INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۱', 2, '9786002290854', 2);
INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۱', 2, '9786002290854', 3);
INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۱', 3, '9786002290854', 4);
INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۱', 2, '9786002290854', 5);

INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۲', 1, '9789643625283', 3);
INSERT INTO books_libraries
VALUES (DEFAULT, 'د-۲', 2, '9789643625283', 4);

INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۳', 1, '9786006047003', 2);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۳', 2, '9786006047003', 4);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۳', 1, '9786006047003', 6);

INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 1, '9786229558799', 1);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 2, '9786229558799', 2);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 2, '9786229558799', 3);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 1, '9786229558799', 4);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 1, '9786229558799', 5);
INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۴', 2, '9786229558799', 6);

INSERT INTO books_libraries
VALUES (DEFAULT, 'تف-۵', 1, '9786006047539', 3);


INSERT INTO members
VALUES ('2680211570', 'محمد', 'دریانی', '1mo.daryani@gmail.com', '09394531377', 5);
INSERT INTO members
VALUES ('0021351581', 'سید علی', 'باباتبار آقاملکی', 'alibabatabar@gmail.com', '09394531377', 2);
INSERT INTO members
VALUES ('2080905538', 'ترانه', 'واحدی', 'taranevahedi@gmail.com', '09354738466', 5);
INSERT INTO members
VALUES ('2110785055', 'علی', 'نعیمی طبیعی', 'alinaemi@gmail.com', '09117549522', 2);
INSERT INTO members
VALUES ('2050901593', 'ادریس', 'محمدی فرید', 'edrismohammadifarid@gmail.com', '09398228535', 5);

INSERT INTO borrows
VALUES (DEFAULT, DEFAULT, 14, NULL, '2680211570', 1);
INSERT INTO borrows
VALUES (DEFAULT, DEFAULT, 14, NULL, '2680211570', 4);
INSERT INTO borrows
VALUES (DEFAULT, '2020-11-16', 14, '2020-11-26', '2080905538', 10);
INSERT INTO borrows
VALUES (DEFAULT, '2020-11-04', 14, '2020-11-16', '2080905538', 7);
INSERT INTO borrows
VALUES (DEFAULT, '2020-11-04', 14, '2020-11-16', '2080905538', 11);
INSERT INTO borrows
VALUES (DEFAULT, DEFAULT, 14, NULL, '2110785055', 15);
INSERT INTO borrows
VALUES (DEFAULT, '2020-10-04', 14, '2020-11-04', '2110785055', 9);
INSERT INTO borrows
VALUES (DEFAULT, DEFAULT, 14, NULL, '2050901593', 20);
INSERT INTO borrows
VALUES (DEFAULT, '2020-11-05', 14, NULL, '2050901593', 6);


