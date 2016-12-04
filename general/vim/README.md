# Install Vim

```
// to install core vim extension
./install-core.sh

// to install big huge extension, such as YouCompleteMe
```
## PS
### bundle.tar.gz

This file contains core extension of Vim to use.

### Special extesion dependency

#### Taglist

Need ctags to install, **Exuberant Ctags**

#### YCM

Need clang for c language, and higer gcc version

```
cd ~/.vim/bundle/YouCompleteMe

#With clang
./install.py --clang-completer

#Without clang
./install.py

#All
./install.py --all
```

#### NeoComplete

Need lua+ vim version

[Follow here](https://github.com/Shougo/neocomplete.vim#installation)

#### python-markdown-instant

```
pip install markdown
pip install pygments
```

Usage

```
:Instantmd
```
