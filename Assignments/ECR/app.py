from flask import Flask, render_template, jsonify, request
import pymysql
import os

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")

def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME
    )

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/api/users", methods=["GET"])
def get_users():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT name FROM users")
    rows = cursor.fetchall()

    users = [r[0] for r in rows]

    conn.close()

    return jsonify(users)

@app.route("/api/users", methods=["POST"])
def add_user():

    data = request.json
    name = data["name"]

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("INSERT INTO users(name) VALUES(%s)", (name,))
    conn.commit()

    conn.close()

    return jsonify({"message": "User added"})
    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
