# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=8CZKw8mBny8"

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

# Função para obter o título do vídeo
obter_titulo_video <- function(yt_dlp, video_url) {
  tryCatch({
    result <- processx::run(
      yt_dlp,
      c("--get-title", video_url),
      echo = FALSE
    )
    titulo <- trimws(result$stdout)
    cat(glue("Título do vídeo: {titulo}\n"))
    return(titulo)
  }, error = function(e) {
    cat("Erro ao obter o título do vídeo:\n", e$message, "\n")
    stop("Não foi possível obter o título do vídeo.")
  })
}

# Obter o título do vídeo para usar como nome da pasta
titulo_video <- obter_titulo_video(yt_dlp, video_url)
output_folder <- titulo_video
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
  cat(glue("Pasta criada: {output_folder}\n"))
}

# Função para baixar o vídeo completo e extrair o áudio em MP3
baixar_audio_completo <- function(yt_dlp, video_url, output_file) {
  cat("Baixando o áudio completo...\n")
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
    cat(glue("Download concluído: {output_file}\n"))
  }, error = function(e) {
    cat("Erro durante o download do áudio:\n", e$message, "\n")
  })
}

# Função para dividir o áudio em faixas com base nos tempos e títulos fornecidos
dividir_audio <- function(ffmpeg, input_file, tracks, output_folder) {
  for (i in seq_along(tracks$titulo)) {
    start_time <- tracks$inicio[i]
    end_time <- if (i < length(tracks$inicio)) tracks$inicio[i + 1] else ""
    title <- tracks$titulo[i]
    output_file <- file.path(output_folder, glue("{sprintf('%02d', i)} - {title}.mp3"))
    
    ffmpeg_args <- c("-i", input_file, "-ss", start_time)
    if (end_time != "") {
      ffmpeg_args <- c(ffmpeg_args, "-to", end_time)
    }
    ffmpeg_args <- c(ffmpeg_args, "-c", "copy", output_file)
    
    cat(glue("Extraindo faixa: {title}...\n"))
    tryCatch({
      processx::run(ffmpeg, ffmpeg_args, echo = TRUE)
      cat(glue("Faixa '{title}' salva em: {output_file}\n"))
    }, error = function(e) {
      cat(glue("Erro ao extrair a faixa '{title}':\n"), e$message, "\n")
    })
  }
}

# Criando o dataframe com os dados das faixas
# Criando o dataframe com os dados das faixas
tracks_data <- data.frame(
  inicio = c(
    "00:00", "01:03", "04:38", "04:55", "08:00",
    "08:10", "11:42", "13:02", "20:32", "24:30",
    "24:47", "28:40", "33:15", "34:20", "36:48",
    "40:24", "41:40", "42:22"
  ),
  titulo = c(
    "A Boca Oca", "João", "Saga", "O Real Resiste", "Bacanas",
    "O Pulso", "O Buraco do Espelho", "Meu Coração", 
    "De Outra Galáxia", "O Que Você Mais Teme", 
    "Vilarejo", "Na Barriga do Vento", "Pensamento", 
    "Azul Vazio", "Contato Imediato", "Um Deus", 
    "O Corpo", "Saia de Mim"
  )
)

# Visualizando o dataframe
print(tracks_data)


# Visualizando o dataframe
print(tracks_data)


print(tracks_data)


# Caminho para o arquivo de áudio completo
audio_completo <- file.path(output_folder, "audio_completo.mp3")

# Baixar o áudio completo
baixar_audio_completo(yt_dlp, video_url, audio_completo)

# Dividir o áudio em faixas
dividir_audio(ffmpeg, audio_completo, tracks_data, output_folder)

# Lista todos os arquivos na pasta que começam com 'audio_completo'
arquivos <- list.files(output_folder, pattern = "^audio_completo", full.names = TRUE)

# Remove os arquivos desnecessários
file.remove(arquivos)
