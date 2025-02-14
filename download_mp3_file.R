#install.packages("processx")  # Para executar comandos do sistema
#install.packages("glue")      # Para manipulação de strings

# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=SFW_fPi-3-Y"

# Pasta de saída para salvar o arquivo MP3
output_folder <- "audio_completo"
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
  cat(glue("Pasta criada: {output_folder}\n"))
}

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

# Função para baixar o áudio completo em MP3
baixar_audio_completo <- function(yt_dlp, video_url, output_folder) {
  cat("Iniciando o download do áudio completo...\n")
  output_file <- file.path(output_folder, "%(title)s.%(ext)s")
  tryCatch({
    processx::run(
      yt_dlp,
      c(
        "--extract-audio",
        "--audio-format", "mp3",
        "--output", output_file,
        video_url
      ),
      echo = TRUE
    )
    cat(glue("Download concluído! Arquivo salvo em: {output_folder}\n"))
  }, error = function(e) {
    cat("Erro durante o download do áudio:\n", e$message, "\n")
  })
}

# Executar o download do áudio completo
baixar_audio_completo(yt_dlp, video_url, output_folder)
