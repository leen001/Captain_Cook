FROM python:3.10-bullseye
RUN apt update && apt upgrade -y
RUN apt install -y build-essential
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --upgrade pip
RUN pip install --no-compile -r requirements.txt
RUN python -m nltk.downloader averaged_perceptron_tagger
RUN pip install --upgrade gunicorn
EXPOSE 3000
COPY . /app
ENTRYPOINT [ "gunicorn" ]
CMD ["--bind", "0.0.0.0:3000", "rest_api:gunicorn_app"]