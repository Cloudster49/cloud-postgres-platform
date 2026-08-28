import psycopg

connection = psycopg.connect(
    host="localhost",
    port=5432,
    dbname="cloud_platform",
    user="postgres",
    password="postgres_dev_password"
)

cursor = connection.cursor()

cursor.execute("SELECT version();")

result = cursor.fetchone()

print(result[0])

cursor.close()
connection.close()