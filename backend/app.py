from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)

# Abilita CORS per permettere ad Angular (porta 4200) di comunicare con Flask
CORS(app, resources={r"/api/*": {"origins": "http://localhost:4200"}})

# Database simulato (Mock Data)
# La struttura segue esattamente il tuo file TypeScript e HTML
db_fleet = [
    {
        "id": 1,
        "name": "Ambulanza A1",
        "plate": "XY 123 AB",
        "status": "available", # 'available' attiva il verde nell'HTML
        "driver": "Mario Rossi",
        "lat": 45.4642,
        "lng": 9.1900,
        "currentTask": None
    },
    {
        "id": 2,
        "name": "Auto Medica 05",
        "plate": "ZA 987 CD",
        "status": "busy", # 'busy' attiva il rosso e mostra il Task
        "driver": "Luca Bianchi",
        "lat": 45.4781,
        "lng": 9.1245,
        "currentTask": "Codice Rosso - Via Roma"
    },
    {
        "id": 3,
        "name": "Mezzo Soccorso 03",
        "plate": "EF 456 GH",
        "status": "maintenance", # 'maintenance' disabilita il bottone
        "driver": "Officina",
        "lat": 45.4321,
        "lng": 9.2132,
        "currentTask": None
    }
]

# --- API ENDPOINTS ---

@app.route('/api/fleet', methods=['GET'])
def get_fleet():
    """Ritorna la lista completa dei veicoli per il componente Angular"""
    return jsonify(db_fleet)

@app.route('/api/fleet/<int:vehicle_id>', methods=['GET'])
def get_vehicle(vehicle_id):
    """Ritorna i dettagli di un singolo veicolo se necessario"""
    vehicle = next((v for v in db_fleet if v["id"] == vehicle_id), None)
    if vehicle:
        return jsonify(vehicle)
    return jsonify({"error": "Veicolo non trovato"}), 404

@app.route('/api/contact', methods=['POST'])
def contact_driver():
    """Endpoint per gestire la logica di chiamata dell'autista"""
    data = request.json
    driver_name = data.get('driver')
    print(f"Log: Tentativo di contatto con {driver_name}")
    return jsonify({"status": "success", "message": f"Chiamata a {driver_name} inoltrata"}), 200

if __name__ == '__main__':
    # Avvia il server sulla porta 5000
    app.run(debug=True, port=5000)