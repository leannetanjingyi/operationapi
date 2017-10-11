

library(jsonlite)
library(httr)
 
key <- "GMlufihfdX1XgoDrumWfDsthdzpOoUmA"
temp <- "https://api.data.gov.sg/v1/environment/air-temperature"


#generate a list of datatime in the appropriate format (e.g. 2016-12-12T09:45:00")
library(lubridate)
dates <- as.vector(seq(as_datetime('2016-12-31 17:27:22 +08'), as_datetime(Sys.time()), 
             by = '1 min'))
length(dates)

df.temp <- as.data.frame(NULL)
for (i in 1:length(dates)){
      datetime <- as.character(format(as_datetime(dates[i]), "%Y-%m-%dT%H:%M:%S"))
      airtemp <-  GET("https://api.data.gov.sg/v1/environment/air-temperature", 
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
      df.airtemp <- subset(df.airtemp, select=-c(metadata.stations.location,
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





