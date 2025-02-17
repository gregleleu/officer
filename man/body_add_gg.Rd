% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/docx_add.R
\name{body_add_gg}
\alias{body_add_gg}
\title{Add a 'ggplot' in a 'Word' document}
\usage{
body_add_gg(
  x,
  value,
  width = 6,
  height = 5,
  res = 300,
  style = "Normal",
  scale = 1,
  ...
)
}
\arguments{
\item{x}{an rdocx object}

\item{value}{ggplot object}

\item{width}{height in inches}

\item{height}{height in inches}

\item{res}{resolution of the png image in ppi}

\item{style}{paragraph style}

\item{scale}{Multiplicative scaling factor, same as in ggsave}

\item{...}{Arguments to be passed to png function.}
}
\description{
add a ggplot as a png image into an rdocx object.
}
\examples{
if( require("ggplot2") ){
  doc <- read_docx()

  gg_plot <- ggplot(data = iris ) +
    geom_point(mapping = aes(Sepal.Length, Petal.Length))

  if( capabilities(what = "png") )
    doc <- body_add_gg(doc, value = gg_plot, style = "centered" )

  print(doc, target = tempfile(fileext = ".docx") )
}
}
\seealso{
Other functions for adding content: 
\code{\link{body_add_blocks}()},
\code{\link{body_add_break}()},
\code{\link{body_add_caption}()},
\code{\link{body_add_docx}()},
\code{\link{body_add_fpar}()},
\code{\link{body_add_img}()},
\code{\link{body_add_par}()},
\code{\link{body_add_plot}()},
\code{\link{body_add_table}()},
\code{\link{body_add_toc}()}
}
\concept{functions for adding content}
