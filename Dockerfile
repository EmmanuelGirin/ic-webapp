#Grab the latest alpine image
FROM python:3.6-alpine

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash

# Install dependencies
RUN pip3 install Flask

# Add our code
ADD ./ /opt/ic-webapp
WORKDIR /opt/ic-webapp

# Expose is NOT supported by Heroku
EXPOSE 8080

# Run the image as a non-root user
#RUN adduser -D myuser
#USER myuser
ENTRYPOINT ["python" , "app.py"]