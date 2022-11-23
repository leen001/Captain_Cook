FROM python:3.10-bullseye
RUN apt update && apt upgrade -y
# RUN apt install -y libmariadb3 libmariadb-dev gcc g++ build-essential
RUN apt install -y build-essential
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --upgrade pip
RUN pip install --no-compile -r requirements.txt
COPY . /app
ENTRYPOINT [ "python" ]
CMD ["src/rest_api.py" ]