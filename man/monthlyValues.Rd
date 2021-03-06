% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/monthlyValues.R
\name{monthlyValues}
\alias{monthlyValues}
\title{Obtain a single groundwater level for each month}
\usage{
monthlyValues(df)
}
\arguments{
\item{df}{data frame with columns EMS_ID, Well_Num, Date, GWL}
}
\value{
a data frame with one value per month. Does not estimate values
        for months where there were 0 observations.
}
\description{
Assigns each reading to a month; sometimes there are several readings in a
month that may be better assigned to a different month if they are at the
border.  Does not estimate values for months where there were 0 observations.
}
\examples{
\dontrun{

}
}

