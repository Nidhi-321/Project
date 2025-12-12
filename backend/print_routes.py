from app import create_app

app = create_app()

for r in sorted(app.url_map.iter_rules(), key=lambda r: r.rule):
    print(f"{r.rule:40} {sorted(list(r.methods))} -> {r.endpoint}")
