#!/usr/bin/env python3
import http.server
import socketserver
import os

os.chdir('/home/user/flutter_app/build/web')

PORT = 5060

class ReuseAddrTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

class CORSHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        super().end_headers()
    
    def log_message(self, format, *args):
        pass

with ReuseAddrTCPServer(('0.0.0.0', PORT), CORSHandler) as httpd:
    print(f'Server running on port {PORT}', flush=True)
    httpd.serve_forever()
