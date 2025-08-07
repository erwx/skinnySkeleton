#!/usr/bin/env Rscript

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("Please install devtools first: install.packages('devtools')")
}
if (!requireNamespace("usethis", quietly = TRUE)) {
  stop("Please install usethis first: install.packages('usethis')")
}

read_from_terminal <- function(prompt) {
  cat(prompt, file = stderr())
  flush.console()
  if (.Platform$OS.type == "unix") {
    result <- system("read -r line < /dev/tty && echo \"$line\"", intern = TRUE)
    if (length(result) > 0 && nchar(result[1]) > 0) {
      return(trimws(result[1]))
    }
  }
  return(trimws(readLines("stdin", n = 1, warn = FALSE)))
}

pkg_name        <- read_from_terminal("Package name: ")
pkg_title       <- read_from_terminal("Package title: ")
author_name     <- read_from_terminal("Author name: ")
author_email    <- read_from_terminal("Author email: ")
pkg_description <- read_from_terminal("Package description (a few sentences): ")

if (nchar(pkg_name) == 0) {
  stop("Package name cannot be empty")
}

pkg_path <- normalizePath(file.path(getwd(), pkg_name), mustWork = FALSE)
cat("Creating package at:", pkg_path, "\n")

usethis::create_package(pkg_path, open = FALSE)
setwd(pkg_path)

desc_content <- paste0(
  "Package: ", pkg_name, "\n",
  "Title: ", pkg_title, "\n",
  "Version: 0.0.0.9000\n",
  "Authors@R: person('", author_name, "', email = '", author_email, "', role = c('aut', 'cre'))\n",
  "Description: ", pkg_description, "\n",
  "License: MIT + file LICENSE\n",
  "Encoding: UTF-8\n",
  "Roxygen: list(markdown = TRUE)\n"
)
writeLines(desc_content, "DESCRIPTION")

hello <- paste0(
  "#' Hello World Function\n",
  "#' @return A greeting\n",
  "#' @export\n",
  "hello <- function() {\n",
  "  'Hello, world!'\n",
  "}"
)
writeLines(hello, file.path("R", "hello.R"))

devtools::document()
usethis::use_mit_license()
devtools::check()

qmd_file <- file("example.qmd", open = "w")
user_os <- R.version$os

writeLines(c(
  "---",
  paste("title: \"", pkg_title, "\"", sep = ""),
  paste("author: \"", author_name, "\"", sep = ""),
  "params:",
  "  name: \"World\"",
  paste0("  os: \"", user_os, "\""),
  "engine: knitr",
  "---",
  "",
  paste("# Hello from ", pkg_title),
  "",
  "Hello, \`r params$name\`!",
  "",
  "This example shows basic parameterization. Your operating system appears to be: **\`r params$os\`**.",
  "",
  paste("Package created by ", author_name, ".")
  ),
  qmd_file
)
close(qmd_file)

system("git init")
system("git add .")
system("git commit -m 'Initial package setup'")

cat("To push to GitHub:\n")
cat("1. Create a new repository on GitHub\n")
cat("2. git remote add origin https://github.com/yourusername/", pkg_name, ".git\n")
cat("3. git push -u origin main\n")
