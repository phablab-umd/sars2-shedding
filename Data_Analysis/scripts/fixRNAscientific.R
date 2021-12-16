# format number Me+N into M x 10^N, but leave nonscientific if less than 1 x 10^3

fixRNAscientific <- function(x) {
  x1 <- as.numeric(x)
  if (x1<1000) {
    y <- x1 %>% format(scientific=FALSE) %>% as.character()
  }
  if (x1>=1000) {
    y <- x1 %>% sprintf("%.1e",.)
    if (x1<1e+10) {
      y <- y %>% gsub("e\\+0"," x 10^",.)
    } else {
      y <- y %>% gsub("e\\+"," x 10^",.)
    }
  }
  return(y)
}

# some of the table outputs have three numbers in them X (Y, Z), GMCIparse_fixsci applies fixRNAscientifc to them

GMCIparse_fixsci <- function(x) {
  x1 <- x %>% strsplit(",|\\(|\\)") %>% unlist() %>% as.numeric()
  x2 <- x1 %>% sapply(fixRNAscientific)
  y <- paste0(x2[1]," (",x2[2],", ",x2[3],")")
  return(y)
}