spinDependency <- function() {
  list(
    htmlDependency(
      "js",
      version = "1.1.2",
      src = c(file = "www/js"),
      script = c(
        "spin.min.js",
        "leaflet.spin.min.js",
        "leaflet.spin-binding.js"
      ),
      stylesheet = c("spin.css"),
      all_files = TRUE
    )
  )
}

add_Spinner <- function(map) {
  map$dependencies <- c(map$dependencies, spinDependency())
  map
}


start_Spinner <- function(map, options = NULL) {
  invokeMethod(map, NULL, "spinner", TRUE, options)
}

stop_Spinner <- function(map) {
  invokeMethod(map, NULL, "spinner", FALSE)
}