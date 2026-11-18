"""Utility helpers for project data processing."""
__version__ = "0.1.0"

def csv_summary(path):
    """Return row/column counts for a CSV file."""
    import csv
    with open(path) as f:
        rows = list(csv.reader(f))
    return {"rows": len(rows), "cols": len(rows[0]) if rows else 0}

def json_flatten(data, prefix=""):
    """Flatten nested JSON into dotted keys."""
    out = {}
    for k, v in data.items():
        key = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            out.update(json_flatten(v, key))
        else:
            out[key] = v
    return out
