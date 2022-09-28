import json
import os

from flask import Flask, make_response, request, jsonify

app = Flask(__name__)


def output(data, code):
    response = make_response(data, code)
    response.headers["Content-Type"] = "application/json"
    return response


def param(inp):
    return request.json[inp]


@app.route('/', methods=['GET'])
def main_route():
    response = make_response(
        jsonify(
            {"message": str("ACCESS DENIED"), "code": 403}
        ),
        403,
    )
    return response


@app.route('/users', methods=['GET'])
def users():
    users = []
    with open("/etc/ocserv/ocpasswd", "r") as f:
        lines = f.readlines()
        for line in lines:
            user_items = line.strip().split(":")
            users.append(user_items[0])
    return output({"code": 200, "data": users}, 200)


@app.route('/add', methods=['POST'])
def add_user():
    username = param('username')
    password = param('password')
    command = f'/usr/bin/echo -e "{password}\n{password}\n"|sudo /usr/bin/ocpasswd -c /etc/ocserv/ocpasswd {username}'
    os.system(command)
    return output({"code": 200}, 200)


@app.route('/remove', methods=['POST'])
def remove_user():
    username = param('username')
    command = f'sudo /usr/bin/ocpasswd  -c /etc/ocserv/ocpasswd -d {username}'
    os.system(command)
    return output({"code": 200}, 200)


@app.route('/onlines', methods=['GET'])
def online_users():
    data = json.loads(os.popen('sudo occtl -j show users').read())
    return output({"code": 200, "data": data}, 200)


@app.route('/lock', methods=['POST'])
def lock():
    username = param('username')
    command = f'sudo /usr/bin/ocpasswd  -c /etc/ocserv/ocpasswd -l {username}'
    os.system(command)
    return output({"code": 200}, 200)

@app.route('/disconnect', methods=['POST'])
def disconnect():
    username = param('username')
    command = f'sudo occtl disconnect user {username}'
    os.system(command)
    return output({"code": 200}, 200)


@app.route('/unlock', methods=['POST'])
def unlock():
    username = param('username')
    command = f'sudo /usr/bin/ocpasswd  -c /etc/ocserv/ocpasswd -u {username}'
    os.system(command)
    return output({"code": 200}, 200)


@app.route('/change-password', methods=['POST'])
def change_password():
    username = param('username')
    password = param('password')
    command = f'/usr/bin/echo -e "{password}\n{password}\n"|sudo /usr/bin/ocpasswd -c /etc/ocserv/ocpasswd {username}'
    os.system(command)
    return output({"code": 200}, 200)


def create_app():
    return app

# if __name__ == "__main__":
#     from waitress import serve
#     serve(app, host="0.0.0.0", port=32145)

# app.run(debug=True, host='0.0.0.0', port=3210)
