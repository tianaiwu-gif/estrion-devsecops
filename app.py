from flask import Flask
import os
app = Flask(__name__)
@app.route("/")
def hello():
    # Dieser Wert MUSS später aus der Kubernetes ConfigMap kommen!
    environment_name = os.environ.get("ENV_NAME", "Local")
    return f"DevSecOps Pipeline erfolgreich! Aktuelles Environment: {environment_name}"
@app.route("/health")
def health():
    return "OK", 200
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
