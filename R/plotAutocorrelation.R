#' @title Autocorrelation plot
#'
#' @description Plot i-th residual vs i+1-th residual. Checking autocorrelation of residuals.
#' Runs score, Durbin-Watson score
#'
#'
#' @param object An object of class ModelAudit
#' @param variable name of dependent or independent variable to order residuals. If NULL the fitted values are taken.
#' @param score Logical, if TRUE values of \link{scoreDW} and \link{scoreRuns} will be added
#'
#' @importFrom ggplot2 ggplot aes
#' @importFrom ggplot2 geom_point geom_hline geom_text
#' @importFrom ggplot2 ggtitle xlab ylab
#' @importFrom ggplot2 theme_classic
#'
#' @export
plotAutocorrelation <- function(object, variable=NULL, score=TRUE){
  x <- y <- NULL
  if(is.null(variable)) variable <- "Fitted values"
  plotData <- generateAutocorrelationDF(object, variable)

  p <- ggplot(plotData, aes(x, y)) +
      geom_point() +
      geom_hline(yintercept = 0) +
      xlab("residual i") +
      ylab("residual i+1") +
      ggtitle("Autocorrelation") +
      theme_classic()

  if(score==TRUE){
    score1 <- scoreDW(object)
    score2 <- scoreRuns(object)
    p <- p + geom_text(x = -Inf, y = Inf,
                       label = paste("Durbin-Watson Score:", round(score1$score,2), " Runs Score:", round(score2$score,2)),
                       hjust = -1, vjust = 1)
  }

  return(p)
}


generateAutocorrelationDF <- function(object, variable){
  if(variable == "Fitted values") {
    values <- object$fitted.values
  } else {
    values <- object$data[,variable]
  }
  n <- length(object$residuals)
  tmpDF <- data.frame(values = values, x = object$residuals)
  tmpDF <- dplyr::arrange(tmpDF, values)
  resultDF <- data.frame(x = tmpDF$x[-n], y = tmpDF$x[-1])
  return(resultDF)
}