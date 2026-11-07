# TV PLAYOUT 0.2

Protótipo desktop multiplataforma de playout para Windows e macOS.

## Novidades da versão 0.2

- Dois players independentes: PREVIEW e PROGRAM.
- O PREVIEW reproduz o clipe selecionado sem áudio, sem interromper o PROGRAM.
- Botão **TAKE → PROGRAM** envia o conteúdo carregado no Preview para o Program.
- O duplo clique em um item da playlist carrega esse item no Preview.
- Clique simples seleciona um item sem interromper a reprodução atual.
- O PROGRAM mantém controles próprios de play, pause, stop, next e seek.
- O avanço automático continua atuando somente no PROGRAM.
- Identificação visual do item que está no ar na playlist.

## Controles

1. Clique em **+ ADICIONAR** e importe um ou mais arquivos.
2. Clique uma vez em um item para selecioná-lo.
3. Use **CARREGAR PREVIEW** ou dê duplo clique no item.
4. Confira o vídeo na tela PREVIEW. O áudio do Preview fica silenciado.
5. Clique em **TAKE → PROGRAM** para colocar esse clipe no Program.
6. Controle a saída pelo conjunto de botões do PROGRAM.

## Requisitos

- CMake 3.21 ou superior.
- Qt 6.5 ou superior, módulos Quick e Multimedia.
- Compilador C++17 (Visual Studio 2022 no Windows; Xcode Command Line Tools no macOS).

## Compilar

```bash
cmake -S . -B build
cmake --build build --config Release
```

No macOS, abra o bundle gerado em `build` ou execute o binário dentro dele.
No Windows, o executável estará na pasta de build correspondente à configuração.

## Limitações conhecidas

Esta versão ainda é um protótipo de interface e reprodução local. Ela **não** implementa:

- Saída NDI.
- Saída SDI via Blackmagic DeckLink.
- Agendamento por data/hora.
- Persistência da playlist e histórico de execução.
- Recuperação automática após falha ou reinicialização.
- Monitoramento de sinal, watchdog ou redundância de saída.
- Garantia de operação broadcast 24/7.

O motor continua baseado em Qt Multimedia. A reprodução de formatos depende dos codecs e backends disponíveis no sistema operacional. O código ainda precisa ser compilado e testado nos ambientes Windows e macOS antes de qualquer uso operacional.

## Próxima etapa sugerida

Versão 0.3: salvar e restaurar playlists, criar histórico de execução e preparar a camada de abstração para integração NDI/DeckLink.
