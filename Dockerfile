#Grab the latest alpine image
FROM alpine:3.6-alpine

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash
ADD ./requirements/requirements.txt /tmp/requirements.txt

# Install dependencies
RUN pip3 install --no-cache-dir -q -r /tmp/requirements.txt

# Add our code
ADD ./ /opt/ic-webapp/
WORKDIR /opt/ic-webapp

# Expose is NOT supported by Heroku
# EXPOSE 5000 		

# Run the image as a non-root user
RUN adduser -D myuser
USER myuser

CMD ["/opt/ic-webapp/app.py"]
ENTRYPOINT ["python"]
