#Grab the latest alpine image
FROM alpine:3.6

# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash
ADD ./requirements/requirements.txt /tmp/requirements.txt

# Install dependencies
RUN pip3 install Flask

# Add our code
ADD ./* /opt/

# Expose is NOT supported by Heroku
# EXPOSE 5000 		

# Run the image as a non-root user
#RUN adduser -D myuser
#USER myuser
ENTRYPOINT ["python" , "/opt/app.py”]
