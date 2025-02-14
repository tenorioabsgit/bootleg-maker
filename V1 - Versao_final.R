# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=4GU6aJLxOh4"

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

# Função para obter o título do vídeo
oter_titulo_video <- function(yt_dlp, video_url) {
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
titulo_video <- oter_titulo_video(yt_dlp, video_url)
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

# Definição dos tempos de início e títulos das faixas
tracks <- data.frame(
  inicio = c(
    "00:00", "03:33", "07:37", "10:12", "13:24", 
    "15:50", "18:44", "20:57", "25:29", "29:05", 
    "31:09", "36:47", "40:35", "43:36", "46:03", 
    "49:11", "53:00", "57:07", "59:57", "01:02:28", 
    "01:05:54", "01:09:02", "01:12:48", "01:15:18", 
    "01:18:20", "01:22:20", "01:23:35", "01:27:37", 
    "01:30:23", "01:34:01", "01:39:13", "01:45:40"
  ),
  titulo = c(
    "Fatal", "Other Side", "Education", "Undone", 
    "Don't Give Me No Lip", "My Father's Son", 
    "Push Me, Pull Me", "No Way", "Help Help", 
    "Sweet Lew", "Falling Down", "Last Soldier", 
    "In the Moonlight", "Black, Red, Yellow", 
    "Hitchhiker", "Force of Nature", "Brother", 
    "Let Me Sleep", "Angel", "Speed of Sound", 
    "Around the Bend", "Stranger Tribe", "Driftin'", 
    "Santa Cruz", "Out of My Mind", "I'm Open", 
    "Dead Man", "Bugs", "Hold On", "Dirty Frank", 
    "Of the Earth", "Just A Girl"
  )
)



# Caminho para o arquivo de áudio completo
audio_completo <- file.path(output_folder, "audio_completo.mp3")

# Baixar o áudio completo
baixar_audio_completo(yt_dlp, video_url, audio_completo)

# Dividir o áudio em faixas
dividir_audio(ffmpeg, audio_completo, tracks, output_folder)

# Lista todos os arquivos na pasta que começam com 'audio_completo'
arquivos <- list.files(output_folder, pattern = "^audio_completo", full.names = TRUE)

# Lista todos os arquivos na pasta que começam com 'audio_completo'
arquivos <- list.files(output_folder, pattern = "^audio_completo", full.names = TRUE)

# Remove os arquivos
file.remove(arquivos)
