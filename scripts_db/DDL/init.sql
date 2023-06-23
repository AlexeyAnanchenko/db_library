CREATE TABLE IF NOT EXISTS public.reader (
    reader_id serial PRIMARY KEY,
    ticket_num BIGINT NOT NULL,
    full_name varchar(255) NOT NULL,
    address_reader varchar(255) NOT NULL,
    num_phone varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.publish_house (
    publish_house_id serial PRIMARY KEY,
    title varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.book (
    book_id serial PRIMARY KEY,
    cipher_book BIGINT NOT NULL,
    title varchar(255) NOT NULL,
    year_public smallint NOT NULL,
    volume_pages integer,
    price numeric(7, 2) NOT NULL DEFAULT 0,
    count_instances integer NOT NULL DEFAULT 0,
    publish_house_id BIGINT REFERENCES public.publish_house (publish_house_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.author (
    author_id serial PRIMARY KEY,
    full_name varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.city (
    city_id serial PRIMARY KEY,
    name_city varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.reader_book (
    reader_book_id serial PRIMARY KEY,
    reader_id BIGINT REFERENCES public.reader (reader_id) ON DELETE CASCADE,
    book_id BIGINT REFERENCES public.book (book_id) ON DELETE CASCADE,
    date_receipt date NOT NULL DEFAULT CURRENT_DATE,
    date_return date
);

CREATE TABLE IF NOT EXISTS public.book_author (
    author_id BIGINT REFERENCES public.author (author_id) ON DELETE CASCADE,
    book_id BIGINT REFERENCES public.book (book_id) ON DELETE CASCADE,
    PRIMARY KEY (author_id, book_id)
);

CREATE TABLE IF NOT EXISTS public.city_publish_house (
    city_id BIGINT REFERENCES public.city (city_id) ON DELETE CASCADE,
    publish_house_id BIGINT REFERENCES public.publish_house (publish_house_id) ON DELETE CASCADE,
    PRIMARY KEY (city_id, publish_house_id)
);

CREATE TABLE IF NOT EXISTS public.lose_book (
    lose_book_id serial PRIMARY KEY,
    book_id BIGINT REFERENCES public.book (book_id) ON DELETE CASCADE,
    date_lose date NOT NULL DEFAULT CURRENT_DATE,
    reader_id BIGINT REFERENCES public.reader (reader_id) ON DELETE SET NULL
)
