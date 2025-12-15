# png_to_webp

Pequeno repositório com um script (`png_to_webp.sh`) para converter imagens PNG para WebP.

## Estrutura

- `png_to_webp.sh` - Script para converter arquivos PNG em WebP.
- `webp_output/` - Pasta de saída onde os arquivos WebP gerados são salvos (ignorável pelo Git).

## Uso

1. Garanta que o script tenha permissão de execução:

```bash
chmod +x png_to_webp.sh
```

2. Execute o script (exemplo):

```bash
./png_to_webp.sh
```

Os arquivos convertidos serão colocados em `webp_output/`.

## Requisitos

É necessário ter o utilitário `cwebp` (parte do pacote libwebp) instalado no sistema.

Instalação (exemplos):

- Debian/Ubuntu:

```bash
sudo apt update && sudo apt install -y webp
```

- macOS (Homebrew):

```bash
brew install webp
```

Após instalar `cwebp`, o script `png_to_webp.sh` poderá executar a conversão.

## Git

A pasta `webp_output/` está no `.gitignore` para evitar commitar arquivos gerados.
