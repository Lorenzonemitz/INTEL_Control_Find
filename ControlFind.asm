;==========================================
;
;	Programa que le e printa as linhas de uma palavra pesquisada,
;	mas sem printar as palavras antes e depois
;
;==========================================



;
; 		Metodos dos nomes no programa:
;
;		nome_nome eh uma funcao
;		NomeNome eh uma variavel
;		nomeNome eh um rotulo de jump
;	


CR EQU 0Dh
LF EQU 0AH

.model small
.stack
	.data

	;Variaveis de Arquivo
	NomeArquivo db 256 dup(?); Nome do arquivo lido da linhade comando
	Handle 		dw 0;Ponteiro do arquivo
	
	;Variaveis da Leitura do Arquivo
	Linha			dw 0; Linha atual do arquivo
	Char 			db 0;Caractere atual lido do Arquivo
	CharUpper		db 0;Caractere atual lido do Arquivo maiusculo
	Continua 		db 10 dup (?); Varivael do S ou N digitado pelo user
	Palavra	 		db 100 dup (?); Palavra buscada no cntrl f
	PalavraUpper	db 100 dup (?); Palavra buscada no cntrl f MAIUSCULO
	Tamanho  		dw 0; Tamanho da palavra a ser lida no cntrl f
	UmaAntes 		db 100 dup (?); Palavra anterior da que esta sendo lida
	StringAux 		db 100 dup (?); Variavel auxiliar para guardar a palavra que esta sendo lida
	
	;Variaveis Auxiliares
	Fim db CR, LF, 0; Terminador de linha

	;Variaveis int_string
	SwN	 	dw 0
	SwF 	db 0
	SwM 	dw 0
	String 	db 10 dup (?)

	;Mensagens do Programa
	TextoBuscaPalavra 	db "-- Que palavra voce quer buscar?",CR, LF, 0
	TextoOcorrencias 	db CR, LF, "-- Foram encontradas as seguintes ocorrencias:",CR, LF, 0
	TextoFimOcorrencias db "-- Fim das ocorrencias.",CR, LF, 0
	TextoSN 			db "-- Quer buscar outra palavra? (S/N)",CR, LF, 0
	TextoSemOcorrencias db "-- Nao foram encontradas ocorrencias.",CR, LF, 0
	TextoEncerrando 	db CR, LF,"-- Encerrando.",CR, LF, 0
	TextoLinha 			db "Linha ", 0
	TextoDoisPontos		db ": ", 0
	
	;Mensagens de Erro
	MsgErroUsuario 	db CR,LF, "-- Por favor, responda somente S ou N. ", CR, LF, 0 ;Erro ao nao ler S ou N
	MsgErroLeitura 	db "Erro ao ler o arquivo!", CR, LF, 0 ;Erro na leitkura do arquivo
	MsgErroFecha 	db "Erro ao fechar arquivo!", CR, LF, 0 ;Erro ao fechar arquivo
	MsgErroAbrir 	db "O arquivo de entrada '", 0 ;Erro ao abrir arquivo
	MsgErroAbrir2	db "' nao existe!", CR, LF, 0 ;Erro ao abrir arquivo 2
	
	.code
		.startup
			
		;leComando:
		call 	le_comando; Le o nome do arquivo
	
		

	loopMain:
		;Pergunta qual palavra vai ler 
		;Abre arquivo
		call 	abre_arquivo
		JC 		erroAbrir ;– Se ok: CF = 0 e AX = handle do arquivo
		MOV 	Handle, AX
		lea		bx,	TextoBuscaPalavra
		call	printa_string
		;Le a palavra do cntrl f
		mov		cx,100; Tam max da palavra
		lea		bx,Palavra
		call	le_string
		lea		bx, TextoOcorrencias
		call 	printa_string
		call	control_f
	
	fimOcorrencias:
		; Fim das ocorrencias
		lea		bx,	TextoFimOcorrencias
		call	printa_string
	querOutra:
		; Pergunta quer outra palavra
		lea		bx,	TextoSN
		call	printa_string
		;Le do teclado S ou N (bx=BufferTec, cx=10)	cx = caracteres
		mov		cx,5
		lea		bx,Continua
		call	le_string
		;Coloca 1 letra do Continua
		LEA DI, Continua
		MOV DL, [DI]
		;Trata N
		CMP 	dl, 'N'
		JE		encerra
		;Trata n
		CMP 	dl, 'n'
		JE		encerra
		;Trata s
		CMP 	dl, 's'
		JNE 	naoSzinho
		lea 	bx, Fim
		call	printa_string
		JMP		loopMain
	naoSzinho:
		;Trata S	
		CMP 	dl, 'S'
		JNE 	nenhumSN
		lea 	bx, Fim
		call	printa_string
		JMP		loopMain
	nenhumSN:
		;Se nem S ou N 
		lea		bx,	MsgErroUsuario
		call	printa_string
		JMP 	querOutra
		
	erroAbrir:
	;Printa erro de abertura
		lea		bx,	MsgErroAbrir
		call	printa_string
		lea		bx,	NomeArquivo
		call	printa_string
		lea		bx,	MsgErroAbrir2
		call	printa_string
		JMP 	encerra
		
	
	encerra:
		;Encerra programa
		lea		bx,	TextoEncerrando
		call	printa_string
		.exit
		
;==========================================
abre_arquivo PROC FAR

		MOV Ah, 3DH
		XOR AL, AL
		LEA DX, NomeArquivo ;– DS:DX = nome do arquivo
		INT 21H

		RET

abre_arquivo endp
	
;==========================================
fecha_arquivo PROC FAR

		MOV AH, 3EH
		MOV BX, Handle
		INT 21H

		RET

fecha_arquivo endp

;==========================================
leitura_arquivo PROC FAR

		MOV AH, 3FH
		MOV BX, Handle
		MOV CX, 1; CX = número de bytes a serem lidos
		LEA DX, Char
		INT 21H

		RET

leitura_arquivo endp

;==========================================
printa_char PROC FAR

		MOV DL, Char ; char a ser impresso
		MOV AH, 02H ; código da rotina print char
		INT 21H ; chamada da syscall 02H

		RET

printa_char endp

;==========================================
int_string PROC FAR
	;Transforma int em String

		mov SwN,ax

		mov cx,5

		mov SwM,10000

		mov SwF,0

	intStringDo:

		mov dx,0
		mov ax,SwN
		div SwM

		cmp al,0
		jne intStringStore
		cmp SwF,0
		je intStringContinua
	intStringStore:
		add al,'0'
		mov [bx],al
		inc bx

		mov SwF,1
	intStringContinua:

		mov SwN,dx

		mov dx,0
		mov ax,SwM
		mov bp,10
		div bp
		mov SwM,ax

		dec cx

		cmp cx,0
		jnz intStringDo

		cmp SwF,0
		jnz intStringContinua2
		mov [bx],'0'
		inc bx
	
	intStringContinua2:

		mov byte ptr[bx],0

		RET

int_string endp

;==========================================
printa_string PROC FAR

		mov dl,[bx]
		cmp dl,0
		je ps_1

		push bx
		mov ah,2
		int 21H
		pop bx

		inc bx

		jmp printa_string

		ps_1:
		RET

printa_string endp
	
;==========================================
le_comando PROC FAR

		push ds ; Salva as informacoes de segmentos
		push es
		mov ax, ds ; Troca DS com ES para poder usa o REP MOVSB
		mov bx, es
		mov ds, bx
		mov es, ax
		mov si, 80h ; Obtem o tamanho da linha de comando e coloca em CX
		mov ch, 0
		mov cl, [si]
		mov ax, cx ; Salva o tamanho do string em AX, para uso futuro
		mov si, 81h ; Inicializa o ponteiro de origem
		lea di, NomeArquivo - 1; Inicializa o ponteiro de destino
		rep movsb
		pop es ; retorna os dados dos registradores de segmentos
		pop ds
		
		RET
		
le_comando endp

;==========================================
le_string	proc	near

		mov		dx,0
		mov 	ax,0

	readString1:
		mov		ah,7
		int		21H
		cmp		al,0DH
		jne		readStringA
		
		mov		byte ptr[bx],0
		
		RET
		

	readStringA:
		cmp		al,08H
		jne		readStringB

		cmp		dx,0
		jz		readString1

		push	dx
		mov		dl,08H
		mov		ah,2
		int		21H
		mov		dl,' '
		mov		ah,2
		int		21H
		mov		dl,08H
		mov		ah,2
		int		21H
		pop		dx
		dec		bx
		inc		cx
		dec		dx
		jmp		readString1

	readStringB:
		
		cmp		cx,0
		je		readString1
		
		cmp		al,' '
		jl		readString1

		mov		[bx],al
		inc		bx
		dec		cx
		inc		dx
		push	dx
		mov		dl,al
		mov		ah,2
		int		21H
		pop		dx

		jmp		readString1

le_string	endp
;==========================================
control_f PROC far 

	;Funcao principal de ler o arquivo e comparar
	;Preparacoes:
	
		
	;Colocar linha em 1, ver o tamanho da Palavra
		MOV 	Linha, 1
		MOV  	Tamanho, 0
		call	tamanho_palavra
		call	upper_palavra
		; Inicializa o índice para percorrer o vetor
		MOV si, 0
		
	loopCompara:
		call	leitura_arquivo
		JC 		erroLeitura
		or 		ax,ax
		JZ 		fimArquivo; AX = 0 se for final do arq
		;Checa pontuacao na palavra
		CMP		si, Tamanho
		JE		checaPassou
		;Checa LF
		cmp		Char, 0AH
		JE		finalLinha
		
		; Transforma char em maiusculo se letra
		MOV		al, Char
		call	upper_char
		MOV		CharUpper, al
		MOV 	al, byte ptr[Palavra + si]
		call	upper_char
		;Comparar as letras
		cmp		al,	CharUpper
		JE 		letraIgual
		
		JMP		percorreAteEspaco
		
		;Comparar as letras
		;cmp		al,	CharUpper
		;JE 		letraIgual
		;cmp		Char, 020h
		;JNE		percorreAteEspaco
		;MOV		si, 0
		;JMP		loopCompara
		
		
	;Quando alguma letra for diferente
	percorreAteEspaco:
		call	leitura_arquivo
		JC 		erroLeitura
		cmp		Char, 020h
		je 		fimPercorreAteEspaco
		;Checa CR
		cmp		Char, 0Dh
		je 		fimPercorreAteEspaco
		;Checa Lf 
		cmp		Char, 0Ah
		je 		finalLinha
		
	fimPercorreAteEspaco:
		MOV		si,0
		JMP		loopCompara
		
	checaPassou:
		;Checa se "espaco" ou pontuacao
		cmp		Char, ','
		je 		printaIgual
		cmp		Char, '.'
		je 		printaIgual
		cmp		Char, '!'
		je 		printaIgual
		cmp		Char, '?'
		je 		printaIgual
		cmp		Char, 020h
		je 		printaIgual
		cmp		Char, ':'
		je 		printaIgual
		cmp		Char, ';'
		je 		printaIgual
		cmp		Char, 0Dh
		je 		printaIgual
		;Se nao for pontuacao nem espaco
		jmp		percorreAteEspaco
			
	letraIgual:
	;Letra igual mas nao necessariamente terminou  
		; Incrementa o índice
		inc 	si
		jmp		loopCompara
			
	printaIgual:
	;Achou a palavra entao printa ela
		;Linha "%d": palavra
		lea 	bx, TextoLinha
		call	printa_string
		MOV		ax, Linha
		lea		bx,	String
		call	int_string
		lea 	bx, String
		call	printa_string
		lea 	bx, TextoDoisPontos
		call	printa_string
		lea 	bx, PalavraUpper
		call	printa_string
		lea		bx, Fim
		call	printa_string
		mov		si, 0
		jmp		loopCompara
		
	finalLinha:
		MOV		ax, Linha
		inc		AX
		MOV		Linha,AX
		MOV		si,0
		JMP		loopCompara
		
	fimArquivo:
		;Fecha arquivo
		call 	fecha_arquivo
		JC 		erroFecha; Se ok: CF = 0
		JMP 	fimControlF
		
	erroFecha:
		lea		bx,	MsgErroFecha
		call	printa_string
		JMP 	fimControlF
		
		erroLeitura:
		lea		bx,	MsgErroLeitura
		call	printa_string
		JMP 	fimArquivo
		
		
	fimControlF:
		call limpa_palavra
		call limpa_palavra_upper
		RET
	
control_f endp 
;==========================================
tamanho_palavra PROC FAR
	;Funcao que descobre o tamanho da palavra no cntrl f
	
		; Inicializa o índice para percorrer o vetor
		mov si, 0
		mov cx, 0
		; Carrega o elemento atual do vetor em AL
		
	loopTamanhoPalavra:
		mov 	al, [Palavra + si]
		cmp 	al, 0h; Ve quando termina a string '/0'
		je 		fimTamanhoPalavra
		inc 	si
		inc 	cx
		JMP		loopTamanhoPalavra
		
	fimTamanhoPalavra:
		mov 	Tamanho, cx 
		
		RET
	
tamanho_palavra endp
;==========================================
upper_char	PROC FAR
; Função para transformar um caractere em maiúsculo se for uma letra

		;AL contém o caractere
		; Verifica se letra minuscula
		cmp al, 'a'
		jb fimUpper
		cmp al, 'z'
		ja fimUpper
		; Converte para maiúsculo (subtrai 32 para a-z)
		sub al, 20h
  
	fimUpper:
		RET
		
upper_char	endp
;==========================================
upper_palavra	PROC FAR
; Função para transformar um caractere em maiúsculo se for uma letra

		;AL contém o caractere
		; Verifica se letra minuscula
		mov 	si,0 
	loopUpperPalavra:
		mov 	al,[Palavra+ si]
		cmp		al, 'a'
		jb 		fimUpperPalavra
		cmp 	al, 'z'
		ja 		fimUpperPalavra
		; Converte para maiúsculo (subtrai 32 para a-z)
		sub al, 20h
  
	fimUpperPalavra:
		MOV 	[PalavraUpper + si], al
		inc 	si
		cmp 	si, Tamanho
		JNE		loopUpperPalavra
		RET
		
upper_palavra	endp
;==========================================
limpa_palavra	PROC FAR
; Função para limpar a palavra depois de ler

		;Limpa a variavel Palavra
		mov 	si,0 
	loopLimpaPalavra:
		mov 	[Palavra + si], 0
		inc 	si
		cmp 	si, 99 
		JNE		loopLimpaPalavra
		RET
		
limpa_palavra	endp
;==========================================
limpa_palavra_upper	PROC FAR
; Função para limpar a palavra upper depois de ler

		;Limpa a variavel Palavra
		mov 	si,0 
	loopLimpaPalavraUpper:
		mov 	[PalavraUpper + si], 0
		inc 	si
		cmp 	si, 99
		JNE		loopLimpaPalavraUpper
		RET
		
limpa_palavra_upper	endp

	end
	
	