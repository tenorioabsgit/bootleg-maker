# Carregar pacotes necessários
library(processx)
library(glue)

# Função para sanitizar nomes de arquivos/pastas
sanitizar_nome <- function(nome) {
  gsub("[/\\:*?\"<>|]", "_", nome) # Substituir caracteres inválidos por "_"
}

# Função para detectar se é playlist ou vídeo
detectar_tipo <- function(video_url) {
  if (grepl("list=", video_url)) {
    return("playlist")
  } else {
    return("video")
  }
}

# Função para baixar áudios em MP3 de uma playlist ou vídeo
baixar_audios <- function(yt_dlp, video_url, output_folder) {
  cat("Iniciando o download dos áudios...\n")
  tryCatch({
    processx::run(
      yt_dlp,
      c(
        "--extract-audio",
        "--audio-format", "mp3",
        "--output", file.path(output_folder, "%(playlist_index)s - %(title)s.%(ext)s"),
        video_url
      ),
      echo = TRUE
    )
    cat("Download de áudios concluído.\n")
  }, error = function(e) {
    cat("Erro durante o download:\n", e$message, "\n")
  })
}

# Caminhos para yt-dlp (presume que está no PATH do sistema)
yt_dlp <- "yt-dlp"

# URL de vídeo ou playlist
video_url <- "https://www.youtube.com/watch?v=NQdpjLh9xok"

# Detectar tipo (playlist ou vídeo)
tipo <- detectar_tipo(video_url)
cat(glue("Tipo detectado: {tipo}\n"))

# Nome fixo para a pasta
output_folder <- "audios_playlist"
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
  cat(glue("Pasta criada: {output_folder}\n"))
}

# Baixar os áudios
baixar_audios(yt_dlp, video_url, output_folder)

cat("Processo concluído. Os áudios foram salvos em:", output_folder, "\n")
