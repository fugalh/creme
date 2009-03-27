NAME="Crème Rappel"
RESOURCES="$(NAME).app/Contents/Resources/"
app:
	chmod 755 bin/creme
	rsync -av bin lib "$(RESOURCES)"
	cp `which growlnotify` "$(RESOURCES)"/bin
	zip -r 'Crème Rappel'.{zip,app}

install:
	ruby setup.rb install

config:
	ruby setup.rb config --shebang=never

.PHONY: app install
