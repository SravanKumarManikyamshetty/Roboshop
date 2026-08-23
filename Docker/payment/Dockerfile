FROM python:3.11-alpine3.23
WORKDIR /app
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
RUN chown -R roboshop:roboshop /app
USER roboshop
CMD ["uwsgi", "--ini", "payment.ini"]