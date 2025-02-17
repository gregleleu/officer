# utils ----
is_scalar_character <- function( x ) {
  is.character(x) && length(x) == 1
}
is_scalar_logical <- function( x ) {
  is.logical(x) && length(x) == 1
}



# functions ----


#' @export
#' @title Replace text at a bookmark location
#' @description Replace text content enclosed in a bookmark
#' with different text. A bookmark will be considered as valid if enclosing words
#' within a paragraph; i.e., a bookmark along two or more paragraphs is invalid,
#' a bookmark set on a whole paragraph is also invalid, but bookmarking few words
#' inside a paragraph is valid.
#' @param x a docx device
#' @param bookmark bookmark id
#' @param value the replacement string, of type character
#' @examples
#' doc <- read_docx()
#' doc <- body_add_par(doc, "a paragraph to replace", style = "centered")
#' doc <- body_bookmark(doc, "text_to_replace")
#' doc <- body_replace_text_at_bkm(doc, "text_to_replace", "new text")
body_replace_text_at_bkm <- function( x, bookmark, value ){

  stopifnot(is_scalar_character(value), is_scalar_character(bookmark))
  x$doc_obj$cursor_replace_first_text(bookmark, value)
  x
}


#' @export
#' @rdname body_replace_text_at_bkm
#' @examples
#'
#'
#' # demo usage of bookmark and images ----
#' template <- system.file(package = "officer", "doc_examples/example.docx")
#'
#' img.file <- file.path( R.home("doc"), "html", "logo.jpg" )
#'
#' doc <- read_docx(path = template)
#' doc <- headers_replace_img_at_bkm(x = doc, bookmark = "bmk_header",
#'                                   value = external_img(src = img.file, width = .53, height = .7))
#' doc <- footers_replace_img_at_bkm(x = doc, bookmark = "bmk_footer",
#'                                   value = external_img(src = img.file, width = .53, height = .7))
#' print(doc, target = tempfile(fileext = ".docx"))
#'
body_replace_img_at_bkm <- function( x, bookmark, value ){

  stopifnot(inherits(x, "rdocx"),
            is_scalar_character(bookmark),
            inherits(value, "external_img"))

  width <- attr(value, "dims")$width
  height <- attr(value, "dims")$height
  x$doc_obj$cursor_replace_first_img(bookmark, as.character(value), width, height)

  x
}

docxpart_replace_img_at_bkm <- function( x, bookmark, value, part ){

  stopifnot(inherits(x, "rdocx"))
  stopifnot(is_scalar_character(bookmark))
  stopifnot(inherits(value, "external_img"))

  width <- attr(value, "dims")$width
  height <- attr(value, "dims")$height

  for(docpart in x[[part]]){
    if( docpart$has_bookmark(bookmark) )
      docpart$cursor_replace_first_img(bookmark, value, width, height)
  }
  x
}



#' @export
#' @rdname body_replace_text_at_bkm
headers_replace_text_at_bkm <- function( x, bookmark, value ){
  stopifnot(is_scalar_character(value), is_scalar_character(bookmark))
  for(header in x$headers){
    if( header$has_bookmark(bookmark) )
      header$cursor_replace_first_text(bookmark, value)
  }

  x
}

#' @export
#' @rdname body_replace_text_at_bkm
headers_replace_img_at_bkm <- function( x, bookmark, value ){
  docxpart_replace_img_at_bkm(x = x, bookmark = bookmark, value = value, part = "headers")
}



#' @export
#' @rdname body_replace_text_at_bkm
footers_replace_text_at_bkm <- function( x, bookmark, value ){
  stopifnot(is_scalar_character(value), is_scalar_character(bookmark))
  for(footer in x$footers){
    if( footer$has_bookmark(bookmark) )
      footer$cursor_replace_first_text(bookmark, value)
  }
  x
}

#' @export
#' @rdname body_replace_text_at_bkm
footers_replace_img_at_bkm <- function( x, bookmark, value ){
  docxpart_replace_img_at_bkm(x = x, bookmark = bookmark, value = value, part = "footers")
}


#' @export
#' @title Replace text anywhere in the document
#' @description Replace text anywhere in the document, or at a cursor.
#'
#' Replace all occurrences of old_value with new_value. This method
#' uses \code{\link{grepl}}/\code{\link{gsub}} for pattern matching; you may
#' supply arguments as required (and therefore use \code{\link{regex}} features)
#' using the optional \code{...} argument.
#'
#' Note that by default, grepl/gsub will use \code{fixed=FALSE}, which means
#' that \code{old_value} and \code{new_value} will be interepreted as regular
#' expressions.
#'
#' \strong{Chunking of text}
#'
#' Note that the behind-the-scenes representation of text in a Word document is
#' frequently not what you might expect! Sometimes a paragraph of text is broken
#' up (or "chunked") into several "runs," as a result of style changes, pauses
#' in text entry, later revisions and edits, etc. If you have not styled the
#' text, and have entered it in an "all-at-once" fashion, e.g. by pasting it or
#' by outputing it programmatically into your Word document, then this will
#' likely not be a problem. If you are working with a manually-edited document,
#' however, this can lead to unexpected failures to find text.
#'
#' You can use the officer function \code{\link{docx_show_chunk}} to
#' show how the paragraph of text at the current cursor has been chunked into
#' runs, and what text is in each chunk. This can help troubleshoot unexpected
#' failures to find text.
#' @seealso \code{\link{grep}}, \code{\link{regex}}, \code{\link{docx_show_chunk}}
#' @author Frank Hangler, \email{frank@plotandscatter.com}
#' @param x a docx device
#' @param old_value the value to replace
#' @param new_value the value to replace it with
#' @param only_at_cursor if \code{TRUE}, only search-and-replace at the current
#' cursor; if \code{FALSE} (default), search-and-replace in the entire document
#' (this can be slow on large documents!)
#' @param warn warn if \code{old_value} could not be found.
#' @param ... optional arguments to grepl/gsub (e.g. \code{fixed=TRUE})
#' @examples
#' doc <- read_docx()
#' doc <- body_add_par(doc, "Placeholder one")
#' doc <- body_add_par(doc, "Placeholder two")
#'
#' # Show text chunk at cursor
#' docx_show_chunk(doc)  # Output is 'Placeholder two'
#'
#' # Simple search-and-replace at current cursor, with regex turned off
#' doc <- body_replace_all_text(doc, old_value = "Placeholder",
#'   new_value = "new", only_at_cursor = TRUE, fixed = TRUE)
#' docx_show_chunk(doc)  # Output is 'new two'
#'
#' # Do the same, but in the entire document and ignoring case
#' doc <- body_replace_all_text(doc, old_value = "placeholder",
#'   new_value = "new", only_at_cursor=FALSE, ignore.case = TRUE)
#' doc <- cursor_backward(doc)
#' docx_show_chunk(doc) # Output is 'new one'
#'
#' # Use regex : replace all words starting with "n" with the word "example"
#' doc <- body_replace_all_text(doc, "\\bn.*?\\b", "example")
#' docx_show_chunk(doc) # Output is 'example one'
body_replace_all_text <- function( x, old_value, new_value,
                                   only_at_cursor = FALSE,
                                   warn = TRUE, ... ){
  stopifnot(is_scalar_character(old_value),
            is_scalar_character(new_value),
            is_scalar_logical(only_at_cursor))
  x$doc_obj$replace_all_text(old_value, new_value, only_at_cursor, warn = warn, ...)
  x
}

#' @export
#' @title Show underlying text tag structure
#' @description Show the structure of text tags at the current cursor. This is
#' most useful when trying to troubleshoot search-and-replace functionality
#' using \code{\link{body_replace_all_text}}.
#' @seealso \code{\link{body_replace_all_text}}
#' @param x a docx device
#' @examples
#' doc <- read_docx()
#' doc <- body_add_par(doc, "Placeholder one")
#' doc <- body_add_par(doc, "Placeholder two")
#'
#' # Show text chunk at cursor
#' docx_show_chunk(doc)  # Output is 'Placeholder two'
docx_show_chunk <- function( x ){
  x$doc_obj$docx_show_chunk()
  invisible(x)
}




#' @export
#' @rdname body_replace_all_text
#' @section header_replace_all_text:
#' Replacements will be performed in each header of all sections.
headers_replace_all_text <- function( x, old_value, new_value, only_at_cursor = FALSE, warn = TRUE,  ... ){
  stopifnot(is_scalar_character(old_value),
            is_scalar_character(new_value),
            is_scalar_logical(only_at_cursor))

  for(header in x$headers){
    header$replace_all_text(old_value, new_value, only_at_cursor, warn = warn, ...)
  }

  x
}
#' @export
#' @rdname body_replace_all_text
#' @section header_replace_all_text:
#' Replacements will be performed in each footer of all sections.
footers_replace_all_text <- function( x, old_value, new_value, only_at_cursor = FALSE, warn = TRUE, ... ){
  stopifnot(is_scalar_character(old_value),
            is_scalar_character(new_value),
            is_scalar_logical(only_at_cursor))

  for(footer in x$footers){
    footer$replace_all_text(old_value, new_value, only_at_cursor, warn = warn, ...)
  }

  x
}

#' @export
#' @title Remove unused media from a document
#' @description The function will scan the media
#' directory and delete images that are not used
#' anymore. This function is to be used when images
#' have been replaced many times.
#' @param x \code{rdocx} or \code{rpptx} object
#' @keywords internal
sanitize_images <- function(x){

  rel_files <- list.files(x$package_dir, pattern = "\\.xml.rels$", recursive = TRUE, full.names = TRUE)

  image_files <- lapply(rel_files,
                        function(x){
                          zz <- read_xml(x)
                          rels <- xml_children(zz)
                          rels <- rels[xml_attr(rels, "Type") %in% "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"]
                          xml_attr(rels, "Target")
                        })
  image_files <- unique(unlist(image_files))

  if(inherits(x, "rdocx")){
    base_doc <- file.path(x$package_dir, "word")
    existing_img <- list.files(
      file.path(base_doc, "media"),
      pattern = "\\.(png|jpg|jpeg|eps|emf)$",
      ignore.case = TRUE,
      recursive = TRUE, full.names = TRUE)
    existing_img <- gsub(paste0(base_doc, "/"), "", existing_img, fixed = TRUE)
    unlink(file.path(base_doc,
                     setdiff(image_files, existing_img)
                     ), force = TRUE)
  } else if(inherits(x, "rpptx")){
    base_doc <- file.path(x$package_dir, "ppt")
    existing_img <- list.files(
      file.path(base_doc, "media"),
      pattern = "\\.(png|jpg|jpeg|eps|emf)$",
      ignore.case = TRUE,
      recursive = TRUE, full.names = TRUE)
    existing_img <- gsub(paste0(base_doc, "/"), "",
                         existing_img, fixed = TRUE)
    unlink(file.path(base_doc, setdiff(image_files, existing_img)), force = TRUE)
  }
  x
}




