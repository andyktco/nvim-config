# nvim-config

Configurația mea de Neovim, bazată pe [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), cu:

- **neo-tree**, exploratorul de fișiere din stânga
- **taburi** sus, cu fișierele deschise (mini.tabline)
- suport pentru **Laravel / Filament**: PHP (intelephense), Blade, Tailwind, Emmet, Pint, blade-formatter

## Instalare pe un server nou (Ubuntu / Debian)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/andyktco/nvim-config/main/install.sh)
source ~/.bashrc
nvim
```

La prima pornire, pluginurile, parserele și uneltele LSP se instalează singure. Durează cam un minut.

### Ce face `install.sh`

1. Instalează cu `apt` pachetele care lipsesc: `git`, `curl`, `build-essential`, `unzip`, `ripgrep`, `nodejs`, `npm`. Pentru asta cere parola de `sudo`.
2. Instalează `tree-sitter` și Neovim **0.12.6** în `~/.local/bin`, fără `sudo`.
3. Clonează configurația în `~/.config/nvim`. Dacă exista deja o configurație acolo, o mută în `~/.config/nvim.bak.<timestamp>`. Dacă e deja clonată, doar o actualizează (`git pull`).
4. Te avertizează dacă Node e mai vechi de versiunea 18.

Fără `sudo`, scriptul merge mai departe și nvim se instalează oricum. Unele funcții nu merg însă, în funcție de ce lipsește:

| Lipsește  | Ce pierzi                                   |
| --------- | ------------------------------------------- |
| `git`     | tot: configurația nu se poate clona         |
| `gcc`     | culorile Treesitter (rămân culorile simple) |
| `node`    | LSP pentru PHP, Blade și Tailwind           |
| `ripgrep` | căutarea în proiect (`<space>sg`)           |
| `unzip`   | unele unelte instalate prin Mason           |

### Iconițe

Iconițele depind de fontul din **terminalul local**, nu de server. Pune un Nerd Font (de exemplu *JetBrainsMono Nerd Font*) în terminalul din care te conectezi prin SSH.

## Actualizare

Pe calculatorul principal, după ce schimbi ceva în config:

```bash
cd ~/.config/nvim && git commit -am "ce am schimbat" && git push
```

Pe server, ca să iei modificările:

```bash
git -C ~/.config/nvim pull
```

## Scurtături utile

| Tastă                 | Ce face                                   |
| --------------------- | ----------------------------------------- |
| `\`                   | deschide / închide exploratorul neo-tree  |
| `Shift+l` / `Shift+h` | tabul următor / anterior                  |
| `<space>bd`           | închide tabul curent                      |
| `<space>sf`           | caută fișiere după nume                   |
| `<space>sg`           | caută text în proiect                     |
| `<space><space>`      | listă cu fișierele deschise               |
| `<space>f`            | formatează fișierul                       |
| `grd`                 | sari la definiție                         |
| `Ctrl+h` / `Ctrl+l`   | fereastra din stânga / dreapta            |
