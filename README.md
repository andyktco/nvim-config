# nvim-config

Configurația mea de **Neovim** și **tmux**.

Neovim, bazat pe [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), cu:

- **neo-tree**, exploratorul de fișiere din stânga
- **taburi** sus, cu fișierele deschise (mini.tabline)
- suport pentru **Laravel / Filament**: PHP (intelephense), Blade, Tailwind, Emmet, Pint, blade-formatter

tmux, cu:

- tema **Catppuccin Mocha**, cu bara de status sus
- **mouse**: click pe panouri, redimensionare trăgând de margini, scroll
- **vim-tmux-navigator**: `Ctrl+h/j/k/l` trece între panourile tmux și split-urile din nvim
- **resurrect + continuum**: sesiunile se salvează automat și se refac după restart

## Instalare pe un server nou (Ubuntu / Debian)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/andyktco/nvim-config/main/install.sh)
exec $SHELL
nvim
```

`exec $SHELL` reîncarcă terminalul, ca să găsească `nvim`. Merge și în **bash**, și în **zsh**: scriptul adaugă `~/.local/bin` în PATH în `~/.bashrc` și, dacă serverul are zsh, și în `~/.zshrc`.

Scriptul se poate rula **de câte ori vrei**. Fiecare pas face doar ce lipsește sau s-a schimbat, așa că după un update la config rulezi aceeași comandă și primești ce e nou.

La prima pornire a lui nvim, uneltele LSP se instalează în fundal. Durează cam un minut.

### Ce face `install.sh`

1. Instalează cu `apt` pachetele care lipsesc: `git`, `curl`, `build-essential`, `unzip`, `ripgrep`, `nodejs`, `npm`, `tmux`. Pentru asta cere parola de `sudo`.
2. Instalează `tree-sitter` și Neovim **0.12.6** în `~/.local/bin`, fără `sudo`.
3. Clonează configurația în `~/.config/nvim`. Dacă exista deja o configurație acolo, o mută în `~/.config/nvim.bak.<timestamp>`. Dacă e deja clonată, doar o actualizează (`git pull`).
4. Aliniază pluginurile nvim la versiunile din `nvim-pack-lock.json`, ca serverul să aibă exact aceleași versiuni.
5. Face un link `~/.config/tmux` către folderul `tmux/` din repo. Un `~/.config/tmux` sau `~/.tmux.conf` existent e mutat ca backup.
6. Instalează sau actualizează Catppuccin (în `~/.local/share/tmux/`), TPM și pluginurile tmux (în `~/.tmux/plugins/`). Dacă tmux rulează, îi reîncarcă configurația.
7. Te avertizează dacă Node e mai vechi de 18 sau tmux mai vechi de 3.2.

> Nu modifica fișiere din `~/.config/nvim` direct pe server: `git pull` o să refuze update-ul. Modifici pe calculatorul principal, faci push, apoi rulezi din nou scriptul.

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

Pe server, ca să iei modificările, rulezi din nou scriptul de instalare (comanda de mai sus).

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

## tmux

Prefixul e **`Ctrl+a`**: apeși `Ctrl+a`, îl eliberezi, apoi apeși tasta comenzii.

| Tastă                    | Ce face                                              |
| ------------------------ | ---------------------------------------------------- |
| `tmux` / `tmux a`        | pornește o sesiune nouă / te reconectează la ultima  |
| `prefix \|`              | împarte vertical (panou nou în dreapta)              |
| `prefix -`               | împarte orizontal (panou nou dedesubt)               |
| `prefix c`               | fereastră nouă (tab)                                 |
| `prefix 1..9`            | sari la fereastra 1..9                               |
| `prefix ,`               | redenumește fereastra                                |
| `prefix x`               | închide panoul                                       |
| `prefix m`               | mărește panoul pe tot ecranul / revino               |
| `prefix h/j/k/l`         | redimensionează panoul (ține apăsat ca să repete)    |
| `Ctrl+h/j/k/l`           | mută-te între panouri (și între split-urile din nvim) |
| `prefix Ctrl+l`          | curăță ecranul (în locul lui `Ctrl+l` din terminal)  |
| `prefix d`               | detașează sesiunea (rămâne pornită în fundal)        |
| `prefix s`               | lista de sesiuni                                     |
| `prefix [`               | modul copiere: `v` selectează, `y` copiază, `q` ieși |
| `prefix Ctrl+s` / `Ctrl+r` | salvează / reface sesiunile manual                 |
| `prefix r`               | reîncarcă `tmux.conf`                                |
| `prefix Ctrl+a`          | trimite un `Ctrl+a` real (începutul liniei în shell) |

Cu mouse-ul: click pe un panou ca să-l activezi, tragi de margine ca să-l redimensionezi, rotița face scroll. Ce selectezi cu mouse-ul se copiază în clipboard. Dacă vrei selecția normală a terminalului, ține apăsat **Shift**.
