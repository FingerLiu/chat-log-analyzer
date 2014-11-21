library(rCharts)
library(shiny)
source.with.encoding('qqLogAnalyzer.R', encoding='UTF-8')
#TODO find a way to use qq_log_parser.pl in R

options(shiny.usecairo = FALSE)

get_empty_chart <- function(){
  x<-rCharts$new()          
  x$addParams(height=0,width=0)
  x
}
