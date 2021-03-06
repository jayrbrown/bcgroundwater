# Copyright 2015 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' Create a graph of historical monthly water level deviations
#'
#' Create a graph of historical median monthly water level deviations from yearly 
#' average with 5th and 95th percentiles
#' @import dplyr ggplot2
#' @importFrom lubridate month
#' 
#' @param  dataframe dataframe containing 'Well_Num', 'Date', 'dev_med_GWL'
#' @param  splines logical: smooth the line using splines?
#' @param  last12 logical: plot the last 12 monthly readings as points?
#' @param  save logical: save as a pdf?
#' @param  path path to folder in which to save if save=TRUE
#' @param  opts other options passed on to ggplot2
#' @export
#' @return A ggplot object
#' @examples \dontrun{
#'
#'}
gwlMonthlyPlot <- function(dataframe, splines=TRUE, last12=TRUE, save=FALSE, path="./", opts=NULL) {
  
  wellNum <- dataframe$Well_Num[1]
  
  data <- dataframe %>%
    group_by(month=month(Date, label=TRUE)) %>%
    summarize(dev_med = mean(dev_med_GWL, na.rm=TRUE)
              , dev_Q5 = quantile(dev_med_GWL, prob=0.05
                                  , na.rm=TRUE)
              , dev_Q95 = quantile(dev_med_GWL, prob=0.95
                                   , na.rm=TRUE))
  
  data.last.12 <- tail(dataframe[,c("Date","dev_med_GWL")],12)
  row.names(data.last.12) <- 1:12
  
  if (splines) {
    splines.df <- as.data.frame(spline(as.numeric(data$month), data$dev_med
                                       , method="fmm"))
    splines.df$y_Q5 <- spline(as.numeric(data$month), data$dev_Q5
                              , method="fmm")$y
    splines.df$y_Q95 <- spline(as.numeric(data$month), data$dev_Q95
                               , method="fmm")$y
    names(splines.df) <- names(data)
    data <- splines.df
  }
  
  plot.monthly <- ggplot(data=data, aes(x=as.numeric(month), y=dev_med)) + 
    geom_ribbon(aes(ymin=dev_Q5, ymax=dev_Q95, fill="#1E90FF"), alpha=0.2) + 
    geom_line(aes(colour="#1E90FF", alpha=0.4), size=1) + 
    labs(title="Monthly groundwater level deviation", x="Month"
         , y ="Difference from yearly average GWL (m)") + 
    theme(panel.background=element_rect(fill="white")
          , line=element_line(colour="grey50")
          , text=element_text(colour="grey50")
          , legend.position="top", legend.box="vertical"
          , legend.box.just = "left"
          # , axis.text.x=element_text(angle=45) # May need if using full month names
          ) + 
    scale_y_reverse() +
    scale_x_continuous(breaks=1:12, labels=month.abb) + 
    scale_fill_identity(name = '', guide = 'legend'
                        , labels = c('Range of 90% of water levels')) + 
    scale_colour_identity(name=''
                        , labels=c("Mean deviation from yearly average")
                        , guide="legend") + 
    scale_alpha_identity(name='', labels=NA) + 
    opts
  
  if (save) {
    ggsave(filename=paste0(path, "monthly_chart_well_", WellNum, ".pdf")
           , plot=plot.monthly)
  }
  
  return(plot.monthly)
  
}
