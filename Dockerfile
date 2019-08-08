FROM arm32v7/alpine:3.10.1 as base



########################################
## 1st stage builds OS for RPi
FROM base as build

WORKDIR /OpenSprinkler

RUN apk --no-cache add bash g++
COPY . /OpenSprinkler
RUN ./build.sh -s ospi




########################################
## 2nd stage is minimal runtime + executable
FROM base


WORKDIR /OpenSprinkler

RUN apk --no-cache add libstdc++ && \
  mkdir -p /data/logs && \
  ln -s /data/stns.dat && \
  ln -s /data/nvm.dat && \
  ln -s /data/ifkey.txt && \
  ln -s /data/logs

COPY --from=build /OpenSprinkler/OpenSprinkler /OpenSprinkler/OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

#-- By default, start OS using /data for saving data/NVM/log files
CMD [ "./OpenSprinkler" ]

