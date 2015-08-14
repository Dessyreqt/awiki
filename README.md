# Awiki

A personal wiki for Atom.

This project is based on the vimwiki package for vim, and strives for basic compatibility with that package. You should be able to point your awiki index to your vimwiki index and it should work just fine!

## Features

### Wiki index page

Awiki supports only one wiki, which can be specified in the settings page. Pressing `alt-w` will open your wiki's index location. This can also be accessed from the main menu under Packages/Awiki/Open Wiki index

### Links

Links are created by surrounding a word with a set of brackets like so:
```
[[Link to another wiki page]]
```
You can also create a link with a description like so:
```
[[destination|description of the link that will look better in HTML]]
```
Finally, you can also move to a different directory by employing the following:
```
[[..\destination|Link to a file in a parent folder]]
[[destinationFolder\destination|Link to a file in a child folder]]
```

You can follow this link by putting the cursor on the link and hitting `alt-enter`. You can also follow it by right-clicking on it and selecting "Open Wiki Link".

You can navigate back to the previous page by pressing `alt-backspace`.
