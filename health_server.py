#!/usr/bin/env python3
"""
HTTP Health Check сервер для Railway
Проверяет что сервер Hypersomnia запущен и работает
"""

import os
import sys
import time
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from threading import Thread

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Обработка GET запросов для health check"""
        try:
            # Проверяем что процесс Hypersomnia запущен
            result = subprocess.run(
                ["pgrep", "-f", "Hypersomnia-Headless.AppImage"], 
                capture_output=True, 
                text=True
            )
            
            if result.returncode == 0:
                # Процесс найден - сервер работает
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                
                status = {
                    "status": "healthy",
                    "service": "hypersomnia-server",
                    "uptime": self.get_uptime(),
                    "pids": result.stdout.strip().split('\n') if result.stdout.strip() else []
                }
                
                import json
                self.wfile.write(json.dumps(status, indent=2).encode())
            else:
                # Процесс не найден
                self.send_response(503)  # Service Unavailable
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                
                status = {
                    "status": "unhealthy", 
                    "service": "hypersomnia-server",
                    "error": "Hypersomnia process not found"
                }
                
                import json
                self.wfile.write(json.dumps(status, indent=2).encode())
                
        except Exception as e:
            # Ошибка при проверке
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            status = {
                "status": "error",
                "service": "hypersomnia-server", 
                "error": str(e)
            }
            
            import json
            self.wfile.write(json.dumps(status, indent=2).encode())
    
    def get_uptime(self):
        """Получение времени работы системы"""
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.readline().split()[0])
                return f"{uptime_seconds:.1f} seconds"
        except:
            return "unknown"
    
    def log_message(self, format, *args):
        """Отключаем логирование HTTP запросов"""
        pass

def start_health_server(port):
    """Запуск HTTP сервера для health checks"""
    server = HTTPServer(('0.0.0.0', port), HealthHandler)
    print(f"Health check server started on port {port}")
    server.serve_forever()

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 8080))
    
    print(f"Starting Hypersomnia Health Check Server on port {port}")
    print(f"Health check endpoint: http://localhost:{port}/")
    
    try:
        start_health_server(port)
    except KeyboardInterrupt:
        print("Health check server stopped")
        sys.exit(0)
    except Exception as e:
        print(f"Health check server error: {e}")
        sys.exit(1)
