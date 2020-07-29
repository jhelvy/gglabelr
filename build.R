library(roxygen2)

# Create the documentation for the package
devtools::document()

# Install the package
devtools::install(force = TRUE)

# Load the package and view the summary
library(gglabelr)
help(package='gglabelr')

# Install from github
devtools::install_github('jhelvy/gglabelr')
