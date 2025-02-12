#!/bin/sh

exec locust -f src/tasks.py
# exec locust -f src/tasks.py --host http://dc.dominio.svc.cluster.local
