from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
from functools import wraps
import os

app = Flask(__name__)
CORS(app)

# Admin password
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD')
ADMIN_TOKEN = "*LZscYCzXCFSH0$^R93C*rCez2*DCv$W"

# ========== HELPER FUNCTIONS ===========

def init_db():
    conn = sqlite3.connect('gps_monolit.db')
    c = conn.cursor()
        
    # Places catalog (list of all places)
    c.execute('''CREATE TABLE IF NOT EXISTS places
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  code CHAR(13) NOT NULL,
                  latitude REAL NOT NULL,
                  longitude REAL NOT NULL,
                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                  active BOOL NOT NULL)''')
    
    conn.commit()
    conn.close()
    
def get_db():
    conn = sqlite3.connect('gps_monolit.db')
    conn.row_factory = sqlite3.Row
    return conn


def admin_required(f):
  @wraps(f)
  def decorated_function(*args, **kwargs):
    # Hledáme token v HTTP hlavičce s názvem "Authorization"
    auth_header = request.headers.get('Authorization')
    
    # Pokud token chybí nebo nesouhlasí, okamžitě pošleme hráče pryč
    if not auth_header or auth_header != f"Bearer {ADMIN_TOKEN}":
      return jsonify({"error": "Přístup odmítnut. Nejsi administrátor."}), 401
      
    return f(*args, **kwargs)
  return decorated_function

# ============ API ENDPOINTS ============

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

@app.route('/api/point_location', methods=['POST'])
def point_location():
    data = request.json
    
    code = data.get('code', '').strip()
        
    conn = get_db()
    c = conn.cursor()
    
    c.execute('''SELECT latitude, longitude
                 FROM places
                 WHERE code = ? AND active = true
                ''', (code,))
    
    point = c.fetchone()
    
    conn.close()
    
    if point:
        return jsonify({
            "lat": point["latitude"],
            "lon": point["longitude"],
        })
    else:
        return jsonify({"error": "Neznámá sekvence symbolů. "}), 404
    
# ========= ADMIN API ENDPOINTS =========

# Admin: Verify password
@app.route('/api/admin/auth', methods=['POST'])
def admin_auth():
    data = request.json
    password = data.get('password').strip()
    
    if password == ADMIN_PASSWORD:
        return jsonify({
            "authenticated": True,
            "token": ADMIN_TOKEN
        })
    else:
        return jsonify({"authenticated": False}), 401

# Admin: Get all unique places
@app.route('/api/admin/place/all', methods=['GET'])
@admin_required
def admin_get_all_places():
    conn = get_db()
    c = conn.cursor()
    
    # Get all places from catalog
    c.execute('''SELECT id, name, code, latitude, longitude, active
                FROM places 
                ORDER BY name ASC''')
    
    places = []
    for row in c.fetchall():
        places.append({
            'id': row['id'],
            'name': row['name'],
            'code': row['code'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
            'active': row['active'],
        })
    
    conn.close()
    return jsonify(places)

@app.route('/api/admin/place/<int:place_id>', methods=['GET'])
@admin_required
def admin_get_place(place_id):
    conn = get_db()
    c = conn.cursor()
    
    # Get all places from catalog
    c.execute('''SELECT name, code, latitude, longitude, active
                FROM places 
                WHERE id = ?''',
                (place_id,))
    
    place = c.fetchone()
    
    conn.close()
    return jsonify({
        "name" : place["name"],
        "latitude" : place["latitude"],
        "longitude" : place["longitude"],
        "code" : place["code"],
    })


# Admin: Toggle place
@app.route('/api/admin/place/<int:place_id>/toggle', methods=['POST'])
@admin_required
def admin_toggle_place(place_id):
    new_state : bool = request.json.get('new_state', True)
        
    conn = get_db()
    c = conn.cursor()
    
    c.execute('UPDATE places SET active = ? WHERE id = ?', (new_state, place_id))
    
    conn.commit()
    conn.close()
    
    return jsonify({"status": "success"})

# Admin: Update place in catalog
@app.route('/api/admin/place/<int:place_id>/update', methods=['PUT'])
@admin_required
def admin_update_place(place_id):
    data = request.json
    name = data.get('name')
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    code = data.get('code')
    
    conn = get_db()
    c = conn.cursor()
    
    c.execute('''UPDATE places 
                 SET name = ?, latitude = ?, longitude = ?, code = ?
                 WHERE id = ?''',
                 (name ,latitude, longitude, code, place_id))
    
    conn.commit()
    conn.close()
    
    return jsonify({"status": "success"})

# Admin: Delete place from catalog
@app.route('/api/admin/place/<int:place_id>/delete', methods=['DELETE'])
@admin_required
def admin_delete_place(place_id):
    conn = get_db()
    c = conn.cursor()
    
    c.execute('''DELETE FROM places
                WHERE id=?''', (place_id,))
        
    conn.commit()
    conn.close()
    
    return jsonify({"status": "success"})

# Admin: Add a new place
@app.route('/api/admin/new_place', methods=['POST'])
@admin_required
def admin_add_place():
    data = request.json
    name = data.get('name')
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    code = data.get('code')
    
    conn = get_db()
    c = conn.cursor()
    
    c.execute('''INSERT INTO places (name, latitude, longitude, code, active)
                    VALUES (?, ?, ?, ?, false)''',
                  (name, latitude, longitude, code))
    
    conn.commit()
    conn.close()
    
    return jsonify({"status": "success"})


init_db()

if __name__ == '__main__':
    print("=" * 50)
    print("GPS Tracker Backend Server")
    print("=" * 50)
    print(f"Admin Password: {ADMIN_PASSWORD}")
    print("Database initialized: gps_monolit.db")
    print("Server starting on http://0.0.0.0:5000")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=True)