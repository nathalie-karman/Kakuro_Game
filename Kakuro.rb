require 'gtk3'
include Gtk
require_relative './Sources/MenuPrincipal.rb'

#Lancement du jeu
mp = MenuPrincipal.new
mp.chargerMenuPrincipal
mp.lanceToi
