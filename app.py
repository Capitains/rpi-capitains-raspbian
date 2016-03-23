# -*- coding: utf-8 -*-

from flask import Flask
from flask.ext.nemo import Nemo
from nautilus.flask_ext import FlaskNautilus
from werkzeug.contrib.cache import FileSystemCache
from flask_cache import Cache

app = Flask("Nautilus")
nautilus_cache = FileSystemCache("/code/cache")
nautilus = FlaskNautilus(
    app=app,
    path="api/cts"
    resources=["/code/data/canonical-latinLit-master"],
    parser_cache=nautilus_cache,
    http_cache=Cache(config={'CACHE_TYPE': "simple"})
)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')