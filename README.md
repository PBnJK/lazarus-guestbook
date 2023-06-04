# Guest Book
Feito no Lazarus em ~2-3 dias (nunca mexi com Pascal na minha vida, em minha defesa)

## Arquivos relevantes

`time_ll.txt`

- Primeira linha: Última hora exata (15:00h, 16:00h, etc) em formato de Timestamp Unix;

- Segunda linha: Último índice de frase salvo. Considerando uma lista `X` com os itens `['a', 'b', 'c']`, o índice 0 será 'a', o 1 será 'b', e o 2 será 'c'.

`db_people.csv`

- Primeira linha: "header". O título dos valores a seguir;

- Linhas subsequentes: Valores, no formato `"NOME","FRASE"`


O código está em `guestbook.pas`. Cuidado! Ele é horroroso!!
