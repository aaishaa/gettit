DROP TABLE IF EXISTS topics CASCADE;
DROP TABLE IF EXISTS products CASCADE;
-- \c login
DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id              SERIAL PRIMARY KEY,
  email           VARCHAR UNIQUE NOT NULL,
  password_digest VARCHAR NOT NULL,
  username        VARCHAR NOT NULL
);

CREATE TABLE topics(
  id    SERIAL PRIMARY KEY,
  title VARCHAR UNIQUE NOT NULL
);

CREATE TABLE products(
  id            SERIAL PRIMARY KEY,
  topic_id      INTEGER REFERENCES topics(id),
  brand         VARCHAR,
  name          VARCHAR NOT NULL,
  description   TEXT,
  votes         INTEGER,
  ptime         DATE
);

CREATE TABLE comments(
  id           SERIAL PRIMARY KEY,
  comment_id   INTEGER REFERENCES products(id),
  from_user    INTEGER,
  pdate        DATE
);

INSERT INTO topics
  (title)
VALUES
  ('Skin'),
  ('Hair'),
  ('Makeup'),
  ('Nails');

INSERT INTO products
  (topic_id, brand, name, description, votes, ptime)
VALUES
  (2, 'It''s a 10', 'Miracle Styling Serum', 'This stuff is so good!', 8, CURRENT_DATE),
  (1, 'Cetaphil', 'Moisturizing Cream', 'So gentle!', 0, CURRENT_DATE),
  (3, 'Lancome', 'Hypnose Lash Drama', 'amazing lengths!', 2, CURRENT_DATE),
  (4, 'OPI', 'Red Hot Rio', 'great red', 4, CURRENT_DATE),
  (2, 'R+Co', 'Dry Shampoo', 'so much volume!', 9, CURRENT_DATE),
  (1, 'SK-II', 'Essence Absolue', 'smoothest skin ever', 5, CURRENT_DATE);