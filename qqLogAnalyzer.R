require(rCharts)
require(httr)
require(RJSONIO)
require(data.table)
#require(Rwordseg)
require(jiebaR)
require(tm)
require(wordcloud)
require(RColorBrewer)
#TODO fix Chinese stopwords problem
#TODO research why segmented terms have SPACE in them.

get_parsed_data <- function(file="data/gb2312.csv",fileEncoding = "gb2312"){
  paresed_data <- read.csv(file,header = TRUE,na.strings = "undefined",sep = ",",quote="\"",stringsAsFactors = FALSE,fileEncoding = fileEncoding)
  paresed_data
}

#fun1 message count influnced by day of month
msg_cnt_by_day <- function(paresed_data){
  dates <- as.Date(paresed_data$date,"%Y-%m-%d %H:%M:%S")
  elements <- format(dates,'%d')
  tmp_data <- data.frame(table(elements))
  msg_cnt <- tmp_data$Freq
  day_of_month_uniq <- tmp_data$elements
  type <- rep(x = "messageCount",times = length(day_of_month_uniq)) 
  df <- data.frame(day_of_month_uniq,msg_cnt,type, stringsAsFactors = FALSE)
  colnames(df) <- c("days","msgs","type")
  h1 <- hPlot(
    x = "days",
    y = "msgs",
    data = df,
    type = "line",
    title = "message count by day of month",
    group ="type"
  )
  h1$yAxis(min = 0,title = list(text = "message count"),labels = list(format = "{value}"));
  h1$tooltip(useHTML = T, formatter = "#! function() {
        return 'Day of a month: <b>' + this.x + '</b><br> Message count:<b> '+ this.y+'</b>';
    } !#")
  h1$legend(enabled = FALSE)
  h1
}

get_top_n_speakers <- function(paresed_data,n = 50){
  data <- subset(paresed_data,select = c(id,name,title))
  #data$title<-factor(data$title)
  freq_data <- data.frame(table(data$id))
  colnames(freq_data) <- c("id","msg_cnt")
  
  desc_data <- data[!duplicated(data$id),]
  
  df <- merge(desc_data,freq_data,by="id")
  set.seed(666)
  random <- runif(nrow(desc_data))
  df <- cbind(df,random)
  df <- df[order(df$msg_cnt,decreasing = TRUE,na.last = TRUE),]
  if(nrow(df)< n){
    n <- nrow(df)
  }
  df <- head(x = df,n = n)
  colnames(df)<-c('id','name','title','y','x')
  #df$name = iconv(df$name,from = "gb2312",to = "utf-8")
  #df$title = iconv(df$title,from = "gb2312",to = "utf-8")
  series <- lapply(split(df,df$title),function(x){
    res <- lapply(split(x, rownames(x)), as.list)
    names(res) <- NULL
    return(res)
  })
  
  a <- rCharts::Highcharts$new()
  invisible(sapply(series, function(x) {
    a$series(data = x, type = "scatter", name = x[[1]]$title)
  }
  ))
  
  a$plotOptions(
    scatter = list(
      cursor = "pointer", 
      marker = list( 
        radius = 6
      )
    )
  )
  
  a$xAxis(title = " ", labels = list(format = " "))
  a$yAxis(min = 0,title = list(text = "message count"), labels = list(format = "{value}"))
  
  a$tooltip(useHTML = T, formatter = "#! function() {
        return 'Msg count: <b>' + this.y + '</b><br> Title:<b> '+ this.series.name+'</b><br>Name:<b>'+this.point.name+'</b>';
    } !#")
  
  a$legend(
    align = 'right', 
    verticalAlign = 'middle', 
    layout = 'vertical', 
    title = list(text = "member type")
  )
  a$title(text =  paste("the most active ",n," members",  sep = " ")) 
  a
}

#not in use
# get_stopwords_CN <- function(path = "F:/dic/stopwords_CN.txt"){
#   data_stw_CN = read.table(file = path,quote = "",colClasses="character",fileEncoding = "gb2312")
#   stopwords_CN=c(NULL)
#   for(i in 1:dim(data_stw_CN)[1]){
#     stopwords_CN = c(stopwords_CN,data_stw_CN[i,1])
#   }
#   stopwords_CN
# }

#not in use
# get_stopwords_CN_utf8 <- function(path = "F:/dic/stopwords_CN_UTF8.txt"){
#   data_stw_CN = read.table(file = path,quote = "",colClasses="character",fileEncoding = "utf-8")
#   stopwords_CN=c(NULL)
#   for(i in 1:dim(data_stw_CN)[1]){
#     stopwords_CN = c(stopwords_CN,data_stw_CN[i,1])
#   }
#   stopwords_CN
# }

#TODO now n is not used
#this version is a simple version without color.
#If you want a wordcloud with color please use get_wordcloud2
# get_wordcloud_Rwordseg <- function(paresed_data,n=50){
#   if(require(Rwordseg)){
#     msg <- paresed_data$message
#     
#     #seg words and change msg to a list
#     msg <- segmentCN(msg,returnType = 'tm')
#     
#     #build temp corpus
#     c <- Corpus(VectorSource(x = msg))
#     c <- tm_map(x = c,removeNumbers)
#     wordcloud(c,max.words = 50)
#   }
# }

get_wordcloud <- function(parsed_data,n=50){

  raw_msg <- parsed_data$message
  mixseg = worker(stop_word = "data//stopwords_CN.txt")
  msg <- sapply(raw_msg,function(x){
    paste(mixseg<=x,collapse = " ")
  })
  
  #build temp corpus
  c <- Corpus(VectorSource(x = msg))
  c <- tm_map(x = c,removeNumbers)
  wordcloud(c,max.words = n)
}

#TODO n is not in use yet
#TODO how can I remove Chinese stopword well!!
#word cloud with color
# get_wordcloud2 <- function(paresed_data,n=50){
#   msg <- paresed_data$message
#   
#   #seg words and change msg to a list
#   msg <- segmentCN(msg,returnType = 'tm')
#   
#   #build temp corpus
#   c <- Corpus(VectorSource(x = msg))
#   
#   #clean data
#   c <- tm_map(x = c,stripWhitespace)
#   c <- tm_map(x = c,content_transformer(tolower))
#   c <- tm_map(x = c,removeWords,stopwords(kind = "en"))
#   c <- tm_map(x = c,removePunctuation)
#   c <- tm_map(x = c,removeNumbers)
#   
#   #c <- tm_map(x = c,removeWords,get_stopwords_CN_utf8())
#   
#   #creat DTM
#   #dtm <- DocumentTermMatrix(x = c,control = list(stopwords = get_stopwords_CN()))
#   dtm <- DocumentTermMatrix(x = c)
#   dtm_removed = removeSparseTerms(x = dtm,sparse = 0.999)
#   
#   #for test
#   #FreqTerms <- findFreqTerms(dtm_removed,3)
#   
#   #get freq cnt
#   df <- as.data.frame(inspect(dtm_removed))
#   Sums <- colSums(df)
#   sort(x = Sums,decreasing = TRUE,na.last = TRUE)
#   Sums <- Sums[1:150]
#   
#   #draw wordcloud
#   op<-par(bg="lightyellow")
#   rainbowLevels<-rainbow((Sums)/(max(Sums)-10))
#   wordcloud(enc2native(names(Sums)),Sums,col=rainbow(length(Sums)))
#   par(op)
# }

#the old version of get_top_n_speakers. out of date
get_top_n_speakers_old <- function(n = 50){
  data <- subset(paresed_data,select = c(id,name,title))
  freq_data <- data.frame(table(data$id))
  colnames(freq_data) <- c("id","msg_cnt")
  
  desc_data <- data[!duplicated(data$id),]
  
  df <- merge(desc_data,freq_data,by="id")
  set.seed(666)
  random <- runif(nrow(desc_data))
  df <- cbind(df,random)
  df <- df[order(df$msg_cnt,decreasing = TRUE,na.last = TRUE),]
  
  df <- head(x = df,n = n)
  
  h2 <- hPlot(
    x = "random",
    y = "msg_cnt",
    data = df,
    type = "scatter",
    #title = paste("top",n,"speakers",sep=" "),
    title = "the most active 50 members",
    group ="title",
    radius = 5
  )
  
  h2$xAxis(title = NULL,labels = list(format = " "));
  h2$tooltip(useHTML = T, formatter = "#! function() {
        return 'Msg count: <b>' + this.y + '</b><br> Title:<b> '+ this.series.name+'</b><br>name:<b>'+this.name+'</b>';
    } !#")
  h2
}
