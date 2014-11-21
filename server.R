library(rCharts)
#TODO add progress indicator http://shiny.rstudio.com/articles/progress.html
#TODEO add a download method to allow user to download a analyze report of the log(consider to use slidfy)
#TODO add a numeric param to all view methods to make sliderInput in use. http://shiny.rstudio.com/articles/download.html
shinyServer(function(input, output) {

  get_data <- function(){
    file_path <- input$file1$datapath
    enc <- input$encoding
    get_parsed_data(file_path,enc)
  }
  
  output$logFormat <- renderUI({  
        switch(input$chatType,
               "QQ" =     selectInput("logFormat", "2.Choose a log Format:", choices = c("parsedCSV", "txt", "mht")),
               "Skype" = return(),#unused
               "Weixin" = return())#unused
  })
  
  output$AnalyzeTitle <- renderText({
    input$submit
    isolate({
      paste("<h4>Analyze result of [", input$viewType,"]</h4>")
    })
  })
  
  output$AnalyzeChart <- renderChart({
    input$submit
    validate(
      need(input$file1,"Please upload a log to analyze.")
      )
    isolate({
      parsed_data <- get_data()
      chart <- switch(input$viewType,
                      "msg count by day" = msg_cnt_by_day(parsed_data),
                      "top n speakers" = get_top_n_speakers(parsed_data),
                      "top keywords" = get_empty_chart())
      chart$addParams(dom = 'AnalyzeChart')
      return(chart)
    })
  })
  
  output$AnalyzePlot <- renderPlot({
    input$submit
    validate(
      need(input$file1,"Please upload a log to analyze.")
    )
    isolate({
      parsed_data <- get_data()
      switch(input$viewType,
             "msg count by day" = NULL,
             "top n speakers" = NULL,
             "top keywords" = 
                 get_wordcloud(parsed_data)          
             )
    })
  })
  
  output$download <- downloadHandler(
    filename <- function(){
      paste("Demo.csv")
    },
    content = function(file) {
      download.file(url = "http://fingerliu.qiniudn.com/files/gb2312.csv",destfile = file)
      #x <- read.csv("tmp",fileEncoding = "gb2312",quote = "\"")
      #save(x, file=file)
    }
  )
})