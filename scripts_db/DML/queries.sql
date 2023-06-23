-- Определить, сколько книг прочитал каждый читатель в текущем году.
-- Вывести рейтинг читателей по убыванию.'

SELECT r.full_name AS "Читатель", COUNT(rb.book_id) AS "Книг прочитано"
FROM reader AS r
LEFT JOIN reader_book AS rb USING(reader_id)
WHERE rb.date_return IS NOT NULL AND EXTRACT(YEAR FROM rb.date_receipt::date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY r.full_name
ORDER BY "Книг прочитано" DESC;

-- Определить, сколько книг у читателей на руках на текущую дату.

SELECT COUNT(rb.book_id) AS "Общее количество книг у читателей"
FROM reader_book AS rb
WHERE rb.date_return IS NULL;

-- Определить читателей, у которых на руках определенная книга.

SELECT r.full_name AS "Читатель"
FROM reader AS r
LEFT JOIN reader_book AS rb USING(reader_id)
WHERE rb.date_return IS NULL AND rb.book_id = (SELECT book_id
					       FROM book
					       WHERE title = 'Собачье сердце');

-- Определите, какие книги на руках читателей.

SELECT DISTINCT b.title AS "Название книги"
FROM book AS b
JOIN reader_book AS rb USING(book_id)
WHERE rb.date_return IS NULL;

-- Вывести количество должников на текущую дату.

SELECT COUNT(DISTINCT reader_id) AS "Количество должников"
FROM reader_book
WHERE date_return IS NULL AND date_receipt < (CURRENT_DATE - INTERVAl '14 days');

-- Книги какого издательства были самыми востребованными у читателей?
-- Отсортируйте издательства по убыванию востребованности книг.

SELECT ph.title AS "Издательство", COUNT(rb.book_id) AS "Прочитано книг"
FROM publish_house AS ph
JOIN book AS b USING(publish_house_id)
JOIN reader_book AS rb USING(book_id)
GROUP BY ph.title
ORDER BY "Прочитано книг" DESC;

-- Определить самого издаваемого автора.

SELECT a.full_name AS "Автор", SUM(b.count_instances) AS "Количество экземпляров"
FROM author AS a
LEFT JOIN book_author AS ba USING(author_id)
LEFT JOIN book AS b USING(book_id)
GROUP BY a.full_name
HAVING SUM(b.count_instances) = (SELECT SUM(b.count_instances) AS "Количество экземпляров"
				 FROM book_author AS ba
				 JOIN book AS b USING(book_id)
				 GROUP BY ba.author_id
				 ORDER BY "Количество экземпляров" DESC
				 LIMIT 1);

-- Определить среднее количество прочитанных страниц читателем за день.

SELECT r.full_name AS "Читатель",
	   (SUM(b.volume_pages) / SUM(rb.days_for_read)) AS "Среднее кол-во прочит. страниц"
FROM reader AS r
LEFT JOIN (SELECT reader_id, book_id,
		   (date_return - date_receipt) AS days_for_read
           FROM reader_book
           WHERE date_return IS NOT NULL) AS rb USING(reader_id)
LEFT JOIN book AS b USING(book_id)
GROUP BY r.full_name
ORDER BY 2 DESC NULLS LAST;

-- Напишите sql запрос, который определяет, терял ли определенный читатель книги.

SELECT r.full_name AS "ФИО читателя", 
	CASE
		WHEN COUNT(lb.book_id) = 0 THEN 'Нет'
        ELSE 'Да'
    END AS "Терял ли книги?"
FROM reader as r
LEFT JOIN lose_book as lb USING(reader_id)
GROUP BY r.full_name
ORDER BY 1;

-- При потере книг количество доступных книг фонда меняется.
-- Напишите sql запрос на обновление соответствующей информации.

UPDATE book AS b
SET count_instances = count_instances - lb.count_lose_book
FROM (
	SELECT book_id, COUNT(book_id) AS count_lose_book
	FROM lose_book
	GROUP BY book_id
	) AS lb
WHERE b.book_id = lb.book_id;

-- Определить сумму потерянных книг по каждому кварталу в течение года.

SELECT lb_2.quarter_lose AS "Квартал",
	COUNT(lb_2.book_id) AS "Количество потерянных книг",
	SUM(lb_2.price) AS "Сумма потерянных книг"
FROM (
	SELECT lb.book_id, b.price,
	EXTRACT(QUARTER FROM lb.date_lose) AS quarter_lose
	FROM lose_book AS lb
	JOIN book AS b USING(book_id)
	WHERE lb.date_lose > (CURRENT_DATE - INTERVAl '1 year')
	) AS lb_2
GROUP BY lb_2.quarter_lose
ORDER BY lb_2.quarter_lose;
