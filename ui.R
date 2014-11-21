library(rCharts)

#TODO  add support for other logFormat mht and txt
#TODO  add full support for utf-8 and gb2312
#TODO  add support for Skype and weixin

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Chat log analyzer Demo"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(

    helpText("Upload a file before you Choose a analyze method"),
    
    selectInput("viewType","Choose a analyze method",
                choices = c("msg count by day","top n speakers","top keywords")),
    
    tags$hr(),
    
    selectInput("chatType", "1.Choose a chat type:",
                choices = c("QQ", "Skype", "Weixin")),
    
    ##QQ's panel
    conditionalPanel(
      condition = "input.chatType == 'QQ'",
      
      uiOutput("logFormat"),
      
      ##only parsedCSV is supported now,so hide detail options when logFormat is not parsedCSV
      conditionalPanel(
        condition = "input.logFormat == 'parsedCSV'",
        radioButtons('encoding', '3.Encoding',
                     c('utf-8'='utf-8',
                       'gb2312'='gb2312'),
                     'gb2312'),
        
        fileInput('file1', '4.Upload chart log',
                  accept=c('text/CSV', 
                           'text/comma-separated-values',
                           'text/plain', 
                           'text/mht',
                           '.mht',
                           '.txt',
                           '.CSV')),
        actionButton(inputId = "submit",label = "GO!"),
        tags$hr(),
        helpText("If you don't have a parsedCSV,you can download this , and upload it to server."),
        downloadButton('download', 'Download Demo parsedCSV')
        
        
      ),
      
      conditionalPanel(
        condition = "input.logFormat != 'parsedCSV'",
        helpText("only logFormat of parsedCSV is supported until now,please select parsedCSV in logFormat")
      )
    ),
    
    ##Skype and Weixin's panel 
    conditionalPanel(
      condition = "input.chatType != 'QQ'",
      helpText("only log of QQ is supported until now,please select QQ in chatType.")
      )

  ),
  
  mainPanel(
    h2("Analyze Zone"),
    htmlOutput("AnalyzeTitle"),
    conditionalPanel(
      condition = "input.viewType =='msg count by day' ||input.viewType == 'top n speakers'",
      showOutput("AnalyzeChart", "Highcharts")
      
                     ),
    conditionalPanel(
      condition = "input.viewType == 'top keywords'",
      plotOutput("AnalyzePlot")
    )
  )
))