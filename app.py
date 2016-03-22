# -*- coding: utf-8 -*-

from flask import Flask
from flask.ext.nemo import Nemo
from nautilus.flask_ext import FlaskNautilus
from werkzeug.contrib.cache import FileSystemCache
from flask_cache import Cache

app = Flask("Nautilus")
nautilus_cache = FileSystemCache("/home/pi/cache")
nautilus = FlaskNautilus(
    app=app,
    path="api/cts"
    resources=["/home/pi/data/canonical-latinLit"],
    parser_cache=nautilus_cache,
    http_cache=Cache(config={'CACHE_TYPE': "simple"})
)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')