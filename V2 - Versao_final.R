# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=_0YXbVRhUL0"

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

# Função para sanitizar nomes de arquivos
sanitizar_nome <- function(nome) {
  gsub("[^A-Za-z0-9 _.-]", "_", nome)
}

# Função para obter o título do vídeo
obter_titulo_video <- function(yt_dlp, video_url) {
  tryCatch({
    result <- processx::run(
      yt_dlp,
      c("--get-title", video_url),
      echo = FALSE
    )
    titulo <- trimws(result$stdout)
    titulo <- sanitizar_nome(titulo)
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
    title <- sanitizar_nome(tracks$titulo[i])
    output_file <- file.path(output_folder, glue("{sprintf('%02d', i)} - {title}.mp3"))
    
    ffmpeg_args <- c("-i", input_file, "-ss", start_time)
    if (end_time != "") {
      duration <- as.numeric(difftime(
        strptime(end_time, "%H:%M:%S"),
        strptime(start_time, "%H:%M:%S"),
        units = "secs"
      ))
      ffmpeg_args <- c(ffmpeg_args, "-t", as.character(duration))
    }
    ffmpeg_args <- c(ffmpeg_args, "-c", "copy", output_file)
    
    cat(glue("Extraindo faixa: {title}...\n"))
    tryCatch({
      processx::run(ffmpeg, ffmpeg_args, echo = TRUE)
      if (file.exists(output_file) && file.info(output_file)$size > 0) {
        cat(glue("Faixa '{title}' salva em: {output_file}\n"))
      } else {
        cat(glue("Falha ao salvar a faixa '{title}'.\n"))
      }
    }, error = function(e) {
      cat(glue("Erro ao extrair a faixa '{title}':\n"), e$message, "\n")
    })
  }
}

# Definição dos tempos de início e títulos das faixas
tracks_data <- data.frame(
  inicio = c(
    "0:00:01", "0:02:37", "0:05:42", "0:09:29", "0:13:40",
    "0:19:16", "0:23:44", "0:26:56", "0:30:33", "0:33:47",
    "0:36:06", "0:45:22", "0:48:53", "0:54:31", "0:59:20",
    "1:02:38", "1:05:41", "1:08:44", "1:12:40", "1:17:24"
  ),
  titulo = c(
    "Início",
    "A Lei Desse Troço (Paulo Miklos / Emicida)",
    "Risco Azul (Paulo Miklos / Céu / Pupillo)",
    "Flores (Antonio Bellotto / Paulo Miklos / Sergio Britto / Charles de Souza Gavin)",
    "Vou te Encontrar (Nando Reis)",
    "Comida (Marcelo Fromer / Arnaldo Antunes / Sergio Britto)",
    "Vigia (Paulo Miklos / Russo Passapusso)",
    "Eu Vou (Tim Bernardes)",
    "Estou Pronto (Guilherme Arantes / Paulo Miklos)",
    "Um bom Lugar (Sabotage)",
    "Pra Dizer Adeus (Nando Reis / Tony Bellotto)",
    "Porque Eu Sei Que é Amor (Paulo Miklos / Sergio Britto)",
    "Isso (Tony Bellotto)",
    "País Elétrico (Erasmo Carlos / Paulo Miklos)",
    "Saudosa Maloca (Adoniran Barbosa)",
    "Sonífera Ilha (Branco Mello / Carlos Barmack / Ciro Pessoa / Marcelo Fromer / Tony Bellotto)",
    "Aluga-se (Raul Seixas / Claudio Roberto)",
    "Lugar Nenhum (Arnaldo Antunes / Marcelo Fromer / Sergio Britto / Charles Gavin / Tony Bellotto)",
    "Bichos Escrotos (Nando Reis / Arnaldo Antunes / Sergio Britto)",
    "É Preciso Saber Viver (Erasmo Carlos / Roberto Carlos)"
  )
)

# Caminho para o arquivo de áudio completo
audio_completo <- file.path(output_folder, "audio_completo.mp3")

# Baixar o áudio completo
baixar_audio_completo(yt_dlp, video_url, audio_completo)

# Dividir o áudio em faixas
dividir_audio(ffmpeg, audio_completo, tracks_data, output_folder)

# Limpar arquivos temporários
arquivos <- list.files(output_folder, pattern = "^audio_completo", full.names = TRUE)
file.remove(arquivos)
cat("Processamento concluído.\n")
