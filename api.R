
      #Packages to be used: 
      library(jsonlite)
      library(httr)
      library(lubridate)
      
      #Important Links/Key
      key <- "GMlufihfdX1XgoDrumWfDsthdzpOoUmA"
      
      #Updated Per Minute
      temp <- "https://api.data.gov.sg/v1/environment/air-temperature"
      rh <- "https://api.data.gov.sg/v1/environment/relative-humidity"
      wd <- "https://api.data.gov.sg/v1/environment/wind-direction"
      ws <- "https://api.data.gov.sg/v1/environment/wind-speed"
      
      #Updated Per 5 Minute
      rain <- 'https://api.data.gov.sg/v1/environment/rainfall'
      
      #Updated Per Hour (Retrieved every hour between 7 AM and 7 PM everyday,
      #The UV index value is averaged over the preceeding hour)
      uv <- "https://api.data.gov.sg/v1/environment/uv-index"


      #Generate a list of datatime in the appropriate format 
      #(e.g. 2016-12-12T09:45:00)
      dates.1min <- as.vector(seq(as_datetime('2016-12-31 00:00:00 +08'), 
                             as_datetime(Sys.time()), 
                             by = '1 min'))
      dates.5min <- as.vector(seq(as_datetime('2016-12-31 00:00:00 +08'), 
                                  as_datetime(Sys.time()), 
                                  by = '5 min'))
      dates.1hr <- as.vector(seq(as_datetime('2016-12-31 00:00:00 +08'), 
                                 as_datetime(Sys.time()), 
                                 by = '1 hr'))

      ptm <- proc.time()
      df.temp <- as.data.frame(NULL)
      for (i in 1:length(dates.1min)){
            datetime <- as.character(format(as_datetime(dates.1min[i]), 
                                            "%Y-%m-%dT%H:%M:%S"))
            airtemp <-  GET(temp, 
                            query = list("date_time"= URLdecode(datetime)),
                            add_headers(.headers = 
                                              c("api-key" = key)))
            df.airtemp <- content(airtemp, as = "text", encoding = NULL)
            df.airtemp <- fromJSON(df.airtemp)
            df.airtemp <- do.call(cbind, lapply(df.airtemp, data.frame))
            df.airtemp <- as.data.frame(df.airtemp)
            long.lat <- df.airtemp$metadata.stations.location
            values <- df.airtemp$items.readings
            values <- do.call(cbind, lapply(values, data.frame))[1:2]
            df.airtemp <- merge.data.frame(df.airtemp,
                                           values,
                                           by.x = "metadata.stations.id",
                                           by.y = "station_id",
                                           all = TRUE)
            df.airtemp <- subset(df.airtemp, 
                                 select=-c(metadata.stations.location,
                                           items.readings))
            df.airtemp$metadata.stations.location.longitude <- long.lat$longitude
            df.airtemp$metadata.stations.location.latitude <- long.lat$latitude
            colnames(df.airtemp) <- c("metadata.stations.id",
                                      "metadata.stations.device_id",
                                      "metadata.stations.name", 
                                      "metadata.reading_type",
                                      "metadata.reading_unit",
                                      "items.timestamp",
                                      "status",
                                      "temperature",
                                      "metadata.stations.location.longitude",
                                      "metadata.stations.location.latitude"
                                      )
            row.names(df.airtemp) <- letters[1:nrow(df.airtemp)]
            df.temp <- rbind.data.frame(df.temp, df.airtemp)
            row.names(df.temp) <- 1:nrow(df.temp)
      }
      proc.time() - ptm




