FROM python:3.11-alpine3.23 as builder
WORKDIR /app
COPY app/ .
RUN pip install --no-cache-dir --user -r requirements.txt



FROM python:3.11-alpine3.23 
WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /root/.local /home/roboshop/.local
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop && chown -R roboshop:roboshop /app
USER roboshop
CMD ["uwsgi", "--ini", "payment.ini"]
