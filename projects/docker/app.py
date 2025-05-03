#!/usr/bin/python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import mimetypes
import os
import socket
from socketserver import ThreadingMixIn

hostName = "0.0.0.0"
serverPort = 8080

class Handler(BaseHTTPRequestHandler):
	"""Custom HTTP request handler."""

	def do_GET(self):
		"""Handle GET requests."""
		if self.path == "/":
			# Respond with the file contents.
			self.send_response(200)
			self.send_header("Content-type", "text/html")
			self.end_headers()
			if os.path.exists('index.html'):
				with open('index.html', 'rb') as file:
					content = file.read()
				self.wfile.write(content)
			else:
				self.wfile.write(b"Error: index.html not found")
		elif self.path == "/hostname":
			# Respond with the system's hostname.
			self.send_response(200)
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			hostname = socket.gethostname()
			self.wfile.write(hostname.encode())
		else:
			self.send_response(404)
			self.end_headers()
			self.wfile.write(b"Error: File not found")

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
	"""Handle requests in a separate thread."""

if __name__ == "__main__":
	webServer = ThreadedHTTPServer((hostName, serverPort), Handler)
	print(f"Server started http://{hostName}:{serverPort}")
	try:
		webServer.serve_forever()
	except KeyboardInterrupt:
		pass
	webServer.server_close()
	print("Server stopped.")
