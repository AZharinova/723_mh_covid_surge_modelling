% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_model_output_helpers.R
\name{surge_table}
\alias{surge_table}
\title{Surge Table}
\usage{
surge_table(model_output, column, column_name)
}
\arguments{
\item{model_output}{output from \code{run_model()} and \code{get_model_output()}}

\item{column}{the column in `model_output` to calculate the summary for, either "group", "condition" or "treatment"}

\item{column_name}{what to name the \code{column} in the new table}
}
\value{
a tibble with more descriptive column names
}
\description{
Helper function to take output from \code{surge_summary} and produce a table of data for display in the surge tabs.
}
