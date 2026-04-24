SELECT format('CREATE USER %I WITH PASSWORD %L CREATEDB', :'user', :'password')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'user');
\gexec