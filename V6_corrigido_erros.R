# Carregar os pacotes necessários
library(processx)
library(glue)

# URL do vídeo do YouTube
video_url <- "https://www.youtube.com/watch?v=jkyKW_FBaJA"

# Caminhos para yt-dlp e ffmpeg (presume que estão no PATH do sistema)
yt_dlp <- "yt-dlp"
ffmpeg <- "ffmpeg"

# Função para sanitizar nomes de arquivos/pastas
sanitizar_nome <- function(nome) {
  gsub("[/\\:*?\"<>|]", "_", nome) # Substituir caracteres inválidos por "_"
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
    titulo_sanitizado <- sanitizar_nome(titulo)
    cat(glue("Título do vídeo: {titulo_sanitizado}\n"))
    return(titulo_sanitizado)
  }, error = function(e) {
    cat("Erro ao obter o título do vídeo:\n", e$message, "\n")
    stop("Não foi possível obter o título do vídeo.")
  })
}

# Obter o título do vídeo para usar como nome da pasta
titulo_video <- obter_titulo_video(yt_dlp, video_url)
output_folder <- titulo_video
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
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
    end_time <- ifelse(i < nrow(tracks), tracks$inicio[i + 1], NA) # Próximo início ou NA
    title <- sanitizar_nome(tracks$titulo[i])
    output_file <- file.path(output_folder, glue("{sprintf('%02d', i)} - {title}.mp3"))
    
    # Configurar argumentos do ffmpeg
    ffmpeg_args <- c("-i", input_file, "-ss", start_time)
    if (!is.na(end_time)) {
      ffmpeg_args <- c(ffmpeg_args, "-to", end_time)
    }
    ffmpeg_args <- c(ffmpeg_args, "-c:a", "libmp3lame", output_file)
    
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
tracks_data <- data.frame(
  inicio = c(
    "00:00", "00:32", "03:33", "07:12", "10:49", 
    "11:27", "13:50", "16:49", "19:20", "24:06", 
    "27:49", "30:44", "33:24", "36:16", "38:55", 
    "42:16"
  ),
  titulo = c(
    "[apresentador]", "Aluga-se", "Homem Primata", 
    "Domingo", "[Paulo Miklos conversa com o público]", 
    "Nós Estamos Bem", "A Melhor Banda de Todos Os Tempos da Última Semana", 
    "Eu Não Sou um Bom Lugar", "Comida", "Pra Dizer Adeus", 
    "Epitáfio", "Você é Minha", "Sonífera Ilha", 
    "Isso", "Bichos Escrotos", "Flores"
  )
)

# Exibindo o dataframe
print(tracks_data)


# Exibindo o dataframe
print(tracks_data)

# Exibindo o dataframe
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
if (length(arquivos) > 0) {
  file.remove(arquivos)
  cat("Arquivos temporários removidos.\n")
} else {
  cat("Nenhum arquivo temporário encontrado para remover.\n")
}
