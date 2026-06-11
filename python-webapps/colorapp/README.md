## Web application created using python

### Pre-requsites
- To run application locally you must have python and pip installed and configured in your local system.
- If want to run application in docker container then Docker should be installed on host where we are building this docker image

### Run application locally
Install required packages for this application and run the application. Once application started you will see the URL to access it on Browser mostly url will be http://127.0.0.1:8080.

Press CTRL+C to exit the app. set environment variable to set the color for application web page.

```
pip3 install -r ./requirements.txt

export APP_COLOR=red
python3 ./app.py
```

### Building docker image
go to current directory and run below command
```
docker build -t color-app:latest .
```

### Running docker container
Once docker image built use below command to run single container 

```
docker run --rm -e APP_COLOR="#1e90ff" -p 8080:8080 color-app:latest
```

(Optional) If you prefer Compose for multiple differently-colored instances:

```
docker compose up -d
```

To stop all containers
```
docker compose down
```

If you want to remove images too
```
docker compose down --rmi
```
