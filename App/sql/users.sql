CREATE TABLE users (
    user_id SERIAL,
    name_first varchar(50),
    name_last varchar(50),
    email varchar(100),
    organisation varchar(255),
    password varchar(32),
    salt varchar(32),
    role integer,
    lang varchar(2),
    created timestamp without time zone NOT NULL default now(),
    CONSTRAINT users_id_pkey PRIMARY KEY (user_id)
  )
  WITH (
    OIDS=FALSE
  );
  ALTER TABLE users OWNER TO postgres;

INSERT INTO users VALUES(nextval('users_user_id_seq'),'Grant','McKenzie','grantdmckenzie@gmail.com','Spatial Development International','$1$45678901$Y0gxvzSrsidsSmiTCrZkK1','$1$45678901$',2,'en',now());