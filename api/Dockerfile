FROM python:3.11-bullseye
RUN apt update && apt upgrade -y
RUN apt install -y libmariadb3 libmariadb-dev gcc g++ build-essential
# RUN apt update && apt install -y gcc wget
# RUN wget https://dlm.mariadb.com/2678574/Connectors/c/connector-c-3.3.3/mariadb-connector-c-3.3.3-debian-bullseye-amd64.tar.gz -O - | tar -zxf - --strip-components=1 -C /usr
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
# RUN pip install --upgrade pip cython
RUN pip install -r requirements.txt
COPY . /app
ENTRYPOINT [ "python" ]
CMD ["src/rest_api.py" ]