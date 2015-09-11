raven.vim
=========
Send code or text from vim to R, Julia, Python, or any other REPL running in a
Tmux session. Raven provides flexibility in choosing/creating a pane to send
to and a few basic commands to easily interact with the selected pane including
sending any command, current line, current selection, and current paragraph.

The core of the plugin is not filetype specific, although support for specific
filetypes is possible with both R and Julia supported out of the box. The plugin
works with both the terminal and GUI versions of Vim. When Vim is running inside
the terminal, code is sent to another Tmux pane (can be in a different window or
even session as Vim). When Vim is running from a GUI, code is sent to a Tmux
pane running in the terminal. 

You can choose to have Raven open a pane in a horizontal or vertical orientation
or you can select an existing pane from a list of all panes across all Tmux
windows and sessions. Pane selection is remembered throughout the session, but
is not permanent, meaning you are able to change the current selected pane to
send code to at any time.



Installation
============
Unless you have a preferred installation method, I recommend installing
[pathogen][https://github.com/tpope/vim-pathogen] and then simply run:

    cd ~/.vim/bundle
    git clone git://github.com/michaelmalick/vim-raven.git

To access the help file in vim run:

    :Helptags

For the plugin to work you need to have [Tmux](http://tmux.sourceforge.net/)
installed. If you don't have Tmux installed and are running a Mac, I recommend
first installing [HomeBrew](http://brew.sh/), then simply run:

    brew install tmux

To date, the plugin has only been tested using Tmux v1.9a. There is currently no
support for Windows.



Usage
=====
Whether you are running Vim in the terminal or a GUI, you first need to start
Tmux in the terminal:

    tmux new -s mysession

The `:RavenPanes` and `:Raven` commands are the core of the plugin. The
`:RavenPanes` command takes no arguments and is called like

    :RavenPanes

This opens a prompt window that lets you select an existing Tmux pane to send
commands to or lets you create a new vertical or horizontal pane (see the help
doc for more info about the `:RavenPanes` command). Once a pane is selected,
send commands to it using the `:Raven` command:

    :Raven ls -a

which sends and runs the 'ls -a' command in the selected pane.



By default, Raven creates a number of mappings to make sending text in a buffer
easier. These can be disable by putting `let g:raven_map_keys = 0` in your
`.vimrc` file.

Global mappings:

    <localleader>rr   open the Raven pane selection window
    <localleader>rd   send current line
    <localleader>rs   visual mode: send current selection
    <localleader>rs   normal mode: send current paragraph
    <localleader>rq   delete pane linked to raven

Filetype mappings for R and Julia:

    <localleader>ro  open R/Julia in selected pane
    <localleader>ri  source/include current file
    <localleader>rf  send function definition
    <localleader>rc  clear the selected pane
    <localleader>rw  set working directory to current files directory
    <localleader>rh  get help for a function (R only)

These mappings can be easily changed using (see help doc for list of available
functions):

    nmap <leader>f  <Plug>RavenSendLine
    nmap <leader>s  <Plug>RavenSendParagraph
    vmap <leader>s  <Plug>RavenSendSelection

You can also map custom commands to send using the `RavenSendText` command:

    nmap <silent> <leader>rl :call RavenSendText('ls -a')<CR>

A typical R session might go something like this:
  - Open a new Tmux session called newsess: `tmux new -s newsess`
  - Open dev.R in Vim `vim dev.R`
  - Open a new pane with `<localleader>rr` then hit `1`
  - Open R in the new pane `<localleader>ro`
  - Send the current line to R `<localleader>rd`


Rationale
=========
There are many Vim-Tmux integration plugins and the Vim-R-Plugin provides
support for R, so why create another plugin? 

The majority of the Vim-Tmux integration plugins (including the Vim-R-Plugin) do
not provide flexibility about selecting which Tmux pane to send to. That is,
they only allow you to open a new pane using the plugin or select an existing
Tmux pane, but not both. Similarly, most of the Vim-Tmux plugins do not provide
support for either R or Julia. While the Vim-R-Plugin provides good support
for R, it has dependencies (vimcom) and is too feature rich for my liking.

Raven was written to provide flexibility in interacting with Tmux and to provide
a simple interface for interacting with R, Julia, etc. More specifically, this
plugin was designed to include the best features of
[Slimux](https://github.com/epeli/slimux),
[Vimux](https://github.com/benmills/vimux), and the
[Vim-R-Plugin](https://github.com/jcfaria/Vim-R-plugin) plugins.



License
=======
Raven is [MIT/X11](http://opensource.org/licenses/MIT) licensed.
Copyright (c) 2015 Michael Malick

