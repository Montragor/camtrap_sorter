FROM public.ecr.aws/lambda/python:3.12

# System-Abhängigkeiten für Bildverarbeitung
RUN dnf install -y mesa-libGL

# Python-Abhängigkeiten installieren
COPY requirements.txt .
RUN pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Eigenen Funktionscode kopieren
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

# Handler festlegen: Dateiname.Funktionsname
CMD ["lambda_function.lambda_handler"]