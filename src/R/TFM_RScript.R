#Buscollection variable cames from the import of the collection from Mongodb by using mongolite

##1.Speed over time

library(ggplot2)
library(dplyr)
library(Hmisc)
library(lubridate)

busCollection$day<-wday(busCollection$time, week_start = getOption("lubridate.week.start", 1))
speedPerDay<-busCollection%>%group_by(day, linea)%>%summarise(speed=mean(speed))
ggplot(speedPerDay, aes(x=day, y=speed, color=as.character(linea)))  +
  geom_line() + 
  scale_x_continuous(breaks=1:7, labels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")) +
  labs(x = "Days of the week", y = "Speed in km/h", 
       title = "Speed per day of the week")+ 
  scale_color_discrete("Line ID",breaks = sort(speedPerDay$linea))+
  theme(plot.title = element_text(hjust = 0.5))

##2.Data Exploration

library(BBmisc)
library(DataExplorer)
library(ggplot2)
library(dplyr)

busCollection<-boxplot(busCollection$speed, main="Speed outlies", xlab="Quantiles of speed", horizontal=TRUE)

exploration<-busCollection
exploration$geometry<-NULL
df <- data.frame(matrix(unlist(exploration), nrow=nrow(exploration)),stringsAsFactors=FALSE)
names(df) <- names(exploration)
dfN<-as.data.frame(lapply(df,as.numeric))
plot_intro(dfN)
plot_missing(dfN)

ggplot(dfN, aes(x=speed, colour = factor(linea), fill = factor(linea))) +
  geom_density(position = "fill") +
  xlab("Speed km/h") + 
  ggtitle("Speed Density per line") +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(fill = "Line ID") +
  guides(colour = FALSE)
ggplot(dfN, aes(x=speed, color=factor(linea), fill=factor(linea))) +
  xlab("Speed km/h") + 
  ggtitle("Speed Density per line") +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(fill = "Line ID") +
  geom_histogram() +
  guides(colour = FALSE)

##3.Histograms

library(plyr)
library(lubridate)
library(ggplot2)

busCollection$hour = hour(busCollection$time) + minute(busCollection$time)/60 + second(busCollection$time)/3600
bins=c(paste0(rep(c(paste0(0,0:9),10:23), each=4),".", c("00",25,50,75))[-1],"24:00")
busCollection$bins = cut(busCollection$hour, breaks=seq(0, 24, 0.25), labels=bins)
busCollection$bins <- as.numeric(as.character(busCollection$bins))
ggplot(busCollection, aes(bins)) +
  geom_histogram(aes(fill = ..count..))+
  scale_x_continuous(name = "Hours of the day") +
  scale_y_continuous(name = "Number of points")+
  ggtitle("Points per hour")+
  theme(plot.title = element_text(hjust = 0.5))  +
  scale_fill_gradient("Number points", low = "#660066", high = "yellow")+ 
  geom_vline(aes(xintercept=mean(bins, na.rm=TRUE)),
             color="blue", linetype="dashed", size=1)
##4.GLM

stopsBinomial<-busCollection
stopsBinomial$stop2<-!is.na(stopsBinomial$stop)
stopsBinomial$stop3<-lapply(stopsBinomial$stopBoolean, as.numeric)
stopsBinomial$stopBinomial<-unlist(stopsBinomial$stop3)
summary(glm(stopsBinomial$stopBinomial ~ stopsBi$speed, family = "binomial"))

withoutUnoStops<-filter(stopsBi,is.na(stop) | speed>=3,215)
summary(glm(withoutUnoStops$stopBinomial ~ withoutUnoStops$speed, family = "binomial"))

##5.Shiny dashboards

#Comparison

library(shiny)
library(shinydashboard)
library(ggplot2)
library(DataExplorer)
library(dplyr)

ui <- dashboardPage(skin = "black",
                    dashboardHeader(title = "EMT Madrid - Bus fleet"
                    ),
                    dashboardSidebar(
                      sidebarMenu(
                        selectInput("stops", label = h3("Points Collection"), choices=list("Stopping" = TRUE, "Not stopping" = FALSE),selected=TRUE),
                        selectInput("ruta", label = h3("Select ruta"), 
                                    choices = list("All"="All","Ruta 1" = 1, "Ruta 2" = 2), 
                                    selected = "All"),
                        selectInput("linea", label=h3("Enter Linea ID"), choices=c("All"="All",sort(unique(busCollection$linea))),selected="All"),
                        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
                      )
                    ),
                    dashboardBody(
                      tabItems(
                        tabItem(tabName = "dashboard",
                                fluidRow(
                                  box(title="Outliners", status = "primary", solidHeader = TRUE,
                                      collapsible = TRUE, plotOutput("boxplot", height = 250)),
                                  box(title="Density", status = "primary", solidHeader = TRUE,
                                      collapsible = TRUE, plotOutput("densityPlot", height = 250)),
                                  box(title="Histogram", status = "primary", solidHeader = TRUE,
                                      collapsible = TRUE, plotOutput("histogramPlot", height = 250)),
                                  box(title="Summary", status = "primary", solidHeader = TRUE,
                                      collapsible = TRUE, verbatimTextOutput("summary"))
                                )
                        )
                      )
                    )
     )

server <- function(input, output) {
  reactiveObject<-reactive({
   if(input$stops==TRUE){
      busStops<-filter(tbl_df(busCollection),!is.na(stop) & speed<3,215)
    }else{
      busStops<-filter(tbl_df(busCollection),!is.na(stop) & speed>=3,215)
    }
    if(input$ruta=="All"&& input$linea=="All"){
      filter(tbl_df(busStops))
    }else if(input$ruta=="All"&& input$linea!="All"){
      filter(tbl_df(busStops),  linea==input$linea)
    }else if(input$ruta!="All"&& input$linea=="All"){
      filter(tbl_df(busStops), ruta==input$ruta)
    }else{
      filter(tbl_df(busStops), ruta==input$ruta & linea==input$linea)
    }
  })
  output$boxplot <- renderPlot({
    boxplot(reactiveObject()$speed, main="Boxplot", xlab="Speed", horizontal=TRUE)
  })
  output$densityPlot <- renderPlot({
    plot_density(reactiveObject()$speed, title= "Density of speed")
  })
  output$histogramPlot <- renderPlot({
    plot_histogram(reactiveObject()$speed, title="Histogram of speed")
  })
  output$summary <- renderPrint({summary(reactiveObject()$speed)})
}

shinyApp(ui, server)

#Traffic monitor

library(shiny)
library(shinydashboard)
library(dplyr)
library(leaflet)
library(rgdal) 
library(raster)
library(DataExplorer)
library(plotly)

ui <- dashboardPage(skin = "black", 
                    dashboardHeader(title = "(Real-Time) Speed in Madrid",titleWidth = 450, 
                                    tags$li(class="dropdown",tags$script(src="leaflet.polylineoffset.js")
                                    ),
                                    tags$li(class="dropdown",
                                            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
                                    )
                    ),
                    dashboardSidebar(
                      sidebarMenu(
                        dateRangeInput('dateRange',label = h3('Filter by date'),start = as.Date('2019-12-10') , end = as.Date('2019-12-17')),
                        checkboxInput("stops", label = "Use stops", FALSE),
                        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
                      )
                    ),
                    dashboardBody(
                      tabItems(
                        # First tab content
                        tabItem(tabName = "dashboard",
                                
                                column(8, tags$style(type = "text/css", "#map {height: 90vh !important;}"), leafletOutput("map")
                                ),
                                column(4,fluidRow(tags$style(type = "text/css", "#densityPlot {height: 45vh !important;}"), plotOutput("densityPlot"), tags$style(type = "text/css", "#piePlot {height: 45vh !important;}"),plotlyOutput("piePlot"))
                                )
                        )
                      )
                    )
   )

server <- function(input, output) {
  reactiveObject<-reactive({
    busUnique<-subset(busCollection, time > as.character(input$dateRange[1]) & time < as.character(input$dateRange[2]))
    if(input$stops==FALSE){
      busUnique<-subset(busUnique, is.na(stop)==input$stops | speed>=3.215)
    }
    busUnique$uniqueSection<-paste(busUnique$vialId,busUnique$ruta)
    head(busUnique)
    groupBus<-busUnique%>%group_by(busUnique$uniqueSection) 
    groupBus %>% summarise(
      speed = mean(speed)
    )->groupBus
    networkUnique<-network
    networkUnique$uniqueSection<-paste(networkUnique$Link_ID,networkUnique$Sentido)
    networkJoined<-merge(networkUnique, groupBus, by.x="uniqueSection", by.y="busUnique$uniqueSection", all=TRUE)
    head(networkJoined)
    shapeData <- spTransform(networkJoined, CRS("+proj=longlat +ellps=GRS80"))
    spdSummary<-summary(shapeData$speed)
    shapeData$spdColor<- cut(shapeData$speed, breaks=c(spdSummary[1], spdSummary[2], spdSummary[4], spdSummary[6]), labels = c("red", "orange", "green"))
    shapeData
  })
  
  output$map <- renderLeaflet(
    {
      spdSummary<-summary(reactiveObject()$speed)
      leaflet() %>% addProviderTiles(providers$CartoDB.DarkMatter) %>% 
        addPolylines(data=subset(reactiveObject(),Sentido==1),col = ~spdColor, weight = 3, popup = ~paste("Speed: ",as.character(round(speed,2)), "km/h , Sentido: ",as.character(Sentido)),opacity=1, options=list(offset=-1.5), highlightOptions = highlightOptions(weight = 8,bringToFront = TRUE))%>%  
        addPolylines(data=subset(reactiveObject(),Sentido==2),col = ~spdColor, weight = 3, popup = ~paste("Speed: ",as.character(round(speed,2)), "km/h , Sentido: ",as.character(Sentido)),opacity=1,options=list(offset=1.5), highlightOptions = highlightOptions(weight = 8,bringToFront = TRUE))%>%
        addLegend(title = "Network Speeds",position="bottomright", opacity=1,colors = c("red", "orange", "green"), labels=c(paste(round(spdSummary[1],2), " - ", round(spdSummary[2],2), " km/h"),paste(round(spdSummary[2],2), " - ", round(spdSummary[4],2), " km/h"), paste(round(spdSummary[4],2), " - ", round(spdSummary[6],2), " km/h")), na.label = "NA")
    })
    output$densityPlot<-renderPlot({
    plot_density(reactiveObject()$speed)
  })
  output$piePlot<-renderPlotly({
    as.data.frame(reactiveObject()) %>%
      group_by(spdColor) %>%
      summarize(count = n()) %>%
      plot_ly(labels = c("Not Fluent","Fluent","High Fluency","Null"), values = ~count, 
              type="pie",
              textposition = 'inside', 
              textinfo='label+percent',
              marker = list(
                colors = ~spdColor,line = list(color = '#FFFFFF', width = 1)
              )
      ) %>%
      layout(
        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
}

shinyApp(ui, server)
