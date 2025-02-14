library(tidyverse)
library(fs)
library(magrittr)

# Definir o diretório onde os arquivos estão armazenados
audio_dir <- "C:/Users/tenorioabs/OneDrive/ciencia_de_dados/R/youtube_extrai_mp3/audios_playlist"

# Definir o tamanho máximo dos arquivos de saída (150 MB em bytes)
max_size <- 150 * 1024 * 1024  

# Listar todos os arquivos na pasta (assumindo que são .mp3)
audio_files <- dir_ls(audio_dir, regexp = "\\.mp3$") %>% 
  file_info() %>% 
  arrange(path)  # Ordena os arquivos corretamente

# Criar a pasta de saída se não existir
output_dir <- file.path(audio_dir, "arquivos_combinados")
dir_create(output_dir)

# Função para obter o tamanho do arquivo
file_size_bytes <- function(file) {
  file.info(file)$size
}

# Criar lotes de arquivos combinados respeitando o limite de 150 MB
current_batch <- c()  # Alterado para vetor de caracteres
current_size <- 0
batch_index <- 1

for (file in audio_files$path) {
  file_size <- file_size_bytes(file)
  
  if (current_size + file_size > max_size) {
    # Criar o arquivo combinado usando FFmpeg
    batch_file <- file.path(output_dir, paste0("audio_combined_", batch_index, ".mp3"))
    
    # Criar arquivo temporário com a lista de arquivos
    writeLines(current_batch, "temp_list.txt")
    
    # Executar FFmpeg para juntar os arquivos
    system(sprintf('ffmpeg -f concat -safe 0 -i temp_list.txt -c copy "%s"', batch_file), intern = TRUE)
    
    # Resetar para o próximo lote
    batch_index <- batch_index + 1
    current_batch <- c()  # Reinicia o vetor de caracteres
    current_size <- 0
  }
  
  # Adicionar o arquivo ao lote
  current_batch <- c(current_batch, sprintf("file '%s'", file))
  current_size <- current_size + file_size
}

# Criar o último lote caso existam arquivos restantes
if (length(current_batch) > 0) {
  batch_file <- file.path(output_dir, paste0("audio_combined_", batch_index, ".mp3"))
  
  writeLines(current_batch, "temp_list.txt")
  
  system(sprintf('ffmpeg -f concat -safe 0 -i temp_list.txt -c copy "%s"', batch_file), intern = TRUE)
}

# Remover arquivo temporário
file_delete("temp_list.txt")

cat("Processo concluído! Arquivos combinados foram salvos em:", output_dir, "\n")
