Install R on your system

Added ignored files / directories to .renvignore

Start an R shell

> install.packages("renv")
> renv::init(project="./R")

> renv::status()
> renv::install("package...")
> renv::snapshot()