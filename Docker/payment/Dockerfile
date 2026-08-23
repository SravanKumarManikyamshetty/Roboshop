FROM python:3.11-alpine3.23
WORKDIR /app
RUN apk add --no-cache gcc musl-dev linux-headers python3-dev pcre-dev
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
RUN chown -R roboshop:roboshop /app
CMD ["uwsgi", "--ini", "payment.ini"]
USER roboshop