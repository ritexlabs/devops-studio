
# app.py
import os
import socket
from flask import Flask, Response

app = Flask(__name__)

@app.route("/")
def index():
    app_color = os.getenv("APP_COLOR", "steelblue")  # Default color
    container_name = socket.gethostname()            # Shows the container hostname
    # Very simple HTML with inline styles using APP_COLOR
    html = f"""
    <!doctype html>
    <html lang="en">
    <head>
        <title>Color App</title>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>
            body {{
                margin: 0;
                padding: 0;
                height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: {app_color};
                color: #fff;
                font-family: Arial, Helvetica, sans-serif;
            }}
            .card {{
                background: rgba(0,0,0,0.35);
                padding: 2rem 3rem;
                border-radius: 12px;
                text-align: center;
                box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            }}
            .label {{
                font-size: 1.1rem;
                opacity: 0.8;
            }}
            .value {{
                font-size: 2rem;
                font-weight: 700;
                margin-top: 0.35rem;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <div class="label">APP_COLOR</div>
            <div class="value">{app_color}</div>
            <div style="height: 1.5rem"></div>
            <div class="label">Container Name</div>
            <div class="value">{container_name}</div>
        </div>
    </body>
    </html>
    """
    return Response(html, mimetype="text/html")

if __name__ == "__main__":
    # For local dev only; Docker will use gunicorn
    app.run(host="0.0.0.0", port=8080)

