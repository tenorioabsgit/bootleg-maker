#install.packages("processx")  # Para executar comandos do sistema
#install.packages("glue")      # Para manipulação de strings

# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=UxbxkjM5aD4"

# Pasta de saída para salvar os arquivos MP3
output_folder <- "musicas_separadas"
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
  cat(glue("Pasta criada: {output_folder}\n"))
}

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

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
    "00:00", "09:09", "12:22", "16:06", "19:28", 
    "22:55", "27:45", "31:31", "34:25", "37:58", 
    "41:36", "43:57", "48:53", "52:30", "55:28", 
    "59:42", "1:03:24", "1:09:27", "1:12:01", "1:14:40"
  ),
  titulo = c(
    "Infinita Highway", "Partiu", "A Revolta dos Dândis I", 
    "Ando Só", "3ª do Plural", "Dom Quixote", 
    "Um Dia de Cada Vez", "A Montanha", 
    "Somos Quem Podemos Ser", "Refrão de Bolero", 
    "Piano Bar", "Pra Ser Sincero", 
    "Surfando Karmas & DNA", "O Preço", 
    "Eu Que Não Amo Você", "Armas Químicas e Poemas", 
    "O Exército de um Homem Só, I", "Ninguém = Ninguém", 
    "Pose", "Toda Forma de Poder"
  )
)






# Caminho para o arquivo de áudio completo
audio_completo <- file.path(output_folder, "audio_completo.mp3")

# Baixar o áudio completo
baixar_audio_completo(yt_dlp, video_url, audio_completo)

# Dividir o áudio em faixas
dividir_audio(ffmpeg, audio_completo, tracks, output_folder)
