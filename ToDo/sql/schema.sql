-- use the following command to create the table:
-- table name todo_list
-- column id integer primary key autoincrement
-- reference_id integer (alpha numeric id to exose on front end)
-- description text to store actual todo text
-- status int to store status of todo (0/1) => (pending/done)
-- created_at timestamp default CURRENT_TIMESTAMP
-- updated_at timestamp to show updated timestamp

CREATE TABLE todo_list (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reference_id TEXT NOT NULL,
    description  TEXT NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP
);

--sample todo row
INSERT INTO todo_list (reference_id, description, status, created_at, updated_at) VALUES('REF-ABC', 'test', 0, CURRENT_TIMESTAMP, '');
