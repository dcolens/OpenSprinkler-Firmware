FROM arm32v7/alpine:3.10.1 as base



########################################
## 1st stage builds OS for RPi
FROM base as build

RUN [ "cross-build-start" ]
WORKDIR /OpenSprinkler

RUN apk --no-cache add bash g++
COPY . /OpenSprinkler
RUN ./build.sh -s ospi

RUN [ "cross-build-end" ]



########################################
## 2nd stage is minimal runtime + executable
FROM base

RUN [ "cross-build-start" ]

WORKDIR /OpenSprinkler

RUN apk --no-cache add libstdc++ && \
    mkdir -p /data/logs

COPY --from=build /OpenSprinkler/OpenSprinkler /OpenSprinkler/OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

#-- By default, start OS using /data for saving data/NVM/log files
CMD [ "./OpenSprinkler", "-d", "/data" ]

RUN [ "cross-build-end" ]
